import subprocess, shutil, os

def test_probe():
    shutil.copy("/tests/probe.lua", "/app/probe.lua")
    try:
        result = subprocess.run(
            ["luau", "probe.lua"],
            capture_output=True, text=True, timeout=90, cwd="/app",
        )
        output = result.stdout + result.stderr
        assert "ROBLOX_GYM_UI_RUNTIME_OK" in output, f"sentinel 'ROBLOX_GYM_UI_RUNTIME_OK' not found\n{output[-2000:]}"
    finally:
        if os.path.exists("/app/probe.lua"):
            os.unlink("/app/probe.lua")
