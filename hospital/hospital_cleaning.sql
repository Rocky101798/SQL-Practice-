WITH CLEANED AS ( 
    SELECT patient_id,
        admission_id,
        TRIM(INITCAP(patient_name)) AS Patient_name, 
        COALESCE(NULLIF(patient_email, ''), 'No Email') AS Patient_Email, 
        TRIM(INITCAP(doctor_name)) AS Doctor_name,
        UPPER(department) AS Department, 
        TRIM(INITCAP(diagnosis)) AS Diagnosis, 
        COALESCE(admission_date, '1900-01-01') AS Admission_Date, 
        COALESCE(discharge_date, '1900-01-01') AS Discharge_Date,
        IFNULL(num_days, 0) AS Num_Days,
        TRIM(INITCAP(ward)) AS Ward, 
        TRY_CAST(treatment_cost AS INT) AS Treatment_Cost, 
        IFNULL(TRY_CAST(insurance_covered AS INT), 0) AS Insurance_Covered, 

        --status label
        CASE WHEN UPPER(payment_status) LIKE '%PAID%' THEN 'Paid'
            WHEN UPPER(payment_status) LIKE '%PENDING%' THEN 'Pending'
            ELSE 'Unknown'
        END AS Payment_Status,
        ----Payment labels
        CASE WHEN UPPER(payment_method) LIKE '%CREDIT CARD%' THEN 'Credit Card'
            WHEN UPPER(payment_method) LIKE '%DEBIT CARD%' THEN 'Debit Card'
            WHEN UPPER(payment_method) LIKE '%CASH%' THEN 'Cash'
            ELSE 'Unknown'
        END AS Payment_Method,

        TRIM(INITCAP(medication)) AS Medication,
        dosage AS Dosage, 
        TRIM(INITCAP(nurse_assigned)) AS Nurse_Assigned,
        TRIM(UPPER(hospital_branch)) AS Hospital_Branch,
        
        ---patient status
        CASE WHEN UPPER(patient_status) LIKE '%DISCHARGED%' THEN 'Discharged'
            WHEN UPPER(patient_status) LIKE '%ADMITTED%' THEN 'Admitted'
            ELSE 'Unknown'
        END AS Patient_Status
    FROM studies101.default.hospital_data
        
), deduped AS (
    SELECT *, 
    ROW_NUMBER() OVER(
            PARTITION BY patient_id,
                        Diagnosis,
                        Admission_Date
            ORDER BY admission_id ASC --keep the lowest transaction_id
        ) AS row_num
    FROM CLEANED
) 
   SELECT patient_id, 
        admission_id, 
        Patient_Name, 
        Patient_Email,
        Doctor_name, 
        Department, 
        Diagnosis, 
        Admission_Date, 
        Discharge_Date,
        Num_Days, 
        Ward, 
        Treatment_Cost,
        Insurance_Covered, 
        Payment_Status, 
        Payment_Method,
        Medication,
        Dosage, 
        Nurse_Assigned,
        Hospital_Branch, 
        Patient_Status,
    ---out of pocket calculation
        TRY_CAST(treatment_cost AS INT) - IFNULL(TRY_CAST(insurance_covered AS INT), 0) AS Out_Of_Pocket, 
    ----Cost band
    CASE WHEN Treatment_Cost < 1000 THEN 'Low Cost'
        WHEN Treatment_Cost BETWEEN 1000 AND 5000 THEN 'Medium Cost'
        WHEN Treatment_Cost > 5000 THEN 'High Cost'
        ELSE 'Unknown'
    END AS Cost_Band, 
    ------Coverage band
    CASE WHEN Insurance_Covered = 0 THEN 'No Coverage'
        WHEN Insurance_Covered < Treatment_Cost * 0.5 THEN 'Partial Coverage'
        ELSE 'Good Coverage'
    END AS Coverage_Band
    FROM deduped
    WHERE row_num = 1
    ORDER BY admission_id ASC;
