-- SHOW TABLES 
SHOW TABLES;

-- show LOCATION TABLE 
SELECT
 *
 FROM md_water_services.location
 LIMIT 10;

-- show VISIT TABLE TABLE 
SELECT
 *
 FROM md_water_services.visits
 LIMIT 10;

-- WATER SOURCE TABLE
SELECT
 *
 FROM md_water_services.water_source
 LIMIT 10;
 
 -- SQL query to find all the unique/Distinct types of water sources
 
 SELECT distinct
		type_of_water_source
 FROM md_water_services.water_source;
 
 -- This SQL query that retrieves all records from time_in_queue table where the time_in_queue is more than 500 min.

SELECT 
*
FROM visits
WHERE time_in_queue > 500
LIMIT 20;

/* So please write a query to find records where the subject_quality_score is 10 , only looking for home taps and where the source
was visited a second time */

SELECT DISTINCT 
	record_id,
    subjective_quality_score,
	visit_count,
    type_of_water_source 
FROM water_quality , water_source
WHERE subjective_quality_score = '10'  AND visit_count = '2' AND type_of_water_source LIKE 'tap_in_home';


-- WATER QUALITY TABLE

SELECT
*
FROM well_pollution
LIMIT 10;


-- This query checks where the results is Clean but the biological column is > 0.01 

SELECT
*
FROM well_pollution
WHERE results = 'Clean' AND biological >0.01;

/* This query identifies the records that mistakenly have the word Clean in the description -it
is important to remember that not all of our field surveyors used the description to set the results – some checked the actual data.*/

SELECT 
*
FROM well_pollution
WHERE description LIKE '%clean%'AND biological > 0.01;
