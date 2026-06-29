WITH cleaned AS (
    SELECT COALESCE(NULLIF(UPPER(TRIM(first_name)),''), 'UNKNOWN') AS First_name, 
        IFNULL(UPPER(TRIM(last_name)), 'UNKNOWN') AS Last_name, 
        UPPER(TRIM(department)) AS Department, 
        IFNULL(UPPER(TRIM(job_title)), 'UNKNOWN') AS Job_Title, 
        CASE WHEN UPPER(employment_type) LIKE '%FULL-TIME%' THEN 'FULL TIME'
            WHEN UPPER(employment_type) LIKE '%CONTRACT%' THEN 'CONTRACT'
            WHEN UPPER(employment_type) LIKE '%PART-TIME%' THEN 'PART TIME'
        END AS Employment_Type, 
        COALESCE(CAST(salary AS NUMERIC), 0) AS Salary, 
        COALESCE(performance_score, 0) AS Performance_Score,
        UPPER(TRIM(city)) AS City,
        COALESCE(email, 'UNKNOWN') AS Email,
        CASE WHEN CAST(salary AS INT) < 60000 THEN 'Junior'
            WHEN CAST(salary AS INT) BETWEEN 60000 AND 85000 THEN 'Mid Level'
            WHEN CAST(salary AS INT) > 85000 THEN 'Senior'
            ELSE 'UNKNOWN'
        END AS Salary_band
    FROM studies101.default.messy_employees
)
SELECT First_name, 
        Last_name, 
        Department, 
        Job_Title,
        Employment_type, 
        Salary,
        Performance_Score, 
        City, 
        Email, 
        Salary_band
FROM cleaned;
