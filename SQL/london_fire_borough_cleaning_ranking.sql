--Check count of null entries anywhere in table; rerun as select * if count > 0
SELECT COUNT(*)
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
WHERE NOT (`bigquery-public-data.london_fire_brigade.fire_brigade_service_calls` IS NOT NULL);

--Display all rows where important columns are null
SELECT *
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
WHERE incident_number IS NULL
OR date_of_call IS NULL
OR borough_name IS NULL
OR first_pump_arriving_deployed_from_station IS NULL;

--Display all rows where stored values are out of reasonable range
SELECT *
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
WHERE date_of_call NOT BETWEEN '2017-01-01' AND '2017-12-31'
OR cal_year <> 2017
OR hour_of_call NOT BETWEEN 0 AND 23;

--Check relevant fields for unusual entry values that might be a typo
SELECT DISTINCT incident_group
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

SELECT DISTINCT property_category
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

SELECT DISTINCT property_type
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
ORDER BY 1;

SELECT DISTINCT address_qualifier
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

SELECT DISTINCT borough_name
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

SELECT DISTINCT proper_case
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

SELECT DISTINCT ward_name
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

SELECT DISTINCT ward_name_new
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

SELECT *
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
WHERE frs <> 'London';

SELECT DISTINCT incident_station_ground
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`;

--Display incident count by borough and property category each month
SELECT FORMAT_DATE("%Y-%m", date_of_call) Month_of_Incident, proper_case BoroughName, property_category, COUNT(incident_number) No_of_Incidents
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
GROUP BY Month_of_Incident, BoroughName, property_category
ORDER BY Month_of_Incident, No_of_Incidents DESC;

--Display incident count by borough and property type each month
SELECT FORMAT_DATE("%Y-%m", date_of_call) Month_of_Incident, proper_case BoroughName, property_type, COUNT(incident_number) No_of_Incidents
FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
GROUP BY Month_of_Incident, BoroughName, property_type
ORDER BY Month_of_Incident, No_of_Incidents DESC;

--Display the top N number of incidents by property type each month
SELECT A.Month_of_Incident, property_type, A.No_of_Incidents
FROM
(
  SELECT Month_of_Incident, property_type, No_of_Incidents,
  DENSE_RANK() OVER(PARTITION BY Month_of_Incident ORDER BY No_of_Incidents DESC) rank_no
  FROM
  (
    SELECT FORMAT_DATE("%Y-%m", date_of_call) Month_of_Incident, property_type, COUNT(incident_number) No_of_Incidents
    FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
    GROUP BY Month_of_Incident, property_type
    ORDER BY Month_of_Incident, No_of_Incidents DESC
  )
  ORDER BY Month_of_Incident
) A
WHERE A.rank_no <= 5;

--Display the top N number of incidents by property category each month
SELECT Month_of_Incident, property_category, No_of_Incidents
FROM
(
  SELECT Month_of_Incident, property_category, No_of_Incidents,
  DENSE_RANK() OVER(PARTITION BY Month_of_Incident ORDER BY No_of_Incidents DESC) rank_no
  FROM
  (
    SELECT FORMAT_DATE("%Y-%m", date_of_call) Month_of_Incident, property_category, COUNT(incident_number) No_of_Incidents
    FROM `bigquery-public-data.london_fire_brigade.fire_brigade_service_calls`
    GROUP BY Month_of_Incident, property_category
    ORDER BY Month_of_Incident, No_of_Incidents DESC
  )
  ORDER BY Month_of_Incident
) A
WHERE A.rank_no <= 3;

--Display the Nth ranked borough by number of incidents per selected period
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
