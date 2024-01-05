
/*
Maji ndogo deep data exploration
SkillS USED: Entry-relationship data (ERDs), Joins and set operations, subqueries, Common Table Expressions(CTES), Views and Normalisation
*/


-- creating auditors table and importing Auditor_report.csv to Mysql


DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);


/* Retrieving corresponding scores from the water_quality table.
Particularly the subjective_quality_score. Joining the visits table and the water_quality table, using the
record_id as the connecting key.
*/

SELECT
	auditor_report.location_id,
	visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.statements AS statements
FROM auditor_report
JOIN visits ON auditor_report.location_id = visits.location_id 
JOIN water_quality ON water_quality.record_id = visits.record_id
JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score AND visits.visit_count
= 1;

-- calculating how many mistakes each employee made grouped them by name

WITH
INCORRECT_RECORDS AS (
	SELECT
	auditor_report.location_id,
	visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.statements AS statements
FROM auditor_report
JOIN visits ON auditor_report.location_id = visits.location_id 
JOIN water_quality ON water_quality.record_id = visits.record_id
JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score AND visits.visit_count
= 1)

SELECT 
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM INCORRECT_RECORDS
GROUP BY employee_name ;


-- AVG number of mistakes made by each employee 

WITH
INCORRECT_RECORDS AS (
	SELECT
		auditor_report.location_id AS audit_location,
		auditor_report.true_water_source_score AS auditor_score,
		visits.record_id,
		water_quality.subjective_quality_score AS surveyor_score,
		employee.assigned_employee_id,
		employee.employee_name
	FROM auditor_report
	JOIN visits ON auditor_report.location_id = visits.location_id 
	JOIN water_quality ON water_quality.record_id = visits.record_id
	JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
	WHERE auditor_report.true_water_source_score  != water_quality.subjective_quality_score AND visits.visit_count
	= 1)
SELECT 
    employee_name,
    COUNT(employee_name) AS number_of_mistakes,
    COUNT(employee_name) / (SELECT COUNT(DISTINCT employee_name) FROM INCORRECT_RECORDS) AS avg_number_of_mistakes
FROM INCORRECT_RECORDS
GROUP BY employee_name;


-- average number of mistakes each employees made.


WITH INCORRECT_RECORDS AS (
    SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id,
        water_quality.subjective_quality_score AS surveyor_score,
        employee.assigned_employee_id,
        employee.employee_name
    FROM auditor_report
    JOIN visits ON auditor_report.location_id = visits.location_id 
    JOIN water_quality ON water_quality.record_id = visits.record_id
    JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
    WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score AND visits.visit_count = 1
)

SELECT 
    COUNT(employee_name) AS total_number_of_mistakes,
    COUNT(DISTINCT employee_name) AS total_number_of_employees,
    COUNT(employee_name) / COUNT(DISTINCT employee_name) AS avg_number_of_mistakes_of_employees
FROM INCORRECT_RECORDS;


-- Avarage mistakaes comparison

WITH INCORRECT_RECORDS AS (
    SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id,
        water_quality.subjective_quality_score AS surveyor_score,
        employee.assigned_employee_id,
        employee.employee_name
    FROM auditor_report
    JOIN visits ON auditor_report.location_id = visits.location_id 
    JOIN water_quality ON water_quality.record_id = visits.record_id
    JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
    WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score AND visits.visit_count = 1
)
SELECT
    COUNT(employee_name) AS number_of_mistakes,
    AVG(COUNT(employee_name)) OVER () AS avg_employee_error_count,
    employee_name,
    COUNT(employee_name) AS employee_error_count
FROM INCORRECT_RECORDS
GROUP BY employee_name
ORDER BY employee_name;


-- comparison of each employee's error_count with avg_error_count_per_empl


WITH INCORRECT_RECORDS AS (
    SELECT
        auditor_report.location_id AS audit_location,
        auditor_report.true_water_source_score AS auditor_score,
        visits.record_id,
        water_quality.subjective_quality_score AS surveyor_score,
        employee.assigned_employee_id,
        employee.employee_name
    FROM auditor_report
    JOIN visits ON auditor_report.location_id = visits.location_id 
    JOIN water_quality ON water_quality.record_id = visits.record_id
    JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
    WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score AND visits.visit_count = 1
)
, Employee_Error_Counts AS (
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM INCORRECT_RECORDS
    GROUP BY employee_name
)
, Avg_Error_count_per_employee AS (
    SELECT AVG(number_of_mistakes) AS avg_employee_error_count
    FROM Employee_Error_Counts
)

SELECT
    e.employee_name,
    e.number_of_mistakes,
    a.avg_employee_error_count
FROM Employee_Error_Counts AS e
CROSS JOIN Avg_Error_count_per_employee AS a
WHERE e.number_of_mistakes > a.avg_employee_error_count
ORDER BY e.employee_name;


-- Creating a VIEW OF INCORRECT RECORDS

CREATE VIEW
INCORRECT_RECORDS AS (
SELECT
	auditor_report.location_id,
	visits.record_id,
    employee.employee_name,
    auditor_report.true_water_source_score AS auditor_score,
    water_quality.subjective_quality_score AS surveyor_score,
    auditor_report.statements AS statements
FROM auditor_report
JOIN visits ON auditor_report.location_id = visits.location_id 
JOIN water_quality ON water_quality.record_id = visits.record_id
JOIN employee ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score AND visits.visit_count
= 1);

-- Converting Error_count query into a CTE

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
employee_name)
-- Query
SELECT * FROM error_count;


-- A filter for Incorrect_records CTE to identify all the records associated with employees that have above avarage mistakes


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
/* Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY employee_name),

suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
employee_name,
location_id,
statements
FROM Incorrect_records
WHERE employee_name in (SELECT employee_name FROM suspect_list);