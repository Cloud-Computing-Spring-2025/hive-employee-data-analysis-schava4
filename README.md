# Hadoop, Hive, and Hue Setup (Pseudo-Distributed Environment)

This project sets up a **pseudo-distributed environment** using **Docker Compose**, including:
- **Hadoop (HDFS - Namenode, Datanode)**
- **Hive (Metastore, HiveServer2)**
- **Hue (Web UI for Hadoop and Hive queries)**

📌 Step 1: Start the Hadoop, Hive, and Hue Containers
docker-compose up -d

📌 Step 2: Copy Data Files into Hive Server Container
docker cp employees.csv hive-server:/
docker cp departments.csv hive-server:/

📌 Step 3: Move CSV Files into HDFS

docker exec -it hive-server /bin/bash
hdfs dfs -mkdir -p /inputs
hdfs dfs -put employees.csv /inputs
hdfs dfs -put departments.csv /inputs

📌 Step 4: Open Hue Web UI
In your browser, go to:
http://localhost:8888

📌 Step 5: Create Tables in Hue
Create Employees Table

CREATE TABLE employees (
    emp_id INT,
    name STRING,
    age INT,
    job_role STRING,
    salary DOUBLE,
    project STRING,
    join_date DATE,
    department STRING
) ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE;

Create Departments Table

CREATE TABLE departments (
    dept_id INT,
    department_name STRING,
    location STRING
) ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE;

📌 Step 6: Load Data into Hive
 LOAD DATA INPATH 'inputs/employees.csv' INTO TABLE employees;
LOAD DATA INPATH 'inputs/departments.csv' INTO TABLE departments;

📌 Step 7: Run Hive Queries in Hue
write the following queries into the Hue Query Editor and execute them.

1️⃣ Retrieve all employees who joined after 2015
SELECT * FROM employees WHERE year(join_date) > 2015;

2️⃣ Find the average salary of employees in each department
SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department;

3️⃣ Identify employees working on the 'Alpha' project
SELECT * FROM employees WHERE project = 'Alpha';

4️⃣ Count the number of employees in each job role
SELECT job_role, COUNT(*) AS count FROM employees GROUP BY job_role;

5️⃣ Retrieve employees whose salary is above the average salary of their department
SELECT e.emp_id, e.name, e.salary, e.department
FROM employees e
JOIN (SELECT department, AVG(salary) AS avg_salary FROM employees GROUP BY department) dept_avg
ON e.department = dept_avg.department
WHERE e.salary > dept_avg.avg_salary;

6️⃣ Find the department with the highest number of employees
SELECT department, COUNT(*) AS emp_count
FROM employees
GROUP BY department
ORDER BY emp_count DESC
LIMIT 1;

7️⃣ Check for employees with null values in any column and exclude them
SELECT * FROM employees
WHERE emp_id IS NOT NULL 
AND name IS NOT NULL 
AND age IS NOT NULL 
AND job_role IS NOT NULL 
AND salary IS NOT NULL 
AND project IS NOT NULL 
AND join_date IS NOT NULL 
AND department IS NOT NULL;

8️⃣ Join employees and departments to display employee details along with department locations
SELECT e.emp_id, e.name, e.job_role, e.salary, e.project, e.join_date, e.department, d.location
FROM employees e
JOIN departments d 
ON e.department = d.department_name;

9️⃣ Rank employees within each department based on salary
SELECT emp_id, name, department, salary, 
RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM employees;

🔟 Find the top 3 highest-paid employees in each department
SELECT emp_id, name, department, salary 
FROM (
    SELECT emp_id, name, department, salary,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
    FROM employees
) ranked_employees
WHERE rank <= 3;