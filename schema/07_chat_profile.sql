-- 07_chat_profile.sql
-- Extends chat_conversations with two more profile fields surfaced
-- by the Settings modal (gear icon at bottom-left of the chats
-- sidebar). The other modal fields — user_name, country, district,
-- lang — are already columns on chat_conversations.
--
-- Required-ness is enforced at the application layer (the UI blocks
-- save when email is blank, and the server defaults email to the
-- empty string when the client omits it). We keep the column
-- nullable so that legacy rows from before this migration ran stay
-- queryable.
--
-- Idempotent — safe to re-run.

ALTER TABLE chat_conversations
    ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE chat_conversations
    ADD COLUMN IF NOT EXISTS phone TEXT;
