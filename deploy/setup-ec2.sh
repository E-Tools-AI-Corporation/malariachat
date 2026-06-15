#!/usr/bin/env bash
# setup-ec2.sh — first-time setup of a fresh Ubuntu 22.04 LTS EC2 for
# malariaChat. Run ONCE on the EC2 after first boot, as root:
#   sudo bash setup-ec2.sh
#
# After this completes you still need to:
#   1. Install the LLM API key on the host (chmod 600, owned by
#      malariachat) — see "Install the API key" in the next-steps
#      output and in deploy/DEPLOY.md.
#   2. From your local machine: run deploy/deploy.sh to push the binary,
#      UI, and schema migrations.
#   3. Reload Caddy (`sudo systemctl reload caddy`) so it picks up the
#      Caddyfile and provisions the Let's Encrypt cert.

set -euo pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "Run as root: sudo bash $0"
    exit 1
fi

# ── 1. System packages ─────────────────────────────────────────────
echo "→ Updating apt + installing base packages…"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
    postgresql postgresql-contrib libpq5 libpq-dev \
    curl ca-certificates gnupg debian-keyring debian-archive-keyring \
    apt-transport-https rsync

# ── 2. malariachat OS user ─────────────────────────────────────────
if ! id malariachat &>/dev/null; then
    echo "→ Creating malariachat system user…"
    useradd -m -s /bin/bash malariachat
fi

# ── 3. PostgreSQL: malariachat role + malariachat DB ───────────────
echo "→ Configuring PostgreSQL…"
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='malariachat'" \
    | grep -q 1 || sudo -u postgres createuser malariachat
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='malariachat'" \
    | grep -q 1 || sudo -u postgres createdb -O malariachat malariachat

# ── 4. Install Go (for xcaddy build) + Caddy with rate-limit plugin ─
if ! command -v go &>/dev/null; then
    echo "→ Installing Go 1.22 (needed by xcaddy)…"
    curl -fsSL -o /tmp/go.tar.gz https://go.dev/dl/go1.22.7.linux-amd64.tar.gz
    rm -rf /usr/local/go
    tar -C /usr/local -xzf /tmp/go.tar.gz
    ln -sf /usr/local/go/bin/go     /usr/local/bin/go
    ln -sf /usr/local/go/bin/gofmt  /usr/local/bin/gofmt
fi

if ! command -v xcaddy &>/dev/null; then
    echo "→ Installing xcaddy…"
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
    cp ~/go/bin/xcaddy /usr/local/bin/xcaddy
fi

if [ ! -x /usr/local/bin/caddy ] || ! /usr/local/bin/caddy list-modules 2>/dev/null | grep -q caddy.handlers.rate_limit; then
    echo "→ Building Caddy with caddy-ratelimit plugin…"
    XCADDY_OUT=/tmp/caddy-build
    xcaddy build --output "$XCADDY_OUT" --with github.com/mholt/caddy-ratelimit
    install -m 0755 "$XCADDY_OUT" /usr/local/bin/caddy

    # Caddy unprivileged-port binding capability
    setcap cap_net_bind_service=+ep /usr/local/bin/caddy
fi

# ── 5. Caddy service user + dirs (if not already from official pkg) ─
if ! id caddy &>/dev/null; then
    groupadd --system caddy
    useradd --system \
        --gid caddy \
        --create-home \
        --home-dir /var/lib/caddy \
        --shell /usr/sbin/nologin \
        --comment "Caddy web server" \
        caddy
fi
install -d -o caddy -g caddy /etc/caddy /var/lib/caddy /var/log/caddy

# Caddy systemd unit (matches the official one).
if [ ! -f /etc/systemd/system/caddy.service ]; then
    cat > /etc/systemd/system/caddy.service <<'EOF'
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/local/bin/caddy reload --config /etc/caddy/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF
fi

# ── 6. malariaChat install directory + API-key directory ───────────
install -d -o malariachat -g malariachat -m 0755 /opt/malariachat
install -d -o malariachat -g malariachat -m 0750 /etc/malariachat

# ── 7. Enable + start postgres, caddy, malariachat (placeholder) ───
systemctl daemon-reload
systemctl enable --now postgresql

# Note: malariachat.service and the Caddyfile are pushed by deploy.sh.
# Don't start Caddy yet — it will fail without a Caddyfile.

cat <<'NEXTSTEPS'

✓ EC2 base setup complete.

Next, from your LOCAL machine (NEVER paste the key into any chat):

  1. Install the LLM API key on the EC2. Copy a file holding only the
     key, then install it where apiKeyPath() looks by default:
       scp ./anthropic-key ubuntu@<ec2-host>:/tmp/ak
       ssh ubuntu@<ec2-host> 'sudo install -o malariachat -g malariachat -m 0600 /tmp/ak /etc/malariachat/anthropic-key && rm /tmp/ak'
     (Alternatively, set ANTHROPIC_API_KEY in the service environment,
      or point ANTHROPIC_API_KEY_PATH at a different key file.)

  2. Push the binary + UI + schema:
       deploy/deploy.sh ubuntu@<ec2-host>

  3. Push the Caddyfile + malariachat.service:
       scp deploy/Caddyfile            ubuntu@<ec2-host>:/tmp/Caddyfile
       scp deploy/malariachat.service  ubuntu@<ec2-host>:/tmp/malariachat.service
       ssh ubuntu@<ec2-host> 'sudo install -m 0644 /tmp/Caddyfile /etc/caddy/Caddyfile && sudo install -m 0644 /tmp/malariachat.service /etc/systemd/system/malariachat.service && sudo systemctl daemon-reload && sudo systemctl enable --now malariachat caddy'

  4. Verify:
       curl -I https://malariachat.org

NEXTSTEPS
