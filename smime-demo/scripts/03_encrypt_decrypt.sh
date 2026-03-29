#!/usr/bin/env bash
set -euo pipefail          # Exit on error/undefined variable/pipeline error for safety

# Set ROOT to the parent directory of this script (i.e., smime-demo root)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Set OUT to the demo output directory
OUT="$ROOT/demo_out"

# Set MSG to the plaintext message file path
MSG="$ROOT/messages/hello.txt"

# Encrypt the message for Bob:
# - Use OpenSSL smime -encrypt command
# - -aes-256-cbc chooses AES-256-CBC encryption
# - -in specifies the plaintext
# - -out is the encrypted output file
# - The recipient is Bob's public certificate (so only Bob can decrypt)
openssl smime -encrypt -aes-256-cbc -in "$MSG" \
  -out "$OUT/encrypted.pem" \
  "$OUT/bob.crt"

# Make a temporary file to store decrypted plaintext before normalizing
tmp="$(mktemp)"

# Decrypt the encrypted message as Bob:
# - -in is the encrypted PEM file
# - -recip is Bob's certificate (for compatibility)
# - -inkey is Bob's private key (needed to decrypt)
# - -out is where the decrypted content will be written (temp file)
openssl smime -decrypt -in "$OUT/encrypted.pem" \
  -recip "$OUT/bob.crt" -inkey "$OUT/bob.key" \
  -out "$tmp"

# Normalize Windows (CRLF) line endings to Unix (LF) in the decrypted file
tr -d '\r' < "$tmp" > "$OUT/decrypted.txt"

# Clean up the temporary decrypted file
rm -f "$tmp"
