USE [APFinance]
GO
/****** Object:  Schema [Financial]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [Financial]
GO
/****** Object:  Schema [FinancialReports]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [FinancialReports]
GO
/****** Object:  Schema [MASTER_DATA]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [MASTER_DATA]
GO
/****** Object:  Schema [MasterData]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [MasterData]
GO
/****** Object:  Schema [Report]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [Report]
GO
/****** Object:  Schema [Reports]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [Reports]
GO
/****** Object:  Schema [TRADE]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [TRADE]
GO
/****** Object:  Schema [TradeTransaction]    Script Date: 7/7/2023 10:59:28 AM ******/
CREATE SCHEMA [TradeTransaction]
GO
/****** Object:  UserDefinedFunction [MasterData].[fRenameTable]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [MasterData].[fRenameTable]
(@TableName VARCHAR (64), @Delimiter CHAR (1))
RETURNS VARCHAR (64)
AS
BEGIN
    DECLARE @Part1 AS VARCHAR (32);
    DECLARE @Part2 AS VARCHAR (32);
    SET @TableName = REPLACE(@TableName, '[', '');
    SET @TableName = REPLACE(@TableName, ']', '');
    IF CHARINDEX(@Delimiter, @TableName, 1) = 0
        BEGIN
            SET @TableName = UPPER(SUBSTRING(@TableName, 1, 1)) + LOWER(SUBSTRING(@TableName, 2, LEN(@TableName) - 1));
        END
    ELSE
        BEGIN
            SET @Part1 = UPPER(SUBSTRING(@TableName, 1, 1)) + LOWER(SUBSTRING(@TableName, 2, CHARINDEX(@Delimiter, @TableName, 1) - 2));
            SET @Part2 = UPPER(SUBSTRING(@TableName, CHARINDEX(@Delimiter, @TableName, 1) + 1, 1)) + LOWER(RIGHT(@TableName, LEN(@TableName) - (CHARINDEX(@Delimiter, @TableName, 1) + 1)));
            SET @TableName = @Part1 + @Part2;
        END
    IF CHARINDEX(@Delimiter, @Part2, 1) > 0
        BEGIN
            DECLARE @Part3 AS VARCHAR (64);
            SELECT @Part3 = MasterData.fRenameTable(@Part2, '_');
            SET @TableName = @Part1 + @Part3;
        END
    RETURN @TableName;
END

GO
/****** Object:  Table [Financial].[Transaction]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[Transaction](
	[TransKey] [int] IDENTITY(1,1) NOT NULL,
	[TransDate] [date] NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[Price] [money] NOT NULL,
	[Quantity] [money] NOT NULL,
	[TransAmount] [decimal](10, 2) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[PortfolioAccountTypeCode] [char](3) NOT NULL,
	[AcctNo] [varchar](32) NOT NULL,
	[BuySell] [char](1) NOT NULL,
	[TransTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  View [Financial].[Msft220422c0016000Analysis]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Financial].[Msft220422c0016000Analysis]
AS
SELECT   YEAR([TRANS_DATE]) AS [YEAR],
         MONTH([TRANS_DATE]) AS [MONTH],
         [CUST_ID],
         [ACCT_NO],
         [SYMBOL],
         SUM([TRANS_AMOUNT]) AS SUM_TRANSACTION
FROM     [Financial].[TRANSACTION]
WHERE    SYMBOL = 'MSFT220422C0016000'
GROUP BY YEAR([TRANS_DATE]), MONTH([TRANS_DATE]), [CUST_ID], [ACCT_NO], [SYMBOL];

GO
/****** Object:  View [Financial].[Msft220422c0016000WeeklyAnalysis]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Financial].[Msft220422c0016000WeeklyAnalysis]
AS
SELECT YEAR([TRANS_DATE]) AS [YEAR],
       MONTH([TRANS_DATE]) AS [MONTH],
       DATEPART(ww, [TRANS_DATE]) AS [WEEK],
       [TRANS_DATE],
       [CUST_ID],
       [ACCT_NO],
       [SYMBOL],
       [BUY_SELL],
       [TRANS_AMOUNT]
FROM   [Financial].[TRANSACTION]
WHERE  SYMBOL = 'MSFT220422C0016000';

GO
/****** Object:  Table [MasterData].[Calendar]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  View [MasterData].[CalendarWeekView]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [MasterData].[CalendarWeekView]
AS
SELECT [CALENDAR_KEY],
       [CALENDAR_YEAR],
       [CALENDAR_QTR],
       CASE WHEN [CALENDAR_QTR] = 1 THEN '1st Quarter' WHEN [CALENDAR_QTR] = 2 THEN '2nd Quarter' WHEN [CALENDAR_QTR] = 3 THEN '3rd Quarter' WHEN [CALENDAR_QTR] = 4 THEN '4th Quarter' END AS QUARTER_NAME,
       [CALENDAR_MONTH],
       CASE WHEN [CALENDAR_MONTH] = 1 THEN 'Jan' WHEN [CALENDAR_MONTH] = 2 THEN 'Feb' WHEN [CALENDAR_MONTH] = 3 THEN 'Mar' WHEN [CALENDAR_MONTH] = 4 THEN 'Apr' WHEN [CALENDAR_MONTH] = 5 THEN 'May' WHEN [CALENDAR_MONTH] = 6 THEN 'Jun' WHEN [CALENDAR_MONTH] = 7 THEN 'Jul' WHEN [CALENDAR_MONTH] = 8 THEN 'Aug' WHEN [CALENDAR_MONTH] = 9 THEN 'Sep' WHEN [CALENDAR_MONTH] = 10 THEN 'Oct' WHEN [CALENDAR_MONTH] = 11 THEN 'Nov' WHEN [CALENDAR_MONTH] = 12 THEN 'Dec' END AS MONTH_ABBREV,
       CASE WHEN [CALENDAR_MONTH] = 1 THEN 'January' WHEN [CALENDAR_MONTH] = 2 THEN 'February' WHEN [CALENDAR_MONTH] = 3 THEN 'March' WHEN [CALENDAR_MONTH] = 4 THEN 'April' WHEN [CALENDAR_MONTH] = 5 THEN 'May' WHEN [CALENDAR_MONTH] = 6 THEN 'June' WHEN [CALENDAR_MONTH] = 7 THEN 'July' WHEN [CALENDAR_MONTH] = 8 THEN 'August' WHEN [CALENDAR_MONTH] = 9 THEN 'September' WHEN [CALENDAR_MONTH] = 10 THEN 'October' WHEN [CALENDAR_MONTH] = 11 THEN 'November' WHEN [CALENDAR_MONTH] = 12 THEN 'December' END AS MONTH_NAME,
       CASE WHEN DATEPART(dd, [CALENDAR_DATE]) BETWEEN 1 AND 7 THEN 1 WHEN DATEPART(dd, [CALENDAR_DATE]) BETWEEN 8 AND 14 THEN 2 WHEN DATEPART(dd, [CALENDAR_DATE]) BETWEEN 15 AND 21 THEN 3 WHEN DATEPART(dd, [CALENDAR_DATE]) BETWEEN 22 AND 28 THEN 4 ELSE 5 END AS CALENDAR_MONTH_WEEK,
       DATEPART(WW, [CALENDAR_DATE]) AS CALENDAR_YEAR_WEEK,
       [CALENDAR_DATE]
FROM   [MasterData].[CALENDAR];

GO
/****** Object:  View [MasterData].[CalendarView]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [MasterData].[CalendarView]
AS
SELECT [CALENDAR_KEY],
       [CALENDAR_YEAR],
       [CALENDAR_QTR],
       CASE WHEN [CALENDAR_QTR] = 1 THEN '1st Quarter' WHEN [CALENDAR_QTR] = 2 THEN '2nd Quarter' WHEN [CALENDAR_QTR] = 3 THEN '3rd Quarter' WHEN [CALENDAR_QTR] = 4 THEN '4th Quarter' END AS QUARTER_NAME,
       [CALENDAR_MONTH],
       CASE WHEN [CALENDAR_MONTH] = 1 THEN 'Jan' WHEN [CALENDAR_MONTH] = 2 THEN 'Feb' WHEN [CALENDAR_MONTH] = 3 THEN 'Mar' WHEN [CALENDAR_MONTH] = 4 THEN 'Apr' WHEN [CALENDAR_MONTH] = 5 THEN 'May' WHEN [CALENDAR_MONTH] = 6 THEN 'Jun' WHEN [CALENDAR_MONTH] = 7 THEN 'Jul' WHEN [CALENDAR_MONTH] = 8 THEN 'Aug' WHEN [CALENDAR_MONTH] = 9 THEN 'Sep' WHEN [CALENDAR_MONTH] = 10 THEN 'Oct' WHEN [CALENDAR_MONTH] = 11 THEN 'Nov' WHEN [CALENDAR_MONTH] = 12 THEN 'Dec' END AS MONTH_ABBREV,
       CASE WHEN [CALENDAR_MONTH] = 1 THEN 'January' WHEN [CALENDAR_MONTH] = 2 THEN 'February' WHEN [CALENDAR_MONTH] = 3 THEN 'March' WHEN [CALENDAR_MONTH] = 4 THEN 'April' WHEN [CALENDAR_MONTH] = 5 THEN 'May' WHEN [CALENDAR_MONTH] = 6 THEN 'June' WHEN [CALENDAR_MONTH] = 7 THEN 'July' WHEN [CALENDAR_MONTH] = 8 THEN 'August' WHEN [CALENDAR_MONTH] = 9 THEN 'September' WHEN [CALENDAR_MONTH] = 10 THEN 'October' WHEN [CALENDAR_MONTH] = 11 THEN 'November' WHEN [CALENDAR_MONTH] = 12 THEN 'December' END AS MONTH_NAME,
       [CALENDAR_DATE]
FROM   [MasterData].[CALENDAR];

GO
/****** Object:  View [dbo].[DbSchemaAssignmentsView]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DbSchemaAssignmentsView]
AS
SELECT schema_name(t.schema_id) AS schema_name,
       t.name AS table_name,
       t.create_date,
       t.modify_date
FROM   sys.tables AS t;

GO
/****** Object:  View [Financial].[CustomerAccountEomBalance]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Financial].[CustomerAccountEomBalance]
AS
SELECT   [CUST_ID],
         [ACCT_NAME],
         YEAR([POST_DATE]) AS YEAR_END,
         MONTH([POST_DATE]) AS MONTH_END,
         SUM([ACCT_BALANCE]) AS EOM_BALANCE
FROM     [AP_FINANCE].[Financial].[ACCOUNT]
GROUP BY YEAR([POST_DATE]), MONTH([POST_DATE]), [CUST_ID], [ACCT_NAME];

GO
/****** Object:  View [Financial].[MonthlyGoldBuyReport]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Financial].[MonthlyGoldBuyReport]
AS
SELECT   T.[CUST_ID],
         T.[ACCT_NO],
         CWV.[CALENDAR_YEAR] AS TRANS_YEAR,
         CWV.[MONTH_NAME] AS TRANS_MONTH,
         CWV.[CALENDAR_MONTH] AS TRANS_MONTH_NO,
         CWV.[QUARTER_NAME] AS TRANS_QTR,
         CWV.[CALENDAR_YEAR_WEEK] AS TRANS_WEEK,
         T.SYMBOL AS TRANS_SYMBOL,
         T.BUY_SELL,
         SUM(T.[TRANS_AMOUNT]) AS SUM_TRANS_AMT
FROM     [AP_FINANCE].[Financial].[TRANSACTION] AS T WITH (NOLOCK)
         INNER JOIN
         [MasterData].[CALENDAR_WEEK_VIEW] AS CWV WITH (NOLOCK)
         ON T.TRANS_DATE = CWV.[CALENDAR_DATE]
WHERE    T.SYMBOL = 'GC=F'
         AND T.BUY_SELL = 'B'
GROUP BY T.[CUST_ID], T.[ACCT_NO], CWV.[CALENDAR_YEAR], CWV.[MONTH_NAME], CWV.[CALENDAR_MONTH], CWV.[QUARTER_NAME], CWV.[CALENDAR_YEAR_WEEK], T.SYMBOL, T.BUY_SELL;

GO
/****** Object:  View [Financial].[MonthlyGoldPerformanceReport]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Financial].[MonthlyGoldPerformanceReport]
AS
SELECT   T.[CUST_ID],
         T.[ACCT_NO],
         CWV.[CALENDAR_YEAR] AS TRANS_YEAR,
         CWV.[MONTH_NAME] AS TRANS_MONTH,
         CWV.[CALENDAR_MONTH] AS TRANS_MONTH_NO,
         CWV.[QUARTER_NAME] AS TRANS_QTR,
         CWV.[CALENDAR_YEAR_WEEK] AS TRANS_WEEK,
         T.SYMBOL AS TRANS_SYMBOL,
         SUM(T.[TRANS_AMOUNT]) AS SUM_TRANS_AMT
FROM     [AP_FINANCE].[Financial].[TRANSACTION] AS T WITH (NOLOCK)
         INNER JOIN
         [MasterData].[CALENDAR_WEEK_VIEW] AS CWV WITH (NOLOCK)
         ON T.TRANS_DATE = CWV.[CALENDAR_DATE]
WHERE    T.SYMBOL = 'GC=F'
GROUP BY T.[CUST_ID], T.[ACCT_NO], CWV.[CALENDAR_YEAR], CWV.[MONTH_NAME], CWV.[CALENDAR_MONTH], CWV.[QUARTER_NAME], CWV.[CALENDAR_YEAR_WEEK], T.SYMBOL;

GO
/****** Object:  View [Financial].[MonthlyGoldSellReport]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Financial].[MonthlyGoldSellReport]
AS
SELECT   T.[CUST_ID],
         T.[ACCT_NO],
         CWV.[CALENDAR_YEAR] AS TRANS_YEAR,
         CWV.[MONTH_NAME] AS TRANS_MONTH,
         CWV.[CALENDAR_MONTH] AS TRANS_MONTH_NO,
         CWV.[QUARTER_NAME] AS TRANS_QTR,
         CWV.[CALENDAR_YEAR_WEEK] AS TRANS_WEEK,
         T.SYMBOL AS TRANS_SYMBOL,
         T.BUY_SELL,
         SUM(T.[TRANS_AMOUNT]) AS SUM_TRANS_AMT
FROM     [AP_FINANCE].[Financial].[TRANSACTION] AS T WITH (NOLOCK)
         INNER JOIN
         [MasterData].[CALENDAR_WEEK_VIEW] AS CWV WITH (NOLOCK)
         ON T.TRANS_DATE = CWV.[CALENDAR_DATE]
WHERE    T.SYMBOL = 'GC=F'
         AND T.BUY_SELL = 'S'
GROUP BY T.[CUST_ID], T.[ACCT_NO], CWV.[CALENDAR_YEAR], CWV.[MONTH_NAME], CWV.[CALENDAR_MONTH], CWV.[QUARTER_NAME], CWV.[CALENDAR_YEAR_WEEK], T.SYMBOL, T.BUY_SELL;

GO
/****** Object:  View [Financial].[MonthlyInstrumentPerformance]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Financial].[MonthlyInstrumentPerformance]
AS
SELECT   T.[CUST_ID],
         T.[ACCT_NO],
         YEAR(T.[TRANS_DATE]) AS TRANS_YEAR,
         CWV.[MONTH_NAME] AS TRANS_MONTH,
         CWV.[CALENDAR_MONTH] AS TRANS_MONTH_NO,
         CWV.[QUARTER_NAME] AS TRANS_QTR,
         CWV.[CALENDAR_YEAR_WEEK] AS TRANS_WEEK,
         CWV.[CALENDAR_DATE] AS TRANS_DATE,
         T.SYMBOL,
         SUM(T.[TRANS_AMOUNT]) AS SUM_TRANS_AMT
FROM     [AP_FINANCE].[Financial].[TRANSACTION] AS T
         INNER JOIN
         [MasterData].[CALENDAR_WEEK_VIEW] AS CWV
         ON T.TRANS_DATE = CWV.[CALENDAR_DATE]
GROUP BY T.[CUST_ID], T.[ACCT_NO], YEAR(T.[TRANS_DATE]), CWV.[MONTH_NAME], CWV.[CALENDAR_MONTH], CWV.[QUARTER_NAME], CWV.[CALENDAR_YEAR_WEEK], CWV.[MONTH_NAME], CWV.[CALENDAR_DATE], T.SYMBOL;

GO
/****** Object:  View [FinancialReports].[AccountMonthlyBalancesMemView]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  View [MasterData].[AccountTypeView]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [MasterData].[AccountTypeView]
AS
SELECT [TRANS_ACCT_TYPE_KEY],
       [ACCT_TYPE_CODE],
       [TYPE_CODE_DESCRIPTION]
FROM   [MasterData].[TRANSACTION_ACCOUNT_TYPE];

GO
/****** Object:  View [MasterData].[TransactionTypeView]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [MasterData].[TransactionTypeView]
AS
SELECT [TRANS_ACCT_TYPE_KEY],
       [TRANS_TYPE_CODE],
       [TYPE_CODE_DESCRIPTION]
FROM   [MasterData].[TRANSACTION_ACCOUNT_TYPE];

GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[NtileSymbolBuckets]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NtileSymbolBuckets](
	[TransYear] [int] NULL,
	[Symbol] [varchar](64) NOT NULL,
	[SumTransactions] [decimal](38, 2) NULL,
	[InvestmentBucket] [bigint] NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[Account]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[Account](
	[AcctKey] [int] IDENTITY(1,1) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[PrtAcctNo] [char](6) NOT NULL,
	[AcctTypeCode] [varchar](8) NOT NULL,
	[AcctBalance] [decimal](10, 2) NOT NULL,
	[PostDate] [date] NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[AccountVersusTarget]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [Financial].[BuyTradeHistory]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[BuyTradeHistory](
	[TransYear] [int] NULL,
	[Symbol] [varchar](64) NOT NULL,
	[TransType] [varchar](3) NOT NULL,
	[SumTransactions] [decimal](10, 2) NULL,
	[InvestmentBucket] [int] NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[CustomerBuyTransaction]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[CustomerBuyTransaction](
	[TransDate] [date] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[TradeNo] [smallint] NOT NULL,
	[TransAmount] [decimal](10, 2) NOT NULL,
	[TransTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[DailyPortfolioAnalysis]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[DailyPortfolioAnalysis](
	[TradeYear] [int] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[Portfolio] [varchar](278) NOT NULL,
	[YearlyValue] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[DeleteTransactions]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[DeleteTransactions](
	[TransKey] [int] NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[MonthlyAccountAnalysis]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [Financial].[Portfolio]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[Portfolio](
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[PortfolioAccountTypeCode] [varchar](3) NOT NULL,
	[Portfolio] [varchar](278) NOT NULL,
	[Value] [decimal](10, 2) NOT NULL,
	[RollingBalance] [decimal](10, 2) NOT NULL,
	[SweepDate] [date] NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[PortfolioMovement]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [Financial].[SellTradeHistory]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[SellTradeHistory](
	[TransYear] [int] NULL,
	[Symbol] [varchar](64) NOT NULL,
	[TransType] [varchar](4) NOT NULL,
	[SumTransactions] [decimal](10, 2) NULL,
	[InvestmentBucket] [int] NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[TickerSymbols]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[TickerSymbols](
	[Symbol] [varchar](64) NOT NULL,
	[Name] [varchar](64) NOT NULL,
	[TransactionTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Financial].[TransactionTest]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Financial].[TransactionTest](
	[TransDate] [date] NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[Price] [money] NULL,
	[Quantity] [money] NULL,
	[TransAmount] [decimal](10, 2) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[PortfolioAccountTypeCode] [varchar](3) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[BuySell] [varchar](1) NOT NULL,
	[TransactionTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [FinancialReports].[AccountClustered]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FinancialReports].[AccountClustered](
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](38, 2) NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [FinancialReports].[AccountMonthlyBalancePTable]    Script Date: 7/7/2023 10:59:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FinancialReports].[AccountMonthlyBalancePTable](
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,
	[PostDate] [date] NULL
) ON [psAccountBalancesByYearScheme]([PostDate])
GO
/****** Object:  Table [FinancialReports].[AccountMonthlyBalances]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [FinancialReports].[PortfolioMonthlyBalances]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [MasterData].[AccountType]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[AccountType](
	[AcctTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[AcctTypeCode] [varchar](8) NOT NULL,
	[AcctTypeName] [varchar](64) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [MasterData].[Customer]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[Customer](
	[CustKey] [int] IDENTITY(1,1) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[CustLname] [varchar](64) NOT NULL,
	[CustFname] [varchar](64) NOT NULL,
	[CustIncome] [money] NOT NULL,
	[IncomeBracket] [varchar](64) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [MasterData].[CustomerMemoryOptimied]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[CustomerMemoryOptimied]
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
/****** Object:  Table [MasterData].[CustomerTickerSymbols]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[CustomerTickerSymbols](
	[CustSymbolKey] [int] IDENTITY(1,1) NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[Symbol] [varchar](64) NOT NULL,
	[TransactionTypeCode] [varchar](8) NOT NULL,
	[CustTradesInFlag] [varchar](1) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [MasterData].[PortfolioAccountType]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[PortfolioAccountType](
	[PortfolioAccountTypeCode] [char](3) NOT NULL,
	[PortfolioAccountTypeName] [varchar](278) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [MasterData].[TickerHistory]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[TickerHistory](
	[Ticker] [varchar](64) NOT NULL,
	[Company] [varchar](128) NOT NULL,
	[TickerDate] [date] NOT NULL,
	[QuoteHour] [smallint] NOT NULL,
	[Quote] [decimal](10, 2) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [MasterData].[TickerPriceRangeHistory]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[TickerPriceRangeHistory](
	[Ticker] [varchar](64) NOT NULL,
	[Company] [varchar](128) NOT NULL,
	[TickerDate] [date] NOT NULL,
	[Low] [decimal](10, 2) NULL,
	[High] [decimal](10, 2) NULL,
	[Spread] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [MasterData].[TickerPriceRangeHistoryDetail]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [MasterData].[TransactionAccountType]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[TransactionAccountType](
	[TransAcctTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[TransTypeCode] [varchar](32) NOT NULL,
	[AcctTypeCode] [varchar](32) NOT NULL,
	[TypeCodeDescription] [varchar](256) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [MasterData].[TransactionType]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[TransactionType](
	[TransTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[TransTypeCode] [varchar](32) NOT NULL,
	[TransTypeDescription] [varchar](256) NOT NULL
) ON [AP_FINANCE_FG]
GO
/****** Object:  Table [Report].[CustomerC0000001Analysis]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  StoredProcedure [Financial].[usp_EquityTransactionGenerator]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Financial].[usp_EquityTransactionGenerator]
@CUST_ID VARCHAR (8), @PORTFOLIO_NO VARCHAR (8), @ACCT_NO VARCHAR (8), @BUY_SELL CHAR (1)
AS
BEGIN
    DECLARE @TRADES TABLE (
        TRANS_DATE        DATE       ,
        SYMBOL            VARCHAR (8),
        PRICE             MONEY      ,
        SHARES            INT        ,
        CUST_ID           CHAR (8)   ,
        PORTFOLIO_NO      VARCHAR (8),
        ACCT_NO           VARCHAR (8),
        [BUY_SELL]        CHAR (1)   ,
        [TRANS_TYPE_CODE] VARCHAR (8));
    DECLARE @BUYDAYS TABLE (
        DAYS INT);
    INSERT  INTO @BUYDAYS
    VALUES (5),
    (10),
    (15),
    (20),
    (25);
    DECLARE @SELLDAYS TABLE (
        DAYS INT);
    DECLARE @TRANS_DAYS TABLE (
        DAYS INT);
    INSERT  INTO @SELLDAYS
    VALUES (12),
    (18),
    (29);
    IF @BUY_SELL = 'B'
        BEGIN
            INSERT INTO @TRANS_DAYS
            SELECT DAYS
            FROM   @BUYDAYS;
        END
    ELSE
        IF @BUY_SELL = 'S'
            BEGIN
                INSERT INTO @TRANS_DAYS
                SELECT DAYS
                FROM   @SELLDAYS;
            END
    DECLARE @TRANS_TYPE_CODE AS VARCHAR (8);
    SET @TRANS_TYPE_CODE = 'TT00002';
    INSERT INTO @TRADES
    EXECUTE TRADE.uspEquityTradeGenerator @CUST_ID, @PORTFOLIO_NO, @ACCT_NO, @BUY_SELL, @TRANS_TYPE_CODE;
    INSERT INTO [Financial].[TRANSACTION]
    SELECT TRANS_DATE,
           SYMBOL,
           PRICE,
           SHARES,
           CASE WHEN @BUY_SELL = 'B' THEN (PRICE * SHARES) WHEN @BUY_SELL = 'S' THEN -(PRICE * SHARES) END AS [TRANS_AMOUNT],
           CUST_ID,
           PORTFOLIO_NO,
           ACCT_NO,
           BUY_SELL,
           TRANS_TYPE_CODE
    FROM   @TRADES
    WHERE  DAY(TRANS_DATE) IN (SELECT DAYS
                               FROM   @TRANS_DAYS);
END

GO
/****** Object:  StoredProcedure [Financial].[usp_InstrumentTransactionGenerator]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Financial].[usp_InstrumentTransactionGenerator]
@CUST_ID VARCHAR (8), @PORTFOLIO_NO VARCHAR (8), @ACCT_NO VARCHAR (8), @BUY_SELL CHAR (1)
AS
BEGIN
    DECLARE @TRADES TABLE (
        TRANS_DATE        DATE        ,
        SYMBOL            VARCHAR (64),
        PRICE             MONEY       ,
        SHARES            INT         ,
        CUST_ID           CHAR (8)    ,
        PORTFOLIO_NO      VARCHAR (8) ,
        ACCT_NO           VARCHAR (8) ,
        [BUY_SELL]        CHAR (1)    ,
        [TRANS_TYPE_CODE] VARCHAR (8) );
    DECLARE @BUYDAYS TABLE (
        DAYS INT);
    INSERT  INTO @BUYDAYS
    VALUES (6),
    (11),
    (16),
    (21),
    (22);
    DECLARE @SELLDAYS TABLE (
        DAYS INT);
    DECLARE @TRANS_DAYS TABLE (
        DAYS INT);
    INSERT  INTO @SELLDAYS
    VALUES (13),
    (19),
    (28);
    IF @BUY_SELL = 'B'
        BEGIN
            INSERT INTO @TRANS_DAYS
            SELECT DAYS
            FROM   @BUYDAYS;
        END
    ELSE
        IF @BUY_SELL = 'S'
            BEGIN
                INSERT INTO @TRANS_DAYS
                SELECT DAYS
                FROM   @SELLDAYS;
            END
    INSERT INTO @TRADES
    EXECUTE TRADE.uspInstrumentTradeGenerator @CUST_ID, @PORTFOLIO_NO, @ACCT_NO, @BUY_SELL;
    INSERT INTO [Financial].[TRANSACTION]
    SELECT TRANS_DATE,
           SYMBOL,
           PRICE,
           SHARES,
           CASE WHEN @BUY_SELL = 'B' THEN (PRICE * SHARES) WHEN @BUY_SELL = 'S' THEN -(PRICE * SHARES) END AS [TRANS_AMOUNT],
           CUST_ID,
           PORTFOLIO_NO,
           ACCT_NO,
           CASE WHEN SYMBOL = 'CHECKING'
                     AND BUY_SELL = 'B' THEN 'D' WHEN SYMBOL = 'CHECKING'
                                                      AND BUY_SELL = 'S' THEN 'W' ELSE BUY_SELL END AS [BUY_SELL],
           TRANS_TYPE_CODE
    FROM   @TRADES
    WHERE  DAY(TRANS_DATE) IN (SELECT DAYS
                               FROM   @TRANS_DAYS);
END

GO
/****** Object:  StoredProcedure [Financial].[usp_RandomFloat]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Financial].[usp_RandomFloat]
@RANDOM_VALUE FLOAT OUTPUT, @START_RANGE FLOAT, @STOP_RANGE FLOAT
AS
SET @RANDOM_VALUE = CONVERT (FLOAT, ROUND(UPPER(RAND() * @STOP_RANGE + @START_RANGE), 0));

GO
/****** Object:  StoredProcedure [Financial].[uspEquityTradeGenerator]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Financial].[uspEquityTradeGenerator]
@CUST_ID VARCHAR (8), @PORTFOLIO_NO VARCHAR (8), @ACCT_NO VARCHAR (8), @BUY_SELL CHAR (1), @TRANS_TYPE_CODE VARCHAR (8)
AS
BEGIN
    DECLARE @EQUITY TABLE (
        SYMBOL VARCHAR (64) NOT NULL);
    DECLARE @TRADE TABLE (
        SHARES      INT   NOT NULL,
        DAY_OF_YEAR INT  ,
        PRICE       FLOAT);
    INSERT  INTO @EQUITY
    VALUES ('AAA'),
    ('BBB'),
    ('CCC'),
    ('DDD'),
    ('EEE'),
    ('FFF');
    DECLARE @START AS INT;
    DECLARE @STOP AS INT;
    DECLARE @RANDOM_QTY AS FLOAT;
    DECLARE @PRICE AS FLOAT;
    SET @START = 1;
    SET @STOP = 365;
    WHILE @START <= @STOP
        BEGIN
            EXECUTE TRADE.usp_RandomFloat @RANDOM_QTY OUTPUT, 100, 200;
            EXECUTE TRADE.usp_RandomFloat @PRICE OUTPUT, 15, 30;
            INSERT  INTO @TRADE
            VALUES (@RANDOM_QTY, @START, @PRICE);
            SET @START = @START + 1;
        END
    SELECT   CAL.CALENDAR_DATE,
             C.SYMBOL,
             CC.PRICE + ASCII(SUBSTRING(C.SYMBOL, 2, 1)) + 15.00 AS PRICE,
             CC.SHARES + ASCII(RIGHT(C.SYMBOL, 1)) AS SHARES,
             @CUST_ID AS CUST_ID,
             @PORTFOLIO_NO AS PORTFOLIO_NO,
             @ACCT_NO AS ACCT_NO,
             @BUY_SELL AS BUY_SELL,
             @TRANS_TYPE_CODE AS TRANS_TYPE_CODE
    FROM     @EQUITY AS C CROSS JOIN @TRADE AS CC
             INNER JOIN
             [MASTER_DATA].[CALENDAR] AS CAL
             ON DATEPART(dayofyear, CAL.CALENDAR_DATE) = CC.DAY_OF_YEAR
    ORDER BY 1, 2, 3;
END

GO
/****** Object:  StoredProcedure [Financial].[uspInstrumentTradeGenerator]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Financial].[uspInstrumentTradeGenerator]
@CUST_ID VARCHAR (8), @PORTFOLIO_NO VARCHAR (8), @ACCT_NO VARCHAR (8), @BUY_SELL CHAR (1)
AS
BEGIN
    DECLARE @Instrument TABLE (
        SYMBOL          VARCHAR (64) NOT NULL,
        TRANS_TYPE_CODE VARCHAR (32) NOT NULL);
    DECLARE @TRADE TABLE (
        SHARES      INT   NOT NULL,
        DAY_OF_YEAR INT  ,
        PRICE       FLOAT);
    INSERT INTO @Instrument
    SELECT [SYMBOL],
           [TRANSACTION_TYPE_CODE]
    FROM   [Financial].[TICKER_SYMBOLS];
    DECLARE @START AS INT;
    DECLARE @STOP AS INT;
    DECLARE @RANDOM_QTY AS FLOAT;
    DECLARE @PRICE AS FLOAT;
    SET @START = 1;
    SET @STOP = 365;
    WHILE @START <= @STOP
        BEGIN
            EXECUTE TRADE.usp_RandomFloat @RANDOM_QTY OUTPUT, 100, 200;
            EXECUTE TRADE.usp_RandomFloat @PRICE OUTPUT, 15, 30;
            INSERT  INTO @TRADE
            VALUES (@RANDOM_QTY, @START, @PRICE);
            SET @START = @START + 1;
        END
    SELECT   CAL.CALENDAR_DATE,
             C.SYMBOL,
             CC.PRICE + ASCII(SUBSTRING(C.SYMBOL, 2, 1)) + 15.00 AS PRICE,
             CC.SHARES + ASCII(RIGHT(C.SYMBOL, 1)) AS SHARES,
             @CUST_ID AS CUST_ID,
             @PORTFOLIO_NO AS PORTFOLIO_NO,
             @ACCT_NO AS ACCT_NO,
             @BUY_SELL AS BUY_SELL,
             C.TRANS_TYPE_CODE AS TRANS_TYPE_CODE
    FROM     @Instrument AS C CROSS JOIN @TRADE AS CC
             INNER JOIN
             [MASTER_DATA].[CALENDAR] AS CAL
             ON DATEPART(dayofyear, CAL.CALENDAR_DATE) = CC.DAY_OF_YEAR
    ORDER BY 1, 2, 3;
END

GO
/****** Object:  StoredProcedure [Financial].[uspLoadTransactions]    Script Date: 7/7/2023 10:59:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Financial].[uspLoadTransactions]
@BUY_FLAG CHAR (1)
AS
DECLARE @CUST_ID AS VARCHAR (8);
DECLARE @PORTFOLIO_NO AS VARCHAR (8);
DECLARE @ACCT_NO AS VARCHAR (8);
DECLARE TRADE_GENERATOR CURSOR
    FOR SELECT   DISTINCT [CUST_ID],
                          [PRTF_NO],
                          [ACCT_NO]
        FROM     [AP_FINANCE].[Financial].[ACCOUNT]
        ORDER BY [CUST_ID], [PRTF_NO], [ACCT_NO];
OPEN TRADE_GENERATOR;
FETCH TRADE_GENERATOR INTO @CUST_ID, @PORTFOLIO_NO, @ACCT_NO;
WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Customer: ' + @CUST_ID + ' Portfolio: ' + @PORTFOLIO_NO + ' Account No: ' + @ACCT_NO;
        EXECUTE TRADE.usp_EquityTransactionGenerator @CUST_ID, @PORTFOLIO_NO, @ACCT_NO, @BUY_FLAG;
        FETCH TRADE_GENERATOR INTO @CUST_ID, @PORTFOLIO_NO, @ACCT_NO;
    END
CLOSE TRADE_GENERATOR;
DEALLOCATE TRADE_GENERATOR;

GO
