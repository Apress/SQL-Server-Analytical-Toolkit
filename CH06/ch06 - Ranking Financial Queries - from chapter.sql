USE [APFinance]
GO

-- Listing 6.1 – Ranking Customer Cash Portfolio
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
WHERE Year > 2011
GROUP BY CustId,Year,PortfolioNo
      ,Portfolio
)

SELECT TradeYear
	,CustId
	,PortfolioNo
	,Portfolio
	,YearlyValue
	,RANK() OVER(
		PARTITION BY Portfolio,TradeYear
		ORDER BY YearlyValue DESC
	) AS PortfolioRankByYear
FROM PortfolioAnalysis
GO
-- Listing 6.2 – Customer C0000002 2012 Monthly Balance
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
GROUP BY CustId,Year,Month,PortfolioNo
      ,Portfolio
ORDER BY SUM(Value) DESC
GO
-- Listing 6.3 – Loading the Portfolio Sweep Table
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

-- Listing 6.4 – FX Account Deep Dive Analysis
SELECT Year       AS TradeYear
	,Month      AS Trademonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value) AS YearlyValue
FROM Financial.Portfolio
WHERE Portfolio = 'FX - FINANCIAL PORTFOLIO'
AND CustId = 'C0000001'
AND Year = 2012
GROUP BY CustId,Year,Month,PortfolioNo
      ,Portfolio
ORDER BY Month
GO
-- Listing 6.5 – 2012 Portfolio Value Pivot Table Query
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
-- Listing 6.6 – Detailed Transaction Analysis
SELECT MONTH(T.[TransDate]) AS TransMonth
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
-- Listing 6.7 – Estimated Query Plan Suggested Index
CREATE NONCLUSTERED INDEX [iePortfolioAnalysisC0000001]
ON [Financial].[Transaction] ([CustId])
INCLUDE (
[TransDate],[Symbol],[Price],[Quantity],[TransAmount],
[PortfolioNo],[AcctNo],[BuySell]
)
GO
-- Listing 6.8 – Portfolio Analysis with Dense Rank
WITH PortfolioAnalysis (
TradeYear,CustId,PortfolioNo,Portfolio,YearlyValue
)
AS (
SELECT [Year] AS TradeYear
      ,CustId
      ,PortfolioNo
      ,Portfolio
	  -- introduce artificial duplicate value
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

SELECT TradeYear
	,CustId
	,PortfolioNo
	,Portfolio
	,YearlyValue
	,RANK() OVER(
		ORDER BY YearlyValue DESC
	) AS PortfolioRank
	,DENSE_RANK() OVER(
		ORDER BY YearlyValue DESC
	) AS PortfolioDenseRank
FROM PortfolioAnalysis
WHERE Portfolio = 'CASH - FINANCIAL PORTFOLIO'
GO
-- Listing 6.9 – Suggested Index
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
-- Listing 6.10 – Top 20 Performing Ticker Symbols
SELECT TOP 20 [QuoteYear]
      ,[Ticker]
      ,[Company]
      ,MIN([Low])               AS MinLow
      ,MAX([High])              AS MaxHigh
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
-- Listing 6.11 – Suggested index
DROP INDEX IF EXISTS eTickerCompanyLowHigh
ON [MasterData].[TickerPriceRangeHistoryDetail]
GO

CREATE NONCLUSTERED INDEX [eTickerCompanyLowHigh]
ON [MasterData].[TickerPriceRangeHistoryDetail] ([QuoteYear])
INCLUDE ([Ticker],[Company],[Low],[High])
GO
-- Listing 6.12a – setup ticker data
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
-- Listing 6.12b – Generate Recommendation Tiles
DECLARE @RatingBuckets INT;

SELECT @RatingBuckets = COUNT(DISTINCT Rating)
FROM @TickerRating;

SELECT Ticker
,Rating
,CASE
		WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 1 
THEN 'Highly Recommend'
		WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 2 
THEN 'Recommend'
		WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 3 
THEN 'Worth a shot'
		WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 4 
THEN 'Are you feeling lucky?'
		WHEN NTILE(@RatingBuckets) OVER (ORDER BY Ticker) = 5 
THEN 'Run away!'
END AS AnalystRecommends
FROM @TickerRating;
GO
-- Listing 6.13 – Rank Values Within Buckets
;WITH SymbolCTE (TransYear,Symbol,SumTransactions,InvestmentBucket)
AS
(
SELECT YEAR([TransDate])  AS TransYear
	,[Symbol]
      ,SUM([TransAmount]) AS SumTransactions
	,NTILE(9) OVER (
	    PARTITION BY YEAR([TransDate])
	     ORDER BY SUM([TransAmount]) DESC
		) AS InvestmentBucket
FROM [APFinance].[Financial].[Transaction]
GROUP BY YEAR([TransDate]),Symbol
)
 
SELECT TransYear
	,Symbol
	,SumTransactions
	,InvestmentBucket
	,RANK() OVER(
			PARTITION BY TransYear,InvestmentBucket
			ORDER BY InvestmentBucket,SumTransactions DESC 
		) AS InvestmentRank
FROM SymbolCTE
GO
-- Listing 6.14 – Assign Row Numbers & Rank to each Partition
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
GROUP BY CustId,Year,PortfolioNo,PortfolioAccountTypeCode,Portfolio
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
-- Listing 6.15 – Query Example to Generate Dynamic Statistics
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
-- Listing 6.16 – Setup Data, Gaps, and islands
CREATE TABLE Financial.CustomerBuyTransaction(
	TransDate		date			NOT NULL,
	CustId			varchar(8)		NOT NULL,
	Symbol			varchar(64)		NOT NULL,
	TradeNo           smallint          NOT NULL,
	TransAmount		decimal(10,2)	NOT NULL,
	TransTypeCode	varchar(8)		NOT NULL
) ON AP_FINANCE_FG
GO

-- Listing 6.17 – Load Trades for Customer LIBOR Trades
INSERT INTO Financial.CustomerBuyTransaction
SELECT
	CAL.[CalendarDate]
	,FT.CustId
	,FT.Symbol
	,ROW_NUMBER() OVER (
		PARTITION BY CAL.[CalendarDate],FT.CustId,FT.Symbol,
FT.TransAmount,FT.TransTypeCode
		ORDER BY CAL.[CalendarDate],FT.CustId,FT.Symbol,
FT.TransAmount,FT.TransTypeCode
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
-- Listing 6.18 – Create Gaps in Trade Activity
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
VALUES('2012-01-01','C0000001','AA',2,312.40,'TT00002')
GO

INSERT INTO Financial.CustomerBuyTransaction
VALUES('2012-01-01','C0000001','LIBOR OIS',2,2000.40,'TT00005')
GO
-- Listing 6.19 – Create the First CTE
WITH TradeGapsCTE(
	TransDate,NextTradeDate,GapTradeDays,
CustId,Symbol,TransAmount,TransTypeCode
)
AS
(
SELECT
	FT.[TransDate] AS TradeDate
	,LEAD(FT.[TransDate]) OVER(
ORDER BY FT.[TransDate]
) AS NextTradeDate
	,CASE
		WHEN (DATEDIFF(dd,FT.[TransDate],LEAD(FT.[TransDate]) 
OVER(ORDER BY FT.[TransDate])) - 1) = -1
		THEN 0
		ELSE (DATEDIFF(dd,FT.[TransDate],LEAD(FT.[TransDate]) 
OVER(ORDER BY FT.[TransDate])) - 1)
	 END AS GapTradeDays
	,FT.CustId
	,FT.Symbol
	,FT.TransAmount
	,FT.TransTypeCode
FROM Financial.CustomerBuyTransaction FT
WHERE CustId = 'C0000005'
AND Symbol = 'LIBOR OIS'
AND YEAR(FT.TransDate) = 2012
),
-- Listing 6.20 – Label the Gaps
GapsAndIslands(
	TransDate,NextTradeDate,GapTradeDays,
GapOrIsland,CustId,Symbol,TransAmount,TransTypeCode
)
AS (
SELECT TG.TransDate
	,TG.NextTradeDate
	,TG.GapTradeDays
	,CASE
		WHEN TG.GapTradeDays = 0 THEN 'ISLAND'
		ELSE 'GAP' + CONVERT(VARCHAR,
ROW_NUMBER() OVER (ORDER BY YEAR(TG.TransDate)))
	END AS GapOrIsland
	,TG.CustId
	,TG.Symbol
	,TG.TransAmount
	,TG.TransTypeCode
FROM TradeGapsCTE TG
),
-- Listing 6.21 – Identify Gap Start & Stop Dates
FinalGapIslanCTE (
	CustId,Symbol,GapTradeDays,GapOrIsland,GapStart,GapEnd
)
AS (
SELECT CustId
	,Symbol
	,GapTradeDays
	,GapOrIsland
	,MIN(TransDate)     AS GapStart
	,MAX(NextTradeDate) AS GapEnd
FROM GapsAndIslands
WHERE NextTradeDate IS NOT NULL
AND GapTradeDays > 0
GROUP BY CustId
	,Symbol
	,GapTradeDays
	,GapOrIsland
)
-- Listing 6.22 – Assemble the Report
SELECT CustId
	,Symbol
	,GapTradeDays
	,GapStart
	,GapEnd
	,(
	SELECT STRING_AGG(CalendarDate,',')
	FROM [MasterData].[Calendar]
	WHERE CalendarDate BETWEEN DATEADD(dd,1,GapStart)
	AND DATEADD(dd,-1,GapEnd)
	) AS GapInTradeDays 
FROM FinalGapIslanCTE 
ORDER BY CustId
	,Symbol
	,GapStart
GO
-- Listing 6.23 – Create Island CTE 1
WITH TradeGapsCTE(
	TransDate,NextTradeDate,GapTradeDays,CustId,Symbol,
TransAmount,TransTypeCode
)
AS
(
SELECT
	FT.[TransDate] AS TradeDate
	,LEAD(FT.[TransDate]) OVER(ORDER BY FT.[TransDate]) AS NextTradeDate
	,CASE 
		WHEN LEAD(FT.[TransDate]) 
OVER(ORDER BY FT.[TransDate]) = FT.TransDate
		THEN 0
		ELSE DATEDIFF(dd,FT.[TransDate],LEAD(FT.[TransDate]) 
OVER(ORDER BY FT.[TransDate])) - 1
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
),
-- uncomment below to test CTE
--SELECT * FROM TradeGapsCTE
--ORDER BY 1

-- Listing 6.24 – Create 2nd CTE, Label Islands and Gaps
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
THEN 'ISLAND' + CONVERT(VARCHAR,ABS((DAY(TG.NextTradeDate) - ROW_NUMBER()OVER (ORDER BY YEAR(TG.TransDate)))))
		WHEN DATEDIFF(dd,TransDate,NextTradeDate) = 1 
THEN 'ISLAND' + CONVERT(VARCHAR,ABS((DAY(TG.NextTradeDate) - ROW_NUMBER()OVER(ORDER BY YEAR(TG.TransDate)))))
		WHEN NextTradeDate IS NULL
			THEN 'ISLAND' + CONVERT(VARCHAR,(ROW_NUMBER() 
OVER(ORDER BY YEAR(TG.TransDate))))
ELSE 'GAP' + CONVERT(VARCHAR,ABS(DAY(TG.NextTradeDate) - ROW_NUMBER()OVER(ORDER BY YEAR(TG.TransDate))))
	END AS GapOrIsland
	,TG.CustId
	,TG.Symbol
	,TG.TransAmount
	,TG.TransTypeCode
FROM TradeGapsCTE TG
),

-- uncomment below to test CTE
--SELECT TransDate,NextTradeDate,GapTradeDays,GapOrIsland,
--CustId,Symbol,TransAmount,TransTypeCode
--FROM GapsAndIslands
--ORDER BY 1
--GO
-- Listing 6.25 – Identifying Start and End Dates for Gaps and Islands
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

--uncomment below to test CTE
SELECT * FROM FinalGapIslandCTE
ORDER BY CustId,GapIslandStart
GO
-- Listing 6.26 – The Final Gap and Island Report
SELECT CustId
	,Symbol
	,CASE 
	WHEN GapOrIsland LIKE 'ISLAND%' THEN DATEDIFF(dd,GapIslandStart,GapIslandEnd) + 1
		ELSE GapTradeDays
	END AS TradeDays
	,GapOrIsland
	,GapIslandStart AS GapOrIslandStart
	,GapIslandEnd AS GapOrIslandEnd
	,CASE
		WHEN GapOrIsland LIKE 'GAP%' THEN
		(
			SELECT STRING_AGG(CalendarDate,',')
			FROM [MasterData].[Calendar]
			WHERE CalendarDate BETWEEN DATEADD(dd,1,GapIslandStart) 
AND DATEADD(dd,-1,GapIslandEnd)
		) 
		ELSE (
			SELECT STRING_AGG(CalendarDate,',')
			FROM [MasterData].[Calendar]
			WHERE CalendarDate BETWEEN GapIslandStart AND GapIslandEnd
		) 
		END AS GapOrIslandTradeDays 
FROM FinalGapIslandCTE 
ORDER BY CustId,Symbol,GapIslandStart
GO
