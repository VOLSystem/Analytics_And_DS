--1. Which shipments were delivered by multiple drivers?
SELECT SHIPMENT_NO
FROM PACKAGE
GROUP BY SHIPMENT_NO
HAVING COUNT(DISTINCT TRUCK_NO) > 1;
--1 Row, shipment 1775

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
--1 Row, Bloomington

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
--Cardinal Precision

--5. Which drivers delivered packages either after October 15, 2011 and before December 31,
--2011 or to customers who were of type 2?

SELECT DRIVERNAME, SHIPDATE, CUSTTYPE
FROM TRUCK INNER JOIN PACKAGE
ON TRUCK.TRUCK_NO = PACKAGE.TRUCK_NO
	INNER JOIN CUSTOMER
	ON PACKAGE.CUSTID = CUSTOMER.CUSTID
WHERE (SHIPDATE > '15-Oct-2011' and SHIPDATE <	 '31-Dec-2011') OR CUSTTYPE = 2;
--6 rows

--6. How many customers of each type have sent packages to each city?
SELECT CITYNAME, CUSTTYPE, SUM(CUSTTYPE) AS NumOfPkgs
FROM CITY INNER JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
	INNER JOIN CUSTOMER
	ON PACKAGE.CUSTID = CUSTOMER.CUSTID
GROUP BY CITYNAME, CUSTTYPE;
--12 rows

--7. Which driver delivered the package that weighs the least?
SELECT MIN(WEIGHT) AS LowestWeight
FROM PACKAGE;

SELECT DRIVERNAME, WEIGHT
FROM PACKAGE INNER JOIN TRUCK
ON PACKAGE.TRUCK_NO = TRUCK.TRUCK_NO
GROUP BY DRIVERNAME, WEIGHT
HAVING WEIGHT = (SELECT MIN(WEIGHT) AS LowestWeight
	FROM PACKAGE);
--Driver: Ferris

--8. Which driver delivered the shipment that weighs the most?
SELECT MAX(WEIGHT) AS MaxWeight
FROM PACKAGE

SELECT DRIVERNAME, WEIGHT
FROM TRUCK INNER JOIN PACKAGE
ON TRUCK.TRUCK_NO = PACKAGE.TRUCK_NO
GROUP BY DRIVERNAME, WEIGHT
HAVING WEIGHT = (SELECT MAX(WEIGHT) AS MaxWeight
FROM PACKAGE);
--Driver: Topi

--9. Which shipments weigh more than the average for all shipments?
SELECT SHIPMENT_NO, SUM(WEIGHT) AS TotalWeight
FROM PACKAGE
GROUP BY SHIPMENT_NO;

SELECT AVG(TotalWeight)
FROM (SELECT SHIPMENT_NO, SUM(WEIGHT) AS TotalWeight
	FROM PACKAGE
	GROUP BY SHIPMENT_NO) AS AvgWeight;

SELECT SHIPMENT_NO, SUM(WEIGHT) AS TotalShippingWeight
FROM PACKAGE
GROUP BY SHIPMENT_NO
HAVING SUM(WEIGHT) > (SELECT AVG(TotalWeight)
	FROM (SELECT SHIPMENT_NO, SUM(WEIGHT) AS TotalWeight
		FROM PACKAGE
		GROUP BY SHIPMENT_NO) AS AvgWeight);
--2 rows

--10. Which drivers have delivered more than the average number of packages carried by all
--drivers (who have carried packages, do not include drivers who have carried no packages)?

SELECT TRUCK_NO, COUNT(TRUCK_NO) PkgsCarried
FROM PACKAGE
GROUP BY TRUCK_NO

SELECT AVG(PkgsCarried)
FROM (SELECT TRUCK_NO, COUNT(TRUCK_NO) PkgsCarried
	FROM PACKAGE
	GROUP BY TRUCK_NO) AvgPkgsPerDriver

SELECT DRIVERNAME, COUNT(TRUCK.TRUCK_NO) NumOfDeliveries
FROM TRUCK INNER JOIN PACKAGE
ON TRUCK.TRUCK_NO = PACKAGE.TRUCK_NO
GROUP BY DRIVERNAME
HAVING COUNT(TRUCK.TRUCK_NO) > (SELECT AVG(PkgsCarried)
FROM (SELECT TRUCK_NO, COUNT(TRUCK_NO) PkgsCarried
	FROM PACKAGE
	GROUP BY TRUCK_NO) AvgPkgsPerDriver);
--3 rows
