https://msdn.microsoft.com/en-us/vba/access-vba/articles/form-error-event-access

/* Report 1:
This report gives the ability to look up a customer by their last name and shows all relevant information
about them in the database. The database generates the unique customer ID, first name, last name, 
street address, city, state, postal code, country, phone number and email address. */
 
SQL Access Code:
SELECT *
FROM CUSTOMER
WHERE CUST_L_NAME = ["Please enter the customer's last name:"];
 
 
/* Report 2:
This report shows the turnaround time between the order date and the completion date for each Made to Order Material.
The database generates the Order ID, the Made to Order Material ID, the Order Date, the Made to order Completion date,
 and the Turnaround time in number of days. */

SQL Code:
CREATE VIEW MTOTurnaround AS
SELECT CUSTOMERORDER.ORDER_ID, MTO_MAT_ID, ORDER_DATE, MTO_COMPLETION_DATE, 
DATEDIFF(DD, ORDER_DATE, MTO_COMPLETION_DATE) AS TURNAROUND_TIME
FROM CUSTOMERORDER
INNER JOIN ORDERLINE
ON CUSTOMERORDER.ORDER_ID = ORDERLINE.ORDER_ID
INNER JOIN MAKETOORDER
ON MAKETOORDER.MTO_MAT_ID = ORDERLINE.PRODUCT_ID
 
 
/* Report 3:
This report shows a list of the planned shipments and information about the shipment, the carrier, 
the Planning Team member who planned it, and the plant from which each shipment will be shipped.  
The report also includes the ability to search by plant and date range. The database generates the unique
 shipment ID, the Expected date, the Planned Arrival Date, the Carrier ID, the Carrier Name, the Representative’s
 Phone Number, the Employee ID, the Employee Name, the Employee Phone Number, and the Plant ID it was shipped from. */
 
SQL Code:
CREATE VIEW PlannedShipmentsView AS
SELECT SHIP_ID, SHIP_EXEC_DATE, SHIP_PLN_ARR_DATE, CARRIER.CARRIER_ID, CARRIER_NAME, CARRIER_CUST_REP_PHONE_NO,
EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, EMPL_PHONE_NO, PLANT.PLANT_ID
FROM SHIPMENT
LEFT JOIN CARRIER
ON SHIPMENT.CARRIER_ID = CARRIER.CARRIER_ID
LEFT JOIN EMPLOYEE
ON SHIPMENT.T_EMPL_ID = EMPLOYEE.EMPL_ID
LEFT JOIN PLANT
ON SHIPMENT.PLANT_ID = PLANT.PLANT_ID
 
 
Access Code:
SELECT *
FROM PlannedShipmentsView
WHERE PlannedShipmentsView.Plant_ID = [Please enter a specific plant:] 
AND (PlannedShipmentsView.Ship_Pln_Arr_Date BETWEEN [Enter the beginning of the date range Ex 01-JAN-2001:] AND [Enter the end of the date range Ex 01-FEB-2001:]);
 
 
 
/* Report 4:
This report shows the number of orders and the total cost of the orders placed by each customer.  
The purpose of this report is to identify the top customers and the customers who have not placed any 
orders within a given date range.  It also includes the ability to search by customer and date range
 and shows the total cost of that customer’s orders. The database generates the total number of orders
 from the customer, the total cost of those orders, the order date, the unique customer ID, the customer’s name,
 phone number, and email. */
SQL Code:
CREATE VIEW OrderSummaryView AS
SELECT CUSTOMERORDER.Order_ID, SUM(Orderline_Total_Cost) TotalOrderCost, Order_Date, CUSTOMER.Cust_ID, 
CUSTOMER.Cust_L_Name, CUSTOMER.Cust_F_Name, Cust_Phone_No, Cust_Email
FROM ORDERLINECALCVIEW INNER JOIN CUSTOMERORDER
ON ORDERLINECALCVIEW.ORDER_ID = CUSTOMERORDER.Order_ID
RIGHT JOIN CUSTOMER
ON CUSTOMERORDER.Cust_ID = CUSTOMER.Cust_ID
GROUP BY CUSTOMERORDER.Order_ID, Order_Date, CUSTOMER.Cust_ID, CUSTOMER.Cust_L_Name, 
CUSTOMER.Cust_F_Name, Cust_Phone_No, Cust_Email
 
SQL Access Code:
SELECT COUNT(Order_ID) AS TotalOrders, SUM(TotalOrderCost) AS TotalCost_PlacedOrders, Order_Date, Cust_ID,
 Cust_L_Name, Cust_F_Name, Cust_Phone_No, Cust_Email
FROM OrderSummaryView
WHERE Cust_L_Name = [Please Enter Customer Last Name] 
AND Cust_F_Name = [Please Enter Customer First Name] 
AND (Order_Date BETWEEN [Please Enter Beginning Date Range Ex '01-JAN-2017':] 
AND [Please Enter Ending Date Range Ex '01-FEB-2017':])
GROUP BY Order_Date, Cust_ID, Cust_L_Name, Cust_F_Name, Cust_Phone_No, Cust_Email;
 
 
 
 
/* Report 5:
This report shows carriers with code of conduct violations.  It shows the carrier that committed the violation,
which issue was violated, and how many times the violation occurred within a given year.  */
SQL Code:
CREATE VIEW NONCOMPLIANCEVIEW AS
SELECT NonCompliance.Carrier_ID, Carrier_Name, Non_Comp_Issue, COUNT(Non_Comp_ID)
FROM Carrier INNER JOIN NonCompliance
ON Carrier.Carrier_ID = NonCompliance.Carrier_ID
GROUP BY Carrier_Name, Non_Comp_Issue, NonCompliance.Carrier_ID
 
SQL Access Code:
SELECT NonCompliance.Carrier_ID, Carrier.Carrier_Name, NonCompliance.Non_Comp_Issue, 
Count(NonCompliance.Non_Comp_ID) AS [# of Offenses]
FROM Carrier INNER JOIN NonCompliance ON Carrier.Carrier_ID = NonCompliance.Carrier_ID
WHERE (((Year([Non_Comp_Date]))=[Enter the desired year:]))
GROUP BY NonCompliance.Carrier_ID, Carrier.Carrier_Name, NonCompliance.Non_Comp_Issue
ORDER BY Carrier.Carrier_Name;
 
/* Report 6:
This report shows the number of orders submitted and the amount of revenue brought in by each sales team member
in the last month.  It is used to identify the top performers on the Sales Team and the Sales Team members who
 are not meeting the company’s goals. The report only shows orders from the last 30 days. 
 The database generates the unique employee ID, their name, and the revenue they generated within the past month. */
SQL Code:
CREATE VIEW PerformanceReportView AS
SELECT S_EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, SUM(ORDERLINE_TOTAL_COST) AS TOTALREVENUE
FROM CUSTOMERORDER
INNER JOIN EMPLOYEE
ON CUSTOMERORDER.S_EMPL_ID = EMPLOYEE.EMPL_ID
INNER JOIN ORDERLINECALCVIEW
ON CUSTOMERORDER.ORDER_ID = ORDERLINECALCVIEW.ORDER_ID
WHERE ORDER_DATE >= GETDATE() -30
GROUP BY S_EMPL_ID, EMPL_F_NAME, EMPL_L_NAME
 
SQL Access Code:
SELECT *
FROM PerformanceReportView
ORDER BY TOTALREVENUE DESC;
 
/* Report 7:
This report shows a list of orders that have not been completed within 15 days.  It includes information 
about the customers who placed each order and the Sales Team member who submitted it.  
The report also includes the current status of each item in the order.  It shows only orders that have been completed
and were completed more than 15 days after the customer ordered it. The database generates the unique order ID,
the unique customer ID that completed the order, the customer’s name, the sales team employee ID, the employee’s name,
the order’s status, the order date, and the order status date. */
 
SQL Code:
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
WHERE ORDER_STATUS_ID = 3
AND ORDER_STATUS_DATE > (DATEADD(DAY, 15, ORDER_DATE));
 
SQL Access Code:
SELECT *
FROM LateOrdersView;
 
 
/* Report 8
This report shows current employees who have been working for IP for either 5, 10, or 25 years and 
relevant information about those employees.  If the employee is a Sales Team Member, information about the 
number of orders the have submitted is provided, and if the employee is a Planning Team Member, 
information about the number of shipments they have managed is provided.

The output also only includes employees who are currently employed by IP. The database generates the unique employee ID,
the employee’s name, the status of the employee, the date the employee was hired, the number of years they have worked,
the type of employee they are, and the number of orders submitted if they are a Sales Team member or the 
number of shipments submitted if they are a Planning Team member. */

SQL Code:
CREATE VIEW EmployeeRewardsView AS
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


