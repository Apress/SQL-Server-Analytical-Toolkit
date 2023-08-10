USE APFinance
GO

/*******************************************/
/* Chapter 5 - APFinance Database Use Case */
/* Aggregate Functions                     */
/* Created: 08/19/2022                     */
/* Modified: 07/20/2023                    */
/* Production                              */
/*******************************************/

-- assume account balances indicate total for that month
-- they do not include prior month, rolling balances indicate that
-- so for example, if an account netted $1000 in January, and in February
-- the account netted another $1000 the total acount value is $2000 as of February
-- same applies for portfolio balances

-- USE FOR REFERENCE IF YOU WANT TO EXPERIMENT

/* ROWS
ROWS BETWEEN lower_bound AND upper_bound
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
ROWS BETWEEN 3 PRECEDING AND CURRENT ROW

UNBOUNDED PRECEDING
N PRECEDING
CURRENT ROW
N FOLLOWING
UNBOUNDED FOLLOWING

*/

/* FRAME
RANGE BETWEEN lower_bound AND upper_bound
RANGE BETWEEN 0 PRECEDING AND CURRENT ROW
RANGE BETWEEN 1 PRECEDING AND CURRENT ROW

BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
BETWEEN n PRECEDING AND CURRENT ROW
BETWEEN CURRENT ROW AND CURRENT ROW
BETWEEN AND CURRENT ROW AND n FOLLOWING
BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
*/

/*
DECLARE @Table TABLE (
	YearValue SMALLINT,
	MonthValue INT,
	ColValue INT
	);

INSERT INTO @Table VALUES
(2010,1,1),
(2010,2,1),
(2010,3,1),
(2010,4,2),
(2010,5,2),
(2010,6,2),
(2010,7,3),
(2010,8,3),
(2010,9,3),
(2010,10,4),
(2010,11,4),
(2010,12,4);

SELECT
	YearValue,
	MonthValue,
	ColValue,
	SUM(ColValue) OVER (
		PARTITION BY YearValue
		ORDER BY MonthValue
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
		) AS [3-MonthRollingSum]
FROM @Table
GO
*/

/*
SET SHOWPLAN_ALL ON
GO

SET SHOWPLAN_TEXT ON
GO

SET STATISTICS PROFILE ON
GO
*/

/***********************/
/* Aggregate Functions */
/***********************/

/*
•	COUNT()
•	COUNT_BIG()
•	SUM()
•	MAX()
•	MIN()
•	AVG()
•	GROUPING()
•	STRING_AGG()
•	STDEV()
•	STDEVP()
•	VAR()
•	VARP()

*/

/***********/
/* COUNT() */
/***********/

/******************************************************/
/* Listing 5.1 – Count() Function in all its’ Flavors */
/******************************************************/

DECLARE @CountExample TABLE (
	ProductType VARCHAR(64)
	);

INSERT INTO @CountExample VALUES
('Type A'),
('Type A'),
('Type A'),
('Type A'),
('Type A'),
('Type A'),
('Type B'),
('Type B'),
('Type B'),
('Type B');

SELECT COUNT(*) FROM @CountExample;

SELECT COUNT(DISTINCT ProductType) FROM @CountExample;

SELECT COUNT(ALL ProductType) FROM @CountExample;

SELECT COUNT(ProductType) FROM @CountExample;
GO

/**************************************************/
/* Listing 5.2a & b – Customer Analysis CTE Query */
/**************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

/*************************************************/
/* remember, customers trade in selected symbols */
/*************************************************/

WITH CustomerTransactions (
	TransYear,TransQtr,TransMonth,TransWeek,TransDate,
		CustId,CustFname,CustLName,AcctNo,BuySell,Symbol,DailyCount
	)
AS (
-- Listing 5.2a –Customer Analysis CTE Query
SELECT YEAR(T.TransDate)        AS TransYear
	,DATEPART(qq,(T.TransDate)) AS TransQtr
	,MONTH(T.TransDate)         AS TransMonth
	,DATEPART(ww,T.TransDate)   AS TransWeek
	,T.TransDate
    ,C.CustId
	,C.CustFname
	,C.CustLname
	,T.AcctNo
    ,T.BuySell
	,T.Symbol
	,COUNT(*) AS DailyCount
FROM [Financial].[Transaction] T
JOIN [MasterData].[Customer] C
ON T.CustId = C.CustId
GROUP BY YEAR(T.TransDate)
	,DATEPART(qq,(T.TransDate))
	,MONTH(T.TransDate)
	,T.TransDate
	,T.BuySell
	,T.Symbol
    ,C.CustId
	,C.CustFname
	,C.CustLname
	,AcctNo
)
-- Listing 5.2b – Customer Analysis Outer Query
SELECT TransYear
	,TransQtr
	,TransMonth
	,TransWeek
	,TransDate
	,CustId
	,CustFName + ' ' + CustLname AS [Customer Name]
	,AcctNo
	,BuySell
	,Symbol
	,DailyCount
	,SUM(DailyCount) OVER (
	PARTITION BY TransQtr
	ORDER BY TransQtr,TransMonth,TransDate 
	ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
	)AS RollingTransCount
FROM CustomerTransactions
WHERE CustId = 'C0000001'
AND TransYear = 2012 
AND BuySell = 'B'
AND Symbol  = 'AA'
AND AcctNo = 'A02C1'
ORDER BY TransYear
		,TransQtr
		,TransMonth
		,TransDate
		,CustId	
		,BuySell
		,Symbol
GO

-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/**********************************************************/
/* Missing index as suggested by Estimated Execution Plan */
/* for the CTE query                                      */
/**********************************************************/

DROP INDEX IF EXISTS ieTransDateSymbolAcctNoBuySell
ON [Financial].[Transaction] 
GO

CREATE NONCLUSTERED INDEX ieTransDateSymbolAcctNoBuySell
ON [Financial].[Transaction] ([CustId])
INCLUDE ([TransDate],[Symbol],[AcctNo],[BuySell])
GO

/*******************/
/* Deeper Analysis */
/*******************/

/*
If you get red lines under code but there are no syntax errors:
rebuild your IntelliSense cache to get rid of red lines.
CTRL+SHIFT+R
or
Edit -> IntelliSense -> Refresh Local Cache.
*/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

/*****************************************************/
/* Listing 5.4 – Loading the Customer Analysis Table */
/*****************************************************/

DROP SCHEMA IF EXISTS Report
GO

CREATE SCHEMA [Report]
GO

-- Query below takes about 4 minutes to run, 644764 rows

TRUNCATE TABLE Report.CustomerC0000001Analysis
GO

INSERT INTO Report.CustomerC0000001Analysis
SELECT YEAR(T.TransDate)        AS TransYear
	,DATEPART(qq,(T.TransDate)) AS TransQtr
	,MONTH(T.TransDate)         AS TransMonth
	,DATEPART(ww,T.TransDate)   AS TransWeek
	,T.TransDate
    ,C.CustId
	,C.CustFname
	,C.CustLname
	,T.AcctNo
    ,T.BuySell
	,T.Symbol
	,COUNT(*) AS DailyCount
FROM [Financial].[Transaction] T
JOIN [MasterData].[Customer] C
ON T.CustId = C.CustId
GROUP BY YEAR(T.TransDate)
	,DATEPART(qq,(T.TransDate))
	,MONTH(T.TransDate)
	,T.TransDate
	,T.BuySell
	,T.Symbol
    ,C.CustId
	,C.CustFname
	,C.CustLname
	,AcctNo
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS PROFILE ON
GO

SELECT TransYear
	,TransQtr
	,TransMonth
	,TransWeek
	,TransDate
	,CustId
	,CustFName + ' ' + CustLname AS [Customer Name]
	,AcctNo
	,BuySell
	,Symbol
	,DailyCount
	,SUM(DailyCount) OVER (
		PARTITION BY TransQtr
		ORDER BY TransQtr,TransMonth,TransDate 
		ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
	)AS RollingTransCount
FROM Report.CustomerC0000001Analysis
WHERE CustId = 'C0000001'
AND TransYear = 2012
AND BuySell = 'B'
AND Symbol  = 'AA'
AND AcctNo = 'A02C1'
ORDER BY TransYear
		,TransQtr
		,TransMonth
		,TransDate
		,CustId	
		,BuySell
		,Symbol
GO

SET STATISTICS PROFILE OFF
GO

-- I thought this index would help

DROP INDEX IF EXISTS ieCust01Cashanalysis 
ON Report.CustomerC0000001Analysis
GO

CREATE INDEX ieCust01Cashanalysis 
ON Report.CustomerC0000001Analysis
(CustId,TransYear,BuySell,Symbol,AcctNo)
GO

/*
Missing Index Details from SQLQuery2.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance(DESKTOP-CEBK38L\Angelo (71))
The Query Processor estimates that implementing the following index could improve the query cost by 83.6611%.
*/

-- drop the old index
DROP INDEX IF EXISTS ieCust01Cashanalysis 
ON Report.CustomerC0000001Analysis
GO

-- drop the new one when experimenting
DROP INDEX IF EXISTS [ieTransQtrMonthWeekDateCustFnameLnameDailyCount]
ON Report.CustomerC0000001Analysis
GO

CREATE NONCLUSTERED INDEX [ieTransQtrMonthWeekDateCustFnameLnameDailyCount]
ON [Report].[CustomerC0000001Analysis] ([TransYear],[CustId],[AcctNo],[BuySell],[Symbol])
INCLUDE ([TransQtr],[TransMonth],[TransWeek],[TransDate],[CustFname],[CustLname],[DailyCount])
GO

/*********************************/
/* USING MEMORY OPTIMIZED TABLES */
/*********************************/

/**********************************************/
/* Create the new memory optimied file group: */
/* AP_FINANCE_MEM_OPT_FG with SSMS            */
/**********************************************/

-- next two commands need not be run as the file group and file
-- where created when the database was created.

/*
ALTER DATABASE [APFinance]
ADD FILEGROUP [AP_FINANCE_MEM_OPT_FG] CONTAINS MEMORY_OPTIMIZED_DATA
GO

ALTER DATABASE [APFinance]
    ADD FILE (  
        NAME = N'AP_FINANCE_MEM_OPT_F1',  
        FILENAME = N'D:\APPRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA\AP_FINANCE_MEM_OPT_F1.NDF'  
    )  TO FILEGROUP AP_FINANCE_MEM_OPT_FG;  
GO 
*/

DROP TABLE IF EXISTS [MasterData].[CustomerMemoryOptimized]
GO

CREATE TABLE [MasterData].[CustomerMemoryOptimized](
	[CustKey] [int] IDENTITY(1,1) NOT NULL INDEX pkCustKey NONCLUSTERED,
	[CustId] [varchar](8) NOT NULL,
	[CustLname] [varchar](64) NOT NULL,
	[CustFname] [varchar](64) NOT NULL,
	[CustIncome] [money] NOT NULL,
	[IncomeBracket] [varchar](64) NOT NULL
) WITH (
MEMORY_OPTIMIZED = ON,
DURABILITY = SCHEMA_ONLY)
GO

/*
TRUNCATE TABLE [MasterData].[CustomerMemoryOptimized]
GO
*/

INSERT INTO [MasterData].[CustomerMemoryOptimized]
SELECT [CustId], [CustLname], [CustFname], [CustIncome], [IncomeBracket]
FROM [MasterData].[Customer]
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

SELECT YEAR(T.TransDate)        AS TransYear
	,DATEPART(qq,(T.TransDate)) AS TransQtr
	,MONTH(T.TransDate)         AS TransMonth
	,DATEPART(ww,T.TransDate)   AS TransWeek
	,T.TransDate
    ,C.CustId
	,C.CustFname
	,C.CustLname
	,T.AcctNo
    ,T.BuySell
	,T.Symbol
	,COUNT(*) AS DailyCount
FROM [MasterData].[CustomerMemoryOptimized] C
JOIN [Financial].[Transaction] T
ON T.CustId = C.CustId
GROUP BY YEAR(T.TransDate)
	,DATEPART(qq,(T.TransDate))
	,MONTH(T.TransDate)
	,T.TransDate
	,T.BuySell
	,T.Symbol
    ,C.CustId
	,C.CustFname
	,C.CustLname
	,AcctNo
GO

-- turn set statistics io/time off
SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/******************************************************/
/* Listing 5.5 – Account Cash Summary Totals Analysis */
/******************************************************/

-- assume account balances indicate total for that month
-- they do not include prior month, rolling balances indicate that
-- so for example, if an account netted $1000 in January, and in February
-- the account netted another $1000 the total acount value is $2000 as of February

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

SET SHOWPLAN_ALL ON
GO

SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,PostDate
	,CustId
    ,PrtfNo
    ,AcctNo
    ,AcctName
    ,AcctTypeCode
	,AcctBalance
    ,SUM(AcctBalance) OVER(
		PARTITION BY YEAR(PostDate),MONTH(PostDate)
		ORDER BY PostDate
	) AS RollingDailyBalance
FROM Financial.Account
WHERE YEAR(PostDate) = 2012
/* To report on more than 1 year */
--WHERE YEAR(PostDate) IN(2012,2013,2014)
AND CustId = 'C0000001'
AND AcctName = 'CASH'
AND MONTH(PostDate) = 1
ORDER BY YEAR(PostDate)
	,MONTH(PostDate) 
	,PostDate
	,CustId
	,AcctName
	,AcctNo
GO

-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

SET SHOWPLAN_ALL OFF
GO

/****************************************************/
/* Index suggested by Estmiated Execution Plan Tool */
/****************************************************/

/*********************************/
/* Listing 5.6 – Suggested Index */
/*********************************/

DROP INDEX IF EXISTS [iePrtNoAcctNoTypeBalPostDate]
ON [Financial].[Account] 
GO

CREATE NONCLUSTERED INDEX [iePrtNoAcctNoTypeBalPostDate]
ON [Financial].[Account] ([CustId],[AcctName])
INCLUDE ([PrtfNo],[AcctNo],[AcctTypeCode],[AcctBalance],[PostDate])
GO

/*****************************************************/
/* Listing 5.7 – Min() and Max() in a simple example */
/********************************8********************/

DECLARE @MinMaxExample TABLE (
	ExampleValue SMALLINT
	);

INSERT INTO @MinMaxExample VALUES
(20),
(20),
(30),
(40),
(60),
(60);

SELECT MIN(ExampleValue) AS MinExampleValue,COUNT(ExampleValue) AS MinCount
FROM @MinMaxExample;
SELECT MIN(ALL ExampleValue) AS MinExampleValueALL,COUNT( ALL ExampleValue) AS MinCountALL 
FROM @MinMaxExample;
SELECT MIN(DISTINCT ExampleValue) AS MinExampleValueDISTINCT,COUNT(DISTINCT ExampleValue) AS MinCountDISTINCT 
FROM @MinMaxExample;

SELECT MAX(ExampleValue) AS MaxExampleValue,COUNT(ExampleValue) AS MAXCount
FROM @MinMaxExample;
SELECT MAX(ALL ExampleValue)AS MaxExampleValueALL,COUNT( ALL ExampleValue) AS MAXCountALL
FROM @MinMaxExample;
SELECT MAX(DISTINCT ExampleValue)AS MaxExampleValueDISTINCT,COUNT( DISTINCT ExampleValue) AS MAXCountDISTINCT
FROM @MinMaxExample;
GO

/**********************************************************/
/* Listing 5.8 – Cash Analysis for Customer C000001 using */
/**********************************************************/
 
DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,PostDate
	,CustId
    ,PrtfNo
    ,AcctNo
    ,AcctName
    ,AcctTypeCode
	,AcctBalance
    ,MIN(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		/* To report on more than 1 year */
		--PARTITION BY YEAR(PostDate),MONTH(PostDate)
		ORDER BY PostDate
	) AS MonthlyAcctMin
		,MAX(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		/* To report on more than 1 year */
		--PARTITION BY YEAR(PostDate),MONTH(PostDate)
		ORDER BY PostDate
	) AS MonthlyAcctMax
FROM Financial.Account
WHERE YEAR(PostDate) = 2012

/* To report on more than 1 year */
--WHERE YEAR(PostDate) IN(2012,2013)

AND CustId = 'C0000001'
AND AcctName = 'CASH'
ORDER BY YEAR(PostDate)
	,MONTH(PostDate) 
	,PostDate
	,CustId
	,AcctName
	,AcctNo
GO

DROP INDEX IF EXISTS iePrtfNoAcctNoAcctTypeCodeAcctBalancePostDate
ON Financial.Account
GO

CREATE NONCLUSTERED INDEX iePrtfNoAcctNoAcctTypeCodeAcctBalancePostDate
ON [Financial].[Account] ([CustId],[AcctName])
INCLUDE ([PrtfNo],[AcctNo],[AcctTypeCode],[AcctBalance],[PostDate])
GO

-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

-- rolling 3 day minimum and maximum balances

SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,PostDate
	,CustId
    ,PrtfNo
    ,AcctNo
    ,AcctName
    ,AcctTypeCode
	,AcctBalance
    ,MIN(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		/* To report on more than 1 year */
		ORDER BY PostDate
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS MonthlyAcctMin
		,MAX(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		/* To report on more than 1 year */
		ORDER BY PostDate
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS MonthlyAcctMax
FROM Financial.Account
WHERE YEAR(PostDate) = 2012
AND CustId = 'C0000001'
AND AcctName = 'CASH'
ORDER BY YEAR(PostDate)
	,MONTH(PostDate) 
	,PostDate
	,CustId
	,AcctName
	,AcctNo
GO

/*********************************/
/* Listing 5.9 – Suggested Index */
/*********************************/

DROP INDEX IF EXISTS iePrtfNoAcctNoAcctTypeCodeAcctBalancePostDate
ON [Financial].[Account]
GO

CREATE NONCLUSTERED INDEX iePrtfNoAcctNoAcctTypeCodeAcctBalancePostDate
ON [Financial].[Account] ([CustId],[AcctName])
INCLUDE ([PrtfNo],[AcctNo],[AcctTypeCode],[AcctBalance],[PostDate])
GO

/************************/
/* Listing 5.10 – Query */
/************************/

-- easy example

DECLARE @AVGMaxExample TABLE (
	ValueType VARCHAR(32),
	ExampleValue SMALLINT
	);

INSERT INTO @AVGMaxExample VALUES
('Type 1',20),
('Type 1',20),
('Type 1',30),
('Type 2',40),
('Type 2',60),
('Type 3',60);

SELECT AVG(ExampleValue) AS AVGExampleValue
FROM @AVGMaxExample;

SELECT AVG(ALL ExampleValue) AS AVGExampleValueALL
FROM @AVGMaxExample;

SELECT AVG(DISTINCT ExampleValue) AS AVGExampleValueDISTINCT
FROM @AVGMaxExample;

SELECT ValueType,AVG(ExampleValue) AS AVGExampleValue
FROM @AVGMaxExample
GROUP BY  ValueType;

SELECT ValueType,AVG(ALL ExampleValue) AS AVGExampleValueALL
FROM @AVGMaxExample
GROUP BY  ValueType;

SELECT ValueType,AVG(DISTINCT ExampleValue) AS AVGExampleValueDISTINCT
FROM @AVGMaxExample
GROUP BY  ValueType;
GO

/*****************************************/
/* Listing 5.11 – Rolling 3 Day Averages */
/*****************************************/

DROP INDEX IF EXISTS [iePrtNoAcctNoTypeBalPostDate] ON [Financial].[Account]
GO

CREATE NONCLUSTERED INDEX [iePrtNoAcctNoTypeBalPostDate] ON [Financial].[Account]
(
	[CustId] ASC,
	[AcctName] ASC
)
INCLUDE([PrtfNo],[AcctNo],[AcctTypeCode],[AcctBalance],[PostDate]) 
WITH (PAD_INDEX = OFF, 
	STATISTICS_NORECOMPUTE = OFF, 
	SORT_IN_TEMPDB = ON, 
	DROP_EXISTING = OFF, 
	ONLINE = OFF, 
	ALLOW_ROW_LOCKS = ON, 
	ALLOW_PAGE_LOCKS = ON, 
	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
	) ON [AP_FINANCE_FG]
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

SELECT YEAR(PostDate)  AS AcctYear
    ,MONTH(PostDate)   AS AcctMonth
	,PostDate
	,CustId
    ,PrtfNo
    ,AcctNo
    ,AcctName
    ,AcctTypeCode
	,AcctBalance
    ,AVG(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)

	/* To report on more than 1 year */
	--PARTITION BY YEAR(PostDate),MONTH(PostDate)

		ORDER BY PostDate
	ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS [3 DayRollingAcctAvg]
FROM Financial.Account
WHERE YEAR(PostDate) = 2012

/*********************************/
/* To report on more than 1 year */
/*********************************/
--WHERE YEAR(PostDate) IN(2012,2013)

AND CustId = 'C0000001'
AND AcctName = 'CASH'
AND MONTH(PostDate) = 1
ORDER BY YEAR(PostDate)
	,MONTH(PostDate) 
	,PostDate
	,CustId
	,AcctName
	,AcctNo
GO

/**************************/
/* Try these out for size */
/**************************/

/*   ,AVG(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		ORDER BY PostDate
		ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
	) AS [4 DayRollingAcctAvg]
	,AVG(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		ORDER BY PostDate
		ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
	) AS [5 DayRollingAcctAvg]
	,AVG(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		ORDER BY PostDate
		ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
	) AS [6 DayRollingAcctAvg]
*/

-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/**************************************/
/* Listing 5.12 – Transaction Rollups */
/* for EURO Foreign Currency          */
/**************************************/

DBCC dropcleanbuffers;
CHECKPOINT
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

SET SHOWPLAN_ALL ON
GO

SELECT YEAR(TransDate) AS TransYear
	  ,DATEPART(qq,TransDate) AS TransQtr
	  ,MONTH(TransDate) AS TransMonth
	  ,TransDate
      ,Symbol
      ,CustId
	  ,TransAmount
	  ,SUM(TransAmount) AS SumOfTransAmt
	  ,GROUPING(TransAmount) AS TransAmtGroup
FROM Financial.[Transaction]
WHERE Symbol IN ('EURO','GBP')
AND CustId = 'C0000003'
AND YEAR(TransDate) = 2012
AND MONTH(TransDate) = 1
GROUP BY YEAR(TransDate)
	  ,DATEPART(qq,TransDate)
	  ,MONTH(TransDate)
	  ,TransDate
      ,Symbol
      ,CustId
	  ,TransAmount WITH ROLLUP
ORDER BY YEAR(TransDate)
	  ,DATEPART(qq,TransDate)
	  ,MONTH(TransDate)
	  ,TransDate
      ,Symbol
      ,CustId
	  ,(
		CASE	
			WHEN TransAmount IS NULL THEN 0
		END
	   )DESC
      ,SUM(TransAmount) DESC
	  ,GROUPING(TransAmount) DESC
GO

-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/*
Missing Index Details from ch05 - aggregate queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance(DESKTOP-CEBK38L\Angelo (52))
The Query Processor estimates that implementing the following index could improve the query cost by 93.7268%.

SELECT * FROM sys.dm_db_missing_index_group_stats
GO
*/

DROP INDEX IF EXISTS [ieTranSymCustBuySell]
ON [Financial].[Transaction]
GO

CREATE NONCLUSTERED INDEX [ieTranSymCustBuySell]
ON [Financial].[Transaction] ([Symbol],[CustId],[BuySell])
INCLUDE ([TransDate],[TransAmount])
GO

/*******************************/
/* Query for Excel Pivot Table */
/*******************************/

SELECT YEAR(TransDate) AS TransYear
	  ,DATEPART(qq,TransDate) AS TransQtr
	  ,MONTH(TransDate) AS TransMonth
	  ,TransDate
      ,Symbol
      ,CustId
	  ,TransAmount
FROM Financial.[Transaction]
WHERE Symbol IN ('EURO','GBP')
AND CustId = 'C0000003'
AND YEAR(TransDate) = 2012
AND MONTH(TransDate) = 1
ORDER BY YEAR(TransDate)
	  ,DATEPART(qq,TransDate)
	  ,MONTH(TransDate)
	  ,TransDate
      ,Symbol
      ,CustId
GO

/*********************************************************/
/* Listing 5.13 – Suggested Index for GROUPING() Example */
/*********************************************************/

DROP INDEX IF EXISTS [ieTranSymCustBuySell]
ON [Financial].[Transaction]
GO

CREATE NONCLUSTERED INDEX [ieTranSymCustBuySell]
ON [Financial].[Transaction] ([Symbol],[CustId],[BuySell])
INCLUDE ([TransDate],[TransAmount])
GO

/****************/
/* STRING_AGG() */
/****************/

/*************************************************/
/* Listing 5.14 – Assemble 24 Hour Ticker Prices */
/*************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SELECT TOP 1000 STRING_AGG('msg start->ticker:' + Ticker 
	+ ',company:' + Company 
	+ ',trade date:' + convert(VARCHAR, TickerDate) 
	+ ',hour:' + convert(VARCHAR, QuoteHour) 
	+ ',price:' + convert(VARCHAR, Quote) + '<-msg stop', '!') + CHAR(10)
FROM MasterData.TickerHistory
WHERE TickerDate = '2015-01-01'
AND Company = 'Banco Santander Brasil'
GROUP BY QuoteHour 
ORDER BY QuoteHour 
GO

/*
(No column name)
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:1,price:109.20<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:2,price:123.20<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:3,price:120.10<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:4,price:110.70<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:5,price:112.30<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:6,price:107.30<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:7,price:110.10<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:8,price:113.40<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:9,price:123.10<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:10,price:124.60<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:11,price:120.80<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:12,price:100.50<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:13,price:114.50<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:14,price:105.70<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:15,price:116.50<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:16,price:120.40<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:17,price:118.90<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:18,price:121.00<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:19,price:102.80<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:20,price:116.70<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:21,price:106.60<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:22,price:115.60<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:23,price:120.70<-msg stop 
msg start->ticker:BSBR,company:Banco Santander Brasil,trade date:2015-01-01,hour:24,price:124.10<-msg stop 
*/



-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

/**********************/
/* STDEV() & STDEVP() */
/**********************/

/********************************************************/
/* Listing 5.15 – Portfolio Standard Deviation Analysis */
/********************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

WITH PortfolioAnalysis (
TradeYear,TradeQtr,TradeMonth,CustId,PortfolioNo,Portfolio,MonthlyValue
)
AS (
SELECT Year					  AS TradeYear
	  ,DATEPART(qq,SweepDate) AS TradeQtr
      ,Month				  AS TradeMonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value)			  AS MonthlyValue
FROM Financial.Portfolio
WHERE Year > 2011
GROUP BY CustId
	  ,PortfolioNo
	  ,Year
      ,Month
	  ,SweepDate
      ,Portfolio
)
SELECT TradeYear
	,TradeQtr
	,TradeMonth
	,CustId
	,PortfolioNo
	,Portfolio
	,MonthlyValue
	,SUM(MonthlyValue) OVER(
	PARTITION BY Portfolio
	ORDER BY Portfolio,TradeMonth
	) AS RollingMonthlyValue
	,STDEV(MonthlyValue) OVER(
	PARTITION BY Portfolio
	ORDER BY Portfolio,TradeMonth
	) AS RollingMonthlyStdev
	,STDEVP(MonthlyValue) OVER(
	PARTITION BY Portfolio
	ORDER BY Portfolio,TradeMonth
	) AS RollingMonthlyStdevp
FROM PortfolioAnalysis
WHERE TradeYear = 2012
AND CustId = 'C0000001'
AND Portfolio = 'CASH - FINANCIAL PORTFOLIO'
/* or try this out

WHERE TradeYear IN(2012,2013)
AND CustId = 'C0000001'
AND Portfolio IN (
	'CASH - FINANCIAL PORTFOLIO',
	'EQUITY - FINANCIAL PORTFOLIO'
	)
*/
ORDER BY CustId,Portfolio,TradeYear,TradeQtr,TradeMonth
GO
 
-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/********************************************************************************/ 
/* Try removing the WHERE clause and look at the estimated query plan node tips */
/* and also the PROFILE statistics                                              */
/********************************************************************************/ 

SET STATISTICS PROFILE ON
GO

WITH PortfolioAnalysis (
TradeYear,TradeQtr,TradeMonth,CustId,PortfolioNo,Portfolio,MonthlyValue
)
AS (
SELECT Year					  AS TradeYear
	  ,DATEPART(qq,SweepDate) AS TradeQtr
      ,Month				  AS TradeMonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value)			  AS MonthlyValue
FROM Financial.Portfolio
WHERE Year > 2011
GROUP BY CustId
	  ,PortfolioNo
	  ,Year
      ,Month
	  ,SweepDate
      ,Portfolio
)

SELECT TradeYear
	,TradeQtr
	,TradeMonth
	,CustId
	,PortfolioNo
	,Portfolio
	,MonthlyValue
	,SUM(MonthlyValue) OVER(
	PARTITION BY CustId, TradeYear,Portfolio
	ORDER BY CustId, TradeYear,Portfolio,TradeMonth
	) AS RollingMonthlyValue
	,STDEV(MonthlyValue) OVER(
	PARTITION BY CustId, TradeYear,Portfolio
	ORDER BY CustId, TradeYear,Portfolio,TradeMonth
	) AS RollingMonthlyStdev
	,STDEVP(MonthlyValue) OVER(
	PARTITION BY CustId, TradeYear,Portfolio
	ORDER BY CustId, TradeYear,Portfolio,TradeMonth
	) AS RollingMonthlyStdevp
FROM PortfolioAnalysis
ORDER BY CustId,Portfolio,TradeYear,TradeQtr,TradeMonth
GO

/******************************************/
/* USE FOR GENERATING NORMAL DISTRIBUTION */
/******************************************/

/*****************************************/
/* Listing 5.16 – Setting Up the Example */
/*****************************************/

DECLARE @TradeYearStdev TABLE (
	TradeYear		SMALLINT NOT NULL,
	TradeQuarter	SMALLINT NOT NULL,
	TradeMonth		SMALLINT NOT NULL,
	CustId			VARCHAR(32) NOT NULL,
	PortfolioNo		VARCHAR(32) NOT NULL,
	Portfolio		VARCHAR(64) NOT NULL, 
	MonthlyValue	DECIMAL(10,2) NOT NULL
	);

INSERT INTO @TradeYearStdev VALUES
('2012','1','1','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','13862.80'),
('2012','1','2','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','14629.50'),
('2012','1','3','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','15568.90'),
('2012','2','4','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','17004.80'),
('2012','2','5','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','18064.90'),
('2012','2','6','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','18500.30'),
('2012','3','7','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','17515.00'),
('2012','3','8','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','16779.50'),
('2012','3','9','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','15576.00'),
('2012','4','10','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','15941.60'),
('2012','4','11','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','14208.80'),
('2012','4','12','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','13804.30');

SELECT TradeYear
	,TradeQuarter
	,TradeMonth
	,CustId
	,PortfolioNo
	,Portfolio
	,MonthlyValue
	,AVG(MonthlyValue) OVER(
	) AS PortfolioAvg
	,STDEVP(MonthlyValue) OVER(
	) AS PortfolioStdevp
FROM @TradeYearStdev
ORDER BY CustId
	,TradeYear
	,TradeMonth
	,PortfolioNo
GO

/******************/
/* VAR() & VARP() */
/******************/

/*****************************************/
/* Listing 5.17 – Setting up the Example */
/*****************************************/

DECLARE @TradeYearStdev TABLE (
	TradeYear		SMALLINT NOT NULL,
	TradeQuarter	SMALLINT NOT NULL,
	TradeMonth		SMALLINT NOT NULL,
	CustId			VARCHAR(32) NOT NULL,
	PortfolioNo		VARCHAR(32) NOT NULL,
	Portfolio		VARCHAR(64) NOT NULL, 
	MonthlyValue	DECIMAL(10,2) NOT NULL
	);

INSERT INTO @TradeYearStdev VALUES
('2012','1','1','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','13862.80'),
('2012','1','2','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','14629.50'),
('2012','1','3','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','15568.90'),
('2012','2','4','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','17004.80'),
('2012','2','5','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','18064.90'),
('2012','2','6','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','18500.30'),
('2012','3','7','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','17515.00'),
('2012','3','8','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','16779.50'),
('2012','3','9','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','15576.00'),
('2012','4','10','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','15941.60'),
('2012','4','11','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','14208.80'),
('2012','4','12','C0000001','P01C1','COMMODITY - FINANCIAL PORTFOLIO','13804.30');

SELECT TradeYear
	,TradeQuarter
	,TradeMonth
	,CustId
	,PortfolioNo
	,Portfolio
	,MonthlyValue
	-- generate values when there are 3 rows of values
	,CASE	
		WHEN TradeMonth % 3 = 0 THEN
			VAR(MonthlyValue) OVER(
				PARTITION BY TradeQuarter
				ORDER BY TradeMonth
				ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
			) 
		ELSE 0 
		END AS PortfolioquarterlyVar
	,CASE	
		WHEN TradeMonth % 3 = 0 THEN
			VARP(MonthlyValue) OVER(
				PARTITION BY TradeQuarter
				ORDER BY TradeMonth
				ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
			) 
		ELSE 0 
		END AS PortfolioquarterlyVarp
FROM @TradeYearStdev
ORDER BY CustId
	,TradeYear
	,TradeMonth
	,PortfolioNo
GO

/*******************/
/* MIN/MAX BY WEEK */
/*******************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SELECT QuoteYear
	,QuoteQtr
	,QuoteMonth
	,QuoteWeek
	,Ticker
	,Company
	,TickerDate
	,[Low]
	,[High]
	,MIN([Low]) OVER(
		PARTITION BY QuoteYear,QuoteQtr,QuoteMonth,[QuoteWeek],[Ticker]
		ORDER BY [Low]
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS MinLow
	,MAX([Low]) OVER(
		PARTITION BY QuoteYear,QuoteQtr,QuoteMonth,[QuoteWeek],[Ticker]
		ORDER BY [Low]
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS MaxLow
	,MIN([High]) OVER(
		PARTITION BY QuoteYear,QuoteQtr,QuoteMonth,[QuoteWeek],[Ticker]
		ORDER BY [High]
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS MinHigh
	,MAX([High]) OVER(
		PARTITION BY QuoteYear,QuoteQtr,QuoteMonth,[QuoteWeek],[Ticker]
		ORDER BY [High]
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS MaxHigh
FROM [MasterData].[TickerPriceRangeHistoryDetail]
WHERE Ticker = 'AA'
AND QuoteYear = 2012
ORDER BY Ticker
	,QuoteYear
	,QuoteQtr
	,QuoteMonth
	,QuoteWeek
	,Company
	,TickerDate
GO

/***************************/
/* QUOTE STDEVP() & VARP() */
/***************************/

SELECT TOP (24) [Ticker]
      ,[Company]
      ,[TickerDate]
      ,[QuoteHour]
      ,[Quote]
	  ,STDEVP(Quote) OVER(
		PARTITION BY TickerDate
		ORDER BY QuoteHour
	) AS TickerSTDEVP
	  ,VARP(Quote) OVER(
		PARTITION BY TickerDate
		ORDER BY QuoteHour
	) AS TickerVARP
FROM[MasterData].[TickerHistory]
GO

/************************************************/
/* Listing 5.18 – Create Account Forecast Table */
/************************************************/

DROP TABLE IF EXISTS [Financial].[AccountVersusTarget]
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

/*****************************************/
/* Actual versus Target Account Analysis */
/*****************************************/

TRUNCATE TABLE [Financial].[AccountVersusTarget]	
GO

INSERT INTO [Financial].[AccountVersusTarget]	
SELECT [CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctTypeCode]
      ,[AcctBalance]
      ,[PostDate]
	  ,CASE
		WHEN [AcctBalance] < 0 THEN (ABS([AcctBalance]) * 1.05)
		WHEN [AcctBalance] BETWEEN 500 AND 1000 THEN [AcctBalance] * 1.25
		WHEN [AcctBalance] BETWEEN 1001 AND 2000 THEN [AcctBalance] * 1.20
		WHEN [AcctBalance] BETWEEN 2001 AND 3000 THEN [AcctBalance] * 1.15
		WHEN [AcctBalance] BETWEEN 3001 AND 4000 THEN [AcctBalance] * 1.10
		ELSE [AcctBalance] * .90
		END AS TargetBalance,

		(
		CASE
		WHEN [AcctBalance] < 0 THEN  (ABS([AcctBalance]) * 1.05)
		WHEN [AcctBalance] BETWEEN 500 AND 1000 THEN [AcctBalance] * 1.25
		WHEN [AcctBalance] BETWEEN 1001 AND 2000 THEN [AcctBalance] * 1.20
		WHEN [AcctBalance] BETWEEN 2001 AND 3000 THEN [AcctBalance] * 1.15
		WHEN [AcctBalance] BETWEEN 3001 AND 4000 THEN [AcctBalance] * 1.10
		ELSE [AcctBalance] * .90
		END
		) - [AcctBalance] AS Delta
FROM [Financial].[Account]
GO

/***************************************************************/
/* Listing 5.19 – Actual Versus Forecast Account Balance Query */
/***************************************************************/

SELECT [CustId] 
	,YEAR([PostDate]) AS PostYear
	,MONTH([PostDate]) AS PostMonth
	,[PostDate] 
	,[PrtfNo] 
	,[AcctNo] 
	,[AcctName] 
	,[AcctTypeCode] 
	,[AcctBalance] 
	,[TargetBalance] 
	,[Delta]
FROM [Financial].[AccountVersusTarget]
WHERE [CustId] = 'C0000001'
AND [PrtfNo] = 'P01C1'
AND [AcctName] = 'EQUITY'
AND YEAR([PostDate]) = '2012'
AND MONTH([PostDate]) = 1
GO

/****************************************/
/* Listing 5.20 – More Nice Bell Curves */
/****************************************/

-- pop results in an Excel spreadsheet
-- generate bell curve graph by calculating normal distributions

SELECT [Ticker]
      ,[Company]
      ,[TickerDate]
      ,[QuoteHour]
      ,[Quote]
	  ,AVG(Quote) OVER(
		) AS AvgQuote
	  ,STDEVP(Quote) OVER(
	) AS TickerSTDEVP
	  ,VARP(Quote) OVER(
	) AS TickerVARP
FROM [MasterData].[TickerHistory]
WHERE TickerDate = '2015-01-05'
ANd Company = 'Cocoa'
ORDER BY QuoteHour
GO

SELECT DISTINCT * 
FROM [dbo].[CheckTableRowCount]
GO

