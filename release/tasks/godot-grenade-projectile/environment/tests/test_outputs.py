import json
import os
import subprocess
from pathlib import Path


def test_outputs():
    root = Path(os.environ.get("TASK_OUTPUT_ROOT", "/app"))
    script = root / "tests" / "test.sh"
    proc = subprocess.run(["sh", str(script)], cwd=root, capture_output=True, text=True, timeout=180)
    log_dir = Path(os.environ.get("VERIFIER_LOG_DIR", "/logs/verifier"))
    result = json.loads((log_dir / "result.json").read_text())
    assert proc.returncode == 0
    assert result["status"] == "evaluated"
    assert result["reward"] == 1
    assert result["passed"] == result["total"] == 6
