-- Select the OLAP schema
USE hr_olap;

-- 1. Populate the static Dim_Date (only need to run once)
CALL sp_populate_dim_date();

-- 2. Sync Departments (prerequisite for Employees/Projects)
CALL sp_load_dim_department();

-- 3. Sync Projects
CALL sp_load_dim_project();

-- 4. Sync Employees (SCD Type 2) -> Now includes fixed names/attrition
CALL sp_scd2_load_dim_employee();

-- 5. Load Performance Reviews -> Now has valid data
CALL sp_load_fact_reviews();