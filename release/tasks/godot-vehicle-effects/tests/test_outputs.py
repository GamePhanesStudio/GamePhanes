import subprocess

def test_probe():
    result = subprocess.run(
        ["godot", "--headless", "--path", "/app", "--script", "/tests/harness.gd"],
        capture_output=True, text=True, timeout=120,
    )
    output = result.stdout + result.stderr
    assert "VEHICLE_EFFECTS_PROBE_OK" in output, f"sentinel 'VEHICLE_EFFECTS_PROBE_OK' not found"
