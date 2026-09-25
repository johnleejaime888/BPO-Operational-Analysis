use project3;

CREATE TABLE staging
LIKE bpo_operation_raw;

INSERT INTO staging
SELECT * FROM bpo_operation_raw;

SELECT * FROM staging;

# Checking Duplicates

WITH duplicateCTE AS (
	SELECT *,
    ROW_NUMBER() OVER(PARTITION BY interaction_id) AS row_num FROM staging
)
SELECT * FROM duplicateCTE WHERE row_num > 1;


# Standardizing Data

SELECT DISTINCT date FROM staging1;

SELECT * FROM staging1 WHERE date IS NULL;

UPDATE staging1 SET date = NULL WHERE date = '';

-- Data Quality Finding: Some transaction records had missing transaction dates. These records were retained because the transaction details remained valid, but they were excluded from time-based analysis.



SELECT agent_id AS column_name, agent_id, COUNT(*) AS frequency  FROM staging GROUP BY agent_id

UNION ALL

SELECT agent_name, agent_name, COUNT(*)  FROM staging GROUP BY agent_name

UNION ALL

SELECT team, team, COUNT(*)  FROM staging GROUP BY team

UNION ALL

SELECT account, account, COUNT(*)  FROM staging GROUP BY account

UNION ALL

SELECT location, location, COUNT(*)  FROM staging GROUP BY location

UNION ALL

SELECT shift, shift, COUNT(*)  FROM staging GROUP BY shift

UNION ALL

SELECT channel, channel, COUNT(*)  FROM staging GROUP BY channel

UNION ALL

SELECT call_type, call_type, COUNT(*)  FROM staging GROUP BY call_type

UNION ALL

SELECT resolution_status, resolution_status, COUNT(*)  FROM staging GROUP BY resolution_status

UNION ALL

SELECT attendance_status, attendance_status, COUNT(*)  FROM staging GROUP BY attendance_status

UNION ALL

SELECT sla_met, sla_met, COUNT(*)  FROM staging GROUP BY sla_met

UNION ALL

SELECT fcr, fcr, COUNT(*)  FROM staging GROUP BY fcr

ORDER BY column_name, frequency;


SELECT * FROM staging;


# VALIDATE Numbers

WITH validate_num AS(
SELECT *,
	concat_ws(' ',
	CASE WHEN handled_calls < 0 THEN 'Invalid handled calls' END,
    CASE WHEN answered_calls < 0 THEN 'Invalid answered calls' END,
    CASE WHEN abandoned_calls < 0 THEN 'Invalid abandoned calls' END,
	CASE WHEN talk_time_minutes < 0 THEN 'Invalid talk_time_minutes' END,
    CASE WHEN hold_time_minutes < 0 THEN 'Invalid hold_time_minutes' END,
    CASE WHEN after_call_work < 0 THEN 'Invalid after_call_work'END,
    CASE WHEN aht_seconds < 0 THEN 'Invalid AHT seconds' END,
	CASE WHEN csat_score < 0 THEN 'Invalid CSAT Score'END,
	CASE WHEN qa_score < 0 THEN 'Invalid QA Score'END,
    CASE WHEN late_minutes < 0 THEN 'Invalid late_minutes'END,
    CASE WHEN overtime_hours < 0 THEN 'Invalid Overtime hours'END

    ) AS remarks
FROM staging
)
SELECT * FROM validate_num WHERE remarks <> '';

CREATE TABLE staging1
LIKE staging;

ALTER TABLE staging1
ADD COLUMN remarks TEXt;

INSERT INTO staging1
SELECT *,
	concat_ws(' ',
	CASE WHEN handled_calls < 0 THEN 'Invalid handled calls' END,
    CASE WHEN answered_calls < 0 THEN 'Invalid answered calls' END,
    CASE WHEN abandoned_calls < 0 THEN 'Invalid abandoned calls' END,
	CASE WHEN talk_time_minutes < 0 THEN 'Invalid talk_time_minutes' END,
    CASE WHEN hold_time_minutes < 0 THEN 'Invalid hold_time_minutes' END,
    CASE WHEN after_call_work < 0 THEN 'Invalid after_call_work'END,
    CASE WHEN aht_seconds < 0 THEN 'Invalid AHT seconds' END,
	CASE WHEN csat_score < 0 THEN 'Invalid CSAT Score'END,
	CASE WHEN qa_score < 0 THEN 'Invalid QA Score'END,
    CASE WHEN late_minutes < 0 THEN 'Invalid late_minutes'END,
    CASE WHEN overtime_hours < 0 THEN 'Invalid Overtime hours'END

    ) AS remarks
FROM staging;


SELECT * FROM staging1 WHERE remarks <> '';

UPDATE staging1 SET aht_seconds = NULL WHERE remarks <> '';

-- AHT Validation: Identified negative AHT values as invalid records. Since no datetime fields were available to validate the correct duration, negative values were excluded from AHT calculations rather than converted to positive values.

