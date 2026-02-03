# scripts/test_e2e_base_cohort.sh
# End-to-end test for sql/02_base_cohort.sql
# - Ensures required repos/paths exist
# - Ensures output/ exists
# - Runs DuckDB script
# - Validates output file exists, non-empty, expected headers, basic row sanity

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_FILE="${PROJECT_ROOT}/sql/02_base_cohort.sql"
OUTPUT_DIR="${PROJECT_ROOT}/output"
OUTPUT_FILE="${OUTPUT_DIR}/base_cohort.csv"
SOURCE_REPO_DIR="${PROJECT_ROOT}/../analyst-take-home-task"
DATASETS_DIR="${SOURCE_REPO_DIR}/datasets"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

pass() {
  echo "PASS: $*"
}

echo "Running E2E test from: ${PROJECT_ROOT}"

# ---- Preconditions ----
[[ -f "${SQL_FILE}" ]] || fail "Missing SQL file: ${SQL_FILE}"
[[ -d "${SOURCE_REPO_DIR}" ]] || fail "Missing source repo dir: ${SOURCE_REPO_DIR}"
[[ -d "${DATASETS_DIR}" ]] || fail "Missing datasets dir: ${DATASETS_DIR}"

for f in encounters.csv medications.csv patients.csv; do
  [[ -f "${DATASETS_DIR}/${f}" ]] || fail "Missing dataset: ${DATASETS_DIR}/${f}"
done

command -v duckdb >/dev/null 2>&1 || fail "duckdb not found on PATH"

# ---- Ensure output dir ----
mkdir -p "${OUTPUT_DIR}"

# ---- Run script ----
rm -f "${OUTPUT_FILE}"

echo "Executing DuckDB script: ${SQL_FILE}"
duckdb :memory: -c ".read ${SQL_FILE}"

# ---- Validate output ----
[[ -f "${OUTPUT_FILE}" ]] || fail "Expected output not created: ${OUTPUT_FILE}"
[[ -s "${OUTPUT_FILE}" ]] || fail "Output file is empty: ${OUTPUT_FILE}"

# Validate header row
expected_header='PATIENT_ID,ENCOUNTER_ID,HOSPITAL_ENCOUNTER_DATE,AGE_AT_VISIT,DEATH_AT_VISIT_IND,COUNT_CURRENT_MEDS,CURRENT_OPIOID_IND,READMISSION_90_DAY_IND,READMISSION_30_DAY_IND,FIRST_READMISSION_DATE'
actual_header="$(head -n 1 "${OUTPUT_FILE}" | tr -d '\r')"

[[ "${actual_header}" == "${expected_header}" ]] || fail $(
  cat <<EOF
Header mismatch.
Expected:
  ${expected_header}
Actual:
  ${actual_header}
EOF
)

# Basic sanity: at least 1 data row
row_count="$(($(wc -l < "${OUTPUT_FILE}") - 1))"
[[ "${row_count}" -ge 1 ]] || fail "Expected at least 1 data row, got ${row_count}"

# Optional quick checks (lightweight, not strict):
# - AGE_AT_VISIT should be numeric and within 18..35 for all rows
# - Indicator columns should be 0/1
python3 - <<'PY' "${OUTPUT_FILE}" || exit 1
import csv, sys

path = sys.argv[1]
with open(path, newline="") as f:
    r = csv.DictReader(f)
    required = [
        "PATIENT_ID","ENCOUNTER_ID","HOSPITAL_ENCOUNTER_DATE","AGE_AT_VISIT",
        "DEATH_AT_VISIT_IND","COUNT_CURRENT_MEDS","CURRENT_OPIOID_IND",
        "READMISSION_90_DAY_IND","READMISSION_30_DAY_IND","FIRST_READMISSION_DATE"
    ]
    for c in required:
        if c not in r.fieldnames:
            print(f"FAIL: Missing column {c}", file=sys.stderr)
            sys.exit(1)

    bad_age = 0
    bad_ind = 0
    n = 0
    for row in r:
        n += 1
        try:
            age = int(float(row["AGE_AT_VISIT"]))
            if not (18 <= age <= 35):
                bad_age += 1
        except Exception:
            bad_age += 1

        for ind_col in ["DEATH_AT_VISIT_IND","CURRENT_OPIOID_IND","READMISSION_90_DAY_IND","READMISSION_30_DAY_IND"]:
            if row[ind_col] not in ("0","1"):
                bad_ind += 1

    if n == 0:
        print("FAIL: No data rows found", file=sys.stderr)
        sys.exit(1)

    if bad_age:
        print(f"FAIL: {bad_age} rows have AGE_AT_VISIT outside 18..35 or non-numeric", file=sys.stderr)
        sys.exit(1)

    if bad_ind:
        print(f"FAIL: {bad_ind} indicator values not in {{0,1}}", file=sys.stderr)
        sys.exit(1)

print("Sanity checks passed.")
PY

pass "Output created with expected schema and basic sanity checks (${row_count} rows)."
echo "Output: ${OUTPUT_FILE}"
