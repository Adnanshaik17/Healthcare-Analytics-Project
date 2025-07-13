CREATE DATABASE HEALTHCARE_PROJECT;

SP_RENAME 'encounters (1)', 'encounters';

SELECT * FROM encounters;
SELECT * FROM organizations;
SELECT * FROM Patients;
SELECT * FROM Payers;
SELECT * FROM procedures;

-- Primary keys
ALTER TABLE encounters
ADD CONSTRAINT PK_encounters PRIMARY KEY (Id);

ALTER TABLE organizations
ADD CONSTRAINT PK_organizations PRIMARY KEY (Id);

ALTER TABLE payers
ADD CONSTRAINT PK_payers PRIMARY KEY (Id);

ALTER TABLE patients
ADD CONSTRAINT PK_patients PRIMARY KEY (Id);



-- Foreign keys
ALTER TABLE encounters
ADD CONSTRAINT FK_encounters_patients FOREIGN KEY (Patient) REFERENCES patients(Id);

ALTER TABLE encounters
ADD CONSTRAINT FK_encounters_payers FOREIGN KEY (Payer) REFERENCES payers(Id);

ALTER TABLE encounters
ADD CONSTRAINT FK_encounters_organizations FOREIGN KEY (Organization) REFERENCES organizations(Id);

ALTER TABLE procedures
ADD CONSTRAINT FK_procedures_patients FOREIGN KEY (Patient) REFERENCES patients(Id);

ALTER TABLE procedures
ADD CONSTRAINT FK_procedures_encounters FOREIGN KEY (Encounter) REFERENCES encounters(Id);

--Checking Duplicates for each table

SELECT Id, COUNT(*) 
FROM encounters 
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT Id, COUNT(*) 
FROM patients
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT Id, COUNT(*) 
FROM organizations
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT Id, COUNT(*) 
FROM payers
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT Encounter, Code, COUNT(*) AS DuplicateCount
FROM procedures
GROUP BY Encounter, Code
HAVING COUNT(*) > 1;

SELECT * FROM procedures
Where Encounter = '6a885401-fed3-37d0-9249-0591b28f2388';

--Here we found duplicates on procedures table, so we need to remove duplicates

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Encounter, Code ORDER BY (SELECT NULL)) AS rn
    FROM procedures
)
DELETE FROM CTE
WHERE rn > 1;

--Checking Null values

SELECT 
  COUNT(*) AS TotalRows,
  SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) AS Null_Id,
  SUM(CASE WHEN Patient IS NULL THEN 1 ELSE 0 END) AS Null_Patient,
  SUM(CASE WHEN Organization IS NULL THEN 1 ELSE 0 END) AS Null_Organization,
  SUM(CASE WHEN Payer IS NULL THEN 1 ELSE 0 END) AS Null_Payer,
  SUM(CASE WHEN EncounterClass IS NULL THEN 1 ELSE 0 END) AS Null_EncounterClass,
  SUM(CASE WHEN Start IS NULL THEN 1 ELSE 0 END) AS Null_Start,
  SUM(CASE WHEN Stop IS NULL THEN 1 ELSE 0 END) AS Null_Stop,
  SUM(CASE WHEN Total_Claim_Cost IS NULL THEN 1 ELSE 0 END) AS Null_TotalClaimCost,
  SUM(CASE WHEN Base_Encounter_Cost IS NULL THEN 1 ELSE 0 END) AS Null_BaseCost,
  SUM(CASE WHEN Payer_Coverage IS NULL THEN 1 ELSE 0 END) AS Null_PayerCoverage,
  SUM(CASE WHEN ReasonCode IS NULL THEN 1 ELSE 0 END) AS Null_ReasonCode,
  SUM(CASE WHEN ReasonDescription IS NULL THEN 1 ELSE 0 END) AS Null_ReasonDescription
FROM encounters;

SELECT 
  COUNT(*) AS TotalRows,
  SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) AS Null_Id,
  SUM(CASE WHEN BirthDate IS NULL THEN 1 ELSE 0 END) AS Null_BirthDate,
  SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Null_Gender,
  SUM(CASE WHEN Race IS NULL THEN 1 ELSE 0 END) AS Null_Race,
  SUM(CASE WHEN Ethnicity IS NULL THEN 1 ELSE 0 END) AS Null_Ethnicity,
  SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_City,
  SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Null_State
FROM patients;

SELECT 
  COUNT(*) AS TotalRows,
  SUM(CASE WHEN Encounter IS NULL THEN 1 ELSE 0 END) AS Null_Encounter,
  SUM(CASE WHEN Code IS NULL THEN 1 ELSE 0 END) AS Null_Code,
  SUM(CASE WHEN Patient IS NULL THEN 1 ELSE 0 END) AS Null_Patient,
  SUM(CASE WHEN Start IS NULL THEN 1 ELSE 0 END) AS Null_Start,
  SUM(CASE WHEN Stop IS NULL THEN 1 ELSE 0 END) AS Null_Stop,
  SUM(CASE WHEN Base_Cost IS NULL THEN 1 ELSE 0 END) AS Null_BaseCost,
  SUM(CASE WHEN ReasonCode IS NULL THEN 1 ELSE 0 END) AS Null_ReasonCode,
  SUM(CASE WHEN ReasonDescription IS NULL THEN 1 ELSE 0 END) AS Null_ReasonDescription
FROM procedures;

SELECT 
  COUNT(*) AS TotalRows,
  SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) AS Null_Id,
  SUM(CASE WHEN Name IS NULL THEN 1 ELSE 0 END) AS Null_Name,
  SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_City,
  SUM(CASE WHEN State_Headquartered IS NULL THEN 1 ELSE 0 END) AS Null_State,
  SUM(CASE WHEN Phone IS NULL THEN 1 ELSE 0 END) AS Null_Phone
FROM payers;

SELECT 
  COUNT(*) AS TotalRows,
  SUM(CASE WHEN Id IS NULL THEN 1 ELSE 0 END) AS Null_Id,
  SUM(CASE WHEN Name IS NULL THEN 1 ELSE 0 END) AS Null_Name,
  SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_City,
  SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Null_State,
  SUM(CASE WHEN LAT IS NULL THEN 1 ELSE 0 END) AS Null_LAT,
  SUM(CASE WHEN LON IS NULL THEN 1 ELSE 0 END) AS Null_LON
FROM organizations;


--BUSINESS REQUIREMENTS

--1.Evaluating Financial Risk by Encounter Outcome
--Determine which ReasonCodes lead to the highest financial risk based on the total uncovered cost 
--(difference between total claim cost and payer coverage). Analyze this by combining 
--patient demographics and encounter outcomes.

SELECT 
    e.ReasonCode,
    e.ReasonDescription,
    p.Gender,
    DATEDIFF(YEAR, p.BirthDate, GETDATE()) AS Age,
    e.EncounterClass,
    SUM(e.Total_Claim_Cost - e.Payer_Coverage) AS UncoveredCost
FROM encounters e
JOIN patients p ON e.Patient = p.Id
WHERE e.ReasonCode IS NOT NULL
GROUP BY 
    e.ReasonCode, e.ReasonDescription,
    p.Gender,
    DATEDIFF(YEAR, p.BirthDate, GETDATE()),
    e.EncounterClass
ORDER BY UncoveredCost DESC;


--2.Identifying Patients with Frequent High-Cost Encounters
--Identify patients who had more than 3 encounters in a year 
--where each encounter had a total claim cost above a certain threshold (e.g., $10,000). 
--The query should return the patient details, number of encounters, and the total cost for those encounters.

SELECT e.Patient, e.DESCRIPTION,
    COUNT(*) AS HighCostEncounterCount,
    SUM(e.Total_Claim_Cost) AS TotalHighCost,
    p.Gender, concat(p.FIRST,' ', p.LAST) AS Patient_Name,
    DATEDIFF(YEAR, p.BirthDate, GETDATE()) AS Age,
    p.City,
    p.State
FROM encounters e
JOIN patients p ON e.Patient = p.Id
WHERE 
    e.Total_Claim_Cost > 10000
GROUP BY 
    e.Patient, 
	e.DESCRIPTION,
    p.Gender, 
	concat(p.FIRST,' ', p.LAST),
    DATEDIFF(YEAR, p.BirthDate, GETDATE()), 
    p.City, 
    p.State
HAVING 
    COUNT(*) > 3
ORDER BY 
    TotalHighCost DESC;

--Removing numbers in first and last name

UPDATE patients
SET first = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                  first, '0', ''), '1', ''), '2', ''), '3', ''),
                  '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', '');

UPDATE patients
SET last = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                  last, '0', ''), '1', ''), '2', ''), '3', ''),
                  '4', ''), '5', ''), '6', ''), '7', ''), '8', ''), '9', '');



--3.Identifying Risk Factors Based on Demographics and Encounter Reasons
--Analyze the top 3 most frequent diagnosis codes (ReasonCodes) and the associated patient demographic data to 
--understand which groups are most affected by high-cost encounters.

WITH Top3Reasons AS (
    SELECT TOP 3 ReasonCode
    FROM encounters
    WHERE ReasonCode IS NOT NULL
    GROUP BY ReasonCode
    ORDER BY COUNT(*) DESC
)
SELECT TOP 3 
    e.Id AS EncounterID,
    e.ReasonCode,
    e.ReasonDescription,
    e.Patient,
    p.Gender,
    DATEDIFF(YEAR, p.BirthDate, GETDATE()) AS Age,
    e.EncounterClass,
    e.Total_Claim_Cost,
    e.Payer_Coverage,
    (e.Total_Claim_Cost - e.Payer_Coverage) AS UncoveredCost
FROM encounters e
JOIN Top3Reasons t ON e.ReasonCode = t.ReasonCode
JOIN patients p ON e.Patient = p.Id
WHERE e.Total_Claim_Cost IS NOT NULL AND e.Payer_Coverage IS NOT NULL
ORDER BY UncoveredCost DESC;

--4.Assessing Payer Contributions for Different Procedure Types
--Analyze payer contributions for the base cost of procedures and identify any gaps between total claim cost and payer coverage.

SELECT 
    pr.Code AS ProcedureCode,
    pr.Description AS ProcedureDescription,
    COUNT(*) AS ProcedureCount,
    SUM(pr.Base_Cost) AS TotalProcedureCost,
    SUM(e.Total_Claim_Cost) AS TotalClaimCost,
    SUM(e.Payer_Coverage) AS TotalPayerCoverage,
    SUM(e.Total_Claim_Cost - e.Payer_Coverage) AS TotalUncoveredCost
FROM procedures pr
JOIN encounters e ON pr.Encounter = e.Id
WHERE pr.Base_Cost IS NOT NULL AND e.Payer_Coverage IS NOT NULL
GROUP BY pr.Code, pr.Description
ORDER BY TotalUncoveredCost DESC;

--5.Identifying Patients with Multiple Procedures Across Encounters
--Find patients who had multiple procedures across different encounters with the same ReasonCode. 

WITH ProcWithReason AS (
    SELECT 
        e.Patient,
        e.ReasonCode,
		e.Description,
        pr.Code AS ProcedureCode,
        pr.Encounter
    FROM procedures pr
    JOIN encounters e ON pr.Encounter = e.Id
    WHERE e.ReasonCode IS NOT NULL
)

SELECT 
    Patient,
    ReasonCode,
	description,
    COUNT(DISTINCT Encounter) AS DistinctEncounters,
    COUNT(DISTINCT ProcedureCode) AS DistinctProcedures
FROM ProcWithReason
GROUP BY Patient, ReasonCode, description
HAVING 
    COUNT(DISTINCT Encounter) > 1 AND
    COUNT(DISTINCT ProcedureCode) > 1
ORDER BY DistinctProcedures DESC;

--6.Analyzing Patient Encounter Duration for Different Classes
--Calculate the average encounter duration for each class (EncounterClass) per organization,
--identifying any encounters that exceed 24 hours.



-- Step 1: Analyze average duration per class and organization

SELECT 
    e.Organization,
    o.Name AS OrganizationName,
    e.EncounterClass,
    COUNT(*) AS EncounterCount,
    AVG(DATEDIFF(HOUR, e.Start, e.Stop)) AS AvgDurationHours
FROM encounters e
JOIN organizations o ON e.Organization = o.Id
WHERE e.Start IS NOT NULL AND e.Stop IS NOT NULL
GROUP BY e.Organization, o.Name, e.EncounterClass
ORDER BY AvgDurationHours DESC;

-- Step 2: Find encounters exceeding 24 hours
SELECT 
    e.Id AS EncounterID,
    e.Patient,
    o.Name AS OrganizationName,
    e.EncounterClass,
    e.Start,
    e.Stop,
    DATEDIFF(HOUR, e.Start, e.Stop) AS DurationHours
FROM encounters e
JOIN organizations o ON e.Organization = o.Id
WHERE 
    e.Start IS NOT NULL AND 
    e.Stop IS NOT NULL AND 
    DATEDIFF(HOUR, e.Start, e.Stop) > 24
ORDER BY DurationHours ;


