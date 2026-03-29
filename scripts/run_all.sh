#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT/demo_out"

"$ROOT/scripts/01_gen_certs.sh"
"$ROOT/scripts/02_sign_verify.sh"
"$ROOT/scripts/03_encrypt_decrypt.sh"
