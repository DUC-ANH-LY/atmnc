#!/usr/bin/env python3
"""Poll attacker@localhost IMAP for messages whose body contains a marker string."""

import argparse
import imaplib
import sys
import time


def main() -> int:
    p = argparse.ArgumentParser(description="Read attacker inbox on GreenMail IMAP")
    p.add_argument("--host", default="127.0.0.1")
    p.add_argument("--port", type=int, default=3143)
    p.add_argument("--user", default="attacker@localhost")
    p.add_argument("--password", default="attackpass")
    p.add_argument("--marker", default="Hello from the S/MIME demo", help="Substring to detect leak")
    p.add_argument("--wait-secs", type=int, default=120, help="Total time to poll")
    p.add_argument("--interval", type=float, default=3.0)
    args = p.parse_args()

    deadline = time.monotonic() + args.wait_secs
    while time.monotonic() < deadline:
        try:
            m = imaplib.IMAP4(args.host, args.port)
            m.login(args.user, args.password)
            m.select("INBOX")
            typ, data = m.search(None, "ALL")
            if typ == "OK" and data[0]:
                for num in data[0].split():
                    typ, msgdata = m.fetch(num, "(RFC822)")
                    if typ != "OK":
                        continue
                    raw = msgdata[0][1]
                    if isinstance(raw, int):
                        continue
                    if args.marker.encode() in raw or args.marker in raw.decode(
                        "utf-8", errors="replace"
                    ):
                        print("Found marker in attacker inbox (possible reply leak).", file=sys.stderr)
                        print(raw.decode("utf-8", errors="replace")[:8000])
                        m.logout()
                        return 0
            m.logout()
        except OSError as e:
            print(f"IMAP: {e}", file=sys.stderr)
        time.sleep(args.interval)

    print("Timeout: marker not found in attacker inbox.", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
