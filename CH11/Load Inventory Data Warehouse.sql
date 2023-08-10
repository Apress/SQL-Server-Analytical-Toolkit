USE [APInventoryWarehouse]
GO

/*************************************************/
/* Chapter 11,12,13 - APInventory Data Warehouse */
/* Load Tables from APInventory                  */
/* Created: 05/12/2022                           */
/* Modified: 07/20/2023                          */
/* Production                                    */
/*************************************************/

-- MAKE SURE APInventory HAS BEEN LOADED FIRST!

/*****************************************/
/* SSIS EXECUTE SQL TASK - LOAD CALENDAR */
/*****************************************/

-- These queries can be used in SSIS package tasks
-- to load the Inventory data warehouse

TRUNCATE TABLE APInventoryWarehouse.Dimension.Calendar
GO

INSERT INTO APInventoryWarehouse.Dimension.Calendar
SELECT CalendarYear,CalendarQtr,CalendarMonth,CalendarDate,NULL,NULL
FROM APInventory.MasterData.Calendar
GO

/*****************************************/
/* SSIS EXECUTE SQL TASK - LOAD COUNTRY */
/*****************************************/

TRUNCATE TABLE APInventoryWarehouse.Dimension.Country
GO

INSERT INTO APInventoryWarehouse.Dimension.Country
SELECT [CountryName], [IS02CountryCode], [IS03CountryCode]
FROM APInventory.MasterData.Country
GO

/*****************************************/
/* SSIS EXECUTE SQL TASK - LOAD LOCATION */
/*****************************************/

TRUNCATE TABLE APInventoryWarehouse.Dimension.[Location]
GO

INSERT INTO APInventoryWarehouse.Dimension.[Location]
SELECT [LocId], [LocName], [LocCountry], [LocState], [LocCity], [LocAddress], [LocPostalCode]
FROM APInventory.MasterData.[Location]
GO

/*********************************************/
/* SSIS EXECUTE SQL TASK - LOAD PRODUCT TYPE */
/*********************************************/

TRUNCATE TABLE APInventoryWarehouse.Dimension.[ProductType]
GO

INSERT INTO APInventoryWarehouse.Dimension.[ProductType]
SELECT [ProdType], [ProdTypeName]
FROM APInventory.MasterData.[ProductType]
GO

/****************************************/
/* SSIS EXECUTE SQL TASK - LOAD PRODUCT */
/****************************************/

TRUNCATE TABLE APInventoryWarehouse.Dimension.[Product]
GO

INSERT INTO APInventoryWarehouse.Dimension.Product
SELECT [ProdId], [ProdName], [RetailPrice],[WholesalePrice], P.[ProdType],PT.ProductTypeKey
FROM APInventory.MasterData.Product P
JOIN APInventoryWarehouse.Dimension.[ProductType] PT
ON P.ProdType = PT.ProdType
GO

/******************************************/
/* SSIS EXECUTE SQL TASK - LOAD WAREHOUSE */
/******************************************/

TRUNCATE TABLE APInventoryWarehouse.[Dimension].[Warehouse]
GO

INSERT INTO APInventoryWarehouse.[Dimension].[Warehouse]
SELECT DISTINCT 
--	IDENTITY(INT,1,1) AS WarehouseKey 
	[LocId]
    ,[InvId]
    ,[WhId]
    ,[WhName]
--INTO [Dimension].[WarehouseNew]
FROM [APInventory].[Product].[Warehouse]
ORDER BY LocId,InvId
GO

/******************************************/
/* SSIS EXECUTE SQL TASK - LOAD INVENTORY */
/******************************************/

USE [APInventoryWarehouse]
GO

DROP TABLE IF  EXISTS  [Dimension].[Inventory]
GO

CREATE TABLE [Dimension].[Inventory](
	[InvKey] [int] IDENTITY(1,1) NOT NULL,
	[InvId] [varchar](4) NOT NULL
) ON [AP_INVENTORY_WAREHOUSE_FG]
GO


TRUNCATE TABLE APInventoryWarehouse.[Dimension].[Inventory]
GO

INSERT INTO APInventoryWarehouse.[Dimension].[Inventory]
SELECT DISTINCT [InvId]
FROM [APInventory].[Product].[Warehouse]
ORDER BY 1
GO

/**************************************************/
/* SSIS EXECUTE SQL TASK - LOAD INVENTORY HISTORY */
/**************************************************/

-- 736320 rows

TRUNCATE TABLE APInventoryWarehouse.[Fact].[InventoryHistory]
GO

-- need to also include current quantity on hand in calculation 

INSERT INTO APInventoryWarehouse.[Fact].[InventoryHistory]
SELECT  C.CalendarKey
	,L.LocKey
	,I.InvKey
	,W.[WhKey]
	,P.ProdKey
	,P.[ProductTypeKey]
	,IT.[QtyOnHand] AS QtyOnHand
FROM APInventory.Product.Warehouse IT
JOIN APInventoryWarehouse.[Dimension].[Calendar] C
ON IT.[AsOfDate] = C.[CalendarDate]
JOIN APInventoryWarehouse.[Dimension].[Location] L
ON IT.LocId = L.[LocId]
JOIN APInventoryWarehouse.[Dimension].[Warehouse] W
ON IT.WhId = W.WhId
JOIN APInventoryWarehouse.[Dimension].[Inventory] I
ON IT.InvId = I.InvId
JOIN APInventoryWarehouse.Dimension.Product P
ON IT.ProdId = P.ProdId
GO

/*****************/
/* BUILD INDEXES */
/*****************/

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

DROP INDEX IF EXISTS [ieInvHistCalendar]
ON APInventoryWarehouse.[Fact].[InventoryHistory]
GO

CREATE NONCLUSTERED INDEX ieInvHistCalendar
ON APInventoryWarehouse.[Fact].[InventoryHistory] ([CalendarKey])
GO

/****************/
/* Location Key */
/****************/

DROP INDEX IF EXISTS [ieInvHistLocKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory]
GO

CREATE NONCLUSTERED INDEX [ieInvHistLocKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory] ([LocKey])
GO

/*****************/
/* Inventory Key */
/*****************/

DROP INDEX IF EXISTS [ieInvHistInvKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory]
GO

CREATE NONCLUSTERED INDEX [ieInvHistInvKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory] ([InvKey])
GO

/*****************/
/* Warehouse Key */
/*****************/

DROP INDEX IF EXISTS [ieInvHistWHKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory]
GO

CREATE NONCLUSTERED INDEX [ieInvHistWHKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory] ([WHKey])
GO

/***************/
/* Product Key */
/***************/

DROP INDEX IF EXISTS [ieInvHistProdKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory]
GO

CREATE NONCLUSTERED INDEX [ieInvHistProdKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory] ([ProdKey])
GO

/********************/
/* Product Type Key */
/********************/

DROP INDEX IF EXISTS [ieInvHistProdTypeKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory]
GO

CREATE NONCLUSTERED INDEX [ieInvHistProdTypeKey]
ON APInventoryWarehouse.[Fact].[InventoryHistory] ([ProductTypeKey])
GO

/***************************/
/* Update Table Statistics */
/***************************/

UPDATE STATISTICS APInventoryWarehouse.[Fact].[InventoryHistory]
GO

-- Use these VIEWs to check data type and length consistency
-- across columns and also table row counts

CREATE OR ALTER VIEW [dbo].[CheckColumnDataTypes]
AS
SELECT t.name AS TableName,c.name AS ColumnName,c.max_length AS ColLength,ot.name
FROM sys.tables t
JOIN sys.columns c
ON t.object_id = C.object_id
JOIN sys.types ot
ON c.system_type_id = ot.system_type_id
GO

SELECT * FROM [dbo].[CheckColumnDataTypes]
GO

CREATE OR ALTER  VIEW [dbo].[CheckTableRowCount]
AS
SELECT t.name,P.rows
FROM sys.tables T
JOIN sys.partitions P
ON T.object_id = P.object_id
GO

SELECT DISTINCT * FROM [dbo].[CheckTableRowCount]
GO









  


