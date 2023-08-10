/*************************************************/
/* Chapter 11,12,13 - APInventory Data Warehouse */
/* Create Database Tables                        */
/* Created: 08/19/2022                           */
/* Modified: 07/20/2023                          */
/* Production Folder                             */
/*************************************************/

USE [APInventoryWarehouse]
GO

/**************/
/* DROP VIEWS */
/**************/

DROP VIEW IF EXISTS [Reports].[MonthlySumInventoryShort]
GO

DROP VIEW IF EXISTS [Reports].[MonthlySumInventory]
GO

DROP VIEW IF EXISTS [Reports].[MonthlyAvgInventory]
GO

DROP VIEW IF EXISTS [Reports].[MonthlyInventoryRanks]
GO

/***************/
/* DROP TABLES */
/***************/

DROP TABLE IF EXISTS [Dimension].[Country]
GO

DROP TABLE IF EXISTS [Dimension].[Inventory]
GO

DROP TABLE IF EXISTS [Fact].[InventoryHistory]
GO

DROP TABLE IF EXISTS [Dimension].[Warehouse]
GO

DROP TABLE IF EXISTS [Dimension].[ProductType]
GO

DROP TABLE IF EXISTS [Dimension].[Product]
GO

DROP TABLE IF EXISTS[Dimension].[Location]
GO

DROP TABLE IF EXISTS [Dimension].[Calendar]
GO

/**************************/
/* DROP AND CREATE SCHEMA */
/**************************/

DROP SCHEMA IF EXISTS [Dimension]
GO

DROP SCHEMA IF EXISTS [Fact]
GO

DROP SCHEMA IF EXISTS [Reports]
GO

CREATE SCHEMA [Dimension]
GO


CREATE SCHEMA [Fact]
GO


CREATE SCHEMA [Reports]
GO

/*****************/
/* CREATE TABLES */
/*****************/

/************/
/* CALENDAR */
/************/

CREATE TABLE [Dimension].[Calendar](
	[CalendarKey] [int] IDENTITY(1,1) NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[CalendarQtr] [int] NULL,
	[CalendarMonth] [int] NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarTxtQuarter] [char](11) NULL,
	[CalendarTxtMonth] [char](3) NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/***********/
/* COUNTRY */
/***********/

CREATE TABLE [Dimension].[Country](
	[CountryKey] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](256) NOT NULL,
	[IS02CountryCode] [nvarchar](2) NOT NULL,
	[IS03CountryCode] [nvarchar](3) NOT NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/************/
/* LOCATION */
/************/

CREATE TABLE [Dimension].[Location](
	[LocKey] [int] IDENTITY(1,1) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[LocName] [varchar](64) NOT NULL,
	[LocCountry] [varchar](64) NOT NULL,
	[LocState] [varchar](64) NOT NULL,
	[LocCity] [varchar](64) NOT NULL,
	[LocAddress] [varchar](64) NOT NULL,
	[LocPostalCode] [varchar](24) NOT NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/***********/
/* PRODUCT */
/***********/

CREATE TABLE [Dimension].[Product](
	[ProdKey] [int] IDENTITY(1,1) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[ProdName] [varchar](64) NOT NULL,
	[RetailPrice] [decimal](10, 2) NOT NULL,
	[WholesalePrice] [decimal](10, 2) NOT NULL,
	[ProdType] [varchar](4) NOT NULL,
	[ProductTypeKey] [int] NOT NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/****************/
/* PRODUCT TYPE */
/****************/

CREATE TABLE [Dimension].[ProductType](
	[ProductTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[ProdType] [varchar](4) NOT NULL,
	[ProdTypeName] [varchar](64) NOT NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/*************/
/* WAREHOUSE */
/*************/

CREATE TABLE [Dimension].[Warehouse](
	[WhKey] [int] IDENTITY(1,1) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[WhName] [varchar](64) NOT NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/*********************/
/* INVENTORY HISTORY */
/*********************/

CREATE TABLE [Fact].[InventoryHistory](
	[CalendarKey] [int] NOT NULL,
	[LocKey] [int] NOT NULL,
	[InvKey] [int] NOT NULL,
	[WhKey] [int] NOT NULL,
	[ProdKey] [int] NOT NULL,
	[ProductTypeKey] [int] NOT NULL,
	[QtyOnHand] [int] NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/*************/
/* INVENTORY */
/*************/

CREATE TABLE [Dimension].[Inventory](
	[InvKey] [int] IDENTITY(1,1) NOT NULL,
	[InvId] [varchar](4) NOT NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO

/*********/
/* VIEWS */
/*********/

/***************************/
/* MONTHLY INVENTORY RANKS */
/***************************/

CREATE VIEW [Reports].[MonthlyInventoryRanks]
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

/*************************/
/* MONTHLY AVG INVENTORY */
/*************************/

CREATE VIEW [Reports].[MonthlyAvgInventory]
-- use below to implement a materialized view
--WITH SCHEMABINDING
AS
WITH WarehouseCTE (
	InvYear,InvQuarterName,InvMonthNo,InvMonthName,LocationId,LocationName
		,InventoryId,WarehouseId,WarehouseName,ProductId,ProductName,ProductType
		,ProdTypeName,MonthlyAvgQtyOnHand
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
	  ,L.LocId             AS LocationId
	  ,L.LocName           AS LocationName
	  ,I.InvId             AS InventoryId
	  ,W.WhId              AS WarehouseId
	  ,W.WhName            AS WarehouseName
	  ,P.ProdId		       AS ProductId
	  ,P.ProdName          AS ProductName
	  ,P.ProdType          AS ProductType
	  ,PT.ProdTypeName     AS ProdTypeName
      ,AVG(IH.[QtyOnHand]) AS MonthlyAvgQtyOnHand
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
GROUP BY YEAR(C.[CalendarDate])
	  ,MONTH(C.[CalendarDate])
	  ,DATEPART(qq,C.[CalendarDate])
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
SELECT InvYear,InvQuarterName,InvMonthNo,InvMonthName,LocationId,LocationName
		,InventoryId,WarehouseId,WarehouseName,ProductType,ProductId,ProductName
		,MonthlyAvgQtyOnHand
FROM WarehouseCTE
GO

/*************************/
/* MONTHLY SUM INVENTORY */
/*************************/

CREATE VIEW [Reports].[MonthlySumInventory]
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
WHERE C.[CalendarDate] = EOMONTH(CONVERT(VARCHAR,YEAR(C.[CalendarDate])),(MONTH(C.[CalendarDate]) - 1))
)
SELECT InvYear,InvQuarterName,InvMonthNo,InvMonthName,AsOfDate,LocationId,LocationName
		,InventoryId,WarehouseId,WarehouseName,ProductType,ProductId,ProductName
		,MonthlySumQtyOnHand
FROM WarehouseCTE
GO

/*******************************/
/* MONTHLY SUM INVENTORY SHORT */
/*******************************/

CREATE VIEW [Reports].[MonthlySumInventoryShort]
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


