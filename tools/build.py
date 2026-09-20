"""Import, test, and export the native prototype using the configured workstation."""
import argparse
import os
import pathlib
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--android", action="store_true")
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[1]
godot = os.environ.get("HOLLOW_GODOT", str(root / "tools/Godot_v4.5.1-stable_linux.x86_64"))
qa = root / "qa"
qa.mkdir(exist_ok=True)

def run(name, command):
    result = subprocess.run(command, cwd=root, capture_output=True, text=True)
    output = result.stdout + result.stderr
    (qa / (name + ".log")).write_text(output)
    print(name, "PASS" if result.returncode == 0 else "FAIL", flush=True)
    print("\n".join(output.splitlines()[-5:]), flush=True)
    if result.returncode or "SCRIPT ERROR:" in output:
        raise SystemExit(result.returncode or 1)

base = [godot, "--headless", "--path", str(root / "game")]
run("import", base + ["--editor", "--quit"])
run("simulation", base + ["--script", "res://tests/run_tests.gd"])
run("ui-layout", [sys.executable, str(root / "tools/run_native_qa.py")])
for target, filename in [("Windows", "Hollow-Windows/Hollow.exe"), ("Linux", "Hollow-Linux/Hollow.x86_64")]:
    output = root / "releases" / filename
    output.parent.mkdir(parents=True, exist_ok=True)
    run(target.lower()+"-export", base + ["--export-release", target, str(output)])
if args.android:
    run("android-export", base + ["--export-debug", "Android", str(root / "releases/Hollow-Android.apk")])
print("Exports complete. Verify packages and keep their engine notices before distribution.")
