/********************************************/
/* Chapter 12 - Inventory Database Use Case */
/* Ranking/Window Functions                 */
/* Created: 08/19/2022                      */
/* Modified: 07/20/2023                     */
/* Production                               */
/********************************************/

USE [APInventory]
GO

/*********************************************************************************/
/* Note: load script for the APInventory & APInventoryWarehouse database         */
/* has been revised so that the warehouse table has movement values for each day */
/* This means total monthly inventory quantities are calclulated as the sum of   */
/* daily inventory in values minus the sum of inventory out vlaues appearing     */
/* on the last day of each month                                                  */
/* This code has been modifed and is slightly different from some of the queries */
/* in the book as how the monthly inventory totals are calculated.               */  
/*********************************************************************************/

/****************************/
/* Ranking/Window Functions */
/****************************/

/*
�	RANK() -- does not support window frames
�	DENSE_RANK() -- does not support window frames
�	NTILE() -- does not support window frames
�	ROW_NUMBER() -- does not support window frames
*/

/**********************************/
/* Code to enhance Calendar table */
/**********************************/

-- if you are using old calendar dimension without text columns execute this script

/*
ALTER TABLE APInventory.MasterData.Calendar
ADD CalendarTxtQuarter CHAR(11) NULL
GO

ALTER TABLE APInventory.MasterData.Calendar
ADD CalendarTxtMonth CHAR(3) NULL
GO
*/

UPDATE APInventory.MasterData.Calendar
SET CalendarTxtQuarter = (
CASE	
		WHEN DATEPART(qq,CalendarDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,CalendarDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,CalendarDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,CalendarDate) = 4 THEN '4th Quarter'
	END 
	),
	CalendarTxtMonth = (
		CASE
			WHEN MONTH(CalendarDate)  = 1 THEN 'Jan'
			WHEN MONTH(CalendarDate)  = 2 THEN 'Feb'
			WHEN MONTH(CalendarDate)  = 3 THEN 'Mar'
			WHEN MONTH(CalendarDate)  = 4 THEN 'Apr'
			WHEN MONTH(CalendarDate)  = 5 THEN 'May'
			WHEN MONTH(CalendarDate)  = 6 THEN 'Jun'
			WHEN MONTH(CalendarDate)  = 7 THEN 'Jul'
			WHEN MONTH(CalendarDate)  = 8 THEN 'Aug'
			WHEN MONTH(CalendarDate)  = 9 THEN 'Sep'
			WHEN MONTH(CalendarDate)  = 10 THEN 'Oct'
			WHEN MONTH(CalendarDate)  = 11 THEN 'Nov'
			WHEN MONTH(CalendarDate)  = 12 THEN 'Dec'
		END
	 )
	 GO

SELECT * FROM APInventory.MasterData.Calendar
GO

/********************************************************************************/
/* LISTING 12.1 - Ranking Inventory Movement Out for Swiss Passenger Car Models */
/********************************************************************************/

-- returns number of rows before current rows + current row

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

WITH MonthlyInventoryMovement (
	MovementYear,MovementQuarter,MovQtrName,MovementMonth,MovMonthName
		,InvId,LocId,WhId,ProdId,MonthlyDecrementMovement
)
AS
(
SELECT YEAR(MovementDate) AS MovementYear
	,DATEPART(qq,MovementDate) AS MovementQuarter
	,CASE	
		WHEN DATEPART(qq,MovementDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,MovementDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,MovementDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,MovementDate) = 4 THEN '4th Quarter'
	END AS MovQtrName
	,MONTH(MovementDate) AS MovementMonth
	,CASE
		WHEN MONTH(MovementDate)  = 1 THEN 'Jan'
		WHEN MONTH(MovementDate)  = 2 THEN 'Feb'
		WHEN MONTH(MovementDate)  = 3 THEN 'Mar'
		WHEN MONTH(MovementDate)  = 4 THEN 'Apr'
		WHEN MONTH(MovementDate)  = 5 THEN 'May'
		WHEN MONTH(MovementDate)  = 6 THEN 'June'
		WHEN MONTH(MovementDate)  = 7 THEN 'Jul'
		WHEN MONTH(MovementDate)  = 8 THEN 'Aug'
		WHEN MONTH(MovementDate)  = 9 THEN 'Sep'
		WHEN MONTH(MovementDate)  = 10 THEN 'Oct'
		WHEN MONTH(MovementDate)  = 11 THEN 'Nov'
		WHEN MONTH(MovementDate)  = 12 THEN 'Dec'
	 END AS MovMonthName
	,InvId
	,LocId
	,WhId
	,ProdId
	,SUM(Decrement) AS MonthlyDecrementMovement
FROM Product.InventoryTransaction
GROUP BY YEAR(MovementDate)
	,DATEPART(qq,MovementDate)
	,MONTH(MovementDate)
	,InvId
	,LocId
	,WhId
	,ProdId
/* DEBUG: 
ORDER BY YEAR(MovementDate)
	,DATEPART(qq,MovementDate)
	,MONTH(MovementDate)
	,ProdId
	,MovementDate 
	,InvId
	,LocId
	,WhId
*/
)

SELECT MovementYear
	,MovementQuarter
	,MovQtrName
	,MovementMonth
	,MovMonthName
	,LocId
	,InvId
	,WhId
	,ProdId
	,MonthlyDecrementMovement
	,RANK() OVER (
		PARTITION BY MovementYear
		ORDER BY MonthlyDecrementMovement DESC
		) AS DecRank
FROM MonthlyInventoryMovement
WHERE MovementYear = 2010
AND LocId = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH111'
AND ProdId = 'P209'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*
Missing Index Details from ch12 - ranking queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APInventory (DESKTOP-CEBK38L\Angelo (53))
The Query Processor estimates that implementing the following index could improve the query cost by 50.752%.
*/

/*
USE APInventory
GO

CREATE NONCLUSTERED INDEX <Name of Missing Index, sysname,>
ON Product.InventoryTransaction (InvId,LocId,WhId,ProdId)
INCLUDE (Decrement,MovementDate)
GO
*/

/*******************************************************************/
/* Listing  12.2 � Suggested Index for Inventory Transaction Table */
/*******************************************************************/

DROP INDEX IF EXISTS ieInvIdLocIdWhIdProdIdDecDate
ON Product.InventoryTransaction
GO

CREATE NONCLUSTERED INDEX ieInvIdLocIdWhIdProdIdDecDate
ON Product.InventoryTransaction (InvId,LocId,WhId,ProdId)
INCLUDE (Decrement,MovementDate)
GO

UPDATE STATISTICS Product.InventoryTransaction
GO

/*********************/
/* HOMEWORK SOLUTION */
/*********************/

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


/******************************************************************************/
/* Revised Query to eliminate CASE blocks and use Calendar table date objects */
/******************************************************************************/

WITH MonthlyInventoryMovement (
MovementYear,MovementQuarter,MovQtrName,MovementMonth,MovMonthName,InvId,LocId,WhId,ProdId,MonthlyDecrementMovement
)
AS
(
SELECT C.[CalendarYear] AS MovementYear
	,C.[CalendarQtr] AS MovementQuarter
	,C.CalendarTxtQuarter AS MovQtrName
	,C.[CalendarMonth] AS MovementMonth
	,C.[CalendarTxtMonth] AS MovMonthName
	,InvId
	,LocId
	,WhId
	,ProdId
	,SUM(Decrement) AS MonthlyDecrementMovement
FROM Product.InventoryTransaction IT
JOIN [MasterData].[Calendar] C
ON IT.MovementDate = C.CalendarDate
GROUP BY C.CalendarYear
	,C.CalendarQtr
	,C.CalendarTxtQuarter
	,C.CalendarMonth
	,C.CalendarTxtMonth 
	,InvId
	,LocId
	,WhId
	,ProdId
/* DEBUG: 
ORDER BY YEAR(MovementDate)
	,DATEPART(qq,MovementDate)
	,MONTH(MovementDate)
	,ProdId
	,MovementDate 
	,InvId
	,LocId
	,WhId
*/
)

SELECT MovementYear
	,MovementQuarter
	,MovQtrName
	,MovementMonth
	,MovMonthName
	,LocId
	,InvId
	,WhId
	,ProdId
	,MonthlyDecrementMovement
	,RANK() OVER (
		PARTITION BY MovementYear
		ORDER BY MonthlyDecrementMovement DESC
		) AS DecRank
FROM MonthlyInventoryMovement
WHERE MovementYear = 2010
AND LocId = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH111'
AND ProdId = 'P209'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/******************************************************************/
/* LISTING 12.2 - Suggested Index for Inventory Transaction Table */
/******************************************************************/

DROP INDEX IF EXISTS ieInvIdLocIdWhIdProdIdDecDate
ON Product.InventoryTransaction
GO

CREATE NONCLUSTERED INDEX ieInvIdLocIdWhIdProdIdDecDate
ON Product.InventoryTransaction (InvId,LocId,WhId,ProdId)
INCLUDE (Decrement,MovementDate)
GO

UPDATE STATISTICS Product.InventoryTransaction
GO

/*****************************************************/
/* LISTING 12.3 - SNOWFLAKE Query for Ranking Report */
/*****************************************************/

USE APInventoryWarehouse
GO

UPDATE APInventoryWarehouse.Dimension.Calendar
SET CalendarTxtQuarter = (
CASE	
		WHEN DATEPART(qq,CalendarDate) = 1 THEN '1st Quarter'	
		WHEN DATEPART(qq,CalendarDate) = 2 THEN '2nd Quarter'	
		WHEN DATEPART(qq,CalendarDate) = 3 THEN '3rd Quarter'
		WHEN DATEPART(qq,CalendarDate) = 4 THEN '4th Quarter'
	END 
	),
	CalendarTxtMonth = (
		CASE
			WHEN MONTH(CalendarDate)  = 1 THEN 'Jan'
			WHEN MONTH(CalendarDate)  = 2 THEN 'Feb'
			WHEN MONTH(CalendarDate)  = 3 THEN 'Mar'
			WHEN MONTH(CalendarDate)  = 4 THEN 'Apr'
			WHEN MONTH(CalendarDate)  = 5 THEN 'May'
			WHEN MONTH(CalendarDate)  = 6 THEN 'Jun'
			WHEN MONTH(CalendarDate)  = 7 THEN 'Jul'
			WHEN MONTH(CalendarDate)  = 8 THEN 'Aug'
			WHEN MONTH(CalendarDate)  = 9 THEN 'Sep'
			WHEN MONTH(CalendarDate)  = 10 THEN 'Oct'
			WHEN MONTH(CalendarDate)  = 11 THEN 'Nov'
			WHEN MONTH(CalendarDate)  = 12 THEN 'Dec'
		END
	 )
	 GO

WITH WarehouseCTE (
	InvYear,InvMonthNo,InvMonthMonthName,LocationId,LocationName
		,InventoryId,WarehouseId,WarehouseName,ProductId,ProductName
,ProductType,ProdTypeName,MonthlyQtyOnHand
) 
AS ( -- returns 24,192 rows
SELECT C.CalendarYear        AS InvYear
	  ,C.CalendarMonth     AS InvMonthNo
	  ,C.CalendarTxtMonth  AS InvMonthMonthName
	  ,L.LocId             AS LocationId
	  ,L.LocName           AS LocationName
	  ,I.InvId             AS InventoryId
	  ,W.WhId              AS WarehouseId
	  ,W.WhName            AS WarehouseName
	  ,P.ProdId		     AS ProductId
	  ,P.ProdName          AS ProductName
	  ,P.ProdType          AS ProductType
	  ,PT.ProdTypeName     AS ProdTypeName
      ,SUM(IH.[QtyOnHand]) AS MonthlyQtyOnHand
FROM [Fact].[InventoryHistory] IH -- WITH (INDEX(ieInvHistCalendar))
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
GROUP BY C.CalendarYear
	  ,C.CalendarMonth
	  ,C.CalendarTxtMonth
	  ,L.LocId
	  ,L.LocName
	  ,I.InvId
	  ,W.WhId
	  ,W.WhName
	  ,P.ProdId
	  ,P.ProdName
	  ,P.ProdType
	  ,PT.ProdTypeName
)
SELECT InvYear,InvMonthNo,InvMonthMonthName,LocationId,LocationName
		,InventoryId,WarehouseId, ProductType,ProductId,ProdTypeName
		,MonthlyQtyOnHand
		,RANK() OVER (
			ORDER BY MonthlyQtyOnHand DESC
			) QtyOnHandRank
FROM WarehouseCTE
WHERE InvYear= 2010
AND LocationId = 'LOC1'
AND InventoryId = 'INV1'
AND WarehouseId = 'WH111'
AND ProductId = 'P041'
GO

/******************************************************************/
/* LISTING 12.4 - Comparing Ranking between RANK() & DENSE_RANK() */
/******************************************************************/

USE APInventory
GO

-- returns number of rows before current rows + current row with no gaps

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

WITH MonthlyInventoryMovement (
	MovementYear,MovementQuarter,MovementMonth,InvId
	,LocId,WhId,ProdId,MonthlyDecrementMovement
)
AS
(
SELECT YEAR(MovementDate) AS MovementYear
	,DATEPART(qq,MovementDate) AS MovementQuarter
	,MONTH(MovementDate) AS MovementMonth
	,InvId
	,LocId
	,WhId
	,ProdId
	,SUM(Decrement) AS MonthlyDecrementMovement
FROM Product.InventoryTransaction
GROUP BY YEAR(MovementDate)
	,DATEPART(qq,MovementDate)
	,MONTH(MovementDate)
	,InvId
	,LocId
	,WhId
	,ProdId
/* DEBUG: 
ORDER BY YEAR(MovementDate)
	,DATEPART(qq,MovementDate)
	,MONTH(MovementDate)
	,ProdId
	,MovementDate 
	,InvId
	,LocId
	,WhId
*/
)

SELECT MovementYear
	,MovementQuarter
	,MovementMonth
	,LocId
	,InvId
	,WhId
	,ProdId
	,MonthlyDecrementMovement
	,RANK() OVER (
		PARTITION BY MovementYear
		ORDER BY MonthlyDecrementMovement DESC
		) AS DecRank
	,DENSE_RANK() OVER (
		PARTITION BY MovementYear
		ORDER BY MonthlyDecrementMovement DESC
		) AS DecDEnseRank
FROM MonthlyInventoryMovement
WHERE MovementYear = 2010
AND LocId = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH111'
AND ProdId = 'P209'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/**************************************************/
/* LISTING 12.5 - Setting Reorder Priority Alerts */
/**************************************************/

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

WITH InventoryReOrderAlert (
 InventoryYear,InventoryMonth,LocId,InvId,WhId,ProdId,ItemsRemaining
)
AS
(
SELECT YEAR(MovementDate) AS InventoryYear
	  ,MONTH(MovementDate) AS InventoryMonth
	  ,IT.LocId
      ,IT.InvId
      ,IT.WhId
      ,IT.ProdId
	  ,SUM(IT.Increment - IT.Decrement) AS ItemsRemaining
FROM APInventory.Product.InventoryTransaction IT
GROUP BY YEAR(MovementDate) 
	  ,MONTH(MovementDate)
	  ,IT.LocId
      ,IT.InvId
      ,IT.WhId
      ,IT.ProdId
/* DEBUG ORDER BY YEAR(MovementDate)
	  ,MONTH(MovementDate)
	  ,IT.LocId
      ,IT.InvId
      ,IT.WhId
      ,IT.ProdId */
)

SELECT
	 InventoryYear
	,InventoryMonth
	,LocId
	,InvId
	,WhId
	,ProdId
	,ItemsRemaining
	,CASE 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 1 THEN 'Order First High Priority Alert'
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 2 THEN 'Order Second High Priority Alert' 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 3 THEN 'Order Third High Priority Alert' 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 4 THEN 'Order Fourth, Medium Priority Alert' 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 5 THEN 'Order Fifth Low Priority Alert' 
		END AS AlertMessage
FROM InventoryReOrderAlert 
WHERE InventoryYear = 2005
  AND Locid = 'LOC1'
  AND InvId = 'INV1'
  AND WhId = 'WH111'
ORDER BY InventoryMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*
Missing Index Details from ch12 - ranking queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APInventory (DESKTOP-CEBK38L\Angelo (70))
The Query Processor estimates that implementing the following index could improve the query cost by 86.0377%.
*/

/*
USE [APInventory]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Product].[InventoryTransaction] ([InvId],[LocId],[WhId])
INCLUDE ([Increment],[Decrement],[MovementDate],[ProdId])
GO
*/

DROP INDEX IF EXISTS [ieInvIdLocIdWhIdIncDecMovDateProdId]
ON [Product].[InventoryTransaction]
GO

CREATE NONCLUSTERED INDEX [ieInvIdLocIdWhIdIncDecMovDateProdId]
ON [Product].[InventoryTransaction] ([InvId],[LocId],[WhId])
INCLUDE ([Increment],[Decrement],[MovementDate],[ProdId])
GO

UPDATE STATISTICS [Product].[InventoryTransaction]
GO

/****************************************************/
/* Listing 12.6 - Report Table replacing CTE logic. */
/****************************************************/

USE [APInventory]
GO

DROP SCHEMA IF EXISTS Reports
GO

CREATE SCHEMA Reports
GO

DROP TABLE IF  EXISTS Reports.InventoryReOrderAlert
GO

CREATE TABLE Reports.InventoryReOrderAlert(
	InventoryYear int NULL,
	InventoryMonth int NULL,
	LocId varchar(4) NOT NULL,
	InvId varchar(4) NOT NULL,
	WhId varchar(5) NOT NULL,
	ProdId varchar(4) NOT NULL,
	ItemsRemaining int NULL
) ON AP_INVENTORY_FG
GO

TRUNCATE TABLE Reports.InventoryReOrderAlert
GO

INSERT INTO Reports.InventoryReOrderAlert
SELECT YEAR(MovementDate) AS InventoryYear
	  ,MONTH(MovementDate) AS InventoryMonth
	  ,IT.LocId
      ,IT.InvId
      ,IT.WhId
      ,IT.ProdId
	  ,SUM(IT.Increment - IT.Decrement) AS ItemsRemaining
FROM APInventory.Product.InventoryTransaction IT
GROUP BY YEAR(MovementDate) 
	  ,MONTH(MovementDate)
	  ,IT.LocId
      ,IT.InvId
      ,IT.WhId
      ,IT.ProdId
ORDER BY YEAR(MovementDate)
	  ,MONTH(MovementDate)
	  ,IT.LocId
      ,IT.InvId
      ,IT.WhId
      ,IT.ProdId 
GO

SELECT * FROM Reports.InventoryReOrderAlert
GO

/******************************************************/
/* Listing 12.7 - Create DDL for the Suggested Index. */
/******************************************************/

DROP INDEX IF EXISTS ieYearLocIdInvIdWhIdInventoryMonthProdIdItemsRemaining
ON Reports.InventoryReOrderAlert
GO

CREATE NONCLUSTERED INDEX ieYearLocIdInvIdWhIdInventoryMonthProdIdItemsRemaining
ON Reports.InventoryReOrderAlert (InventoryYear,LocId,InvId,WhId)
INCLUDE (InventoryMonth,ProdId,ItemsRemaining)
GO

UPDATE STATISTICS Reports.InventoryReOrderAlert
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

/******************************************/
/* Try the query against the report table */
/* Also Generate the estimated query plan */
/******************************************/

SELECT
	 InventoryYear
	,InventoryMonth
	,LocId
	,InvId
	,WhId
	,ProdId
	,ItemsRemaining
	,CASE 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 1 THEN 'Order First High Priority Alert'
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 2 THEN 'Order Second High Priority Alert' 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 3 THEN 'Order Third High Priority Alert' 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 4 THEN 'Order Fourth, Medium Priority Alert' 
		WHEN NTILE(5) OVER(
		ORDER BY ItemsRemaining ASC 
		) = 5 THEN 'Order Fifth Low Priority Alert' 
		END AS AlertMessage
FROM Reports.InventoryReOrderAlert 
WHERE InventoryYear = 2005
  AND Locid = 'LOC1'
  AND InvId = 'INV1'
  AND WhId = 'WH111'
ORDER BY InventoryMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*
Missing Index Details from SQLQuery3.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APInventory (DESKTOP-CEBK38L\Angelo (66))
The Query Processor estimates that implementing the following index could improve the query cost by 78.2161%.
*/

/*
USE [APInventory]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Reports].[InventoryReOrderAlert] ([InventoryYear],[LocId],[InvId],[WhId])
INCLUDE ([InventoryMonth],[ProdId],[ItemsRemaining])
GO
*/

DROP INDEX IF EXISTS ieYearLocIdInvIdWhIdInventoryMonthProdIdItemsRemaining
ON Reports.InventoryReOrderAlert
GO

CREATE NONCLUSTERED INDEX ieYearLocIdInvIdWhIdInventoryMonthProdIdItemsRemaining
ON Reports.InventoryReOrderAlert (InventoryYear,LocId,InvId,WhId)
INCLUDE (InventoryMonth,ProdId,ItemsRemaining)
GO

UPDATE STATISTICS Reports.InventoryReOrderAlert
GO

/***************************************************************/
/* Listing  12.8 � Generating Random Values using ROW_NUMBER() */
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

WITH InventoryMovement (
AsOfYear,AsOfQuarter,AsOfMonth,AsOfDate,LocId,InvId,WhId,ProdId,InvOut,InvIn
)
AS
(
SELECT AsOfYear
	,CASE
		WHEN DATEPART(qq,AsOfDate)  = 1 THEN 'Qtr 1'
		WHEN DATEPART(qq,AsOfDate)  = 2 THEN 'Qtr 2'
		WHEN DATEPART(qq,AsOfDate)  = 3 THEN 'Qtr 3'
		WHEN DATEPART(qq,AsOfDate)  = 4 THEN 'Qtr 4'
	  END AS AsOfQuarter
	 ,CASE
		WHEN MONTH(AsOfDate)  = 1 THEN 'Jan'
		WHEN MONTH(AsOfDate)  = 2 THEN 'Feb'
		WHEN MONTH(AsOfDate)  = 3 THEN 'Mar'
		WHEN MONTH(AsOfDate)  = 4 THEN 'Apr'
		WHEN MONTH(AsOfDate)  = 5 THEN 'May'
		WHEN MONTH(AsOfDate)  = 6 THEN 'June'
		WHEN MONTH(AsOfDate)  = 7 THEN 'Jul'
		WHEN MONTH(AsOfDate)  = 8 THEN 'Aug'
		WHEN MONTH(AsOfDate)  = 9 THEN 'Sep'
		WHEN MONTH(AsOfDate)  = 10 THEN 'Oct'
		WHEN MONTH(AsOfDate)  = 11 THEN 'Nov'
		WHEN MONTH(AsOfDate)  = 12 THEN 'Dec'
	  END AS AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,ROUND(CEILING(RAND(ROW_NUMBER() OVER (
	PARTITION BY AsOfYear,DATEPART(qq,AsOfDate)
	ORDER BY AsOfDate
	))
	* 85 *
	RAND(ROW_NUMBER() OVER (
	PARTITION BY AsOfYear
	ORDER BY AsOfDate
	) * 1900
	)),1) AS InvOut
	,ROUND(CEILING(RAND(ROW_NUMBER() OVER (
	PARTITION BY AsOfYear,DATEPART(qq,AsOfDate)
	ORDER BY AsOfDate
	))
	* 100 *
	RAND(ROW_NUMBER() OVER (
	PARTITION BY AsOfYear
	ORDER BY AsOfDate
	) * 100000
	)),1) AS InvIn
FROM Product.Warehouse
WHERE AsOfYear = 2002
AND ProdId = 'P101'
AND Locid = 'LOC1'
AND InvId = 'INV1'
AND WhId = 'WH112'
GROUP BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
)
SELECT AsOfYear
	,AsOfQuarter
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,InvOut
	,InvIn
	,InvIn - InvOut AS QtyOnHand
FROM InventoryMovement
ORDER BY AsOfYear
	,AsOfQuarter
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/**********************************************************/
/* Listing  12.9 � TSQL VIEW to Support Inventory Ranking */
/************************************&*********************/

USE APInventoryWarehouse
GO

/* Report Builder Filters for SSRS reports
AND LocationId = 'LOC1'
AND InventoryId = 'INV1'
AND WarehouseId = 'WH111'
AND ProductId = 'P041'
GO
*/

CREATE OR ALTER VIEW Reports.MonthlyInventoryRanks
-- use below to implement a materialized view
--WITH SCHEMABINDING
AS
WITH WarehouseCTE (
	InvYear,InvMonthNo,InvMonthName,LocationId,LocationName
		,InventoryId,WarehouseId,WarehouseName,ProductId,ProductName,ProductType
		,ProdTypeName,MonthlyQtyOnHand
) 
AS ( -- returns 24,192 rows
SELECT YEAR(C.[CalendarDate])  AS InvYear
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
	  ,L.LocId             AS LocationId
	  ,L.LocName           AS LocationName
	  ,I.InvId             AS InventoryId
	  ,W.WhId              AS WarehouseId
	  ,W.WhName            AS WarehouseName
	  ,P.ProdId		       AS ProductId
	  ,P.ProdName          AS ProductName
	  ,P.ProdType          AS ProductType
	  ,PT.ProdTypeName     AS ProdTypeName
      ,IH.[QtyOnHand] AS MonthlyQtyOnHand
FROM [Fact].[InventoryHistory] IH -- WITH (INDEX(ieInvHistCalendar))
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
WHERE C.[CalendarDate] = EOMONTH(CONVERT(VARCHAR,YEAR(C.[CalendarDate])),(MONTH(C.[CalendarDate]) - 1))
)
SELECT InvYear,InvMonthNo,InvMonthName,LocationId,LocationName
		,InventoryId,WarehouseId,WarehouseName,ProductType,ProductId,ProductName
		,MonthlyQtyOnHand
		,RANK() OVER (
			PARTITION BY InvYear,InvMonthNo,InvMonthName,LocationId,InventoryId,WarehouseId
			ORDER BY MonthlyQtyOnHand DESC
			) QtyOnHandRank2
FROM WarehouseCTE
GO

/*****************/
/*  the VIEW */
/*****************/

SELECT * FROM Reports.MonthlyInventoryRanks
GO

/*****************************************/
/* Filter Queries (used in SSRS reports) */
/*****************************************/

-- do not add a GO after query, Report Builder does not like it!

-- inventory year

SELECT DISTINCT InvYear
FROM APInventoryWarehouse.Reports.MonthlyInventoryRanks
ORDER BY 1

-- inventory month

SELECT DISTINCT InvMonthName
FROM APInventoryWarehouse.Reports.MonthlyInventoryRanks
ORDER BY 1

-- inventory location id

SELECT DISTINCT LocationId
FROM APInventoryWarehouse.Reports.MonthlyInventoryRanks
ORDER BY 1

-- inventory id

SELECT DISTINCT InventoryId
FROM APInventoryWarehouse.Reports.MonthlyInventoryRanks
ORDER BY 1

-- inventory warehouse id

SELECT DISTINCT WarehouseId
FROM APInventoryWarehouse.Reports.MonthlyInventoryRanks
ORDER BY 1

-- inventory product id

SELECT DISTINCT ProductId
FROM APInventoryWarehouse.Reports.MonthlyInventoryRanks
ORDER BY 1

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






