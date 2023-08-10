/********************************/
/* Create Sales Database Tables */
/* Created BY: Angelo R Bobak   */
/* Created: 08/04/22            */
/* Revised: 07/20/2023          */
/* Production                   */
/********************************/

USE [APSales]
GO

/**************/
/* DROP VIEWS */
/**************/

DROP VIEW IF EXISTS [dbo].[CheckTableRowCount]
GO

DROP VIEW IF EXISTS [dbo].[CheckColumnDataTypes]
GO

DROP VIEW IF EXISTS [DimTable].[CalendarView]
GO

DROP VIEW IF EXISTS [dbo].[SalesPersonActivityReport-TEST]
GO

DROP VIEW IF EXISTS [DimTable].[StoreSalesPersonPurchaseActivity]
GO

DROP VIEW IF EXISTS [DimTable].[StoreSalesPerson]
GO

DROP VIEW IF EXISTS [DimTable].[SalesView]
GO

/***************/
/* DROP TABLES */
/***************/

DROP TABLE IF EXISTS [StagingTable].[CustomerFavoriteProductSubCategories]
GO

DROP TABLE IF EXISTS [SalesReports].[YearlySummaryReport]
GO

DROP TABLE IF EXISTS [SalesReports].[MemorySalesTotals]
GO

DROP TABLE IF EXISTS [FactTable].[Sales]
GO

DROP TABLE IF EXISTS [DimTable].[ProductSubCategory]
GO

DROP TABLE IF EXISTS [DimTable].[ProductCategory]
GO

DROP TABLE IF EXISTS [DimTable].[Product]
GO

DROP TABLE IF EXISTS [DimTable].[Country]
GO

DROP TABLE IF EXISTS [Demographics].[CustomerPaymentHistory]
GO

DROP TABLE IF EXISTS [DimTable].[Calendar]
GO

DROP TABLE IF EXISTS [StagingTable].[SalesTransaction]
GO

DROP TABLE IF EXISTS [DimTable].[Store]
GO

DROP TABLE IF EXISTS [DimTable].[Customer]
GO

DROP TABLE IF EXISTS [SalesReports].[YearlySalesReport]
GO

/*****************/
/* CREATE SCHEMA */
/*****************/

DROP SCHEMA IF EXISTS [Demographics]
GO

CREATE SCHEMA [Demographics]
GO

DROP SCHEMA IF EXISTS [DimTable]
GO

CREATE SCHEMA [DimTable]
GO

DROP SCHEMA IF EXISTS [FactTable]
GO

CREATE SCHEMA [FactTable]
GO

DROP SCHEMA IF EXISTS [SalesReports]
GO

CREATE SCHEMA [SalesReports]
GO

DROP SCHEMA IF EXISTS [StagingTable]
GO

CREATE SCHEMA [StagingTable]
GO

/*****************/
/* CREATE TABLES */
/*****************/

/************/
/* CUSTOMER */
/************/

DROP TABLE IF EXISTS [DimTable].[Customer]
GO

CREATE TABLE [DimTable].[Customer](
	[CustomerKey] [int] IDENTITY(1,1) NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[CustomerFullName] [nvarchar](256) NOT NULL,
	[CustomerFirstName] [nvarchar](256) NOT NULL,
	[CustomerLastName] [nvarchar](256) NOT NULL,
	[StoreNo] [nvarchar](32) NULL
) ON [AP_SALES_FG]
GO

/*******************************************/
/* CUSTOMER FAVORITE PRODUCT SUBCATEGORIES */
/*******************************************/

DROP TABLE IF  EXISTS  [StagingTable].[CustomerFavoriteProductSubCategories]
GO

CREATE TABLE [StagingTable].[CustomerFavoriteProductSubCategories](
	[CustomerNo] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL
) ON [AP_SALES_FG]
GO

/*********/
/* STORE */
/*********/

DROP TABLE IF EXISTS [DimTable].[Store]
GO

CREATE TABLE [DimTable].[Store](
	[StoreKey] [int] IDENTITY(1,1) NOT NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL
) ON [AP_SALES_FG]
GO

/***********************/
/* YEARLY SALES REPORT */
/***********************/

DROP TABLE IF EXISTS [SalesReports].[YearlySalesReport]
GO

CREATE TABLE [SalesReports].[YearlySalesReport](
	[CustomerFullName] [nvarchar](256) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[ProductName] [nvarchar](256) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductCategoryName] [nvarchar](256) NOT NULL,
	[ProductSubCategoryName] [nvarchar](256) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[TransactionQuantity] [int] NOT NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[UnitRetailPrice] [decimal](10, 2) NOT NULL,
	[UnitSalesTaxAmount] [decimal](10, 2) NOT NULL,
	[TotalWholeSaleAmount] [decimal](10, 2) NULL,
	[TotalSalesAmount] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO

/*********************/
/* SALES TRANSACTION */
/*********************/

DROP TABLE IF EXISTS [StagingTable].[SalesTransaction]
GO

CREATE TABLE [StagingTable].[SalesTransaction](
	[CountryName] [nvarchar](256) NOT NULL,
	[ISO2CountryCode] [nvarchar](2) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[StoreNo] [nvarchar](32) NULL,
	[CalendarDate] [date] NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[TransactionQuantity] [int] NULL,
	[UnitRetailPrice] [decimal](10, 2) NOT NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[UnitSalesTaxAmount] [decimal](10, 2) NULL,
	[TotalSalesAmount] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO

/************/
/* CALENDAR */
/************/

DROP TABLE IF EXISTS [DimTable].[Calendar]
GO

CREATE TABLE [DimTable].[Calendar](
	[CalendarKey] [int] NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarYear] [nvarchar](32) NOT NULL,
	[CalendarQuarter] [int] NOT NULL,
	[CalendarQuarterAbbrev] [char](2) NOT NULL,
	[CalendarMonth] [int] NOT NULL,
	[CalendarMonthAbbrev] [nvarchar](32) NOT NULL,
	[DayOfMonth] [smallint] NOT NULL
) ON [AP_SALES_FG]
GO

/****************************/
/* CUSTOMER PAYMENT HISTORY */
/****************************/

DROP TABLE IF EXISTS [Demographics].[CustomerPaymentHistory]
GO

CREATE TABLE [Demographics].[CustomerPaymentHistory](
	[CreditYear] [smallint] NOT NULL,
	[CreditQtr] [smallint] NULL,
	[CustomerKey] [int] NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[CustomerFullName] [nvarchar](256) NOT NULL,
	[TotalPaymentsTodate] [int] NOT NULL,
	[30DaysLatePaymentCount] [int] NOT NULL,
	[60DaysLatePaymentCount] [int] NOT NULL,
	[90DaysLatePaymentCount] [int] NOT NULL,
	[Over90DaysLatePaymentCount] [int] NOT NULL
) ON [AP_SALES_FG]
GO

/***********/
/* COUNTRY */
/***********/

DROP TABLE IF EXISTS [DimTable].[Country]
GO

CREATE TABLE [DimTable].[Country](
	[CountryKey] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](256) NOT NULL,
	[ISO2CountryCode] [nvarchar](2) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL
) ON [AP_SALES_FG]
GO

/***********/
/* PRODUCT */
/***********/

DROP TABLE IF EXISTS [DimTable].[Product]
GO

CREATE TABLE [DimTable].[Product](
	[ProductKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[ProductName] [nvarchar](256) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[ProductRetailPrice] [decimal](10, 2) NOT NULL
) ON [AP_SALES_FG]
GO

/********************/
/* PRODUCT CATEGORY */
/********************/

DROP TABLE IF EXISTS [DimTable].[ProductCategory]
GO

CREATE TABLE [DimTable].[ProductCategory](
	[ProductCategoryKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductCategoryName] [nvarchar](256) NOT NULL
) ON [AP_SALES_FG]
GO

/***********************/
/* PRODUCT SUBCATEGORY */
/***********************/

DROP TABLE IF EXISTS [DimTable].[ProductSubCategory]
GO

CREATE TABLE [DimTable].[ProductSubCategory](
	[ProductSubCategoryKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryName] [nvarchar](256) NOT NULL
) ON [AP_SALES_FG]
GO

/*********/
/* SALES */
/*********/

DROP TABLE IF EXISTS [FactTable].[Sales]
GO

CREATE TABLE [FactTable].[Sales](
	[CustomerKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[CountryKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[CalendarKey] [int] NOT NULL,
	[TransactionQuantity] [int] NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[UnitRetailPrice] [decimal](10, 2) NOT NULL,
	[UnitSalesTaxAmount] [decimal](10, 2) NULL,
	[TotalWholeSaleAmount] [decimal](22, 2) NULL,
	[TotalSalesAmount] [decimal](22, 2) NULL
) ON [AP_SALES_FG]
GO

/***********************/
/* MEMORY SALES TOTALS */
/***********************/

DROP TABLE IF EXISTS [SalesReports].[MemorySalesTotals]
GO

CREATE TABLE [SalesReports].[MemorySalesTotals]
(
	[SalesTotalKey] [int] IDENTITY(1,1) NOT NULL,
	[SalesYear] [int] NOT NULL,
	[SalesQuarter] [int] NOT NULL,
	[SalesMonth] [int] NOT NULL,
	[CustomerNo] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StoreNo] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProductNo] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CalendarDate] [date] NOT NULL,
	[SalesTotal] [decimal](10, 2) NULL,

INDEX [ieSalesYearStoreNo] NONCLUSTERED 
(
	[SalesYear] ASC,
	[StoreNo] ASC
),
 PRIMARY KEY NONCLUSTERED 
(
	[SalesTotalKey] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO


/*************************/
/* YEARLY SUMMARY REPORT */
/*************************/

DROP TABLE IF EXISTS [SalesReports].[YearlySummaryReport]
GO

CREATE TABLE [SalesReports].[YearlySummaryReport](
	[SalesYear] [int] NULL,
	[SalesMonth] [int] NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL,
	[TotalSales] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO

/*******************************************/
/* CUSTOMER FAVORITE PRODUCT SUBCATEGORIES */
/*******************************************/

DROP TABLE IF EXISTS  [StagingTable].[CustomerFavoriteProductSubCategories]
GO

CREATE TABLE [StagingTable].[CustomerFavoriteProductSubCategories](
	[CustomerNo] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL
) ON [AP_SALES_FG]
GO

/*********/
/* VIEWS */
/*********/

/**************/
/* SALES VIEW */
/**************/

DROP VIEW IF EXISTS [DimTable].[SalesView]
GO

CREATE VIEW [DimTable].[SalesView]
AS
SELECT DISTINCT YEAR(CalendarDate) AS Year,
	DATEPART(qq, CalendarDate) AS Quarter,
    MONTH(CalendarDate) AS Month,
    ProductNo,
    ProductName,
    ProductCategoryCode,
    ProductSubCategoryCode,
    StoreNo,
    StoreName,
    SUM(TotalSalesAmount) AS SumTotal
FROM  SalesReports.YearlySalesReport WITH (NOLOCK)
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq, CalendarDate)
	,ProductNo
	,ProductName
	,ProductCategoryCode
	,ProductSubCategoryCode
	,StoreNo
	,StoreName;
GO

/***************************/
/* STORE SALES PERSON VIEW */
/***************************/

DROP VIEW IF EXISTS [DimTable].[StoreSalesPerson]
GO

CREATE VIEW [DimTable].[StoreSalesPerson]
AS
SELECT S.[StoreNo]
      ,S.[StoreName]
      ,S.[StoreTerritory]
	  ,C.CustomerNo AS SalesPersonNo
	  ,C.CustomerLastName AS SalesPersonLastName
	  ,C.CustomerFirstName AS SalesPersonFirstName
	  ,C.CustomerFullName AS SalesPersonFullName
  FROM [APSalesTest].[DimTable].[Store] S
JOIN [DimTable].[Customer] C
ON S.StoreNo = C.StoreNo
-- for debugging
--ORDER BY S.StoreNo,C.CustomerNo
GO

/********************************************/
/* STORE SALESPERSON PURCHASE ACTIVITY VIEW */
/********************************************/

DROP VIEW IF EXISTS [DimTable].[StoreSalesPersonPurchaseActivity]
GO

CREATE VIEW [DimTable].[StoreSalesPersonPurchaseActivity]
AS
SELECT SSP.StoreNo
	,SSP.StoreName
	,SSP.StoreTerritory
	,SSP.SalesPersonNo
	,SSP.SalesPersonLastName
	,SSP.SalesPersonFirstName
	,SSP.SalesPersonFullName
	,YSP.CalendarDate AS SalesTransactionDate
	,YSP.ProductNo
	,YSP.TransactionQuantity
	,YSP.ProductWholeSalePrice AS WholeSalesPrice
	,YSP.UnitRetailPrice,YSP.TransactionQuantity * YSP.ProductWholeSalePrice AS TotalPurchaseAmount
	,YSP.TransactionQuantity * YSP.UnitRetailPrice AS TotalRetailSalesAmount
	,YSP.TransactionQuantity * YSP.UnitRetailPrice - YSP.TransactionQuantity * YSP.ProductWholeSalePrice AS MarkupSalesAmount
FROM  DimTable.StoreSalesPerson AS SSP INNER JOIN
	(
	SELECT StoreNo
		,CustomerFullName
		,CalendarDate
		,ProductNo
		,TransactionQuantity
		,ProductWholeSalePrice
		,UnitRetailPrice
        FROM SalesReports.YearlySalesReport
	) AS YSP 
	ON SSP.StoreNo = YSP.StoreNo 
	AND SSP.SalesPersonFullName = YSP.CustomerFullName
GO

/********************************************/
/* SALES PERSON ACTIVITY REPORT - TEST VIEW */
/********************************************/

DROP VIEW IF EXISTS[dbo].[SalesPersonActivityReport-TEST]
GO

CREATE VIEW [dbo].[SalesPersonActivityReport-TEST]
AS
SELECT YEAR([CalendarDate]) AS SalesYear
	  ,MONTH([CalendarDate]) AS SalesMonth
	  ,'SP-' + [CustomerNo] AS SalesPersonNo
      ,[StoreNo]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductNo]
	  ,[TransactionQuantity]
	  ,[UnitRetailPrice]
	  ,[TotalSalesAmount] AS UnitRetailSaleAmount
      ,SUM([TotalSalesAmount]) AS TotalMonthlyRetailSales
FROM [APSalesTest].[StagingTable].[SalesTransaction]
GROUP BY YEAR([CalendarDate])
	  ,MONTH([CalendarDate])
	  ,[CustomerNo]
      ,[StoreNo]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductNo]
	  ,[TransactionQuantity]
	  ,[UnitRetailPrice]
	  ,[TotalSalesAmount]
/*ORDER BY YEAR([CalendarDate])
	  ,MONTH([CalendarDate])
	  ,[CustomerNo]
      ,[StoreNo]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductNo]
	  */
GO

/*****************/
/* CALENDAR VIEW */
/*****************/

DROP VIEW IF EXISTS [DimTable].[CalendarView]
GO

CREATE VIEW [DimTable].[CalendarView]
AS
SELECT [CalendarKey]
	,[CalendarYear]
	,[CalendarQuarter]
    ,CASE 
		WHEN [CalendarQuarter] = 1 THEN '1st Quarter' 
		WHEN [CalendarQuarter] = 2 THEN '2nd Quarter'
		WHEN [CalendarQuarter] = 3 THEN '3rd Quarter' 
		WHEN [CalendarQuarter] = 4 THEN '4th Quarter'
	END AS Quarter_Name
	,[CalendarMonth]
	,CASE 
		WHEN [CalendarMonth] = 1 THEN 'Jan' 
		WHEN [CalendarMonth] = 2 THEN 'Feb'
		WHEN [CalendarMonth] = 3 THEN 'Mar' 
		WHEN [CalendarMonth] = 4 THEN 'Apr' 
		WHEN [CalendarMonth] = 5 THEN 'May' 
		WHEN [CalendarMonth] = 6 THEN 'Jun' 
		WHEN [CalendarMonth] = 7 THEN 'Jul' 
		WHEN [CalendarMonth] = 8 THEN 'Aug' 
		WHEN [CalendarMonth] = 9 THEN 'Sep' 
		WHEN [CalendarMonth] = 10 THEN 'Oct' 
		WHEN [CalendarMonth] = 11 THEN 'Nov' 
		WHEN [CalendarMonth] = 12 THEN 'Dec' 
	END AS MonthAbbrev
	,CASE 
		WHEN [CalendarMonth] = 1 THEN 'January' 
		WHEN [CalendarMonth] = 2 THEN 'February' 
		WHEN [CalendarMonth] = 3 THEN 'March' 
		WHEN [CalendarMonth] = 4 THEN 'April' 
		WHEN [CalendarMonth] = 5 THEN 'May' 
		WHEN [CalendarMonth] = 6 THEN 'June' 
		WHEN [CalendarMonth] = 7 THEN 'July' 
		WHEN [CalendarMonth] = 8 THEN 'August' 
		WHEN [CalendarMonth] = 9 THEN 'September' 
		WHEN [CalendarMonth] = 10 THEN 'October' 
		WHEN [CalendarMonth] = 11 THEN 'November' 
		WHEN [CalendarMonth] = 12 THEN 'December' 
	END AS [MonthName]
	,[CalendarDate]
FROM [DimTable].[Calendar];
GO

/******************************/
/* CHECK TABLE ROW COUNT VIEW */
/******************************/

CREATE OR ALTER VIEW CheckTableRowCount
AS
SELECT t.name,P.rows
FROM sys.tables T
JOIN sys.partitions P
ON T.object_id = P.object_id
GO

SELECT DISTINCT * 
FROM CheckTableRowCount
ORDER BY 1
GO

/********************************/
/* CHECK COLUMN DATA TYPES VIEW */
/********************************/

CREATE OR ALTER VIEW [dbo].[CheckColumnDataTypes]
AS
SELECT t.name AS TableName,c.name AS ColumnName,c.max_length AS ColLength,ot.name
FROM sys.tables t
JOIN sys.columns c
ON t.object_id = C.object_id
JOIN sys.types ot
ON c.system_type_id = ot.system_type_id
GO

SELECT DISTINCT * 
FROM CheckColumnDataTypes
ORDER BY 1
GO


