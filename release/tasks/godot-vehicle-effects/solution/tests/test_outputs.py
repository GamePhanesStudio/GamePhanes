import os
import subprocess
from pathlib import Path
import yaml
import atexit

ROOT = Path(os.environ.get("TASK_OUTPUT_ROOT", "/app"))

def _default_reward():
    logs = Path('/logs/verifier')
    logs.mkdir(parents=True, exist_ok=True)
    reward = logs / 'reward.txt'
    if not reward.exists():
        reward.write_text('0\n')
atexit.register(_default_reward)

def test_rubric_checks():
    spec = yaml.safe_load((ROOT / "rubric.yaml").read_text()) or {}
    failures = []
    for check in spec.get("checks", []):
        kind = check.get("type")
        if kind == "file_exists":
            ok = (ROOT / check["path"]).is_file()
        elif kind == "file_contains":
            ok = check.get("expected", "") in (ROOT / check["path"]).read_text()
        elif kind in ("godot_probe", "godot_playmode_probe"):
            probe = ROOT / ".forge_probe.gd"
            probe.write_text(check.get("probe_script", ""))
            proc = subprocess.run(["godot", "--headless", "--path", str(ROOT), "--script", str(probe)], capture_output=True, text=True, timeout=120)
            ok = proc.returncode == 0 and check.get("expected", "") in (proc.stdout + proc.stderr)
            probe.unlink(missing_ok=True)
        else:
            continue
        if not ok:
            failures.append(check.get("id", "unknown"))
    assert not failures, "failed checks: " + ", ".join(failures)
    logs = Path('/logs/verifier')
    logs.mkdir(parents=True, exist_ok=True)
    (logs / 'reward.txt').write_text('1\n')
