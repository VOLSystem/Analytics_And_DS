--1. What are the names of customers who have sent packages to Baltimore?
SELECT CUSTNAME
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
INNER JOIN CITY
ON PACKAGE.CITYID = CITY.CITYID
WHERE CITY.CITYNAME = 'Baltimore';

SELECT CUSTNAME
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
INNER JOIN CITY
ON PACKAGE.CITYID = CITY.CITYID
WHERE CITY.CITYNAME IN ('Baltimore');

--2. To what destinations have customers with revenue less than $30 million sent packages?
SELECT DISTINCT CITYNAME
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
INNER JOIN CITY
ON PACKAGE.CITYID = CITY.CITYID
WHERE ANNUALREVENUE < 30000000;

--3. What are the names and populations of cities that have received packages weighing over 70 pounds?
SELECT DISTINCT CITYNAME, POPULATION
FROM CITY INNER JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
WHERE WEIGHT > 70

--4. Who are the customers (names) having over $20 million in annual revenue who have sent packages weighing less than 50 pounds?
SELECT CUSTNAME
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
WHERE ANNUALREVENUE > 20000000 AND WEIGHT < 50

-- 5. Who are the retail customers (names) who have sent packages weighing up to 45 pounds or have sent a package to Bloomington?
SELECT CUSTNAME
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
INNER JOIN CITY
ON PACKAGE.CITYID = CITY.CITYID
WHERE WEIGHT <= 45 AND CITYNAME IN ('Bloomington');

--6. Who are the drivers who have delivered packages for customers with annual revenue over $20 million to cities with populations over 1 million?
SELECT DISTINCT DRIVERNAME
FROM CITY INNER JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
INNER JOIN TRUCK
ON PACKAGE.TRUCK_NO = TRUCK.TRUCK_NO
INNER JOIN CUSTOMER
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
WHERE (ANNUALREVENUE > 20000000) AND (POPULATION > 1000000);

--7. List the cities that have received packages from customers having less than $15 million in annual revenue.
SELECT DISTINCT CITYNAME
FROM CITY INNER JOIN PACKAGE
ON CITY.CITYID = PACKAGE.CITYID
INNER JOIN CUSTOMER
ON PACKAGE.CUSTID = CUSTOMER.CUSTID
WHERE ANNUALREVENUE < 15000000;

--8. List the names of drivers who have delivered packages weighing over 90 pounds.
SELECT DRIVERNAME
FROM PACKAGE INNER JOIN TRUCK
ON PACKAGE.TRUCK_NO = TRUCK.TRUCK_NO
WHERE WEIGHT > 90;

--9. List the name and annual revenue of customers who have sent packages weighing at least than 70 pounds.
SELECT CUSTNAME, ANNUALREVENUE
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
WHERE WEIGHT >= 70;

--10. List the name and annual revenue of customers whose packages have been delivered by Jones.
SELECT CUSTNAME, ANNUALREVENUE
FROM CUSTOMER INNER JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
INNER JOIN TRUCK
ON PACKAGE.TRUCK_NO = TRUCK.TRUCK_NO
WHERE DRIVERNAME = 'Jones';

--11. Provide details for the package(s) that weigh the most.
SELECT MAX(WEIGHT)
FROM PACKAGE;

SELECT *
FROM PACKAGE
WHERE WEIGHT = (SELECT MAX(WEIGHT)
				FROM PACKAGE);



--12. In terms of annual revenue, list the name of our smallest customer(s)?
SELECT MIN(ANNUALREVENUE)
FROM CUSTOMER

SELECT CUSTNAME
FROM CUSTOMER
WHERE ANNUALREVENUE = (SELECT MIN(ANNUALREVENUE)
						FROM CUSTOMER);

--13. Which customers (provide names) have not yet shipped anything?
SELECT CUSTNAME
FROM CUSTOMER LEFT JOIN PACKAGE
ON CUSTOMER.CUSTID = PACKAGE.CUSTID
WHERE PACKAGE.CUSTID IS NULL;

--14. What is the average annual revenue of our customers who are type 3?
SELECT AVG(ANNUALREVENUE)
FROM CUSTOMER
WHERE CUSTTYPE = '3';

--15. Provide a list of the truck drivers and the customers each has truck driver has delivered to.
SELECT DRIVERNAME, CUSTNAME
FROM TRUCK INNER JOIN PACKAGE
ON TRUCK.TRUCK_NO = PACKAGE.TRUCK_NO
INNER JOIN CUSTOMER
ON PACKAGE.CUSTID = CUSTOMER.CUSTID