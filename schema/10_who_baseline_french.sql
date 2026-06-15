-- 10_who_baseline_french.sql
-- Adds French (`lang='fr'`) to the danger_signs CHECK constraint
-- and seeds a starter set of French severe-malaria keywords against
-- the WHO-2024 protocol. Enables Burundi and DRC (BI / CD) teaching-
-- mode French support added in the same commit.
--
-- Idempotent.

-- 1. Extend danger_signs.lang CHECK to accept 'fr' (alongside en/rw/sw).
DO $do$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.check_constraints
        WHERE constraint_name = 'danger_signs_lang_check'
    ) THEN
        ALTER TABLE danger_signs DROP CONSTRAINT danger_signs_lang_check;
    END IF;
    ALTER TABLE danger_signs
        ADD CONSTRAINT danger_signs_lang_check
        CHECK (lang IN ('en', 'rw', 'sw', 'fr'));
END
$do$;

-- 2. French severe-malaria keyword starter set (Phase A UNREVIEWED).
-- Drawn from common medical French and the WHO francophone severe-
-- malaria criteria. Native-clinician review pending (Phase B).
INSERT INTO danger_signs (protocol_id, category, lang, keyword, is_severe) VALUES
  ('WHO-2024', 'convulsions',   'fr', 'convulsion',            true),
  ('WHO-2024', 'convulsions',   'fr', 'convulsions',           true),
  ('WHO-2024', 'convulsions',   'fr', 'crise',                 true),
  ('WHO-2024', 'consciousness', 'fr', 'inconscient',           true),
  ('WHO-2024', 'consciousness', 'fr', 'perte de conscience',   true),
  ('WHO-2024', 'consciousness', 'fr', 'somnolent',             true),
  ('WHO-2024', 'consciousness', 'fr', 'léthargique',           true),
  ('WHO-2024', 'feeding',       'fr', 'ne peut pas boire',     true),
  ('WHO-2024', 'feeding',       'fr', 'ne peut pas téter',     true),
  ('WHO-2024', 'feeding',       'fr', 'refuse de boire',       true),
  ('WHO-2024', 'feeding',       'fr', 'refuse de manger',      true),
  ('WHO-2024', 'feeding',       'fr', 'vomissements répétés',  true),
  ('WHO-2024', 'feeding',       'fr', 'vomit tout',            true),
  ('WHO-2024', 'breathing',     'fr', 'difficulté à respirer', true),
  ('WHO-2024', 'breathing',     'fr', 'respiration rapide',    true),
  ('WHO-2024', 'shock',         'fr', 'faiblesse importante',  true),
  ('WHO-2024', 'shock',         'fr', 'très faible',           true),
  ('WHO-2024', 'bleeding_pallor','fr', 'urines foncées',       true),
  ('WHO-2024', 'bleeding_pallor','fr', 'jaunisse',             true),
  ('WHO-2024', 'bleeding_pallor','fr', 'saignement',           true)
ON CONFLICT DO NOTHING;
