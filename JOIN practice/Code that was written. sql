WITH cleaned_students AS (
    SELECT student_id, 
        TRIM(INITCAP(student_name)) AS Student_Name, 
        COALESCE(NULLIF(student_email, ''), 'No Email') AS Student_Email,
        date_of_birth AS Date_Of_Birth, 
        TRIM(UPPER(gender)) AS Gender,
        COALESCE(NULLIF(phone_number, ''), '0') AS Phone_Number,
        TRIM(UPPER(city)) AS City,
        enrollment_date AS Enrollment_Date,
        ----labelling membership tiers
        CASE WHEN UPPER(membership_tier) LIKE '%GOLD%' THEN 'Gold Tier'
            WHEN UPPER(membership_tier) LIKE '%SILVER%' THEN 'Silver Tier'
            WHEN UPPER(membership_tier) LIKE '%BRONZE%' THEN 'Bronze Tier'
            ELSE 'Unknown'
        END AS Membership_Tier,
        TRIM(UPPER(status)) AS Status
    FROM studies101.joint_practice.students
),
    cleaned_enrolment AS (
        SELECT enrollment_id AS Enrollment_ID,
            student_id AS Student_ID,
            course_id AS Course_ID,
            enrollment_date AS Enrollment_Date,
            ----labelling completion status
            CASE WHEN UPPER(completion_status) LIKE '%COMPLETED%' THEN 'Completed'
                    WHEN UPPER(completion_status) LIKE '%IN PROGRESS%' THEN 'In Progress'
                    ELSE 'Cancelled'
            END AS Completion_Status,
            IFNULL(grade, 'In Progress') AS Grade,
            IFNULL(score,0) AS Score,
            TRIM(UPPER(payment_status)) AS Payment_Status,
            -----Labelling payment Method
            CASE WHEN UPPER(payment_method) LIKE '%DEBIT CARD%' THEN 'Debit Card'
                 WHEN UPPER(payment_method) LIKE '%CREDIT CARD%' THEN 'Credit Card'
                ELSE 'Cash'
            END AS Payment_Method,
            discount_applied AS Discount_Applied, 
            COALESCE(final_fee, 0) AS Final_Fee, 
            ROW_NUMBER() OVER (
            PARTITION BY student_id, 
                        course_id
            ORDER BY enrollment_id ASC) AS row_num
        FROM studies101.joint_practice.enrolments
), 
    cleaned_courses AS (
        SELECT course_id AS Course_ID,
            TRIM(INITCAP(course_name)) AS Course_Name,
            TRIM(UPPER(department)) AS Department,
            TRIM(INITCAP(instructor_name)) AS Instructor_Name,
            TRY_CAST(duration_weeks AS INT) AS Duration_Weeks,
            course_fee AS Course_Fee,
            TRIM(UPPER(level)) AS Level, 
            max_students AS Max_Students, 
            start_date AS Start_Date
        FROM studies101.joint_practice.courses
            
)
    SELECT s.student_id,
            s.Student_Name, 
            s.Student_Email,
            s.Date_Of_Birth,
            s.Gender,
            s.Phone_Number,
            s.City,
            s.Enrollment_Date,
            s.Membership_Tier,
            s.Status,
            e.Enrollment_ID,
            e.Course_ID,
            e.Enrollment_Date,
            e.Completion_Status,
            e.Grade,
            e.Score,
            e.Payment_Status,
            e.Payment_Method,
            e.Discount_Applied,
            e.Final_Fee,
            c.Course_ID,
            c.Course_Name,
            c.Department,
            c.Instructor_Name,
            c.Duration_Weeks,
            c.Course_Fee,
            c.Level,
            c.Max_Students,
            c.Start_Date,
            SUM(CAST(e.Final_Fee AS INT)) AS Final_Fee, 
            -----This is to measure the score students got
            CASE WHEN e.Score >= 90 THEN 'Distinction'
                WHEN e.Score BETWEEN 75 AND 89 THEN 'Merit'
                WHEN e.Score BETWEEN 50 AND 74 THEN 'Pass'
                WHEN e.Score < 50 THEN 'Fail'
                ELSE 'In Progress'
            END AS Performance_Band,
            ----This is place a fee band
            CASE WHEN e.Final_Fee < 1500 THEN 'Budget'
                WHEN e.Final_Fee BETWEEN 1500 AND 2500 THEN 'Standard'
                WHEN e.Final_Fee > 2500 THEN 'Premium'
                ELSE 'In Progress'
            END AS Fee_Band      
    FROM cleaned_students AS s
    INNER JOIN cleaned_enrolment AS e
    INNER JOIN cleaned_courses AS c 
    ON s.student_id = e.student_id
    AND e.Course_ID = c.Course_ID
    WHERE e.row_num = 1             -- deduplication applied here
    GROUP BY s.student_id,
            s.Student_Name, 
            s.Student_Email,
            s.Date_Of_Birth,
            s.Gender,
            s.Phone_Number,
            s.City,
            s.Enrollment_Date,
            s.Membership_Tier,
            s.Status,
            e.Enrollment_ID,
            e.student_id,
            e.Course_ID,
            e.Enrollment_Date,
            e.Completion_Status,
            e.Grade,
            e.Score,
            e.Payment_Status,
            e.Payment_Method,
            e.Discount_Applied,
            e.Final_Fee,
            c.Course_ID,
            c.Course_Name,
            c.Department,
            c.Instructor_Name,
            c.Duration_Weeks,
            c.Course_Fee,
            c.Level,
            c.Max_Students,
            c.Start_Date
    ORDER BY s.Student_Name ASC;
