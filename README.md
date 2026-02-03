# Drug Overdose Cohort Data Exercise (SQL / DuckDB)

## Project Overview

This project implements an end-to-end cohort construction pipeline using healthcare encounter data, with a focus on producing a clean, analysis-ready dataset suitable for downstream reporting or modeling.

The workflow identifies hospital encounters associated with drug overdose, applies clinically relevant eligibility criteria, and derives encounter-level indicators related to medication exposure, in-hospital mortality, and short-term readmissions. The result is a single, well-defined cohort table exported as a flat CSV for reuse across analytical tools.

The solution is implemented entirely in **SQL using DuckDB**, operating directly on raw CSV inputs without requiring an external database or ETL framework. The project emphasizes transparent logic, reproducibility, and portability.



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

This repository intentionally does **not** include the raw datasets.

It assumes the original assignment repository is cloned locally and placed as a **sibling directory** to this repository so that all SQL/scripts can reference source files using **relative paths** (portable; no `~/...` absolute paths).

Example layout:
```text
parent_directory/
├── chop-analytics-exercise/        # this repository
│   ├── sql/
│   ├── output/
│   └── README.md
└── analyst-take-home-task/         # provided assignment repository
    ├── datasets/
    │   └── *.csv
    └── data-dictionary.xlsx
```

---

## Notes

- All logic is written to be rerunnable from the raw CSV inputs.
- No raw data files are modified.
- SQL scripts are organized to reflect the logical progression of the analysis.
- Absolute paths (e.g. ~/...) are avoided so the project runs on any machine when both repos are cloned side-by-side.



---

# Initialization & Running the Project

Follow these steps to initialize the environment and run the exploratory SQL.

### 1. Clone both repositories into the same parent directory

```bash
git clone <YOUR_REPO_URL>
git clone https://github.com/chop-analytics/analyst-take-home-task
Both repositories must be siblings in the same parent directory for relative paths to resolve correctly.
```

### 2. Install Homebrew & DuckDB (macOS)
If Homebrew is not installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```bash
brew install duckdb
```
Verify:

```bash
duckdb --version
```
### 3. DuckDB installation (other platforms)

If Homebrew is not available, DuckDB can be installed via:

- Linux: package managers or prebuilt binaries  
- Windows: DuckDB CLI binary or via WSL  

See the official DuckDB installation guide:
https://duckdb.org/docs/installation/


### 4. Run exploratory SQL
From the root of this repository:

```bash
duckdb
```

Then inside the DuckDB prompt:

```text
.read sql/00_explore_datasets.sql
```
This script loads the raw CSV files from the assignment repository and performs initial dataset inspection.
