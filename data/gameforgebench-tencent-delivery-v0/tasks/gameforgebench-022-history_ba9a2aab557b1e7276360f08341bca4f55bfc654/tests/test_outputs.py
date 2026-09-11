import subprocess

def test_probe():
    result = subprocess.run(
        ["luau", "/tests/harness.lua"],
        capture_output=True, text=True, timeout=90, cwd="/app",
    )
    output = result.stdout + result.stderr
    assert "ROBLOX_KNIT_RUNTIME_OK" in output, f"sentinel 'ROBLOX_KNIT_RUNTIME_OK' not found"
