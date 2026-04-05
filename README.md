# Hospital Pandemic Management Database System

A relational database project for managing hospital data during infectious disease outbreaks.  
This system stores patient information, vaccination records, laboratory test results, infection status, risk factors, contact tracing records, and hospital visits. It was implemented in **Microsoft SQL Server / SSMS** using T-SQL. The project script creates the database, tables, indexes, trigger, view, stored procedure, role permissions, sample data, and analytical queries. Based on the uploaded SQL script. filecite turn2file0
## Project Features

- Patient data management
- Residence and demographic tracking
- Staff management
- Vaccination history
- Laboratory test records
- Virus status monitoring
- Risk factor tracking
- Contact tracing between patients
- Hospital visit management
- View for high-risk infected patients
- Trigger for automatic virus status update
- Stored procedure for patient history
- Role-based access control
- Sample data generation with more than 40 rows per table
- Analytical and reporting SQL queries

## Technologies Used

- **Database Management System:** Microsoft SQL Server
- **Environment:** SQL Server Management Studio (SSMS)
- **Language:** T-SQL

## Database Schema

The system includes the following tables:

- `Residence`
- `Patient`
- `Staff`
- `Vaccination`
- `RiskFactor`
- `ContactRecord`
- `HospitalVisit`
- `Lab_Test`
- `VirusStatus`

### Main Relationships

- A patient belongs to one residence
- A patient can have many vaccinations
- A patient can have many lab tests
- A patient can have many virus status records
- A patient can have many risk factors
- A patient can have many hospital visits
- A patient can be connected to other patients through contact records
- A staff member can handle many hospital visits
- A staff member can perform many lab tests

## Included SQL Objects

### Tables
The script creates all core relational tables with primary keys and foreign keys.

### Indexes
Indexes are created to improve query performance on commonly used columns such as:

- patient name
- lab test date
- vaccination name
- virus status patient ID

### Trigger
`trg_after_lab_test_insert`

Automatically inserts a record into `VirusStatus` when a newly inserted lab test result is `Positive`.

### View
`HighRiskInfected`

Displays patients who are both infected and have registered risk factors.

### Stored Procedure
`GetPatientHistory`

Returns all related information for a given patient, including:

- basic patient information
- vaccinations
- lab tests
- virus status
- risk factors
- hospital visits
- contact records

### Role / Access Control
`doctor_role`

Permissions granted include:

- `SELECT`
- `INSERT`
- `UPDATE`

for the main medical tables.

## How to Run

1. Open **SQL Server Management Studio (SSMS)**.
2. Connect to your SQL Server instance.
3. Open the SQL script file.
4. Run the script step by step or execute the full script in order.
5. The script will:
   - create the `hospital_db` database
   - create all tables
   - create indexes
   - create the trigger
   - create the view
   - create the stored procedure
   - create the role and grant permissions
   - insert sample data
   - run analytical queries

## Sample Analytical Queries

The project includes example queries for:

- retrieving all patients
- filtering patients by gender
- finding positive and negative lab tests
- listing patients with high risk factors
- finding patients with required quarantine
- counting contact records
- calculating average contact duration
- grouping hospital visits by department
- grouping staff by role
- retrieving patient history with the stored procedure

## Example Execution

### Run the stored procedure
```sql
EXEC GetPatientHistory @pid = 5;
```

### Use the view
```sql
SELECT * FROM HighRiskInfected;
```

## Data Volume

The script inserts **more than 40 records per table**, satisfying the project requirement for sample data generation. The SQL script uses set-based inserts and generated rows for testing and demonstration. fileciteturn2file0

## Project Structure Suggestion

```text
Hospital-Pandemic-Database/
│── SQLQuery1.sql
│── README.md
│── ERD.png
│── Report.docx
```

## Academic Scope

This project covers the main stages of database development:

- requirements analysis
- conceptual design
- logical design
- normalization
- physical implementation
- advanced SQL features
- access control
- analytical querying

## Author Notes

This project was developed as a database modeling and implementation assignment. It demonstrates the use of relational database principles for healthcare-oriented data management and outbreak monitoring.

## License

This project is for educational and academic use.
