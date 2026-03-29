#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "CVE-2026-2748 educational PoC — whitespace in S/MIME certificate email SAN"
echo "See: $ROOT/README.md"
echo ""

"$ROOT/scripts/01_gen_ca_and_attacker.sh"
echo ""
"$ROOT/scripts/02_build_and_sign_message.sh"
echo ""
python3 "$ROOT/scripts/03_gateway_binding_check.py"

echo ""
echo "Done. Artifacts under $ROOT/demo_out/"
