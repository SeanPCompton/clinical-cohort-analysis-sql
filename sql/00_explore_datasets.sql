-- Purpose:
--  1) Register each CSV as a temp view (portable, relative paths)
--  2) Produce a quick dataset summary report (rows, columns)
--  3) Show small row samples (SELECT * LIMIT 10)
--
-- Constraints:
--  - no joins
--  - no transformations beyond loading
--  - relative paths only (assume sibling repo layout)

-- --------------------------------------------------------------------
-- 1) Register datasets as temp views
-- --------------------------------------------------------------------

CREATE OR REPLACE TEMP VIEW allergies AS
SELECT *
FROM read_csv_auto(
    '../analyst-take-home-task/datasets/allergies.csv'
    , SAMPLE_SIZE = -1
);

CREATE OR REPLACE TEMP VIEW encounters AS
SELECT *
FROM read_csv_auto(
    '../analyst-take-home-task/datasets/encounters.csv'
    , SAMPLE_SIZE = -1
);

CREATE OR REPLACE TEMP VIEW medications AS
SELECT *
FROM read_csv_auto(
    '../analyst-take-home-task/datasets/medications.csv'
    , SAMPLE_SIZE = -1
);

CREATE OR REPLACE TEMP VIEW patients AS
SELECT *
FROM read_csv_auto(
    '../analyst-take-home-task/datasets/patients.csv'
    , SAMPLE_SIZE = -1
);

CREATE OR REPLACE TEMP VIEW procedures AS
SELECT *
FROM read_csv_auto(
    '../analyst-take-home-task/datasets/procedures.csv'
    , SAMPLE_SIZE = -1
);

-- --------------------------------------------------------------------
-- 2) Summary report: row_count + column_count per dataset
-- --------------------------------------------------------------------

SELECT
    'datasets/allergies.csv'                                    AS dataset
    , (SELECT COUNT(*) FROM allergies)                          AS row_count
    , (SELECT COUNT(*) FROM pragma_table_info('allergies'))     AS column_count

UNION ALL

SELECT
    'datasets/encounters.csv'                                    AS dataset
    , (SELECT COUNT(*) FROM encounters)                          AS row_count
    , (SELECT COUNT(*) FROM pragma_table_info('encounters'))     AS column_count

UNION ALL

SELECT
    'datasets/medications.csv'                                    AS dataset
    , (SELECT COUNT(*) FROM medications)                          AS row_count
    , (SELECT COUNT(*) FROM pragma_table_info('medications'))     AS column_count

UNION ALL

SELECT
    'datasets/patients.csv'                                    AS dataset
    , (SELECT COUNT(*) FROM patients)                          AS row_count
    , (SELECT COUNT(*) FROM pragma_table_info('patients'))     AS column_count

UNION ALL

SELECT
    'datasets/procedures.csv'                                    AS dataset
    , (SELECT COUNT(*) FROM procedures)                          AS row_count
    , (SELECT COUNT(*) FROM pragma_table_info('procedures'))     AS column_count
;

-- --------------------------------------------------------------------
-- 3) Row samples
-- --------------------------------------------------------------------

SELECT * FROM allergies LIMIT 10;
SELECT * FROM encounters LIMIT 10;
SELECT * FROM medications LIMIT 10;
SELECT * FROM patients LIMIT 10;
SELECT * FROM procedures LIMIT 10;

