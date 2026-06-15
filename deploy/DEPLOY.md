# Deploying malariaChat to AWS at `malariachat.org`

End-to-end walkthrough for putting the Phase A teaching deployment on
an AWS EC2 instance behind HTTPS, with the domain `malariachat.org`
(already in Route 53), per-IP rate limiting, and a tight `max_tokens`
cap on Anthropic API calls.

Target: a fresh **Ubuntu 22.04 LTS** EC2 in `us-east-1` (any region
works; adjust to taste). You will need an LLM API key for the
configured backend (the default backend is Anthropic).

---

## What lives where

```
local machine (this repo)     EC2 (Ubuntu 22.04, us-east-1, t3.small)
─────────────────────────     ─────────────────────────────────────
malariachat/                  /opt/malariachat/
├── malariachat.abe           ├── malariachat           (binary)
├── llm.abe                   ├── ui/index.html
├── ui/index.html             └── schema/01-*.sql
├── schema/01-*.sql
└── deploy/                    /etc/caddy/Caddyfile      (TLS + ratelimit)
    ├── Caddyfile              /etc/systemd/system/malariachat.service
    ├── deploy.sh             /etc/malariachat/anthropic-key  (chmod 600)
    ├── setup-ec2.sh          PostgreSQL → db: malariachat, user: malariachat
    └── malariachat.service
```

---

## One-time setup

### 1. Provision the EC2

In the AWS console (or via `aws` CLI on your local machine):

- Launch a fresh **t3.small** Ubuntu 22.04 LTS instance in **us-east-1**.
- Storage: **20 GB gp3** is plenty (schema + UI + binary + logs < 1 GB).
- Security group inbound:
  - **22** (SSH) from your IP only
  - **80** (HTTP) from `0.0.0.0/0` — Let's Encrypt validation needs this
  - **443** (HTTPS) from `0.0.0.0/0`
- Attach an **Elastic IP** so the public IP is stable across reboots.

### 2. Point Route 53 at the EC2

In Route 53, for the `malariachat.org` hosted zone, create two **A** records:

- `malariachat.org` → `<the Elastic IP>`
- `www.malariachat.org` → `<the Elastic IP>`

TTL 300 is fine for now.

### 3. Run the EC2 setup script

```bash
# From your local machine:
scp deploy/setup-ec2.sh ubuntu@malariachat.org:/tmp/

# SSH in and run as root:
ssh ubuntu@malariachat.org
sudo bash /tmp/setup-ec2.sh
exit
```

What it does:
- Installs Postgres, Go (for xcaddy), rsync, base build packages
- Creates the `malariachat` OS user + Postgres role + Postgres database
- Builds Caddy with the `caddy-ratelimit` plugin (needed for per-IP
  rate limit — the standard apt-installed Caddy doesn't include it)
- Creates `caddy` user + systemd unit
- Sets up `/opt/malariachat` and `/etc/malariachat` directories

### 4. Install the LLM API key on the EC2

> **Never paste the key into chat or anywhere it might be transcribed.**

The daemon reads the key two ways (see `apiKeyPath()` / `loadApiKey()`
in `llm.abe`):

- **`ANTHROPIC_API_KEY`** — the key value, read directly from the
  environment. Convenient for the systemd unit (`Environment=` or an
  `EnvironmentFile=`).
- **a key file** — path from `ANTHROPIC_API_KEY_PATH`, or, when that
  env var is unset, the default `/etc/malariachat/anthropic-key`.

To install a key file at the default location, put the key in a local
file (containing only the key) and copy it over:

```bash
# From your local machine (./anthropic-key holds ONLY the key):
scp ./anthropic-key ubuntu@malariachat.org:/tmp/ak

ssh ubuntu@malariachat.org
sudo install -o malariachat -g malariachat -m 0600 /tmp/ak /etc/malariachat/anthropic-key
rm /tmp/ak
exit
```

For local development, the simplest path is `export ANTHROPIC_API_KEY=...`
before running the daemon.

### 5. Install the Caddyfile + systemd unit

```bash
# From your local machine:
scp deploy/Caddyfile           ubuntu@malariachat.org:/tmp/
scp deploy/malariachat.service ubuntu@malariachat.org:/tmp/

ssh ubuntu@malariachat.org
sudo install -m 0644 /tmp/Caddyfile           /etc/caddy/Caddyfile
sudo install -m 0644 /tmp/malariachat.service /etc/systemd/system/malariachat.service
sudo systemctl daemon-reload
exit
```

---

## Every deployment after that

From your local machine, run:

```bash
deploy/deploy.sh ubuntu@malariachat.org
```

What it does:
1. Compiles `malariachat.abe` locally (`abec ...`)
2. Stages binary + `ui/` + `schema/` into a tempdir
3. `rsync` to `ubuntu@malariachat.org:/opt/malariachat/` (uses
   `rsync-path="sudo rsync"` to write as root then `chown -R malariachat`)
4. Applies any new schema migrations (idempotent `psql -f *.sql`)
5. `sudo systemctl restart malariachat.service`
6. Smoke-checks `http://127.0.0.1:8444/v1/health` on the EC2 + a
   public-internet `https://malariachat.org/v1/health` check.

You need `sudo` without password on the EC2 for the rsync step. The
default `ubuntu` user on AWS Ubuntu AMIs has this via the
`/etc/sudoers.d/90-cloud-init-users` file.

---

## First-time boot

After the one-time setup AND a first `deploy.sh`:

```bash
ssh ubuntu@malariachat.org
sudo systemctl enable --now malariachat
sudo systemctl enable --now caddy
```

Caddy will provision the Let's Encrypt certificate on first start
(takes ~30 seconds — watch `sudo journalctl -u caddy -f`).

Hit `https://malariachat.org` in a browser. You should see the
chat UI with the country dropdown defaulting to Rwanda. Open the
Settings modal, change to one of the teaching-mode countries
(e.g. Tanzania), and try a query.

---

## Configuration locked in this build

- **`max_tokens` = 800** (`configMaxTokens()` in
  `malariachat.abe`). IPTp canonical narrative is ~250 tokens;
  assess + caveat ~400. 800 gives ~2× headroom and caps Anthropic
  spend per request. Raise only if responses get truncated.

- **Per-IP rate limit = 60 requests / minute** (Caddyfile,
  `events 60`, `window 1m`). Effectively 1 req/sec average. Reviewer
  using the app normally is well under this; an abuser hits the
  ceiling fast. Returns HTTP 429 when exceeded.

- **HTTPS only**. The Caddyfile redirects HTTP→HTTPS automatically.

- **Daemon binds 127.0.0.1:8444 only**, so the public internet can
  only reach it through Caddy. (This is how the Abe daemon currently
  binds — confirm with `sudo ss -tlnp | grep 8444` on the EC2.)

---

## Operations

### Watch live logs

```bash
sudo journalctl -u malariachat -f    # daemon logs
sudo journalctl -u caddy     -f    # access + TLS logs
```

### Restart after a config change

```bash
sudo systemctl restart malariachat   # after deploy.sh — automatic
sudo systemctl reload  caddy       # after Caddyfile edits (zero-downtime)
```

### Verify health from anywhere

```bash
curl -sS https://malariachat.org/v1/health
```

### Postgres backup

A daily logical backup is enough for a teaching deployment.
Add to `/etc/cron.daily/malariachat-backup`:

```bash
#!/bin/bash
set -e
DATE=$(date +%Y%m%d)
sudo -u malariachat pg_dump -Fc malariachat > /var/backups/malariachat-$DATE.dump
find /var/backups -name 'malariachat-*.dump' -mtime +30 -delete
```

(`chmod +x` it.) Then optionally `aws s3 cp` the daily dump to a
private S3 bucket if you want off-instance retention.

---

## Reviewer onboarding

Each reviewer opens `https://malariachat.org`, then:

1. Clicks the **gear icon** at the bottom-left of the chats sidebar.
2. Enters their name, **email** (required — chats are filtered per
   email + country), their country, and language.
3. Saves.

Their chats are isolated to their email + country combination — a
Tanzanian reviewer won't see a Kenyan reviewer's chats and vice
versa.

> **Privacy note for reviewers**: this is a synthetic-data teaching
> tool. The current build does not implement email-based auth — anyone
> entering a given email sees that email's chats. Tell reviewers to
> treat the email as a *session label*, not a secret. Real
> authentication is Phase B.

---

## What's NOT in this deployment (Phase B follow-ups)

- No CDN / no edge caching (Cloudfront could front Caddy if traffic warrants)
- No email/auth — anyone with a reviewer's email string can see their chats
- No automated chat-history export for reviewer feedback aggregation
- No multi-AZ failover — single EC2 is a single point of failure
- No CloudWatch metrics / alerts — relying on `journalctl`
- Postgres on the same EC2 as the daemon (RDS later if needed)

---

## Cost estimate (us-east-1, on-demand)

- EC2 t3.small: ~$15/month
- 20 GB gp3 storage: ~$2/month
- Elastic IP (attached): free; only billed if unattached
- Route 53 hosted zone: $0.50/month
- Anthropic API: usage-based. At 60 req/min ceiling × 800 max_tokens
  × ~$1.50/M input + $5/M output for Haiku 4.5, the rate-limited
  ceiling is ~$0.001 per request. Realistic teaching traffic at
  ~30 reviewers × 10 messages/day × 30 days = 9,000 messages/month
  = ~$10/month.

Expected total: **$25–30/month** at modest reviewer traffic.

---

## Known Phase B items relevant once live

See the Phase B punch list in the top-level `README.md` for the full
list. The items most likely to surface from real reviewer traffic:

- **Swahili content errors** — concrete known issues (`dawa ya asili`,
  `kumnyonyeza kwa sehemu ya tumboni`, `chakula kisicho na mafuta`).
  Will show up the moment a real Swahili reviewer asks a non-IPTp
  clinical question.
- **Non-IPTp `doX` SW/FR fallback** — those handlers fall back to
  English for SW/FR. Reviewers from Tanzania/Kenya/Burundi/DRC will
  notice on /v1/assess, /v1/danger, /v1/pregnancy queries.
- **French content gaps** — severeMalariaReferral in English for
  CD/BI users; unreviewed French danger keywords.

These are all behind the teaching-mode banner. Real clinical
deployment needs the native-clinician review pass first.
