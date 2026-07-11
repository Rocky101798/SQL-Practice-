# 📊 SQL Practice — Data Cleaning & Analysis

A collection of SQL practice projects focused on real-world data 
cleaning, transformation, and analysis using Databricks and 
Google BigQuery.

---

## 🛠️ Tools & Platforms

- **Databricks** — Primary SQL environment
- **Google BigQuery** — Secondary SQL environment  
- **GitHub** — Version control and portfolio showcase

---

## 📁 Repository Structure

| Folder | Files |
|---|---|
| **Employees Dataset** | `messy_employees.csv` `cleaning_queries.sql` `README.md` |
| **Hospital Dataset** | `messy_hospital.csv` `cleaning_queries.sql` `README.md` |
| **Hotel Dataset** | `messy_hotel.csv` `cleaning_queries.sql` `README.md` |
| **JOIN Practice** | `students.csv` `courses.csv` `enrollments.csv` `employees.csv` `salaries.csv` `join_queries.sql` `README.md` |

---

## 🧹 Cleaning Functions Practiced

| Function | Purpose |
|---|---|
| `TRIM()` | Remove leading and trailing whitespace |
| `UPPER()` | Normalize text to uppercase |
| `LOWER()` | Normalize text to lowercase |
| `INITCAP()` | Capitalize first letter of each word |
| `NULLIF()` | Convert empty strings to proper NULLs |
| `COALESCE()` | Replace NULLs with default values |
| `IFNULL()` | Single fallback NULL replacement |
| `CAST()` | Convert columns to correct data types |
| `TRY_CAST()` | Safe type conversion without crashing |
| `SAFE_CAST()` | BigQuery equivalent of TRY_CAST |
| `CASE` | Standardize inconsistent category values |
| `ROW_NUMBER()` | Identify and remove duplicate rows |

---

## 🔗 SQL Concepts Covered

### Data Cleaning
- Removing leading and trailing whitespace
- Normalizing inconsistent text casing
- Handling NULL values and empty strings
- Converting text columns to correct data types
- Standardizing inconsistent category values
- Detecting and removing duplicate records

### CTEs (Common Table Expressions)
- Single CTEs for cleaner queries
- Chained CTEs for multi-step pipelines
- Three CTE pipelines combining cleaning
  and deduplication
- Clean first, deduplicate second pattern

### Window Functions
- `ROW_NUMBER()` with `PARTITION BY`
- `OVER()` clause for grouped calculations
- Deduplication using `QUALIFY` on Databricks

### JOINs
- `INNER JOIN` — matching records only
- `LEFT JOIN` — all records from left table
- Two table JOIN pipelines
- Three table JOIN pipelines
- JOIN combined with GROUP BY and aggregations

### Aggregations
- `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
- `GROUP BY` with cleaned columns
- `HAVING` for filtering grouped results
- Aggregations across joined tables

---

## 📂 Datasets Overview

### 🏢 Employees Dataset
Practice cleaning a 30-row employee dataset
covering departments, salaries, job titles
and employment types.

**Key cleaning challenges:**
- Mixed case department names
- Whitespace in employee names
- Missing performance scores
- Inconsistent employment type labels

---

### 🏥 Hospital Dataset
Practice cleaning a 50-row hospital admissions
dataset with patient records, diagnoses,
treatment costs and insurance information.

**Key cleaning challenges:**
- Duplicate patient admissions
- Missing admission and discharge dates
- NULL handling in PARTITION BY
- Cost calculations with missing insurance data

---

### 🏨 Hotel Dataset
Practice cleaning a 30-row hotel bookings
dataset covering room types, stay durations,
loyalty tiers and payment records.

**Key cleaning challenges:**
- Inconsistent room type naming
- Missing checkout dates
- Loyalty tier standardization
- Stay value and coverage tier calculations

---

### 🔗 JOIN Practice

**Students, Courses & Enrollments (3 tables)**
Three-table JOIN pipeline connecting students
to their course enrollments and course details.

**Employees & Salaries (2 tables)**
Two-table JOIN pipeline connecting employee
records to their salary and payment information.

**Key JOIN concepts practiced:**
- INNER JOIN vs LEFT JOIN behaviour
- Identifying unmatched records
- Deduplication before joining
- Aggregations across joined tables
- Calculated columns in the final SELECT

---

## 🏗️ Pipeline Pattern Used

Every cleaning project follows this structure:

```sql
-- CTE 1: Clean the data first
WITH cleaned AS (
    SELECT
        TRIM(INITCAP(name))                      AS name,
        COALESCE(NULLIF(email, ''), 'No Email')  AS email,
        COALESCE(TRY_CAST(salary AS DECIMAL), 0) AS salary,
        CASE
            WHEN UPPER(status) = 'ACTIVE' THEN 'Active'
            ELSE 'Inactive'
        END                                      AS status
    FROM raw_table
),

-- CTE 2: Deduplicate on clean values
deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY id, date
            ORDER BY record_id ASC
        ) AS row_num
    FROM cleaned
)

-- Final SELECT: calculated columns only
SELECT
    *,
    salary * 1.1 AS salary_with_raise
FROM deduped
WHERE row_num = 1;
```

---

## 💡 Key Lessons Learned

**Always clean before deduplicating**  
Dirty values like extra spaces or mixed case
cause `ROW_NUMBER()` to miss true duplicates.
Clean the data first so values match correctly
in the `PARTITION BY` clause.

**Use `TRY_CAST` over `CAST` on real data**  
`CAST` crashes when it hits an unexpected value.
`TRY_CAST` returns NULL instead, keeping the
query running safely.

**`GROUP BY` must match `SELECT` exactly**  
Any transformation applied in `SELECT` must be
repeated identically in `GROUP BY`, otherwise
SQL groups on the original dirty values.

**`COALESCE` vs `IFNULL`**  
Both replace NULLs but `COALESCE` accepts
multiple fallback values while `IFNULL` only
accepts one. Use `COALESCE` when you have
multiple fallback options.

**NULL does not equal NULL in `PARTITION BY`**  
When deduplicating on a nullable column, wrap
it with `COALESCE` first so NULL values match
each other correctly across duplicate rows.

---

## 👤 Author

**Siphamandla M.**  
Junior Data Analyst  
Practicing SQL for data cleaning, transformation
and analysis across multiple platforms.

---

## 📌 Status

🟢 Active — regularly updated with new datasets
and SQL concepts as I continue learning.
