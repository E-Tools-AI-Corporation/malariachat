-- 09_who_baseline.sql
-- Phase A of the malariaChat Tanzania/Kenya extension (teaching tool).
-- Adds a `WHO-2024` protocol so non-Rwanda countries can route to a
-- non-Rwanda-specific protocol_id. Clinical content currently mirrors
-- RBC-2024 (RBC is downstream of WHO); the separation exists so:
--   (a) citations to TZ/KE users read "WHO 2024", not "RBC 2024"
--   (b) Phase B can introduce NMCP-2024 (Tanzania) and DNMP-2024
--       (Kenya) overlays without touching either RBC or WHO rows
--   (c) MFT and other RW-specific concepts stay scoped to RBC
--
-- Also extends danger_signs.lang to accept 'sw' and seeds a starter
-- set of Swahili severe-malaria keywords (Phase A unreviewed draft).
--
-- Idempotent — all INSERTs use ON CONFLICT DO NOTHING; ALTER guarded.

-- 1. The protocol row itself (FK target for all the SELECTs below).
INSERT INTO protocol_versions (protocol_id, title, effective_from, source_citation)
VALUES (
    'WHO-2024',
    'WHO Global Malaria Programme — Guidelines for malaria (2024) — teaching baseline',
    '2024-01-01',
    'WHO Guidelines for malaria (2024 edition) / Global Malaria Programme'
) ON CONFLICT (protocol_id) DO NOTHING;

-- 2. IPTp-SP — WHO is the source RBC mirrors, so values are identical.
INSERT INTO iptp_protocol
  (protocol_id, drug, tablets_per_dose, mg_per_dose, weeks_start, min_doses,
   interval_weeks, contraindications_en, contraindications_rw, delivery)
SELECT 'WHO-2024', drug, tablets_per_dose, mg_per_dose, weeks_start, min_doses,
       interval_weeks, contraindications_en, contraindications_rw, delivery
FROM iptp_protocol
WHERE protocol_id = 'RBC-2024'
ON CONFLICT DO NOTHING;

-- 3. AL weight bands — universal WHO-standard ACT bands.
INSERT INTO antimalarial_weight_bands
  (protocol_id, min_kg, max_kg, age_label_en, age_label_rw,
   tablets_per_dose, total_tablets, schedule_en, schedule_rw,
   contraindicated, drug)
SELECT 'WHO-2024', min_kg, max_kg, age_label_en, age_label_rw,
       tablets_per_dose, total_tablets, schedule_en, schedule_rw,
       contraindicated, drug
FROM antimalarial_weight_bands
WHERE protocol_id = 'RBC-2024' AND drug = 'AL'
ON CONFLICT DO NOTHING;

-- 4. Trimester rules — AL all trimesters per WHO 2024.
INSERT INTO trimester_rules
  (protocol_id, trimester, weeks_min, weeks_max,
   treatment_en, treatment_rw, al_allowed)
SELECT 'WHO-2024', trimester, weeks_min, weeks_max,
       treatment_en, treatment_rw, al_allowed
FROM trimester_rules
WHERE protocol_id = 'RBC-2024'
ON CONFLICT DO NOTHING;

-- 5. Danger signs (en + rw). WHO criteria mirror RBC's severe-malaria
-- definition, so direct copy is correct for now.
INSERT INTO danger_signs (protocol_id, category, lang, keyword, is_severe)
SELECT 'WHO-2024', category, lang, keyword, is_severe
FROM danger_signs
WHERE protocol_id = 'RBC-2024'
ON CONFLICT DO NOTHING;

-- 6. Treatment-failure markers (post-AL day-3 indicators).
INSERT INTO treatment_failure_markers (protocol_id, lang, keyword, marker_type)
SELECT 'WHO-2024', lang, keyword, marker_type
FROM treatment_failure_markers
WHERE protocol_id = 'RBC-2024'
ON CONFLICT DO NOTHING;

-- 7. Rectal-artesunate pre-referral doses.
INSERT INTO ras_doses
  (protocol_id, age_min_months, age_max_months, weight_min_kg, weight_max_kg,
   capsules, total_mg, instructions_en, instructions_rw)
SELECT 'WHO-2024', age_min_months, age_max_months, weight_min_kg, weight_max_kg,
       capsules, total_mg, instructions_en, instructions_rw
FROM ras_doses
WHERE protocol_id = 'RBC-2024'
ON CONFLICT DO NOTHING;

-- 8. Extend danger_signs.lang CHECK to accept 'sw' (Swahili).
-- Phase A enables Swahili-typing TZ/KE students to trigger the severe
-- gate on their own language. Starter set below is my unreviewed draft;
-- flag for native review before clinical deployment.
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
        CHECK (lang IN ('en', 'rw', 'sw'));
END
$do$;

-- 9. Swahili severe-malaria keywords — Phase A starter set (UNREVIEWED).
-- TODO: native Swahili clinician review before Phase B / pilot deployment.
INSERT INTO danger_signs (protocol_id, category, lang, keyword, is_severe) VALUES
  ('WHO-2024', 'convulsions',   'sw', 'degedege',            true),
  ('WHO-2024', 'convulsions',   'sw', 'kifafa',              true),
  ('WHO-2024', 'consciousness', 'sw', 'kupoteza fahamu',     true),
  ('WHO-2024', 'consciousness', 'sw', 'fahamu',              true),
  ('WHO-2024', 'consciousness', 'sw', 'hana fahamu',         true),
  ('WHO-2024', 'feeding',       'sw', 'hawezi kunywa',       true),
  ('WHO-2024', 'feeding',       'sw', 'hawezi kunyonya',     true),
  ('WHO-2024', 'feeding',       'sw', 'kushindwa kunywa',    true),
  ('WHO-2024', 'feeding',       'sw', 'kushindwa kunyonya',  true),
  ('WHO-2024', 'breathing',     'sw', 'kupumua kwa shida',   true),
  ('WHO-2024', 'breathing',     'sw', 'kushindwa kupumua',   true),
  ('WHO-2024', 'shock',         'sw', 'udhaifu mkubwa',      true),
  ('WHO-2024', 'shock',         'sw', 'mwili dhaifu sana',   true),
  ('WHO-2024', 'bleeding_pallor','sw','damu kutoka',         true),
  ('WHO-2024', 'bleeding_pallor','sw','mkojo mweusi',        true),
  ('WHO-2024', 'bleeding_pallor','sw','ngozi ya manjano',    true),
  ('WHO-2024', 'feeding',       'sw', 'kutapika sana',       true),
  ('WHO-2024', 'feeding',       'sw', 'kutapika kila kitu',  true)
ON CONFLICT DO NOTHING;
