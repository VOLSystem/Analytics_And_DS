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