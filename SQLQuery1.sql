USE master;
GO

IF DB_ID('hospital_db') IS NOT NULL
BEGIN
    ALTER DATABASE hospital_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE hospital_db;
END;
GO

CREATE DATABASE hospital_db;
GO

USE hospital_db;
GO

CREATE TABLE Residence (
    residence_id INT IDENTITY(1,1) PRIMARY KEY,
    country VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    address_line VARCHAR(255) NOT NULL,
    living_condition VARCHAR(100)
);
GO

CREATE TABLE Patient (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    national_id VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    residence_id INT,
    CONSTRAINT FK_Patient_Residence
        FOREIGN KEY (residence_id) REFERENCES Residence(residence_id)
);
GO

CREATE TABLE Staff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    department VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Vaccination (
    vaccination_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    dose_number INT NOT NULL,
    vaccination_date DATE NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    CONSTRAINT FK_Vaccination_Patient
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);
GO

CREATE TABLE RiskFactor (
    risk_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    condition_name VARCHAR(100) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    notes VARCHAR(255),
    CONSTRAINT FK_RiskFactor_Patient
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);
GO

CREATE TABLE ContactRecord (
    contact_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    contacted_patient_id INT NOT NULL,
    contact_date DATE NOT NULL,
    contact_type VARCHAR(100) NOT NULL,
    duration_minutes INT NOT NULL,
    risk_level VARCHAR(50) NOT NULL,
    CONSTRAINT FK_ContactRecord_Patient
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_ContactRecord_Contacted
        FOREIGN KEY (contacted_patient_id) REFERENCES Patient(patient_id)
);
GO

CREATE TABLE HospitalVisit (
    visit_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    staff_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE,
    department VARCHAR(100) NOT NULL,
    reason_for_visit VARCHAR(255),
    CONSTRAINT FK_HospitalVisit_Patient
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_HospitalVisit_Staff
        FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);
GO

CREATE TABLE Lab_Test (
    test_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    staff_id INT NOT NULL,
    test_type VARCHAR(100) NOT NULL,
    virus_name VARCHAR(100) NOT NULL,
    test_date DATE NOT NULL,
    result VARCHAR(50) NOT NULL,
    CONSTRAINT FK_LabTest_Patient
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_LabTest_Staff
        FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);
GO

CREATE TABLE VirusStatus (
    status_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    virus_name VARCHAR(100) NOT NULL,
    current_status VARCHAR(50) NOT NULL,
    quarantine_status VARCHAR(50) NOT NULL,
    status_date DATE NOT NULL,
    CONSTRAINT FK_VirusStatus_Patient
        FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);
GO

CREATE INDEX idx_patient_name
ON Patient(first_name, last_name);
GO

CREATE INDEX idx_lab_test_date
ON Lab_Test(test_date);
GO

CREATE INDEX idx_vaccination_name
ON Vaccination(vaccine_name);
GO

CREATE INDEX idx_virusstatus_patient
ON VirusStatus(patient_id);
GO


CREATE TRIGGER trg_after_lab_test_insert
ON Lab_Test
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO VirusStatus (patient_id, virus_name, current_status, quarantine_status, status_date)
    SELECT 
        i.patient_id,
        i.virus_name,
        'Infected',
        'Required',
        CAST(GETDATE() AS DATE)
    FROM inserted i
    WHERE i.result = 'Positive';
END;
GO

CREATE VIEW HighRiskInfected AS
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    v.virus_name,
    v.current_status,
    r.condition_name,
    r.severity
FROM Patient p
JOIN VirusStatus v ON p.patient_id = v.patient_id
JOIN RiskFactor r ON p.patient_id = r.patient_id
WHERE v.current_status = 'Infected';
GO

SELECT * FROM HighRiskInfected;
GO

USE hospital_db;
GO

CREATE PROCEDURE GetPatientHistory
    @pid INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM Patient WHERE patient_id = @pid;
    SELECT * FROM Vaccination WHERE patient_id = @pid;
    SELECT * FROM Lab_Test WHERE patient_id = @pid;
    SELECT * FROM VirusStatus WHERE patient_id = @pid;
    SELECT * FROM RiskFactor WHERE patient_id = @pid;
    SELECT * FROM HospitalVisit WHERE patient_id = @pid;
    SELECT * 
    FROM ContactRecord
    WHERE patient_id = @pid OR contacted_patient_id = @pid;
END;
GO

EXEC GetPatientHistory @pid = 1;
GO

USE hospital_db;
GO

CREATE ROLE doctor_role;
GO

GRANT SELECT, INSERT, UPDATE ON Patient TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON Vaccination TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON Lab_Test TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON VirusStatus TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON RiskFactor TO doctor_role;
GRANT SELECT, INSERT, UPDATE ON HospitalVisit TO doctor_role;
GRANT SELECT ON ContactRecord TO doctor_role;
GRANT SELECT ON Residence TO doctor_role;
GRANT SELECT ON Staff TO doctor_role;
GO

USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO Residence (country, city, district, address_line, living_condition)
SELECT
    'Armenia',
    'City' + CAST(n AS VARCHAR(10)),
    'District' + CAST(n AS VARCHAR(10)),
    'Street ' + CAST(n AS VARCHAR(10)),
    CASE 
        WHEN n % 2 = 0 THEN 'Apartment'
        ELSE 'House'
    END
FROM nums;
GO

USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO Patient (national_id, first_name, last_name, date_of_birth, gender, residence_id)
SELECT
    'NID' + CAST(1000 + n AS VARCHAR(10)),
    'Name' + CAST(n AS VARCHAR(10)),
    'Surname' + CAST(n AS VARCHAR(10)),
    DATEADD(DAY, n * 30, '1995-01-01'),
    CASE 
        WHEN n % 2 = 0 THEN 'Male'
        ELSE 'Female'
    END,
    n
FROM nums;
GO

SELECT COUNT(*) AS total_patients FROM Patient;
GO

USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO Staff (full_name, role, department)
SELECT
    'Staff ' + CAST(n AS VARCHAR(10)),
    CASE 
        WHEN n % 3 = 0 THEN 'Doctor'
        WHEN n % 3 = 1 THEN 'Nurse'
        ELSE 'Lab Technician'
    END,
    CASE 
        WHEN n % 4 = 0 THEN 'Cardiology'
        WHEN n % 4 = 1 THEN 'Emergency'
        WHEN n % 4 = 2 THEN 'Laboratory'
        ELSE 'General Medicine'
    END
FROM nums;
GO

SELECT COUNT(*) AS total_staff FROM Staff;
GO


USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO Vaccination (patient_id, vaccine_name, dose_number, vaccination_date, batch_number)
SELECT
    n,
    CASE 
        WHEN n % 3 = 0 THEN 'Pfizer'
        WHEN n % 3 = 1 THEN 'Moderna'
        ELSE 'Sputnik V'
    END,
    (n % 3) + 1,
    DATEADD(DAY, n, '2024-01-01'),
    'BATCH' + CAST(1000 + n AS VARCHAR(10))
FROM nums;
GO

SELECT COUNT(*) AS total_vaccinations FROM Vaccination;
GO

USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO RiskFactor (patient_id, condition_name, severity, notes)
SELECT
    n,
    CASE 
        WHEN n % 4 = 0 THEN 'Diabetes'
        WHEN n % 4 = 1 THEN 'Asthma'
        WHEN n % 4 = 2 THEN 'Heart Disease'
        ELSE 'Hypertension'
    END,
    CASE 
        WHEN n % 3 = 0 THEN 'High'
        WHEN n % 3 = 1 THEN 'Medium'
        ELSE 'Low'
    END,
    'Risk note for patient ' + CAST(n AS VARCHAR(10))
FROM nums;
GO

SELECT COUNT(*) AS total_risk_factors FROM RiskFactor;
GO

USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO ContactRecord (
    patient_id,
    contacted_patient_id,
    contact_date,
    contact_type,
    duration_minutes,
    risk_level
)
SELECT
    n,
    CASE 
        WHEN n = 50 THEN 1
        ELSE n + 1
    END,
    DATEADD(DAY, n, '2025-01-01'),
    CASE 
        WHEN n % 2 = 0 THEN 'Close'
        ELSE 'Casual'
    END,
    10 + n,
    CASE 
        WHEN n % 3 = 0 THEN 'High'
        WHEN n % 3 = 1 THEN 'Medium'
        ELSE 'Low'
    END
FROM nums;
GO

SELECT COUNT(*) AS total_contacts FROM ContactRecord;
GO

USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO HospitalVisit (
    patient_id,
    staff_id,
    admission_date,
    discharge_date,
    department,
    reason_for_visit
)
SELECT
    n,
    n,
    DATEADD(DAY, n, '2025-02-01'),
    DATEADD(DAY, n + 2, '2025-02-01'),
    CASE 
        WHEN n % 4 = 0 THEN 'Cardiology'
        WHEN n % 4 = 1 THEN 'Emergency'
        WHEN n % 4 = 2 THEN 'Laboratory'
        ELSE 'General Medicine'
    END,
    CASE 
        WHEN n % 3 = 0 THEN 'Routine Checkup'
        WHEN n % 3 = 1 THEN 'Fever'
        ELSE 'Infection Monitoring'
    END
FROM nums;
GO

SELECT COUNT(*) AS total_visits FROM HospitalVisit;
GO

USE hospital_db;
GO

;WITH nums AS (
    SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO Lab_Test (
    patient_id,
    staff_id,
    test_type,
    virus_name,
    test_date,
    result
)
SELECT
    n,
    n,
    CASE 
        WHEN n % 2 = 0 THEN 'PCR'
        ELSE 'Antigen'
    END,
    CASE 
        WHEN n % 2 = 0 THEN 'COVID-19'
        ELSE 'Influenza'
    END,
    DATEADD(DAY, n, '2025-03-01'),
    CASE 
        WHEN n % 3 = 0 THEN 'Positive'
        ELSE 'Negative'
    END
FROM nums;
GO

SELECT COUNT(*) AS total_lab_tests FROM Lab_Test;
GO

SELECT COUNT(*) AS total_virus_status FROM VirusStatus;
GO

USE hospital_db;
GO

INSERT INTO VirusStatus (
    patient_id,
    virus_name,
    current_status,
    quarantine_status,
    status_date
)
SELECT
    patient_id,
    'COVID-19',
    'Recovered',
    'Not Required',
    '2025-04-01'
FROM Patient
WHERE patient_id <= 30;

SELECT COUNT(*) AS total_virus_status FROM VirusStatus;
GO

SELECT COUNT(*) AS total_virus_status FROM VirusStatus;
GO

USE hospital_db;
GO

SELECT * FROM Patient;
GO

SELECT first_name, last_name FROM Patient;
GO

SELECT * FROM Patient WHERE gender = 'Female';
GO

SELECT * FROM Patient WHERE gender = 'Male';
GO

SELECT * FROM Vaccination WHERE dose_number >= 2;
GO

SELECT * FROM Lab_Test WHERE result = 'Positive';
GO

SELECT * FROM Lab_Test WHERE result = 'Negative';
GO

SELECT DISTINCT virus_name FROM Lab_Test;
GO

SELECT * FROM RiskFactor WHERE severity = 'High';
GO

SELECT * FROM ContactRecord WHERE risk_level = 'High';
GO

SELECT p.first_name, p.last_name, r.condition_name
FROM Patient p
JOIN RiskFactor r ON p.patient_id = r.patient_id;
GO

SELECT p.first_name, p.last_name, v.current_status
FROM Patient p
JOIN VirusStatus v ON p.patient_id = v.patient_id;
GO

SELECT * FROM HospitalVisit WHERE department = 'Emergency';
GO

SELECT * FROM Patient ORDER BY last_name;
GO

SELECT * FROM Patient WHERE date_of_birth > '2000-01-01';
GO

SELECT * FROM Lab_Test ORDER BY test_date DESC;
GO

SELECT p.patient_id, p.first_name, COUNT(v.vaccination_id) AS vaccination_count
FROM Patient p
LEFT JOIN Vaccination v ON p.patient_id = v.patient_id
GROUP BY p.patient_id, p.first_name;
GO

SELECT * FROM ContactRecord WHERE duration_minutes > 30;
GO

SELECT * FROM VirusStatus WHERE quarantine_status = 'Required';
GO

SELECT * FROM Patient WHERE patient_id IN (SELECT patient_id FROM RiskFactor);
GO

SELECT * FROM Patient WHERE patient_id NOT IN (SELECT patient_id FROM Vaccination);
GO

SELECT * FROM Patient WHERE first_name LIKE 'Name1%';
GO

SELECT * FROM Lab_Test WHERE test_type = 'PCR';
GO

SELECT p.first_name, l.result
FROM Patient p
JOIN Lab_Test l ON p.patient_id = l.patient_id;
GO

SELECT COUNT(*) AS total_contacts FROM ContactRecord;
GO

SELECT AVG(duration_minutes) AS avg_contact_duration FROM ContactRecord;
GO

SELECT * FROM HighRiskInfected;
GO

SELECT department, COUNT(*) AS total_visits
FROM HospitalVisit
GROUP BY department;
GO

SELECT role, COUNT(*) AS total_staff
FROM Staff
GROUP BY role;
GO

EXEC GetPatientHistory @pid = 5;
GO