USE hr_olap;
CALL sp_load_fact_reviews();


USE hr_olap;

UPDATE Dim_Employee de
JOIN hr_oltp.Employees e ON de.employee_id = e.employee_id
SET de.first_name = e.first_name,
    de.last_name = e.last_name
WHERE de.first_name IS NULL;

USE hr_olap;

UPDATE Dim_Employee de
JOIN hr_oltp.Employees e ON de.employee_id = e.employee_id
SET de.attrition = e.attrition,
    de.over_time = e.over_time,
    de.years_at_company = e.years_at_company
WHERE de.attrition IS NULL;


CALL sp_load_dim_department();