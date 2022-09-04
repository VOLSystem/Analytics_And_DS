DROP TABLE EMPLSTATUSLOG;
DROP TABLE EMPLSTATUS;
DROP TABLE ORDERPRODUCTSTATUSLOG;
DROP TABLE ORDERLINE;
DROP TABLE ORDERSTATUSLOG;
DROP TABLE STATUS;
DROP TABLE INVENTORYCOUNT;
DROP TABLE DELIVERY;
DROP TABLE SHIPMENT;
DROP TABLE TRANSTEAM;
DROP TABLE CUSTOMERORDER;
DROP TABLE SALESTEAM;
DROP TABLE MAKETOSTOCK;
DROP TABLE MAKETOORDER;
DROP TABLE PRODUCTLINE;
DROP TABLE MATERIAL;
DROP TABLE EMPLOYEE;
DROP TABLE ROLL;
DROP TABLE PRODUCT;
DROP TABLE PLANT;
DROP TABLE NONCOMPLIANCE;
DROP TABLE CARRIER;
DROP TABLE CUSTOMER;
DROP VIEW [OrderlineCalcView];
DROP VIEW [DeliveryCalcView];
DROP VIEW [MaterialsinRollsView];
DROP VIEW [InventoryView];
DROP VIEW [PlannedShipmentsView];
DROP VIEW [MaterialsinRollsView];
DROP VIEW [OrderSummaryView];
DROP VIEW [NonComplianceView];
DROP VIEW [PerformanceReportView];
DROP VIEW [LateOrdersView];
DROP VIEW [EmployeeRewardsView]
DROP VIEW [ActiveOrdersView];

CREATE TABLE PLANT(
	Plant_ID INT IDENTITY(2000,5) NOT NULL PRIMARY KEY,
	Plant_Street VARCHAR(35),
	Plant_City VARCHAR(30),
	Plant_State VARCHAR(20),
	Plant_Postal_Code CHAR(5),
	Plant_Country VARCHAR(30)
);

CREATE TABLE EMPLOYEE(
	Empl_ID INT IDENTITY(100000001,1) NOT NULL PRIMARY KEY,
	Plant_ID INT DEFAULT 2000,
	Empl_F_Name VARCHAR(20) NOT NULL,
	Empl_L_Name VARCHAR(20) NOT NULL,
	Empl_Street VARCHAR(35),
	Empl_City VARCHAR(30),
	Empl_State VARCHAR(20),
	Empl_Postal_Code CHAR(5),
	Empl_Country VARCHAR(30),
	Empl_Phone_No CHAR(12),
	Empl_Birth_Date DATE NOT NULL,
	Empl_Hire_Date DATE NOT NULL DEFAULT GETDATE(),
	Empl_Type CHAR(1),
	CONSTRAINT EMPLOYEEPLANT_Plant_ID_FK FOREIGN KEY (Plant_ID)  REFERENCES PLANT(Plant_ID)
	ON UPDATE CASCADE ON DELETE SET DEFAULT
);

CREATE TABLE EMPLSTATUS(
	Empl_Status_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Empl_Status_Name VARCHAR(50) NOT NULL DEFAULT 'Active' CHECK(Empl_Status_Name IN('Active','Terminated','Maternity Leave','Special Assignment'))  
);

CREATE TABLE EMPLSTATUSLOG(
	Empl_ID INT NOT NULL,
	Empl_Status_ID INT NOT NULL,
	Empl_Status_Date DATE NOT NULL DEFAULT GETDATE(),
	CONSTRAINT EMPLSTATUSDATE_COMP_PK PRIMARY KEY (Empl_Status_ID,Empl_ID,Empl_Status_Date),  
	CONSTRAINT STATUS_Empl_Status_ID_FK FOREIGN KEY (Empl_Status_ID) REFERENCES EMPLSTATUS(Empl_Status_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT STATUS_Empl_ID_FK FOREIGN KEY (Empl_ID) REFERENCES EMPLOYEE(Empl_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE TRANSTEAM(
	T_Empl_ID INT NOT NULL PRIMARY KEY,
	CONSTRAINT EMPLOYEETRANSTEAM_T_Empl_ID_FK FOREIGN KEY (T_Empl_ID) REFERENCES EMPLOYEE(Empl_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE SALESTEAM(
	S_Empl_ID INT NOT NULL PRIMARY KEY,
	CONSTRAINT EMPLOYEESALESSTEAM_S_Empl_ID_FK FOREIGN KEY (S_Empl_ID) REFERENCES EMPLOYEE(Empl_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE CUSTOMER(
	Cust_ID  INT IDENTITY(123456,1) NOT NULL PRIMARY KEY,
	Cust_F_Name VARCHAR(20) NOT NULL,
	Cust_L_Name VARCHAR(20) NOT NULL,
	Cust_Street VARCHAR(35),
	Cust_City VARCHAR(30),
	Cust_State VARCHAR(20),
	Cust_Postal_Code CHAR(5),
	Cust_Country VARCHAR(30),
	Cust_Phone_No CHAR(12) NOT NULL,
	Cust_Email VARCHAR(30) NOT NULL
);

CREATE TABLE CARRIER(
	Carrier_ID INT IDENTITY(111111,1) NOT NULL PRIMARY KEY,
	Carrier_Name VARCHAR(50) NOT NULL,
	Carrier_Street VARCHAR(35),
	Carrier_City VARCHAR(30),
	Carrier_State VARCHAR(20),
	Carrier_Postal_Code CHAR(5),
	Carrier_Country VARCHAR(30),
	Carrier_Cust_Rep_Phone_No CHAR(12)
);

CREATE TABLE NONCOMPLIANCE(
	Non_Comp_ID INT IDENTITY(1111111111,1) NOT NULL PRIMARY KEY,
	Carrier_ID INT NOT NULL DEFAULT 111112,
	Non_Comp_Date DATE NOT NULL DEFAULT GETDATE() CHECK(Non_Comp_Date<=GETDATE()),
	Non_Comp_Issue VARCHAR(35) NOT NULL CHECK(Non_Comp_Issue in('Business Conduct & Ethics', 'Health, Safety & Environment','Workplace, Labor & Human Rights', 'Accountability')),
	Non_Comp_Statement VARCHAR(250),
	CONSTRAINT NONCOMPLIANCECARRIER_Carrier_ID_FK FOREIGN KEY (Carrier_ID) REFERENCES CARRIER(Carrier_ID)
	ON UPDATE CASCADE ON DELETE SET DEFAULT
);

CREATE TABLE PRODUCT(
	Product_ID INT IDENTITY(111111,1) NOT NULL PRIMARY KEY,
	Product_Wgt DECIMAL(6,2) NOT NULL CHECK(Product_Wgt>0) DEFAULT 1,
	Product_Cost DECIMAL(6,2) NOT NULL CHECK(Product_Cost>0),
	Product_Type VARCHAR(4) NOT NULL CHECK(Product_Type in('Mat','Roll')),
	Product_Descript VARCHAR(150)
);

CREATE TABLE ROLL(
	Roll_No INT NOT NULL PRIMARY KEY,
	Roll_Size VARCHAR(12),
	Roll_Length INTEGER CHECK(Roll_Length>=0),
	CONSTRAINT Roll_No_FK FOREIGN KEY (Roll_No) REFERENCES Product(Product_ID)
    	ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE MATERIAL(
	Mat_ID INT NOT NULL PRIMARY KEY,
	Mat_Type CHAR(3) NOT NULL CHECK(Mat_Type in('MTS','MTO'))
	CONSTRAINT Matl_ID_FK FOREIGN KEY (Mat_ID) REFERENCES Product(Product_ID)
    	ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE MAKETOSTOCK(
	MTS_Mat_ID INT NOT NULL PRIMARY KEY,
	CONSTRAINT MAKETOSTOCKMATERIAL_MTS_Material_ID_FK FOREIGN KEY (MTS_Mat_ID) REFERENCES MATERIAL(Mat_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE MAKETOORDER(
	MTO_Mat_ID INT NOT NULL,
	MTO_Completion_Date DATETIME NOT NULL DEFAULT GETDATE(),
	CONSTRAINT MAKETOORDER_COMP_PK PRIMARY KEY (MTO_Mat_ID,MTO_Completion_Date),
	CONSTRAINT MAKETOORDERMATERIAL_MTO_Mat_ID_FK FOREIGN KEY (MTO_Mat_ID) REFERENCES MATERIAL(Mat_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE CUSTOMERORDER(
	Order_ID INT IDENTITY(900000,1) NOT NULL PRIMARY KEY,
	Cust_ID INT NOT NULL,
	S_Empl_ID INT NOT NULL DEFAULT 100000003,
	Order_Date DATE NOT NULL DEFAULT GETDATE(),
	CONSTRAINT ORDERCUSTOMER_Cust_ID_FK FOREIGN KEY (Cust_ID) REFERENCES CUSTOMER(Cust_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT ORDERSALESTEAM_S_Empl_ID_FK FOREIGN KEY (S_Empl_ID) REFERENCES EMPLOYEE(Empl_ID)
	ON UPDATE CASCADE ON DELETE SET DEFAULT
);

CREATE TABLE SHIPMENT(
	Ship_ID  INT IDENTITY(1000000001,1) NOT NULL PRIMARY KEY,
	Plant_ID INT DEFAULT 2000 NOT NULL,
	T_Empl_ID INT DEFAULT 100000002 NOT NULL,
	Carrier_ID INT DEFAULT 111112 NOT NULL,
	Ship_Container_ID VARCHAR(20),
	Ship_Exec_Date DATE NOT NULL DEFAULT GETDATE(),
	Ship_Pln_Arr_Date DATE,
	Ship_Notes VARCHAR(250),
	CONSTRAINT SHIPMENTPLANT_Plant_ID_FK FOREIGN KEY (Plant_ID) REFERENCES PLANT(Plant_ID)
	ON UPDATE CASCADE ON DELETE SET DEFAULT,
	CONSTRAINT SHIPMENTTRANSTEAM_T_Empl_ID_FK FOREIGN KEY (T_Empl_ID) REFERENCES TRANSTEAM(T_Empl_ID)
	ON UPDATE NO ACTION ON DELETE SET DEFAULT,
	CONSTRAINT SHIPMENTCARRIER_Carrier_ID_FK FOREIGN KEY (Carrier_ID) REFERENCES CARRIER(Carrier_ID)
	ON UPDATE CASCADE ON DELETE SET DEFAULT
);

CREATE TABLE DELIVERY(
	Del_ID INT IDENTITY(222222220,1) NOT NULL PRIMARY KEY,
	Ship_ID INT NOT NULL,
	Cust_ID INT NOT NULL,
	Del_Container_ID VARCHAR(20),
	Del_Exp_Date DATE,
	CONSTRAINT DELIVERYCUSTOMER_Cust_ID_FK FOREIGN KEY (Cust_ID) REFERENCES CUSTOMER(Cust_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT DELIVERYSHIPMENT_Ship_ID_FK FOREIGN KEY (Ship_ID) REFERENCES SHIPMENT(Ship_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE STATUS(
	Status_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Status_Name VARCHAR(10) NOT NULL DEFAULT 'Submitted' CHECK(Status_Name IN('Submitted','In-process','Completed'))  
);

CREATE TABLE ORDERSTATUSLOG(
	Order_ID INT NOT NULL,
	Order_Status_ID INT NOT NULL,
	Order_Status_Date DATE NOT NULL DEFAULT GETDATE(),
	CONSTRAINT ORDSTATUSCUSTORD_COMP_PK PRIMARY KEY (Order_Status_ID,Order_ID),  
	CONSTRAINT OSLORDSTATUS_Order_Status_ID_FK FOREIGN KEY (Order_Status_ID) REFERENCES STATUS(Status_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT ORDSTATUSLOGCUSTORD_Order_ID_FK FOREIGN KEY (Order_ID) REFERENCES CUSTOMERORDER(Order_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE ORDERLINE(
	Orderline_ID INT IDENTITY(500000000,1) NOT NULL PRIMARY KEY,
	Order_ID INT NOT NULL,
	Del_ID INT,
	Product_ID INT NOT NULL,
	Plant_ID INT NOT NULL,
	Orderline_Qty INTEGER NOT NULL CHECK(Orderline_Qty>0),
	CONSTRAINT ORDERLINECUSTORDER_Order_ID_FK FOREIGN KEY (Order_ID) REFERENCES CUSTOMERORDER(Order_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT ORDERLINEPRODUCT_Product_ID_FK FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID)
	ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT ORDERLINEDELIVERY_Del_ID_FK FOREIGN KEY (Del_ID) REFERENCES DELIVERY(Del_ID)
	ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT ORDERLINEPLANT_Plant_ID_FK FOREIGN KEY (Plant_ID) REFERENCES PLANT(Plant_ID)
	ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE ORDERPRODUCTSTATUSLOG(
	Orderline_ID INT NOT NULL,
	Order_Product_Status_ID INT NOT NULL,
	Order_Product_Status_Date DATE NOT NULL DEFAULT GETDATE(),
	CONSTRAINT ORDPROSTATUSORDERLINE_COMP_PK PRIMARY KEY (Order_Product_Status_ID,Orderline_ID),  
	CONSTRAINT ORDPROSTATUSLOG_ORDPROSTATUS_Order_Product_Status_ID_FK FOREIGN KEY (Order_Product_Status_ID) REFERENCES STATUS(Status_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
	CONSTRAINT ORDPROSTATUSLOG_ORDERLINE_Orderline_ID_FK FOREIGN KEY (Orderline_ID) REFERENCES ORDERLINE(Orderline_ID)
	ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE INVENTORYCOUNT(
Plant_ID INTEGER NOT NULL,
Product_ID INTEGER NOT NULL,
Qty_On_Hand INTEGER CHECK(Qty_On_Hand >=0),
Qty_On_Order INTEGER,
Qty_On_BackOrder INTEGER,
Reorder_Point INTEGER,
CONSTRAINT InvCount_Comp_PK PRIMARY KEY(Plant_ID, Product_ID),
CONSTRAINT InvCount_Plant_ID_FK FOREIGN KEY (Plant_ID) REFERENCES PLANT(Plant_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION,
CONSTRAINT InvCount_Product_ID_FK FOREIGN KEY (Product_ID) REFERENCES PRODUCT(Product_ID)
	ON UPDATE CASCADE ON DELETE NO ACTION);

CREATE TABLE PRODUCTLINE(
	Roll_No INT NOT NULL,
	MTS_Mat_ID INT NOT NULL,
	CONSTRAINT ROLLMTS_COMP_PK PRIMARY KEY(Roll_No,MTS_Mat_ID),
	CONSTRAINT PRODUCTLINEROLL_Roll_No_FK FOREIGN KEY (Roll_No) REFERENCES ROLL(Roll_No)
	ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT PRODUCTLINEMTS_MTS_Mat_ID_FK FOREIGN KEY (MTS_Mat_ID) REFERENCES MATERIAL(Mat_ID)
	ON UPDATE NO ACTION ON DELETE NO ACTION
);

INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('4245 Sugarlimb Road', 'Loudon', 'Tennessee',37774,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('66313 Highland Crossing Road', 'LaGrange', 'Georgia',30240,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('76657 Southridge Road', 'Beech Island', 'South Carolina',29842,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('9328 Chinook Road', 'Sheridan', 'Arkansas',72150,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('53 Birchwood Road', 'Russellville', 'Alabama',35653,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('85 Washington Street', 'Menasha', 'Wisconsin',54952,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('4200 US-190', 'DeRidder', 'Louisiana',70634,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('855 E US Hwy 80', 'Forney', 'Texas',75126,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('1600 Pennsylvania Ave', 'Tyrone', 'Pennsylvania',16686,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('31831 US-12', 'Wallula', 'Washington',99360,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('2550 US-80', 'Bloomingdale', 'Georgia',31302,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('32224 U.S. 31', 'Brewton', 'Alabama',36426,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('1585 US-701', 'Elizabethtown', 'North Carolina',28337,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('152 West Main Street', 'Sylva', 'North Carolina',28779,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('100 Gaston Road', 'Roanoke Rapids', 'North Carolina',27870,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('1382 Elm Street West', 'Hampton', 'South Carolina',29924,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('25910 US-23', 'Circleville', 'Ohio',43113,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('21313 US-221', 'Laurens', 'South Carolina',29360,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('107 Frontage Rd', 'St. George', 'South Carolina',29477,'United States');
INSERT INTO PLANT (Plant_Street, Plant_City, Plant_State, Plant_Postal_Code, Plant_Country)
VALUES ('28270 Old U.S. 80', 'Demopolis', 'Alabama',36732,'United States');

INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Greatwide Logistics Services', '120 Belk Court', 'Blythewood','South Carolina',29016, 'United States','803-691-9461');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('J.B. Hunt Transport Services', '520 W Summit Hill Drive SW','Knoxville','Tennessee',37902, 'United States','800-351-0357');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Swift Transportation', '1451 Spartanburg Hwy','Jonesville','South Carolina',29353, 'United States','864-674-5513');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('R&L Carriers', '3928 Valley East Industrial Dr','Birmingham','Alabama',35217, 'United States','205-853-3466');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Knight Transportation', '4275 Westward Avenue','Columbus','Ohio',43228, 'United States','888-667-1300');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('YRC Worldwide', '1212 La Vista Drive','Dallas','Texas',75214, 'United States','214-606-5112');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('U.S. Express Enterprises', '3703 Kennebec Drive','Madison','Wisconsin',53703, 'United States','608-266-0382');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Saia', '1045 Jefferson Davis Hwy','Beech Island','South Carolina',29842, 'United States','803-593-1970');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('C.R. England', '2012 US-67','Mt. Pleasant','Texas',75455, 'United States','903-572-8300');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Schneider National', '1 Schneider Dr','Carlisle','Pennsylvania',17013, 'United States','717-691-4461');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Estes Express Lines', '10815 Reames Rd','Charlotte','North Carolina',28269, 'United States','704-597-9130');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Old Dominion Freight Line', '3378 Wall Triana Hwy SW','Huntsville','Alabama',35824, 'United States','256-464-9086');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Universal Truckload Services', '7800 Little York Rd','Houston','Texas',77016, 'United States','832-368-5027');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Ryder System', 'W229 N2480 County Hwy F','Waukesha','Wisconsin',53186, 'United States','262-574-1900');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Heartland Express', '1700 Main Street','Little Rock','Arkansas',72206, 'United States','501-275-8777');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Mercer Transportation', '921 Moss Street','Lake Charles','Louisiana',70601, 'United States','337-602-8441');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Con-way', ' 3525 East Ayres Street','Pasco','Washington',99301, 'United States','509-380-0963');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Landstar System', '1919 Bull Street','Savannah','Georgia',31401, 'United States','912-401-0543');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Southeastern Freight Lines', '1717 Old Dean Forest Road','Pooler','Georgia',31322, 'United States','912-964-7136');
INSERT INTO CARRIER (Carrier_Name, Carrier_Street, Carrier_City, Carrier_State, Carrier_Postal_Code, Carrier_Country, Carrier_Cust_Rep_Phone_No)
VALUES ('Werner Enterprises', '669 Snow Hill Road','Fayetteville','North Carolina',28306, 'United States','910-424-2050');

INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Ardenia', 'Stileman', '105 Messerschmidt Street', 'Shreveport','Louisiana', '71161','United States', '318-709-7298', 'astileman0@reference.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Jammal', 'Phette', '874 Mallory Lane', 'Washington', 'District of Columbia', '20456', 'United States', '202-234-8954', 'jphette@avatar.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Amandy', 'Ruprecht', '7802 Huxley Pass', 'Waterloo', 'Iowa', '50706', 'United States', '319-981-3746', 'aruprecht2@mashable.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Violante', 'Woolfitt', '10 Morning Place', 'Manassas', 'Virginia', '22111', 'United States', '434-971-4815', 'vwoolfitt3@fotki.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Tersina', 'Jaggli', '54372 Rockefeller Avenue', 'Fort Lauderdale', 'Florida', '33345', 'United States', '754-115-0160', 'tjag@bing.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Monro', 'Robbert', '2953 Dottie Hill', 'Orlando', 'Florida', '32859', 'United States', '407-916-1191', 'mrobbert@desdev.cn');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Henka', 'Kidgell', '4948 Emmet Plaza', 'Brockton', 'Massachusetts', '24005', 'United States', '508-274-5202', 'hkidgell@youku.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Christalle', 'Bartosins', '173 Lakewood Gardens Crossing', 'Lexington', 'Kentucky', '40591', 'United States', '859-630-9273', 'cbartosinki@friendfeed.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Grove', 'Livingston', '670 Bunting Pass', 'Long Beach', 'California', '90831', 'United States', '561-290-2700', 'gliving@bing.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Ferne', 'Sprosson', '746 Roxbury Place', 'Scranton', 'Pennsylvania', '18505', 'United States', '570-654-6901', 'fspro1984@gmail.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Piotr', 'Clift', '84563 Banding Crossing', 'Houston', 'Texas', '77225', 'United States', '763-322-0145', 'pclifta@redcross.org');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Jane', 'Udden', '29 Porter Junction', 'Huntington', 'West Virginia', '25705', 'United States', '304-447-3128', 'judden@engadet.net');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Towny', 'Barnclough', '98141 Michigan Drive', 'Denver', 'Colorado', '80255', 'United States', '720-386-7992', 'tbarnaclough@photobucket.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Robinett', 'Bristow', '24 Dapin Junction', 'Washington', 'District of Columbia', '20041', 'United States', '703-228-5869', 'rbristo1@gmail.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Bryan', 'Seilmann', '2 Little Fleur Trail', 'Saint Louis', 'Missouri', '63169', 'United States', '314-238-4241', 'bseilmanne@yellowbrook.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Filmer', 'Stiebler', '2026 Roxbury Center', 'Greenville', 'South Carolina', '29610', 'United States', '864-905-7050', 'fsti@amazon.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Kerry', 'Kauble', '3 Loeprich Junction', 'San Jose', 'California', '95194', 'United States', '408-612-0187', 'kkaub344@gnu.org');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Ann', 'Isworth', '5 Declaration Highway', 'Norfolk', 'Virginia', '23509', 'United States', '757-245-1490', 'aisworthh@google.pl');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Aube', 'Storms', '747 Coleman Drive', 'Asheville', 'North Carolina', '28815', 'United States', '8285585660', 'astormy@gmail.com');
INSERT INTO CUSTOMER (Cust_F_Name, Cust_L_Name, Cust_Street, Cust_City, Cust_State, Cust_Postal_Code, Cust_Country, Cust_Phone_No, Cust_Email)
VALUES ('Ilse', 'Shrieves', '4434 North Pass', 'Chicago', 'Illinois', '60657', 'United States', '773-212-2779', 'ilseshr@indianatimes.com');

INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111116, '11-25-2007', 'Workplace, Labor & Human Rights', 'Driver not certified to handle loading equipment.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111125, '1-16-2008', 'Accountability', 'Failed to secure loading dock following after hours delivery.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111112, '3-28-2008', 'Business Conduct & Ethics', 'Falsified hours report, attempting to over bill.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111111, '10-06-2008', 'Health, Safety & Environment', 'Improper disposal of used containers.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111123, '6-1-2009', 'Health, Safety & Environment', 'Failure to properly secure load before departure.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111130, '2-22-2010', 'Workplace, Labor & Human Rights', 'Directed plant employee to assist with loading w/o authorization.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111112, '10-31-2010', 'Business Conduct & Ethics', 'Failure to disclose non-permitted materials contained on vehicle during transport.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111117, '4-29-2011', 'Accountability', 'Failure to update records to indicate vehicle permit renewal.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111128, '11-17-2011', 'Business Conduct & Ethics', 'Failure to disclose non-standard rate charged before accepting shipment.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111122, '5-24-2012', 'Workplace, Labor & Human Rights', 'Failure to update records for OSHA certification.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111130, '12-21-2012', 'Health, Safety & Environment', 'Left loading equipment unsecured after loading completed.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111121, '7-2-2013', 'Business Conduct & Ethics', 'Fined for improper reporting of revenue sources.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111112, '7-8-2013', 'Workplace, Labor & Human Rights', 'Directed plant employee to assist with loading w/o authorization.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111129, '10-21-2013', 'Health, Safety & Environment', 'Cited for improperly sealed fuel storage containers.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111114, '8-27-2014', 'Accountability', 'Failure to notify of external compliance audit');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111111, '9-12-2015', 'Accountability', 'Prior month billable hours not updated.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111126, '12-19-2015', 'Business Conduct & Ethics', 'Cited for falsifying billable hours on outside job.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111130, '3-16-2016', 'Health, Safety & Environment', 'Failure to secure roll storage area after loading.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111124, '11-23-2016', 'Workplace, Labor & Human Rights','Employed child as long haul driver, paid with pizza.');
INSERT INTO NONCOMPLIANCE (Carrier_ID, Non_Comp_Date, Non_Comp_Issue, Non_Comp_Statement)
VALUES (111125, '5-9-2017', 'Accountability', 'Third late delivery for the month.');

INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00300.00,245.00,'Roll','Roll of Absorbent Fluff Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00360.50,300.00,'Roll','Roll of Bleached Chemi-Thermomechanical Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00150.25,225.00,'Roll','Roll of Debonded Fluff Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00480.00,350.00,'Roll', 'Roll of Northern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00520.00,325.00,'Roll', 'Roll of Southern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00280.70,235.00,'Roll', 'Roll of Bleached Eucalyptus Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00650.00,345.00,'Roll','Mixed roll of Absorbent Fluff Pulp and Northern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00790.50,405.00,'Roll', 'Mixed roll of Bleached Chemi-Thermomechanical Pulp and Southern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00350.00,385.00,'Roll', 'Roll of Northern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00230.60,175.00,'Roll','Mixed roll of Debonded Fluff Pulp and Bleached Eucalyptus Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00250.90,180.00,'Roll', 'Mixed roll of Debonded Fluff Pulp and Southern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00340.30,165.00,'Roll', 'Roll of Differentiated Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00170.40,120.00,'Roll', 'Mixed roll of Absorbent Fluff Pulp and Bleached Eucalyptus Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00430.00,225.00,'Roll', 'Mixed roll of Specialty Pulp and Northern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00335.10,290.00,'Roll', 'Roll of Specialty Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00175.80,185.00,'Roll', 'Mixed roll of Bleached Chemi-Thermomechanical Pulp and Bleached Eucalyptus Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00265.20,245.00,'Roll', 'Roll of Tissue Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00380.70,135.00,'Roll', 'Mixed roll of Tissue Pulp and Northern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00410.40,160.00,'Roll', 'Mixed roll of Northern Bleached Softwood Kraft Recycled Fiber and Differentiated Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00260.60,185.00,'Roll', 'Mixed roll of Southern Bleached Softwood Kraft Recycled Fiber and Specialty Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,125.00,'Mat','Recycled Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00120.50,115.00,'Mat','Absorbent Fluff Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00170.00,125.00,'Mat','Debonded Fluff Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00140.00,175.00,'Mat','Differentiated Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,115.00,'Mat','Mechanical Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,135.00,'Mat','Chemical Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,185.00,'Mat','Air Dry Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,110.00,'Mat','Flash Dried Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00170.00,135.00,'Mat','Tissue Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,195.00,'Mat','Chemithermo Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,105.00,'Mat','Cellulose Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00115.20,215.00,'Mat','Northern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00135.00,165.00,'Mat','Northern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,135.00,'Mat','Synthetic Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,125.00,'Mat','Pine Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00140.80,105.00,'Mat','Debonded Fluff Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00001.00,110.00,'Mat','Spruce Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00170.00,180.00,'Mat','Southern Bleached Softwood Kraft Recycled Fiber');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00125.50,100.00,'Mat','Bleached Chemi-Thermomechanical Pulp');
INSERT INTO PRODUCT (Product_Wgt, Product_Cost, Product_Type, Product_Descript)
VALUES(00130.00,195.00,'Mat','Specialty Pulp');

INSERT INTO ROLL VALUES (111111,'25 X 38', 950);
INSERT INTO ROLL VALUES (111112,'25 X 38', 920);
INSERT INTO ROLL VALUES (111113,'25 X 38', 950);
INSERT INTO ROLL VALUES (111114,'25 X 38', 905);
INSERT INTO ROLL VALUES (111115,'25 X 38', 930);
INSERT INTO ROLL VALUES (111116,'25 X 38', 950);
INSERT INTO ROLL VALUES (111117,'17 X 22', 374);
INSERT INTO ROLL VALUES (111118,'25.5 X 30.5', 778);
INSERT INTO ROLL VALUES (111119,'24 X 36', 864);
INSERT INTO ROLL VALUES (111120,'25.5 X 30.5', 778);
INSERT INTO ROLL VALUES (111121,'20 X 26', 520);
INSERT INTO ROLL VALUES (111122,'22.5 X 28.5', 641);
INSERT INTO ROLL VALUES (111123,'24 X 36', 864);
INSERT INTO ROLL VALUES (111124,'20 X 26', 520);
INSERT INTO ROLL VALUES (111125,'17 X 22', 374);
INSERT INTO ROLL VALUES (111126,'20 X 26', 520);
INSERT INTO ROLL VALUES (111127,'22.5 X 28.5', 641);
INSERT INTO ROLL VALUES (111128,'17 X 22', 374);
INSERT INTO ROLL VALUES (111129,'25.5 X 30.5', 778);
INSERT INTO ROLL VALUES (111130,'20 X 26', 520);

INSERT INTO EMPLSTATUS(Empl_Status_Name) VALUES('Active');
INSERT INTO EMPLSTATUS(Empl_Status_Name) VALUES('Terminated');
INSERT INTO EMPLSTATUS(Empl_Status_Name) VALUES('Maternity Leave');
INSERT INTO EMPLSTATUS(Empl_Status_Name) VALUES('Special Assignment');

INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2000, 'Robert', 'Half', '100 Cambridge Place', 'Loudon', 'Tennessee',37774, 'United States','734-963-8725', '12-MAR-1970', '6-JAN-2007', 'T'); 
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2010, 'Olivia', 'Roshma', '10551 Hoffman Junction', 'Beech Island', 'South Carolina', 29842, 'United States','918-857-8472', '11-SEP-1992', '1-JUN-2015', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2040, 'Chung Se', 'Xi', '50756 Goodland Way', 'Tyrone', 'Pennsylvania',16686, 'United States','320-467-1709', '15-DEC-1986', '3-APR-2007', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2010, 'Angela', 'Gardener', '97295 Morningstar Park', 'Beech Island', 'South Carolina', 29842, 'United States','561-764-8264', '10-FEB-1993', '26-JUL-2015', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2090, 'Mary Ann', 'Pollock', '91414 Graceland Drive', 'St. George','South Carolina', 29477, 'United States','303-638-5802', '1-NOV-1985', '18-AUG-2012', 'S'); 
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2085, 'Chris', 'Boone', '2 Goodland Park','Laurens', 'South Carolina',29360,'United States','415-903-3460', '2-JUN-1995', '10-JUN-2017', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2080, 'Pamela', 'Frisk', '7914 Menomonie Point','Circleville', 'Ohio', 43113,'United States','323-745-0235', '17-OCT-1974', '31-MAY-1997', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2050, 'Harambe', 'Strong', '797 Eagle Crest Crossing','Bloomingdale', 'Georgia',31302,'United States','702-688-4796', '26-SEP-1967','2-JAN-1992', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2075, 'Arobi', 'Kraskev', '97753 Blackbird Lane','Hampton','South Carolina',29924,'United States','704-305-0710', '14-NOV-1994', '15-JUL-2016', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2045, 'Rebekah', 'Conner', '995 Sheridan Street','Wallula', 'Washington',99360,'United States','972-807-1299', '18-DEC-1986','16-JAN-2017','T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2050, 'Forrest', 'Gump', '87119 Mayer Way','Bloomingdale', 'Georgia',31302,'United States','281-366-5063', '7-MAR-1970', '15-MAY-1992', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2055, 'Kalonji', 'Woods', '39 Karstens Way', 'Brewton', 'Alabama',36426, 'United States','202-682-5942', '21-APR-1989', '15-AUG-2012', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2030, 'Sera', 'Thompson', '1259 Kim Street', 'DeRidder', 'Louisiana',70634,'United States','862-541-2114', '13-OCT-1976', '20-MAY-2001', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2025, 'Taylor', 'Dishner', '214 Hallows Pass','Menasha', 'Wisconsin',54952,'United States','724-404-4119', '5-FEB-1995', '15-JUN-2017', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2010, 'MB', 'Pring', '3042 Browning Trail','Beech Island', 'South Carolina',29842,'United States','618-214-8783', '22-MAY-1995', '15-AUG-2017', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2005, 'Dallas', 'Shraden', '4 Straubel Junction','LaGrange', 'Georgia',30240,'United States','813-382-7159', '19-FEB-1997', '14-JUN-2007', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2085, 'Francesca', 'Pollos', '754 Roth Parkway','Laurens','South Carolina',29360,'United States','520-120-1399', '4-APR-1985', '15-JAN-2016', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2085, 'Polly', 'Walker', '67 Huxley Parkway','Laurens', 'South Carolina',29360,'United States','916-739-5372', '14-SEP-1993', '12-JUN-2015', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2065, 'Gustaf', 'Granger', '24 Shoshone Way','Sylva', 'North Carolina',28779,'United States','814-393-8995', '9-NOV-1992', '6-JAN-2014', 'T');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2095, 'Jose', 'Ortega', '934 Kim Avenue','Demopolis', 'Alabama',36732, 'United States','617-348-4247', '12-DEC-1963', '6-JAN-1992', 'S');
INSERT INTO EMPLOYEE (Plant_ID, Empl_F_Name, Empl_L_Name, Empl_Street, Empl_City, Empl_State, Empl_Postal_Code, Empl_Country, Empl_Phone_No, Empl_Birth_Date, Empl_Hire_Date, Empl_Type)
VALUES (2020, 'David', 'Wright', '75 Beale Street','Forester', 'Arkansas',72515, 'United States','617-345-4243', '5-OCT-1964', '17-FEB-1991', 'S');

INSERT INTO EMPLSTATUSLOG VALUES(100000001, 1, '1-6-2007');
INSERT INTO EMPLSTATUSLOG VALUES(100000001, 4, '10-5-2009');
INSERT INTO EMPLSTATUSLOG VALUES(100000001, 1, '4-13-2010');
INSERT INTO EMPLSTATUSLOG VALUES(100000002, 1, '6-1-2015');
INSERT INTO EMPLSTATUSLOG VALUES(100000002, 3, '8-15-2016');
INSERT INTO EMPLSTATUSLOG VALUES(100000002, 1, '10-12-2016');
INSERT INTO EMPLSTATUSLOG VALUES(100000003, 1, '4-3-2007');
INSERT INTO EMPLSTATUSLOG VALUES(100000004, 1, '7-26-2015');
INSERT INTO EMPLSTATUSLOG VALUES(100000005, 1, '8-18-2012');
INSERT INTO EMPLSTATUSLOG VALUES(100000006, 1, '6-10-2017');
INSERT INTO EMPLSTATUSLOG VALUES(100000007, 1, '5-31-1997');
INSERT INTO EMPLSTATUSLOG VALUES(100000008, 1, '1-2-1992');
INSERT INTO EMPLSTATUSLOG VALUES(100000009, 1, '7-15-2016');
INSERT INTO EMPLSTATUSLOG VALUES(100000010, 1, '1-16-2017');
INSERT INTO EMPLSTATUSLOG VALUES(100000011, 1, '5-15-1992');
INSERT INTO EMPLSTATUSLOG VALUES(100000012, 1, '8-15-2012');
INSERT INTO EMPLSTATUSLOG VALUES(100000013, 1, '5-20-2001');
INSERT INTO EMPLSTATUSLOG VALUES(100000014, 1, '6-15-2017');
INSERT INTO EMPLSTATUSLOG VALUES(100000015, 1, '8-15-2017');
INSERT INTO EMPLSTATUSLOG VALUES(100000016, 1, '6-14-2007');
INSERT INTO EMPLSTATUSLOG VALUES(100000017, 1, '1-15-2016');
INSERT INTO EMPLSTATUSLOG VALUES(100000018, 1, '6-12-2015');
INSERT INTO EMPLSTATUSLOG VALUES(100000019, 1, '1-6-2014');
INSERT INTO EMPLSTATUSLOG VALUES(100000020, 1, '1-6-1992');
INSERT INTO EMPLSTATUSLOG VALUES(100000021, 1, '2-17-1991');
INSERT INTO EMPLSTATUSLOG VALUES(100000021, 4, '12-15-1991');
INSERT INTO EMPLSTATUSLOG VALUES(100000021, 1, '3-4-1992');
INSERT INTO EMPLSTATUSLOG VALUES(100000021, 2, '7-14-1995');

/*SELECT * FROM EMPLOYEE
SELECT EMPL_ID,EMPL_F_NAME,EMPL_L_NAME,EMPL_BIRTH_DATE,EMPL_HIRE_DATE,
   	 DATEDIFF(year,EMPL_BIRTH_DATE,GETDATE()) AS Age, DATEDIFF(year,EMPL_HIRE_DATE,GETDATE()) AS #YrsWorked
FROM EMPLOYEE*/

INSERT INTO SALESTEAM VALUES (100000003);
INSERT INTO SALESTEAM VALUES (100000005);
INSERT INTO SALESTEAM VALUES (100000006);
INSERT INTO SALESTEAM VALUES (100000007);
INSERT INTO SALESTEAM VALUES (100000009);
INSERT INTO SALESTEAM VALUES (100000011);
INSERT INTO SALESTEAM VALUES (100000014);
INSERT INTO SALESTEAM VALUES (100000016);
INSERT INTO SALESTEAM VALUES (100000017);
INSERT INTO SALESTEAM VALUES (100000020);

INSERT INTO TRANSTEAM VALUES (100000001);
INSERT INTO TRANSTEAM VALUES (100000002);
INSERT INTO TRANSTEAM VALUES (100000004);
INSERT INTO TRANSTEAM VALUES (100000008);
INSERT INTO TRANSTEAM VALUES (100000010);
INSERT INTO TRANSTEAM VALUES (100000012);
INSERT INTO TRANSTEAM VALUES (100000013);
INSERT INTO TRANSTEAM VALUES (100000015);
INSERT INTO TRANSTEAM VALUES (100000018);
INSERT INTO TRANSTEAM VALUES (100000019);

INSERT INTO STATUS (Status_Name) VALUES('Submitted');
INSERT INTO STATUS (Status_Name) VALUES('In-process');
INSERT INTO STATUS (Status_Name) VALUES('Completed');

INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123456,100000003, '10-2-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123459,100000007, '10-9-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123471,100000014, '10-12-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123464,100000005, '10-17-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123468,100000009, '10-18-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123460,100000016, '10-19-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123472,100000020, '10-24-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123461,100000017, '10-26-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123463,100000006, '10-30-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123470,100000011, '11-3-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123475,100000009, '11-7-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123466,100000017, '11-9-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123473,100000005, '11-10-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123458,100000011, '11-15-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123462,100000020, '11-21-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123457,100000007, '11-24-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123469,100000016, '11-29-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123474,100000003, '12-4-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123467,100000014, '12-7-2017');
INSERT INTO CUSTOMERORDER (Cust_ID, S_Empl_ID, Order_Date)
VALUES(123465,100000006, '12-11-2017');

INSERT INTO ORDERSTATUSLOG VALUES(900000, 1, '10-2-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900000, 2, '10-3-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900000, 3, '10-3-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900001, 1, '10-9-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900001, 2, '10-10-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900001, 3, '10-13-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900002, 1, '10-12-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900002, 2, '10-13-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900002, 3, '10-17-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900003, 1, '10-17-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900003, 2, '10-19-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900003, 3, '10-23-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900004, 1, '10-18-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900004, 2, '10-19-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900004, 3, '10-19-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900005, 1, '10-19-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900005, 2, '10-20-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900005, 3, '10-20-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900006, 1, '10-24-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900006, 2, '10-25-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900006, 3, '10-25-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900007, 1, '10-26-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900007, 2, '10-27-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900007, 3, '10-27-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900008, 1, '10-30-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900008, 2, '10-31-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900008, 3, '10-31-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900009, 1, '11-3-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900009, 2, '11-8-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900009, 3, '11-20-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900010, 1, '11-7-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900010, 2, '11-9-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900010, 3, '11-9-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900011, 1, '11-9-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900011, 2, '11-10-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900011, 3, '11-10-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900012, 1, '11-10-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900012, 2, '11-13-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900012, 3, '12-3-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900013, 1, '11-15-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900013, 2, '11-20-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900013, 3, '11-21-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900014, 1, '11-21-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900014, 2, '11-22-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900014, 3, '11-22-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900015, 1, '11-24-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900015, 2, '11-27-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900015, 3, '11-29-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900016, 1, '11-29-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900016, 2, '11-30-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900016, 3, '12-1-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900017, 1, '12-4-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900017, 2, '12-5-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900018, 1, '12-7-2017');
INSERT INTO ORDERSTATUSLOG VALUES(900019, 1, '12-11-2017');

INSERT INTO MATERIAL VALUES(111131,'MTO');
INSERT INTO MATERIAL VALUES(111132,'MTS');
INSERT INTO MATERIAL VALUES(111133,'MTS');
INSERT INTO MATERIAL VALUES(111134,'MTS');
INSERT INTO MATERIAL VALUES(111135,'MTO');
INSERT INTO MATERIAL VALUES(111136,'MTO');
INSERT INTO MATERIAL VALUES(111137,'MTO');
INSERT INTO MATERIAL VALUES(111138,'MTO');
INSERT INTO MATERIAL VALUES(111139,'MTS');
INSERT INTO MATERIAL VALUES(111140,'MTO');
INSERT INTO MATERIAL VALUES(111141,'MTO');
INSERT INTO MATERIAL VALUES(111142,'MTS');
INSERT INTO MATERIAL VALUES(111143,'MTS');
INSERT INTO MATERIAL VALUES(111144,'MTO');
INSERT INTO MATERIAL VALUES(111145,'MTO');
INSERT INTO MATERIAL VALUES(111146,'MTS');
INSERT INTO MATERIAL VALUES(111147,'MTO');
INSERT INTO MATERIAL VALUES(111148,'MTS');
INSERT INTO MATERIAL VALUES(111149,'MTS');
INSERT INTO MATERIAL VALUES(111150,'MTS');

INSERT INTO MAKETOORDER VALUES(111131,'2017-10-03T17:52:51');
INSERT INTO MAKETOORDER VALUES(111135,'2017-10-19T15:55:15');
INSERT INTO MAKETOORDER VALUES(111136,'2017-10-20T11:41:11');
INSERT INTO MAKETOORDER VALUES(111140,'2017-10-25T12:54:15');
INSERT INTO MAKETOORDER VALUES(111138,'2017-10-27T16:45:19');
INSERT INTO MAKETOORDER VALUES(111145,'2017-10-31T14:35:56');
INSERT INTO MAKETOORDER VALUES(111137,'2017-11-10T13:33:18');
INSERT INTO MAKETOORDER VALUES(111147,'2017-11-13T16:47:36');

INSERT INTO MAKETOSTOCK VALUES(111132);
INSERT INTO MAKETOSTOCK VALUES(111133);
INSERT INTO MAKETOSTOCK VALUES(111134);
INSERT INTO MAKETOSTOCK VALUES(111139);
INSERT INTO MAKETOSTOCK VALUES(111142);
INSERT INTO MAKETOSTOCK VALUES(111143);
INSERT INTO MAKETOSTOCK VALUES(111146);
INSERT INTO MAKETOSTOCK VALUES(111148);
INSERT INTO MAKETOSTOCK VALUES(111149);
INSERT INTO MAKETOSTOCK VALUES(111150);

INSERT INTO PRODUCTLINE VALUES(111111,111132);
INSERT INTO PRODUCTLINE VALUES(111112,111149);
INSERT INTO PRODUCTLINE VALUES(111113,111146);
INSERT INTO PRODUCTLINE VALUES(111114,111142);
INSERT INTO PRODUCTLINE VALUES(111115,111148);
INSERT INTO PRODUCTLINE VALUES(111116,111134);
INSERT INTO PRODUCTLINE VALUES(111117,111132);
INSERT INTO PRODUCTLINE VALUES(111117,111142);
INSERT INTO PRODUCTLINE VALUES(111118,111149);
INSERT INTO PRODUCTLINE VALUES(111118,111148);
INSERT INTO PRODUCTLINE VALUES(111119,111143);
INSERT INTO PRODUCTLINE VALUES(111120,111146);
INSERT INTO PRODUCTLINE VALUES(111120,111134);
INSERT INTO PRODUCTLINE VALUES(111121,111146);
INSERT INTO PRODUCTLINE VALUES(111121,111148);
INSERT INTO PRODUCTLINE VALUES(111122,111133);
INSERT INTO PRODUCTLINE VALUES(111123,111132);
INSERT INTO PRODUCTLINE VALUES(111123,111134);
INSERT INTO PRODUCTLINE VALUES(111124,111142);
INSERT INTO PRODUCTLINE VALUES(111124,111150);
INSERT INTO PRODUCTLINE VALUES(111125,111150);
INSERT INTO PRODUCTLINE VALUES(111126,111149);
INSERT INTO PRODUCTLINE VALUES(111126,111134);
INSERT INTO PRODUCTLINE VALUES(111127,111139);
INSERT INTO PRODUCTLINE VALUES(111128,111139);
INSERT INTO PRODUCTLINE VALUES(111128,111142);
INSERT INTO PRODUCTLINE VALUES(111129,111143);
INSERT INTO PRODUCTLINE VALUES(111129,111133);
INSERT INTO PRODUCTLINE VALUES(111130,111148);
INSERT INTO PRODUCTLINE VALUES(111130,111150);


INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2000,100000010,111121,'FIC-06NQ9TL5-XSZBUU','10-9-2017', '10-11-2017','call ship receiving specialist on arrival');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2005,100000015,111125,'ULE5HJ-W2NPCGPJ','10-16-2017',
'10-19-2017','call ship receiving specialist on arrival and request signature');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2005,100000004,111118,'7DPM7U-AV09E-BDEIRX','10-19-2017',
 '10-26-2017','request signature and verify at the front receptionist');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2015,100000019,111130,'B0F-VTLTD2SMHH-C9ANR','10-24-2017',
 '10-25-2017','drop off by 2:00pm to warehouse A on the campus');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2035,100000018,111113,'759NEU-1982JD-A','10-25-2017',
'10-27-2017','do not leave in the shipyard');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2015,100000002,111117,'2K87N3QCW87Z76H','10-26-2017',
 '11-2-2017','notify IP on arrival; do not leave in the shipyard');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2085,100000013,111119,'PC5O-30000BPI7I7OW','10-31-2017',
 '11-1-2017','notify IP on arrival; do not leave in the shipyard; notify shipping specialist on arrival and unload to customer');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2070,100000008,111120,'DDL-Q4XGEUN-TU4','11-2-2017','11-9-2017','do not leave in the shipyard');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2040,100000015,111114,'AXVM7H72PD5Z0F','11-6-2017', '11-8-2017','notify IP on arrival');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2015,100000004,111127,'D4S6A4RSV650MNZ','11-10-2017',
'11-10-2017','do not leave in the shipyard; notify IP on arrival');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2065,100000004,111111,'5KZ3-4C85GB-FPVK9','11-14-2017',
'11-21-2017','call ship receiving specialist on arrival and request signature');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2055,100000002,111122,'HR9QXCKY8776-0K','11-16-2017',
'11-17-2017','notify IP on arrival; call ship receiving specialist on arrival and request signature');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2025,100000001,111129,'CUY-000SZGM-02R3R','11-17-2017',
'11-21-2017','do not leave in the shipyard; call ship receiving specialist on arrival and request signature');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2065,100000013,111114,'P-TU4TRRIG9','11-22-2017',
'12-6-2017','drop off to warehouse B on the campus');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2015,100000018,111126,'V000000-OTWZU','11-28-2017',
'12-5-2017','do not leave in the shipyard');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2065,100000012,111130,'9545788XXADXTF','12-1-2017',
'12-6-2017','do not leave in the shipyard; notify IP on arrival');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2065,100000012,111112,'NKE0K4-FHTY5667','12-6-2017',
'12-7-2017','call ship receiving specialist on arrival and request signature');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2065,100000019,111125,'CAKD-P1AWQXA43I4','12-13-2017',
'12-15-2017','do not leave in the shipyard');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2005,100000001,111118,'3ER5I706-3SB3R','12-14-2017',
 '12-18-2017','do not leave in the shipyard; notify IP on arrival');
INSERT INTO SHIPMENT (Plant_ID, T_Empl_ID, Carrier_ID, Ship_Container_ID, Ship_Exec_Date, Ship_Pln_Arr_Date, Ship_Notes)
VALUES(2065,100000013,111112,'LDHB400006QKXL','12-18-2017',
'12-21-2017','call ship receiving specialist on arrival and request signature');

INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000001,123456,'IW9WVERIR02H8DK603S9', '10-11-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000002,123457,'48CHQ84NQ290A1J38DK1', '10-18-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000002,123457,'202C39CMD8G4M60CJ1AL', '10-19-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000003,123458,'438CBC8S7CKE308S6A12', '10-26-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000004,123459,'22HH2333BC19AJ47DNVC', '10-25-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000005,123460,'3456256NB0DK349S2LC1', '10-27-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000006,123461,'54665X823228DHFNVH51', '11-02-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000006,123461,'43272C2Z7712385G72', '11-01-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000007,123462,'24839H43IQHRQCJ485', '11-01-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000008,123463,'32413XAG1940DJCHS63M', '11-09-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000009,123464,'65757I77SH237DHA15', '11-08-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000010,123465,'45URW5V3J8DKA30291JV', '11-10-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000011,123466,'32R3434KFHC8S0J26C5A', '11-21-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000011,123466,'Q09J4RCQH93KCH102D', '11-17-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000012,123467,'587U663KSL48CHSM017D', '11-17-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000013,123468,'VT45443J1SH39DJ6SJ12', '11-21-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000014,123469,'343389CNR4DH7DK374', '12-05-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000014,123469,'C0230320J3SFL8901D', '12-06-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000015,123470,'4RRRJC9Q3N593MSG10', '12-05-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000016,123471,'E2390328DJ47CG1038S2', '12-06-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000017,123472,'ER033RCJ37DHCB659A5L', '12-07-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000018,123473,'328CN98432H2847DH123', '12-15-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000018,123473,'48NCN9KXB58S402KAH12', '12-14-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000019,123474,'21341355643FFDJ38DH1', '12-18-2017');
INSERT INTO DELIVERY(Ship_ID,Cust_ID, Del_Container_ID,Del_Exp_Date) VALUES(1000000020,123475,'132421CC5947CH3017', '12-21-2017');

INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900000,222222220,111131,2000,300);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900001,222222221,111111,2005,2);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900001,222222222,111133,2055,200);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900002,222222223,111133,2055,100);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900003,222222224,111134,2080,150);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900004,222222225,111135,2060,225);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900005,222222226,111116,2015,3);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900005,222222227,111136,2095,150);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900006,222222228,111140,2085,115);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900007,222222229,111138,2070,200);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900008,222222230,111145,2075,175);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900009,222222231,111149,2015,100);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900010,222222232,111124,2065,4);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900010,222222233,111143,2065,150);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900011,222222234,111137,2055,125);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900012,222222235,111147,2040,200);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900013,222222236,111150,2015,250);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900013,222222237,111146,2035,300);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900014,222222238,111148,2065,125);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900015,222222239,111139,2045,75);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900016,222222240,111113,2065,4);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900017,222222241,111121,2065,2);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900017,222222242,111139,2090,75);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900018,222222243,111132,2005,115);
INSERT INTO ORDERLINE(Order_ID,Del_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900019,222222244,111150,2015,205);


INSERT INTO INVENTORYCOUNT VALUES(2005,111111,140,30,100,100);
INSERT INTO INVENTORYCOUNT VALUES(2015,111112,130,60,50,90);
INSERT INTO INVENTORYCOUNT VALUES(2065,111113,120,0,30,110);
INSERT INTO INVENTORYCOUNT VALUES(2065,111114,0,0,40,50);
INSERT INTO INVENTORYCOUNT VALUES(2015,111115,200,30,5,100);
INSERT INTO INVENTORYCOUNT VALUES(2015,111116,120,70,200,120);
INSERT INTO INVENTORYCOUNT VALUES(2005,111117,150,0,3,80);
INSERT INTO INVENTORYCOUNT VALUES(2015,111118,60,70,4,100);
INSERT INTO INVENTORYCOUNT VALUES(2065,111119,150,90,0,200);
INSERT INTO INVENTORYCOUNT VALUES(2065,111120,130,100,0,100);
INSERT INTO INVENTORYCOUNT VALUES(2065,111121,150,40,6,100);
INSERT INTO INVENTORYCOUNT VALUES(2005,111122,130,50,0,150);
INSERT INTO INVENTORYCOUNT VALUES(2005,111123,110,110,0,140);
INSERT INTO INVENTORYCOUNT VALUES(2065,111124,130,70,5,100);
INSERT INTO INVENTORYCOUNT VALUES(2065,111125,110,30,0,150);
INSERT INTO INVENTORYCOUNT VALUES(2015,111126,150,50,0,200);
INSERT INTO INVENTORYCOUNT VALUES(2030,111127,140,60,0,160);
INSERT INTO INVENTORYCOUNT VALUES(2065,111128,120,80,0,130);
INSERT INTO INVENTORYCOUNT VALUES(2005,111129,130,40,20,100);
INSERT INTO INVENTORYCOUNT VALUES(2015,111130,140,40,0,120);
INSERT INTO INVENTORYCOUNT VALUES(2000,111131,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2005,111132,0,500,0,1500);
INSERT INTO INVENTORYCOUNT VALUES(2005,111133,3000,2500,0,5000);
INSERT INTO INVENTORYCOUNT VALUES(2015,111134,3500,800,0,4500);
INSERT INTO INVENTORYCOUNT VALUES(2035,111135,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2015,111136,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2055,111137,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2070,111138,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2065,111139,4000,5000,0,5250);
INSERT INTO INVENTORYCOUNT VALUES(2085,111140,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2010,111141,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2065,111142,10500,950,0,12250);
INSERT INTO INVENTORYCOUNT VALUES(2065,111143,2050,1250,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2075,111144,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2040,111145,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2065,111146,7500,1500,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2025,111147,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2015,111148,0,0,750,1500);
INSERT INTO INVENTORYCOUNT VALUES(2015,111149,200,550,0,350);
INSERT INTO INVENTORYCOUNT VALUES(2065,111150,1350,400,0,1500);
INSERT INTO INVENTORYCOUNT VALUES(2065,111148,550,750,0,1500);
INSERT INTO INVENTORYCOUNT VALUES(2005,111142,500,950,0,250);
INSERT INTO INVENTORYCOUNT VALUES(2005,111134,3000,800,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2065,111134,2000,800,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2030,111139,4500,5000,0,5250);
INSERT INTO INVENTORYCOUNT VALUES(2005,111143,2000,1250,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2015,111150,1200,400,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2020,111136,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2020,111141,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2025,111144,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2000,111136,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2000,111138,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2010,111137,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2010,111147,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2035,111134,2250,800,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2035,111146,6000,1500,0,500);
INSERT INTO INVENTORYCOUNT VALUES(2035,111120,150,100,0,50);
INSERT INTO INVENTORYCOUNT VALUES(2040,111141,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2040,111144,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2040,111147,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2045,111114,100,40,0,60);
INSERT INTO INVENTORYCOUNT VALUES(2045,111142,600,950,0,250);
INSERT INTO INVENTORYCOUNT VALUES(2045,111119,170,90,0,200);
INSERT INTO INVENTORYCOUNT VALUES(2045,111143,2000,1250,0,1500);
INSERT INTO INVENTORYCOUNT VALUES(2045,111139,4000,5000,0,5250);
INSERT INTO INVENTORYCOUNT VALUES(2050,111131,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2050,111147,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2055,111122,140,50,0,150);
INSERT INTO INVENTORYCOUNT VALUES(2055,111133,4250,2500,0,5000);
INSERT INTO INVENTORYCOUNT VALUES(2055,111125,130,150,0,50);
INSERT INTO INVENTORYCOUNT VALUES(2055,111150,1250,400,0,1500);
INSERT INTO INVENTORYCOUNT VALUES(2060,111135,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2060,111136,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2090,111149,325,550,0,350);
INSERT INTO INVENTORYCOUNT VALUES(2090,111134,2250,800,0,2500);
INSERT INTO INVENTORYCOUNT VALUES(2090,111126,180,50,0,150);
INSERT INTO INVENTORYCOUNT VALUES(2090,111139,5000,5000,0,5250);
INSERT INTO INVENTORYCOUNT VALUES(2090,111127,150,200,0,160);
INSERT INTO INVENTORYCOUNT VALUES(2095,111136,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2095,111137,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2095,111138,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2080,111123,130,110,0,140);
INSERT INTO INVENTORYCOUNT VALUES(2080,111128,110,100,0,50);
INSERT INTO INVENTORYCOUNT VALUES(2080,111132,450,500,0,1500);
INSERT INTO INVENTORYCOUNT VALUES(2080,111134,3800,800,0,4500);
INSERT INTO INVENTORYCOUNT VALUES(2080,111139,4200,5000,0,5250);
INSERT INTO INVENTORYCOUNT VALUES(2080,111142,9340,950,0,12250);
INSERT INTO INVENTORYCOUNT VALUES(2070,111135,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2070,111136,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2070,111137,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2075,111145,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2085,111141,NULL,NULL,NULL,NULL);
INSERT INTO INVENTORYCOUNT VALUES(2085,111144,NULL,NULL,NULL,NULL);


INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000000, 1, '10-2-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000000, 2, '10-3-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000000, 3, '10-8-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000001, 1, '10-2-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000001, 2, '10-3-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000001, 3, '10-8-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000002, 1, '10-2-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000002, 2, '10-4-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000002, 3, '10-7-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000003, 1, '10-12-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000003, 2, '10-13-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000003, 3, '10-17-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000004, 1, '10-17-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000004, 2, '10-19-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000004, 3, '10-23-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000005, 1, '10-18-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000005, 2, '10-20-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000005, 3, '10-23-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000006, 1, '10-19-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000006, 2, '10-20-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000006, 3, '10-23-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000007, 1, '10-19-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000007, 2, '10-20-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000007, 3, '10-24-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000008, 1, '10-24-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000008, 2, '10-25-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000008, 3, '10-26-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000009, 1, '10-26-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000009, 2, '10-27-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000009, 3, '11-1-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000010, 1, '10-30-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000010, 2, '10-30-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000010, 3, '10-31-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000011, 1, '11-3-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000011, 2, '11-8-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000011, 3, '11-9-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000012, 1, '11-7-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000012, 2, '11-9-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000012, 3, '11-9-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000013, 1, '11-7-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000013, 2, '11-9-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000013, 3, '11-9-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000014, 1, '11-9-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000014, 2, '11-14-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000014, 3, '11-15-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000015, 1, '11-10-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000015, 2, '11-13-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000015, 3, '11-14-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000016, 1, '11-15-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000016, 2, '11-20-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000016, 3, '11-21-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000017, 1, '11-15-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000017, 2, '11-19-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000017, 3, '11-20-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000018, 1, '11-21-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000018, 2, '11-22-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000018, 3, '11-22-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000019, 1, '11-24-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000019, 2, '11-27-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000019, 3, '11-29-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000020, 1, '11-29-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000020, 2, '11-30-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000020, 3, '12-1-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000021, 1, '12-4-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000021, 2, '12-5-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000022, 1, '12-7-2017');
INSERT INTO ORDERPRODUCTSTATUSLOG VALUES(500000023, 1, '12-11-2017');



--view #1 Calculates total weight and total cost of each orderline:
CREATE VIEW OrderlineCalcView AS
(SELECT ORDERLINE.ORDERLINE_ID,ORDERLINE.ORDER_ID,DEL_ID,ORDERLINE.PRODUCT_ID,
  	(orderline.orderline_qty*product.product_cost) as Orderline_Total_Cost, (orderline.orderline_qty*product.product_wgt) as Orderline_Total_Wgt
FROM ORDERLINE,PRODUCT
WHERE ORDERLINE.PRODUCT_ID=PRODUCT.PRODUCT_ID
GROUP BY ORDERLINE.ORDERLINE_ID,ORDERLINE.ORDER_ID,DEL_ID,ORDERLINE.PRODUCT_ID, ORDERLINE.ORDERLINE_QTY,
     	PRODUCT.PRODUCT_COST,PRODUCT.PRODUCT_WGT);

--view #2 Calculates delivery total weights:
CREATE VIEW DeliveryCalcView AS
SELECT DELIVERY.Del_ID,DELIVERY.Ship_ID,SUM(PRODUCT.Product_Wgt*ORDERLINE.Orderline_Qty) AS Del_Total_Wgt,Del_Container_ID,Del_Exp_Date
FROM DELIVERY,ORDERLINE,PRODUCT
WHERE DELIVERY.DEL_ID=ORDERLINE.DEL_ID AND PRODUCT.PRODUCT_ID=ORDERLINE.PRODUCT_ID
GROUP BY DELIVERY.DEL_ID,DELIVERY.SHIP_ID,DEL_CONTAINER_ID,DEL_EXP_DATE;

--view #3
CREATE VIEW InventoryView AS
SELECT PLANT_ID,INVENTORYCOUNT.PRODUCT_ID,PRODUCT_DESCRIPT,QTY_ON_HAND,QTY_ON_ORDER,QTY_ON_BACKORDER,REORDER_POINT
FROM INVENTORYCOUNT,PRODUCT
WHERE INVENTORYCOUNT.PRODUCT_ID=PRODUCT.PRODUCT_ID AND QTY_ON_HAND IS NOT NULL;

-- view #4 Query 1, shows details about planned shipments:
CREATE VIEW PlannedShipmentsView AS
SELECT SHIP_ID, SHIP_EXEC_DATE, SHIP_PLN_ARR_DATE, CARRIER.CARRIER_ID, CARRIER_NAME, CARRIER_CUST_REP_PHONE_NO,
EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, EMPL_PHONE_NO, PLANT.PLANT_ID
FROM SHIPMENT
LEFT JOIN CARRIER
ON SHIPMENT.CARRIER_ID = CARRIER.CARRIER_ID
LEFT JOIN EMPLOYEE
ON SHIPMENT.T_EMPL_ID = EMPLOYEE.EMPL_ID
LEFT JOIN PLANT
ON SHIPMENT.PLANT_ID = PLANT.PLANT_ID;

-- view #5 Query 2, shows materials in rolls.
CREATE VIEW MaterialsinRollsView AS
SELECT Roll_No, MTS_Mat_ID, Product.Product_Cost As [Roll Cost], MatCost.Product_Cost As [Material Cost], Plant_ID, Qty_On_Hand
FROM ProductLine
INNER JOIN Product
ON Roll_No = Product_ID
INNER JOIN (SELECT Product_ID, Product_Cost
FROM Product
INNER JOIN MakeToStock
ON Product.Product_ID = MakeToStock.MTS_Mat_ID) As MatCost
ON MTS_Mat_ID = MatCost.Product_ID
LEFT JOIN InventoryCount
ON InventoryCount.Product_ID = Product.Product_ID;
-- ORDER BY MTS_MAt_ID

-- view #6 Query 4, shows order summaries by customer
CREATE VIEW OrderSummaryView AS
SELECT CUSTOMERORDER.Order_ID, SUM(Orderline_Total_Cost) TotalOrderCost, Order_Date, CUSTOMER.Cust_ID, CUSTOMER.Cust_L_Name, CUSTOMER.Cust_F_Name, Cust_Phone_No, Cust_Email
FROM OrderlineCalcView INNER JOIN CUSTOMERORDER
ON OrderlineCalcView.ORDER_ID = CUSTOMERORDER.Order_ID
RIGHT JOIN CUSTOMER
ON CUSTOMERORDER.Cust_ID = CUSTOMER.Cust_ID
GROUP BY CUSTOMERORDER.Order_ID, Order_Date, CUSTOMER.Cust_ID, CUSTOMER.Cust_L_Name, CUSTOMER.Cust_F_Name, Cust_Phone_No, Cust_Email;


-- view #7 Query 6, shows noncompliance offenses by carrier and type
CREATE VIEW NonComplianceView AS
SELECT NonCompliance.Carrier_ID, Carrier_Name, Non_Comp_Issue, COUNT(Non_Comp_ID) AS [Noncompliance ID]
FROM Carrier INNER JOIN NonCompliance
ON Carrier.Carrier_ID = NonCompliance.Carrier_ID
GROUP BY Carrier_Name, Non_Comp_Issue, NonCompliance.Carrier_ID;
-- ORDER BY Carrier_Name

-- view #8 Query 7, shows the performance of employees.
CREATE VIEW PerformanceReportView AS
SELECT S_EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, SUM(ORDERLINE_TOTAL_COST) AS TOTALREVENUE
FROM CUSTOMERORDER
INNER JOIN EMPLOYEE
ON CUSTOMERORDER.S_EMPL_ID = EMPLOYEE.EMPL_ID
INNER JOIN OrderlineCalcView
ON CUSTOMERORDER.ORDER_ID = OrderlineCalcView.ORDER_ID
WHERE ORDER_DATE >= GETDATE() -30
GROUP BY S_EMPL_ID, EMPL_F_NAME, EMPL_L_NAME;
-- ORDER BY TOTALREVENUE DESC

-- view #9 Query 8, shows orders that were completed more than 15 days late.
CREATE VIEW LateOrdersView AS
SELECT CUSTOMERORDER.ORDER_ID, CUSTOMERORDER.CUST_ID, CUST_F_NAME, CUST_L_NAME, 
S_EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, STATUS_NAME, ORDER_DATE, ORDER_STATUS_DATE
FROM CUSTOMERORDER
INNER JOIN ORDERSTATUSLOG
ON CUSTOMERORDER.ORDER_ID = ORDERSTATUSLOG.ORDER_ID
INNER JOIN CUSTOMER
ON CUSTOMERORDER.CUST_ID = CUSTOMER.CUST_ID
INNER JOIN EMPLOYEE
ON CUSTOMERORDER.S_EMPL_ID = EMPLOYEE.EMPL_ID
INNER JOIN STATUS
ON ORDERSTATUSLOG.ORDER_STATUS_ID = STATUS.STATUS_ID
WHERE ORDER_STATUS_DATE > (DATEADD(DAY, 15, ORDER_DATE));


DROP VIEW LateOrdersView

--view #10 Query 9 employee rewards
CREATE VIEW EmployeeRewards AS
SELECT EMPLOYEE.EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, EMPL_STATUS_NAME, EMPL_HIRE_DATE,
DATEDIFF(YEAR, EMPL_HIRE_DATE, GETDATE()) AS #YEARSWORKED, EMPL_TYPE, COUNT(ORDER_ID) AS #ORDERS_OR_SHIPMENTS
FROM EMPLOYEE
LEFT JOIN CUSTOMERORDER
ON EMPLOYEE.EMPL_ID = CUSTOMERORDER.S_EMPL_ID
INNER JOIN EMPLSTATUSLOG
ON EMPLOYEE.EMPL_ID = EMPLSTATUSLOG.EMPL_ID
INNER JOIN EMPLSTATUS
ON EMPLSTATUS.EMPL_STATUS_ID = EMPLSTATUSLOG.EMPL_STATUS_ID
WHERE EMPL_TYPE = 'S' AND DATEDIFF(YEAR, EMPL_HIRE_DATE, GETDATE()) IN (5, 10, 25)
AND EMPL_STATUS_NAME = 'ACTIVE'
GROUP BY EMPLOYEE.EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, EMPL_STATUS_NAME, EMPL_HIRE_DATE, EMPL_TYPE
UNION
SELECT EMPLOYEE.EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, EMPL_STATUS_NAME, EMPL_HIRE_DATE,
DATEDIFF(YEAR, EMPL_HIRE_DATE, GETDATE()) AS #YEARSWORKED, EMPL_TYPE, COUNT(SHIP_ID) AS #ORDERS_OR_SHIPMENTS
FROM EMPLOYEE
LEFT JOIN SHIPMENT
ON EMPLOYEE.EMPL_ID = SHIPMENT.T_EMPL_ID
INNER JOIN EMPLSTATUSLOG
ON EMPLOYEE.EMPL_ID = EMPLSTATUSLOG.EMPL_ID
INNER JOIN EMPLSTATUS
ON EMPLSTATUS.EMPL_STATUS_ID = EMPLSTATUSLOG.EMPL_STATUS_ID
WHERE EMPL_TYPE = 'T' AND DATEDIFF(YEAR, EMPL_HIRE_DATE, GETDATE()) IN (5, 10, 25)
AND EMPL_STATUS_NAME = 'ACTIVE'
GROUP BY EMPLOYEE.EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, EMPL_STATUS_NAME, EMPL_HIRE_DATE, EMPL_TYPE;



--dynamic inventory
BEGIN TRANSACTION HAPPY
BEGIN TRY
INSERT INTO CUSTOMERORDER(Cust_ID, S_Empl_ID, Order_Date) VALUES(123456,100000007,GETDATE());
INSERT INTO ORDERLINE(Order_ID,Product_ID,Plant_ID,Orderline_Qty) VALUES(900020,111112,2015,2);
UPDATE T1
SET T1.QTY_ON_HAND= QTY_ON_HAND-ORDERLINE_QTY
FROM INVENTORYCOUNT T1, ORDERLINE T2
WHERE T1.PLANT_ID=T2.PLANT_ID AND T1.PRODUCT_ID=T2.PRODUCT_ID AND T2.PRODUCT_ID=111112 AND T2.PLANT_ID=2015
   	 AND ORDERLINE_QTY=2
PRINT 'YAY'
COMMIT TRANSACTION HAPPY
END TRY
BEGIN CATCH

ROLLBACK TRANSACTION HAPPY;
PRINT 'OH NO'
END CATCH
SELECT * FROM CUSTOMERORDER
SELECT * FROM INVENTORYCOUNT WHERE PRODUCT_ID=111112

FOR ACCESS:
UPDATE T1
SET T1.QTY_ON_HAND=(QTY_ON_HAND- ORDERLINE_QTY)
FROM INVENTORYCOUNT T1, ORDERLINE T2
WHERE T1.PLANT_ID=T2.PLANT_ID AND T1.PRODUCT_ID=T2.PRODUCT_ID AND T2.PRODUCT_ID=[Forms![New Orderline Form]![Product_ID]]
AND T2.PLANT_ID=[Forms![New Orderline Form]![Plant_ID]]
AND ORDERLINE_QTY=[Forms![New Orderline Form]![Orderline_Qty]]

--view #11 Query 10 MTO Turnaround
CREATE VIEW MTOTurnaround AS
SELECT CUSTOMERORDER.ORDER_ID, MTO_MAT_ID, ORDER_DATE, MTO_COMPLETION_DATE, DATEDIFF(DD, ORDER_DATE, MTO_COMPLETION_DATE) AS TURNAROUND_TIME
FROM CUSTOMERORDER
INNER JOIN ORDERLINE
ON CUSTOMERORDER.ORDER_ID = ORDERLINE.ORDER_ID
INNER JOIN MAKETOORDER
ON MAKETOORDER.MTO_MAT_ID = ORDERLINE.PRODUCT_ID

CREATE VIEW ActiveOrdersView AS
SELECT CUSTOMERORDER.order_ID
FROM CUSTOMERORDER INNER JOIN ORDERSTATUSLOG
ON CUSTOMERORDER.Order_ID = orderstatuslog.order_id
GROUP BY CUSTOMERORDER.order_ID
HAVING MAX(Order_Status_ID) = 1 OR MAX(Order_Status_ID) = 2;

