1.
SELECT SHIP_ID, SHIP_EXEC_DATE, SHIP_PLN_ARR_DATE, CARRIER.CARRIER_ID, CARRIER_NAME, CARRIER_CUST_REP_PHONE_NO, EMPL_ID, EMPL_F_NAME, EMPL_L_NAME, EMPL_PHONE_NO, PLANT.PLANT_ID
FROM ((SHIPMENT LEFT JOIN CARRIER
ON SHIPMENT.CARRIER_ID = CARRIER.CARRIER_ID)
LEFT JOIN EMPLOYEE
ON SHIPMENT.T_EMPL_ID = EMPLOYEE.EMPL_ID)
LEFT JOIN PLANT
ON SHIPMENT.PLANT_ID = PLANT.PLANT_ID
WHERE Plant.Plant_ID = [Please enter a specific plant:] AND (Ship_Pln_Arr_Date BETWEEN [Enter the beginning of the date range Ex 01-JAN-2001:] AND [Enter the end of the date range Ex 01-FEB-2001:]);

6. 
SELECT NonCompliance.Carrier_ID, Carrier.Carrier_Name, NonCompliance.Non_Comp_Issue, Count(NonCompliance.Non_Comp_ID) AS [# of Offenses]
FROM Carrier INNER JOIN NonCompliance ON Carrier.Carrier_ID = NonCompliance.Carrier_ID
WHERE (((Year([Non_Comp_Date]))=[Enter the desired year:]))
GROUP BY NonCompliance.Carrier_ID, Carrier.Carrier_Name, NonCompliance.Non_Comp_Issue
ORDER BY Carrier.Carrier_Name;
