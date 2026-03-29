#!/usr/bin/env bash
set -euo pipefail    # Exit if any command fails, any variable is unset, or any command in a pipeline fails

# Get the root directory of the project (one level above where this script lives)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Set the output directory for certs, keys, and processed files (should already exist)
OUT="$ROOT/demo_out"
# Location of the input text message to sign
MSG="$ROOT/messages/hello.txt"

# Sign the message using S/MIME:
#   - Input: plaintext file ($MSG)
#   - Output: S/MIME (PKCS#7) signed message PEM file ($OUT/signed.pem)
#   - Use Alice's certificate and private key to sign
#   - The signed PEM contains both the message and signature, plus some headers
openssl smime -sign -in "$MSG" -text \
  -signer "$OUT/alice.crt" -inkey "$OUT/alice.key" \
  -out "$OUT/signed.pem"

# Create a temporary file to store the verified output
tmp="$(mktemp)"

# Verify the S/MIME signature:
#   - Input: the signed PEM ($OUT/signed.pem)
#   - CAfile: trust this CA certificate only ($OUT/ca.crt)
#   - Output: message body gets written to $tmp *if* the signature verifies successfully
openssl smime -verify -in "$OUT/signed.pem" \
  -CAfile "$OUT/ca.crt" \
  -out "$tmp"

echo "Verified output: $tmp"

rm -f "$tmp"
