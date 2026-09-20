"""Refuse Android updates unless the preserved prototype key is available."""
import hashlib
import pathlib
import subprocess

EXPECTED_CERTIFICATE = "df7193174d83fa04c2be605ebcfb4c989c302fc714705674b449d3b60cbdef62"


def verify_prototype_key():
    key = pathlib.Path.home() / ".local/share/godot/keystores/debug.keystore"
    if not key.is_file():
        raise SystemExit("Android export blocked: restore the existing PRIVATE Hollow test signing key; never generate a replacement.")
    result = subprocess.run(
        ["keytool", "-exportcert", "-keystore", str(key), "-alias", "androiddebugkey", "-storepass", "android"],
        capture_output=True,
    )
    if result.returncode or hashlib.sha256(result.stdout).hexdigest() != EXPECTED_CERTIFICATE:
        raise SystemExit("Android export blocked: the available key does not match the delivered prototype certificate.")
    print("Preserved Android prototype signing certificate verified.", flush=True)


if __name__ == "__main__":
    verify_prototype_key()
