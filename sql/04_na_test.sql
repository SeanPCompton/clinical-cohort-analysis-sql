-- alergies:
CREATE OR REPLACE TEMP VIEW allergies_audit AS
SELECT *
FROM read_csv(
	'../analyst-take-home-task/datasets/allergies.csv'
	,ALL_VARCHAR = true
);

--DESCRIBE allergies_audit;

SELECT
	SUM(CASE WHEN START = 'NA' THEN 1 ELSE 0 END) AS na_start
	,SUM(CASE WHEN STOP = 'NA' THEN 1 ELSE 0 END) AS na_stop
	,SUM(CASE WHEN PATIENT = 'NA' THEN 1 ELSE 0 END) AS na_patient
	,SUM(CASE WHEN ENCOUNTER = 'NA' THEN 1 ELSE 0 END) AS na_encounter
	,SUM(CASE WHEN CODE = 'NA' THEN 1 ELSE 0 END) AS na_code
	,SUM(CASE WHEN DESCRIPTION = 'NA' THEN 1 ELSE 0 END) AS na_description
FROM allergies_audit;

-- encounters:
CREATE OR REPLACE TEMP VIEW encounters_audit AS
SELECT *
FROM read_csv(
	'../analyst-take-home-task/datasets/encounters.csv'
	,ALL_VARCHAR = true
);

-- DESCRIBE encounters_audit;

SELECT
   -- Id
	--SUM(CASE WHEN Id = 'NA' THEN 1 ELSE 0 END)                AS na_id
	--,SUM(CASE WHEN START = 'NA' THEN 1 ELSE 0 END)           AS na_start
	--,SUM(CASE WHEN STOP = 'NA' THEN 1 ELSE 0 END)            AS na_stop
	--,SUM(CASE WHEN PATIENT = 'NA' THEN 1 ELSE 0 END)         AS na_patient
	
    SUM(CASE WHEN PROVIDER = 'NA' THEN 1 ELSE 0 END)        AS na_provider
	,SUM(CASE WHEN ENCOUNTERCLASS = 'NA' THEN 1 ELSE 0 END)  AS na_encounterclass
	,SUM(CASE WHEN CODE = 'NA' THEN 1 ELSE 0 END)            AS na_code
	--,SUM(CASE WHEN DESCRIPTION = 'NA' THEN 1 ELSE 0 END)     AS na_description
	--,SUM(CASE WHEN COST = 'NA' THEN 1 ELSE 0 END)            AS na_cost
	,SUM(CASE WHEN REASONCODE = 'NA' THEN 1 ELSE 0 END)      AS na_reasoncode
	,SUM(CASE WHEN REASONDESCRIPTION = 'NA' THEN 1 ELSE 0 END) AS na_reasondescription
    ,count(reasoncode) as reason_row_count
FROM encounters_audit

--group by Id
;


-- medications
CREATE OR REPLACE TEMP VIEW medications_audit AS
SELECT *
FROM read_csv(
	'../analyst-take-home-task/datasets/medications.csv'
	,ALL_VARCHAR = true
);

SELECT
    SUM(CASE WHEN START = 'NA' THEN 1 ELSE 0 END) AS NA_STA
    ,SUM(CASE WHEN STOP = 'NA' THEN 1 ELSE 0 END) AS NA_STOP -- CONTAINS 'NA'
    ,SUM(CASE WHEN PATIENT = 'NA' THEN 1 ELSE 0 END) AS NA_PAT
    ,SUM(CASE WHEN ENCOUNTER = 'NA' THEN 1 ELSE 0 END) AS NA_ENC
    ,SUM(CASE WHEN CODE = 'NA' THEN 1 ELSE 0 END) AS NA_CODE
    ,SUM(CASE WHEN DESCRIPTION = 'NA' THEN 1 ELSE 0 END) AS NA_DESC
    ,SUM(CASE WHEN COST = 'NA' THEN 1 ELSE 0 END) AS NA_COST
    ,SUM(CASE WHEN DISPENSES = 'NA' THEN 1 ELSE 0 END) AS NA_DISP
    ,SUM(CASE WHEN TOTALCOST = 'NA' THEN 1 ELSE 0 END) AS NA_TOCOST
    ,SUM(CASE WHEN REASONCODE = 'NA' THEN 1 ELSE 0 END) AS NA_RC -- CONTAINS 'NA'
    ,SUM(CASE WHEN REASONDESCRIPTION = 'NA' THEN 1 ELSE 0 END) AS NA_RD -- CONTAINS 'NA'

from medications_audit;

-- patients
CREATE OR REPLACE TEMP VIEW patients_audit AS
SELECT *
FROM read_csv(
	'../analyst-take-home-task/datasets/patients.csv'
	,ALL_VARCHAR = true
);

--DESCRIBE patients_audit;

SELECT
    SUM(CASE WHEN id = 'NA' THEN 1 ELSE 0 END) AS NA_id
    ,SUM(CASE WHEN birthdate = 'NA' THEN 1 ELSE 0 END) AS NA_bday
    ,SUM(CASE WHEN deathdate = 'NA' THEN 1 ELSE 0 END) AS NA_dday -- CONTAINS 'NA'
from patients_audit;

-- procedures
CREATE OR REPLACE TEMP VIEW procedures_audit AS
SELECT *
FROM read_csv(
	'../analyst-take-home-task/datasets/procedures.csv'
	,ALL_VARCHAR = true
);

-- DESCRIBE procedures_audit;

