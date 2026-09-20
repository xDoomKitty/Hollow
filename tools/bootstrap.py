"""Recover the pinned Linux Godot workstation; downloaded binaries stay untracked."""
import hashlib
import os
import pathlib
import urllib.request
import zipfile

root = pathlib.Path(__file__).resolve().parent
version = "4.5.1-stable"
base = f"https://github.com/godotengine/godot-builds/releases/download/{version}/"
archives = {
    "Godot_v4.5.1-stable_linux.x86_64.zip": "02ec53d1cc7dbb9cc6355393c61b9ab43d1244751a124f10248a4802830788cd",
    "Godot_v4.5.1-stable_export_templates.tpz": "1998af37f1387684e2c211cdb483daf492fc64dc6b12096bddcdca25b6910c86",
}

def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

for name, expected in archives.items():
    path = root / name
    if not path.exists() or digest(path) != expected:
        temporary = path.with_suffix(".download")
        print("Downloading", name, flush=True)
        urllib.request.urlretrieve(base + name, temporary)
        if digest(temporary) != expected:
            raise SystemExit("Checksum mismatch; keeping the prior toolchain intact.")
        temporary.replace(path)
    if name.endswith(".zip"):
        executable = "Godot_v4.5.1-stable_linux.x86_64"
        with zipfile.ZipFile(path) as archive:
            (root / executable).write_bytes(archive.read(executable))
        (root / executable).chmod(0o755)
    else:
        data = pathlib.Path(os.environ.get("XDG_DATA_HOME", pathlib.Path.home() / ".local/share"))
        destination = data / "godot/export_templates/4.5.1.stable"
        destination.mkdir(parents=True, exist_ok=True)
        members = ["version.txt", "linux_release.x86_64", "linux_debug.x86_64", "windows_release_x86_64.exe", "windows_debug_x86_64.exe", "android_release.apk", "android_debug.apk", "web_nothreads_release.zip", "web_nothreads_debug.zip"]
        with zipfile.ZipFile(path) as archive:
            for member in members:
                (destination / member).write_bytes(archive.read("templates/" + member))
print("Godot workstation restored. Android also needs Java 17 and tools/fetch_android_tools.py.")
