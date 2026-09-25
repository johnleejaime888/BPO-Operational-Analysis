

#OPERATION

SELECT * FROM staging1;

UPDATE staging1 SET handled_calls = 82 WHERE interaction_id='INT000001';

# What is the total number of calls?

SELECT SUM(COALESCE(handled_calls, 0) + COALESCE(answered_calls, 0) + COALESCE(abandoned_calls, 0)) AS TOTAL_CALLS FROM staging1;


# What is the average daily call volume?
    
WITH avg_call_day AS (
	SELECT
		DATE(date) AS ARAW,
        SUM(COALESCE(handled_calls, 0)) AS total_handled_calls,
        SUM(COALESCE(answered_calls, 0)) AS total_answered_calls,
		SUM(COALESCE(abandoned_calls, 0)) AS total_abandoed_calls,
        
        SUM(COALESCE(handled_calls, 0) + COALESCE(answered_calls,0) + COALESCE(abandoned_calls, 0)) AS total_daily_calls
    FROM staging1 GROUP BY date
)
SELECT
AVG(total_handled_calls),
AVG(total_answered_calls),
AVG(total_abandoed_calls),
AVG(total_daily_calls) FROM avg_call_day;
    
# Which account receives the most calls?
	
    SELECT account,
		SUM(COALESCE(handled_calls, 0) + COALESCE(answered_calls, 0) + COALESCE(abandoned_calls, 0)) AS TOTAL_CALLS
    FROM staging1 WHERE call_type = 'Inbound' GROUP BY account ORDER BY account ASC limit 1;
    

# Which team handles the most calls?
    
    WITH CTE1 AS (
		SELECT team, sum(COALESCE(handled_calls, 0 )) AS total_handled_calls FROM staging1 GROUP BY team
    )
    SELECT team, total_handled_calls FROM CTE1 GROUP BY team ORDER BY total_handled_calls DESC limit 1;

# Which shift has the highest call volume?

	WITH CTE1 AS (
		SELECT shift,
        SUM(COALESCE(handled_calls, 0) + COALESCE(answered_calls, 0) + COALESCE(abandoned_calls, 0)) AS total_calls
        FROM staging1 GROUP BY shift
    )
    SELECT shift, total_calls FROM CTE1 GROUP BY shift ORDER BY total_calls DESC LIMIT 1;
    
    
# Agent Performance

# Which agents handle the most calls? -- TOP 5 AGENTS
    
WITH CTE1 AS (
	SELECT agent_name,
    SUM(COALESCE(handled_calls, 0 )) AS total_handled_calls
    FROM staging1 GROUP BY agent_name
)
SELECT agent_name, total_handled_calls FROM CTE1 GROUP BY agent_name ORDER BY total_handled_calls DESC LIMIT 5;

# Which agents have the highest AHT? -- TOP 5 AGENTS

WITH CTE1 AS (
	SELECT agent_name,
    SUM(COALESCE(aht_seconds, 0 )) AS total_aht_seconds
    FROM staging1 GROUP BY agent_name
)
SELECT agent_name, total_aht_seconds FROM CTE1 GROUP BY agent_name ORDER BY total_aht_seconds DESC LIMIT 5;


# Which agents have the highest QA scores? -- TOP 5 AGENTS

WITH CTE1 AS (
	SELECT agent_name,
    SUM(COALESCE(qa_score, 0 )) AS total_qa_score
    FROM staging1 GROUP BY agent_name
)
SELECT agent_name, total_qa_score FROM CTE1 GROUP BY agent_name ORDER BY total_qa_score DESC LIMIT 5;

# Which agents have the highest CSAT? -- TOP 5 AGENTS
WITH CTE1 AS (
	SELECT agent_name, SUM(COALESCE(csat_score,0)) AS total_csat_score FROM staging1 GROUP BY agent_name
)
SELECT agent_name, total_csat_score FROM CTE1 GROUP BY agent_name ORDER BY total_csat_score DESC Limit 5;


# Which agents have the highest FCR?

WITH CTE1 AS (
	SELECT agent_name, COUNT(fcr) AS total_fcr FROM staging1 WHERE fcr = 'YES' GROUP BY agent_name
)
SELECT agent_name, total_fcr FROM CTE1 GROUP BY agent_name ORDER BY total_fcr DESC Limit 5;

# SLA

# What is the overall SLA achievement?

SELECT COUNT(sla_met) AS Total_SLA FROM staging1 WHERE sla_met='YES';

# Which team has the lowest SLA?

WITH team_sla AS (
	SELECT team, count(sla_met) AS Total_SLA FROM staging1 WHERE sla_met = 'YES' GROUP BY team
)
SELECT team, Total_SLA FROM team_sla GROUP BY team ORDER BY Total_SLA ASC Limit 1;

# Which shift has the highest SLA?

WITH team_sla AS (
	SELECT team, count(sla_met) AS Total_SLA FROM staging1 WHERE sla_met = 'YES' GROUP BY team
)
SELECT team, Total_SLA FROM team_sla GROUP BY team ORDER BY Total_SLA DESC LIMIT 1;

# Does high call volume affect SLA?

WITH affect_sla AS (
	SELECT sla_met, SUM(COALESCE(answered_calls, 0)) AS total_calls,
    COUNT(sla_met) AS total_sla 
    FROM staging1 GROUP BY sla_met
)
SELECT sla_met, total_calls, total_sla FROM affect_sla GROUP BY sla_met;


# Productivity

# Which team handles the most calls per agent?

WITH handled_calls_team_agent AS (
    SELECT 
        team,
        agent_name,
        SUM(COALESCE(handled_calls, 0)) AS total_handled_calls
    FROM staging1
    GROUP BY team, agent_name
)
SELECT team, COUNT(agent_name) AS total_agents, SUM(total_handled_calls) AS total_calls, 
ROUND(AVG(total_handled_calls), 2) AS average_call_per_agent 
FROM handled_calls_team_agent GROUP BY team ORDER BY average_call_per_agent DESC;


# Which account has the highest AHT?

WITH aht_account AS (
	SELECT account, sum(COALESCE(aht_seconds, 0)) AS total_aht_seconds FROM staging1 GROUP BY account
)
SELECT account, total_aht_seconds, 
ROUND(total_aht_seconds / 60) AS total_aht_minutes,
ROUND(total_aht_seconds / 60 / 60, 2) AS total_aht_hours
FROM aht_account GROUP BY account ORDER BY total_aht_hours DESC;

# Which channel has the highest AHT?

WITH aht_channel AS (
	SELECT channel, sum(COALESCE(aht_seconds, 0)) AS total_aht_seconds FROM staging1 GROUP BY channel
)
SELECT channel, total_aht_seconds, 
ROUND(total_aht_seconds / 60) AS total_aht_minutes,
ROUND(total_aht_seconds / 60 / 60, 2) AS total_aht_hours
FROM aht_channel GROUP BY channel ORDER BY total_aht_hours DESC LIMIT 1;

# Attendance

# Which team has the highest absenteeism? 

WITH absenteeism AS (
	SELECT team, COUNT(attendance_status) AS total_absenteeism
    FROM staging WHERE attendance_status = 'absent' GROUP BY team
)
SELECT team, total_absenteeism FROM absenteeism GROUP BY team ORDER BY total_absenteeism DESC LIMIT 1;

# Does absenteeism affect SLA?

WITH absenteeism AS (
	SELECT team, attendance_status, COUNT(attendance_status) AS total_absenteeism,
    SUM(COALESCE(handled_calls, 0)) AS total_handled_calls,
    COUNT(sla_met) AS total_sla
    FROM staging GROUP BY team, attendance_status
)
SELECT team, attendance_status, total_absenteeism, total_handled_calls, total_sla FROM absenteeism GROUP BY team, attendance_status ORDER BY team; 

# Which shift has the highest late minutes?

WITH shift AS (
	SELECT shift, SUM(COALESCE(late_minutes)) AS total_late_minutes
    FROM staging GROUP BY shift
)
SELECT shift, total_late_minutes FROM shift GROUP BY shift ORDER BY total_late_minutes DESC; 

# Customer Experience

# Which team has the highest CSAT?

WITH team_csat AS (
	SELECT team, SUM(COALESCE(csat_score, 0)) AS total_csat,
    round(AVG(csat_score), 2) AS avg_csat
    FROM staging1 GROUP BY team
)
SELECT team, SUM(total_csat) AS total_csat1, round(AVG(avg_csat), 2) AS avg_csat FROM team_csat GROUP BY team ORDER BY avg_csat DESC ;

# Does higher AHT result in higher CSAT?

WITH aht_csat AS (
	SELECT team, 
    SUM(COALESCE(aht_seconds, 0)) AS total_aht_seconds,
    SUM(COALESCE(csat_score, 0 )) AS total_csat_scores,
    COUNT(1) AS total_count
    FROM staging1 GROUP BY team
)
SELECT team, total_aht_seconds,
 ROUND((total_aht_seconds / total_count), 2) AS avg_total_aht_seconds,
 total_csat_scores,
 ROUND((total_csat_scores / total_count), 2) AS avg_total_csat_scores
 FROM aht_csat;


