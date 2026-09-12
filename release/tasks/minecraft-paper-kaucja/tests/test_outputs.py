import subprocess, json
from pathlib import Path

def test_probe():
    result = subprocess.run(
        ["python3", "/tests/verify.py"],
        capture_output=True, text=True, timeout=360,
    )
    try:
        report = json.loads(result.stdout.strip().splitlines()[-1])
    except (json.JSONDecodeError, IndexError):
        report = {}
    reward = report.get("reward")
    assert reward == 1, f"verify.py reward={reward}\n{result.stdout[-2000:]}\n{result.stderr[-500:]}"
