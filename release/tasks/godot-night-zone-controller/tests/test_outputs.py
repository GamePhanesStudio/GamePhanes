import subprocess, shutil, os

def test_probe():
    subprocess.run(
        ["godot", "--headless", "--path", "/app", "--import"],
        capture_output=True, text=True, timeout=120,
    )
    shutil.copy("/tests/night_zone_probe.gd", "/app/.gfb_runtime_probe.gd")
    try:
        result = subprocess.run(
            ["godot", "--headless", "--path", "/app", "--script", ".gfb_runtime_probe.gd"],
            capture_output=True, text=True, timeout=120, cwd="/app",
        )
        output = result.stdout + result.stderr
        assert "NIGHT_ZONE_PROBE1_OK" in output, f"sentinel 'NIGHT_ZONE_PROBE1_OK' not found"
        assert "NIGHT_ZONE_PROBE2_OK" in output, f"sentinel 'NIGHT_ZONE_PROBE2_OK' not found"
        assert "NIGHT_ZONE_PROBE3_OK" in output, f"sentinel 'NIGHT_ZONE_PROBE3_OK' not found"
    finally:
        try:
            os.unlink("/app/.gfb_runtime_probe.gd")
        except FileNotFoundError:
            pass
