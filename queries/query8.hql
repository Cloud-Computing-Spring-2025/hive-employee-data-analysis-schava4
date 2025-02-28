SELECT e.emp_id, e.name, e.job_role, e.salary, e.project, e.join_date, e.department, d.location
FROM employees e
JOIN departments d 
ON e.department = d.department_name;
