#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "CVE-2019-10740 educational demo — Roundcube reply-leak class (MIME wrap)"
echo "See: $ROOT/README.md"
echo ""

"$ROOT/scripts/01_crafted_trap_email.sh"

echo ""
echo "Done. Artifact: $ROOT/demo_out/cve_2019_10740_trap.eml"
