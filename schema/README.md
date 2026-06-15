# MalariaChat PostgreSQL schema

This directory holds the schema and seed data that back the clinical
content served by `malariachat.abe`.

## Files

- `01_schema.sql` — DDL for all tables. Idempotent (drops on re-run).
- `02_seed_from_handbook.sql` — populates authoritative content extracted from
  the RBC-aligned bilingual CHW handbook (Rwanda).

## Quick start (when you're ready)

```bash
createdb malariachat
psql malariachat -f 01_schema.sql
psql malariachat -f 02_seed_from_handbook.sql
```

## What lives where

| Concern | Table |
|---|---|
| Per-drug weight-band dose lookup (AL + ASPY + DHAP) | `antimalarial_weight_bands` |
| Pre-referral RAS dose | `ras_doses` |
| MFT rotation — group → current first-line drug (rotates yearly) | `mft_current_drug` |
| Pregnancy-safety matrix per drug (ASPY-T1 contraindication, etc.) | `antimalarial_pregnancy_safety` |
| Pregnancy trimester rules | `trimester_rules` |
| IPTp-SP protocol | `iptp_protocol` |
| Malaria vaccines (RTS,S, R21) | `vaccines`, `vaccine_doses` |
| 7 official danger sign categories + keywords | `danger_signs` |
| Drug aliases (Coartem ↔ AL, etc.) | `drug_aliases` |
| Treatment-failure detection markers | `treatment_failure_markers` |
| Reviewed bilingual prose (every template currently in `.abe`) | `reviewed_phrases` |
| UI preset payloads | `preset_examples` |
| RDT / RAS / AL counselling / home prevention step lists | `procedure_steps` |
| Glossary (every abbreviation in the handbook) | `terminology` |
| Districts (30, with MFT group A/B/C) + health centres + CHW directory | `districts`, `health_centres`, `chw_directory` |
| Encounter audit log | `encounters` |
| Drug stock + adverse events | `drug_stock_snapshots`, `adverse_events` |
| Weekly DHIS2 rollups + epi facts | `weekly_case_counts`, `epi_facts` |

## Migration path

`malariachat.abe` carries a fair amount of hardcoded clinical content.
Once the Abe runtime gets richer PostgreSQL externs (`pg_connect`,
`pg_query(conn, sql, params)`, `pg_row_get(result, row, col)`,
`pg_close`), each handler shrinks to roughly:

```
function assessHandler(req, res):
    weight = parseWeightKg(body)
    rule   = pg_query("SELECT tablets, schedule_rw FROM antimalarial_weight_bands "
                    + "WHERE drug = 'AL' "
                    + "WHERE :weight BETWEEN min_kg AND max_kg "
                    + "AND protocol_id = 'RBC-2024'")
    prose  = pg_query("SELECT prose FROM reviewed_phrases "
                    + "WHERE template_key = 'assess_dose_prose' AND lang = :lang "
                    + "AND active")
    response = format(prose, weight, rule)
    pg_query("INSERT INTO encounters ...")
    return jsonResponse(response)
```

— and the hardcoded prose templates / weight-band lookups disappear from code.

## Authoritative sources currently seeded

- The RBC-aligned bilingual CHW handbook (Rwanda)
- WHO Malaria Guidelines (handbook citation)
- Rwanda MFT strategy (RBC/MOPDD)
- Rwanda Malaria Strategic Plan 2020-2024
- iCCM protocols for community health workers in Rwanda
- The deterministic Kinyarwanda templates maintained in
  `malariachat.abe`

## Known TODOs in the seed

- The 4 prevention RW templates and 3 report RW templates currently appear as
  short headers in `02_seed_from_handbook.sql` with notes pointing back to the
  full text in `malariachat.abe`. When migrating the API to read from
  `reviewed_phrases`, copy the full template bodies into those rows.
- `chw_directory` is empty — populate per actual deployment.
- `preset_examples` is empty — UI presets currently live in the JS file; copy
  the bilingual `{en, rw}` pairs over when migrating.
- `weekly_case_counts` is empty — fed by DHIS2 sync (out of scope for now).
