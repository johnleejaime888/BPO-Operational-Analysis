# 1. What is our overall AHT, FCR rate, and average CSAT — and how do they trend over the data period?
	
  SELECT 
		MONTH(call_date) AS month_number,
		MONTHNAME(call_date) AS month_name,
        SUM(COALESCE(aht_seconds, 0)) AS total_aht_seconds,
        ROUND(AVG(COALESCE(aht_seconds, 0)), 2) AS avg_aht_seconds,
        COUNT(COALESCE(resolved_first_call, 0)) AS total_fcr,
        ROUND(AVG(COALESCE(csat_score, 0)), 2) AS avg_csat_score
	FROM staging1
		GROUP BY MONTH(call_date), MONTHNAME(call_date)
		ORDER BY month_number;
        
# January had a low average AHT with high FCR and CSAT scores. In contrast, April, May, and June had higher average AHT and FCR but lower CSAT scores.


# 2. Which **team** has the best/worst AHT and FCR? Is there a tradeoff (e.g. a team that resolves fast but has lower CSAT)?
	SELECT team, 
		SUM(COALESCE(aht_seconds, 0)) AS total_aht_seconds,
        COUNT(CASE WHEN resolved_first_call = 'Yes' THEN 1 END) AS total_yes_fcr,
		ROUND(AVG(COALESCE(csat_score, 0)), 2) AS avg_csat_Score
    FROM staging1 GROUP BY team ORDER BY total_aht_seconds DESC;
    
# Based on the data, the Sales team records the highest total AHT and FCR, while the Billing team has the lowest total AHT and a high CSAT score.


#3. Which **shift** (Day/Mid/Night) has the longest wait times? Does that correlate with lower CSAT?
 
	SELECT COUNT(*) AS row_count, shift, 
		SUM(COALESCE(wait_time_seconds, 0)) AS total_wait_time,
		ROUND(AVG(COALESCE(wait_time_seconds, 0)), 2) AS avg_wait_time,
		COUNT(COALESCE(csat_score, 0)) AS total_csat_score,
		ROUND(AVG(COALESCE(csat_score, 0)), 2) AS avg_csat_score
	FROM staging1 GROUP BY shift;
 
/* Based on the data, the Mid shift has the highest average wait time at 45.93 seconds. However, we cannot conclude that the higher wait time directly leads to lower CSAT scores, 
as other factors may also influence customer satisfaction, such as average AHT, FCR, and QA scores. Further analysis of these metrics is needed to better understand their relationship with CSAT.
*/
SELECT * FROM staging1;
#4. Who are the **top 10 and bottom 10 agents** by a blended performance view (FCR rate + CSAT + AHT)? Careful: don't rank on a single metric in isolation — a fast AHT with terrible CSAT is not "good."

SELECT * FROM (
    SELECT agent_name, 
        COUNT(CASE WHEN resolved_first_call = 'Yes' THEN 1 END) AS total_fcr,
        ROUND(AVG(COALESCE(csat_score, 0)), 2) AS avg_csat_score,
        ROUND(AVG(COALESCE(aht_seconds, 0)), 2) AS avg_aht_seconds
    FROM staging1 
    GROUP BY agent_name 
    ORDER BY avg_csat_score DESC 
    LIMIT 10
) AS top10

UNION

SELECT * FROM (
    SELECT agent_name, 
        COUNT(CASE WHEN resolved_first_call = 'Yes' THEN 1 END) AS total_fcr,
        ROUND(AVG(COALESCE(csat_score, 0)), 2) AS avg_csat_score,
        ROUND(AVG(COALESCE(aht_seconds, 0)), 2) AS avg_aht_seconds
    FROM staging1 
    GROUP BY agent_name 
    ORDER BY avg_csat_score ASC 
    LIMIT 10
) AS bottom10;

#5. Which **region(s)** generate the most call volume, and do they show

	SELECT region, COUNT(call_id) FROM staging1 GROUP BY region ORDER BY COUNT(call_id) DESC;

# Cebu recorded the highest call volume among all regions, while Region IV-A had the lowest call volume during the period analyzed.
