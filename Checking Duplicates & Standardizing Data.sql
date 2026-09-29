

/*In this process, I cleaned the raw data by identifying and fixing inconsistent data, including typos, extra spaces, improper formats, and negative values. 
I also removed duplicate records to maintain data accuracy and ensure unique row counts.*/

/* 
Data Validation
 - Duplicates Records
 - I identified blank and negative values in the aht_seconds and csat_score columns and converted them to NULL to prevent invalid values from affecting the calculation of totals and other metrics.
 - I identified missing values in the transferred and resolved_first_call columns and replaced them with "Unknown" to preserve the records without making assumptions about the correct values.
 */

/* SQL Function Used: 
CTE Function, Windows Function, Argregated Function, CASE Function, CONCAT, LOCATE, UPPER, LOWER
SUBSTRING, SUBSTRING_INDEX, SELECT, UPDATE, DELETE, WHERE, AS, GROUP BY */




# Cleaning and Standardizing Data

WITH duplicate_data AS(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY call_id) AS row_num
FROM staging
)
SELECT * FROM duplicate_data;

DELETE FROM staging1 WHERE row_num > 1;

SELECT agent_name, TRIM(agent_name),
CASE 
    -- Used the LOCATE() function to identify values containing extra spaces in the column. 
    WHEN LOCATE(' ', TRIM(agent_name)) > 0 THEN
        CONCAT(
            -- First Name (Capital 1st letter + small 2nd letter onwards)
            UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(agent_name), ' ', 1), 1, 1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(agent_name), ' ', 1), 2)),
            ' ',
            -- Second Name (Capital 1st letter + small 2nd letter onwards)
            UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(agent_name), ' ', -1), 1, 1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(agent_name), ' ', -1), 2))
        )
    -- ELSE used if the value is 1 word.
    ELSE
        CONCAT(
            UPPER(SUBSTRING(TRIM(agent_name), 1, 1)),
            LOWER(SUBSTRING(TRIM(agent_name), 2))
        )
END AS clean_name
FROM staging1;

UPDATE staging1 SET agent_name = TRIM(agent_name);

UPDATE staging1 SET agent_name = (SELECT
CASE 
    WHEN LOCATE(' ', agent_name) > 0 THEN
        CONCAT(
            -- First Name (Capital 1st letter + small 2nd letter onwards)
            UPPER(SUBSTRING(SUBSTRING_INDEX(agent_name, ' ', 1), 1, 1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(agent_name, ' ', 1), 2)),
            ' ',
            -- Second Name (Capital 1st letter + small 2nd letter onwards)
            UPPER(SUBSTRING(SUBSTRING_INDEX(agent_name, ' ', -1), 1, 1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(agent_name, ' ', -1), 2))
        )
    -- ELSE used if the values is 1 word.
    ELSE
        CONCAT(
            UPPER(SUBSTRING(agent_name, 1, 1)),
            LOWER(SUBSTRING(agent_name, 2))
        )
END);


SELECT DISTINCT(team), TRIM(team),
	CASE
		WHEN LOCATE(' ', TRIM(team)) > 0 THEN
			CONCAT(
            UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', 1),1 ,1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', 1), 2)),
            ' ',
            UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', -1), 1, 1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', -1), 2))
            
            )
            
		ELSE
        
			CONCAT (
			UPPER(SUBSTRING(TRIM(team), 1, 1)),
            LOWER(SUBSTRING(TRIM(team), 2))
            )
			
    END AS clean_team
FROM staging1;


UPDATE staging1 SET team =
	CASE
		WHEN LOCATE(' ', TRIM(team)) > 0 THEN
			CONCAT(
            UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', 1),1 ,1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', 1), 2)),
            ' ',
            UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', -1), 1, 1)),
            LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(team), ' ', -1), 2))
            
            )
            
		ELSE
        
			CONCAT (
			UPPER(SUBSTRING(TRIM(team), 1, 1)),
            LOWER(SUBSTRING(TRIM(team), 2))
			)
			
    END;
    
    SELECT customer_name, TRIM(customer_name),
	CASE
		WHEN LOCATE(' ', TRIM(customer_name)) > 0 THEN
			CONCAT(
				UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 1, 1)),
                LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 2)),
                ' ',
                UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', -1), 1, 1)),
                LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', -1), 2))
            )
		ELSE
			CONCAT(
				UPPER(SUBSTRING(TRIM(customer_name), 1, 1)),
				LOWER(SUBSTRING(TRIM(customer_name), 2))
            )
    END AS clean_name
FROM staging1;

UPDATE staging1 SET customer_name =
	CASE
		WHEN LOCATE(' ', TRIM(customer_name)) > 0 THEN
			CONCAT(
				UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 1, 1)),
                LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', 1), 2)),
                ' ',
                UPPER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', -1), 1, 1)),
                LOWER(SUBSTRING(SUBSTRING_INDEX(TRIM(customer_name),' ', -1), 2))
            )
		ELSE
			CONCAT(
				UPPER(SUBSTRING(TRIM(customer_name), 1, 1)),
				LOWER(SUBSTRING(TRIM(customer_name), 2))
            )
    END;
    
UPDATE staging1 
	SET call_type = 
		CASE
			WHEN LOWER(call_type) = 'outbound' THEN 'Outbound'
			WHEN LOWER(call_type) = 'inbound'  THEN 'Inbound'
			ELSE call_type  -- keeps original value kung hindi na-match
		END;
        
SELECT DISTINCT(queue) FROM staging1;

SELECT transferred, count(*) FROM staging1 GROUP BY transferred;

UPDATE staging1 SET transferred = 
	CASE
		WHEN transferred = 'NO' THEN 'No'
        WHEN transferred = 'YES' THEN 'Yes'
        WHEN transferred = 'UNKNOWN' THEN 'Unknown'
        WHEN transferred = 0 THEN 'UNKNOWN'
        WHEN transferred = '' THEN 'UNKNOWN'
    END;
    
    SELECT DISTINCT(resolved_first_call), count(*) FROM staging1 GROUP BY resolved_first_call;
    
    UPDATE staging1 SET resolved_first_call = 
	CASE
		WHEN resolved_first_call = 'N' THEN 'No'
        WHEN resolved_first_call = 'Y' THEN 'Yes'
        WHEN resolved_first_call = ' ' THEN 'Unknown'
    END;
    
    SELECT DISTINCT (sentiment) FROM staging1;
    
    SELECT DISTINCT (escalated), count(*) FROM staging1 GROUP BY escalated;
    
    UPDATE staging1 SET escalated = 
	CASE
		WHEN escalated = 'N' THEN 'No'
        WHEN escalated = 'Y' THEN 'Yes'
        WHEN escalated = ' ' THEN 'Unknown'
    END;
    
SELECT DISTINCT (language) FROM staging1;

SELECT DISTINCT(region) FROM staging1;

SELECT DISTINCT(disposition_code) FROM staging1;

/* I identified blank and negative values in the aht_seconds, hold_time_seconds,
   and wait_time_seconds columns to determine which records required cleaning.  */

SELECT * FROM staging1 WHERE aht_seconds < 0 OR hold_time_seconds < 0 OR wait_time_seconds < 0 OR csat_score = '';

UPDATE staging1 SET csat_score = NULL WHERE csat_score = '';


SELECT * FROM staging1





