"""Build and verify the submitted plugin in an isolated real Paper server."""

import json
import os
import shutil
import signal
import stat
import subprocess
import tempfile
import time
from pathlib import Path

LOGS = Path("/logs/verifier")
LOGS.mkdir(parents=True, exist_ok=True)
RUNTIME_UID = 65534
CHECK_IDS = {
    "resource_files", "resource_values",
    "lifecycle_gui", "locale_transition", "boundary_locale",
    "two_player_views", "reload_cleanup", "disable_lifecycle",
}


def command(args, cwd, label):
    with (LOGS / f"{label}.stdout.log").open("w") as stdout, (LOGS / f"{label}.stderr.log").open("w") as stderr:
        return subprocess.run(args, cwd=cwd, stdout=stdout, stderr=stderr, timeout=90).returncode


def validate_submission(source):
    if source.is_symlink() or not source.is_dir():
        raise ValueError("submission root must be a regular directory")
    for path in source.rglob("*"):
        mode = path.lstat().st_mode
        if stat.S_ISLNK(mode) or not (stat.S_ISDIR(mode) or stat.S_ISREG(mode)):
            raise ValueError(f"non-regular submission entry: {path.relative_to(source)}")
        if path.is_file():
            relative = path.relative_to(source)
            expected = {"java": {".java"}, "resources": {".yml", ".yaml", ".properties"}}
            if path.suffix not in expected.get(relative.parts[0], set()):
                raise ValueError(f"unsupported submission file: {relative}")
            if path.stat().st_size > 1024 * 1024:
                raise ValueError(f"oversized submission file: {relative}")


def verify():
    report = {"runtime": "Paper 26.1.2 build 63 / Java 25", "status": "infrastructure_failure", "reward": None}
    (LOGS / "reward.txt").unlink(missing_ok=True)
    (LOGS / "behavior.json").unlink(missing_ok=True)
    # The root-owned orchestrator, not the plugin JVM, owns reward files.
    Path("/logs").chmod(0o700)
    LOGS.chmod(0o700)
    Path("/tests").chmod(0o700)
    try:
        validate_submission(Path("/app/src/main"))
    except ValueError as exc:
        report.update(status="invalid_submission", reward=0, error=str(exc))
        return report
    resource_root = Path("/app/src/main/resources/lang")
    en_resource = resource_root / "en_us.properties"
    ru_resource = resource_root / "ru_ru.properties"
    resource_files = en_resource.is_file() and ru_resource.is_file()
    ru_text = ru_resource.read_text(encoding="utf-8", errors="replace") if ru_resource.is_file() else ""
    resource_values = (
        resource_files
        and "title=Настройки" in ru_text
        and "save=Сохранить" in ru_text
    )
    support_checks = [
        {"id": "resource_files", "type": "file_exists", "path": "src/main/resources/lang/en_us.properties", "passed": resource_files,
         "detail": "English and Russian locale resources are present"},
        {"id": "resource_values", "type": "file_contains", "path": "src/main/resources/lang/ru_ru.properties", "passed": resource_values,
         "detail": "Russian resource contains title and save translations"},
    ]
    if not resource_files or not resource_values:
        checks = support_checks + [
            {"id": check_id, "type": "paper_server_event_probe", "passed": False,
             "detail": "runtime probe skipped because locale resources are incomplete"}
            for check_id in sorted(CHECK_IDS - {"resource_files", "resource_values"})
        ]
        report.update(status="evaluated", reward=0, checks=checks,
                      integrity_scope="resource preflight failed before Paper startup")
        return report
    with tempfile.TemporaryDirectory(prefix="deployment-verify-") as raw:
        root = Path(raw)
        root.chmod(0o755)
        classes = root / "classes"
        classes.mkdir()
        jars = sorted(Path("/opt/paper").glob("*.jar")) + sorted(Path("/opt/paper/libraries").rglob("*.jar")) + sorted(Path("/opt/paper/versions").rglob("*.jar"))
        classpath = os.pathsep.join(map(str, jars))
        sources = sorted(Path("/app/src/main/java").rglob("*.java"))
        rc = command(["javac", "-proc:none", "-encoding", "UTF-8", "--release", "25", "-cp", classpath,
                      "-d", str(classes), *map(str, sources)], root, "candidate_compile")
        if rc:
            report.update(status="candidate_compile_failure", reward=0)
            return report
        shutil.copytree("/app/src/main/resources", classes, dirs_exist_ok=True)
        server = root / "server"
        plugins = server / "plugins"
        plugins.mkdir(parents=True)
        if command(["jar", "cf", str(plugins / "Localization.jar"), "-C", str(classes), "."], root, "candidate_jar"):
            raise RuntimeError("candidate packaging failed")
        probe_classes = root / "probe_classes"
        probe_classes.mkdir()
        if command(["javac", "-proc:none", "-encoding", "UTF-8", "--release", "25", "-cp", classpath + os.pathsep + str(classes),
                    "-d", str(probe_classes), "/tests/ForgeVerifier.java"], root, "probe_compile"):
            raise RuntimeError("hidden probe compilation failed; inspect probe_compile.stderr.log")
        (probe_classes / "plugin.yml").write_text("name: ForgeVerifier\nversion: '6.0'\nmain: ForgeVerifier\napi-version: '26.1'\ndepend: [Localization]\n")
        if command(["jar", "cf", str(plugins / "ForgeVerifier.jar"), "-C", str(probe_classes), "."], root, "probe_jar"):
            raise RuntimeError("hidden probe packaging failed")
        for name in ("libraries", "versions", "cache"):
            if (Path("/opt/paper") / name).exists():
                (server / name).symlink_to(Path("/opt/paper") / name, target_is_directory=True)
        (server / "eula.txt").write_text("eula=true\n")
        (server / "server.properties").write_text(
            "online-mode=false\nenforce-secure-profile=false\nserver-ip=127.0.0.1\n"
            "view-distance=2\nsimulation-distance=2\nspawn-protection=0\n"
            "level-name=world\nlevel-type=minecraft:flat\ngenerate-structures=false\n"
            "level-seed=61723\ngamemode=creative\nallow-flight=true\nmax-tick-time=60000\n"
            'generator-settings={"layers":[{"block":"minecraft:bedrock","height":1},{"block":"minecraft:dirt","height":2},{"block":"minecraft:grass_block","height":1}],"biome":"minecraft:plains"}\n'
        )
        behavior_path = server / "probe-output/behavior.json"
        (server / "probe-output").mkdir()
        # Do not follow Paper library symlinks while assigning the writable
        # server workspace to an unprivileged, supplementary-group-free JVM.
        for path in [server, *server.rglob("*")]:
            if not path.is_symlink():
                os.chown(path, RUNTIME_UID, RUNTIME_UID)
        isolation = subprocess.run(
            ["python3", "-c", "import os,json; "
             "checks={p:os.access(p,mode) for p,mode in "
             "[('/logs/verifier',os.W_OK),('/tests',os.R_OK),('/app/build.sh',os.W_OK)]}; "
             "print(json.dumps({'uid':os.getuid(),'unexpected_access':checks}),flush=True); "
             "assert not any(checks.values()), checks"],
            user=RUNTIME_UID, group=RUNTIME_UID, extra_groups=[],
            capture_output=True, text=True,
        )
        (LOGS / "isolation.stdout.log").write_text(isolation.stdout)
        (LOGS / "isolation.stderr.log").write_text(isolation.stderr)
        if isolation.returncode:
            raise RuntimeError("runtime access preflight failed; inspect isolation.stdout.log and isolation.stderr.log")
        (LOGS / "isolation.json").write_text(json.dumps({
            "runtime_uid": RUNTIME_UID, "grader_files_os_protected": True,
            "check_output": isolation.stdout.strip(),
            "same_jvm_probe_isolation": "not_established",
        }, indent=2) + "\n")
        with (LOGS / "server.log").open("w") as output, (LOGS / "client.log").open("w") as client_log:
            proc = subprocess.Popen(["java", "-Xms512M", "-Xmx2G", "-jar", "/opt/paper/paper.jar", "--nogui"],
                                    cwd=server, stdin=subprocess.PIPE, stdout=output, stderr=subprocess.STDOUT, text=True,
                                    user=RUNTIME_UID, group=RUNTIME_UID, extra_groups=[], start_new_session=True)
            client = None
            try:
                deadline = time.monotonic() + 300
                while time.monotonic() < deadline:
                    text = (LOGS / "server.log").read_text(errors="replace")
                    if 'Done (' in text:
                        client = subprocess.Popen(["node", "/tests/client.js"], stdout=client_log, stderr=subprocess.STDOUT)
                        break
                    if proc.poll() is not None:
                        raise RuntimeError("server exited before readiness; inspect server.log")
                    time.sleep(0.25)
                if client is None:
                    raise RuntimeError("server readiness deadline exceeded; inspect server.log for last stage")
                while time.monotonic() < deadline:
                    if behavior_path.is_file():
                        result = json.loads(behavior_path.read_text())
                        checks = result.get("checks", [])
                        checks = support_checks + checks
                        if len(checks) != len(CHECK_IDS) or {c["id"] for c in checks} != CHECK_IDS:
                            raise RuntimeError("incomplete behavioral check ledger")
                        if any(type(c.get("passed")) is not bool for c in checks):
                            raise RuntimeError("non-boolean behavioral check")
                        (LOGS / "behavior.json").write_text(json.dumps(result, indent=2) + "\n")
                        report.update(status="evaluated", reward=int(all(c["passed"] for c in checks)), checks=checks,
                                      integrity_scope="OS grader files isolated; same-JVM probe integrity pending")
                        return report
                    if proc.poll() is not None:
                        raise RuntimeError("server exited without behavioral ledger; inspect server.log and client.log")
                    if client.poll() is not None:
                        raise RuntimeError("protocol client exited before probes; inspect client.log")
                    time.sleep(0.25)
                raise RuntimeError("behavior deadline exceeded; inspect PROBE_STAGE and client login logs")
            finally:
                if client and client.poll() is None:
                    client.terminate()
                    try: client.wait(timeout=10)
                    except subprocess.TimeoutExpired: client.kill(); client.wait()
                if proc.poll() is None:
                    try:
                        proc.stdin.write("stop\n"); proc.stdin.flush(); proc.wait(timeout=20)
                    except (BrokenPipeError, subprocess.TimeoutExpired):
                        proc.kill(); proc.wait()
                try:
                    os.killpg(proc.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass


try:
    report = verify()
except Exception as exc:
    report = {"status": "infrastructure_failure", "reward": None, "error": str(exc)}
(LOGS / "result.json").write_text(json.dumps(report, indent=2) + "\n")
if report["reward"] is not None:
    (LOGS / "reward.txt").write_text(str(report["reward"]) + "\n")
print(json.dumps(report))
raise SystemExit(1 if report["reward"] is None else 0)
