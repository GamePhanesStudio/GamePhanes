import subprocess, json
from pathlib import Path

def test_probe():
    result = subprocess.run(
        ["python3", "/tests/run_verifier.py"],
        capture_output=True, text=True, timeout=180,
    )
    try:
        report = json.loads(result.stdout.strip())
    except json.JSONDecodeError:
        reward_txt = Path("/logs/verifier/reward.txt")
        reward = int(reward_txt.read_text().strip()) if reward_txt.exists() else 0
        assert reward == 1, f"run_verifier.py failed\n{result.stdout[-2000:]}\n{result.stderr[-500:]}"
        return
    assert report.get("reward") == 1, f"reward={report.get('reward')}\n{result.stdout[-2000:]}"
