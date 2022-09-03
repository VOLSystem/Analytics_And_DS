--Determining the Nth ranked entry per selected period
SELECT *
FROM
(
  SELECT DENSE_RANK() OVER(PARTITION BY Month_of_Incident ORDER BY Month_of_Incident, Number_of_Incidents DESC) rank_no,
  borough_name, Month_of_Incident, Number_of_Incidents
  FROM
  (
    SELECT borough_name, FORMAT_DATE("%Y-%m", date_of_call) Month_of_Incident,
    COUNT(incident_number) Number_of_Incidents
    FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls` 
    GROUP BY Month_of_Incident, borough_name
    ORDER BY Month_of_Incident, Number_of_Incidents DESC
  )
  ORDER BY Month_of_Incident, Number_of_Incidents DESC
) A
WHERE A.rank_no = 2