
/*******************************************/
/* Chapter 11,12,13 - APInventory Database */
/* Create Database Tables                  */
/* Created: 08/19/2022                     */
/* Modified: 07/20/2023                    */
/* Production Folder                       */
/*******************************************/

USE [APInventory]
GO

/**************/
/* DROP VIEWS */
/**************/

DROP VIEW IF EXISTS [Product].[WarehouseMonthly]
GO

/***************/
/* DROP TABLES */
/***************/

DROP TABLE IF EXISTS [Reports].[InventoryReOrderAlert]
GO

DROP TABLE IF EXISTS [Product].[InventoryTransaction]
GO

DROP TABLE IF EXISTS [Product].[InventorySalesReport]
GO

DROP TABLE IF EXISTS [Product].[InventoryMovementHistory]
GO

DROP TABLE IF EXISTS [Product].[Inventory]
GO

DROP TABLE IF EXISTS [MasterData].[ProductType]
GO

DROP TABLE IF EXISTS [MasterData].[Product]
GO

DROP TABLE IF EXISTS [MasterData].[LocationOld]
GO

DROP TABLE IF EXISTS [MasterData].[Location]
GO

DROP TABLE IF EXISTS [MasterData].[Country]
GO

DROP TABLE IF EXISTS [MasterData].[Calendar]
GO

DROP TABLE IF EXISTS [dbo].[ErrorLog]
GO

DROP TABLE IF EXISTS [Product].[Warehouse]
GO

/****************************/
/* DROP AND RECREATE SCHEMA */
/****************************/

DROP SCHEMA IF EXISTS [MasterData]
GO

DROP SCHEMA IF EXISTS [Product]
GO

DROP SCHEMA IF EXISTS [Reports]
GO

DROP SCHEMA IF EXISTS [Tools]
GO

CREATE SCHEMA [MasterData]
GO

CREATE SCHEMA [Product]
GO

CREATE SCHEMA [Reports]
GO

CREATE SCHEMA [Tools]
GO

/*****************/
/* CREATE TABLES */
/*****************/

CREATE TABLE [Product].[Warehouse](
	[LocId] [varchar](4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[WhName] [varchar](64) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[InvOut] [int] NOT NULL,
	[InvIn] [int] NOT NULL,
	[QtyOnHand] [int] NOT NULL,
	[ReorderLevel] [int] NOT NULL,
	[AsOfYear] [int] NOT NULL,
	[AsOfMonth] [int] NOT NULL,
	[AsOfDate] [varchar](10) NOT NULL
) ON [AP_INVENTORY_FG]
GO

/*************/
/* ERROR LOG */
/*************/

CREATE TABLE [dbo].[ErrorLog](
	[ErrorNo] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProc] [nvarchar](128) NULL,
	[ErrorLine] [int] NULL,
	[ErrorMsg] [nvarchar](4000) NULL,
	[ErrorDate] [datetime] NULL
) ON [AP_INVENTORY_FG]
GO

/************/
/* CALENDAR */
/************/

CREATE TABLE [MasterData].[Calendar](
	[CalendarKey] [int] NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[CalendarQtr] [int] NULL,
	[CalendarMonth] [int] NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarTxtQuarter] [char](11) NULL,
	[CalendarTxtMonth] [char](3) NULL
) ON [AP_INVENTORY_FG]
GO

/***********/
/* COUNTRY */
/***********/

CREATE TABLE [MasterData].[Country](
	[CountryKey] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](256) NOT NULL,
	[IS02CountryCode] [nvarchar](2) NOT NULL,
	[IS03CountryCode] [nvarchar](3) NOT NULL
) ON [AP_INVENTORY_FG]
GO

/************/
/* LOCATION */
/************/

CREATE TABLE [MasterData].[Location](
	[LocKey] [int] IDENTITY(1,1) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[LocName] [varchar](64) NOT NULL,
	[LocCountry] [varchar](64) NOT NULL,
	[LocState] [varchar](64) NOT NULL,
	[LocCity] [varchar](64) NOT NULL,
	[LocAddress] [varchar](64) NOT NULL,
	[LocPostalCode] [varchar](24) NOT NULL
) ON [AP_INVENTORY_FG]
GO

/***********/
/* PRODUCT */
/***********/

CREATE TABLE [MasterData].[Product](
	[ProdId] [varchar](4) NOT NULL,
	[ProdName] [varchar](64) NOT NULL,
	[RetailPrice] [decimal](10, 2) NOT NULL,
	[WholesalePrice] [decimal](10, 2) NOT NULL,
	[ProdType] [varchar](4) NOT NULL
) ON [AP_INVENTORY_FG]
GO

/****************/
/* PRODUCT TYPE */
/****************/

CREATE TABLE [MasterData].[ProductType](
	[ProdType] [varchar](4) NOT NULL,
	[ProdTypeName] [varchar](64) NOT NULL
) ON [AP_INVENTORY_FG]
GO

/*************/
/* INVENTORY */
/*************/

CREATE TABLE [Product].[Inventory](
	[LocId] [varchar](4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[Units] [int] NULL,
	[AsOfDate] [datetime] NOT NULL
) ON [AP_INVENTORY_FG]
GO

/******************************/
/* INVENTORY MOVEMENT HISTORY */
/******************************/

CREATE TABLE [Product].[InventoryMovementHistory](
	[InvId] [varchar](4) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[QtyOnHand] [int] NULL,
	[MovementDate] [date] NOT NULL
) ON [AP_INVENTORY_FG]
GO

/**************************/
/* INVENTORY SALES REPORT */
/**************************/

CREATE TABLE [Product].[InventorySalesReport](
	[AsOfYear] [int] NOT NULL,
	[AsOfMonth] [int] NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[RetailPrice] [money] NOT NULL,
	[InvOutTotal] [int] NULL,
	[SalesTotal] [money] NULL
) ON [AP_INVENTORY_FG]
GO

/*************************/
/* INVENTORY TRANSACTION */
/*************************/

CREATE TABLE [Product].[InventoryTransaction](
	[Increment] [int] NULL,
	[Decrement] [int] NULL,
	[MovementDate] [date] NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[ProdId] [varchar](4) NOT NULL
) ON [AP_INVENTORY_FG]
GO

/***************************/
/* INVENTORY REORDER ALERT */
/***************************/

CREATE TABLE [Reports].[InventoryReOrderAlert](
	[InventoryYear] [int] NULL,
	[InventoryMonth] [int] NULL,
	[LocId] [varchar](4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[ItemsRemaining] [int] NULL
) ON [AP_INVENTORY_FG]
GO

/*********/
/* VIEWS */
/*********/

/*********************/
/* WAREHOUSE MONTHLY */
/*********************/

CREATE   VIEW [Product].[WarehouseMonthly]
AS
SELECT W.[LocId]
      ,W.[InvId]
      ,W.[WhId]
      ,W.[WhName]
      ,W.[ProdId]
      ,W2.InvOut AS InvOut
      ,W2.InvIn AS InvIn
      ,W.[QtyOnHand]
      ,W.[ReorderLevel]
      ,W.[AsOfYear]
      ,W.[AsOfMonth]
      ,W.[AsOfDate]
FROM [Product].[Warehouse] W
JOIN (
	SELECT [LocId]
      ,[InvId]
      ,[WhId]
	  ,[ProdId]
	  ,[AsOfYear]
      ,[AsOfMonth]
	  ,SUM(InvOut) AS InvOut,SUM(InvIn) AS InvIn
	FROM [Product].[Warehouse] 
	GROUP BY [LocId]
      ,[InvId]
      ,[WhId]
	  ,[ProdId]
	  ,[AsOfYear]
      ,[AsOfMonth]
	) W2
ON (
	 W2.[LocId] = W.[LocId]
    AND W2.[InvId] = W.[InvId]
    AND W2.[WhId] = W.[WhId]
	AND W2.[ProdId] = W.[ProdId]
	AND W2.[AsOfYear] = W.[AsOfYear]
    AND W2.[AsOfMonth] = W.[AsOfMonth]
	)
WHERE W.[AsOfDate] = EOMONTH(CONVERT(VARCHAR,YEAR(W.AsOfDate)),(MONTH(W.AsOfDate) - 1))
/*ORDER BY W.[LocId]
      ,W.[InvId]
      ,W.[WhId]
      ,W.[ProdId]
      ,W.[AsOfYear]
      ,W.[AsOfMonth]
      ,W.[AsOfDate]
	*/
GO

/*****************/
/* UTILITY VIEWS */
/*****************/

/***************************/
/* CHECK COLUMN DATA TYPES */
/***************************/

-- USE THIS TO MAKE SURE COLUMNS LIKE ID COLUMNS HAVE THE SAME LENGTH

CREATE OR ALTER VIEW dbo.CheckColumndataTypes
AS
SELECT t.name AS TableName,c.name AS ColumnName,c.max_length AS ColLength,ot.name
FROM sys.tables t
JOIN sys.columns c
ON t.object_id = C.object_id
JOIN sys.types ot
ON c.system_type_id = ot.system_type_id
GO

SELECT DISTINCT * FROM dbo.CheckColumndataTypes
ORDER BY 2
GO
/*************************/
/* CHECK TABLE ROW COUNT */
/*************************/

CREATE OR ALTER VIEW CheckTableRowCount
AS
SELECT t.name,P.rows
FROM sys.tables T
JOIN sys.partitions P
ON T.object_id = P.object_id
GO