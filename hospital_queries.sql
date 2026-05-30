-- STEP 1: Create your database
CREATE DATABASE healthcare_db;

-- STEP 2: Create the main table
CREATE TABLE patient_data (
    patient_id VARCHAR(10),
    patient_name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    blood_group VARCHAR(5),
    city VARCHAR(50),
    admission_date DATE,
    discharge_date DATE,
    length_of_stay_days INT,
    department VARCHAR(50),
    diagnosis VARCHAR(50),
    disease_category VARCHAR(50),
    treatment_type VARCHAR(50),
    admission_type VARCHAR(20),
    doctor_name VARCHAR(100),
    bed_number INT,
    room_type VARCHAR(20),
    insurance_type VARCHAR(50),
    total_bill_amount_inr NUMERIC,
    insurance_covered_inr NUMERIC,
    out_of_pocket_inr NUMERIC,
    treatment_cost_inr NUMERIC,
    medication_cost_inr NUMERIC,
    lab_test_cost_inr NUMERIC,
    readmitted_within_30_days VARCHAR(5),
    recovery_rate_percent INT,
    patient_satisfaction_score NUMERIC,
    outcome VARCHAR(20)
);
select * from patient_data;
-- STEP 3: Import CSV (change the path to where your CSV is saved)(note it)
COPY patient_data
FROM 'C:/Users/SAMSUNG/Desktop/Data_Analyst/HealthCareProjectEndToEnd/patient_data.csv'
DELIMITER ','
CSV HEADER;

-- Basic Join & Patient Summary (using CTE)
-- CTE: Clean patient summary
WITH patient_summary AS (
    SELECT 
        patient_id,
        patient_name,
        age,
        gender,
        department,
        diagnosis,
        disease_category,
        length_of_stay_days,
        total_bill_amount_inr,
        insurance_covered_inr,
        out_of_pocket_inr,
        recovery_rate_percent,
        readmitted_within_30_days,
        outcome
    FROM patient_data
    WHERE admission_date >= '2022-01-01'
)
SELECT * FROM patient_summary
ORDER BY total_bill_amount_inr DESC;

--Department KPIs (Window Function)
-- Department-wise performance with ranking
SELECT 
    department,
    COUNT(*) AS total_patients,
    ROUND(AVG(length_of_stay_days), 2) AS avg_length_of_stay,
    ROUND(AVG(total_bill_amount_inr), 2) AS avg_treatment_cost,
    ROUND(AVG(recovery_rate_percent), 2) AS avg_recovery_rate,
    SUM(CASE WHEN readmitted_within_30_days = 'Yes' THEN 1 ELSE 0 END) AS readmissions,
    ROUND(
        100.0 * SUM(CASE WHEN readmitted_within_30_days = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS readmission_rate_pct,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS dept_rank_by_volume
FROM patient_data
GROUP BY department
ORDER BY total_patients DESC;

--Monthly Admission Trend
-- Monthly admissions trend analysis
SELECT 
    EXTRACT(YEAR FROM admission_date) AS year,
    EXTRACT(MONTH FROM admission_date) AS month,
    TO_CHAR(admission_date, 'Mon-YYYY') AS month_label,
    COUNT(*) AS total_admissions,
    ROUND(AVG(total_bill_amount_inr), 0) AS avg_bill,
    SUM(total_bill_amount_inr) AS total_revenue
FROM patient_data
GROUP BY year, month, month_label
ORDER BY year, month;

--Age Group vs Diagnosis Heatmap Data
-- Age group bucketing
SELECT 
    CASE 
        WHEN age < 18 THEN '0-17 (Child)'
        WHEN age BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN age BETWEEN 36 AND 55 THEN '36-55 (Middle Age)'
        WHEN age BETWEEN 56 AND 70 THEN '56-70 (Senior)'
        ELSE '70+ (Elderly)'
    END AS age_group,
    diagnosis,
    COUNT(*) AS patient_count
FROM patient_data
GROUP BY age_group, diagnosis
ORDER BY age_group, patient_count DESC;

-- Insurance vs Out-of-Pocket Analysis
-- Billing analysis by insurance type
SELECT 
    insurance_type,
    COUNT(*) AS total_patients,
    ROUND(AVG(total_bill_amount_inr), 0) AS avg_total_bill,
    ROUND(AVG(insurance_covered_inr), 0) AS avg_insurance_covered,
    ROUND(AVG(out_of_pocket_inr), 0) AS avg_out_of_pocket,
    ROUND(100.0 * AVG(insurance_covered_inr) / NULLIF(AVG(total_bill_amount_inr), 0), 1) AS coverage_pct
FROM patient_data
GROUP BY insurance_type
ORDER BY avg_total_bill DESC;


