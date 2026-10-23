"""Fixture tests for check-client-ca.py.

Usage: check-client-ca-test.py <path to check-client-ca.py>

Seven cases: six must be rejected (non-zero exit) and one clean bundle must be
accepted (exit 0). Exits non-zero if any case behaves differently.
"""

import base64
import datetime
import json
import os
import subprocess
import sys
import tempfile

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.x509.oid import NameOID

CHECKER = sys.argv[1]
BEGIN = "-----BEGIN CERTIFICATE-----"
END = "-----END CERTIFICATE-----"


def make_cert(common_name):
    key = ec.generate_private_key(ec.SECP256R1())
    name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, common_name)])
    now = datetime.datetime.now(datetime.UTC)
    return (
        x509.CertificateBuilder()
        .subject_name(name)
        .issuer_name(name)
        .public_key(key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(now)
        .not_valid_after(now + datetime.timedelta(days=1))
        .sign(key, hashes.SHA256())
    )


def run(text, blocked=None):
    """Run the checker on a bundle containing text and return its exit status."""
    with tempfile.TemporaryDirectory() as tmp:
        bundle = os.path.join(tmp, "bundle.pem")
        with open(bundle, "w", encoding="ascii") as handle:
            handle.write(text)
        command = [sys.executable, CHECKER, bundle]
        if blocked is not None:
            hook = os.path.join(tmp, "blocked.json")
            with open(hook, "w", encoding="utf-8") as handle:
                json.dump(blocked, handle)
            command += ["--blocked-json", hook]
        result = subprocess.run(command, check=False, capture_output=True, text=True)
        return result.returncode


good = make_cert("fixture-clean")
good_pem = good.public_bytes(serialization.Encoding.PEM).decode("ascii")
good_digest = good.fingerprint(hashes.SHA256()).hex().upper()
not_a_cert = base64.b64encode(b"not a certificate").decode("ascii")

cases = {
    "empty": (run(""), "reject"),
    "malformed": (run(f"{BEGIN}\n!!!not base64!!!\n{END}\n"), "reject"),
    "truncated": (run(f"{BEGIN}\n{not_a_cert}\n"), "reject"),
    "invalidcert": (run(f"{BEGIN}\n{not_a_cert}\n{END}\n"), "reject"),
    "valid-plus-truncated": (run(f"{good_pem}{BEGIN}\n{not_a_cert}\n", {}), "reject"),
    "knownblocked": (run(good_pem, {good_digest: "fixture-blocked"}), "reject"),
    "validclean": (run(good_pem, {}), "accept"),
}

failed = False
for name, (code, expected) in sorted(cases.items()):
    ok = code != 0 if expected == "reject" else code == 0
    status = "ok" if ok else "FAIL"
    print(f"{name:<22} exit={code} expected={expected} {status}")
    failed = failed or not ok
sys.exit(1 if failed else 0)
