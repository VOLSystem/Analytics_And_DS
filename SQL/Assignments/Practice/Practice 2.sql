--1. How many customers do we have of each type?
SELECT CUSTTYPE, COUNT(CUSTTYPE) NumOfEach
FROM CUSTOMER
GROUP BY CUSTTYPE

--2. What is the average revenue for each type of customer?
SELECT CUSTTYPE, AVG(ANNUALREVENUE) AvgRevenue
FROM CUSTOMER
GROUP BY CUSTTYPE

--3. Provide a list showing the number of packages sent by each customer ID.
SELECT CUSTID, COUNT(SHIPMENT_NO) NumOfPkgs
FROM PACKAGE
GROUP BY CUSTID;

--4. Provide a list showing the number of packages carried by each truck_no.
SELECT TRUCK_NO, COUNT(SHIPMENT_NO) NumOfPkgs
FROM PACKAGE
GROUP BY TRUCK_NO;

--5. Provide a list showing the number of shipments carried by each truck_no.
SELECT TRUCK_NO, COUNT(DISTINCT SHIPMENT_NO) NumOfShipments
FROM PACKAGE
GROUP BY TRUCK_NO;

--6. What is the total weight and number of packages for each shipment?
SELECT SHIPMENT_NO, SUM(WEIGHT), COUNT(SHIPMENT_NO) NumOfPkgs
FROM PACKAGE
GROUP BY SHIPMENT_NO;

--7. Which customers have sent fewer than 2 packages?
SELECT CUSTID, COUNT(SHIPMENT_NO)
FROM PACKAGE
GROUP BY CUSTID
HAVING COUNT(SHIPMENT_NO) < 2;

--8. Which shipments weigh more than 75 lbs?
SELECT SHIPMENT_NO, SUM(WEIGHT) TotalWeight
FROM PACKAGE
GROUP BY SHIPMENT_NO
HAVING SUM(WEIGHT) > 75;

--9. How many shipments have gone out each month?
SELECT DATENAME(MONTH, SHIPDATE) MonthShipped, COUNT(SHIPMENT_NO) NumOfPackages
FROM PACKAGE
GROUP BY DATENAME(MONTH, SHIPDATE);

--10. Which cities have not been shipped to?
SELECT CITY.CITYID, CITYNAME
FROM CITY LEFT JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
WHERE PACKAGE.CITYID IS NULL

--11. Which packages weigh more than average?
SELECT CUSTID, SHIPMENT_NO, SUM(WEIGHT) PackageWeight
FROM PACKAGE
GROUP BY CUSTID, SHIPMENT_NO

SELECT AVG(PackageWeight)
FROM (SELECT CUSTID, SHIPMENT_NO, SUM(WEIGHT) PackageWeight
FROM PACKAGE
GROUP BY CUSTID, SHIPMENT_NO) TotalWeight;

SELECT CUSTID, SHIPMENT_NO, SUM(WEIGHT) PkgWeight
FROM PACKAGE
GROUP BY CUSTID, SHIPMENT_NO
HAVING SUM(WEIGHT) > (SELECT AVG(PackageWeight)
FROM (SELECT CUSTID, SHIPMENT_NO, SUM(WEIGHT) PackageWeight
FROM PACKAGE
GROUP BY CUSTID, SHIPMENT_NO) TotalWeight);

--12. Which shipments weigh more than average?
SELECT SHIPMENT_NO, SUM(WEIGHT) TotalWeight
FROM PACKAGE
GROUP BY SHIPMENT_NO;

SELECT AVG(TotalWeight)
FROM (SELECT SHIPMENT_NO, SUM(WEIGHT) TotalWeight
FROM PACKAGE
GROUP BY SHIPMENT_NO) TtlShpWeight;

SELECT SHIPMENT_NO, SUM(WEIGHT) ShipmentWeight
FROM PACKAGE
GROUP BY SHIPMENT_NO
HAVING SUM(WEIGHT) > (SELECT AVG(TotalWeight)
FROM (SELECT SHIPMENT_NO, SUM(WEIGHT) TotalWeight
FROM PACKAGE
GROUP BY SHIPMENT_NO) TtlShpWeight);