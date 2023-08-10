
/*****************************************/
/* Chapter 05,06,07 - APFinance Database */
/* Create Tables                         */
/* Created: 08/19/2022                   */
/* Modified: 07/20/2023                  */
/* Production                            */
/*****************************************/

USE [APFinance]
GO

/**************/
/* DROP VIEWS */
/**************/

DROP VIEW IF EXISTS [FinancialReports].[AccountMonthlyBalancesMemView]
GO

/***************/
/* DROP TABLES */
/***************/

DROP TABLE IF EXISTS [Report].[CustomerC0000001Analysis]
GO

DROP TABLE IF EXISTS [MasterData].[TransactionType]
GO

DROP TABLE IF EXISTS [MasterData].[TransactionAccountType]
GO

DROP TABLE IF EXISTS [MasterData].[TickerPriceRangeHistoryDetail]
GO

DROP TABLE IF EXISTS [MasterData].[TickerPriceRangeHistory]
GO

DROP TABLE IF EXISTS [MasterData].[TickerHistory]
GO

DROP TABLE IF EXISTS [MasterData].[PortfolioAccountType]
GO

DROP TABLE IF EXISTS [MasterData].[CustomerTickerSymbols]
GO

DROP TABLE IF EXISTS [MasterData].[CustomerMemoryOptimized]
GO

DROP TABLE IF EXISTS [MasterData].[Customer]
GO

DROP TABLE IF EXISTS [MasterData].[Calendar]
GO

DROP TABLE IF EXISTS [MasterData].[AccountType]
GO

DROP TABLE IF EXISTS [Financial].[Transaction]
GO

DROP TABLE IF EXISTS [Financial].[TickerSymbols]
GO

DROP TABLE IF EXISTS [Financial].[PortfolioMovement]
GO

DROP TABLE IF EXISTS [Financial].[Portfolio]
GO

DROP TABLE IF EXISTS [Financial].[NtileSymbolBuckets]
GO

DROP TABLE IF EXISTS [Financial].[MonthlyAccountAnalysis]
GO

DROP TABLE IF EXISTS [Financial].[DailyPortfolioAnalysis]
GO

DROP TABLE IF EXISTS [Financial].[CustomerBuyTransaction]
GO

DROP TABLE IF EXISTS [Financial].[AccountVersusTarget]
GO

DROP TABLE IF EXISTS [Financial].[Account]
GO

DROP TABLE IF EXISTS [dbo].[ErrorLog]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2011]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2012]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2013]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2014]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2015]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountClustered]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalances]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem]
GO

DROP TABLE IF EXISTS [FinancialReports].[PortfolioMonthlyBalances]
GO


/************************/
/* DROP & CREATE SCHEMA */
/************************/

DROP SCHEMA IF EXISTS [Financial]
GO

CREATE SCHEMA [Financial]
GO

DROP SCHEMA IF EXISTS [MasterData]
GO

CREATE SCHEMA [MasterData]
GO

DROP SCHEMA IF EXISTS [Report]
GO

CREATE SCHEMA [Report]
GO

DROP SCHEMA IF EXISTS [FinancialReports]
GO

CREATE SCHEMA [FinancialReports]
GO

/*****************/
/* CREATE TABLES */
/*****************/

/***************/
/* TRANSACTION */
/***************/

CREATE TABLE [Financial].[Transaction](
	[TransKey] [int] IDENTITY(1,1) NOT NULL,
	[TransDate] [date] NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[Price] [money] NOT NULL,
	[Quantity] [money] NOT NULL,
	[TransAmount] [decimal](10, 2) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[PortfolioAccountTypeCode] [char](8) NOT NULL,
	[AcctNo] [varchar](32) NOT NULL,
	[BuySell] [char](1) NOT NULL,
	[TransTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
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
) ON [AP_FINANCE_FG]
GO

/*********************************/
/* ACCOUNTMONTHLYBALANCESMEM2011 */
/**********************************/

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2011]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrtfNo] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctNo] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctName] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

INDEX [ieMonthlyAcctBalanceMemory2011] NONCLUSTERED 
(
	[CustId] ASC,
	[AcctYear] ASC,
	[AcctMonth] ASC,
	[PrtfNo] ASC,
	[AcctNo] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/*********************************/
/* ACCOUNTMONTHLYBALANCESMEM2012 */
/**********************************/

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2012]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrtfNo] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctNo] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctName] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

INDEX [ieMonthlyAcctBalanceMemory2012] NONCLUSTERED 
(
	[CustId] ASC,
	[AcctYear] ASC,
	[AcctMonth] ASC,
	[PrtfNo] ASC,
	[AcctNo] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/*********************************/
/* ACCOUNTMONTHLYBALANCESMEM2013 */
/**********************************/

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2013]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrtfNo] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctNo] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctName] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

INDEX [ieMonthlyAcctBalanceMemory2013] NONCLUSTERED 
(
	[CustId] ASC,
	[AcctYear] ASC,
	[AcctMonth] ASC,
	[PrtfNo] ASC,
	[AcctNo] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/*********************************/
/* ACCOUNTMONTHLYBALANCESMEM2014 */
/**********************************/

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2014]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrtfNo] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctNo] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctName] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

INDEX [ieMonthlyAcctBalanceMemory2014] NONCLUSTERED 
(
	[CustId] ASC,
	[AcctYear] ASC,
	[AcctMonth] ASC,
	[PrtfNo] ASC,
	[AcctNo] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/*********************************/
/* ACCOUNTMONTHLYBALANCESMEM2015 */
/**********************************/

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2015]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrtfNo] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctNo] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctName] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

INDEX [ieMonthlyAcctBalanceMemory2015] NONCLUSTERED 
(
	[CustId] ASC,
	[AcctYear] ASC,
	[AcctMonth] ASC,
	[PrtfNo] ASC,
	[AcctNo] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
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
) ON [PRIMARY]
GO

/***********/
/* ACCOUNT */
/***********/

CREATE TABLE [Financial].[Account](
	[AcctKey] [int] IDENTITY(1,1) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctTypeCode] [varchar](8) NOT NULL,
	[AcctBalance] [decimal](10, 2) NOT NULL,
	[PostDate] [date] NOT NULL
) ON [AP_FINANCE_FG]
GO

/*************************/
/* ACCOUNT VERSUS TARGET */
/*************************/

CREATE TABLE [Financial].[AccountVersusTarget](
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctTypeCode] [varchar](8) NOT NULL,
	[AcctBalance] [decimal](10, 2) NOT NULL,
	[PostDate] [date] NOT NULL,
	[TargetBalance] [numeric](14, 4) NULL,
	[Delta] [numeric](15, 4) NULL
) ON [AP_FINANCE_FG]
GO

/****************************/
/* CUSTOMER BUY TRANSACTION */
/****************************/

CREATE TABLE [Financial].[CustomerBuyTransaction](
	[TransDate] [date] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[TradeNo] [smallint] NOT NULL,
	[TransAmount] [decimal](10, 2) NOT NULL,
	[TransTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
GO

/****************************/
/* DAILY PORTFOLIO ANALYSIS */
/****************************/

CREATE TABLE [Financial].[DailyPortfolioAnalysis](
	[TradeYear] [int] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[Portfolio] [varchar](278) NOT NULL,
	[YearlyValue] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO

/****************************/
/* MONTHLY ACCOUNT ANALYSIS */
/****************************/

CREATE TABLE [Financial].[MonthlyAccountAnalysis](
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[MonthlyBalance] [decimal](38, 2) NULL
) ON [AP_FINANCE_FG]
GO

/************************/
/* NTILE SYMBOL BUCKETS */
/************************/

CREATE TABLE [Financial].[NtileSymbolBuckets](
	[TransYear] [int] NULL,
	[Symbol] [varchar](64) NOT NULL,
	[SumTransactions] [decimal](38, 2) NULL,
	[InvestmentBucket] [bigint] NULL
) ON [AP_FINANCE_FG]
GO

/*************/
/* PORTFOLIO */
/*************/

CREATE TABLE [Financial].[Portfolio](
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[PortfolioAccountTypeCode] [varchar](8) NOT NULL,
	[Portfolio] [varchar](278) NOT NULL,
	[Value] [decimal](10, 2) NOT NULL,
	[RollingBalance] [decimal](10, 2) NOT NULL,
	[SweepDate] [date] NOT NULL
) ON [AP_FINANCE_FG]
GO

/**********************/
/* PORTFOLIO MOVEMENT */
/**********************/

CREATE TABLE [Financial].[PortfolioMovement](
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[PortfolioAccountTypeCode] [varchar](3) NOT NULL,
	[Portfolio] [varchar](278) NOT NULL,
	[Value] [decimal](10, 2) NOT NULL,
	[SweepDate] [date] NOT NULL
) ON [AP_FINANCE_FG]
GO

/******************/
/* TICKER SYMBOLS */
/******************/

CREATE TABLE [Financial].[TickerSymbols](
	[Symbol] [varchar](64) NOT NULL,
	[Name] [varchar](64) NOT NULL,
	[TransactionTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
GO

/*********************/
/* ACCOUNT CLUSTERED */
/*********************/

CREATE TABLE [FinancialReports].[AccountClustered](
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO

/****************************/
/* ACCOUNT MONTHLY BALANCES */
/****************************/

CREATE TABLE [FinancialReports].[AccountMonthlyBalances](
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO

/***********************************/
/* ACCOUNT MONTHLY BALANCES MEMORY */
/***********************************/

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrtfNo] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctNo] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctName] [varchar](24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

INDEX [ieMonthlyAcctBalanceMemory] NONCLUSTERED 
(
	[CustId] ASC,
	[AcctYear] ASC,
	[AcctMonth] ASC,
	[PrtfNo] ASC,
	[AcctNo] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/******************************/
/* PORTFOLIO MONTHLY BALANCES */
/******************************/

CREATE TABLE [FinancialReports].[PortfolioMonthlyBalances](
	[TradeYear] [int] NOT NULL,
	[TradeQtr] [int] NULL,
	[TradeMonth] [int] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[Portfolio] [varchar](278) NOT NULL,
	[MonthlyValue] [decimal](38, 2) NULL
) ON [AP_FINANCE_FG]
GO

/****************/
/* ACCOUNT TYPE */
/****************/

CREATE TABLE [MasterData].[AccountType](
	[AcctTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[AcctTypeCode] [varchar](8) NOT NULL,
	[AcctTypeName] [varchar](64) NOT NULL
) ON [AP_FINANCE_FG]
GO

/************/
/* CUSTOMER */
/************/

CREATE TABLE [MasterData].[Customer](
	[CustKey] [int] IDENTITY(1,1) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[CustLname] [varchar](64) NOT NULL,
	[CustFname] [varchar](64) NOT NULL,
	[CustIncome] [money] NOT NULL,
	[IncomeBracket] [varchar](64) NOT NULL
) ON [AP_FINANCE_FG]
GO

/*****************************/
/* CUSTOMER MEMORY OPTIMIZED */
/*****************************/

CREATE TABLE [MasterData].[CustomerMemoryOptimized]
(
	[CustKey] [int] IDENTITY(1,1) NOT NULL,
	[CustId] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CustLname] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CustFname] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CustIncome] [money] NOT NULL,
	[IncomeBracket] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

INDEX [pkCustKey] NONCLUSTERED 
(
	[CustKey] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/***************************/
/* CUSTOMER TICKER SYMBOLS */
/***************************/

CREATE TABLE [MasterData].[CustomerTickerSymbols](
	[CustSymbolKey] [int] IDENTITY(1,1) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[TransactionTypeCode] [varchar](8) NOT NULL,
	[CustTradesInFlag] [varchar](1) NOT NULL
) ON [AP_FINANCE_FG]
GO

/**************************/
/* PORTFOLIO ACCOUNT TYPE */
/**************************/

CREATE TABLE [MasterData].[PortfolioAccountType](
	[PortfolioAccountTypeCode] [char](3) NOT NULL,
	[PortfolioAccountTypeName] [varchar](278) NOT NULL
) ON [AP_FINANCE_FG]
GO

/******************/
/* TICKER HISTORY */
/******************/

CREATE TABLE [MasterData].[TickerHistory](
	[Ticker] [varchar](64) NOT NULL,
	[Company] [varchar](128) NOT NULL,
	[TickerDate] [date] NOT NULL,
	[QuoteHour] [smallint] NOT NULL,
	[Quote] [decimal](10, 2) NOT NULL
) ON [AP_FINANCE_FG]
GO

/******************************/
/* TICKER PRICE RANGE HISTORY */
/******************************/

CREATE TABLE [MasterData].[TickerPriceRangeHistory](
	[Ticker] [varchar](64) NOT NULL,
	[Company] [varchar](128) NOT NULL,
	[TickerDate] [date] NOT NULL,
	[Low] [decimal](10, 2) NULL,
	[High] [decimal](10, 2) NULL,
	[Spread] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO

/*************************************/
/* TICKER PRICE RANGE HISTORY DETAIL */
/*************************************/

CREATE TABLE [MasterData].[TickerPriceRangeHistoryDetail](
	[QuoteYear] [int] NULL,
	[QuoteQtr] [int] NULL,
	[QuoteMonth] [int] NULL,
	[QuoteWeek] [int] NULL,
	[TickerDate] [date] NOT NULL,
	[Ticker] [varchar](64) NOT NULL,
	[Company] [varchar](128) NOT NULL,
	[Low] [decimal](10, 2) NULL,
	[High] [decimal](10, 2) NULL,
	[Spread] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO

/****************************/
/* TRANSACTION ACCOUNT TYPE */
/****************************/

CREATE TABLE [MasterData].[TransactionAccountType](
	[TransAcctTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[TransTypeCode] [varchar](32) NOT NULL,
	[AcctTypeCode] [varchar](32) NOT NULL,
	[TypeCodeDescription] [varchar](256) NOT NULL
) ON [AP_FINANCE_FG]
GO

/********************/
/* TRANSACTION TYPE */
/********************/

CREATE TABLE [MasterData].[TransactionType](
	[TransTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[TransTypeCode] [varchar](32) NOT NULL,
	[TransTypeDescription] [varchar](256) NOT NULL
) ON [AP_FINANCE_FG]
GO

/******************************/
/* CUSTOMER C0000001 ANALYSIS */
/******************************/

CREATE TABLE [Report].[CustomerC0000001Analysis](
	[TransYear] [int] NULL,
	[TransQtr] [int] NULL,
	[TransMonth] [int] NULL,
	[TransWeek] [int] NULL,
	[TransDate] [date] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[CustFname] [varchar](64) NOT NULL,
	[CustLname] [varchar](64) NOT NULL,
	[AcctNo] [varchar](32) NOT NULL,
	[BuySell] [char](1) NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[DailyCount] [int] NULL
) ON [AP_FINANCE_FG]
GO

/*********/
/* VIEWS */
/*********/

USE [APFinance]
GO

/*************************************/
/* ACCOUNT MONTHLY BALANCES MEM VIEW */
/*************************************/

DROP VIEW IF EXISTS [FinancialReports].[AccountMonthlyBalancesMemView]
GO

CREATE VIEW [FinancialReports].[AccountMonthlyBalancesMemView]
AS
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2011]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2012]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2013]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2014]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2015]
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

/***************************/
/* CHECK COLUMN DATA TYPES */
/***************************/

CREATE OR ALTER   VIEW [dbo].[CheckColumnDataTypes]
AS
SELECT t.name AS TableName,c.name AS ColumnName,c.max_length AS ColLength,ot.name
FROM sys.tables t
JOIN sys.columns c
ON t.object_id = C.object_id
JOIN sys.types ot
ON c.system_type_id = ot.system_type_id
GO
