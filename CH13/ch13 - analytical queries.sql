/****************************************/
/* Chapter 13 - Inventory Database      */
/* Analytical Functions                 */
/* Created: 08/19/2022                  */
/* Modified: 07/20/2023                 */
/* Production                           */
/****************************************/

/*********************************************************************************/
/* Note: load script for the APInventory & APInventoryWarehouse database         */
/* has been revised so that the warehouse table has movement values for each day */
/* This means total monthly inventory quantities are calclulated as the sum of   */
/* daily inventory in values minus the sum of inventory out vlaues appearing     */
/* on the last day of each month                                                  */
/* This code has been modifed and is slightly different from some of the queries */
/* in the book as how the monthly inventory totals are calculated.               */  
/*********************************************************************************/

USE [APInventory]
GO

/************************/
/* Analytical Functions */
/************************/

/*
•	CUME_DIST() -- does not support window frames
•	FIRST_VALUE() -- supports window frames
•	LAST_VALUE() -- supports window frames
•	LAG() -- does not support window frames
•	LEAD() -- does not support window frames
•	PERCENT_RANK() -- does not support window frames
•	PERCENTILE_CONT() -- does not support window frames
•	PERCENTILE_DISC() -- does not support window frames
*/

/***************************************************************/
/* LISTING 13.1 - Cumulative Distribution for Rolling Averages */
/***************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH YearlyWarehouseReport (
	AsOfYear,AsOfQuarter,AsOfMonth,AsOfDate,LocId,InvId,WhId,ProdId,AvgQtyOnHand
	)
AS
(
SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,AsOfMonth
	-- ,AsOfDate – last day of the month
	-- changed to below as Warehouse table now contains all days of the month
	-- prior version contaned only the last day of the month
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1)) AS AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AVG(QtyOnHand) AS AvgOnHand
FROM Product.Warehouse
GROUP BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	-- ,AsOfDate – last day of the month
	-- changed to below as Warehouse table now contains all days of the month
	-- prior version contaned only the last day of the month
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1))
	,LocId
	,InvId
	,WhId
	,ProdId
/* DEBUG 
ORDER BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
*/
)

SELECT AsOfYear
	,AsOfQuarter
		,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
	,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AvgQtyOnHand AS MonthlyAvgQtyOnHand
	,CUME_DIST() OVER (
		PARTITION BY AsOfYear
		ORDER BY AsOfMonth ASC
		--ORDER BY AvgQtyOnHand
	) AS RollingYearCume
FROM YearlyWarehouseReport
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/****************************************************************/
/* LISTING 13.2 - Rolling First and Last Value Monthly Averages */
/****************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH YearlyWarehouseReport (
	AsOfYear,AsOfQuarter,AsOfMonth,AsOfDate,LocId,InvId,WhId,ProdId,AvgQtyOnHand
	)
AS
(
SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,AsOfMonth
	-- ,AsOfDate – last day of the month
	-- changed to below as Warehouse table now contains all days of the month
	-- prior version contaned only the last day of the month
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1)) AS AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AVG(QtyOnHand) AS AvgQtyOnHand
FROM Product.Warehouse
GROUP BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	-- ,AsOfDate – last day of the month
	-- changed to below as Warehouse table now contains all days of the month
	-- prior version contaned only the last day of the month
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1))
	,LocId
	,InvId
	,WhId
	,ProdId
/* DEBUG 
ORDER BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId 
*/
)

SELECT AsOfYear
	,AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
	,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AvgQtyOnHand AS MonthlyAvgQtyOnHand
	,FIRST_VALUE(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear
		ORDER BY AsOfDate
		) AS FirstValue
	,LAST_VALUE(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear
		ORDER BY AsOfDate
		) AS LastValue
	,LAST_VALUE(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear
		ORDER BY AsOfDate
		) -	FIRST_VALUE(AvgQtyOnHand) OVER (
			PARTITION BY AsOfYear
			ORDER BY AsOfDate
		) AS Change
FROM YearlyWarehouseReport
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*******************************************************************************/
/* LISTING 13.3 – Current Month Movements versus Last Month, Quarter, and Year */
/*******************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH YearlyWarehouseReport (
	AsOfYear,AsOfQuarter,AsOfMonth,AsOfDate,LocId,InvId,WhId,ProdId,AvgQtyOnHand
	)
AS
(
SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,AsOfMonth
	-- ,AsOfDate – last day of the month
	-- changed to below as Warehouse table now contains all days of the month
	-- prior version contaned only the last day of the month
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1)) AS AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AVG(QtyOnHand) AS AvgQtyOnHand
FROM Product.Warehouse
GROUP BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	-- ,AsOfDate – last day of the month
	-- changed to below as Warehouse table now contains all days of the month
	-- prior version contaned only the last day of the month
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1))
	,LocId
	,InvId
	,WhId
	,ProdId
/* DEBUG 
ORDER BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
*/
)

SELECT AsOfYear
	,AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
	,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AvgQtyOnHand AS MonthlyAvgQtyOnHand
	,LAG(AvgQtyOnHand,1,0) OVER (
--		PARTITION BY AsOfYear
		ORDER BY AsOfDate
		) AS PriorMonthAverage
	,LAG(AvgQtyOnHand,3,0) OVER (
--		PARTITION BY AsOfYear
		ORDER BY AsOfDate
		) AS Prior3MonthAverage
	,LAG(AvgQtyOnHand,12,0) OVER (
--		PARTITION BY AsOfYear
		ORDER BY AsOfDate
		) AS Prior12MonthAverage
	,AvgQtyOnHand -LAG(AvgQtyOnHand,1,0) 
		OVER (
--			PARTITION BY AsOfYear
			ORDER BY AsOfDate
			) AS Change
FROM YearlyWarehouseReport
WHERE --AsOfYear IN(2002,2003,2004)
	AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*****************************************/
/* LISTING 13.4 – VIEW replacing the CTE */
/*****************************************/

USE [APInventoryWarehouse]
GO

--DROP VIEW IF EXISTS [Reports].[MonthlyAvgInventory]
--GO

CREATE OR ALTER VIEW [Reports].[MonthlySumInventory]
-- use below to implement a materialized view
--WITH SCHEMABINDING
AS
WITH WarehouseCTE (
	InvYear,InvQuarterName,InvMonthNo,InvMonthName,AsOfDate,LocationId,LocationName
		,InventoryId,WarehouseId,WarehouseName,ProductId,ProductName,ProductType
		,ProdTypeName,MonthlySumQtyOnHand
) 
AS ( 
SELECT YEAR(C.[CalendarDate])  AS InvYear
	  ,CASE	
			WHEN DATEPART(qq,C.[CalendarDate]) = 1 THEN 'Qtr 1'	
			WHEN DATEPART(qq,C.[CalendarDate]) = 2 THEN 'Qtr 2'	
			WHEN DATEPART(qq,C.[CalendarDate]) = 3 THEN 'Qtr 3'
			WHEN DATEPART(qq,C.[CalendarDate]) = 4 THEN 'Qtr 4'
		END AS AsOfQtrName
	  ,MONTH(C.[CalendarDate]) AS InvQuarterName
	  ,CASE
			WHEN MONTH(C.[CalendarDate])  = 1 THEN 'Jan'
			WHEN MONTH(C.[CalendarDate])  = 2 THEN 'Feb'
			WHEN MONTH(C.[CalendarDate])  = 3 THEN 'Mar'
			WHEN MONTH(C.[CalendarDate])  = 4 THEN 'Apr'
			WHEN MONTH(C.[CalendarDate])  = 5 THEN 'May'
			WHEN MONTH(C.[CalendarDate])  = 6 THEN 'June'
			WHEN MONTH(C.[CalendarDate])  = 7 THEN 'Jul'
			WHEN MONTH(C.[CalendarDate])  = 8 THEN 'Aug'
			WHEN MONTH(C.[CalendarDate])  = 9 THEN 'Sep'
			WHEN MONTH(C.[CalendarDate])  = 10 THEN 'Oct'
			WHEN MONTH(C.[CalendarDate])  = 11 THEN 'Nov'
			WHEN MONTH(C.[CalendarDate])  = 12 THEN 'Dec'
	   END AS InvMonthMonthName
	  ,C.[CalendarDate] AS AsOfDate
	  ,L.LocId             AS LocationId
	  ,L.LocName           AS LocationName
	  ,I.InvId             AS InventoryId
	  ,W.WhId              AS WarehouseId
	  ,W.WhName            AS WarehouseName
	  ,P.ProdId		       AS ProductId
	  ,P.ProdName          AS ProductName
	  ,P.ProdType          AS ProductType
	  ,PT.ProdTypeName     AS ProdTypeName
      ,IH.[QtyOnHand] AS MonthlySumQtyOnHand
FROM [Fact].[InventoryHistory] IH 
JOIN [Dimension].[Location] L
	ON IH.LocKey = L.LocKey
JOIN [Dimension].[Calendar] C
	ON IH.CalendarKey = C.CalendarKey
JOIN [Dimension].[Warehouse] W
	ON IH.WhKey = W.WhKey
JOIN [Dimension].[Inventory] I
	ON IH.[InvKey] = I.InvKey
JOIN [Dimension].[Product] P
	ON IH.ProdKey = P.ProdKey
JOIN [Dimension].[ProductType] PT
	ON P.ProductTypeKey = PT.ProductTypeKey
	-- was: WHERE C.[CalendarDate] = AsOfDate – last day of the month
	-- changed to below as Warehouse table now contains all days of the month
	-- prior version contaned only the last day of the month
WHERE C.[CalendarDate] = EOMONTH(CONVERT(VARCHAR,YEAR(C.[CalendarDate])),(MONTH(C.[CalendarDate]) - 1))
)
SELECT InvYear,InvQuarterName,InvMonthNo,InvMonthName,AsOfDate
	,LocationId,LocationName
	,InventoryId,WarehouseId,WarehouseName,ProductType,ProductId
	,ProductName,MonthlySumQtyOnHand
FROM WarehouseCTE
GO

SELECT *
FROM [Reports].[MonthlySumInventory]
WHERE ProductId = 'P033'
AND WarehouseId = 'WH111'
AND InvYear = 2002
GO

CREATE OR ALTER VIEW [Reports].[MonthlySumInventoryShort]
-- use below to implement a materialized view
--WITH SCHEMABINDING
AS
WITH WarehouseCTE (
	InvYear,InvQuarterName,InvMonthNo,InvMonthName,AsOfDate,LocationId,InventoryId,WarehouseId,ProductId,ProductType
		,MonthlySumQtyOnHand
) 
AS ( 
SELECT YEAR(C.[CalendarDate])  AS InvYear
	  ,CASE	
			WHEN DATEPART(qq,C.[CalendarDate]) = 1 THEN 'Qtr 1'	
			WHEN DATEPART(qq,C.[CalendarDate]) = 2 THEN 'Qtr 2'	
			WHEN DATEPART(qq,C.[CalendarDate]) = 3 THEN 'Qtr 3'
			WHEN DATEPART(qq,C.[CalendarDate]) = 4 THEN 'Qtr 4'
	   END AS AsOfQtrName
	  ,MONTH(C.[CalendarDate]) AS InvMonthNo
	  ,CASE
			WHEN MONTH(C.[CalendarDate])  = 1 THEN 'Jan'
			WHEN MONTH(C.[CalendarDate])  = 2 THEN 'Feb'
			WHEN MONTH(C.[CalendarDate])  = 3 THEN 'Mar'
			WHEN MONTH(C.[CalendarDate])  = 4 THEN 'Apr'
			WHEN MONTH(C.[CalendarDate])  = 5 THEN 'May'
			WHEN MONTH(C.[CalendarDate])  = 6 THEN 'June'
			WHEN MONTH(C.[CalendarDate])  = 7 THEN 'Jul'
			WHEN MONTH(C.[CalendarDate])  = 8 THEN 'Aug'
			WHEN MONTH(C.[CalendarDate])  = 9 THEN 'Sep'
			WHEN MONTH(C.[CalendarDate])  = 10 THEN 'Oct'
			WHEN MONTH(C.[CalendarDate])  = 11 THEN 'Nov'
			WHEN MONTH(C.[CalendarDate])  = 12 THEN 'Dec'
	   END AS InvMonthMonthName
	  ,C.[CalendarDate] AS AsOfDate
	  ,L.LocId             AS LocationId
	  ,I.InvId             AS InventoryId
	  ,W.WhId              AS WarehouseId
	  ,P.ProdId		       AS ProductId
	  ,P.ProdType          AS ProductType
      ,IH.[QtyOnHand] AS MonthlySumQtyOnHand
FROM [Fact].[InventoryHistory] IH 
JOIN [Dimension].[Location] L
	ON IH.LocKey = L.LocKey
JOIN [Dimension].[Calendar] C
	ON IH.CalendarKey = C.CalendarKey
JOIN [Dimension].[Warehouse] W
	ON IH.WhKey = W.WhKey
JOIN [Dimension].[Inventory] I
	ON IH.[InvKey] = I.InvKey
JOIN [Dimension].[Product] P
	ON IH.ProdKey = P.ProdKey
JOIN [Dimension].[ProductType] PT
	ON P.ProductTypeKey = PT.ProductTypeKey
-- was: WHERE C.[CalendarDate] = AsOfDate – last day of the month
-- changed to below as Warehouse table now contains all days of the month
-- prior version contaned only the last day of the month
WHERE C.[CalendarDate] = EOMONTH(CONVERT(VARCHAR,YEAR(C.[CalendarDate])),(MONTH(C.[CalendarDate]) - 1))
)
SELECT InvYear,InvQuarterName,InvMonthNo,InvMonthName,LocationId
		,InventoryId,WarehouseId,ProductType,ProductId
		,MonthlySumQtyOnHand
		,LAG(MonthlySumQtyOnHand,1,0) OVER (
			PARTITION BY  [LocationId],[InventoryId],[WarehouseId],[ProductId]
			ORDER BY InvYear,InvMonthNo,[LocationId],[InventoryId],[WarehouseId],[ProductId]
		) AS PriorMonthSum
		,LAG(MonthlySumQtyOnHand,3,0) OVER (
			PARTITION BY  [LocationId],[InventoryId],[WarehouseId],[ProductId]
			ORDER BY InvYear,InvMonthNo,[LocationId],[InventoryId],[WarehouseId],[ProductId]
		) AS PriorQuarterSum
		,LAG(MonthlySumQtyOnHand,12,0) OVER (
			PARTITION BY  [LocationId],[InventoryId],[WarehouseId],[ProductId]
			ORDER BY InvYear,InvMonthNo,[LocationId],[InventoryId],[WarehouseId],[ProductId]
		) AS PriorYearSum
FROM WarehouseCTE
WHERE InvYear >= 2002
GO

SELECT *
FROM [Reports].[MonthlySumInventoryShort]
ORDER BY LocationId,InventoryId,WarehouseId,ProductId,InvYear,InvMonthNo
GO

/********************************************************/
/* LISTING 13.5 – LEAD Example that uses the Table VIEW */
/********************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

-- just get top 24 to copy to Excel

-- SELECT TOP 24 [InvYear]
SELECT [InvYear]
	,InvQuarterName
	,InvMonthNo
    ,[InvMonthName]
    ,[LocationId]
    ,[LocationName]
    ,[InventoryId]
    ,[WarehouseId]
    ,[ProductType]
    ,[ProductId]
    ,MonthlySumQtyOnHand
	,LEAD(MonthlySumQtyOnHand,1,0) OVER (
		PARTITION BY [LocationId],[InventoryId],[WarehouseId],[ProductId]
		ORDER BY InvYear,InvMonthNo,[LocationId],[InventoryId]
			,[WarehouseId],[ProductId]
		) AS NextMonthSum
	,LEAD(MonthlySumQtyOnHand,3,0) OVER (
	  	PARTITION BY [LocationId],[InventoryId],[WarehouseId],[ProductId]
		ORDER BY InvYear,InvMonthNo,[LocationId],[InventoryId]
			,[WarehouseId],[ProductId]
		) AS Skip3MonthSum
	  ,LEAD(MonthlySumQtyOnHand,12,0) OVER (
	  	PARTITION BY [LocationId],[InventoryId],[WarehouseId],[ProductId]
		ORDER BY InvYear,InvMonthNo,[LocationId],[InventoryId]
			,[WarehouseId],[ProductId]
		) AS Skip12MonthSum
	  ,MonthlySumQtyOnHand - LEAD(MonthlySumQtyOnHand,1,0) 
		OVER (
		PARTITION BY [LocationId],[InventoryId],[WarehouseId],[ProductId]
		ORDER BY InvYear,InvMonthNo,[LocationId],[InventoryId]
			,[WarehouseId],[ProductId]
			) AS Change
FROM [Reports].[MonthlySumInventory]
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*********************************************************/
/* Listing 13.6 – Percent Rank for Product P101 for 2002 */
/*********************************************************/

USE [APInventory]
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
	,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1))
	,LocId
	,InvId
	,WhId
	,ProdId
	,SUM([InvIn] - [InvOut]) + 50 AS QtyOnHand
	,FORMAT(PERCENT_RANK() OVER (
		PARTITION BY AsOfYear
		ORDER BY SUM([InvIn] - [InvOut]) + 50
	),'P') AS PercentRank
FROM Product.Warehouse
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GROUP BY AsOfYear, 
	DATEPART(qq,AsOfDate),
	AsOfMonth,
	EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1)),
	Locid,
	InvId,
	WhId, 
	ProdId
ORDER BY AsOfYear, 
	AsOfMonth,
	Locid,
	InvId,
	WhId, 
	ProdId
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*************************************************************/
/* LISTING 13.7 - Percentile Continuous for Quantity on Hand */
/*************************************************************/

USE [APInventory]
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE OFF
GO 

/********************************/
/* Generates interpolated value */
/********************************/

SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
		,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,AsOfDate -- last day of the month
	,LocId
	,InvId
	,WhId
	,ProdId
	,QtyOnHand
	,PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Continuous .25]
	,PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Continuous .5]
	,PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Continuous .75]
FROM Product.Warehouse
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO  

-- turn set statistics io/time/profile off

/**********************************************/
/* This query uses the Warehouse monthly VIEW */
/**********************************************/

SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
		,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,AsOfDate -- last day of the month
	,LocId
	,InvId
	,WhId
	,ProdId
	,QtyOnHand
	,PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Continuous .25]
	,PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Continuous .5]
	,PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Continuous .75]
FROM Product.WarehouseMonthly
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

/******************************************************************/
/* LISTING 13.8 - Percentile Discrete Query for Inventory on Hand */
/******************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
		,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,QtyOnHand
	,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete.25]
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete .5]
	,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete .75]
FROM Product.Warehouse
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/********************************************/
/* This query uses the Warehouseonthly VIEW */
/********************************************/

SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
		,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,QtyOnHand
	,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete.25]
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete .5]
	,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete .75]
FROM Product.WarehouseMonthly
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

/*********************/
/* HOMEWORK SOLUTION */
/*********************/

-- Cover all Years

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,CASE	
		WHEN DATEPART(qq,AsOfDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,AsOfDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,AsOfDate) = 4 THEN '4th Quarter'
	END AS AsOfQtrName
	,AsOfMonth
	,CASE
		WHEN AsOfMonth = 1 THEN 'Jan'
		WHEN AsOfMonth = 2 THEN 'Feb'
		WHEN AsOfMonth = 3 THEN 'Mar'
		WHEN AsOfMonth = 4 THEN 'Apr'
		WHEN AsOfMonth = 5 THEN 'May'
		WHEN AsOfMonth = 6 THEN 'June'
		WHEN AsOfMonth = 7 THEN 'Jul'
		WHEN AsOfMonth = 8 THEN 'Aug'
		WHEN AsOfMonth = 9 THEN 'Sep'
		WHEN AsOfMonth = 10 THEN 'Oct'
		WHEN AsOfMonth = 11 THEN 'Nov'
		WHEN AsOfMonth = 12 THEN 'Dec'
	 END AS AvgMonthName
	,EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1)) AS AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,SUM([InvIn] - [InvOut]) + 50 AS QtyOnHand
		,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY  SUM([InvIn] - [InvOut]) + 50)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Discrete .25]
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY  SUM([InvIn] - [InvOut]) + 50)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Discrete .5]
	,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY  SUM([InvIn] - [InvOut]) + 50)
		OVER (
		PARTITION BY AsOfYear
		) AS [%Discrete .75]
FROM Product.Warehouse
GROUP BY AsOfYear, 
	DATEPART(qq,AsOfDate),
	AsOfMonth,
	EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1)),
	Locid,
	InvId,
	WhId, 
	ProdId
ORDER BY AsOfYear, 
	AsOfMonth,
	Locid,
	InvId,
	WhId, 
	ProdId
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/****************************************************/
/* Listing 13.9 – Enhanced Query, at least we hope! */
/****************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

DROP INDEX IF EXISTS pkCalendar
ON MasterData.Calendar
GO

CREATE UNIQUE CLUSTERED INDEX pkCalendar
ON MasterData.Calendar (CalendarYear,CalendarDate)
GO

UPDATE STATISTICS MasterData.Calendar 
GO

SELECT AsOfYear
	,C.CalendarQtr
	,C.CalendarTxtQuarter AS AsOfQtrName
	,C.CalendarTxtMonth AS AvgMonthName
	,C.CalendarDate AS AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,QtyOnHand
	,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete.25]
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete .5]
	,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY QtyOnHand)
		OVER (
			PARTITION BY AsOfYear
		) AS [%Discrete .75]
FROM MasterData.Calendar C
JOIN Product.Warehouse W
ON W.AsOfDate = C.CalendarDate
WHERE C.CalendarYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 


-- Check row counts

USE [APInventory]
GO

SELECT DISTINCT * 
FROM [dbo].[CheckTableRowCount]
ORDER BY 1
GO

USE [APInventoryWarehouse]
GO

SELECT DISTINCT * 
FROM [dbo].[CheckTableRowCount]
ORDER BY 1
GO


