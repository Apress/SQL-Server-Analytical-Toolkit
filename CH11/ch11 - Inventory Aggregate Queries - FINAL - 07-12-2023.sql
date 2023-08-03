/***********************************/
/* Chapter 11 - Inventory Use Case */
/* Aggregate Functions             */
/* Created: 08/01/2022             */
/* Modified: 07/12/2023            */
/***********************************/

/*********************************************************************************/
/* Note: load script for the APInventory & APInventoryWarehouse database         */
/* has been revised so that the warehouse table has movement values for each day */
/* This means total monthly inventory quantities are calclulated as the sum of   */
/* daily inventory in values minus the sum of inventory out vlaues appearing     */
/* on the last day of each month                                                  */
/* This code has been modifed and is slightly different from some of the queries */
/* in the book as how the monthly inventory totals are calculated.               */  
/*********************************************************************************/

/*****************************************************************/
/* Note, all these functions support window frame specifications */
/*****************************************************************/

/**********************************************/
/* Listing 11.1 - Load The Calendar dimension */
/**********************************************/

TRUNCATE TABLE APInventoryWarehouse.Dimension.Calendar
GO

INSERT INTO APInventoryWarehouse.Dimension.Calendar
SELECT CalendarYear,CalendarQtr,CalendarMonth,CalendarDate
FROM APInventory.MasterData.Calendar
GO

/*************************************/
/* Listing 11.2 - Error Trapping Kit */
/*************************************/

CREATE TABLE [dbo].[ErrorLog](
	[ErrorNo]		[int] NULL,
	[ErrorSeverity]	[int] NULL,
	[ErrorState]	[int] NULL,
	[ErrorProc]		[nvarchar](128) NULL,
	[ErrorLine]		[int] NULL,
	[ErrorMsg]		[nvarchar](4000) NULL,
	[ErrorDate]		[datetime]
)
GO

INSERT INTO [dbo].[ErrorLog]
SELECT  
      ERROR_NUMBER()	AS [ERROR_NO]  
     ,ERROR_SEVERITY()	AS [ERROR_SEVERITY]
     ,ERROR_STATE()		AS [ERROR_STATE]  
     ,ERROR_PROCEDURE()	AS [ERROR_PROC] 
     ,ERROR_LINE()		AS [ERROR_LINE] 
     ,ERROR_MESSAGE()	AS [ERROR_MSG]
	,GETDATE()			AS [ERROR_DATE];  
GO

/*************************************************/
/* LISTING 11.3 - INVENTORY LEVEL PROFILE REPORT */
/*************************************************/

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
	LocId,InvId,WhId,ProdId,AsOfYear,AsOfMonth,AsOfDate,InvOut,InvIn,Change,QtyOnHand
)
AS(
SELECT LocId
    ,InvId
	,WhId
    ,ProdId
    ,AsOfYear
    ,AsOfMonth
	,AsOfDate
	,InvOut
	,InvIn
	,(InvIn - InvOut) AS Change
	,(InvIn - InvOut) + LAG(QtyOnHand,1,0) OVER ( 
		PARTITION BY LocId,InvId,WhId,ProdId
		ORDER BY [AsOfDate]
	)AS QtyOnHand -- 05/31/2022
FROM APInventory.Product.WarehouseMonthly
)

SELECT LocId
    ,InvId
	,WhId
    ,ProdId
    ,AsOfYear
    ,AsOfMonth
	,AsOfDate
	,InvOut
	,InvIn
	,Change
	,QtyOnHand
    ,COUNT(*) OVER (
		PARTITION BY AsOfYear,LocId,InvId,WhId,ProdId
		ORDER BY LocId,InvId,WhId,AsOfMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	 ) AS WarehouseLT50
	,MIN(QtyOnHand) OVER (
		PARTITION BY AsOfYear,LocId,InvId,WhId,ProdId
		ORDER BY LocId,InvId,WhId,AsOfMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	   ) AS MinMonthlyQty
	,MAX(QtyOnHand) OVER (
		PARTITION BY AsOfYear,LocId,InvId,WhId,ProdId
		ORDER BY LocId,InvId,WhId,AsOfMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	   ) AS MaxMonthlyQty
	,SUM(QtyOnHand) OVER (
		PARTITION BY AsOfYear,LocId,InvId,WhId,ProdId
		ORDER BY LocId,InvId,WhId,AsOfMonth
		ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
	    ) AS Rolling2MonthlyQty
	 ,AVG(QtyOnHand) OVER (
		PARTITION BY AsOfYear,LocId,InvId,WhId,ProdId
		ORDER BY LocId,InvId,WhId,AsOfMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	    ) AS AvgMonthlyQty
FROM InventoryMovement
WHERE QtyOnHand <= 50
--AND AsOfYear = 2003
AND LocId = 'LOC1'
AND InvId = 'INV1'
AND ProdId ='P033'
ORDER BY LocId
    ,InvId
	,WhId
    ,ProdId
    ,AsOfYear
    ,AsOfMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

DROP INDEX IF EXISTS ieProdWhLocIdInvIdProdIdAsOfYearQtyOnHand
ON [Product].[Warehouse]
GO

CREATE NONCLUSTERED INDEX ieProdWhLocIdInvIdProdIdAsOfYearQtyOnHand
ON [Product].[Warehouse] ([LocId],[InvId],[ProdId],[AsOfYear],[QtyOnHand])
INCLUDE ([AsOfMonth],[AsOfDate])
GO

/*
Missing Index Details from ch11 - Inventory Aggregate Queries - FINAL.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APInventory (DESKTOP-CEBK38L\Angelo (85))
The Query Processor estimates that implementing the following index could improve the query cost by 11.5808%.
*/

/*
USE [APInventory]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Product].[Warehouse] ([LocId],[InvId],[ProdId])
INCLUDE ([InvOut],[InvIn],[AsOfYear],[AsOfMonth])
GO
*/

DROP INDEX IF EXISTS ieInvOutInvInAsOfYearAsOfMonth
ON [Product].[Warehouse] 
GO

CREATE NONCLUSTERED INDEX ieInvOutInvInAsOfYearAsOfMonth
ON [Product].[Warehouse] ([LocId],[InvId],[ProdId])
INCLUDE ([InvOut],[InvIn],[AsOfYear],[AsOfMonth])
GO

UPDATE STATISTICS [Product].[Warehouse]
GO


/*******************************************************/
/* Same Query, more or less against the data warehouse */
/*******************************************************/

/****************************************************************************/
/* Listing 11.4 - Rolling Yearly Averages for inventory Movement In and Out */
/****************************************************************************/

use APInventoryWarehouse
GO

SELECT MovementDate
    ,InvId
    ,LocId
    ,WhId
    ,ProdId
	,Increment
     ,Decrement
	,AVG(CONVERT(DECIMAL(10,5),Increment)) OVER (
		ORDER BY MovementDate
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS MonthlyAvgIncr
	,AVG(CONVERT(DECIMAL(10,5),Decrement)) OVER (
		ORDER BY MovementDate
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS MonthlyAvgDecr
  FROM APInventory.Product.InventoryTransaction
  WHERE ProdId = 'P033'
  AND YEAR(MovementDate) = 2010
  AND MONTH(MovementDate) = 5
  AND WhId = 'WH112'
  GO

/**********************************/
/* Listing 11.5 - Suggested Index */
/**********************************/

CREATE NONCLUSTERED INDEX ieWhIdProdIdMovementDate
ON APInventory.Product.InventoryTransaction (WhId,ProdId)
INCLUDE (Increment,Decrement,MovementDate,InvId,LocId)
GO

/******************************************/
/* Listing 11.6 - Example SNOWFLAKE Query */
/******************************************/

USE APInventoryWarehouse
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

SELECT C.CalendarYear
	  ,C.CalendarMonth
	  ,C.CalendarDate AS AsOfDate
	  ,L.LocId
	  ,L.LocName
	  ,I.InvId
	  ,W.WhId
	  ,P.ProdId
	  ,P.ProdName
	  ,QtyOnHand
	  ,SUM(IH.QtyOnHand) OVER (
			ORDER BY C.CalendarMonth
			ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
		) AS RollingSum
	  ,AVG(SUM(CONVERT(DECIMAL(10,2),IH.QtyOnHand))) OVER (
			ORDER BY C.CalendarMonth
			ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
		) AS RollingAvgOnHand
FROM ApInventoryWarehouse.Fact.InventoryHistory IH
JOIN Dimension.Calendar C 
	ON IH.CalendarKey = C.CalendarKey
JOIN Dimension.Location L
	ON IH.LocKey = L.LocKey
JOIN Dimension.Warehouse W
	ON IH.WhKey = W.WhKey
JOIN Dimension.Inventory I
	ON IH.InvKey = I.InvKey
JOIN Dimension.Product P
	ON IH.ProdKey = P.ProdKey
JOIN Dimension.ProductType PT
	ON P.ProductTypeKey = PT.ProductTypeKey
WHERE C.CalendarYear = 2010

-- Was: AND C.[CalendarDate] = AsOfDate – last day of the month
-- changed to below as Warehouse table now contains all days of the month
-- prior version contaned only the last day of the month
AND C.[CalendarDate] = EOMONTH(CONVERT(VARCHAR,YEAR(C.[CalendarDate])),(MONTH(C.[CalendarDate]) - 1))

AND L.LocId = 'LOC1'
AND I.InvId = 'INV1'
AND W.WhId = 'WH111'
AND P.ProdName LIKE 'French Type 1 Locomotive %'
AND P.ProdId = 'P101'
GROUP BY C.CalendarYear
	  ,C.CalendarMonth
	  ,C.CalendarDate
	  ,L.LocId
	  ,L.LocName
	  ,I.InvId
	  ,W.WhId
	  ,P.ProdId
	  ,P.ProdName
      ,QtyOnHand
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***********************************************************************************/
/* Listing  11.7 – Average and Standard Deviation Report for Inventory Quantities. */
/***********************************************************************************/

USE APInventory
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

WITH YearlyWarehouseReport (
	AsOfYear,AsOfQuarter,AsOfMonth,AsOfDate,LocId,InvId,WhId,ProdId,AvgQtyOnHand)
AS
(
SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AVG(QtyOnHand) AS AvgQtyOnHand
FROM Product.Warehouse
-- changed to below as Warehouse table now contains all days of the month
-- prior version contaned only the last day of the month
WHERE AsOfDate = EOMONTH(CONVERT(VARCHAR,YEAR(AsOfDate)),(MONTH(AsOfDate) - 1))
GROUP BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	,AsOfDate
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
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AvgQtyOnHand AS MonthlyAvgQtyOnHand
	,AVG(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear,WhId
		ORDER BY AsOfYear
		) AS YearlyAvg
	,STDEV(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear,WhId
		ORDER BY AsOfYear
		) AS YearlyStdev
FROM YearlyWarehouseReport
WHERE AsOfYear = 2003
  AND LocId = 'LOC1'
  AND InvId = 'INV1'
  AND ProdId ='P033'
GO

-- turn set statistics io/time/profile off
 
SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/******************************************/
/* LISTING 11.8 - Example SnowFlake Query */
/******************************************/

USE APInventoryWarehouse
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

SELECT C.CalendarYear
	  ,C.CalendarMonth
	  ,C.CalendarDate
	  ,L.LocId
	  ,L.LocName
	  ,I.InvId
	  ,W.WhId
	  ,P.ProdId
	  ,P.ProdName
	  ,SUM(QtyOnHand) As QtyOnHandSum
	  ,AVG(CONVERT(DECIMAL(10,2),IH.QtyOnHand)) OVER (
			PARTITION BY C.CalendarYear
			ORDER BY C.CalendarMonth
		) AS RollingAvg
	  ,STDEV(SUM(IH.QtyOnHand)) OVER (
			PARTITION BY C.CalendarYear
			ORDER BY C.CalendarMonth
		) AS RollingStdev
FROM Fact.InventoryHistory IH
JOIN Dimension.Calendar C 
	ON IH.CalendarKey = C.CalendarKey
JOIN Dimension.Location L
	ON IH.LocKey = L.LocKey
JOIN Dimension.Warehouse W
	ON IH.WhKey = W.WhKey
JOIN Dimension.Inventory I
	ON IH.InvKey = I.InvKey
JOIN Dimension.Product P
	ON IH.ProdKey = P.ProdKey
JOIN Dimension.ProductType PT
	ON P.ProductTypeKey = PT.ProductTypeKey
WHERE L.LocId = 'LOC1'
AND I.InvId = 'INV1'
AND W.WhId = 'WH112'
AND P.ProdName LIKE 'French Type 1 Locomotive%'
AND P.ProdId = 'P101'
AND C.CalendarYear = 2002
GROUP BY C.CalendarYear
	  ,C.CalendarMonth
	  ,C.CalendarDate
	  ,L.LocId
	  ,L.LocName
	  ,I.InvId
	  ,W.WhId
	  ,P.ProdId
	  ,P.ProdName
      ,QtyOnHand
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*******************************************************************/
/* Listing  11.9 – Average, Variance and Standard Deviation Report */
/*******************************************************************/

USE APInventory
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

WITH YearlyWarehouseReport (
	AsOfYear,AsOfQuarter,AsOfMonth,AsOfDate,LocId,InvId,WhId,ProdId,AvgQtyOnHand
	)
AS
(
SELECT AsOfYear
	,DATEPART(qq,AsOfDate) AS AsOfQuarter
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AVG(QtyOnHand) AS AvgQtyOnHand
FROM Product.Warehouse
GROUP BY AsOfYear
	,DATEPART(qq,AsOfDate)
	,AsOfMonth
	,AsOfDate
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
	,AsOfMonth
	,AsOfDate
	,LocId
	,InvId
	,WhId
	,ProdId
	,AvgQtyOnHand AS MonthlyAvgQtyOnHand
	,AVG(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear,WhId
		ORDER BY AsOfYear
		) AS YearlyAvg
	,VAR(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear,WhId
		ORDER BY AsOfYear
		) AS YearlyVar
	,STDEV(AvgQtyOnHand) OVER (
		PARTITION BY AsOfYear,WhId
		ORDER BY AsOfYear
		) AS YearlySTDEV
	/* just to prove that the square root of the variance */
	/* is the standard deviation */
	,SQRT(
			VAR(AvgQtyOnHand) OVER (
			PARTITION BY AsOfYear,WhId
			ORDER BY AsOfYear
			)
		) AS MyYearlyStdev
FROM YearlyWarehouseReport
WHERE AsOfYear = 2003
  AND LocId = 'LOC1'
  AND InvId = 'INV1'
  AND ProdId ='P033'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*
Missing Index Details from ch11 - Inventory Aggregate Queries - NEW.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APInventory (DESKTOP-CEBK38L\Angelo (80))
The Query Processor estimates that implementing the following index could improve the query cost by 75.9964%.
*/

/*
USE [APInventory]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Product].[Warehouse] ([LocId],[InvId],[ProdId],[AsOfYear])
INCLUDE ([QtyOnHand],[AsOfMonth],[AsOfDate])
GO
*/

DROP INDEX IF EXISTS ieProdWhLocIdInvIdProdIdAsOfYear
ON Product.Warehouse 
GO

CREATE NONCLUSTERED INDEX ieProdWhLocIdInvIdProdIdAsOfYear
ON Product.Warehouse (LocId,InvId,ProdId,AsOfYear)
INCLUDE (QtyOnHand,AsOfMonth,AsOfDate)
GO

UPDATE STATISTICS Product.Warehouse
GO

/***********************************************************/
/* LISTING 11.10 - TSQL Script for SSIS Execute TSQL Tasks */
/***********************************************************/

/*******************/
/* CLUSTERED INDEX */
/*******************/

DROP INDEX IF EXISTS pkInventoryHistory
ON APInventoryWarehouse.Fact.InventoryHistory 
GO

CREATE UNIQUE CLUSTERED INDEX pkInventoryHistory
ON APInventoryWarehouse.Fact.InventoryHistory (LocKey,InvKey,WhKey,ProdKey,CalendarKey)
GO

/***********************/
/* NON CLUSTERED INDEX */
/***********************/

DROP INDEX IF EXISTS ieProdProdTypeQty 
ON APInventoryWarehouse.Fact.InventoryHistory
GO

CREATE NONCLUSTERED INDEX ieProdProdTypeQty
ON APInventoryWarehouse.Fact.InventoryHistory (ProdKey)
INCLUDE (ProductTypeKey,QtyOnHand)
GO

/****************/
/* Calendar Key */
/****************/

DROP INDEX IF EXISTS ieInvHistCalendar
ON APInventoryWarehouse. Fact.InventoryHistory
GO

CREATE NONCLUSTERED INDEX ieInvHistCalendar
ON APInventoryWarehouse. Fact.InventoryHistory (CalendarKey)
GO

/****************/
/* Location Key */
/****************/

DROP INDEX IF EXISTS ieInvHistLocKey
ON APInventoryWarehouse.Fact.InventoryHistory
GO

CREATE NONCLUSTERED INDEX ieInvHistLocKey
ON APInventoryWarehouse.Fact.InventoryHistory (LocKey)
GO

/*****************/
/* Inventory Key */
/*****************/

DROP INDEX IF EXISTS ieInvHistInvKey
ON APInventoryWarehouse.Fact.InventoryHistory
GO

CREATE NONCLUSTERED INDEX ieInvHistInvKey
ON APInventoryWarehouse.Fact.InventoryHistory (InvKey)
GO

/*****************/
/* Warehouse Key */
/*****************/

DROP INDEX IF EXISTS ieInvHistWHKey
ON APInventoryWarehouse.Fact.InventoryHistory
GO

CREATE NONCLUSTERED INDEX ieInvHistWHKey
ON APInventoryWarehouse.Fact.InventoryHistory (WHKey)
GO

/***************/
/* Product Key */
/***************/

DROP INDEX IF EXISTS ieInvHistProdKey
ON APInventoryWarehouse.Fact.InventoryHistory
GO

CREATE NONCLUSTERED INDEX ieInvHistProdKey
ON APInventoryWarehouse.Fact.InventoryHistory (ProdKey)
GO

/********************/
/* Product Type Key */
/********************/

DROP INDEX IF EXISTS ieInvHistProdTypeKey
ON APInventoryWarehouse.Fact.InventoryHistory
GO

CREATE NONCLUSTERED INDEX ieInvHistProdTypeKey
ON APInventoryWarehouse.Fact.InventoryHistory (ProductTypeKey)
GO

UPDATE STATISTICS Fact.InventoryHistory
GO





