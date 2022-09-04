--1
CREATE TABLE CUSTOMER3 (
Cust_ID CHAR(3) NOT NULL,
Cust_Name VARCHAR(15),
Region VARCHAR(2),
Phone CHAR(12),
CONSTRAINT CUSTOMER_PK PRIMARY KEY (Cust_ID));

CREATE TABLE STOCK3 (
Item_ID CHAR(3) NOT NULL,
Descript VARCHAR(15),
Price DECIMAL(4,2),
OnHand INT,
CONSTRAINT STOCK_PK PRIMARY KEY (Item_ID));

CREATE TABLE VENDOR3 (
Vendor_ID CHAR(3) NOT NULL,
Item_ID CHAR(3),
Cost DECIMAL(4,2),
ShipDays VARCHAR(2),
CONSTRAINT VENDOR_COMP_PK PRIMARY KEY (Vendor_ID,Item_ID),
CONSTRAINT VENDOR_STOCK_FK FOREIGN KEY (Item_ID) REFERENCES STOCK3(Item_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION);

CREATE TABLE ORDERS3 (
Order_NO CHAR(3) NOT NULL,
Cust_ID CHAR(3),
Item_ID CHAR(3),
Quantity INT,
Order_Date DATE,
CONSTRAINT ORDERS_PK PRIMARY KEY (Order_NO),
CONSTRAINT ORDERS_CUST_FK FOREIGN KEY (Cust_ID) REFERENCES CUSTOMER3(Cust_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
CONSTRAINT ORDERS_STOCK_FK FOREIGN KEY (Item_ID) REFERENCES STOCK3(Item_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION);

--2
INSERT INTO CUSTOMER3 VALUES('AAA', 'ALEX', 'NE', '555-111-1111');
INSERT INTO CUSTOMER3 VALUES('BBB', 'BILL', 'W', '555-222-2222');
INSERT INTO CUSTOMER3 VALUES('CCC', 'CHRISTY', 'NE', '555-333-3333');
INSERT INTO CUSTOMER3 VALUES('DDD', 'DAVID', 'W', '555-444-4444');
INSERT INTO CUSTOMER3 VALUES('EEE', 'ELIZABETH', 'W', '555-555-5555');
INSERT INTO CUSTOMER3 VALUES('LLL', 'LACIE', 'S', '555-666-6666');

INSERT INTO STOCK3 VALUES('I01','Plums',1.75,'100');
INSERT INTO STOCK3 VALUES('I02','Apples',2.00,'200');
INSERT INTO STOCK3 VALUES('I03','Oranges',3.25,'300');
INSERT INTO STOCK3 VALUES('I04','Pears',4.00,'100');
INSERT INTO STOCK3 VALUES('I05','Bananas',5.25,'300');
INSERT INTO STOCK3 VALUES('I06','Grapes',6.50,'200');
INSERT INTO STOCK3 VALUES('I07','Kiwi',7.00,'300');

INSERT INTO ORDERS3 VALUES('001','AAA','I01', '10','2/1/2017');
INSERT INTO ORDERS3 VALUES('002','BBB','I02','20','2/2/2017');
INSERT INTO ORDERS3 VALUES('003','AAA','I03','30','2/5/2017');
INSERT INTO ORDERS3 VALUES('004','CCC','I01','40','2/11/2017');
INSERT INTO ORDERS3 VALUES('005','BBB','I05','50','2/13/2017');
INSERT INTO ORDERS3 VALUES('006','CCC','I04','60','2/13/2017');
INSERT INTO ORDERS3 VALUES('007','LLL','I03','70','2/15/2017');
INSERT INTO ORDERS3 VALUES('008','EEE','I07','20','2/15/2017');
INSERT INTO ORDERS3 VALUES('009','CCC','I01','40','2/17/2017');
INSERT INTO ORDERS3 VALUES('010','BBB','I05','60','2/21/2017');

INSERT INTO VENDOR3 VALUES('V01','I01','.50','3');
INSERT INTO VENDOR3 VALUES('V01','I02','1.00','4');
INSERT INTO VENDOR3 VALUES('V02','I03','1.50','4');
INSERT INTO VENDOR3 VALUES('V03','I01','2.00','2');
INSERT INTO VENDOR3 VALUES('V03','I05','2.50','2');
INSERT INTO VENDOR3 VALUES('V03','I03','3.00','4');
INSERT INTO VENDOR3 VALUES('V04','I03','3.50','4');
INSERT INTO VENDOR3 VALUES('V04','I02','1.50','5');
INSERT INTO VENDOR3 VALUES('V05','I01','6.50','6');
INSERT INTO VENDOR3 VALUES('V05','I05','1.50','8');

--3
--a. Show all the data we have about customers in the NE region.
SELECT *
FROM CUSTOMER3
WHERE REGION = 'NE';
--2 rows

--b. Show customer IDs that have submitted orders, but list each customer id once.
SELECT DISTINCT CUST_ID
FROM ORDERS3;
--5 rows

--c. Show which items have a price less than 5.00 and have over 100 on hand.
SELECT Item_ID, Descript
FROM STOCK3
WHERE Price < 5.00 AND OnHand > 100;
--2 rows

--d. Calculate the overall average quantity on hand.*
SELECT AVG(OnHand) AS 'Avg Quantity'
FROM STOCK3;
-- 214 items

--e. Calculate the total market value of the inventory.*
SELECT SUM(Price*OnHand) AS 'Total Inv Mkt Value'
FROM STOCK3;
--$6925.00
