-- 05_chat.sql
-- Schema for malariaChat — the chatbot UX that replaces the forms UI.
--
-- Two tables:
--   chat_conversations — one row per CHW session. Carries the district
--       and language for the whole session; auto-closes after 3 hours
--       of inactivity (closed_at set by the /v1/chat handler when a new
--       message arrives more than 3 hours after the last). chw_id is
--       reserved for when chw_directory is populated; today it stays
--       NULL for anonymous-by-default sessions.
--   chat_messages — one row per chat turn (user OR assistant). History
--       is reconstructed by SELECTing all messages for a conversation
--       in created_at order. audit_id is one per turn, tying each turn
--       to the existing audit log entries.
--
-- Idempotent — safe to re-run.

CREATE TABLE IF NOT EXISTS chat_conversations (
    conversation_id  TEXT PRIMARY KEY,                              -- 'MLW-CONV-<random>'
    chw_id           INTEGER REFERENCES chw_directory(chw_id),      -- NULL = anonymous
    district         TEXT,                                          -- canonical Rwandan district (loose ref, not FK)
    lang             TEXT CHECK (lang IS NULL OR lang IN ('en','rw')),
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    last_activity_at TIMESTAMP NOT NULL DEFAULT NOW(),              -- bumped on every turn; used for 3h auto-close
    closed_at        TIMESTAMP                                      -- NULL = open
);

CREATE TABLE IF NOT EXISTS chat_messages (
    message_id          SERIAL PRIMARY KEY,
    conversation_id     TEXT NOT NULL REFERENCES chat_conversations(conversation_id),
    role                TEXT NOT NULL CHECK (role IN ('user','assistant','system')),
    text                TEXT,                                       -- the conversational content
    intent              TEXT,                                       -- on assistant turns: dose/danger/pregnancy/first-line/iptp/vaccines/open
    structured_json     TEXT,                                       -- on assistant turns where a /v1/* endpoint was invoked: the JSON it returned
    structured_endpoint TEXT,                                       -- '/v1/assess' etc., when applicable
    audit_id            TEXT,                                       -- one per turn, tied to the audit log
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_conv
    ON chat_messages(conversation_id, created_at);
