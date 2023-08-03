USE [AP_SALES]
GO

/*
select t.name,c.name
from sys.tables t
join sys.columns c
on t.object_id = c.object_id
where t.type = 'U'
order by t.name,2
GO
*/

DROP SCHEMA IF EXISTS [DIM]
GO

CREATE SCHEMA [DIM]
GO

DROP SCHEMA IF EXISTS [FACT]
GO

CREATE SCHEMA [FACT]
GO

DROP SCHEMA IF EXISTS [MASTER_DATA]
GO

CREATE SCHEMA [MASTER_DATA]
GO

/************/
/* CALENDAR */
/************/

DROP TABLE IF EXISTS [DIM].[Calendar]
GO

CREATE TABLE [DIM].[Calendar](
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

/***********/
/* COUNTRY */
/***********/

DROP TABLE IF EXISTS [DIM].[Country]
GO

CREATE TABLE [DIM].[Country](
	[CountryKey] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](256) NOT NULL,
	[ISO2CountryCode] [nvarchar](2) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL
) ON [AP_SALES_FG]
GO

/************/
/* CUSTOMER */
/************/

DROP TABLE IF EXISTS [DIM].[Customer]
GO

CREATE TABLE [DIM].[Customer](
	[CustomerKey] [int] IDENTITY(1,1) NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[CustomerFullName] [nvarchar](256) NOT NULL,
	[CustomerFirstName] [nvarchar](256) NOT NULL,
	[CustomerLastName] [nvarchar](256) NOT NULL,
	[StoreNo] [nvarchar](32) NULL
) ON [AP_SALES_FG]
GO

/***********/
/* PRODUCT */
/***********/

DROP TABLE IF EXISTS [DIM].[Product]
GO

CREATE TABLE [DIM].[Product](
	[ProductKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[ProductName] [nvarchar](256) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductWholeSalePrice] [money] NOT NULL,
	[ProductRetailPrice] [money] NOT NULL
) ON [AP_SALES_FG]
GO

/********************/
/* PRODUCT CATEGORY */
/********************/

DROP TABLE IF EXISTS [DIM].[ProductCategory]
GO

CREATE TABLE [DIM].[ProductCategory](
	[ProductCategoryKey]  [int] IDENTITY(1,1) NOT NULL,
	[ProductCategoryCode] [nvarchar](32)      NOT NULL,
	[ProductCategoryName] [nvarchar](256)     NOT NULL
) ON [AP_SALES_FG]
GO

/************************/
/* PRODUCT SUB CATEGORY */
/************************/

DROP TABLE IF EXISTS [DIM].[ProductSubCategory]
GO

CREATE TABLE [DIM].[ProductSubCategory](
	[ProductSubCategoryKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryName] [nvarchar](256) NOT NULL
) ON [AP_SALES_FG]
GO

/*********/
/* STORE */
/*********/

DROP TABLE IF EXISTS [FACT].[Store]
GO

CREATE TABLE [DIM].[Store](
	[StoreKey] [int] IDENTITY(1,1) NOT NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL
) ON [AP_SALES_FG]
GO

/***************/
/* DISTRIBUTOR */
/***************/

CREATE TABLE DIM.Distributor(
  DistributorKey INTEGER IDENTITY NOT NULL,
  DistributorNo  VARCHAR(8) NOT NULL,
  DistributorName VARCHAR(128) NOT NULL
)
GO

/*********************/
/* STORE DISTRIBUTOR */
/*********************/

DROP TABLE IF EXISTS DIM.StoreDistributor
GO

CREATE TABLE DIM.StoreDistributor(
DistributorKey INTEGER NOT NULL,
StoreKey INTEGER NOT NULL,
StoreNo VARCHAR(32) NOT NULL
)
GO

/*********/
/* SALES */
/*********/

DROP TABLE IF EXISTS [FACT].[Sales]
GO

CREATE TABLE [FACT].[Sales](
	[CustomerKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[CountryKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[CalendarKey] [int] NOT NULL,
	[TransactionQuantity] [int] NULL,
	[TransactionAmount] [money] NOT NULL,
	[SalesTaxAmount] [money] NOT NULL,
	[TotalSalesAmount] [money] NOT NULL
) ON [AP_SALES_FG]
GO

/*********************/
/* SALES TRANSACTION */
/*********************/

DROP TABLE IF EXISTS [STAGE].[Sales_Transaction]
GO

CREATE TABLE [STAGE].[Sales_Transaction](
	[CountryName] [nvarchar](256) NOT NULL,
	[ISO2CountryCode] [nvarchar](2) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[StoreNo] [nvarchar](32) NOT NULL,

	[CalendarDate] [date] NOT NULL,

	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[TransactionQuantity] [int] NOT NULL,

	[UnitRetailPrice] [money] NOT NULL,
	[UnitWholeSalePrice] [money] NOT NULL,

	[UnitSalesTaxAmount] [money] NOT NULL,
	[TotalSalesAmount] [money] NOT NULL

) ON [AP_SALES_FG]
GO

/*******************/
/* USP_RANDOMFLOAT */
/*******************/

DROP PROCEDURE IF EXISTS [FACT].[usp_RandomFloat]
GO

CREATE PROCEDURE [FACT].[usp_RandomFloat]
@RANDOM_VALUE FLOAT OUTPUT, @START_RANGE FLOAT, @STOP_RANGE FLOAT
AS
SET @RANDOM_VALUE = CONVERT (FLOAT, ROUND(UPPER(RAND() * @STOP_RANGE + @START_RANGE), 0));
GO
