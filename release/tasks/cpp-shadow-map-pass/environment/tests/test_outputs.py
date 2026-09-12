import json, os, re, subprocess
from pathlib import Path
import yaml

PROBE_ROOT = Path(os.environ.get("VERIFIER_TMP_ROOT", "/tmp/forge-verifier"))
PROBE_ROOT.mkdir(parents=True, exist_ok=True)

ROOT = Path(os.environ.get("TASK_OUTPUT_ROOT", "/app"))
RUBRIC = Path(os.environ.get("RUBRIC_PATH", str(ROOT / "rubric.yaml")))

def read(path):
    p = ROOT / str(path)
    return p.read_text(encoding="utf-8", errors="replace") if p.is_file() else ""

def test_rubric():
    spec = yaml.safe_load(RUBRIC.read_text(encoding="utf-8")) or {}
    checks = spec.get("checks", [])
    assert checks, "rubric has no checks"
    failures = []
    for c in checks:
        kind, path = c.get("type"), c.get("path", "")
        p = ROOT / path
        ok = p.is_file() if kind == "file_exists" else False
        text = read(path)
        if kind == "file_contains": ok = bool(c.get("expected")) and str(c["expected"]) in text
        if kind == "file_regex": ok = bool(re.search(str(c.get("pattern", c.get("expected", ""))), text, re.M))
        if kind == "godot_probe":
            probe_path = PROBE_ROOT / ".forge_verifier_probe.gd"
            try:
                probe_path.write_text(str(c.get("probe_script", "")) + "\n", encoding="utf-8")
                proc = subprocess.run(f"godot --headless --path . --script {probe_path}", shell=True, cwd=ROOT, capture_output=True, text=True, timeout=120)
                output = (proc.stdout or "") + (proc.stderr or "")
                expected = str(c.get("expected", ""))
                ok = proc.returncode == 0 and (expected in output if expected else True)
            finally:
                probe_path.unlink(missing_ok=True)
        if kind == "csharp_probe":
            probe_path = PROBE_ROOT / ".forge_verifier_probe.cs"
            executable = PROBE_ROOT / ".forge_verifier_probe.exe"
            try:
                if not p.is_file():
                    ok = False
                else:
                    probe_path.write_text(str(c.get("probe_script", "")) + "\n", encoding="utf-8")
                    compile_proc = subprocess.run(["mcs", f"-out:{executable}", str(p), str(probe_path)], cwd=ROOT, capture_output=True, text=True, timeout=120)
                    proc = compile_proc if compile_proc.returncode != 0 else subprocess.run(["mono", str(executable)], cwd=ROOT, capture_output=True, text=True, timeout=120)
                    output = (proc.stdout or "") + (proc.stderr or "")
                    expected = str(c.get("expected", ""))
                    ok = proc.returncode == 0 and (expected in output if expected else True)
            finally:
                probe_path.unlink(missing_ok=True)
                executable.unlink(missing_ok=True)
        if kind == "lua_probe":
            probe_path = PROBE_ROOT / ".forge_verifier_probe.lua"
            try:
                if not p.is_file():
                    ok = False
                else:
                    probe_path.write_text(str(c.get("probe_script", "")) + "\n", encoding="utf-8")
                    proc = subprocess.run(["lua", str(probe_path)], cwd=ROOT, capture_output=True, text=True, timeout=120)
                    output = (proc.stdout or "") + (proc.stderr or "")
                    expected = str(c.get("expected", ""))
                    ok = proc.returncode == 0 and (expected in output if expected else True)
            finally:
                probe_path.unlink(missing_ok=True)
        if kind == "java_probe":
            probe_path = PROBE_ROOT / "ForgeVerifier.java"
            classes = PROBE_ROOT / ".forge_java_classes"
            try:
                if not p.is_file():
                    ok = False
                else:
                    probe_path.write_text(str(c.get("probe_script", "")) + "\n", encoding="utf-8")
                    classes.mkdir(exist_ok=True)
                    compile_proc = subprocess.run(["javac", "-d", str(classes), str(p), str(probe_path)], cwd=ROOT, capture_output=True, text=True, timeout=120)
                    proc = compile_proc if compile_proc.returncode != 0 else subprocess.run(["java", "-cp", str(classes), "ForgeVerifier"], cwd=ROOT, capture_output=True, text=True, timeout=120)
                    output = (proc.stdout or "") + (proc.stderr or "")
                    expected = str(c.get("expected", ""))
                    ok = proc.returncode == 0 and (expected in output if expected else True)
            finally:
                probe_path.unlink(missing_ok=True)
                import shutil
                shutil.rmtree(classes, ignore_errors=True)
        if kind == "cpp_probe":
            probe_path = PROBE_ROOT / ".forge_verifier_probe.cpp"
            executable = PROBE_ROOT / ".forge_verifier_probe"
            try:
                if not p.is_file():
                    ok = False
                else:
                    probe_path.write_text(str(c.get("probe_script", "")) + "\n", encoding="utf-8")
                    probe_sources = [str(probe_path)] if f'#include "{p}"' in str(c.get("probe_script", "")) else [str(p), str(probe_path)]
                    compile_proc = subprocess.run(
                        ["g++", "-std=c++17", "-O2", "-I.", "-o", str(executable), *probe_sources],
                        cwd=ROOT, capture_output=True, text=True, timeout=120,
                    )
                    proc = compile_proc if compile_proc.returncode != 0 else subprocess.run(
                        [str(executable)], cwd=ROOT, capture_output=True, text=True, timeout=120,
                    )
                    output = (proc.stdout or "") + (proc.stderr or "")
                    expected = str(c.get("expected", ""))
                    ok = proc.returncode == 0 and (expected in output if expected else True)
            finally:
                probe_path.unlink(missing_ok=True)
                executable.unlink(missing_ok=True)
        if kind == "command":
            proc = subprocess.run(str(c.get("command", "")), shell=True, cwd=ROOT, capture_output=True, text=True, timeout=120)
            output = (proc.stdout or "") + (proc.stderr or "")
            expected = str(c.get("expected", ""))
            ok = proc.returncode == 0 and (expected in output if expected and expected != "exit_code=0" else True)
        if kind in ("json_field", "yaml_field"):
            try:
                value = json.loads(text) if kind == "json_field" else yaml.safe_load(text)
                for part in str(c.get("field", "")).split("."): value = value[part]
                ok = value == c.get("expected")
            except Exception: ok = False
        if not ok: failures.append(c.get("id", "check"))
    assert not failures, "failed checks: " + ", ".join(failures)
