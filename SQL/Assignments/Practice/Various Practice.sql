CREATE TABLE Customer (
CustID CHAR(3) NOT NULL,
CustNameFirst VARCHAR(20),
CustNameLast VARCHAR(20),
AnnualRevenune INT(11),
CustType VARCHAR(1),
CONSTRAINT CustomerID_PK PrimaryKey (CustID));

CREATE TABLE Package (
Shipment_NO VARCHAR(4) NOT NULL,
CustID CHAR(3) NOT NULL,
Weight Int(4),
TruckNo CHAR(3), NOT NULL,
CityID CHAR(3) NOT NULL,
ShipDate DATE,
CONSTRAINT PackageID_PK PrimaryKey (Shipment_NO)
CONSTRAINT PackageCust_FK ForeignKey (CustID) REFERENCES CUSTOMER(CustID)
CONSTRAINT PackageTruck_FK ForeignKey (TruckNo) REFERENCES TRUCK(TruckNo)
CONSTRAINT PackageCity_FK ForeignKey (CityID) REFERENCES CITYNAME(CityID));

CREATE TABLE TRUCK (
TruckNo CHAR(3), NOT NULL,
DriverNameFirst VARCHAR(20),
DriverNameLast VARCHAR(20),
SupervisorNameFirst, VARCHAR(20),
SupervisorLastName, VARCHAR(20)
Constraint TruckID_PK PrimaryKey (TruckNo));

CREATE TABLE CITYNAME (
CityID CHAR(3) NOT NULL,
CityName VARCHAR(25),
POPULATION INT
Constraint CityNameID_PK PrimaryKey (CityID));

DROP TABLE PACKAGE;
DROP TABLE CUSTOMER;
DROP TABLE TRUCK;
DROP TABLE CITY;

CREATE TABLE PACKAGE (
SHIPMENT_NO DECIMAL(4,0) NOT NULL,
CUSTID           DECIMAL(3,0) NOT NULL,
WEIGHT           DECIMAL(6,2) CHECK (WEIGHT > 0),
TRUCK_NO   DECIMAL(3,0) /*DEFAULT 100*/ NOT NULL, --TRUCK_NO   DECIMAL(3,0) DEFAULT 100 NOT NULL
CITYID           DECIMAL(3,0),
SHIPDATE   DATE  /*CHECK (SHIPDATE > GETDATE()-1)*/,
CONSTRAINT Package_PK PRIMARY KEY (SHIPMENT_NO, CUSTID),
CONSTRAINT Package_Cust_FK FOREIGN KEY (CUSTID) REFERENCES CUSTOMER(CUSTID)
ON UPDATE CASCADE ON DELETE NO ACTION,
CONSTRAINT Package_Truck_FK FOREIGN KEY (TRUCK_NO) REFERENCES TRUCK (TRUCK_NO)
ON UPDATE CASCADE ON DELETE NO ACTION,
CONSTRAINT Package_City_FK FOREIGN KEY (CITYID) REFERENCES CITY (CITYID)
ON UPDATE CASCADE ON DELETE NO ACTION) ;
--cascade, no action, set null, set default

--CREATE INDEX I1_IDX ON Inventory (Name) ;

INSERT INTO CUSTOMER VALUES (100, 'SPECIFIC MODELS', 9000000, 1);

INSERT INTO PACKAGE VALUES (1777, 112, 30, 100, 103, '10-DEC-2012');

/*Specify which Columns:
	INSERT INTO Inventory (ID, Name) VALUES (9999, 'No Name'); 
Or Specify Nulls:
	INSERT INTO Inventory VALUES (1 , 'Fish' , 'Gills' , NULL);
	INSERT INTO Inventory VALUES (1 , 'Fish' , 'Gills', '');
*Numeric nulls MUST use NULL, alphanumeric can use either NULL or ‘’
*/

/*ALTER TABLE Inventory ALTER COLUMN annualrevenues varchar (15);
ALTER TABLE Inventory DROP COLUMN annualrevenues;
ALTER TABLE Inventory DROP InvOrder_Comp_PK;
ALTER TABLE Inventory ADD
CONSTRAINT Inventory_ID_PK PRIMARY KEY (ID);
*/

--Update Tables
UPDATE PACKAGE
SET WEIGHT = WEIGHT/2.2

SELECT WEIGHT/2.2 AS WeightInKg
FROM PACKAGE

--DELETE FROM Inventory
--WHERE Name = 'Kitty';

--SELECT CAST (animal AS VARCHAR(10)) FROM customer
--SELECT CAST ((SalesYTD/CommissPct) as DECIMAL (10,1)

/*
5	SELECT  	columns
1	FROM		tables
2	WHERE	conditions
3	GROUP BY	columns
4	HAVING	conditions
6	ORDER BY	columns  ORDER BY Name DESC;*/ 



--1. Which shipments were delivered by multiple drivers?
SELECT SHIPMENT_NO
FROM PACKAGE
GROUP BY SHIPMENT_NO
HAVING COUNT(DISTINCT TRUCK_NO) > 1;
--1 Row, shipments 1775

--2. For how many different customers has each driver delivered packages?
SELECT PACKAGE.TRUCK_NO, DRIVERNAME, COUNT(DISTINCT CUSTID) AS 'Num of Customers'
FROM PACKAGE INNER JOIN TRUCK
ON PACKAGE.TRUCK_NO = TRUCK.TRUCK_NO
GROUP BY PACKAGE.TRUCK_NO, DRIVERNAME;
--7 Rows

--3. Which cities have had at least two shipments sent to them?
SELECT CITYNAME, COUNT(DISTINCT SHIPMENT_NO) AS NumOfShipments
FROM PACKAGE INNER JOIN CITY
ON PACKAGE.CITYID = CITY.CITYID
GROUP BY CITYNAME
HAVING COUNT(DISTINCT SHIPMENT_NO) >= 2;
--1 Rows

--4. Which customer has sent the most packages?
SELECT CUSTNAME, COUNT(SHIPMENT_NO) AS NumOfPkgs
FROM PACKAGE, CUSTOMER
WHERE PACKAGE.CUSTID = CUSTOMER.CUSTID
GROUP BY CUSTNAME;


SELECT MAX(NumOfPkgs)
FROM (SELECT CUSTNAME, COUNT(SHIPMENT_NO) AS NumOfPkgs
	FROM PACKAGE, CUSTOMER
	WHERE PACKAGE.CUSTID = CUSTOMER.CUSTID
	GROUP BY CUSTNAME) AS TopShipments;

SELECT CUSTNAME AS NAME, COUNT(SHIPMENT_NO) AS PkgsSent
FROM CUSTOMER INNER JOIN PACKAGE
	ON CUSTOMER.CUSTID = PACKAGE.CUSTID
GROUP BY CUSTNAME
HAVING COUNT(SHIPMENT_NO) >=
		(SELECT MAX(NumOfPkgs)
FROM (SELECT CUSTNAME, COUNT(SHIPMENT_NO) AS NumOfPkgs
	FROM PACKAGE, CUSTOMER
	WHERE PACKAGE.CUSTID = CUSTOMER.CUSTID
	GROUP BY CUSTNAME) AS TopShipments);
--1 Row

--3
SELECT CUSTID, COUNT(SHIPMENT_NO) AS 'Number of Packages'
FROM PACKAGE
GROUP BY CUSTID;

--4
SELECT TRUCK_NO, COUNT(SHIPMENT_NO) AS 'No Of Shipments'
FROM PACKAGE
GROUP BY TRUCK_NO;

--5
SELECT TRUCK_NO, COUNT (DISTINCT SHIPMENT_NO) 'No Of Shipments'
FROM PACKAGE
GROUP BY TRUCK_NO;

--7
SELECT CUSTID, COUNT(SHIPMENT_NO) AS 'No of Packages'
FROM PACKAGE
GROUP BY CUSTID
HAVING COUNT(SHIPMENT_NO) < 2;

--10. Which cities have not been shipped to?
SELECT CITY.CITYID, CITYNAME
FROM CITY, PACKAGE
WHERE CITY.CITYID = PACKAGE.CITYID

--records that have a match in both tables
SELECT DISTINCT CITY.CITYID, CITYNAME 
FROM CITY INNER JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID

--records that match and records in the left side table that do not match
SELECT CITY.CITYID, CITYNAME
FROM CITY LEFT JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
WHERE SHIPMENT_NO IS NULL

--records that match and records in the right side table that do not have matches on the left
SELECT CITY.CITYID, CITYNAME
FROM CITY RIGHT JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID

SELECT CITY.CITYID, CITYNAME, SHIPMENT_NO, CUSTNAME
FROM CITY RIGHT JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
INNER JOIN CUSTOMER
ON PACKAGE.CUSTID = CUSTOMER.CUSTID

--self join
/*
SELECT e.employeeid, e.lastname,e.reportsto, m.lastname
FROM employees e, employees m
WHERE e.reportsto=m.employeeid

SELECT e.employeeid, e.lastname, e.reportsto, m.lastname
FROM employees e 
LEFT JOIN employees m
ON e.reportsto=m.employeeid */


--SQL 3
--1. What are the names of customers who have sent packages to Baltimore?
SELECT CUSTNAME
FROM CUSTOMER, PACKAGE, CITY
WHERE CUSTOMER.CUSTID = PACKAGE.CUSTID AND PACKAGE.CITYID = CITY.CITYID AND CITY.CITYID = '111';

--2. To what destinations have customers with revenue less than $30 million sent packages?
SELECT DISTINCT CITY.CITYNAME
FROM CUSTOMER, PACKAGE, CITY
WHERE CUSTOMER.CUSTID = PACKAGE.CUSTID AND PACKAGE.CITYID = CITY.CITYID AND CUSTOMER.ANNUALREVENUE < 30000000;

SELECT DISTINCT CITY.CITYNAME
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
INNER JOIN CITY
ON PACKAGE.CITYID = CITY.CITYID
WHERE CUSTOMER.ANNUALREVENUE < 30000000;

--5. Who are the retail customers (names) who have sent packages weighing up to 45 pounds or have sent a 
--package to Bloomington?

SELECT CUSTNAME, WEIGHT, CITYNAME
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID= PACKAGE.CITYID
INNER JOIN CITY
ON PACKAGE.CITYID = CITY.CITYID
WHERE WEIGHT <= 45 OR CITYNAME = 'BLOOMINGTON';

SELECT CUSTNAME, WEIGHT, CITYNAME
FROM CUSTOMER, PACKAGE, CITY
WHERE CUSTOMER.CUSTID= PACKAGE.CITYID
AND PACKAGE.CITYID = CITY.CITYID
AND (WEIGHT <= 45
OR CITYNAME = 'BLOOMINGTON');


--7. List the cities that have received packages from customers having less than $15 million in annual revenue.
SELECT CUSTID
FROM CUSTOMER
WHERE ANNUALREVENUE < 15000000

SELECT CITYID
FROM PACKAGE
WHERE CUSTID IN (SELECT CUSTID
	FROM CUSTOMER
	WHERE ANNUALREVENUE < 15000000)

SELECT DISTINCT CITYNAME
FROM CITY
WHERE CITYID IN (SELECT CITYID
	FROM PACKAGE
	WHERE CUSTID IN (SELECT CUSTID
	FROM CUSTOMER
	WHERE ANNUALREVENUE < 15000000))

--most prescribed medications
select count(medicine_code)NumberPrescribed
from prescription
group by medicine_code

select Max(NumberPrescribed)
from (select count(medicine_code)NumberPrescribed
	from prescription
	group by medicine_code)MostPrescribed

select med_name_common, normal_dosage, quantity_stock
from medicine inner join prescription
on medicine.medicine_code = prescription.medicine_code
group by med_name_common, normal_dosage, quantity_stock
having count(prescription.medicine_code) = (select Max(NumberPrescribed)
							from (select count(medicine_code)NumberPrescribed
							from prescription
							group by medicine_code)MostPrescribed)


--1 Patients by Specialization attending
SELECT spec_title, count(pat_id) NumberOfPatientsTreated
FROM TREATMENT RIGHT JOIN STAFF_MEDSPEC
ON TREATMENT.STAFF_ID = STAFF_MEDSPEC.STAFF_ID
RIGHT JOIN MEDICAL_SPECIALTY
ON STAFF_MEDSPEC.SPECIALTY_CODE = MEDICAL_SPECIALTY.SPECIALTY_CODE
GROUP BY SPEC_TITLE
--15 rows

--2 Wards not earning a profit
SELECT WARD_DEPT_NAME, SUM(ACTUAL_CHARGE - SERVICE_CHARGE)ProfitOrLoss, COUNT(TREATMENT_NUMBER) #OfTreatmentsByWard
FROM WARD_DEPT INNER JOIN STAFF
ON WARD_DEPT.WARD_ID = STAFF.WARD_DEPT_ASSIGNED
INNER JOIN TREATMENT
ON STAFF.STAFF_ID = TREATMENT.STAFF_ID
INNER JOIN SERVICE
ON TREATMENT.SERVICE_ID = SERVICE.SERVICE_ID
GROUP BY WARD_DEPT_NAME
HAVING SUM(ACTUAL_CHARGE - SERVICE_CHARGE) <= 0

--3 Most expensive treatment
SELECT MAX(ACTUAL_CHARGE)
FROM TREATMENT

SELECT pat_id, actual_charge MaxAmtCharged, service.service_id, service_description
FROM TREATMENT INNER JOIN SERVICE
ON TREATMENT.SERVICE_ID = SERVICE.SERVICE_ID
group by pat_id, ACTUAL_CHARGE, service.service_id, service_description
HAVING ACTUAL_CHARGE = (SELECT MAX(ACTUAL_CHARGE)
						FROM TREATMENT)

--bed assignment unavailable
SELECT PAT_ID
FROM PATIENT INNER JOIN BED
ON PATIENT.BED_NUMBER = BED.BED_NUMBER
WHERE BED_AVAILABILITY = 'N'

--patients with no prescription issued
SELECT PATIENT.PAT_ID, PAT_LAST_NAME, PAT_FIRST_NAME
FROM PATIENT LEFT JOIN PRESCRIPTION
ON PATIENT.PAT_ID = PRESCRIPTION.PAT_ID
WHERE PRE_NUMBER IS NULL



--Items not appearing in a list

SELECT CITY.CITYID, CITYNAME
FROM CITY LEFT JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
WHERE PACKAGE.CITYID IS NULL

SELECT CITYNAME
FROM CITY LEFT JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
WHERE SHIPMENT_NO IS NULL


--WHERE ColumnName IN ('....')
--WHERE ColumnName NOT IN ('....')

--Wildcard criteria, etc.

--WHERE Name LIKE 'Jo%'	includes John, Joe, etc.
--WHERE Name LIKE 'Jo_'	includes Joe – NOT Jo

--Displaying Maximums
SELECT CUSTNAME, SUM(WEIGHT) TotalShipped
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
GROUP BY CUSTNAME

SELECT MAX(TotalShipped)
FROM (SELECT CUSTNAME, SUM(WEIGHT) TotalShipped
	FROM CUSTOMER INNER JOIN PACKAGE
	ON CUSTOMER.CUSTID = PACKAGE.CUSTID
	GROUP BY CUSTNAME) MaxShipped;

SELECT CUSTNAME, SUM(WEIGHT) MostShippedByWeight
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
GROUP BY CUSTNAME
HAVING SUM(WEIGHT) = (SELECT MAX(TotalShipped)
	FROM (SELECT CUSTNAME, SUM(WEIGHT) TotalShipped
	FROM CUSTOMER INNER JOIN PACKAGE
	ON CUSTOMER.CUSTID = PACKAGE.CUSTID
	GROUP BY CUSTNAME) MaxShipped);
