"""Exit non-zero unless a PEM bundle is a well-formed bundle free of eMudhra certs.

The blocked list is the incident's published fingerprint set: the roots from
roots.json and the intermediates from impacted-intermediates.json at
https://emudhra.we-have-a-problem.com/ (third-party data; the count of eight
compromised intermediates is corroborated by Mozilla bug 2083449,
https://bugzilla.mozilla.org/show_bug.cgi?id=2083449).

The check fails closed: it needs at least one valid certificate, strict base64,
real X.509 parsing, and balanced BEGIN/END markers, so an empty, truncated or
malformed bundle cannot pass.
"""

import argparse
import base64
import binascii
import hashlib
import json
import re
import sys

from cryptography import x509

FINGERPRINTS = {
    "7DD78D5F4F13459A83DFF9ABBBA62EDBAF6F2D102BF257FD712F4D9F2746ED8D": "root: emSign Root TLS CA - G3",
    "F2EDAAFF3D9B701FB4D14C9F285F8C0BAD90FC3BCC1FA07D47F4718EDABA34A5": "root: emSign Root CS CA - G3",
    "D7A7A0FB5D7E2731D771E9484EBCDEF71D5F0C3E0A2948782BC83EE0EA699EF4": "root: AAA Certificate Services",
    "86A1ECBA089C4A8D3BBE2734C612BA341D813E043CF9E8A862CD5C57A36BBE6B": "root: emSign ECC Root CA - G3",
    "42C4ACCD12C4F59597925E1A08A7A90102608543809308D50EC427E118BA1493": "EM DV TLS CA - G3B",
    "45A883F349AEDFD5F3A649B5498FFB121712BA8B448F3F2A91DBC5A766FCDDBE": "EM DV TLS CA - G3B (AAA cross-sign)",
    "98B896625C0C230ADEEC3EB2CF6AAD5001ECF9156A68644E82374CE5833BC25B": "EM OV TLS CA - G3B",
    "5F1DED4DD590AF74631290CF073B122A2AAC6A1FA479778A0BD43579BD832699": "EM OV TLS CA - G3B (AAA cross-sign)",
    "E7568FE6E12331F4FD7DE61DA4C7559D0F8EB192A218D4741A3BA75184333838": "EM EV TLS CA - G3B",
    "579480AEA166290BD3C643589E795FC0D0E54E86505D180F1DFF99EFD3199512": "EM EV TLS CA - G3B (AAA cross-sign)",
    "0164D7CEAE5BB909C272AF151FF44B1177AE9B47D9424B94F1D9558C30934D19": "EM DV TLS CA - G3C",
    "62B7F9868263F72F6911FC78CEAF72C1979158B7368BF648683BB2AA39B02E72": "EM DV TLS CA - G3C (AAA cross-sign)",
    "CB6E15165AC802E9B3F993F16C25D41F4E81C21EBDE71AE1B012AC00BF9C7C3F": "EM OV TLS CA - G3C",
    "7485B51C0ED192878FA1D2F948FB529AE1842CC5086C4B67F7BE5B2039DE9489": "EM OV TLS CA - G3C (AAA cross-sign)",
    "432EC25F0D28DE9006D97BF752F17BBB2CD41F669933FCB072D9A1148D0261F3": "EM EV TLS CA - G3C",
    "FD9D5C2DBBD4995AB69B8D50C439D9527B00529199C2FD01B2174EB58F07021F": "EM EV TLS CA - G3C (AAA cross-sign)",
    "9E39DE2881273ACC225A149C72BA3E0F51424963669AB633EE1DC7DF5DB067B4": "EM OV CS CA - G3B",
    "A496E23AC0CAB8155FC9B117B97EAE368EFCBB9041AEC8804D5A308D2D01C2D8": "EM OV CS CA - G3B (AAA cross-sign)",
    "4B2460A466F95FD40113BCDCCA2CEB29B3B093921DE45474DA7DF48874C630B1": "EM OV CS CA - G3C",
    "84112972B8E59D14560AE7E7119654474AAD119990CF3722BFC1E3B91615E1FD": "EM OV CS CA - G3C (AAA cross-sign)",
}

BEGIN = "-----BEGIN CERTIFICATE-----"
END = "-----END CERTIFICATE-----"
BLOCK = re.compile(re.escape(BEGIN) + r"([A-Za-z0-9+/=\s]*?)" + re.escape(END))


def problems_for(text, blocked):
    """Return a list of problems; an empty list means the bundle is acceptable."""
    problems = []
    begins = text.count(BEGIN)
    ends = text.count(END)
    blocks = BLOCK.findall(text)
    if begins != ends or begins != len(blocks):
        problems.append(
            "unbalanced or malformed PEM markers: "
            f"{begins} BEGIN, {ends} END, {len(blocks)} well-formed blocks"
        )
    valid = 0
    for body in blocks:
        try:
            der = base64.b64decode("".join(body.split()), validate=True)
            x509.load_der_x509_certificate(der)
        except (binascii.Error, ValueError) as exc:
            problems.append(f"invalid certificate block: {exc}")
            continue
        valid += 1
        digest = hashlib.sha256(der).hexdigest().upper()
        if digest in blocked:
            problems.append(f"blocked certificate present: {blocked[digest]}")
    if valid == 0:
        problems.append("no valid certificate found")
    return problems


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("bundle", help="PEM bundle to check")
    parser.add_argument(
        "--blocked-json",
        help="test hook: JSON object {SHA-256: label} replacing the built-in list",
    )
    args = parser.parse_args()

    blocked = FINGERPRINTS
    if args.blocked_json:
        with open(args.blocked_json, encoding="utf-8") as handle:
            blocked = {key.upper(): value for key, value in json.load(handle).items()}

    # Bytes decoded as latin-1 cannot fail, so non-ASCII comment lines in a bundle
    # never crash the guard; the PEM bodies themselves must still be strict ASCII
    # base64 to parse.
    with open(args.bundle, "rb") as handle:
        text = handle.read().decode("latin-1")

    problems = problems_for(text, blocked)
    for problem in problems:
        print(f"error: {problem}", file=sys.stderr)
    sys.exit(1 if problems else 0)


main()
