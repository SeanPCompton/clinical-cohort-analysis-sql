# Drug Overdose Cohort Data Exercise (SQL / DuckDB)

## Project Overview

This repository contains a take-home data exercise focused on cohort construction and metric derivation using healthcare encounter data.

The objective is to identify hospital encounters for drug overdose, apply eligibility criteria to define a study cohort, and calculate a set of encounter-level indicators related to medication exposure, mortality, and readmissions. The final deliverable is a flat, analysis-ready dataset exported as a CSV file.

The project is implemented using **SQL with DuckDB**, operating directly on the provided CSV files.



## Project Approach

The analysis follows a clear, reproducible workflow:

1. **Dataset exploration**  
   Inspect each source dataset individually to understand structure, keys, date fields, and relationships, using the provided data dictionary as reference.

2. **Cohort construction**  
   Define a cohort of eligible drug overdose encounters based on encounter type, encounter date, and patient age at visit. This step establishes the row-level grain of the analysis.

3. **Metric derivation**  
   Calculate encounter-level indicators related to:
   - death timing
   - active medications at encounter start
   - opioid exposure
   - 30- and 90-day overdose readmissions

   All metrics are derived relative to the cohort encounters and reduced back to one row per encounter.

4. **Final export**  
   Combine cohort and derived metrics into a single flat table and export the results to a CSV file for submission.

---

## Repository Structure

- `datasets/` — Raw input CSV files (unchanged)
- `docs/` — Data dictionary files corresponding to each dataset
- `sql/` — SQL scripts organized by analysis stage
- `output/` — Final exported CSV file
- `README.md` — Project overview and execution notes

---

## Notes

- All logic is written to be rerunnable from the raw CSV inputs.
- No raw data files are modified.
- SQL scripts are organized to reflect the logical progression of the analysis.