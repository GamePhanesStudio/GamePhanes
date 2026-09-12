import subprocess, os

def test_probe():
    compile_r = subprocess.run(
        ["g++", "-std=c++17", "-I", "/app", "/tests/probe.cpp", "-o", "/tmp/gfb_probe_probe"],
        capture_output=True, text=True, timeout=60,
    )
    assert compile_r.returncode == 0, f"compile failed:\n{compile_r.stderr}"
    run_r = subprocess.run(["/tmp/gfb_probe_probe"], capture_output=True, text=True, timeout=60)
    output = run_r.stdout + run_r.stderr
    assert "CPP_PREDICTION_PROBE_OK" in output, f"sentinel not found\n{output[-2000:]}"
    if os.path.exists("/tmp/gfb_probe_probe"):
        os.unlink("/tmp/gfb_probe_probe")
