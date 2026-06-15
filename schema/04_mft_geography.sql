-- 04_mft_geography.sql
-- Replaces the (incorrect) province-based MFT model with the
-- district-and-group model documented in Rwanda's MFT Q&A
-- (MFT__IBIBAZO_N_IBISUBIZO_KU_NDWARA_YA_MALARIYA.pdf, page 3) and
-- the Integrated Malaria Control Guidelines 2024 (page 13).
--
-- Why the rewrite: the original regional_first_line_drugs table mapped
-- province → drug. That's wrong on two axes:
--   1. The unit of MFT geography is the district, not the province.
--      Rwanda's 30 districts are split into three groups (A, B, C),
--      and the groups cross provincial boundaries.
--   2. Each group's drug rotates yearly. The mapping is operational
--      data, not static handbook data — the handbook deliberately
--      directs CHWs to ask their supervisor for the current cycle.
--   3. CHWs are authorised to dose all three drugs (AL, ASPY, DHAP);
--      the earlier "refer to health centre for non-AL" behaviour was
--      clinically wrong per MFT Q&A page 9.
--
-- Idempotent — safe to re-run.

-- 1. Add mft_group to districts.
ALTER TABLE districts
    ADD COLUMN IF NOT EXISTS mft_group TEXT;

DO $constraint$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'districts_mft_group_check'
          AND conrelid = 'districts'::regclass
    ) THEN
        ALTER TABLE districts
        ADD CONSTRAINT districts_mft_group_check
        CHECK (mft_group IS NULL OR mft_group IN ('A', 'B', 'C'));
    END IF;
END $constraint$;

-- 2. mft_current_drug — single row per group with the current rotation.
-- The user MUST INSERT/UPDATE this with the latest RBC bulletin
-- (rotates yearly). Handlers hard-fail with a clear message when no
-- row exists for the queried group, so a misconfigured system never
-- silently shows a stale drug.
CREATE TABLE IF NOT EXISTS mft_current_drug (
    group_letter   TEXT PRIMARY KEY,
    drug           TEXT NOT NULL,
    effective_from DATE NOT NULL,
    source_note    TEXT,
    CHECK (group_letter IN ('A', 'B', 'C')),
    CHECK (drug IN ('AL', 'ASPY', 'DHAP'))
);

-- 3. antimalarial_pregnancy_safety — drug→trimester eligibility per
-- Integrated Guidelines 2024 §1.B (the "Malaria Treatment Indications"
-- matrix). Handlers consult this to apply the ASPY-T1 contraindication
-- with an AL fallback.
CREATE TABLE IF NOT EXISTS antimalarial_pregnancy_safety (
    drug                TEXT PRIMARY KEY,
    trimester_1_allowed BOOLEAN NOT NULL,
    trimester_2_allowed BOOLEAN NOT NULL,
    trimester_3_allowed BOOLEAN NOT NULL,
    fallback_drug       TEXT,                       -- when contraindicated
    source              TEXT                        -- citation
);

-- 4. Drop the old province-based table. We deliberately CASCADE since
-- no downstream tables referenced it.
DROP TABLE IF EXISTS regional_first_line_drugs CASCADE;
