# MalariaChat

[https://malariachat.org](https://malariachat.org)

A teaching chatbot for malaria, designed for community-health-worker training
across seven African countries. Open source. Written end-to-end in [Abe](https://github.com/Electronic-Tools-Company/abe),
a small systems language with a C-compiled runtime.

> **Disclaimer.** MalariaChat is an open-source software *example* and a *teaching*
> tool — it is **not a validated or certified clinical decision-support system, and
> not a substitute for professional medical judgement**. Every response is
> protocol-derived and must be reviewed by a qualified supervisor; do not use it to
> make real patient-care decisions. Provided "as is", without warranty (see LICENSE).

This README serves two audiences:

- **Users** (CHW students, public-health trainers, malaria educators) who
  just want to use the site — start at [Using MalariaChat](#using-malariachat).
- **Developers** (Abe-curious, malaria-tool builders, contributors) who
  want to understand the code, build it, deploy it, or fork it for their
  own purposes — start at [MalariaChat as an Abe Example](#malariachat-as-an-abe-example).

---

## What MalariaChat does

MalariaChat answers the malaria questions a community health worker (CHW)
or trainee asks at the bedside:

- Dose calculation for AL by patient weight
- Severity triage — does this patient have danger signs requiring referral?
- Pregnancy-aware treatment — which trimester, which drug?
- IPTp (Intermittent Preventive Treatment in pregnancy) explanation
- Malaria vaccines (RTS,S, R21) eligibility
- Open-ended Q&A on prevention, terminology, programme structure

The defining design choice: **clinical decisions are deterministic, not
LLM-generated.** Dose, severity, and pregnancy answers come from SQL
tables (RBC 2024 for Rwanda; WHO 2024 baseline for the six teaching-mode
countries). The LLM only rewords the structured result into conversational
prose. This means a wrong drug or wrong dose is essentially impossible —
the LLM is never asked to invent a number.

A visible teaching-mode banner appears on every response for the six
non-Rwanda countries, reminding the user that the content is the WHO
2024 baseline and not a country-specific national protocol.

---

## Country and language support

| Country | Code | Mode | UI / clinical languages |
|---|---|---|---|
| Rwanda | RW | Production (RBC 2024 protocol) | English, Kinyarwanda |
| Tanzania | TZ | Teaching (WHO 2024 baseline) | English, Kinyarwanda, Swahili |
| Kenya | KE | Teaching | English, Kinyarwanda, Swahili |
| Uganda | UG | Teaching | English |
| Zambia | ZM | Teaching | English |
| Burundi | BI | Teaching | French |
| DR Congo | CD | Teaching | French |

Teaching-mode content is reviewed against the WHO Global Malaria Programme
Guidelines (2024). It is **not yet reviewed by national-clinician reviewers
for any non-Rwanda country**. Phase A demo / training use only; pilot
clinical use requires the Phase B review pass (see the Phase B punch
list below).

---

# Using MalariaChat

## Opening the site

Go to [https://malariachat.org](https://malariachat.org) in any browser
(desktop or mobile). The chat loads with the welcome screen and a
"Rwanda CHW assistant" banner at the top.

## First-time setup (settings)

Click the **gear icon ⚙ at the bottom-left** of the chats sidebar to open
the Settings modal. Fill in:

- **User Name** — free-text. Optional but useful so the LLM can address
  you ("Health worker Marie, …").
- **Email** *(required)* — your work email. Chats are filtered per
  email + country combination, so different reviewers see different
  chat histories. **There is no password / no authentication on the
  email field today** — treat the email as a session label, not a
  secret. Real auth is a Phase B item.
- **Phone** *(optional)* — currently stored but not used by the app.
- **Country** — pick yours from the dropdown. Switching country may
  also force the language (see below).
- **District** *(Rwanda only)* — the 30 Rwandan districts, grouped
  A/B/C by MFT (Multiple First-Line Therapy) rotation. Hidden when
  country isn't Rwanda. Optional — leaving it blank defaults to
  Group A; the canonical response will then tell you to set the
  district for accurate MFT routing.
- **Language** — English (`en`), Kinyarwanda (`rw`), Swahili (`sw`),
  or French (`fr`). Not all combinations are enabled:
  - Rwanda / Tanzania / Kenya: English, Kinyarwanda, Swahili
  - Uganda / Zambia: **English only**
  - Burundi / DRC: **French only**

  Switching the country to a single-language country automatically
  forces the language and disables the other pills.

Click **Save**. Your settings persist in the browser's localStorage
under the key `malariaChat.settings.v2` — they survive page reloads
but live only in that browser.

## Asking questions

Type your question in the message box at the bottom. Examples that
work well:

- `child 22 kg RDT positive, no danger signs`
- `pregnant 8 weeks, RDT positive`
- `What is IPTp?`
- `convulsion and unable to drink` *(triggers the severe-malaria gate)*
- `Quel est le traitement pour une femme enceinte au 2e trimestre ?` *(BI / CD)*
- `Mtoto kilo 12 RDT chanya` *(TZ / KE in Swahili)*

The deterministic engine extracts the relevant clinical inputs (weight,
RDT result, gestational age, district, danger keywords) from your text
and routes the response accordingly. Conversational details — "the child
has been vomiting since morning", politeness phrases, free-form context —
are fine to include; only the clinical anchors influence the calculation.

## Reading the response

A typical response has up to four parts:

1. **Teaching caveat** *(non-Rwanda countries only)* — a `[Teaching mode]` /
   `[Hali ya kufundisha]` / `[Mode enseignement]` / `[Uburyo bw'inyigisho]`
   line at the very top, naming your country and pointing at your
   national malaria control programme for clinical use.
2. **Salutation** *(optional)* — `Health worker,` / `Nshuti z'Ubuzima,` /
   `Watoa huduma za afya,` / `Agent de santé,` — matching your language.
3. **Clinical narrative** — the deterministic answer (drug, dose,
   schedule, contraindications, trimester rule, etc.) reworded by the
   LLM. Numbers, drug names, and weight bands are *exactly* what the
   structured engine computed; the LLM is forbidden by rule 1 to invent
   them.
4. **Protocol markers** — `[DOSE_ALERT]`, `[KOHEREZA]`, `[PROTOCOL_REVIEW_REQUIRED]`,
   `[BIMENYETSO_BIBI]` — these are deliberate visual flags meant to
   stand out. Don't translate or paraphrase them; they're meant to be
   parseable by both humans and any downstream automation.

## Chats sidebar

The left rail lists your past chats, scoped to **your email + your
current country**. Switching country in Settings refreshes the
sidebar to show only that country's history (so a Tanzanian reviewer
won't see their Rwandan colleague's chats). Click any past chat to
load it back into the main thread; click **+ New chat** to start
fresh.

The chat title is the first message you sent in that conversation.
A `3h` auto-close hits any conversation idle for more than three
hours; the next message you send opens a new conversation row.

## What MalariaChat will NOT do

- **Make a clinical decision the deterministic engine can't compute.** If
  you ask "should I refer this patient", the answer is structured by
  the SQL tables — there is no "AI clinical judgement" layer.
- **Diagnose anything other than malaria.** Outside-scope questions
  get a polite "ask your supervisor".
- **Work without your supervisor.** Every response carries
  `[PROTOCOL_REVIEW_REQUIRED]`. Phase A is a training tool, not a
  field deployment.
- **Remember you across browsers.** Settings live in localStorage in
  the browser you're on. Chat history lives in the server's database
  keyed by your email — the email IS the identity.

## Reporting feedback

While the app is in reviewer pilot, the best feedback channels are:

- For Kinyarwanda / Swahili / French content errors — exact quotes from
  the response that read wrong (with the country + language you were
  in) into a GitHub issue at
  [Electronic-Tools-Company/abe](https://github.com/Electronic-Tools-Company/abe/issues).
- For clinical content concerns — the same, but flag them clearly. A
  Phase B safety pass with national clinicians is queued and your
  feedback will feed into it.
- For UI / bug reports — same GitHub issues.

---

# MalariaChat as an Abe Example

## Why it's a useful Abe demo

MalariaChat is a small but real production deployment that exercises
roughly 80% of Abe's standard library:

- HTTP server (with routing, query/body parsing, JSON responses)
- HTTP client (Anthropic API integration)
- PostgreSQL via libpq (deterministic clinical lookups)
- Multi-language string manipulation, JSON building, regex-style
  pattern matching (`indexOf` chains as a stand-in for full regex)
- Per-process counters, audit logging, opaque pointer types
- Production-shape system service (systemd, Caddy in front, TLS)

The Abe source is **3000+ lines for the main service** (`malariachat.abe`)
+ ~250 lines for the LLM wrapper (`llm.abe`) + ~1000 lines of
HTML/CSS/JS for the chat UI (`ui/index.html`). Nothing in the daemon
is "magic" — every behaviour is grep-able to a function definition in
the .abe files.

## High-level architecture

```
Internet → Route 53 (malariachat.org A record)
             ↓
        AWS EC2 t3.small (us-east-1, Ubuntu 22.04)
             │
   ┌─────────┴──────────────────────────────────────┐
   │                                                │
   ▼                                                ▼
 Caddy (port 443, TLS, rate limit)         PostgreSQL 15
   │                                                ▲
   ▼                                                │
 malariachat       (port 8444, Abe daemon) ────────┘
   │                                          (libpq, loopback)
   ▼
 LLM backend (default: Anthropic claude-haiku-4-5-20251001)
```

## Repo layout

All paths are relative to this repo's root.

```
malariachat/
├── malariachat.abe             # the 3000-line main service
├── llm.abe                     # pluggable LLM backend (swap point)
├── ui/
│   └── index.html              # ~1000 lines, vanilla HTML/CSS/JS (no framework)
├── schema/                     # 10 idempotent SQL migrations
│   ├── 01_schema.sql           # all tables
│   ├── 02_seed_from_handbook.sql       # RBC 2024 protocol data
│   ├── 03_migrate_weight_bands.sql
│   ├── 04_mft_geography.sql    # Rwanda 30 districts → MFT groups A/B/C
│   ├── 05_chat.sql             # chat_conversations + chat_messages
│   ├── 06_chat_settings.sql    # adds country / user_name
│   ├── 07_chat_profile.sql     # adds email / phone
│   ├── 08_iptp_contraindications_rw_clarify.sql
│   ├── 09_who_baseline.sql     # WHO-2024 protocol clone for teaching mode
│   └── 10_who_baseline_french.sql      # French danger keywords
├── deploy/                     # AWS deployment artifacts
│   ├── Caddyfile               # TLS + rate-limit reverse proxy
│   ├── malariachat.service     # systemd unit for the daemon
│   ├── setup-ec2.sh            # first-time EC2 setup
│   ├── deploy.sh               # every-deploy: build, scp, restart
│   └── DEPLOY.md               # step-by-step deployment walkthrough
└── README.md                   # this file
```

## Key design patterns to study

If you're forking MalariaChat for a different clinical domain, these
patterns generalise:

### 1. The `doX` / handler split

Every clinical concept has a pure-function "doer" (`doAssess`,
`doDanger`, `doPregnancy`, `doFirstLine`, `doIptp`, `doVaccines`)
that returns a `"NNN{json}"` string — three-digit HTTP status prefix
+ JSON body. Two thin shells consume it:

- The HTTP handler (`/v1/assess`, `/v1/iptp`, etc.) — for direct
  programmatic access.
- The `/v1/chat` orchestrator — which classifies user intent,
  dispatches to the right `doX`, hands the structured result to the
  LLM for paraphrasing, and persists the turn.

This separation means each clinical decision is one testable function
and the chat flow is just routing + LLM glue.

### 2. Canonical narratives (rule 10)

Some prose is too important to let the LLM compose freely — IPTp
contraindications, the default-A note, the PLACEHOLDER MFT-rotation
note, the educational caveat. These are **canonical strings**, written
once by a clinician, locked into the system prompt with explicit
"emit verbatim" instructions and listed forbidden-paraphrase examples.
Result: the LLM emits clinical-critical text character-for-character
across non-deterministic generations.

The mechanism: rule 10 in `chatWrapClinicalPrompt`. When the
deterministic engine emits a `narrative` field in its structured
result, the LLM must emit it as the body of the reply. Rephrasing,
translating, summarising, and synonym substitution are all explicitly
forbidden.

### 3. Server-side caveat prepend

The teaching-mode caveat for non-Rwanda countries is **prepended by
the server** to the LLM response, not emitted by the LLM. This was
hard-won: previously we asked the LLM to emit the caveat and it
substituted country names (saying "Tanzania" for a Zambia user) and
sometimes skipped the caveat entirely on severe-malaria responses.
Server-side prepend eliminates both failure modes.

Pattern: anything safety-critical that has a determinable form should
NOT rely on the LLM to emit it.

### 4. Post-LLM substitution

The chatHandler does several post-LLM string substitutions for non-RW
countries — `RBC 2024 → WHO 2024`, `district hospital → referral
hospital`, `Inshuti y'Ubuzima → CHW`, `Multiple First-Line Therapy →
the national first-line antimalarial`, `district → commune` (Burundi)
/ `district → territoire` (DRC), and so on. Each is documented inline
with a comment explaining the failure mode it patches.

This is a workaround for the deeper Phase B work: properly threading
country-aware text construction through the prose helpers. The
substitution approach traded purity for shipping speed.

### 5. Idempotent SQL migrations

Every `schema/NN_*.sql` file uses `IF NOT EXISTS` / `ON CONFLICT DO
NOTHING` / DO-blocks that check for prior state. Re-running the
migration set on a partially-applied database does not error and does
not duplicate rows. This is what makes `deploy.sh` safe to re-run.

### 6. Style-guide source-of-truth

`llm.abe` exports `rwStyleGuide()` and `swStyleGuide()` —
Kinyarwanda and Swahili style conventions distilled from clinician
review. Updating one bullet here changes every RW/SW response the
system produces, no matter which deterministic path emitted the
narrative. This is the load-bearing surface for native-speaker review.

## Building MalariaChat locally

> **Toolchain news.** The latest Abe compiler is **`abec` 0.2.0**
> ([`v2026.06.21`](https://github.com/E-Tools-AI-Corporation/abec/releases/latest)) —
> it adds a complete, native machine-learning toolchain (tensors, layers/models,
> transformer attention, inference + training, quantization, GPU, ONNX, and more;
> see the 22-chapter
> [ML manual](https://github.com/E-Tools-AI-Corporation/abec/releases/latest/download/ABE-Pro-ML-Manual-0.2.0.md)).
> MalariaChat builds unchanged on 0.2.0; its clinical answers stay deterministic
> SQL by design, so it doesn't depend on the ML features.

You need:

- The `abec` Abe compiler — a commercial product (see
  [Compiler licensing](#compiler-licensing-abec)); an unlicensed evaluation
  build is enough to compile this example. Get the latest Linux x86-64 build from
  [the abec releases page](https://github.com/E-Tools-AI-Corporation/abec/releases/latest)
  (or the [bundle](https://github.com/E-Tools-AI-Corporation/abec/releases/latest/download/abec-0.2.0-linux-x86_64.tar.gz) with the runtime included)
- PostgreSQL 15+ running on `127.0.0.1:5432`
- An LLM API key for the configured backend. For the default Anthropic
  backend, set `ANTHROPIC_API_KEY` in the environment, or point
  `ANTHROPIC_API_KEY_PATH` at a file containing the key.

```bash
# From this repo's root:

# 1. Build the daemon
abec malariachat.abe -o /tmp/malariachat

# 2. Create the database + apply migrations
sudo -u postgres createuser $(whoami)
sudo -u postgres createdb -O $(whoami) malariachat
for f in schema/*.sql; do psql -d malariachat -f "$f"; done

# 3. Run (the daemon serves ui/index.html and reads schema/*.sql)
export ANTHROPIC_API_KEY="sk-ant-..."   # or set ANTHROPIC_API_KEY_PATH
/tmp/malariachat

# 4. Open
xdg-open http://localhost:8444    # or your platform's equivalent
```

Hit `http://localhost:8444` in a browser. Use Settings to pick a
country + language; the chat works locally with no other dependencies.

## Deploying MalariaChat (AWS EC2 example)

See [`deploy/DEPLOY.md`](deploy/DEPLOY.md) for the full step-by-step
guide. The short version:

```bash
deploy/setup-ec2.sh                  # one-time on the EC2: postgres, caddy, go, dirs
deploy/deploy.sh ubuntu@<host>       # every deploy: build local, scp, restart
```

Cost: ~$25–30/month on AWS us-east-1 at modest reviewer traffic
(EC2 t3.small + EBS + Route 53 + Anthropic Haiku 4.5 usage).

## Forking MalariaChat for your own clinical domain

Realistic checklist if you're cloning MalariaChat to teach a
different topic (cardio, neonatal, antibiotic stewardship, …) in
your own countries / languages:

1. **Schema** — replace `02_seed_from_handbook.sql` with your
   protocol's clinical data. Keep the table structure (`*_protocol`,
   `*_weight_bands`, `danger_signs`, etc.); the deterministic-engine
   pattern carries over.
2. **Country / language layer** — `protocolForCountry` /
   `educationalCaveat` / `countryDisplayName` / LABELS.X in
   `ui/index.html`. The structure already supports en/rw/sw/fr;
   adding a 5th language is parallel work.
3. **`doX` functions** — these are the meat of the clinical logic.
   Each is ~50–200 lines of SQL-driven dispatch + JSON building.
4. **Style guides** — `llm.abe` `rwStyleGuide` and
   `swStyleGuide`. Replace with your domain's preferred clinical
   vocabulary.
5. **Welcome / placeholders / banners** — LABELS in `ui/index.html`.
6. **Branding** — favicon, header text, the `MalariaChat` string in
   ~15 places (sed-replaceable).

What you **probably don't** need to change:

- The chat orchestrator (`chatHandler`) — domain-agnostic
- The settings modal flow and `chat_conversations` schema
- The LLM wrapper (`llm.abe`)
- The deployment artifacts (`deploy/`)
- The systemd / Caddy / proxy layer

## Phase B punch list

What's not done in the current build, in priority order:

1. Native-clinician review of Swahili and French content
2. Concrete observed Swahili content errors (`dawa ya asili` for
   artemisinin, `kumnyonyeza kwa sehemu ya tumboni` for rectal
   administration, `chakula kisicho na mafuta` for AL with food)
3. Full SW / FR canonical narratives for non-IPTp `doX` functions
4. Email-based real authentication
5. Chat-history retention / export for reviewer feedback aggregation
6. Multi-AZ / RDS / failover (current single-EC2 has no SLA)
7. CloudWatch metrics / alerts
8. `parseGestationalWeeks` should accept months (`8 mois` → 32 weeks)
9. The 6 raw TCP socket externs design (`runtime/PHASE_B_TCP_EXTERNS.md`)
   would let raw-TCP services be written in Abe directly (not needed
   for MalariaChat itself anymore but enables other Abe services)

See the in-repo design notes for the full list with context.

---

## Compiler licensing (abec)

MalariaChat itself is MIT-licensed (see below), but it is **built with `abec`,
the Abe compiler — a commercial product of E-Tools AI Corporation**. The two are
separate: this example is free and open; the compiler that turns `.abe` source
into a native binary is licensed.

- **Evaluation:** with no licence installed, `abec` still compiles — it prints an
  `UNLICENSED EVALUATION` banner and works for a built-in trial window. That is
  enough to build and study MalariaChat.
- **Production / banner-free builds** require a licence. Install your licence
  token in any one of these ways:
  - write it to `~/.abe/license`
  - `export ABEC_LICENSE="ABE1.…"`  (recommended for CI and containers)
  - `export ABE_LICENSE_FILE=/path/to/license`
  - precedence if more than one is present: `ABEC_LICENSE` → `ABE_LICENSE_FILE` →
    `~/.abe/license`
- `abec --version` always works without a licence.
- To purchase a licence or request an extended evaluation, contact
  **licensing@e-tools.ai**.

## Licence and contributions

MalariaChat is released under the [MIT License](LICENSE). Use, modify,
and redistribute freely; please retain attribution.

Clinical content (the RBC 2024 protocol seeded in
`schema/02_seed_from_handbook.sql`) is the property of the Rwanda
Biomedical Centre. The WHO 2024 baseline is the property of the
World Health Organization. Both are publicly accessible; MalariaChat
treats them as reference data, not as MalariaChat's IP.

Contributions welcome via PRs to
[Electronic-Tools-Company/abe](https://github.com/Electronic-Tools-Company/abe).
The Phase B punch list above is a good place to start.

## Acknowledgements

- **Rwanda Biomedical Centre (RBC)** — for the 2024 Integrated
  Malaria Control Guidelines.
- **WHO Global Malaria Programme** — for the 2024 baseline.
- **Antoine Bigirimana** — clinical-side design, native Kinyarwanda
  review across hundreds of LLM-generated draft phrases, country-rollout
  decisions.
- **Anthropic** — Claude Haiku 4.5 powers the prose-paraphrase layer
  in the reference deployment. The LLM backend is pluggable: swap in
  any LLM (hosted or self-hosted) at the single seam in `llm.abe`.
- **The Abe language and runtime** — the substrate this is all
  written in. See [the Abe repo](https://github.com/Electronic-Tools-Company/abe)
  for the language itself.
