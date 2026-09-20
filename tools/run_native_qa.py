"""Isolated native scene/input/layout checks. --visual also captures renders.
Visual mode needs a working graphical display. Headless checks make no device claim.
"""
import argparse
import os
import pathlib
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument("--visual", action="store_true")
args = parser.parse_args()
root = pathlib.Path(__file__).resolve().parents[1]
godot = os.environ.get("HOLLOW_GODOT", str(root / "tools/Godot_v4.5.1-stable_linux.x86_64"))
(root / "qa").mkdir(exist_ok=True)
for script, log in [("ui_playtest.gd", "native-ui.log"), ("input_playtest.gd", "native-input.log"), ("expedition_playtest.gd", "native-expedition.log")]:
    with tempfile.TemporaryDirectory(prefix="hollow-qa-") as profile:
        command = [godot, "--path", str(root / "game"), "--audio-driver", "Dummy", "--script", "res://tests/" + script]
        if not args.visual:
            command.append("--headless")
        try:
            result = subprocess.run(command, env=dict(os.environ, XDG_DATA_HOME=profile), capture_output=True, text=True, timeout=180)
            text = result.stdout + result.stderr
            code = result.returncode
        except subprocess.TimeoutExpired as error:
            text = (error.stdout or b"").decode() + (error.stderr or b"").decode() + "\nNative QA timed out.\n"
            code = 1
        (root / "qa" / log).write_text(text)
        print(text, flush=True)
        if code or "SCRIPT ERROR:" in text:
            raise SystemExit(code or 1)
