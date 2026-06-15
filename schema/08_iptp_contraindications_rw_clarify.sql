-- 08_iptp_contraindications_rw_clarify.sql
-- Three CHW-clarity corrections to the Kinyarwanda contraindications
-- string for IPTp-SP, from native-speaker review:
--
--   1. "trimester" → "first three months". The clinical loanwords
--      `icyiciro` / `igihembwe` for "trimester" don't reliably land
--      with pregnant women who think in months. Three-months is more
--      accurate and accessible.
--   2. "bafite SIDA" → "barwaye SIDA". `bafite` means "they have/
--      possess" (a virus, a thing); `barwaye` emphasises the disease
--      state. Preferred for clinical framing.
--   3. "ohereza kuri muganga" → "Abo babyeyi ubohereza kwa muganga".
--      "kuri muganga" reads literally as "on/at the doctor" and
--      sounds off; the natural form is "kwa muganga" (directional
--      "to the clinician/clinic"). The "Abo babyeyi" antecedent
--      explicitly names who is being referred — the mothers in the
--      contraindicated cohort.
--
-- These corrections also live in `llm.abe` :: rwStyleGuide() so the
-- LLM applies them automatically to future RW prose.
--
-- Idempotent — only UPDATEs when the old wording is still present.

UPDATE iptp_protocol
SET contraindications_rw =
    'NTITANGWA mu mezi atatu ya mbere y''ubutwite; NTITANGWA ku bagore barwaye SIDA bafata cotrimoxazole — Abo babyeyi ubohereza kwa muganga.'
WHERE protocol_id = 'RBC-2024'
  AND contraindications_rw =
    'NTITANGWA mu cyiciro cya mbere cy''ubutwite. NTITANGWA ku bagore bafite SIDA bafata cotrimoxazole — ohereza kuri muganga.';
