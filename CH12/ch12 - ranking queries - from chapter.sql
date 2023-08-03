USE [APInventory]
GO

-- Listing  12.1 – Ranking Inventory Movement Out for Swiss Passenger Car Models

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
	,InvId,LocId,WhId,ProdId
	,SUM(Decrement) AS MonthlyDecrementMovement
FROM Product.InventoryTransaction
GROUP BY YEAR(MovementDate)
	,DATEPART(qq,MovementDate)
	,MONTH(MovementDate)
	,InvId
	,LocId
	,WhId
	,ProdId
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
-- Listing  12.2 – Suggested Index for Inventory Transaction Table
CREATE NONCLUSTERED INDEX ieInvIdLocIdWhIdProdIdDecDate
ON Product.InventoryTransaction (InvId,LocId,WhId,ProdId)
INCLUDE (Decrement,MovementDate)
GO

UPDATE STATISTICS Product.InventoryTransaction
GO
-- Listing  12.3 – SNOWFLAKE Query for Ranking Report
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
CREATE UNIQUE CLUSTERED INDEX ieCalendarKey
ON [Dimension].[Calendar](CalendarKey)
GO
-- Listing  12.4 – Comparing Ranking between RANK() & DENSE_RANK()
WITH MonthlyInventoryMovement (
MovementYear,MovementQuarter,MovementMonth,InvId,LocId,WhId
,ProdId,MonthlyDecrementMovement
)
AS
(
SELECT YEAR(MovementDate)        AS MovementYear
	,DATEPART(qq,MovementDate) AS MovementQuarter
	,MONTH(MovementDate)       AS MovementMonth
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
-- Listing  12.5 – Setting Reorder Priority Alerts
WITH InventoryReOrderAlert (
 InventoryYear,InventoryMonth,LocId,InvId,WhId,ProdId,ItemsRemaining
)
AS
(
SELECT YEAR(MovementDate)  AS InventoryYear
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
-- Listing  12.6 – Report Table replacing CTE logic.
USE APInventory
GO

DROP SCHEMA IF EXISTS Reports
GO

CREATE SCHEMA Reports
GO

DROP TABLE IF EXISTS Reports.InventoryReOrderAlert
GO

CREATE TABLE Reports.InventoryReOrderAlert(
	InventoryYear int  NULL,
	InventoryMonth int NULL,
	LocId varchar(4)   NOT NULL,
	InvId varchar(4)   NOT NULL,
	WhId varchar(5)    NOT NULL,
	ProdId varchar(4)  NOT NULL,
	ItemsRemaining 	 int NULL
) ON AP_INVENTORY_FG
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
-- Listing  12.7 – Create DDL for the Suggested Index
CREATE NONCLUSTERED INDEX ieYearLocIdInvIdWhIdInventoryMonthProdIdItemsRemaining
ON Reports.InventoryReOrderAlert (InventoryYear,LocId,InvId,WhId)
INCLUDE (InventoryMonth,ProdId,ItemsRemaining)
GO
-- Listing  12.8 – Generating Random Values using ROW_NUMBER()
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
-- Listing  12.9 – TSQL VIEW to Support Inventory Ranking
CREATE VIEW MonthlyInventoryRanks
AS
WITH WarehouseCTE (
	InvYear,InvMonthNo,InvMonthMonthName,LocationId,LocationName
	,InventoryId,WarehouseId,WarehouseName,ProductId,ProductName
,ProductType,ProdTypeName,MonthlyQtyOnHand
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
GROUP BY YEAR(C.[CalendarDate])
	  ,MONTH(C.[CalendarDate])
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
	,InventoryId,WarehouseId,WarehouseName,ProductType,ProductId
,ProductName
	,MonthlyQtyOnHand
	,RANK() OVER (
PARTITION BY InvYear,InvMonthNo,InvMonthName,LocationId
,InventoryId,WarehouseId			
ORDER BY MonthlyQtyOnHand DESC
	) QtyOnHandRank
FROM WarehouseCTE
GO
