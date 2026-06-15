-- =============================================================================
-- MalariaChat — PostgreSQL schema
-- =============================================================================
-- Source-of-truth tables for the malaria CHW assistant. The Abe-side API
-- becomes a thin routing layer over these tables; protocol changes (e.g.
-- new RBC release) are handled with INSERTs of new rows + a switch of the
-- active protocol_id, not with a recompile.
--
-- Idempotent for development: drops everything on re-run. Use migrations
-- (numbered _02_*, _03_*, ...) for production schema changes.
-- =============================================================================

DROP TABLE IF EXISTS adverse_events            CASCADE;
DROP TABLE IF EXISTS encounters                CASCADE;
DROP TABLE IF EXISTS drug_stock_snapshots      CASCADE;
DROP TABLE IF EXISTS weekly_case_counts        CASCADE;
DROP TABLE IF EXISTS epi_facts                 CASCADE;
DROP TABLE IF EXISTS preset_examples           CASCADE;
DROP TABLE IF EXISTS reviewed_phrases          CASCADE;
DROP TABLE IF EXISTS terminology               CASCADE;
DROP TABLE IF EXISTS procedure_steps           CASCADE;
DROP TABLE IF EXISTS treatment_failure_markers CASCADE;
DROP TABLE IF EXISTS drug_aliases              CASCADE;
DROP TABLE IF EXISTS danger_signs              CASCADE;
DROP TABLE IF EXISTS chat_messages                  CASCADE;
DROP TABLE IF EXISTS chat_conversations             CASCADE;
DROP TABLE IF EXISTS vaccine_doses                  CASCADE;
DROP TABLE IF EXISTS vaccines                       CASCADE;
DROP TABLE IF EXISTS iptp_protocol                  CASCADE;
DROP TABLE IF EXISTS trimester_rules                CASCADE;
DROP TABLE IF EXISTS antimalarial_pregnancy_safety  CASCADE;
DROP TABLE IF EXISTS mft_current_drug               CASCADE;
DROP TABLE IF EXISTS ras_doses                      CASCADE;
DROP TABLE IF EXISTS antimalarial_weight_bands      CASCADE;
DROP TABLE IF EXISTS al_weight_bands                CASCADE;
DROP TABLE IF EXISTS chw_directory                  CASCADE;
DROP TABLE IF EXISTS health_centres                 CASCADE;
DROP TABLE IF EXISTS districts                      CASCADE;
DROP TABLE IF EXISTS protocol_versions              CASCADE;

-- =============================================================================
-- Reference data — relatively stable, edited by RBC / district staff
-- =============================================================================

CREATE TABLE districts (
    district_id     SERIAL PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,
    province        TEXT NOT NULL CHECK (province IN
                       ('Eastern','Southern','Western','Northern','Kigali')),
    altitude_m      INTEGER,
    transmission    TEXT CHECK (transmission IN ('high','medium','low')),
    -- MFT rotation group per the MFT Q&A (page 3). The drug each group
    -- uses rotates yearly — see mft_current_drug. The 30 districts of
    -- Rwanda are split across the three groups.
    mft_group       TEXT CHECK (mft_group IS NULL OR mft_group IN ('A','B','C'))
);

CREATE TABLE health_centres (
    centre_id       SERIAL PRIMARY KEY,
    district_id     INTEGER REFERENCES districts(district_id),
    name            TEXT NOT NULL,
    level           TEXT CHECK (level IN ('post','centre','hospital','referral')),
    phone           TEXT,
    has_artesunate  BOOLEAN DEFAULT FALSE,
    has_al          BOOLEAN DEFAULT FALSE,
    has_ras         BOOLEAN DEFAULT FALSE,
    UNIQUE (district_id, name)
);

CREATE TABLE chw_directory (
    chw_id          SERIAL PRIMARY KEY,
    national_id_hash TEXT UNIQUE,                -- app hashes before storing
    centre_id       INTEGER REFERENCES health_centres(centre_id),
    trained_through TEXT,                        -- 'inshuti_zubuzima_2024' etc.
    active          BOOLEAN DEFAULT TRUE
);

-- =============================================================================
-- Protocol versions — versioned by release. New protocols add rows; the
-- API selects the currently-active protocol per query.
-- =============================================================================

CREATE TABLE protocol_versions (
    protocol_id     TEXT PRIMARY KEY,            -- 'RBC-2024', 'WHO-2025-08', etc.
    title           TEXT NOT NULL,
    effective_from  DATE NOT NULL,
    effective_until DATE,                        -- NULL = currently active
    source_citation TEXT
);

-- =============================================================================
-- Clinical rules — dose tables, trimester rules, regional MFT, IPTp, vaccines
-- =============================================================================

-- Weight-band dose tables for any first-line antimalarial. Today only
-- AL is seeded (from the RBC CHW handbook §4.2). When ASPY and DHA-PPQ
-- bands are added the rows just slot in with drug='ASPY' / 'DHA-PPQ'.
CREATE TABLE antimalarial_weight_bands (
    band_id         SERIAL PRIMARY KEY,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    drug            TEXT NOT NULL,               -- 'AL', 'ASPY', 'DHA-PPQ', ...
    min_kg          NUMERIC(5,2) NOT NULL,
    max_kg          NUMERIC(5,2),                -- NULL = open band (≥)
    age_label_en    TEXT,                        -- '4 mo – 3 yr'
    age_label_rw    TEXT,
    tablets_per_dose INTEGER NOT NULL,
    total_tablets   INTEGER NOT NULL,
    schedule_en     TEXT NOT NULL,
    schedule_rw     TEXT NOT NULL,
    contraindicated BOOLEAN DEFAULT FALSE,
    UNIQUE (protocol_id, drug, min_kg)
);

CREATE TABLE ras_doses (
    ras_id          SERIAL PRIMARY KEY,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    age_min_months  INTEGER NOT NULL,
    age_max_months  INTEGER,                     -- NULL = open
    weight_min_kg   NUMERIC(5,2) NOT NULL,
    weight_max_kg   NUMERIC(5,2),
    capsules        INTEGER NOT NULL,
    total_mg        INTEGER NOT NULL,
    instructions_en TEXT NOT NULL,
    instructions_rw TEXT NOT NULL
);

-- MFT current rotation. Per the MFT Q&A (page 3) Rwanda's 30 districts
-- are split into three groups (A/B/C) and each group's first-line drug
-- rotates yearly. The current assignment is operational data — must be
-- updated against the latest RBC bulletin. Handlers hard-fail with a
-- clear message if a group has no row, so a stale / missing rotation
-- never silently shows the wrong drug.
CREATE TABLE mft_current_drug (
    group_letter    TEXT PRIMARY KEY CHECK (group_letter IN ('A','B','C')),
    drug            TEXT NOT NULL CHECK (drug IN ('AL','ASPY','DHAP')),
    effective_from  DATE NOT NULL,
    source_note     TEXT
);

-- Per Integrated Guidelines 2024 page 13 "Malaria Treatment
-- Indications" matrix: AL/DHAP indicated all trimesters; ASPY
-- contraindicated in 1st trimester (allowed in 2nd + 3rd). Handlers
-- consult this when the patient is pregnant and the group's current
-- drug would be contraindicated — they substitute the fallback drug.
CREATE TABLE antimalarial_pregnancy_safety (
    drug                TEXT PRIMARY KEY CHECK (drug IN ('AL','ASPY','DHAP')),
    trimester_1_allowed BOOLEAN NOT NULL,
    trimester_2_allowed BOOLEAN NOT NULL,
    trimester_3_allowed BOOLEAN NOT NULL,
    fallback_drug       TEXT,
    source              TEXT
);

CREATE TABLE trimester_rules (
    rule_id         SERIAL PRIMARY KEY,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    trimester       INTEGER CHECK (trimester IN (1,2,3)),
    weeks_min       INTEGER NOT NULL,            -- 1, 14, 27
    weeks_max       INTEGER,                     -- 13, 26, NULL
    treatment_en    TEXT NOT NULL,
    treatment_rw    TEXT NOT NULL,
    al_allowed      BOOLEAN NOT NULL,
    UNIQUE (protocol_id, trimester)
);

CREATE TABLE iptp_protocol (
    iptp_id         SERIAL PRIMARY KEY,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    drug            TEXT NOT NULL,               -- 'SP'
    tablets_per_dose INTEGER NOT NULL,           -- 3
    mg_per_dose     TEXT NOT NULL,               -- '1500/75 mg'
    weeks_start     INTEGER NOT NULL,            -- 13
    min_doses       INTEGER NOT NULL,            -- 3
    interval_weeks  INTEGER NOT NULL,            -- 4
    contraindications_en TEXT NOT NULL,
    contraindications_rw TEXT NOT NULL,
    delivery        TEXT NOT NULL                -- 'DOT at every ANC visit'
);

CREATE TABLE vaccines (
    vaccine_id      TEXT PRIMARY KEY,            -- 'RTS,S/AS01', 'R21/Matrix-M'
    name            TEXT NOT NULL,
    target          TEXT NOT NULL,               -- 'P. falciparum'
    age_eligibility_en TEXT NOT NULL,
    age_eligibility_rw TEXT NOT NULL
);

CREATE TABLE vaccine_doses (
    dose_id         SERIAL PRIMARY KEY,
    vaccine_id      TEXT REFERENCES vaccines(vaccine_id),
    dose_number     INTEGER NOT NULL,
    age_months      INTEGER NOT NULL,
    notes_en        TEXT,
    notes_rw        TEXT,
    UNIQUE (vaccine_id, dose_number)
);

-- =============================================================================
-- Detection lists — keyword scans the API uses for routing
-- =============================================================================

CREATE TABLE danger_signs (
    sign_id         SERIAL PRIMARY KEY,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    category        TEXT NOT NULL,               -- 1 of the handbook's 7 categories:
                                                 -- 'consciousness','convulsions','feeding',
                                                 -- 'breathing','shock','bleeding_pallor','vomiting'
    lang            TEXT CHECK (lang IN ('en','rw')),
    keyword         TEXT NOT NULL,
    is_severe       BOOLEAN DEFAULT TRUE,
    UNIQUE (protocol_id, lang, keyword)
);
CREATE INDEX idx_danger_protocol ON danger_signs (protocol_id, lang);

CREATE TABLE drug_aliases (
    alias_id        SERIAL PRIMARY KEY,
    canonical_drug  TEXT NOT NULL,               -- 'AL','quinine','artesunate','SP'
    alias           TEXT NOT NULL UNIQUE,        -- 'Coartem','Lonart','Riamet','artemether-lumefantrine'
    match_form      TEXT CHECK (match_form IN ('exact','substring','word_boundary'))
);

CREATE TABLE treatment_failure_markers (
    marker_id       SERIAL PRIMARY KEY,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    lang            TEXT CHECK (lang IN ('en','rw')),
    keyword         TEXT NOT NULL,
    marker_type     TEXT CHECK (marker_type IN ('time','symptom','test')),
    UNIQUE (protocol_id, lang, keyword)
);

-- =============================================================================
-- Reviewed content — deterministic prose templates + UI presets + glossary
-- =============================================================================

CREATE TABLE reviewed_phrases (
    phrase_id       SERIAL PRIMARY KEY,
    template_key    TEXT NOT NULL,               -- 'severe_referral','assess_dose_prose',
                                                 -- 'preg_t1_prose','itn_distribution',
                                                 -- 'irs_schedule','zero_cases_report', etc.
    lang            TEXT CHECK (lang IN ('en','rw')),
    prose           TEXT NOT NULL,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    reviewed_by     TEXT NOT NULL,               -- 'antoine.bigirimana','rbc_2024_panel'
    reviewed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    active          BOOLEAN DEFAULT TRUE,
    notes           TEXT
);
CREATE UNIQUE INDEX idx_reviewed_active
    ON reviewed_phrases (template_key, lang, protocol_id)
    WHERE active = TRUE;

CREATE TABLE preset_examples (
    preset_id       SERIAL PRIMARY KEY,
    endpoint        TEXT NOT NULL,               -- '/v1/assess', etc.
    label_en        TEXT NOT NULL,
    label_rw        TEXT NOT NULL,
    text_en         TEXT NOT NULL,
    text_rw         TEXT NOT NULL,
    display_order   INTEGER NOT NULL,
    active          BOOLEAN DEFAULT TRUE
);

CREATE TABLE procedure_steps (
    step_id         SERIAL PRIMARY KEY,
    procedure       TEXT NOT NULL,               -- 'rdt_perform','ras_administer',
                                                 -- 'al_counsel','itn_hang','itn_wash'
    step_number     INTEGER NOT NULL,
    text_en         TEXT NOT NULL,
    text_rw         TEXT NOT NULL,
    UNIQUE (procedure, step_number)
);

CREATE TABLE terminology (
    term_id         SERIAL PRIMARY KEY,
    abbreviation    TEXT NOT NULL UNIQUE,        -- 'AL','RDT','IPTp-SP', etc.
    expansion_en    TEXT NOT NULL,
    expansion_rw    TEXT NOT NULL                -- handbook's bilingual definition
);

-- =============================================================================
-- Operational data — encounter audit, drug stock, adverse events
-- =============================================================================

CREATE TABLE encounters (
    encounter_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    audit_id        TEXT NOT NULL UNIQUE,        -- 'MLW-...', the existing ID format
    chw_id          INTEGER REFERENCES chw_directory(chw_id),
    centre_id       INTEGER REFERENCES health_centres(centre_id),
    endpoint        TEXT NOT NULL,
    lang            TEXT CHECK (lang IN ('en','rw')),
    request_body    TEXT NOT NULL,               -- post-PHI-scrub
    response_body   JSONB NOT NULL,
    source_kind     TEXT NOT NULL,               -- 'deterministic:rbc-2024-...' or 'llm:claude-haiku-4-5'
    latency_ms      INTEGER,
    severe_gate     BOOLEAN DEFAULT FALSE,
    treatment_failure BOOLEAN DEFAULT FALSE,
    weight_kg       NUMERIC(5,2),
    weeks_gestation INTEGER,
    protocol_id     TEXT REFERENCES protocol_versions(protocol_id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_enc_created    ON encounters (created_at DESC);
CREATE INDEX idx_enc_chw_date   ON encounters (chw_id, created_at DESC);
CREATE INDEX idx_enc_severe     ON encounters (created_at DESC) WHERE severe_gate = TRUE;
CREATE INDEX idx_enc_failure    ON encounters (created_at DESC) WHERE treatment_failure = TRUE;

CREATE TABLE drug_stock_snapshots (
    snapshot_id     SERIAL PRIMARY KEY,
    centre_id       INTEGER REFERENCES health_centres(centre_id),
    drug            TEXT NOT NULL,               -- 'AL_5_14','AL_15_24','RAS_100','RDT'
    units_on_hand   INTEGER NOT NULL,
    expires_at      DATE,
    reported_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_stock_recent ON drug_stock_snapshots (centre_id, drug, reported_at DESC);

CREATE TABLE adverse_events (
    event_id        SERIAL PRIMARY KEY,
    encounter_id    UUID REFERENCES encounters(encounter_id),
    drug            TEXT,
    reaction        TEXT NOT NULL,
    severity        TEXT CHECK (severity IN ('mild','moderate','severe','fatal')),
    reported_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- Surveillance / dashboard rollups — fed by DHIS2 sync or computed views
-- =============================================================================

CREATE TABLE weekly_case_counts (
    district_id     INTEGER REFERENCES districts(district_id),
    iso_year        INTEGER NOT NULL,
    iso_week        INTEGER NOT NULL,
    confirmed_cases INTEGER DEFAULT 0,
    severe_cases    INTEGER DEFAULT 0,
    deaths          INTEGER DEFAULT 0,
    rdt_count       INTEGER DEFAULT 0,
    rdt_positive    INTEGER DEFAULT 0,
    PRIMARY KEY (district_id, iso_year, iso_week)
);

CREATE TABLE epi_facts (
    fact_id         SERIAL PRIMARY KEY,
    fact_year       INTEGER NOT NULL,
    fact_key        TEXT NOT NULL,               -- 'national_case_change_pct'
    fact_value      TEXT NOT NULL,
    source          TEXT,
    UNIQUE (fact_year, fact_key)
);

-- =============================================================================
-- malariaChat — conversation + message history (Phase 1 chatbot UX).
-- See schema/05_chat.sql for the migration that adds these on existing
-- DBs. Schema below is the fresh-install form.
-- =============================================================================

-- One row per CHW session. Auto-closes after 3 hours of inactivity
-- (handled by /v1/chat handler, not the schema).
CREATE TABLE chat_conversations (
    conversation_id  TEXT PRIMARY KEY,                              -- 'MLW-CONV-<random>'
    chw_id           INTEGER REFERENCES chw_directory(chw_id),      -- NULL = anonymous (default today)
    district         TEXT,                                          -- canonical Rwandan district (loose ref, not FK)
    lang             TEXT CHECK (lang IS NULL OR lang IN ('en','rw')),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    last_activity_at TIMESTAMP NOT NULL DEFAULT NOW(),
    closed_at        TIMESTAMP                                      -- NULL = open
);

-- One row per chat turn (user OR assistant). audit_id is per-turn
-- so each turn ties to the existing audit log.
CREATE TABLE chat_messages (
    message_id          SERIAL PRIMARY KEY,
    conversation_id     TEXT NOT NULL REFERENCES chat_conversations(conversation_id),
    role                TEXT NOT NULL CHECK (role IN ('user','assistant','system')),
    text                TEXT,
    intent              TEXT,                                       -- dose/danger/pregnancy/first-line/iptp/vaccines/open
    structured_json     TEXT,                                       -- the /v1/* result JSON when applicable
    structured_endpoint TEXT,
    audit_id            TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_chat_messages_conv
    ON chat_messages(conversation_id, created_at);
