import os
import re
import subprocess
from pathlib import Path

import yaml

ROOT = Path(os.environ.get("TASK_OUTPUT_ROOT", "/app"))
RUBRIC = Path(os.environ.get("RUBRIC_PATH", str(ROOT / "rubric.yaml")))


def test_rubric():
    spec = yaml.safe_load(RUBRIC.read_text(encoding="utf-8")) or {}
    failures = []
    checks = spec.get("checks", [])
    for check in checks:
        kind = check.get("type")
        path = ROOT / str(check.get("path", ""))
        ok = path.is_file() if kind == "file_exists" else False
        text = path.read_text(encoding="utf-8", errors="replace") if path.is_file() else ""
        if kind == "file_contains":
            ok = str(check.get("expected", "")) in text
        elif kind == "file_regex":
            ok = bool(re.search(str(check.get("pattern", "")), text, re.M))
        elif kind == "command":
            proc = subprocess.run(check["command"], shell=True, cwd=ROOT, capture_output=True, text=True, timeout=120)
            ok = proc.returncode == 0
        elif kind == "godot_probe":
            probe = ROOT / ".forge_verifier_probe.gd"
            probe.write_text(str(check.get("probe_script", "")) + "\n", encoding="utf-8")
            try:
                proc = subprocess.run(["godot", "--headless", "--path", ".", "--script", probe.name], cwd=ROOT, capture_output=True, text=True, timeout=120)
                output = (proc.stdout or "") + (proc.stderr or "")
                ok = proc.returncode == 0 and str(check.get("expected", "")) in output
            finally:
                probe.unlink(missing_ok=True)
        if not ok:
            failures.append(str(check.get("id", "check")))
    assert not failures, "failed checks: " + ", ".join(failures)
