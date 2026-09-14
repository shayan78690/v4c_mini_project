# Diagrams

Create these two diagrams manually in draw.io (https://draw.io) and save here.

## 1. ER Diagram (OLTP) — er_diagram.drawio
Tables to draw with FK relationships:
- Departments (department_id PK, department_name, location)
- Employees (employee_id PK, department_id FK, first_name, last_name, email, job_role...)
- Projects (project_id PK, department_id FK, project_name, status, budget...)
- Project_Assignments (assignment_id PK, employee_id FK, project_id FK, role_in_project...)
- Performance_Reviews (review_id PK, employee_id FK, reviewer_id FK, performance_rating...)
- Salary_History (history_id PK, employee_id FK, old_salary, new_salary, change_date...)

## 2. Star Schema (OLAP) — star_schema.drawio
Central fact table with 4 dimension tables:
- Fact_PerformanceReviews (center)
  → Dim_Employee (SCD Type 2: surrogate_key, start_date, end_date, is_current)
  → Dim_Department (dept_key PK, department_name, location)
  → Dim_Project (project_key PK, project_name, status)
  → Dim_Date (date_key PK, full_date, year, quarter, month)
