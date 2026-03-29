#!/usr/bin/env bash
set -euo pipefail     # exit immediately if a command fails, variable is unset, or a pipeline fails

# Get the root of the project by moving up one directory from the script's folder
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Set output directory where certificates & keys will go
OUT="$ROOT/demo_out"
# Make sure the output directory exists
mkdir -p "$OUT"

# Generate a self-signed Certificate Authority (CA) key and certificate;
#   - creates an RSA 2048-bit private key (ca.key)
#   - creates a self-signed X.509 certificate (ca.crt) valid for 365 days
#   - does NOT encrypt the key with a password (thanks to -nodes)
#   - sets the subject common name to 'Demo CA'
openssl req -x509 -newkey rsa:2048 \
  -keyout "$OUT/ca.key" -out "$OUT/ca.crt" \
  -days 365 -nodes -subj "/CN=Demo CA"

# Generate a keypair and certificate signing request (CSR) for Alice,
#   - saves 2048-bit RSA private key to alice.key (no passphrase)
#   - writes CSR to alice.csr, subject CN 'Alice'
openssl req -newkey rsa:2048 \
  -keyout "$OUT/alice.key" -out "$OUT/alice.csr" -nodes -subj "/CN=Alice"

# Use CA to sign Alice's CSR and make her certificate:
#   - input CSR is alice.csr
#   - -CA points to CA cert and key
#   - -CAserial holds the serial number, new file created if needed
#   - produces alice.crt (valid 365 days)
openssl x509 -req -in "$OUT/alice.csr" \
  -CA "$OUT/ca.crt" -CAkey "$OUT/ca.key" \
  -CAserial "$OUT/ca.srl" -CAcreateserial \
  -out "$OUT/alice.crt" -days 365

# Same steps for Bob: make his keypair and CSR (no password)
openssl req -newkey rsa:2048 \
  -keyout "$OUT/bob.key" -out "$OUT/bob.csr" -nodes -subj "/CN=Bob"

# CA signs Bob's CSR to produce bob.crt.
#   -CAserial uses the same file to increment serials for each cert issued
openssl x509 -req -in "$OUT/bob.csr" \
  -CA "$OUT/ca.crt" -CAkey "$OUT/ca.key" \
  -CAserial "$OUT/ca.srl" \
  -out "$OUT/bob.crt" -days 365

# Clean up temporary CSR files—only keys and certs are kept
rm -f "$OUT/alice.csr" "$OUT/bob.csr"
