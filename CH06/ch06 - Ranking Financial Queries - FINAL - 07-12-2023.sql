/*****************************************/
/* Chapter 6 - Finance Database Use Case */
/* Ranking/Window Functions              */
/* Created: 08/19/2022                   */
/* Modified: 05/31/2023                  */
/*****************************************/

-- in these examples:
	-- assume monthly value is what is left in the account at the end of the month
	-- assume rolling monthly value adds current month ( after all the pluses and 
	-- minuses) value plus last months value
	-- so this represent the total value to the current month

-- same applies to portfolio balances

-- in real life an account may have $100 in January
-- and $50 dollars in February
-- thats because $50 were debited from the account in February
-- so all that is left over is $50 (current month to date)

USE [APFinance]
GO

/******************/
/* RANK FUNCTIONS */
/******************/

/**********/
/* RANK() */
/**********/

/*************/
/* EXAMPLE 1 */
/*************/

/*************************************************/
/* listing 6.1 - Ranking Customer Cash Portfolio */
/*************************************************/

-- returns number of rows before current rows + current row

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

WITH PortfolioAnalysis (
TradeYear,CustId,PortfolioNo,Portfolio,YearlyValue
)
AS (
SELECT Year AS TradeYear
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value) AS YearlyValue
FROM Financial.Portfolio
--WHERE Year > 2011
GROUP BY CustId,Year,PortfolioNo
      ,Portfolio
--ORDER BYCustId,Year,PortfolioNo
--      ,Portfolio
)

SELECT TradeYear,
	CustId,
	PortfolioNo,
	Portfolio,
	YearlyValue,
	RANK() OVER(
	PARTITION BY Portfolio,TradeYear
	ORDER BY YearlyValue DESC
	) AS PortfolioRankByYear
FROM PortfolioAnalysis
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
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

/********************************************************/
/* Listing 6.2 – Customer C0000002 2012 Monthly Balance */
/********************************************************/

SELECT Year AS TradeYear
	,CASE	
		WHEN [Month] = 1 THEN 'Jan' 
		WHEN [Month] = 2 THEN 'Feb'
		WHEN [Month] = 3 THEN 'Mar'
		WHEN [Month] = 4 THEN 'Apr'
		WHEN [Month] = 5 THEN 'May'
		WHEN [Month] = 6 THEN 'Jun'
		WHEN [Month] = 7 THEN 'Jul'
		WHEN [Month] = 8 THEN 'Aug'
		WHEN [Month] = 9 THEN 'Sep'
		WHEN [Month] = 10THEN 'Oct'
		WHEN [Month] = 11 THEN 'Nov'
		WHEN [Month] = 12 THEN 'Dec'
	END AS Trademonth
   ,CustId
   ,PortfolioNo
   ,Portfolio
   ,SUM(Value) AS YearlyValue
   ,RANK() OVER(
		ORDER BY SUM(Value) DESC
	) AS PortfolioRankByMonth
FROM Financial.Portfolio
WHERE Portfolio = 'FX - FINANCIAL PORTFOLIO'
AND CustId = 'C0000001'
AND Year = 2012
GROUP BY CustId,Year,Month,PortfolioNo,Portfolio
ORDER BY SUM(Value) DESC
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/***************************************************/
/* listing 6.3 - Loading the Portfolio Sweep Table */
/***************************************************/

DROP TABLE IF EXISTS [Financial].[DailyPortfolioAnalysis]
GO

CREATE TABLE [Financial].[DailyPortfolioAnalysis](
	[TradeYear] [int] NOT NULL,
	[CustId] [varchar](8) NOT NULL,
	[PortfolioNo] [varchar](8) NOT NULL,
	[Portfolio] [varchar](278) NOT NULL,
	[YearlyValue] [decimal](10, 2) NULL
) ON [AP_FINANCE_FG]
GO

-- NO NEED TO TRUNCATE TABLE AFTER YOU FIRST CREATED IT
-- THE COMMAND IS HERE FOR WHEN YOU DO YOUR TESTING AND
-- MIGHT NEED TO TRUNCATE AND RELOAD

TRUNCATE TABLE Financial.DailyPortfolioAnalysis
GO

INSERT INTO Financial.DailyPortfolioAnalysis
SELECT Year AS TradeYear
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value) AS YearlyValue
FROM Financial.Portfolio
GROUP BY CustId,Year,PortfolioNo
      ,Portfolio
ORDER BY Portfolio ASC,Year ASC, SUM(Value) DESC
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

SELECT TradeYear,
	CustId,
	PortfolioNo,
	Portfolio,
	YearlyValue,
	RANK() OVER(
	PARTITION BY Portfolio,TradeYear
	ORDER BY YearlyValue DESC
	) AS PortfolioRankByYear
FROM Financial.DailyPortfolioAnalysis
WHERE TradeYear > 2011
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/**************************************/
/* listing 6.4 - FX Account Deep Dive */
/**************************************/

-- turn set statistics io/time/profile on

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

SELECT Year     AS TradeYear
	,Month      AS Trademonth
    ,CustId
    ,PortfolioNo
    ,Portfolio
    ,SUM(Value) AS YearlyValue
FROM Financial.Portfolio
WHERE Portfolio = 'FX - FINANCIAL PORTFOLIO'
AND CustId = 'C0000001'
AND Year = 2012
GROUP BY CustId,Year,Month,PortfolioNo,Portfolio
ORDER BY Month
GO

/**********************/
/* compare cash to FX */
/**********************/

SELECT Year     AS TradeYear
	,Month      AS Trademonth
    ,CustId
    ,PortfolioNo,PortfolioAccountTypeCode
    ,Portfolio
    ,SUM(Value) AS YearlyValue
FROM Financial.Portfolio
WHERE Portfolio IN('FX - FINANCIAL PORTFOLIO','CASH - FINANCIAL PORTFOLIO')
AND CustId = 'C0000001'
AND Year = 2012
GROUP BY CustId,Year,Month,PortfolioNo,PortfolioAccountTypeCode
      ,Portfolio
ORDER BY Month,Portfolio
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/********************************************************/
/* Listing 6.5 – 2012 Portfolio Value Pivot Table Query */
/********************************************************/

-- turn set statistics io/time/profile on

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

SELECT [Year] AS TradeYear
	,CASE	
		WHEN [Month] = 1 THEN 'Jan' 
		WHEN [Month] = 2 THEN 'Feb'
		WHEN [Month] = 3 THEN 'Mar'
		WHEN [Month] = 4 THEN 'Apr'
		WHEN [Month] = 5 THEN 'May'
		WHEN [Month] = 6 THEN 'Jun'
		WHEN [Month] = 7 THEN 'Jul'
		WHEN [Month] = 8 THEN 'Aug'
		WHEN [Month] = 9 THEN 'Sep'
		WHEN [Month] = 10THEN 'Oct'
		WHEN [Month] = 11 THEN 'Nov'
		WHEN [Month] = 12 THEN 'Dec'
	END AS Trademonth
   ,CustId
   ,PortfolioNo
   ,Portfolio
   ,SUM(Value) AS [MonthTotal]
FROM Financial.Portfolio
WHERE CustId = 'C0000001'
AND Year = 2012
GROUP BY Year,Month,Custid,PortfolioNo,Portfolio
ORDER BY Custid,Year,Month,PortfolioNo,Portfolio
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/***********************************************/
/* Listing 6.6 – Detailed Transaction Analysis */
/***********************************************/

-- turn set statistics io/time/profile on

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

SELECT YEAR(T.[TransDate]) AS TransYear
	,CASE	
		WHEN MONTH(T.[TransDate]) = 1 THEN 'Jan' 
		WHEN MONTH(T.[TransDate]) = 2 THEN 'Feb'
		WHEN MONTH(T.[TransDate]) = 3 THEN 'Mar'
		WHEN MONTH(T.[TransDate]) = 4 THEN 'Apr'
		WHEN MONTH(T.[TransDate]) = 5 THEN 'May'
		WHEN MONTH(T.[TransDate]) = 6 THEN 'Jun'
		WHEN MONTH(T.[TransDate]) = 7 THEN 'Jul'
		WHEN MONTH(T.[TransDate]) = 8 THEN 'Aug'
		WHEN MONTH(T.[TransDate]) = 9 THEN 'Sep'
		WHEN MONTH(T.[TransDate]) = 10THEN 'Oct'
		WHEN MONTH(T.[TransDate]) = 11 THEN 'Nov'
		WHEN MONTH(T.[TransDate]) = 12 THEN 'Dec'
	END AS Trademonth
	,T.[TransDate]
    ,T.[Symbol]
    ,T.[Price]
    ,T.[Quantity]
    ,T.[TransAmount]
    ,T.[CustId]
    ,T.[PortfolioNo]
	,PAT.PortfolioAccountTypeCode
    ,PAT.PortfolioAccountTypeName
    ,T.[AcctNo]
    ,T.[BuySell]
  FROM [APFinance].[Financial].[Transaction] T
  JOIN [MasterData].[PortfolioAccountType] PAT
  ON T.PortfolioAccountTypeCode = PAT.PortfolioAccountTypeCode
  WHERE YEAR(T.TransDate) = 2012
  AND T.CustId = 'C0000001'
  GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/******************************************************/
/* listing 6.7 - Estimated Query Plan Suggested Index */
/******************************************************/

/*
Missing Index Details from ch06 - Ranking Financial Queries - V3.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance (DESKTOP-CEBK38L\Angelo (57))
The Query Processor estimates that implementing the following index could improve the query cost by 67.1517%.
*/

/*
USE [APFinance]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Financial].[Transaction] ([CustId])
INCLUDE ([TransDate],[Symbol],[Price],[Quantity],[TransAmount],[PortfolioNo],[PortfolioAccountTypeCode],[AcctNo],[BuySell])
GO
*/

DROP INDEX IF EXISTS [ieCustIdDateSumbolPortfolioAcct]
ON [Financial].[Transaction]
GO

CREATE NONCLUSTERED INDEX [ieCustIdDateSumbolPortfolioAcct]
ON [Financial].[Transaction] ([CustId])
INCLUDE ([TransDate],[Symbol],[Price],[Quantity],[TransAmount],[PortfolioNo],[PortfolioAccountTypeCode],[AcctNo],[BuySell])
GO


/****************/
/* DENSE_RANK() */
/****************/

/******************/
/* REVIEW EXAMPLE */
/******************/

/**************************************************/
/* Listing 6.8 Portfolio analysis with Dense Rank */
/**************************************************/

/*************/
/* EXAMPLE 1 */
/*************/

-- returns number of rows before current rows + current row with no gaps

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

WITH PortfolioAnalysis (
TradeYear,CustId,PortfolioNo,Portfolio,YearlyValue
)
AS (
SELECT [Year] AS TradeYear
      ,CustId
      ,PortfolioNo
      ,Portfolio
	  -- introduce artifical duplicate value
	  -- to see how rank vs dense_rank behave
      ,CASE
		WHEN Portfolio = 'CASH - FINANCIAL PORTFOLIO'
			AND [Year] = 2012 THEN 33894.20
			ELSE SUM(Value) 
	END AS YearlyValue 
FROM Financial.Portfolio
WHERE Year > 2011
GROUP BY CustId,Year,PortfolioNo
      ,Portfolio
)

SELECT TradeYear,
	CustId,
	PortfolioNo,
	Portfolio,
	YearlyValue,
	RANK() OVER(
	ORDER BY YearlyValue DESC
	) AS PortfolioRank,
	DENSE_RANK() OVER(
	ORDER BY YearlyValue DESC
	) AS PortfolioDenseRank
FROM PortfolioAnalysis
WHERE Portfolio = 'CASH - FINANCIAL PORTFOLIO'
GO
-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/*************/
/* EXAMPLE 2 */
/*************/

DECLARE @RankExample TABLE (
	NumValue INT
	);

INSERT INTO @RankExample 
VALUES(10),(20),(25),(27),(30),(30),(30),(30),(30),(30),(30),(40),(50),(60),(70),(80),(90),(100);

SELECT NumValue 
	,RANK() OVER (ORDER BY NumValue) AS [Rank]
	,DENSE_RANK() OVER (ORDER BY NumValue) As DenseRank
FROM @RankExample;
GO

/*********************************/
/* Listing 6.9 - suggested index */
/*********************************/

/*
Missing Index Details from ch06 - Ranking Financial Queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance (DESKTOP-CEBK38L\Angelo (70))
The Query Processor estimates that implementing the following index could improve the query cost by 69.9728%.
*/

/*
USE [APFinance]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Financial].[Portfolio] ([Portfolio],[Year])
INCLUDE ([CustId],[PortfolioNo],[Value])
GO
*/

DROP INDEX IF EXISTS [ieCustIdPortfolioNoValue]
ON [Financial].[Portfolio] 
GO

CREATE NONCLUSTERED INDEX [ieCustIdPortfolioNoValue]
ON [Financial].[Portfolio] ([Portfolio],[Year])
INCLUDE ([CustId],[PortfolioNo],[Value])
GO

/************************************/
/* Top 20 performing ticker symbols */
/************************************/

/***************************************************/
/* listing 6.10 - Top 20 Performing Ticker Symbols */
/***************************************************/

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

-- 54057 rows in [APFinance].[MasterData].[TickerPriceRangeHistoryDetail]

SELECT TOP 20 [QuoteYear]
      ,[Ticker]
      ,[Company]
      ,MIN([Low]) AS MinLow
      ,MAX([High]) AS MaxHigh
      ,MAX([High]) - MIN([Low]) AS MaxSpread
	  ,RANK() OVER(
			ORDER BY MAX([High]) DESC
		) AS PerformanceRank
	  ,DENSE_RANK() OVER(
			ORDER BY MAX([High]) DESC
		) AS PerformanceDenseRank
FROM [APFinance].[MasterData].[TickerPriceRangeHistoryDetail]
WHERE [QuoteYear] = 2015
GROUP BY[QuoteYear]
      ,[Ticker]
      ,[Company]
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/**********************************/
/* listing 6.11 - suggested index */
/**********************************/

/*
Missing Index Details from ch06 - Ranking Financial Queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance (DESKTOP-CEBK38L\Angelo (70))
The Query Processor estimates that implementing the following index could improve the query cost by 54.8106%.
*/

/*
USE [APFinance]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [MasterData].[TickerPriceRangeHistoryDetail] ([QuoteYear])
INCLUDE ([Ticker],[Company],[Low],[High])
GO
*/

DROP INDEX IF EXISTS eTickerCompanyLowHigh
ON [MasterData].[TickerPriceRangeHistoryDetail]
GO

CREATE NONCLUSTERED INDEX [eTickerCompanyLowHigh]
ON [MasterData].[TickerPriceRangeHistoryDetail] ([QuoteYear])
INCLUDE ([Ticker],[Company],[Low],[High])
GO

/*
Before
Index Seek: 63%
Hash Match: 33%
Sort 4%
After
Index Seek: 28%
Hash Match: 63%
Sort 9%
*/ 

/***********/
/* NTILE() */
/***********/

/**************************************/
/* listing 6.12a - set up ticker data */
/**************************************/

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

DECLARE @TickerRating TABLE
(
Ticker VARCHAR(8) NOT NULL,
Rating VARCHAR(8) NOT NULL
);

INSERT INTO @TickerRating VALUES 
('AAA','A+'),
('AAB','A+'),
('AAC','A+'),
('AAD','A+'),

('BBB','A'),
('BBC','A'),
('BBD','A'),
('BBE','A'),

('CCC','B+'),
('CCD','B+'),
('CCE','B+'),
('CCE','B+'),

('DDD','B'),
('DDE','B'),
('DDF','B'),
('DDG','B'),

('ZZZ','JUNK'),
('ZZA','JUNK'),
('ZZB','JUNK'),
('ZZB','JUNK');

/*************************************************/
/* Listing 6.12b – Generate Recommendation Tiles */
/*************************************************/

DECLARE @RatingBuckets INT;

SELECT @RatingBuckets = COUNT(DISTINCT Rating)
FROM @TickerRating;

SELECT Ticker ,Rating,
CASE
	WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 1 THEN 'Highly Recommend'
	WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 2 THEN 'Recommend'
	WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 3 THEN 'Worth a shot'
	WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 4 THEN 'Are you feeling lucky?'
	WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 5 THEN 'Run away!'
END AS AnalystRecommends
FROM  @TickerRating;
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*************/
/* Example 2 */
/*************/

/*****************************************/
/* Rank investments within ntile buckets */
/*****************************************/

/********************************************/
/* figure 6.13 - rank values within buckets */
/********************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

;WITH SymbolCTE (TransYear,Symbol,SumTransactions,InvestmentBucket)
AS
(
SELECT YEAR([TransDate]) AS TransYear
	  ,[Symbol]
      ,SUM([TransAmount]) AS SumTransactions
	  ,NTILE(9) OVER (
	    PARTITION BY YEAR([TransDate])
		ORDER BY SUM([TransAmount]) DESC
		) AS InvestmentBucket
FROM [APFinance].[Financial].[Transaction]
WHERE BuySell = 'B'
GROUP BY YEAR([TransDate]),Symbol
)
 
SELECT TransYear,
	Symbol,
	SumTransactions,
	InvestmentBucket,
	RANK() OVER(
			PARTITION BY TransYear,InvestmentBucket
			ORDER BY InvestmentBucket,SumTransactions DESC 
		) AS InvestmentRank
FROM SymbolCTE
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

DROP INDEX IF EXISTS ieTransDateSymbolTransAmount
ON [Financial].[Transaction]
GO

CREATE NONCLUSTERED INDEX ieTransDateSymbolTransAmount
ON [Financial].[Transaction] ([BuySell])
INCLUDE ([TransDate],[Symbol],[TransAmount])
GO

/*************************/
/* Report Table Strategy */
/*************************/

TRUNCATE TABLE NtileSymbolBuckets
GO

INSERT INTO NtileSymbolBuckets
SELECT YEAR([TransDate]) AS TransYear
	  ,[Symbol]
      ,SUM([TransAmount]) AS SumTransactions
	  ,NTILE(9) OVER (
	    PARTITION BY YEAR([TransDate])
		ORDER BY SUM([TransAmount]) DESC
		) AS InvestmentBucket
FROM [APFinance].[Financial].[Transaction]
WHERE BuySell = 'B'
GROUP BY YEAR([TransDate]),Symbol
ORDER BY YEAR([TransDate]),Symbol
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

 SELECT TransYear,
	Symbol,
	SumTransactions,
	InvestmentBucket,
	RANK() OVER(
			PARTITION BY TransYear,InvestmentBucket
			ORDER BY InvestmentBucket,SumTransactions DESC 
		) AS InvestmentRank
FROM NtileSymbolBuckets
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/****************/
/* ROW_NUMBER() */
/****************/

/**************************************************************/
/* listing 6.14 - Assign Row Numbers & Rank to each Partition */
/**************************************************************/

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

WITH PortfolioAnalysis (
TradeYear,CustId,PortfolioNo,PortfolioAccountType,Portfolio,YearlyValue
)
AS (
SELECT Year AS TradeYear
      ,CustId
      ,PortfolioNo
	  ,PortfolioAccountTypeCode
      ,Portfolio
	  ,SUM(Value) AS YearlyValue

FROM Financial.Portfolio
WHERE Year > 2011
GROUP BY CustId,Year,PortfolioNo,PortfolioAccountTypeCode
      ,Portfolio,RollingBalance
--ORDER BYCustId,Year,PortfolioNo
--      ,Portfolio
)

SELECT TradeYear
	,CustId
	,PortfolioNo
	,PortfolioAccountType
	,Portfolio
	,YearlyValue
	,RANK() OVER(
	PARTITION BY CustId,TradeYear
		ORDER BY CustId,TradeYear,YearlyValue DESC
	) AS PortfolioRankByYear
	,ROW_NUMBER() OVER(
		PARTITION BY CustId,TradeYear
	ORDER BY CustId,TradeYear,YearlyValue DESC
	) AS PortfolioRowNumByYear
FROM PortfolioAnalysis
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/**********************************************************************************************/
/* USE THIS QUERY AND RUN A LIVE QUERY PLAN TO SEE THE TIME SPENT ON EACH TASK INCREMENT LIVE */
/**********************************************************************************************/

/***************************************************************/
/* Listing 6.15 – Query Example to Generate Dynamic Statistics */
/***************************************************************/

 SELECT TransYear,
	N.Symbol,
	SumTransactions,
	InvestmentBucket,
	RANK() OVER(
			PARTITION BY TransYear,InvestmentBucket
			ORDER BY InvestmentBucket,SumTransactions DESC 
		) AS InvestmentRank
FROM NtileSymbolBuckets N
CROSS JOIN [MasterData].[Calendar]
CROSS JOIN [Financial].[TickerSymbols]
GO

/*************/
/* EXAMPLE 2 */
/*************/

/*********************************/
/* Set up gaps and island report */
/*********************************/

/************************************************/
/* Listing 6.16 – Setup Data, Gaps, and islands */
/************************************************/

CREATE TABLE [Financial].[CustomerBuyTransaction](
	[TransDate]     [date] NOT NULL,
	[CustId]        [varchar](8) NOT NULL,
	[Symbol]        [varchar](64) NOT NULL,
	[TradeNo]       [smallint] NOT NULL,
	[TransAmount]   [decimal](10, 2) NOT NULL,
	[TransTypeCode] [varchar](8) NOT NULL
) ON [AP_FINANCE_FG]
GO

/********************************************************/
/* Listing 6.17 – Load Trades for Customer LIBOR Trades */
/********************************************************/

TRUNCATE TABLE Financial.CustomerBuyTransaction
GO

INSERT INTO Financial.CustomerBuyTransaction
SELECT
	CAL.[CalendarDate]
	,FT.CustId
	,FT.Symbol
	,ROW_NUMBER() OVER (
		PARTITION BY CAL.[CalendarDate],FT.CustId,FT.Symbol,FT.TransAmount,FT.TransTypeCode
		ORDER BY CAL.[CalendarDate],FT.CustId,FT.Symbol,FT.TransAmount,FT.TransTypeCode
		) AS TradeNo
	,FT.TransAmount
	,FT.TransTypeCode
FROM [MasterData].[Calendar] CAL
JOIN [Financial].[Transaction] FT
ON CAL.[CalendarDate] = FT.TransDate
WHERE [BuySell] = 'B'
ORDER BY CAL.[CalendarDate],FT.CustId,FT.Symbol
GO

INSERT INTO Financial.CustomerBuyTransaction
VALUES('2012-01-01','C0000001','AA',2,312.40,'TT00002')
GO

SELECT *
FROM [Financial].[CustomerBuyTransaction]
ORDER BY 1,2,3
GO

DELETE FROM Financial.CustomerBuyTransaction
WHERE TransAmount = 0
GO

/**************************/
/* Create some trade gaps */
/**************************/

/************************************************/
/* Listing 6.18 – Create Gaps in Trade Activity */
/************************************************/

-- use next query as a guide for the gaps
-- we need to create

DELETE FROM Financial.CustomerBuyTransaction
WHERE [TransDate] IN(
	SELECT [TransDate]
	FROM [Financial].[CustomerBuyTransaction]
	WHERE YEAR([TransDate]) = 2012
	AND DAY(TransDate) IN (1,14,15,16,28)
	UNION ALL
	SELECT [TransDate]
	FROM [Financial].[CustomerBuyTransaction]
	WHERE YEAR([TransDate]) = 2013
	AND DAY(TransDate) IN (5,17,22,23,24)
	UNION ALL
	SELECT [TransDate]
	FROM [Financial].[CustomerBuyTransaction]
	WHERE YEAR([TransDate]) = 2014
	AND DAY(TransDate) IN (9,19,25,26,27,28)
	UNION ALL
	SELECT [TransDate]
	FROM [Financial].[CustomerBuyTransaction]
	WHERE YEAR([TransDate]) = 2015
	AND DAY(TransDate) IN (2,8,11,17,23,24,25,26)
	)
	GO

-- need to insert these back in

INSERT INTO Financial.CustomerBuyTransaction
VALUES('2012-01-01','C0000005','AA',2,312.40,'TT00002')
GO

INSERT INTO Financial.CustomerBuyTransaction
VALUES('2012-01-01','C0000005','LIBOR OIS',1,2000.40,'TT00005')
GO

INSERT INTO Financial.CustomerBuyTransaction
VALUES('2012-01-01','C0000005','LIBOR OIS',2,1999.40,'TT00005')
GO

/**************************/
/* GAP OR ISLANDS PROBLEM */
/**************************/

/**************/
/* First Step */
/* Set up CTE */
/**************/

/*
retrieve next date with LEAD()
calculate number of lag dates - 1 
*/

/***************************************/
/* Listing 6.19 – Create the First CTE */
/***************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

DROP TABLE IF EXISTS [Financial].[CustomerBuyTransaction]
GO

WITH TradeGapsCTE(
	TransDate,NextTradeDate,GapTradeDays,CustId,Symbol,TransAmount,TransTypeCode
)
AS
(
SELECT
	FT.[TransDate] AS TradeDate
	,LEAD(FT.[TransDate]) OVER(ORDER BY FT.[TransDate]) AS NextTradeDate
	,CASE
		WHEN (DATEDIFF(dd,FT.[TransDate],LEAD(FT.[TransDate]) OVER(ORDER BY FT.[TransDate])) - 1) = -1
			THEN 0
		ELSE (DATEDIFF(dd,FT.[TransDate],LEAD(FT.[TransDate]) OVER(ORDER BY FT.[TransDate])) - 1)
	 END AS GapTradeDays
	,FT.CustId
	,FT.Symbol
	,FT.TransAmount
	,FT.TransTypeCode
FROM Financial.CustomerBuyTransaction FT
WHERE CustId = 'C0000005'
AND Symbol = 'LIBOR OIS'
AND YEAR(FT.TransDate) = 2012
-- debug, sort results and make sure
-- they are what you expect
--ORDER BY FT.TransDate
)
-- uncomment below to test CTE
--SELECT * FROM TradeGapsCTE
,

/***************/
/* Second Step */
/* label gaps  */
/***************/

/*********************************/
/* Listing 6.20 – Label the Gaps */
/*********************************/

/*
identify start of gap and island dates
*/

GapsAndIslands(
	TransDate,NextTradeDate,GapTradeDays,GapOrIsland,CustId
		,Symbol,TransAmount,TransTypeCode
)
AS (
SELECT TG.TransDate
	,TG.NextTradeDate
	,TG.GapTradeDays
	,CASE
		WHEN TG.GapTradeDays = 0 THEN 'ISLAND'
		ELSE 'GAP' + CONVERT(VARCHAR,ROW_NUMBER() OVER (ORDER BY YEAR(TG.TransDate)))
	END AS GapOrIsland
	,TG.CustId
	,TG.Symbol
	,TG.TransAmount
	,TG.TransTypeCode
FROM TradeGapsCTE TG
)
-- uncomment below to test CTE
-- SELECT * FROM GapsAndIslands
,

/**************/
/* Third Step */
/**************/

/*
identify start & stop dates of gaps
using MIN()/MAX(0 functions
*/

/**************************************************/
/* Listing 6.21 – Identify Gap Start & Stop Dates */
/**************************************************/

FinalGapIslanCTE (
	CustId,Symbol,GapTradeDays,GapOrIsland,GapStart,GapEnd
)
AS (
SELECT 	CustId
	,Symbol
	,GapTradeDays
	,GapOrIsland
	,MIN(TransDate) AS GapStart
	,MAX(NextTradeDate) AS GapEnd
FROM GapsAndIslands
WHERE NextTradeDate IS NOT NULL
AND GapTradeDays > 0
GROUP BY CustId
	,Symbol
	,GapTradeDays
	,GapOrIsland
)

-- uncomment below to test CTE
--SELECT * FROM FinalGapIslanCTE
--ORDER BY GapStart

/************* */
/* Fourth Step */
/***************/

/*
create final report that
displays list of gap days
*/

/**************************************/
/* Listing 6.22 – Assemble the Report */
/**************************************/

SELECT CustId,
	Symbol,
	GapTradeDays,
	GapStart,
	GapEnd,
	(
	SELECT STRING_AGG(CalendarDate,',')
	FROM [MasterData].[Calendar]
	WHERE CalendarDate BETWEEN DATEADD(dd,1,GapStart) AND DATEADD(dd,-1,GapEnd)
	) AS GapInTradeDays 
FROM FinalGapIslanCTE 
ORDER BY CustId,
	Symbol,
	GapStart
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO

/*
Missing Index Details from ch06 - Ranking Financial Queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance (DESKTOP-CEBK38L\Angelo (79))
The Query Processor estimates that implementing the following index could improve the query cost by 93.1833%.
*/

/*
USE [APFinance] 
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Financial].[CustomerBuyTransaction] ([CustId],[Symbol])
INCLUDE ([TransDate],[TransAmount],[TransTypeCode])
GO
*/

DROP INDEX IF EXISTS [CustIdSymbolTransDateTransAmountTransTypeCode]
ON [Financial].[CustomerBuyTransaction]
GO

CREATE NONCLUSTERED INDEX [CustIdSymbolTransDateTransAmountTransTypeCode]
ON [Financial].[CustomerBuyTransaction] ([CustId],[Symbol])
INCLUDE ([TransDate],[TransAmount],[TransTypeCode])
GO

/*****************/
/* ISLAND REPORT */
/*****************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO

DROP TABLE IF EXISTS [Financial].[CustomerBuyTransaction]
GO

/**************************************/
/* Listing 6.23 – Create Island CTE 1 */
/**************************************/

WITH TradeGapsCTE(
	TransDate,NextTradeDate,GapTradeDays,CustId,Symbol,TransAmount,TransTypeCode
)
AS
(
SELECT
	FT.[TransDate] AS TradeDate
	,LEAD(FT.[TransDate]) OVER(ORDER BY FT.[TransDate]) AS NextTradeDate
	,CASE 
		WHEN LEAD(FT.[TransDate]) OVER(ORDER BY FT.[TransDate]) = FT.TransDate
			THEN 0
		ELSE DATEDIFF(dd,FT.[TransDate],LEAD(FT.[TransDate]) OVER(ORDER BY FT.[TransDate])) - 1
	END AS GapTradeDays
	,FT.CustId
	,FT.Symbol
	,FT.TransAmount
	,FT.TransTypeCode
FROM Financial.CustomerBuyTransaction FT
WHERE CustId = 'C0000005'
AND Symbol = 'LIBOR OIS'
AND YEAR(FT.TransDate) = 2012
--ORDER BY FT.TransDate
)
-- uncomment below to test CTE
--SELECT * FROM TradeGapsCTE
,

/*********************************************************/
/* Listing 6.24 – Create 2nd CTE, Label Islands and Gaps */
/*********************************************************/

/****************/
/* Second Step  */
/* label gaps & */
/* islands      */
/****************/

/*
identify start of gap and island dates
*/

GapsAndIslands(
	TransDate,NextTradeDate,GapTradeDays,GapOrIsland,
	CustId,Symbol,TransAmount,TransTypeCode
)
AS (
SELECT TG.TransDate
	,CASE	
		WHEN TG.NextTradeDate IS NULL THEN DATEADD(dd,1,TG.TransDate)
		ELSE TG.NextTradeDate 
	 END AS NextTradeDate 
	,CASE	
		WHEN TG.GapTradeDays IS NULL THEN 0
		ELSE TG.GapTradeDays
	 END AS GapTradeDays
	,CASE
		WHEN DATEDIFF(dd,TransDate,NextTradeDate) = 0 
			THEN 'ISLAND' + CONVERT(VARCHAR,(DAY(TG.NextTradeDate) - ROW_NUMBER() OVER (ORDER BY YEAR(TG.TransDate))))
		WHEN DATEDIFF(dd,TransDate,NextTradeDate) = 1 
			THEN 'ISLAND' +  CONVERT(VARCHAR,(DAY(TG.NextTradeDate) - ROW_NUMBER() OVER (ORDER BY YEAR(TG.TransDate))))
		WHEN NextTradeDate IS NULL
			THEN 'ISLAND' +  CONVERT(VARCHAR,(ROW_NUMBER() OVER (ORDER BY YEAR(TG.TransDate))))
		ELSE 'GAP' + CONVERT(VARCHAR,ABS(DAY(TG.NextTradeDate) - ROW_NUMBER() OVER (ORDER BY YEAR(TG.TransDate))))
	END AS GapOrIsland
	,TG.CustId
	,TG.Symbol
	,TG.TransAmount
	,TG.TransTypeCode
FROM TradeGapsCTE TG
)

-- uncomment below to test CTE
--SELECT TransDate,NextTradeDate,GapTradeDays,GapOrIsland,CustId,Symbol,TransAmount,TransTypeCode
--FROM GapsAndIslands
--ORDER BY 1
,

/**************/
/* Third Step */
/**************/

/*
identify start & stop dates of islands
using MIN()/MAX() functions
*/

/**********************************************************************/
/* Listing 6.25 – Identifying Start and End date for Gaps and Islands */
/**********************************************************************/

FinalGapIslandCTE (
	CustId,Symbol,GapTradeDays,GapOrIsland,GapIslandStart,GapIslandEnd
)
AS (
SELECT CustId
	,Symbol
	,GapTradeDays
	,GapOrIsland
	,MIN(TransDate) AS GapIslandStart
	,MAX(NextTradeDate) AS GapIslandEnd
FROM GapsAndIslands
GROUP BY CustId
	,Symbol
	,GapTradeDays
	,GapOrIsland
)

-- uncomment below to test CTE
--SELECT * FROM FinalGapIslandCTE
--ORDER BY CustId,GapIslandStart
--GO

/************* */
/* Fourth Step */
/***************/

/**************************************************/
/* Listing 6.26 – The Final Gap and Island Report */
/**************************************************/

/*
create final report that
displays list of island & gap days
*/

SELECT CustId,
	Symbol,

	CASE 
		WHEN GapOrIsland LIKE 'ISLAND%' THEN DATEDIFF(dd,GapIslandStart,GapIslandEnd) + 1
		ELSE GapTradeDays
	END AS TradeDays,
	GapOrIsland,
	GapIslandStart AS GapOrIslandStart,
	GapIslandEnd AS GapOrIslandEnd,
	CASE
		WHEN GapOrIsland LIKE 'GAP%' THEN
		(
			SELECT STRING_AGG(CalendarDate,',')
			FROM [MasterData].[Calendar]
			WHERE CalendarDate BETWEEN DATEADD(dd,1,GapIslandStart) AND DATEADD(dd,-1,GapIslandEnd)
		) 
		ELSE (
			SELECT STRING_AGG(CalendarDate,',')
			FROM [MasterData].[Calendar]
			WHERE CalendarDate BETWEEN GapIslandStart AND GapIslandEnd
		) 
		END AS GapOrIslandTradeDays 
FROM FinalGapIslandCTE 
ORDER BY CustId,
	Symbol,
	GapIslandStart
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO
