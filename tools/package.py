"""Package committed native source/history and working game exports with notices."""
import hashlib
import json
import pathlib
import shutil
import subprocess
import sys
import tempfile
import zipfile

root = pathlib.Path(__file__).resolve().parents[1]
destination = pathlib.Path(sys.argv[1]).resolve()
destination.mkdir(parents=True, exist_ok=True)
status = subprocess.check_output(["git", "status", "--porcelain"], cwd=root, text=True)
if status.strip():
    raise SystemExit("Commit the current source before packaging it.")
revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
readme = (root / "README.md").read_bytes()
notices = (root / "game/assets/ENGINE_NOTICES.txt").read_bytes()
files = []
for platform, executable in [("Windows", "Hollow.exe"), ("Linux", "Hollow.x86_64")]:
    name = "Hollow-" + platform
    source = root / "releases" / name / executable
    archive_path = destination / (name + ".zip")
    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        archive.write(source, name + "/" + executable)
        archive.writestr(name + "/README.md", readme)
        archive.writestr(name + "/ENGINE_NOTICES.txt", notices)
        archive.writestr(name + "/BUILD.txt", "Hollow 0.68.0\nGodot 4.5.1\nSource revision: " + revision + "\n")
    files.append(archive_path)
apk = destination / "Hollow-Android.apk"
shutil.copy2(root / "releases/Hollow-Android.apk", apk)
files.append(apk)
tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=root).decode().split("\0")
archive_path = destination / "Hollow_Source.zip"
with tempfile.TemporaryDirectory(prefix="hollow-bundle-") as temp:
    bundle = pathlib.Path(temp) / "Hollow-history.bundle"
    subprocess.run(["git", "bundle", "create", str(bundle), "--all"], cwd=root, check=True)
    with zipfile.ZipFile(archive_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for name in tracked:
            if name:
                archive.write(root / name, "Hollow-Source/" + name)
        archive.write(bundle, "Hollow-history.bundle")
files.append(archive_path)
manifest = {"version": "0.68.0", "revision": revision, "files": {}}
for path in files:
    with zipfile.ZipFile(path) as archive:
        if archive.testzip() is not None:
            raise SystemExit("Archive integrity failure: " + path.name)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    manifest["files"][path.name] = {"bytes": path.stat().st_size, "sha256": digest}
(destination / "Hollow_Build_Manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(json.dumps(manifest, indent=2))
