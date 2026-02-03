-- -- ============================================================
-- -- Clinical Cohort Analysis — Single-Script Solution
-- --
-- -- Engine:
-- --   DuckDB
-- --
-- -- One-time project setup (from the parent directory):
-- --
-- --   # Clone the provided source data repository
-- --   git clone https://github.com/chop-analytics/analyst-take-home-task
-- --
-- --   # Create the analysis project
-- --   mkdir clinical-cohort-analysis-sql
-- --   cd clinical-cohort-analysis-sql
-- --
-- --   # Project structure
-- --   mkdir sql
-- --   mkdir output
-- --
-- --   # Place this file in:
-- --   #   clinical-cohort-analysis-sql/sql/02_base_cohort.sql
-- --
-- -- Execution:
-- --   Run DuckDB from the project root:
-- --
-- --     duckdb
-- --     .read sql/02_base_cohort.sql
-- --
-- -- Data ingestion:
-- --   Source data is read directly from CSV files via read_csv().
-- --   No external database or ETL step is required.
-- --
-- -- Output:
-- --   Results are exported via COPY (...) TO 'output/...'.
-- --   The output/ directory must exist prior to execution.
-- -- ============================================================


CREATE OR REPLACE TEMP VIEW encounters AS
SELECT
    "PATIENT" AS patient
    ,"Id" AS id
    ,CAST(TRY_CAST(NULLIF("START", 'NA') AS TIMESTAMP) AS DATE) AS start
    ,CAST(TRY_CAST(NULLIF("STOP",  'NA') AS TIMESTAMP) AS DATE) AS stop
    ,"REASONDESCRIPTION" AS reasondescription
FROM read_csv(
    '../analyst-take-home-task/datasets/encounters.csv'
    ,ALL_VARCHAR = true
);

CREATE OR REPLACE TEMP VIEW medications AS
WITH medications_src AS (
    SELECT *
    FROM read_csv_auto(
        '../analyst-take-home-task/datasets/medications.csv'
        ,SAMPLE_SIZE = -1
        ,NULLSTR = 'NA'
        ,types = {
            'CODE':'VARCHAR'
        }
    )
)
, medications_deduped AS (
    SELECT DISTINCT
        "PATIENT" AS patient
        ,"ENCOUNTER" AS encounter
        ,"CODE" AS code
        ,"DESCRIPTION" AS description
        ,TRY_CAST("START" AS DATE) AS start
        ,TRY_CAST("STOP"  AS DATE) AS stop
    FROM medications_src
)
SELECT
    patient
    ,encounter
    ,code
    ,description
    ,start
    ,stop
FROM medications_deduped;


CREATE OR REPLACE TEMP VIEW patients AS
SELECT
    id
    ,CAST(birthdate AS DATE) AS birthdate
    ,CAST(deathdate AS DATE) AS deathdate
    -- other columns as-is
FROM read_csv_auto(
    '../analyst-take-home-task/datasets/patients.csv'
    ,SAMPLE_SIZE = -1
    ,NULLSTR = 'NA'
);


CREATE OR REPLACE TEMP VIEW base_cohort AS

WITH qualifying_encounters AS (
    SELECT
        encounters.patient AS patient_id
        ,encounters.id AS encounter_id
        ,encounters.start AS hospital_encounter_date
        ,encounters.stop AS encounter_end_date
    FROM encounters
    WHERE 1 = 1
        AND encounters.reasondescription = 'Drug overdose'
        AND encounters.start > DATE '1999-07-15'
)

,cohort AS (
    SELECT
        qualifying_encounters.patient_id
        ,qualifying_encounters.encounter_id
        ,qualifying_encounters.hospital_encounter_date
        ,qualifying_encounters.encounter_end_date
        ,DATE_DIFF(
            'year'
            , patients.birthdate
            ,qualifying_encounters.hospital_encounter_date
            ) 
            AS age_at_visit
        ,patients.birthdate
        ,patients.deathdate

    FROM qualifying_encounters
    INNER JOIN patients
        ON patients.id = qualifying_encounters.patient_id
    WHERE 1 = 1
        AND DATE_DIFF('year', patients.birthdate, qualifying_encounters.hospital_encounter_date) BETWEEN 18 AND 35
)

,current_meds AS (
    SELECT
        cohort.patient_id
        ,cohort.encounter_id
        ,cohort.hospital_encounter_date
        ,medications.code AS medication_code
        ,medications.description AS medication_description
        ,medications.start AS medication_start_date
        ,medications.stop AS medication_stop_date
    FROM medications
    INNER JOIN cohort
        ON medications.patient = cohort.patient_id
    WHERE 1 = 1
        AND medications.start < cohort.hospital_encounter_date
        AND (
            medications.stop IS NULL
        OR  medications.stop >= cohort.hospital_encounter_date
    )

)

,opioids_list AS (
    SELECT *
    FROM (VALUES
        ('hydromorphone')
        ,('fentanyl')
        ,('oxycodone-acetaminophen')
    ) AS opioids(opioid_token)
)

,current_opioids AS (
    SELECT DISTINCT
        current_meds.patient_id
        ,current_meds.encounter_id
        ,current_meds.medication_code AS opioid_code
        ,current_meds.medication_description
        ,current_meds.medication_start_date
        ,current_meds.medication_stop_date
    FROM current_meds
    INNER JOIN opioids_list
        ON LOWER(current_meds.medication_description)
            LIKE '%' || opioids_list.opioid_token || '%'
)

,readmissions AS (
    SELECT
        first_encounter.patient_id
        ,first_encounter.encounter_id AS first_encounter_id
        ,first_encounter.hospital_encounter_date AS first_encounter_date
        ,MIN(readmit.hospital_encounter_date) AS first_readmission_date
    FROM cohort first_encounter
     INNER JOIN cohort readmit
         ON first_encounter.patient_id = readmit.patient_id
        AND readmit.hospital_encounter_date > first_encounter.encounter_end_date
        AND readmit.hospital_encounter_date
            <= CAST(first_encounter.encounter_end_date + INTERVAL '90 days' AS DATE)
    GROUP BY
        first_encounter.patient_id
        ,first_encounter.encounter_id
        ,first_encounter.hospital_encounter_date
)

SELECT
    cohort.patient_id
    ,cohort.encounter_id
    ,cohort.hospital_encounter_date
    ,cohort.age_at_visit
    
    ,CASE
        WHEN cohort.deathdate IS NULL THEN 0
        WHEN cohort.deathdate BETWEEN cohort.hospital_encounter_date AND cohort.encounter_end_date THEN 1
        ELSE 0
    END AS death_at_visit_ind

    ,COUNT(
            DISTINCT CAST(current_meds.medication_code AS VARCHAR) 
            || '|' || CAST(current_meds.medication_start_date AS VARCHAR)

    ) AS count_current_meds
    
    ,CASE
        WHEN current_opioids.opioid_code IS NOT NULL THEN 1
        ELSE 0
    END AS current_opioid_ind

    ,CASE
        WHEN readmissions.first_readmission_date IS NULL THEN 0
        ELSE 1
    END AS readmission_90_day_ind

    ,CASE
        WHEN readmissions.first_readmission_date IS NULL THEN 0
        WHEN readmissions.first_readmission_date
            <= CAST(cohort.encounter_end_date + INTERVAL '30 days' AS DATE)
        THEN 1
        ELSE 0
    END AS readmission_30_day_ind

    ,CASE
        WHEN readmissions.first_readmission_date IS NULL THEN NULL
        ELSE readmissions.first_readmission_date
    END AS first_readmission_date

FROM
    cohort
LEFT JOIN
    current_meds ON cohort.encounter_id = current_meds.encounter_id
LEFT JOIN
    current_opioids ON cohort.encounter_id = current_opioids.encounter_id
LEFT JOIN
    readmissions
        ON cohort.patient_id = readmissions.patient_id
        AND cohort.encounter_id = readmissions.first_encounter_id

GROUP BY 
    cohort.patient_id
    ,cohort.encounter_id
    ,cohort.hospital_encounter_date
    ,cohort.age_at_visit
    ,cohort.deathdate
    ,cohort.encounter_end_date
    ,current_opioids.opioid_code
    ,readmissions.first_readmission_date
;

-- Write final output to .CSV file:
COPY (
    SELECT
        patient_id                  AS PATIENT_ID
        ,encounter_id               AS ENCOUNTER_ID
        ,hospital_encounter_date    AS HOSPITAL_ENCOUNTER_DATE
        ,age_at_visit               AS AGE_AT_VISIT
        ,death_at_visit_ind         AS DEATH_AT_VISIT_IND
        ,count_current_meds         AS COUNT_CURRENT_MEDS
        ,current_opioid_ind         AS CURRENT_OPIOID_IND
        ,readmission_90_day_ind     AS READMISSION_90_DAY_IND
        ,readmission_30_day_ind     AS READMISSION_30_DAY_IND
        ,COALESCE(
            CAST(first_readmission_date AS VARCHAR)
        ,'N/A'
        )                          AS FIRST_READMISSION_DATE
    FROM base_cohort
) TO 'output/base_cohort.csv'
WITH (
    HEADER
    ,OVERWRITE TRUE
);

