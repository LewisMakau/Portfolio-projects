/*
Maji ndogo deep data exploration part 4
SKILLS USED: Use of views, subqueries,CTES, joins and operations, windows functions and control flow functions
*/



/* 
1.Joining visits to location table on location_id
2.Joining water_sorce to visit table on source_id
3.Where visits.visit_count = 1 as a filter.

*/

SELECT 
	location.province_name,
	location.town_name,
    visits.visit_count,
    visits.location_id,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM visits
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
WHERE visits.visit_count= 1 ;

-- removing the location_id and visit_count columns 

SELECT 
	location.province_name,
	location.town_name,
    water_source.type_of_water_source,
    water_source.number_of_people_served
FROM visits
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
WHERE visits.visit_count= 1 ;


-- Adding the location_type column from location and time_in_queue from visits to our results set 

SELECT 
	location.province_name,
	location.town_name,
    location.location_type,
    water_source.type_of_water_source,
    water_source.number_of_people_served,
    visits.time_in_queue
FROM visits
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
WHERE visits.visit_count= 1 ;



-- Getting the results from the well_pollution table well_pollution.results

SELECT 
	location.province_name,
	location.town_name,
    location.location_type,
    water_source.type_of_water_source,
    water_source.number_of_people_served,
    visits.time_in_queue,
    well_pollution.results
FROM visits
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
LEFT JOIN well_pollution ON well_pollution.source_id = visits.source_id
WHERE visits.visit_count= 1 ;


-- Creating combined_analysis_table VIEW


CREATE VIEW 
combined_analysis_table AS (
SELECT 
	location.province_name,
	location.town_name,
    location.location_type,
    water_source.type_of_water_source AS source_type,
    water_source.number_of_people_served AS people_served,
    visits.time_in_queue,
    well_pollution.results
FROM visits
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
LEFT JOIN well_pollution ON well_pollution.source_id = visits.source_id
WHERE visits.visit_count=
 1);



-- Creating PIVOT TABLE for Province and Water source types


WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
	province_name,
	SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name
)
SELECT
	ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated

ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type= 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well

FROM combined_analysis_table ct
JOIN province_totals pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name
ORDER BY ct.province_name;


-- Grouping Pivot table by Province and town


WITH town_totals AS (-- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT 	province_name,
		town_name, 
		SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well

FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY ct.town_name;

		
-- Creating  A TEMPORALY TABLE

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT 	province_name,
		town_name, 
		SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,

ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
    
FROM combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY ct.town_name;



-- Selecting town_aggregated_water_access

SELECT 
	*
FROM town_aggregated_water_access;


-- Finding town with the highest ratio of people who have taps, but have no running water


SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access;


-- Creating Project_Progress table

CREATE TABLE Project_progress (
  Project_id SERIAL PRIMARY KEY,
  source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
  Address VARCHAR(50),
  Town VARCHAR(30),
  Province VARCHAR(30),
  Source_type VARCHAR(50),
  Improvement VARCHAR(50),
  Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
  Date_of_completion DATE,
  Comments TEXT
);


-- Query to get data for Project_progress Table 

SELECT
	location.address,
	location.town_name,
	location.province_name,
	water_source.source_id,
	water_source.type_of_water_source,
	well_pollution.results,
    
CASE 
	WHEN results = 'Contaminated:Biological' THEN 'Install UV filter'
    WHEN results = 'Contaminated: Chemical' THEN 'RO filter'
	WHEN type_of_water_source = 'river' THEN 'Drill well'
	WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN
            CONCAT("Install ", FLOOR(visits.time_in_queue / 30), " taps nearby")
	WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
	ELSE NULL
    END AS Improvement
    
FROM water_source
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN visits ON water_source.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id

WHERE visits.visit_count = 1
AND ((water_source.type_of_water_source = 'shared_tap'
AND visits.time_in_queue >= 30)
OR well_pollution.results NOT IN ('Clean')
OR water_source.type_of_water_source IN ('river','tap_in_home_broken'));


-- Adding Project_progress_query data to Project_Progress Table 

INSERT INTO project_progress (
			source_id,
			Address,
			Town,
			Province,
			Source_type, 
			Improvement, 
			Source_status,
			Date_of_completion,
			Comments)
SELECT
	water_source.source_id,
    location.address AS Address,
    location.town_name AS Town,
    location.province_name AS Province,
    water_source.type_of_water_source AS Source_type,
	
CASE 
	WHEN results = 'Contaminated:Biological' THEN 'Install UV filter'
    WHEN results = 'Contaminated: Chemical' THEN 'RO filter'
	WHEN type_of_water_source = 'river' THEN 'Drill well'
	WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN
            CONCAT("Install ", FLOOR(visits.time_in_queue / 30), " taps nearby")
	WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
	ELSE NULL
    END AS Improvement,
CASE
	WHEN well_pollution.results IN ('Clean') THEN 'Complete'
	ELSE 'Backlog'
    END AS Source_status,
    Null AS Date_of_completion,
    NULL AS Comments
    
FROM water_source
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN visits ON water_source.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id

WHERE visits.visit_count = 1
AND ((water_source.type_of_water_source = 'shared_tap'
AND visits.time_in_queue >= 30)
OR well_pollution.results NOT IN ('Clean')
OR water_source.type_of_water_source IN ('river','tap_in_home_broken'));