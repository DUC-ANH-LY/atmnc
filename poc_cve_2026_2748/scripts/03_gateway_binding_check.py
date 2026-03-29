#!/usr/bin/env python3
"""Post-verify identity binding: vulnerable vs strict (CVE-2026-2748 style)."""

from __future__ import annotations

import email.utils
import re
import string
import subprocess
import sys
import tempfile
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    out = root / "demo_out"
    signed = out / "signed_spoof.pem"
    ca = out / "ca.crt"

    for p in (signed, ca):
        if not p.is_file():
            print(f"error: missing {p}", file=sys.stderr)
            return 1

    recovered = out / "recovered_from_verify.eml"

    verify = subprocess.run(
        [
            "openssl",
            "smime",
            "-verify",
            "-in",
            str(signed),
            "-CAfile",
            str(ca),
            "-out",
            str(recovered),
        ],
        capture_output=True,
        text=True,
    )
    print("--- Cryptographic verification (openssl smime -verify) ---")
    if verify.returncode == 0:
        print("Result: OK (signature and chain valid)")
    else:
        print("Result: FAILED")
        if verify.stderr:
            print(verify.stderr.strip(), file=sys.stderr)
        return 1

    from_addr = _parse_from_header(recovered.read_text(encoding="utf-8", errors="replace"))
    if not from_addr:
        print("error: could not parse From: header from verified message", file=sys.stderr)
        return 1

    signer_pem = _pkcs7_signer_pem(signed)
    if not signer_pem:
        print("error: could not extract signer certificate from PKCS#7", file=sys.stderr)
        return 1

    san_email = _san_email_from_pem(signer_pem)
    if san_email is None:
        print("error: could not parse rfc822Name from Subject Alternative Name", file=sys.stderr)
        return 1

    print("\n--- Identity binding (gateway / application layer) ---")
    print(f"From address (message):     {from_addr!r}")
    print(f"Signer cert email (SAN):    {san_email!r}")

    vuln_match = _strip_all_ascii_ws(san_email) == _strip_all_ascii_ws(from_addr)
    print("\nVulnerable binding (strip ALL ASCII whitespace, then compare):")
    print(
        "  "
        + (
            "MATCH — spoof accepted as same identity (modeled vulnerable gateway)"
            if vuln_match
            else "NO MATCH"
        )
    )

    strict_ok = not any(c in string.whitespace for c in san_email)
    strict_equal = strict_ok and san_email == from_addr
    print("\nStrict binding (reject SAN if any whitespace; else require exact match):")
    if not strict_ok:
        print("  REJECT — malformed / whitespace in certificate email (patched-style)")
    elif strict_equal:
        print("  OK — SAN email exactly equals From address")
    else:
        print("  NO MATCH — SAN email differs from From address")

    return 0


def _strip_all_ascii_ws(s: str) -> str:
    return "".join(c for c in s if c not in string.whitespace)


def _parse_from_header(raw: str) -> str | None:
    for line in raw.splitlines():
        if line.lower().startswith("from:"):
            _, addr = email.utils.parseaddr(line[5:].strip())
            return addr if addr else None
    return None


def _pkcs7_signer_pem(signed_pem: Path) -> str | None:
    p7 = subprocess.run(
        ["openssl", "smime", "-pk7out", "-in", str(signed_pem)],
        capture_output=True,
        check=True,
    ).stdout
    out = subprocess.run(
        ["openssl", "pkcs7", "-print_certs", "-inform", "PEM"],
        input=p7,
        capture_output=True,
        check=True,
    ).stdout.decode("utf-8", errors="replace")
    blocks = re.findall(
        r"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----",
        out,
        flags=re.DOTALL,
    )
    return blocks[0] if blocks else None


def _san_email_from_pem(pem: str) -> str | None:
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".pem", delete=False, encoding="utf-8"
    ) as f:
        f.write(pem)
        path = f.name
    try:
        r = subprocess.run(
            ["openssl", "x509", "-noout", "-ext", "subjectAltName", "-in", path],
            capture_output=True,
            text=True,
        )
        text = r.stdout if r.returncode == 0 else ""
        if not text.strip():
            r2 = subprocess.run(
                ["openssl", "x509", "-noout", "-text", "-in", path],
                capture_output=True,
                text=True,
                check=True,
            )
            text = r2.stdout
        for line in text.splitlines():
            line = line.strip()
            if line.startswith("email:"):
                return line.split(":", 1)[1].strip()
        return None
    finally:
        Path(path).unlink(missing_ok=True)


if __name__ == "__main__":
    raise SystemExit(main())
