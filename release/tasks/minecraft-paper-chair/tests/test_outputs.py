import subprocess, os, tempfile
from pathlib import Path

def test_probe():
    cp_parts = list(Path("/app/build/libs").glob("*.jar")) + (list(Path("/app/libs").glob("*.jar")) if Path("/app/libs").exists() else [])
    cp_parts += list(Path("/opt/paper").rglob("*.jar"))
    cp = ":".join(str(p) for p in cp_parts) + ":/app"
    out_dir = tempfile.mkdtemp(prefix="gfb_probe_")
    try:
        src_root = Path("/app/src/main/java")
        if src_root.exists():
            sources = [str(p) for p in src_root.rglob("*.java")]
            if sources:
                src_r = subprocess.run(
                    ["javac", "-cp", cp, "-d", out_dir] + sources,
                    capture_output=True, text=True, timeout=60,
                )
                assert src_r.returncode == 0, f"src compile failed:\n{src_r.stderr}"
        cp_full = cp + ":" + out_dir
        compile_r = subprocess.run(
            ["javac", "-cp", cp_full, "/tests/Probe.java", "-d", out_dir],
            capture_output=True, text=True, timeout=60,
        )
        assert compile_r.returncode == 0, f"compile failed:\n{compile_r.stderr}"
        run_r = subprocess.run(
            ["java", "-cp", f"{out_dir}:{cp_full}", "Probe", "/app"],
            capture_output=True, text=True, timeout=90,
        )
        output = run_r.stdout + run_r.stderr
        assert "MINECRAFT_PAPER_PROBE_OK" in output, f"sentinel not found\n{output[-2000:]}"
    finally:
        import shutil; shutil.rmtree(out_dir, ignore_errors=True)
