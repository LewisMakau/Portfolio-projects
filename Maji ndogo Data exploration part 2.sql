

-- mail address for each employee by 

SET sql_Safe_updates =0;
/*UPATE_EMAILS*/
USE md_water_services;
SELECT
	*
FROM md_water_services.employee;
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
'@ndogowater.gov');


-- trim of employee phone numbers

SET sql_Safe_updates =0;
USE md_water_services;
SELECT
	*
FROM md_water_services.employee;
UPDATE employee
SET phone_number = TRIM(phone_number)
;

-- count how many of our employees live in each town from employee table

USE md_water_services;
SELECT DISTINCT
	town_name,
COUNT(employee_name) OVER (PARTITION BY town_name ) AS Number_employees
FROM
    md_water_services.employee;
    
-- EMPLOYEES PER PROVINCE NAME AND TOWN
    
USE md_water_services;
SELECT DISTINCT
	province_name,
	town_name,
COUNT(employee_name) OVER (PARTITION BY province_name ORDER BY town_name ) AS Number_employees
FROM
    md_water_services.employee;


-- number of records each employee collected
-- limited to only the top 3 employee_ids with the highest number of locations visited

SELECT
    assigned_employee_id,
	COUNT(*)AS visit_count
FROM 
	md_water_services.visits
GROUP BY assigned_employee_id
ORDER BY visit_count DESC;
    
-- query that looks up the top 3 employee's info

SELECT 
	employee_name,email,phone_number,assigned_employee_id
FROM employee
WHERE assigned_employee_id IN (20,22,1,34,33);


-- query that counts the number of records per town

SELECT 
	town_name,
	COUNT(*) AS Records_per_Town
FROM location
GROUP BY town_name
ORDER BY COUNT(*) DESC;

-- count of the records per province

SELECT 
	province_name,
	COUNT(*) AS Records_per_Province
FROM location
GROUP BY province_name
ORDER BY COUNT(*) DESC;

/* Qeury to show
-province_name
-town_name
-An aggregated count of records for each town (per_town).
-grouped by both province_name and town_name.
Ordered by province_name and then sorted by the towns with their record counts in descending order */

SELECT
	town_name,
	province_name,
	COUNT(town_name) AS Records_per_town
FROM location
GROUP BY province_name ,town_name
ORDER BY province_name ,Records_per_town DESC;

-- Number of records for each location type

SELECT 
	location_type,
	COUNT(location_type) AS Numbers_location
FROM location
GROUP BY location_type;

-- Number of people surveyed in total

SELECT
	SUM(number_of_people_served) AS Number_of_people_surveyed
FROM md_water_services.water_source;

-- Number of wells, taps and rivers in totat

SELECT
	type_of_water_source,
	COUNT(type_of_water_source) AS Number_of_water_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY Number_of_water_source DESC;


-- Number of people sharing a particular types of water sources on average

SELECT
	type_of_water_source,
	ROUND(AVG(number_of_people_served)) AS AVG_Number_of_peopel_served_per_source
FROM water_source
GROUP BY type_of_water_source;


-- Number of people getting water from each type of source

SELECT 
	type_of_water_source,
	SUM(number_of_people_served) AS Population_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY Population_served DESC;

--  Number of people getting water from each type of source in percebtage rounded to 0 decimals

SELECT 
	type_of_water_source,
	ROUND((SUM(number_of_people_served)/27628140)*100) AS Percentage_of_Population_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY Percentage_of_Population_served DESC;

-- Type of sources -Total people served grouped by the types 
-- Rank based on the total people served, grouped by the types 

SELECT 
	type_of_water_source,
	SUM(number_of_people_served) AS Population_served,
RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS Rank_by_group
FROM water_source
GROUP BY type_of_water_source
ORDER BY Rank_by_group;


-- Remove tap_in_home from the ranking

SELECT 
	type_of_water_source,
	SUM(number_of_people_served) AS Population_served,
RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) AS Rank_by_population
FROM water_source
WHERE type_of_water_source NOT IN ('tap_in_home')
GROUP BY type_of_water_source
ORDER BY Rank_by_population;

/* query to show the sources within each type , assigned a rank, result limited to improvable sources.
Ordered in DEC Order */

SELECT 
	source_id,
    type_of_water_source,
    number_of_people_served,
RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS Rank_priority
FROM water_source
WHERE type_of_water_source NOT IN ('tap_in_home');

-- Query to show how long the survey took 

SELECT
	Min(time_of_record) AS min_time_of_record,
	MAX(time_of_record) AS max_time_of_record,
DATEDIFF('2023-07-14 13:53:00','2021-01-01 09:10:00') AS Time_survey_took
FROM visits;

-- Query to show how long people have to queue on average in Maji Ndogo.

SELECT 
AVG(NULLIF(time_in_queue,0))
FROM visits;

-- queue times aggregated across the different days of the week

SELECT 
	DAYNAME(time_of_record) AS Day_of_the_week,
	ROUND(AVG(NULLIF(time_in_queue,0))) AS AVG_time_in_queue
FROM visits
GROUP BY Day_of_the_week
ORDER BY Day_of_the_week;


-- Time during the day people collect water

SELECT 
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
	ROUND(AVG(NULLIF(time_in_queue,0))) AS AVG_time_in_queue
FROM visits
GROUP BY hour_of_day;


-- Time people collect water ,hour ot the day 7 days a week*

SELECT
  TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
  -- Sunday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue ELSE NULL END), 0) AS Sunday,
  -- Monday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue ELSE NULL END), 0) AS Monday,
  -- Tuesday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue ELSE NULL END), 0) AS Tuesday,
  -- Wednesday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue ELSE NULL END), 0) AS Wednesday,
  -- Thursday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue ELSE NULL END), 0) AS Thursday,
  -- Friday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue ELSE NULL END), 0) AS Friday,
  -- Saturday
  ROUND(AVG(CASE WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue ELSE NULL END), 0) AS Saturday
FROM visits
WHERE time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY hour_of_day
ORDER BY hour_of_day;