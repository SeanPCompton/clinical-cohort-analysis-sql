-- allergies
WITH src AS (
	SELECT *
	FROM read_csv_auto('../analyst-take-home-task/datasets/allergies.csv', SAMPLE_SIZE = -1)
)
SELECT
	'allergies' AS dataset
	, COUNT(*) AS row_count
	, COUNT(
		DISTINCT concat_ws(
			'|'
			, "PATIENT"
			, "ENCOUNTER"
			, CAST("CODE" AS VARCHAR)
			, CAST("START" AS VARCHAR)
		)
	) AS distinct_pk_candidate
	, MIN("START") AS min_date
	, MAX("START") AS max_date
	, COUNT(*) - COUNT("START") AS null_start_count
FROM src;

-- encounters
WITH src AS (
	SELECT *
	FROM read_csv_auto('../analyst-take-home-task/datasets/encounters.csv', SAMPLE_SIZE = -1)
)
SELECT
	'encounters' AS dataset
	, COUNT(*) AS row_count
	, COUNT(DISTINCT Id) AS distinct_pk
	, MIN("START") AS min_date
	, MAX("START") AS max_date
	, COUNT(*) - COUNT("START") AS null_date_count
FROM src;

-- medications
WITH src AS (
	SELECT *
	FROM read_csv_auto('../analyst-take-home-task/datasets/medications.csv', SAMPLE_SIZE = -1)
)
SELECT
	'medications' AS dataset
	, COUNT(*) AS row_count
	, COUNT(
		DISTINCT concat_ws(
			'|'
			, "PATIENT"
			, "ENCOUNTER"
			, CAST("CODE" AS VARCHAR)
			, CAST("START" AS VARCHAR)
		)
	) AS distinct_pk_candidate
	, MIN("START") AS min_date
	, MAX("START") AS max_date
	, COUNT(*) - COUNT("START") AS null_date_count
FROM src;

-- patients
WITH src AS (
	SELECT *
	FROM read_csv_auto('../analyst-take-home-task/datasets/patients.csv', SAMPLE_SIZE = -1)
)
SELECT
	'patients' AS dataset
	, COUNT(*) AS row_count
	, COUNT(DISTINCT Id) AS distinct_pk
	, MIN("BIRTHDATE") AS min_date
	, MAX("BIRTHDATE") AS max_date
	, COUNT(*) - COUNT("BIRTHDATE") AS null_date_count
FROM src;

-- procedures
WITH src AS (
	SELECT *
	FROM read_csv_auto('../analyst-take-home-task/datasets/procedures.csv', SAMPLE_SIZE = -1)
)
SELECT
	'procedures' AS dataset
	, COUNT(*) AS row_count
	, COUNT(
		DISTINCT concat_ws(
			'|'
			, "PATIENT.x"
			, "ENCOUNTER"
			, "CODE.x"
			, CAST("DATE" AS VARCHAR)
		)
	) AS distinct_pk_candidate
	, MIN("DATE") AS min_date
	, MAX("DATE") AS max_date
	, COUNT(*) - COUNT("DATE") AS null_date_count
FROM src;