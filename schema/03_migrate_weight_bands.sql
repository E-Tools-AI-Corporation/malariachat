-- 03_migrate_weight_bands.sql
-- Generalises al_weight_bands → antimalarial_weight_bands so the
-- table can hold dose tables for any RBC-2024 first-line drug
-- (AL today, ASPY / DHA-PPQ if/when those bands are seeded).
-- Existing AL rows are tagged drug='AL'. Idempotent — safe to
-- re-run on a database that's already been migrated.

-- Rename the table. ALTER ... IF EXISTS makes this a no-op if the
-- rename has already happened.
ALTER TABLE IF EXISTS al_weight_bands
    RENAME TO antimalarial_weight_bands;

-- Add the drug column. ADD COLUMN IF NOT EXISTS makes this idempotent.
-- Default 'AL' so the existing five rows are correctly tagged.
ALTER TABLE antimalarial_weight_bands
    ADD COLUMN IF NOT EXISTS drug TEXT NOT NULL DEFAULT 'AL';

-- Replace the (protocol_id, min_kg) unique constraint with one that
-- includes drug so that ASPY rows and AL rows can share the same
-- min_kg without collision.
ALTER TABLE antimalarial_weight_bands
    DROP CONSTRAINT IF EXISTS al_weight_bands_protocol_id_min_kg_key;

DO $constraint$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'antimalarial_weight_bands_pid_drug_minkg_key'
          AND conrelid = 'antimalarial_weight_bands'::regclass
    ) THEN
        ALTER TABLE antimalarial_weight_bands
        ADD CONSTRAINT antimalarial_weight_bands_pid_drug_minkg_key
        UNIQUE (protocol_id, drug, min_kg);
    END IF;
END $constraint$;

-- Cosmetic: rename the SERIAL sequence so its name matches the table.
ALTER SEQUENCE IF EXISTS al_weight_bands_band_id_seq
    RENAME TO antimalarial_weight_bands_band_id_seq;
