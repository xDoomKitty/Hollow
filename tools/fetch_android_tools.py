"""Restore Google's non-Gradle Android tools. Requires an existing Java 17."""
import pathlib
import shutil
import urllib.request
import zipfile

root = pathlib.Path(__file__).resolve().parent
java = shutil.which("java")
if not java:
    raise SystemExit("Java 17 is required; see Godot's Android export documentation. No tools were changed.")
java_home = pathlib.Path(java).resolve().parents[1]
sources = [
    ("android-buildtools.zip", "https://dl.google.com/android/repository/build-tools_r35.0.1_linux.zip", "build-tools/35.0.1"),
    ("android-platformtools.zip", "https://dl.google.com/android/repository/platform-tools-latest-linux.zip", "platform-tools"),
]
for name, url, target in sources:
    archive_path = root / name
    if not archive_path.exists():
        temporary = archive_path.with_suffix(".download")
        urllib.request.urlretrieve(url, temporary)
        temporary.replace(archive_path)
    destination = root / "android-sdk" / target
    destination.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive_path) as archive:
        for info in archive.infolist():
            parts = pathlib.PurePosixPath(info.filename).parts[1:]
            if not parts or info.is_dir() or ".." in parts:
                continue
            path = destination.joinpath(*parts)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(archive.read(info))
            path.chmod((info.external_attr >> 16) & 0o777 or 0o755)
print("Android SDK:", root / "android-sdk")
print("Java SDK:", java_home)
print("Set these Godot Editor Settings export paths. Restore the EXISTING private test key before exporting an update; do not generate a different key.")
