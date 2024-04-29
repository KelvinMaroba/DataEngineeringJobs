--
/* DATA CLEANING */
--  

USE data_jobs;

SELECT * FROM dbo.data_jobs;

--CREATE A NEW STAGING TABLE TO RUN THE SQL QUERIES AWAY FROM THE RAW DATA
--INSERT ALL OF THE DATA FROM DATA JOBS INTO DATA JOBS STAGING

CREATE TABLE data_jobs_staging(
work_year INT,
job_title NVARCHAR(50),
job_category NVARCHAR(50),
salary_currency NVARCHAR(10),
salary INT,
salary_in_usd INT,
employee_residence NVARCHAR(50),
experience_level NVARCHAR(50),
employment_type NVARCHAR(50),
work_setting NVARCHAR(50),
company_location NVARCHAR(50),
company_size NVARCHAR(10));

INSERT INTO data_jobs_staging
SELECT * FROM dbo.data_jobs;

SELECT * FROM data_jobs_staging;

--FIND AND REMOVE DUPLICATES FROM THE DATA

WITH cteDuplicates
AS
(
SELECT *,ROW_NUMBER() OVER(
PARTITION BY work_year, job_title, job_category, salary_currency, salary, salary_in_usd,
employee_residence, experience_level, employment_type, work_setting, company_location, company_size
ORDER BY work_year, job_title, job_category, salary_currency, salary, salary_in_usd,
employee_residence, experience_level, employment_type, work_setting, company_location, company_size) AS row_num
FROM data_jobs_staging
)

SELECT * FROM cteDuplicates
WHERE row_num > 1;

--VERIFY THAT DUPLICATED VALUES ARE EXACTLY THE SAME
SELECT *
FROM dbo.data_jobs
WHERE work_year = 2023 AND job_title = 'Data Engineer' AND job_category = 'Data Engineering' AND employee_residence = 'United States'
						AND experience_level = 'Senior' AND salary_in_usd = 120000 AND employment_type = 'Full-time'
						AND work_setting = 'In-person' AND company_location = 'United States' AND company_size = 'M';

--DELETE ROWS OF ROW_NUM GREATER THAN 1

WITH cteDuplicates
AS
(
SELECT *,ROW_NUMBER() OVER(
PARTITION BY work_year, job_title, job_category, salary_currency, salary, salary_in_usd,
employee_residence, experience_level, employment_type, work_setting, company_location, company_size
ORDER BY work_year, job_title, job_category, salary_currency, salary, salary_in_usd,
employee_residence, experience_level, employment_type, work_setting, company_location, company_size) AS row_num
FROM data_jobs_staging
)
DELETE
FROM cteDuplicates
WHERE row_num > 1;

SELECT * FROM data_jobs_staging;


--
/* EXPLORATORY DATA ANALYSIS  */
--


--FIND THE TOTAL NUMBER OF JOBS RECORDED
SELECT COUNT(*) AS total_number_of_jobs
FROM dbo.data_jobs_staging

--FIND THE NUMBER OF JOBS PER AFRICAN COUNTRY
SELECT company_location, count(*) AS roles_per_african_country
FROM dbo.data_jobs_staging
GROUP BY company_location
HAVING company_location IN ('South Africa', 'Ghana', 'Nigeria','Algeria','Kenya','Egypt', 
								'Cental African Republic')
ORDER BY roles_per_african_country DESC;

--FIND THE NUMBER OF JOBS PER JOB TITLE
SELECT job_title, count(*) AS roles_per_title
FROM dbo.data_jobs_staging
Group BY job_title
ORDER BY roles_per_title DESC;

--FIND THE NUMBER OF ENTRY LEVEL ROLES PER JOB TITLE
SELECT job_title, count(*) AS roles_per_title
FROM dbo.data_jobs_staging
WHERE experience_level = 'Entry-Level' 
Group BY job_title
ORDER BY roles_per_title DESC;

--FIND THE NUMBER OF ENTRY LEVEL ROLES PER JOB TITLE LOCATED IN AFRICA
SELECT job_title, count(*) AS roles_per_title
FROM dbo.data_jobs_staging
WHERE experience_level = 'Entry-Level' AND company_location IN ('South Africa', 'Ghana', 'Nigeria','Algeria','Kenya','Egypt', 
								'Cental African Republic')
Group BY job_title
ORDER BY roles_per_title DESC;

--AVERAGE SALARY BASED ON THE SUM OF ALL ROLES
SELECT AVG(salary_in_usd) AS average_salary
FROM dbo.data_jobs_staging;

--ROLES WHERE SALARY IS ABOVE AVERAGE
SELECT job_title, salary_in_usd
FROM dbo.data_jobs_staging
WHERE salary_in_usd > (
						SELECT AVG(salary_in_usd) AS average_salary
						FROM dbo.data_jobs);

--ROLE THAT HAS THE HIGEST PAY 
SELECT * 
FROM dbo.data_jobs_staging
WHERE salary_in_usd = (SELECT MAX(salary_in_usd)
						FROM dbo.data_jobs_staging);

--ROLES WITH THE LOWEST PAY
SELECT * 
FROM dbo.data_jobs_staging
WHERE salary_in_usd = (SELECT MIN(salary_in_usd)
						FROM dbo.data_jobs_staging);

--YEAR THAT HAD THE MOST ROLES AVAILABLE TO DATA PROFESSIONALS
SELECT work_year, COUNT(*) AS roles_per_year
FROM dbo.data_jobs_staging
GROUP BY work_year
ORDER BY roles_per_year DESC;

--COMPARE TOTAL AVERAGE SALARY IN UNITED STATES, UNITED KINGDOM AND GERMANY IN 2023
SELECT
	(SELECT AVG(salary_in_usd) FROM dbo.data_jobs_staging WHERE company_location = 'United States' AND work_year = 2023) AS average_salary_in_us ,
	(SELECT AVG(salary_in_usd) FROM dbo.data_jobs_staging WHERE company_location = 'United Kingdom' AND work_year = 2023) AS average_salary_in_uk,
	(SELECT AVG(salary_in_usd) FROM dbo.data_jobs_staging WHERE company_location = 'Germany' AND work_year = 2023) AS average_salary_in_germany ;


--FIND THE NUMBER OF ENTRY LEVEL JOBS PER JOB TITLE IN 2023
SELECT job_title , COUNT(*) AS count_job_titles
FROM data_jobs_staging
WHERE work_year = 2023 AND	experience_level = 'Entry-level'
GROUP BY job_title
ORDER BY count_job_titles DESC;

--FIND DISTRIBUTION ACROSS WORK SETTING WITHIN ENTRY LEVEL JOBS
SELECT work_setting , COUNT(*) AS count_work_distribution
FROM data_jobs_staging
WHERE experience_level = 'Entry-level'
GROUP BY work_setting
ORDER BY count_work_distribution DESC;

--AVERAGE SALARIES ACROSS JOB CATEGORIES FOR ENTRY LEVEL
SELECT job_category, AVG(salary_in_usd) AS average_salary
FROM dbo.data_jobs_staging
WHERE experience_level = 'Entry-Level'
GROUP BY job_category;

--COUNT ENTRY LEVEL JOBS PER COUNTRY
SELECT company_location , COUNT(*) AS count_work_location
FROM data_jobs_staging
WHERE experience_level = 'Entry-level'
GROUP BY company_location
ORDER BY count_work_location DESC;