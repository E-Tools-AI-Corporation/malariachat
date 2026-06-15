-- 06_chat_settings.sql
-- Extends chat_conversations with per-session settings introduced by
-- the right-column settings panel on the malariaChat UI:
--   user_name — free-text display name the CHW enters (may be NULL)
--   country   — ISO-style short label; 'RW' is the only supported value
--               today. Burundi/DRC/Kenya/Tanzania/Uganda/Zambia are
--               allowed at the column level so the UI can record what
--               the CHW selected, but the handler refuses chat turns
--               whose effective country is anything other than 'RW'
--               with a "not supported yet" banner. Default 'RW'.
--
-- Idempotent — safe to re-run.

ALTER TABLE chat_conversations
    ADD COLUMN IF NOT EXISTS user_name TEXT;

ALTER TABLE chat_conversations
    ADD COLUMN IF NOT EXISTS country TEXT NOT NULL DEFAULT 'RW';

-- Loose check: keep the column open enough for future expansion
-- (Zambia/Uganda/Kenya/Tanzania are planned next) but pin the
-- vocabulary so a typo can't slip through silently.
DO $do$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE table_name = 'chat_conversations'
          AND constraint_name = 'chat_conversations_country_check'
    ) THEN
        ALTER TABLE chat_conversations
            ADD CONSTRAINT chat_conversations_country_check
            CHECK (country IN ('RW','BI','CD','KE','TZ','UG','ZM'));
    END IF;
END
$do$;
