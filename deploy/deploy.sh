#!/usr/bin/env bash
# deploy.sh — build malariaChat locally and push to the EC2.
#
# Usage:
#   deploy/deploy.sh <ssh-target>
#
# Example:
#   deploy/deploy.sh ubuntu@malariachat.org
#
# Run from anywhere — the script locates the project root from its own
# location. Requires the Abe compiler `abec` on PATH.

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <ssh-target>   (e.g. ubuntu@malariachat.org)" >&2
    exit 1
fi
REMOTE="$1"

# Project root = the directory that contains this deploy/ folder.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "▸ Project root: $PROJECT_ROOT"
echo "▸ Remote:       $REMOTE"
echo

# ── 1. Build the binary locally ───────────────────────────────────
echo "→ Compiling malariachat.abe…"
cd "$PROJECT_ROOT"
abec malariachat.abe -o /tmp/malariachat-deploy
echo "  binary size: $(stat -c %s /tmp/malariachat-deploy) bytes"

# ── 2. Stage the artifacts ────────────────────────────────────────
STAGE="$(mktemp -d)"
trap "rm -rf '$STAGE'" EXIT
echo "→ Staging artifacts in $STAGE…"
cp /tmp/malariachat-deploy "$STAGE/malariachat"
chmod +x "$STAGE/malariachat"
cp -r "$PROJECT_ROOT/ui"      "$STAGE/ui"
cp -r "$PROJECT_ROOT/schema"  "$STAGE/schema"

# ── 3. Rsync to remote ────────────────────────────────────────────
echo "→ Rsyncing to $REMOTE:/opt/malariachat/…"
# --rsync-path with sudo so the unprivileged ssh user can write into
# /opt/malariachat. Requires sudo without password OR an SSH agent +
# interactive sudo prompt.
rsync -azP --delete-after \
    --rsync-path="sudo rsync" \
    "$STAGE/" "$REMOTE:/opt/malariachat/"

# Ownership fix after rsync.
echo "→ Fixing ownership on remote…"
ssh "$REMOTE" "sudo chown -R malariachat:malariachat /opt/malariachat"

# ── 4. Apply any new schema migrations ────────────────────────────
echo "→ Applying schema migrations…"
ssh "$REMOTE" 'sudo -u malariachat bash -c "cd /opt/malariachat/schema && for f in \$(ls *.sql 2>/dev/null | sort); do echo \"  applying \$f\"; psql -d malariachat -f \$f >/dev/null; done"'

# ── 5. Restart the daemon ─────────────────────────────────────────
echo "→ Restarting malariachat.service…"
ssh "$REMOTE" 'sudo systemctl restart malariachat.service'
sleep 2
ssh "$REMOTE" 'sudo systemctl is-active malariachat.service'

# ── 6. Smoke check via loopback ───────────────────────────────────
echo "→ Smoke check on remote loopback…"
ssh "$REMOTE" 'curl -sS http://127.0.0.1:8444/v1/health | head -c 200; echo'

# ── 7. Smoke check via public HTTPS (if Caddy is up) ──────────────
echo "→ Public HTTPS check…"
if curl -sS --max-time 5 -o /dev/null -w "%{http_code}\n" https://malariachat.org/v1/health 2>/dev/null; then
    echo "  ✓ https://malariachat.org reachable"
else
    echo "  ⚠ https://malariachat.org NOT yet reachable (Caddy may still be provisioning the cert; check sudo journalctl -u caddy on the EC2)"
fi

echo
echo "✓ Deployment complete."
