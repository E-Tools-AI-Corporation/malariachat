-- =============================================================================
-- MalariaChat — seed from "Malariya Igitabo cy'Umujyanama" CHW handbook
-- =============================================================================
-- Authoritative bilingual content extracted from the RBC-aligned bilingual
-- CHW handbook (Rwanda).
-- Long Kinyarwanda passages use $$dollar$$ quoting so apostrophes (n', y',
-- cy'...) don't need escaping.
--
-- Run after 01_schema.sql:
--   psql malariachat -f 01_schema.sql
--   psql malariachat -f 02_seed_from_handbook.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Protocol version
-- -----------------------------------------------------------------------------
INSERT INTO protocol_versions (protocol_id, title, effective_from, effective_until, source_citation) VALUES
    ('RBC-2024',
     'RBC / MOPDD Malaria CHW Handbook — Igitabo cy''Umujyanama',
     '2024-01-01', NULL,
     'RBC/MOPDD Malaria CHW Handbook (Igitabo cy''Umujyanama) + WHO Malaria Guidelines + Rwanda MFT strategy + Rwanda Malaria Strategic Plan 2020-2024 + iCCM protocols');

-- -----------------------------------------------------------------------------
-- Annex A1 — AL weight-band table (handbook §4.2 / §A1)
-- -----------------------------------------------------------------------------
INSERT INTO antimalarial_weight_bands
  (protocol_id, drug, min_kg, max_kg, age_label_en, age_label_rw,
   tablets_per_dose, total_tablets, schedule_en, schedule_rw, contraindicated)
VALUES
  ('RBC-2024', 'AL', 0,    5,    'under 4 mo', 'munsi y''amezi 4',
   0, 0,
   'Refer; AL not first-line below 5 kg without prescriber.',
   'Boherezwe kwa muganga; AL ntabwo ariwo muti wa mbere ku bafite ibiro biri munsi ya 5.',
   TRUE),
  ('RBC-2024', 'AL', 5,    15,   'child 4 mo – 3 yr', 'umwana w''amezi 4 – imyaka 3',
   1, 6,
   '1 tablet 6 doses over 60 hours (hour 0, 8, then BD x 2 days), with fat-containing food.',
   'Ikinini 1 — doze 6 mu masaha 60 (kw''isaha ya mbere, kw''isaha ya munani, hanyuma kabiri ku munsi mu minsi 2), gifatanywe n''ibiryo birimo amavuta.',
   FALSE),
  ('RBC-2024', 'AL', 15,   25,   'child 3 – 8 yr',    'umwana w''imyaka 3 – 8',
   2, 12,
   '2 tablets 6 doses over 60 hours (hour 0, 8, then BD x 2 days), with fat-containing food.',
   'Ibinini 2 — doze 6 mu masaha 60 (kw''isaha ya mbere, kw''isaha ya munani, hanyuma kabiri ku munsi mu minsi 2), bifatanywe n''ibiryo birimo amavuta.',
   FALSE),
  ('RBC-2024', 'AL', 25,   35,   'child 9 – 13 yr',   'umwana w''imyaka 9 – 13',
   3, 18,
   '3 tablets 6 doses over 60 hours (hour 0, 8, then BD x 2 days), with fat-containing food.',
   'Ibinini 3 — doze 6 mu masaha 60 (kw''isaha ya mbere, kw''isaha ya munani, hanyuma kabiri ku munsi mu minsi 2), bifatanywe n''ibiryo birimo amavuta.',
   FALSE),
  ('RBC-2024', 'AL', 35,   NULL, 'adult 14+ yr',      'umuntu mukuru w''imyaka 14+',
   4, 24,
   '4 tablets 6 doses over 60 hours (hour 0, 8, then BD x 2 days), with fat-containing food.',
   'Ibinini 4 — doze 6 mu masaha 60 (kw''isaha ya mbere, kw''isaha ya munani, hanyuma kabiri ku munsi mu minsi 2), bifatanywe n''ibiryo birimo amavuta.',
   FALSE);

-- -----------------------------------------------------------------------------
-- Annex A2 — Pre-referral RAS (handbook §6 / §A2)
-- -----------------------------------------------------------------------------
INSERT INTO ras_doses
  (protocol_id, age_min_months, age_max_months, weight_min_kg, weight_max_kg,
   capsules, total_mg, instructions_en, instructions_rw)
VALUES
  ('RBC-2024', 6, 35, 5, 14,
   1, 100,
   'Lateral position, insert capsule, hold buttocks together 10 minutes; refer immediately.',
   'Ryamya umwana ku ruhande, shyira capsule mu nyuma, fumbira amato iminota 10; ohereza umurwayi ako kanya.'),
  ('RBC-2024', 36, 71, 14, 20,
   2, 200,
   'Lateral position, insert both capsules, hold buttocks together 10 minutes; repeat dose if expelled within 30 min; refer immediately.',
   'Ryamya umwana ku ruhande, shyira capsules zombi mu nyuma, fumbira amato iminota 10; ongera utange dose niba isohotse mu masaha 30; ohereza umurwayi ako kanya.');

-- -----------------------------------------------------------------------------
-- ASPY weight-band doses — per Integrated Guidelines 2024 Table 3.
-- Once daily for 3 days. Granules below 20 kg, tablets above.
-- -----------------------------------------------------------------------------
INSERT INTO antimalarial_weight_bands
  (protocol_id, drug, min_kg, max_kg, age_label_en, age_label_rw,
   tablets_per_dose, total_tablets, schedule_en, schedule_rw, contraindicated)
VALUES
  ('RBC-2024', 'ASPY', 0, 5, 'under 5 kg', 'munsi y''ibiro 5',
   0, 0,
   'Refer; ASPY not first-line below 5 kg without prescriber.',
   'Boherezwe kwa muganga; ASPY ntabwo ariwo muti wa mbere ku bafite ibiro biri munsi ya 5.',
   TRUE),
  ('RBC-2024', 'ASPY', 5, 8, 'child 5–<8 kg', 'umwana w''ibiro 5–<8',
   0, 0,
   'Granules sachet: artesunate 20 mg + pyronaridine 60 mg, once daily for 3 days. Reconstitute as oral suspension.',
   'Imiti y''ibinyampeke: artesunate 20 mg + pyronaridine 60 mg, rimwe ku munsi mu minsi 3. Vanga mu mazi yo kunywa.',
   FALSE),
  ('RBC-2024', 'ASPY', 8, 15, 'child 8–<15 kg', 'umwana w''ibiro 8–<15',
   0, 0,
   'Granules sachet: artesunate 40 mg + pyronaridine 120 mg, once daily for 3 days.',
   'Imiti y''ibinyampeke: artesunate 40 mg + pyronaridine 120 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'ASPY', 15, 20, 'child 15–<20 kg', 'umwana w''ibiro 15–<20',
   0, 0,
   'Oral suspension: artesunate 60 mg + pyronaridine 180 mg, once daily for 3 days.',
   'Umuti wo kunywa mu mazi: artesunate 60 mg + pyronaridine 180 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'ASPY', 20, 24, 'child 20–<24 kg', 'umwana w''ibiro 20–<24',
   1, 3,
   '1 tablet (artesunate 60 mg + pyronaridine 180 mg) once daily for 3 days.',
   'Ikinini 1 (artesunate 60 mg + pyronaridine 180 mg) rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'ASPY', 24, 45, 'adult 24–<45 kg', 'umuntu mukuru w''ibiro 24–<45',
   2, 6,
   '2 tablets (artesunate 120 mg + pyronaridine 360 mg) once daily for 3 days.',
   'Ibinini 2 (artesunate 120 mg + pyronaridine 360 mg) rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'ASPY', 45, 65, 'adult 45–<65 kg', 'umuntu mukuru w''ibiro 45–<65',
   3, 9,
   '3 tablets (artesunate 180 mg + pyronaridine 540 mg) once daily for 3 days.',
   'Ibinini 3 (artesunate 180 mg + pyronaridine 540 mg) rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'ASPY', 65, NULL, 'adult ≥65 kg', 'umuntu mukuru w''ibiro 65+',
   4, 12,
   '4 tablets (artesunate 240 mg + pyronaridine 720 mg) once daily for 3 days.',
   'Ibinini 4 (artesunate 240 mg + pyronaridine 720 mg) rimwe ku munsi mu minsi 3.',
   FALSE);

-- -----------------------------------------------------------------------------
-- DHAP weight-band doses — per Integrated Guidelines 2024 Table 4.
-- Once daily for 3 days. Dose given as combined mg (DHA + piperaquine).
-- -----------------------------------------------------------------------------
INSERT INTO antimalarial_weight_bands
  (protocol_id, drug, min_kg, max_kg, age_label_en, age_label_rw,
   tablets_per_dose, total_tablets, schedule_en, schedule_rw, contraindicated)
VALUES
  ('RBC-2024', 'DHAP', 0, 5, 'under 5 kg', 'munsi y''ibiro 5',
   0, 0,
   'Refer; DHAP not first-line below 5 kg without prescriber.',
   'Boherezwe kwa muganga; DHAP ntabwo ariwo muti wa mbere ku bafite ibiro biri munsi ya 5.',
   TRUE),
  ('RBC-2024', 'DHAP', 5, 8, 'child 5–<8 kg', 'umwana w''ibiro 5–<8',
   0, 0,
   'Dihydroartemisinin 20 mg + piperaquine 160 mg, once daily for 3 days.',
   'Dihydroartemisinin 20 mg + piperaquine 160 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'DHAP', 8, 11, 'child 8–<11 kg', 'umwana w''ibiro 8–<11',
   0, 0,
   'Dihydroartemisinin 30 mg + piperaquine 240 mg, once daily for 3 days.',
   'Dihydroartemisinin 30 mg + piperaquine 240 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'DHAP', 11, 17, 'child 11–<17 kg', 'umwana w''ibiro 11–<17',
   0, 0,
   'Dihydroartemisinin 40 mg + piperaquine 320 mg, once daily for 3 days.',
   'Dihydroartemisinin 40 mg + piperaquine 320 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'DHAP', 17, 25, 'child 17–<25 kg', 'umwana w''ibiro 17–<25',
   0, 0,
   'Dihydroartemisinin 60 mg + piperaquine 480 mg, once daily for 3 days.',
   'Dihydroartemisinin 60 mg + piperaquine 480 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'DHAP', 25, 36, 'adult 25–<36 kg', 'umuntu mukuru w''ibiro 25–<36',
   0, 0,
   'Dihydroartemisinin 80 mg + piperaquine 640 mg, once daily for 3 days.',
   'Dihydroartemisinin 80 mg + piperaquine 640 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'DHAP', 36, 60, 'adult 36–<60 kg', 'umuntu mukuru w''ibiro 36–<60',
   0, 0,
   'Dihydroartemisinin 120 mg + piperaquine 960 mg, once daily for 3 days.',
   'Dihydroartemisinin 120 mg + piperaquine 960 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'DHAP', 60, 80, 'adult 60–<80 kg', 'umuntu mukuru w''ibiro 60–<80',
   0, 0,
   'Dihydroartemisinin 160 mg + piperaquine 1280 mg, once daily for 3 days.',
   'Dihydroartemisinin 160 mg + piperaquine 1280 mg, rimwe ku munsi mu minsi 3.',
   FALSE),
  ('RBC-2024', 'DHAP', 80, NULL, 'adult ≥80 kg', 'umuntu mukuru w''ibiro 80+',
   0, 0,
   'Dihydroartemisinin 200 mg + piperaquine 1600 mg, once daily for 3 days.',
   'Dihydroartemisinin 200 mg + piperaquine 1600 mg, rimwe ku munsi mu minsi 3.',
   FALSE);

-- -----------------------------------------------------------------------------
-- Pregnancy safety per drug — Integrated Guidelines 2024 page 13
-- (Malaria Treatment Indications matrix). ASPY contraindicated in T1
-- with AL as the canonical fallback (AL is the most-tested ACT and a
-- valid alternative for ASPY-first-line groups per page 13's matrix).
-- -----------------------------------------------------------------------------
INSERT INTO antimalarial_pregnancy_safety
  (drug, trimester_1_allowed, trimester_2_allowed, trimester_3_allowed,
   fallback_drug, source) VALUES
  ('AL',   TRUE,  TRUE, TRUE, NULL, 'Integrated Guidelines 2024 §1.C'),
  ('DHAP', TRUE,  TRUE, TRUE, NULL, 'Integrated Guidelines 2024 §1.C'),
  ('ASPY', FALSE, TRUE, TRUE, 'AL', 'Integrated Guidelines 2024 §1.C — ASPY contraindicated in 1st trimester');

-- -----------------------------------------------------------------------------
-- MFT current drug rotation — operational data, MUST be confirmed
-- against the latest RBC bulletin. The drug each group uses rotates
-- yearly per the MFT Q&A (page 3). Values below are placeholders ready
-- to be confirmed/updated by the deployment operator — handlers will
-- expose `currentDrugSource: PLACEHOLDER...` so the UI surfaces the
-- caveat to the CHW until the operator confirms.
-- -----------------------------------------------------------------------------
INSERT INTO mft_current_drug (group_letter, drug, effective_from, source_note) VALUES
  ('A', 'AL',   '2024-01-01', 'PLACEHOLDER — confirm against current RBC bulletin'),
  ('B', 'ASPY', '2024-01-01', 'PLACEHOLDER — confirm against current RBC bulletin'),
  ('C', 'DHAP', '2024-01-01', 'PLACEHOLDER — confirm against current RBC bulletin');

-- -----------------------------------------------------------------------------
-- §8 — Trimester rules
-- -----------------------------------------------------------------------------
INSERT INTO trimester_rules
  (protocol_id, trimester, weeks_min, weeks_max, treatment_en, treatment_rw, al_allowed)
VALUES
  ('RBC-2024', 1, 1, 13,
   'AL or DHAP indicated in all trimesters per RBC 2024 §6.1 (5th edition). ASPY contraindicated in 1st trimester. Quinine retained as fallback only when ACT is unavailable or contraindicated.',
   'AL cyangwa DHAP byemewe muri trimestre zose hakurikijwe amabwiriza ya RBC 2024 §6.1. ASPY NTIYEMEWE mu trimestre ya mbere. Quinine ikoreshwa gusa iyo ACT idahari cyangwa itemewe.',
   TRUE),
  ('RBC-2024', 2, 14, 26,
   'AL, DHAP, or ASPY all indicated in 2nd trimester per RBC 2024 §6.1. Use per patient''s MFT group rotation, dosed by weight band. Quinine retained as fallback only when ACT is unavailable or contraindicated.',
   'AL, DHAP, cyangwa ASPY byose byemewe mu trimestre ya kabiri hakurikijwe amabwiriza ya RBC 2024 §6.1. Tanga umuti hakurikijwe ihinduka ry''imiti mw''itsinda ry''umurwayi (MFT), muhe doze hakurikijwe ibiro. Quinine ikoreshwa gusa iyo ACT idahari cyangwa itemewe.',
   TRUE),
  ('RBC-2024', 3, 27, NULL,
   'AL, DHAP, or ASPY all indicated in 3rd trimester per RBC 2024 §6.1. Use per patient''s MFT group rotation, dosed by weight band. Quinine retained as fallback only when ACT is unavailable or contraindicated.',
   'AL, DHAP, cyangwa ASPY byose byemewe mu trimestre ya gatatu hakurikijwe amabwiriza ya RBC 2024 §6.1. Tanga umuti hakurikijwe ihinduka ry''imiti mw''itsinda ry''umurwayi (MFT), muhe doze hakurikijwe ibiro. Quinine ikoreshwa gusa iyo ACT idahari cyangwa itemewe.',
   TRUE);

-- -----------------------------------------------------------------------------
-- §8.2 — IPTp-SP protocol
-- -----------------------------------------------------------------------------
INSERT INTO iptp_protocol
  (protocol_id, drug, tablets_per_dose, mg_per_dose, weeks_start, min_doses,
   interval_weeks, contraindications_en, contraindications_rw, delivery)
VALUES
  ('RBC-2024', 'SP', 3, '1500/75 mg', 13, 3, 4,
   'Do NOT give in 1st trimester. Do NOT give to HIV-positive women on cotrimoxazole — refer to clinician.',
   'NTITANGWA mu mezi atatu ya mbere y''ubutwite; NTITANGWA ku bagore barwaye SIDA bafata cotrimoxazole — Abo babyeyi ubohereza kwa muganga.',
   'DOT (directly observed therapy) at every ANC visit from 13 weeks gestation.');

-- -----------------------------------------------------------------------------
-- §9 — Vaccines (RTS,S and R21)
-- -----------------------------------------------------------------------------
INSERT INTO vaccines (vaccine_id, name, target, age_eligibility_en, age_eligibility_rw) VALUES
  ('RTS,S/AS01',    'RTS,S/AS01 (Mosquirix)', 'P. falciparum',
   'Young children in moderate- to high-transmission districts (per Rwanda eligibility list).',
   'Abana bato mu turere malariya iri henshi (reba urutonde rw''u Rwanda).'),
  ('R21/Matrix-M',  'R21/Matrix-M',           'P. falciparum',
   'Young children in moderate- to high-transmission districts (per Rwanda eligibility list).',
   'Abana bato mu turere malariya iri henshi (reba urutonde rw''u Rwanda).');

INSERT INTO vaccine_doses (vaccine_id, dose_number, age_months, notes_en, notes_rw) VALUES
  ('RTS,S/AS01', 1, 5,  'First dose alongside other childhood vaccines.', 'Dose ya mbere hamwe n''izindi nkingo z''abana.'),
  ('RTS,S/AS01', 2, 6,  'Second dose 1 month after dose 1.',              'Dose ya kabiri ukwezi nyuma ya dose ya mbere.'),
  ('RTS,S/AS01', 3, 7,  'Third dose 1 month after dose 2.',               'Dose ya gatatu ukwezi nyuma ya dose ya kabiri.'),
  ('RTS,S/AS01', 4, 24, 'Booster at 24 months.',                          'Dose y''inyongera ku mezi 24.');

-- -----------------------------------------------------------------------------
-- §5.1 — The seven danger signs (handbook's official categorisation)
-- Each row = one keyword in one language, attached to a category.
-- -----------------------------------------------------------------------------
INSERT INTO danger_signs (protocol_id, category, lang, keyword) VALUES
  -- 1. Consciousness — confused, drowsy, unable to wake
  ('RBC-2024', 'consciousness', 'en', 'unconscious'),
  ('RBC-2024', 'consciousness', 'en', 'cannot wake'),
  ('RBC-2024', 'consciousness', 'en', 'not waking'),
  ('RBC-2024', 'consciousness', 'en', 'drowsy'),
  ('RBC-2024', 'consciousness', 'en', 'lethargic'),
  ('RBC-2024', 'consciousness', 'en', 'altered consciousness'),
  ('RBC-2024', 'consciousness', 'en', 'avpu'),
  ('RBC-2024', 'consciousness', 'rw', 'ntashobora gukanguka'),
  ('RBC-2024', 'consciousness', 'rw', 'ntazirikana'),
  ('RBC-2024', 'consciousness', 'rw', 'ntasinzira'),
  ('RBC-2024', 'consciousness', 'rw', 'ntashobora kuvuga'),

  -- 2. Convulsions — ≥2 in 24 hours
  ('RBC-2024', 'convulsions', 'en', 'convulsion'),
  ('RBC-2024', 'convulsions', 'en', 'seizure'),
  ('RBC-2024', 'convulsions', 'en', 'fitting'),
  ('RBC-2024', 'convulsions', 'rw', 'hungabana'),
  ('RBC-2024', 'convulsions', 'rw', 'imitsi'),

  -- 3. Feeding / fluids — cannot drink, breastfeed, sit, stand
  ('RBC-2024', 'feeding', 'en', 'cannot drink'),
  ('RBC-2024', 'feeding', 'en', 'unable to drink'),
  ('RBC-2024', 'feeding', 'en', 'won''t drink'),
  ('RBC-2024', 'feeding', 'en', 'cannot breastfeed'),
  ('RBC-2024', 'feeding', 'en', 'won''t feed'),
  ('RBC-2024', 'feeding', 'en', 'refusing feeds'),
  ('RBC-2024', 'feeding', 'en', 'refusing to feed'),
  ('RBC-2024', 'feeding', 'en', 'not eating'),
  ('RBC-2024', 'feeding', 'rw', 'ntashobora kunywa'),
  ('RBC-2024', 'feeding', 'rw', 'ntashobora konka'),
  ('RBC-2024', 'feeding', 'rw', 'ntashobora kwicara'),

  -- 4. Breathing — deep, laboured, rapid
  ('RBC-2024', 'breathing', 'en', 'respiratory distress'),
  ('RBC-2024', 'breathing', 'en', 'rapid breathing'),
  ('RBC-2024', 'breathing', 'en', 'difficulty breathing'),
  ('RBC-2024', 'breathing', 'en', 'indrawing'),
  ('RBC-2024', 'breathing', 'en', 'deep breathing'),
  ('RBC-2024', 'breathing', 'en', 'laboured breathing'),
  ('RBC-2024', 'breathing', 'rw', 'ntashobora guhumeka'),
  ('RBC-2024', 'breathing', 'rw', 'ahumeka cyane'),

  -- 5. Shock — cold extremities, weak pulse
  ('RBC-2024', 'shock', 'en', 'shock'),
  ('RBC-2024', 'shock', 'en', 'cold hands'),
  ('RBC-2024', 'shock', 'en', 'cold extremities'),
  ('RBC-2024', 'shock', 'en', 'weak pulse'),
  ('RBC-2024', 'shock', 'en', 'capillary refill'),
  ('RBC-2024', 'shock', 'en', 'sunken eyes'),
  ('RBC-2024', 'shock', 'en', 'skin turgor'),
  ('RBC-2024', 'shock', 'en', 'severe dehydration'),
  ('RBC-2024', 'shock', 'rw', 'amaso ahishe'),

  -- 6. Bleeding / pallor / jaundice
  ('RBC-2024', 'bleeding_pallor', 'en', 'severe anaemia'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'severe anemia'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'pallor'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'pale palm'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'abnormal bleeding'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'nose bleed'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'bleeding gums'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'dark urine'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'coca-cola urine'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'coca cola urine'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'haemoglobinuria'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'hemoglobinuria'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'jaundice'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'yellow eyes'),
  ('RBC-2024', 'bleeding_pallor', 'en', 'yellow skin'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'inkari z''umukara'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'inkari nk''ikawa'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'amaso y''umuhondo'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'kuva amaraso'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'byerurutse'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'intege nke zikabije'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'intege nke bikabije'),
  ('RBC-2024', 'bleeding_pallor', 'rw', 'nta mbaraga'),

  -- 7. Vomiting — persistent, cannot keep meds down
  ('RBC-2024', 'vomiting', 'en', 'vomiting everything'),
  ('RBC-2024', 'vomiting', 'en', 'persistent vomiting'),
  ('RBC-2024', 'vomiting', 'en', 'repeated vomiting'),
  ('RBC-2024', 'vomiting', 'rw', 'kuruka byose'),
  ('RBC-2024', 'vomiting', 'rw', 'kuruka kenshi'),

  -- Hypoglycaemia is a separate severe-malaria complication; categorise here
  -- alongside shock as "metabolic emergency"
  ('RBC-2024', 'shock', 'en', 'hypoglycaemia'),
  ('RBC-2024', 'shock', 'en', 'hypoglycemia'),
  ('RBC-2024', 'shock', 'en', 'blood sugar < 3'),
  ('RBC-2024', 'shock', 'en', 'bs < 3');

-- -----------------------------------------------------------------------------
-- Drug aliases (handbook §A1 + brand names)
-- -----------------------------------------------------------------------------
INSERT INTO drug_aliases (canonical_drug, alias, match_form) VALUES
  ('AL',     'Coartem',                    'substring'),
  ('AL',     'Lonart',                     'substring'),
  ('AL',     'Riamet',                     'substring'),
  ('AL',     'artemether-lumefantrine',    'substring'),
  ('AL',     'artemether/lumefantrine',    'substring'),
  ('AL',     'artemether lumefantrine',    'substring'),
  ('AL',     ' AL ',                       'word_boundary'),
  ('AL',     'AL course',                  'substring'),
  ('AL',     'AL treatment',               'substring'),
  ('AL',     'AL regimen',                 'substring'),
  ('ASPY',   'artesunate-pyronaridine',    'substring'),
  ('DHA-PPQ','dihydroartemisinin-piperaquine', 'substring'),
  ('SP',     'sulfadoxine-pyrimethamine',  'substring'),
  ('SP',     'Fansidar',                   'substring');

-- -----------------------------------------------------------------------------
-- Treatment failure markers (§10.1: day 3 fever, day 28 recurrence)
-- -----------------------------------------------------------------------------
INSERT INTO treatment_failure_markers (protocol_id, lang, keyword, marker_type) VALUES
  ('RBC-2024', 'en', 'day 3',                    'time'),
  ('RBC-2024', 'en', '3 days',                   'time'),
  ('RBC-2024', 'en', 'third day',                'time'),
  ('RBC-2024', 'en', 'day 28',                   'time'),
  ('RBC-2024', 'en', 'still febrile',            'symptom'),
  ('RBC-2024', 'en', 'still fever',              'symptom'),
  ('RBC-2024', 'en', 'still positive',           'test'),
  ('RBC-2024', 'en', 'still rdt+',               'test'),
  ('RBC-2024', 'en', 'treatment failure',        'symptom'),
  ('RBC-2024', 'rw', 'munsi wa 3',               'time'),
  ('RBC-2024', 'rw', 'iminsi 3',                 'time'),
  ('RBC-2024', 'rw', 'akiri n''umuriro',         'symptom'),
  ('RBC-2024', 'rw', 'umuriro ntugabanuka',      'symptom'),
  ('RBC-2024', 'rw', 'ntugabanuka',              'symptom'),
  ('RBC-2024', 'rw', 'ikomeje kuba pozitifu',    'test'),
  ('RBC-2024', 'rw', 'igikomeje kuba pozitifu',  'test'),
  ('RBC-2024', 'rw', 'ntibikoze',                'symptom');

-- -----------------------------------------------------------------------------
-- Annex B — Glossary (full handbook bilingual abbreviation table)
-- -----------------------------------------------------------------------------
INSERT INTO terminology (abbreviation, expansion_en, expansion_rw) VALUES
  ('ACT',           'Artemisinin-based combination therapy',
                    'Umuti uhuza artemisinin n''undi muti uvura malariya'),
  ('AL',            'Artemether-Lumefantrine',
                    'Ibinini bivura malariya yoroshye'),
  ('ANC',           'Antenatal Care',
                    'Igenzura ry''umugore utwite'),
  ('ASPY',          'Artesunate-Pyronaridine',
                    'Umuti wa mbere mu Burengerazuba'),
  ('DHA-PPQ',       'Dihydroartemisinin-Piperaquine',
                    'Umuti wa mbere mu Burasirazuba na hagati'),
  ('DHIS2',         'District Health Information System 2',
                    'Sisitemu yo kwakira amakuru y''ubuzima'),
  ('DOT',           'Directly Observed Therapy',
                    'Gufata umuti umuntu agitegerezwa'),
  ('G6PD',          'Glucose-6-phosphate dehydrogenase',
                    'Iza yikora mu maraso (kubuza primaquine kuri bayifite)'),
  ('HMIS',          'Health Management Information System',
                    'Sisitemu y''amakuru y''ubuzima'),
  ('iCCM',          'Integrated Community Case Management',
                    'Ubuvuzi bw''abana bukorwa n''abajyanama'),
  ('IPTp-SP',       'Intermittent Preventive Treatment in pregnancy with Sulfadoxine-Pyrimethamine',
                    'Umuti SP uhabwa abagore batwite ku ANC'),
  ('IRS',           'Indoor Residual Spraying',
                    'Guhuhura imiti mu rugo'),
  ('ITN',           'Insecticide-Treated Net',
                    'Inzitiramibu y''umuti uhamya'),
  ('LLIN',          'Long-Lasting Insecticidal Net',
                    'Inzitiramibu y''umuti uramba'),
  ('MFT',           'Multiple First-Line Therapy',
                    'Gahunda y''imiti myinshi yo gutangira mu Rwanda'),
  ('MOPDD',         'Malaria and Other Parasitic Diseases Division',
                    'Ishami rya RBC ry''iza ya malariya n''iy''undi mukoko'),
  ('P. falciparum', 'Plasmodium falciparum',
                    'Ubwoko bukomeye bwa malariya'),
  ('RAS',           'Rectal Artesunate Suppository',
                    'Umuti utangwa mu nkokora mbere yo kohereza'),
  ('RBC',           'Rwanda Biomedical Centre',
                    'Ikigo cy''igihugu cya RBC'),
  ('RDT',           'Rapid Diagnostic Test',
                    'Ikizamini kibarure kya malariya'),
  ('SP',            'Sulfadoxine-Pyrimethamine',
                    'Umuti ukoreshwa muri IPTp'),
  ('WHO',           'World Health Organization',
                    'Umuryango w''isi w''ubuzima'),
  ('OMS',           'World Health Organization (FR/RW form)',
                    'Umuryango w''isi w''ubuzima');

-- -----------------------------------------------------------------------------
-- Epi facts (current year)
-- -----------------------------------------------------------------------------
INSERT INTO epi_facts (fact_year, fact_key, fact_value, source) VALUES
  (2024, 'national_case_change_pct', '+45.8', 'CHW handbook §1.3 — 2024 national figures vs 2023');

-- -----------------------------------------------------------------------------
-- Districts — all 30 of Rwanda, with MFT rotation group from the
-- MFT Q&A page 3. altitude_m / transmission fields populated only
-- where we have data from the earlier seed; left NULL otherwise
-- (transmission stratification updates with surveillance, not
-- static-handbook content).
-- -----------------------------------------------------------------------------
INSERT INTO districts (name, province, altitude_m, transmission, mft_group) VALUES
  -- Group A (11 districts: all 3 Kigali + Gicumbi + most of Eastern)
  ('Gasabo',     'Kigali',   NULL, NULL,     'A'),
  ('Kicukiro',   'Kigali',   NULL, NULL,     'A'),
  ('Nyarugenge', 'Kigali',   NULL, NULL,     'A'),
  ('Gicumbi',    'Northern', NULL, NULL,     'A'),
  ('Nyagatare',  'Eastern',  NULL, NULL,     'A'),
  ('Gatsibo',    'Eastern',  NULL, NULL,     'A'),
  ('Rwamagana',  'Eastern',  NULL, NULL,     'A'),
  ('Kayonza',    'Eastern',  1400, 'high',   'A'),
  ('Bugesera',   'Eastern',  1380, 'high',   'A'),
  ('Ngoma',      'Eastern',  1450, 'high',   'A'),
  ('Kirehe',     'Eastern',  1350, 'high',   'A'),
  -- Group B (8 districts: all of Southern)
  ('Muhanga',    'Southern', NULL, NULL,     'B'),
  ('Kamonyi',    'Southern', NULL, NULL,     'B'),
  ('Ruhango',    'Southern', NULL, NULL,     'B'),
  ('Nyanza',     'Southern', NULL, NULL,     'B'),
  ('Nyamagabe',  'Southern', 2100, 'low',    'B'),
  ('Huye',       'Southern', NULL, NULL,     'B'),
  ('Nyaruguru',  'Southern', 2200, 'low',    'B'),
  ('Gisagara',   'Southern', NULL, NULL,     'B'),
  -- Group C (11 districts: all 7 Western + 4 of Northern)
  ('Rusizi',     'Western',  NULL, NULL,     'C'),
  ('Nyamasheke', 'Western',  NULL, NULL,     'C'),
  ('Karongi',    'Western',  NULL, NULL,     'C'),
  ('Rutsiro',    'Western',  NULL, NULL,     'C'),
  ('Ngororero',  'Western',  NULL, NULL,     'C'),
  ('Nyabihu',    'Western',  NULL, NULL,     'C'),
  ('Rubavu',     'Western',  NULL, NULL,     'C'),
  ('Gakenke',    'Northern', 1950, 'medium', 'C'),
  ('Musanze',    'Northern', NULL, NULL,     'C'),
  ('Burera',     'Northern', 2050, 'low',    'C'),
  ('Rulindo',    'Northern', 1800, 'medium', 'C');

-- -----------------------------------------------------------------------------
-- §3.2 — RDT performance procedure (10 steps)
-- -----------------------------------------------------------------------------
INSERT INTO procedure_steps (procedure, step_number, text_en, text_rw) VALUES
  ('rdt_perform', 1,
   'Read the instructions in the kit. Each kit may have small differences.',
   'Soma amabwiriza yari muri kit. Buri kit ifite agahinda gato.'),
  ('rdt_perform', 2,
   'Wash hands, put on gloves.',
   'Karaba intoki, ushyire imikono y''isuku.'),
  ('rdt_perform', 3,
   'Clean the side of the 4th finger with an alcohol swab and let it dry.',
   'Hozaho urutoki (rwa kane) rw''ukuboko k''iburyo n''akabuto k''alcool, urekere kuma.'),
  ('rdt_perform', 4,
   'Lance the side of the fingertip with a sterile lancet.',
   'Komanya urutoki kuruhande na lancet imwe.'),
  ('rdt_perform', 5,
   'Wipe away the first drop of blood with dry gauze. Use the second drop.',
   'Hanagura igitonyanga cya mbere n''akabuto kumye. Igitonyanga cya kabiri ni cyo ukoresha.'),
  ('rdt_perform', 6,
   'Collect a small drop of blood with the device provided in the kit. DO NOT use too much.',
   'Fata igitonyanga gito cy''amaraso ukoresheje icyombo cyari muri kit. NTUKABE NYINSHI.'),
  ('rdt_perform', 7,
   'Place the blood in the sample well.',
   'Shyira amaraso aho byagaragajwe ko ushyira sample (well).'),
  ('rdt_perform', 8,
   'Add the indicated number of drops of buffer (often 4 or 5).',
   'Ongeraho imitonyanga ya buffer nk''uko byagaragajwe (akenshi 4 cyangwa 5).'),
  ('rdt_perform', 9,
   'Wait 15 to 20 minutes. DO NOT read before the time.',
   'Tegereza iminota 15 kugeza ku 20. NTUKASOME mbere y''igihe.'),
  ('rdt_perform', 10,
   'Read the result, record in the register, inform the patient.',
   'Soma ibisubizo, andika muri register, ubwire umurwayi.');

-- -----------------------------------------------------------------------------
-- §6.3 — RAS administration (7 steps)
-- -----------------------------------------------------------------------------
INSERT INTO procedure_steps (procedure, step_number, text_en, text_rw) VALUES
  ('ras_administer', 1,
   'Wash your hands and put on gloves.',
   'Karaba intoki, ushyire imikono y''isuku.'),
  ('ras_administer', 2,
   'Position the child on their side with the upper leg flexed.',
   'Ryamya umwana ku ruhande, ukubita igisate cy''iruhande.'),
  ('ras_administer', 3,
   'Insert the capsule(s) gently into the rectum.',
   'Shyira capsule mu nyuma — neza neza.'),
  ('ras_administer', 4,
   'Hold the buttocks together for 10 minutes to prevent expulsion.',
   'Fumbira amato y''umwana iminota 10 kugira ngo capsule itasohoka.'),
  ('ras_administer', 5,
   'If the capsule is expelled within 30 minutes, give a fresh dose.',
   'Niba capsule yasohoye mu masaha 30, tanga indi.'),
  ('ras_administer', 6,
   'Refer the patient immediately. Do not wait.',
   'Ohereza umurwayi ako kanya. Ntugategereze.'),
  ('ras_administer', 7,
   'Document on the referral note: dose, time given.',
   'Andika ku rupapuro rwo kohereza: dose, igihe cyo gutanga.');

-- -----------------------------------------------------------------------------
-- §4.3 — AL counselling (6 patient-facing points)
-- -----------------------------------------------------------------------------
INSERT INTO procedure_steps (procedure, step_number, text_en, text_rw) VALUES
  ('al_counsel', 1,
   'How many tablets per dose, and the total number of doses.',
   'Umubare w''ibinini buri dose, n''umubare w''amadose yose.'),
  ('al_counsel', 2,
   'When to take each dose: Day 1 (hour 0 and hour 8), Day 2 and Day 3 (morning and evening).',
   'Igihe cyo gufata buri dose: ku munsi wa 1 (saa zero n''isaha 8), ku munsi wa 2 na 3 (mu gitondo n''umugoroba).'),
  ('al_counsel', 3,
   'AL must be taken with fat-containing food — milk, animal fat, peanut paste, or avocado.',
   'AL ifatwa hamwe n''ibiribwa birimo amavuta — amata, amavuta y''inyamaswa, ubunyobwa bw''ubunyobwa, cyangwa ubunyobwa bw''amaperone.'),
  ('al_counsel', 4,
   'If the patient vomits within 30 minutes of a dose, the dose must be repeated.',
   'Niba umurwayi yarutse mu masegonda 30 nyuma yo gufata dose, ngomba kongera kuyifata.'),
  ('al_counsel', 5,
   'All doses must be taken, even if the patient feels better.',
   'Buri dose igomba gufatwa, n''iyo umurwayi yumva yarakize.'),
  ('al_counsel', 6,
   'Return immediately if any danger sign appears.',
   'Garuka ako kanya niba kimwe ku bimenyetso byihutirwa cyabaye.');

-- -----------------------------------------------------------------------------
-- §7.3 — 8-point home prevention checklist
-- -----------------------------------------------------------------------------
INSERT INTO procedure_steps (procedure, step_number, text_en, text_rw) VALUES
  ('home_prevention', 1, 'Use a bed net every night.',
                         'Koresha inzitiramibu buri joro.'),
  ('home_prevention', 2, 'Drain standing water around the house.',
                         'Ohereza amazi yose ahagaze hafi y''urugo.'),
  ('home_prevention', 3, 'Close doors and windows at dusk.',
                         'Funga inzu n''amadirishya nimugoroba.'),
  ('home_prevention', 4, 'Wear long sleeves and trousers in the evening.',
                         'Yambare imyenda mireremire mu maboko n''amaguru nimugoroba.'),
  ('home_prevention', 5, 'Use insect repellent if affordable.',
                         'Koresha imiti yirinda imibu (repellents) mubishoboye.'),
  ('home_prevention', 6, 'If you have fever for 24 hours, come for testing.',
                         'Niba ufite umuriro mu masaha 24, hita uza guhabwa ikizamini.'),
  ('home_prevention', 7, 'If prescribed treatment, take all doses as directed.',
                         'Niba uhawe umuti, ufate uko bigenwe — buri dose.'),
  ('home_prevention', 8, 'Know the danger signs, return immediately if any appear.',
                         'Menye ibimenyetso byihutirwa, garuka ako kanya niba bibaye.');

-- -----------------------------------------------------------------------------
-- Reviewed phrases — the deterministic prose templates the API currently
-- hardcodes as Abe functions. These rows are the source-of-truth bilingual
-- text; the API would query reviewed_phrases instead of compiling templates.
-- -----------------------------------------------------------------------------

-- severeMalariaReferralEn / Rw
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by, notes) VALUES
  ('severe_referral', 'en',
   '[KOHEREZA] DANGER — SEVERE MALARIA SIGNS DETECTED. REFER IMMEDIATELY to the nearest district hospital. If rectal artesunate is available, administer per RBC 2024 weight-band before transfer. Place patient on their side. Do NOT give oral AL at home. Go now.',
   'RBC-2024', 'antoine.bigirimana',
   'Tagged with [KOHEREZA] in EN per protocol convention'),
  ('severe_referral', 'rw',
   $$[BIMENYETSO_BIBI] IBIMENYETSO BIKOMEYE BYA MALARIA BIRAGARAGARA. KOHEREZA umurwayi VUBA ku bitaro by'akarere bya hafi. Niba artesunate yo mu kibuno ihari, yitange ukurikije imbonerahamwe ya RBC 2024 mbere yo kumwohereza ku bitaro. Ryamisha umurwayi ku ruhande. NTUMUHE AL akiri mu rugo. IHUTE.$$,
   'RBC-2024', 'antoine.bigirimana', NULL);

-- assessProseEn / Rw
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by, notes) VALUES
  ('assess_dose_prose', 'en',
   $$For a patient weighing {kg} kg, the RBC 2024 weight-band table assigns the {band} band: give {tablets} tablets of AL twice daily for 3 days, with food. [DOSE_ALERT] Verify the weight and band before each dose. If any danger signs appear (convulsions, unable to drink or breastfeed, persistent vomiting, severe weakness), refer immediately to the nearest health centre regardless of the dose given.$$,
   'RBC-2024', 'antoine.bigirimana', 'Placeholders {kg}, {band}, {tablets} for runtime substitution'),
  ('assess_dose_prose', 'rw',
   $$Umurwayi w'ibiro {kg} kg, dukurikije imbonerahamwe ya RBC 2024, ari mu cyiciro cya {band}: muhe ibinini {tablets} bya AL incuro 2 ku munsi mu minsi 3, hamwe n'ibiryo. [DOSE_ALERT] Suzuma uburemere n'icyiciro mbere ya buri doze. Niba ibimenyetso bibi byagaragaye (guhungabana, kunywa cyangwa konka bigoye, kuruka bidahwema, intege nke bikabije), ohereza umurwayi vuba ku kigo nderabuzima cyangwa ku bitaro bikwegereye, ntiwite kuri doze watanze.$$,
   'RBC-2024', 'antoine.bigirimana', NULL);

-- pregnancyProseEn / Rw — T1 only
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('preg_t1_prose', 'en',
   'At {weeks} weeks gestation the patient is in the FIRST trimester. RBC 2024 mandates: quinine 10mg/kg + clindamycin 5mg/kg, three times daily for 7 days. AL is contraindicated in the first trimester. Confirm gestational age against the antenatal record before starting therapy. Refer if any danger signs appear.',
   'RBC-2024', 'antoine.bigirimana'),
  ('preg_t1_prose', 'rw',
   $$Mu byumweru {weeks} by'inda, umurwayi ari mu mezi atatu ya MBERE y'inda (trimestre ya mbere). RBC 2024 itegeka: quinine 10mg/kg hamwe na clindamycin 5mg/kg, incuro 3 ku munsi mu minsi 7. AL ntiyatangwa mu mezi atatu ya mbere y'inda. Suzuma ibyumweru by'inda mu mateka y'isuzuma ry'umubyeyi mbere yo kumuha imiti. Mwohereze ku bitaro niba ibimenyetso bibi byagaragaye.$$,
   'RBC-2024', 'antoine.bigirimana');

-- pregnancyProseEn / Rw — T2/T3
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('preg_t2_t3_prose', 'en',
   'At {weeks} weeks gestation the patient is in the {ordinal} trimester. RBC 2024: AL is acceptable by weight band, twice daily for 3 days with food. Quinine remains first-line if AL is contraindicated by other factors. Refer if any danger signs appear.',
   'RBC-2024', 'antoine.bigirimana'),
  ('preg_t2_t3_prose', 'rw',
   $$Mu byumweru {weeks} by'inda, umurwayi ari mu mezi atatu ya {ordinalRw} y'inda (trimestre ya {ordinalRw}). RBC 2024: AL ishobora gutangwa ukurikije ibiro by'umubyeyi, incuro 2 ku munsi mu minsi 3 hamwe n'ibiryo. Muhe Quinine niba AL idakwiye kubera ibibazo bitandukanye. Mwohereze ku bitaro niba ibimenyetso bibi byagaragaye.$$,
   'RBC-2024', 'antoine.bigirimana');

-- treatmentFailureProseEn / Rw
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('treatment_failure_prose', 'en',
   'Day-3 treatment failure pattern detected (post-AL fever / persistent positive RDT). RBC 2024: REFER to the district hospital. Do NOT repeat AL — treatment failure requires a second-line regimen (typically quinine or artesunate IV) that only the district hospital can dispense. Document the case in DHIS2 and report to the health-centre in-charge.',
   'RBC-2024', 'antoine.bigirimana'),
  ('treatment_failure_prose', 'rw',
   $$Biragaragara ko imiti itakoze (umuriro ntugabanuka nyuma y'iminsi 3 ya AL cyangwa RDT ikomeje kuba pozitifu). RBC 2024: KOHEREZA umurwayi ku bitaro by'akarere. NTUSUBIRE GUTANGA AL — ibitakoze bisaba undi muti (nka quinine cyangwa artesunate ya intra-veinous) utangwa ku bitaro gusa. Andika ibyabaye muri DHIS2 kandi umenyeshe umuyobozi w'ikigo nderabuzima.$$,
   'RBC-2024', 'antoine.bigirimana');

-- dangerNoSevereProseEn / Rw
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('danger_no_severe_prose', 'en',
   'Based on the information provided, there are no severe malaria danger signs present in this child (fever, but able to drink). Monitoring advice: Monitor for improvement or worsening of symptoms. Continue to assess for any new symptoms and provide supportive care as needed. If the fever persists or worsens, reassess for potential malaria treatment. Next step: Ask the CHW to report back on the child''s condition after 24 hours and provide further guidance based on their response.',
   'RBC-2024', 'antoine.bigirimana'),
  ('danger_no_severe_prose', 'rw',
   $$Dukurikije icyo batubwiye, malaria muri uyu mwana ntikaze cyane (afite umuriro, ariko ashobora kunywa). Ibyo twangenzura: twagenzura niba umuriro uzamuka cyangwa umanuka tugakomeza kumuba hafi. Niba akomeje kugira umuriro cyangwa se umuriro ukomeje kuzamuka, turebe niba byabaye malaria, tumuhe imiti ya malaria. Intambwe ikurikira: Dusabe Nshuti z'Ubuzima kuduha raporo ku ndwara y'uyu mwana mu masaha 24, tubabwire ibyo bakora dukurikije igisubizo cyabo.$$,
   'RBC-2024', 'antoine.bigirimana');

-- alBandTableEn / Rw  (the explain-dose endpoint)
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('al_band_table', 'en',
$$RBC 2024 AL weight-band table:
  5-14 kg  = 1 tablet  BD x 3 days with food
  15-24 kg = 2 tablets BD x 3 days with food
  25-34 kg = 3 tablets BD x 3 days with food
  >=35 kg  = 4 tablets BD x 3 days with food
Under 5 kg: refer; AL is not first-line at this weight.
1st-trimester pregnancy: AL contraindicated — use quinine + clindamycin.
Day-3 treatment failure: refer; do NOT repeat AL.$$,
   'RBC-2024', 'antoine.bigirimana'),
  ('al_band_table', 'rw',
$$Imbonerahamwe ya RBC 2024 y'ingano ya AL hakurikijwe ibiro:

* 5-14 kg = ikinini 1 kabiri ku munsi (BD) mu minsi 3, gifatanywe n'ibiryo
* 15-24 kg = ibinini 2 kabiri ku munsi (BD) mu minsi 3, bifatanywe n'ibiryo
* 25-34 kg = ibinini 3 kabiri ku munsi (BD) mu minsi 3, bifatanywe n'ibiryo
* >=35 kg = ibinini 4 kabiri ku munsi (BD) mu minsi 3, bifatanywe n'ibiryo

Abari munsi ya 5 kg: boherezwe kwa muganga; AL ntabwo ariwo muti wa mbere ku bafite ibi biro.

Abagore batwite mu gihembwe cya mbere: AL ntiyemewe — hakoreshejwe quinine hamwe na clindamycin.

Kunanirwa kuvura ku munsi wa 3: ohereza umurwayi kwa muganga; ntusubiremo AL.$$,
   'RBC-2024', 'antoine.bigirimana');

-- trimesterTableEn / Rw  (the explain-trimester endpoint)
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('trimester_table', 'en',
$$RBC 2024 trimester table for malaria treatment:
  1-13 weeks (1st trimester): quinine 10mg/kg + clindamycin 5mg/kg, TID x 7 days. AL CONTRAINDICATED.
  14-26 weeks (2nd trimester): AL by weight band (see /v1/explain-dose).
  27+ weeks (3rd trimester): AL by weight band.
All trimesters: severe-malaria signs require immediate referral and pre-referral rectal artesunate where available, regardless of trimester.$$,
   'RBC-2024', 'antoine.bigirimana'),
  ('trimester_table', 'rw',
$$Imbonerahamwe ya RBC 2024 mu kuvura malariya abagore batwite ukurikije igihembwe bagezemo:

* Ibyumweru 1-13 (igihembwe cya mbere): quinine 10mg/kg hamwe na clindamycin 5mg/kg, gatatu ku munsi (TID) mu minsi 7. AL NTIYEMEWE.
* Ibyumweru 14-26 (igihembwe cya kabiri): AL hakurikijwe ibiro (reba imbonerahamwe ya doze aha haruguru).
* Ibyumweru 27 kuzamura (igihembwe cya gatatu): AL hakurikijwe ibiro.

Mu bihembwe byose byo gutwita: ibimenyetso bya malariya ikabije bisaba kohereza umurwayi kwa muganga ako kanya no gutanga rectal artesunate mbere yo kumwohereza aho iboneka, hatitawe ku gihembwe cyo gutwita agezemo.$$,
   'RBC-2024', 'antoine.bigirimana');

-- Prevention RW deterministic templates (4 of them — RW only; EN goes to LLM)
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('prevention_itn_distribution', 'rw',
$$# Inama ku Mikoreshereze y'Inzitiramibu (ITN) - Inyoborere Ngufi

## **Abagomba Guhabwa Inzitiramibu**

* **Abagore batwite n'abana bari munsi y'imyaka 5**: Bahabwa umwihariko (ni bo bafite ibyago byinshi)
* **Urugo rwose**: Nibura inzitiramibu imwe ku bantu 2
* Reba urutonde rw'abanditswe; wirinde ko bamwe bahabwa kabiri

(See full template in malariachat.abe::preventionItnProseRw — moved here for the schema bootstrap; the API will read this row instead of the hardcoded function.)$$,
   'RBC-2024', 'antoine.bigirimana'),
  ('prevention_itn_at_home', 'rw',
$$# Kwirinda Malariya Hakoreshejwe Inzitiramibu (ITNs) n'Umutekano w'Abaturage

(See full template in malariachat.abe::preventionItnAtHomeProseRw — full text migrates here.)$$,
   'RBC-2024', 'antoine.bigirimana'),
  ('prevention_community_messaging', 'rw',
$$# Ubutumwa bwo Gushishikariza Abana bari Mu Mashuri Gukoresha Inzitiramibu (ITN)

(See full template in malariachat.abe::preventionCommunityProseRw — full text migrates here.)$$,
   'RBC-2024', 'antoine.bigirimana'),
  ('prevention_irs_schedule', 'rw',
$$# Kwirinda Malariya mu Turere two mu Ntara y'Iburasirazuba Dukunze Kugira ubwandu bwinshi

(See full template in malariachat.abe::preventionIrsProseRw — full text migrates here.)$$,
   'RBC-2024', 'antoine.bigirimana');

-- Report RW deterministic templates (3)
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('report_zero_cases', 'rw',
$$# Gutanga Raporo y'ibarura rya Malariya muri DHIS2 - Ntayihari mu karere ka Burera

(See full template in malariachat.abe::reportZeroCasesProseRw — full text migrates here.)$$,
   'RBC-2024', 'antoine.bigirimana'),
  ('report_active_transmission', 'rw',
$$# Gutanga Raporo ya Malariya muri DHIS2 - Kayonza (Ubwandu Burakomeza Gukwirakwira)

(See full template in malariachat.abe::reportActiveTransmissionProseRw — full text migrates here.)$$,
   'RBC-2024', 'antoine.bigirimana'),
  ('report_form_completion', 'rw',
$$# Ifishi yo Kohereza Umurwayi wa Malariya Ikabije - Raporo ya DHIS2 (Kayonza)

(See full template in malariachat.abe::reportFormCompletionProseRw — full text migrates here.)$$,
   'RBC-2024', 'antoine.bigirimana');

-- Closing message (handbook §closing)
INSERT INTO reviewed_phrases (template_key, lang, prose, protocol_id, reviewed_by) VALUES
  ('handbook_closing', 'en',
   'Malaria kills many African children. Yet it can be diagnosed in 20 minutes, treated in 3 days, and prevented by a bed net and a few preventive doses. The reason malaria still kills is rarely a failure of knowledge — it is stock-outs, late referrals, and missed danger signs. The system that closes those gaps depends on you, the community health worker.',
   'RBC-2024', 'rbc_2024_panel'),
  ('handbook_closing', 'rw',
$$Malariya irica abana b'i Afurika benshi. Ariko izi ndwara zishobora kuvurwa: igipimo cya RDT mu masegonda 20, umuti wo kunywa w'iminsi 3, inzitiramibu, n'amadose ya IPTp-SP — ibi byose bishobora gukumira urupfu.

Impamvu malariya ikomeza kwica akenshi si ukubura ubumenyi — ni inkomyi z'imiti, kohereza vuba, kutamenya ibimenyetso byihutirwa. Sisitemu ikora neza ishingiye kuri wowe, umujyanama w'ubuzima.$$,
   'RBC-2024', 'rbc_2024_panel');
