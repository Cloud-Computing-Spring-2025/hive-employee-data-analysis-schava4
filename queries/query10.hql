SELECT emp_id, name, department, salary 
FROM (
    SELECT emp_id, name, department, salary,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
    FROM employees
) ranked_employees
WHERE rank <= 3;
