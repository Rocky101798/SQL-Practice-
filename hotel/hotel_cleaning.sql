WITH cleaned AS (
    SELECT booking_id AS Booking_ID, 
    COALESCE(NULLIF(TRIM(INITCAP(guest_name)),''), 'No Name') AS Guest_Name,
    COALESCE(NULLIF(LOWER(guest_email), ''), 'No Email') AS Guest_Emails,
    TRIM(INITCAP(room_type)) AS Room_Type,
    IFNULL(CAST(check_in_date AS STRING), 'No_Date') AS Check_In_Date,
    IFNULL(CAST(check_out_date AS STRING), 'No_Date') AS Check_Out_Date,
    IFNULL(num_nights, 1) AS Num_Nights,
    room_rate AS Room_Rate,
    COALESCE(total_amount, 0) AS Total_Amounts,

      --stay bands 
    CASE WHEN CAST(room_rate AS DECIMAL) * IFNULL(CAST(num_nights AS INT), 1) < 300 THEN 'Budget Stay'
        WHEN CAST(room_rate AS DECIMAL) * IFNULL(CAST(num_nights AS INT), 1) BETWEEN 300 AND 1000 THEN 'Standard Stay'
        WHEN CAST(room_rate AS DECIMAL) * IFNULL(CAST(num_nights AS INT), 1) > 1000 THEN 'Premium Stay'
        ELSE 'Unknown'
    END AS Stay_Category,

    --booking status
    CASE WHEN UPPER(booking_status) LIKE '%CONFIRMED%' THEN 'Confirmed'
            WHEN UPPER(booking_status) LIKE '%CANCELLED%' THEN 'Cancelled'
            ELSE 'Unknown'
    END AS Booking_Status,

    --payment status
    CASE WHEN UPPER(payment_status) LIKE '%PAID%' THEN 'Paid'
            WHEN UPPER(payment_status) LIKE '%PENDING%' THEN 'Pending'
            WHEN UPPER(payment_status) LIKE '%REFUNDED%' THEN 'Refunded'
            ELSE 'Unknown'
    END AS Payment_Status,

    --payment method
    CASE WHEN UPPER(payment_method) LIKE '%CREDIT CARD%' THEN 'Credit Card'
            WHEN UPPER(payment_method) LIKE '%DEBIT CARD%' THEN 'Debit Card'
            WHEN UPPER(payment_method) LIKE '%CASH%' THEN 'Cash'
            ELSE 'Unknown'
        END AS Payment_Method,
    TRIM(INITCAP(hotel_location)) AS Hotel_Location,
    TRIM(INITCAP(staff_member)) AS Staff_Member, 
      
      --loyalty statuses 
    CASE WHEN UPPER(loyalty_tier) LIKE '%GOLD%' THEN 'Gold Member'
        WHEN UPPER(loyalty_tier) LIKE '%SILVER%' THEN 'Silver Member'
        WHEN UPPER(loyalty_tier) LIKE '%PLATINUM%' THEN 'Platinum Member'
        ELSE 'Standard'
    END AS Loyalty_Status
FROM studies101.default.messy_hotel

)
SELECT Booking_ID, 
    Guest_Name,
    Room_Type,
    Guest_Emails, 
    Check_In_Date,
    Check_Out_Date,
    Num_Nights, 
    Room_Rate,
    Total_Amounts, 
    Stay_Category,
    Booking_Status,
    Payment_Status, 
    Payment_Method,
    Hotel_Location, 
    Staff_Member, 
    Loyalty_Status
FROM cleaned;
