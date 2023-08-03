/*******************************************/
/* Chapter 06 - Aggregate Function Queries */
/*******************************************/

USE [APFinance]
GO

-- Listing 5.1 – Count() Function in all its’ Flavors
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
-- Listing 5.2a –Customer Analysis CTE Query
SELECT YEAR(T.TransDate)          AS TransYear
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
ORDER BY C.CustId
	,YEAR(T.TransDate)
	,DATEPART(qq,(T.TransDate))
	,MONTH(T.TransDate)
	,T.TransDate
	,T.BuySell
	,T.Symbol
	,C.CustFname
	,C.CustLname
	,AcctNo
GO
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
WHERE CustId  = 'C0000001'
AND TransYear = 2012
AND BuySell   = 'B'
AND Symbol    = 'AA'
AND AcctNo    = 'A02C1'
ORDER BY TransYear
,TransQtr
	,TransMonth
	,TransDate
	,CustId	
	,BuySell
	,Symbol
GO
-- Listing 5.3 – Suggested index
USE [APFinance]
GO
CREATE NONCLUSTERED INDEX ieTransDateSymbolAcctNoBuySell
ON [Financial].[Transaction] ([CustId])
INCLUDE ([TransDate],[Symbol],[AcctNo],[BuySell])
GO
-- Listing 5.4 – Loading the Customer Analysis Table
TRUNCATE TABLE Report.CustomerC0000001Analysis
GO

INSERT INTO Report.CustomerC0000001Analysis
SELECT YEAR(T.TransDate)          AS TransYear
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
-- Listing 5.5 – Account Cash Summary Totals Analysis
SELECT YEAR(PostDate) AS AcctYear
    ,MONTH(PostDate)  AS AcctMonth
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
FROM APFinance.Financial.Account
WHERE YEAR(PostDate) = 2012

/* Uncomment the line below, to report on more than 1 year, 
   and comment out the line above*/
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
-- Listing 5.6 – Suggested Index
CREATE NONCLUSTERED INDEX [iePrtNoAcctNoTypeBalPostDate]
ON [Financial].[Account] ([CustId],[AcctName])
INCLUDE ([PrtfNo],[AcctNo],[AcctTypeCode],[AcctBalance],[PostDate])
GO 
-- Listing 5.7 – Min() and Max() in a simple example
DECLARE @MinMaxExample TABLE (
	ExampleValue SMALLINT
	);

INSERT INTO @MinMaxExample VALUES(20),(20),(30),(40),(60),(60);

SELECT MIN(ExampleValue)   AS MinExampleValue
,COUNT(ExampleValue) AS MinCount
FROM @MinMaxExample;
SELECT MIN(ALL ExampleValue)    AS MinExampleValueALL
,COUNT( ALL ExampleValue) AS MinCountALL 
FROM @MinMaxExample;
SELECT MIN(DISTINCT ExampleValue)  AS MinExampleValueDISTINCT
,COUNT(DISTINCT ExampleValue) AS MinCountDISTINCT 
FROM @MinMaxExample;

SELECT MAX(ExampleValue)   AS MaxExampleValue
,COUNT(ExampleValue) AS MAXCount
FROM @MinMaxExample;
SELECT MAX(ALL ExampleValue)    AS MaxExampleValueALL
,COUNT( ALL ExampleValue) AS MAXCountALL
FROM @MinMaxExample;
SELECT MAX(DISTINCT ExampleValue)    AS MaxExampleValueDISTINCT
,COUNT( DISTINCT ExampleValue) AS MAXCountDISTINCT
FROM @MinMaxExample;
GO

-- Listing 5.8 – Cash Analysis for Customer C000001 using MIN() & MAX()
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
FROM APFinance.Financial.Account
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
/*    ,MIN(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		ORDER BY PostDate
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS MonthlyAcctMin
    ,MAX(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)
		ORDER BY PostDate
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS MonthlyAcctMax */
-- Listing 5.9 – Suggested Index
USE [APFinance]
GO
CREATE NONCLUSTERED INDEX iePrtfNoAcctNoAcctTypeCodeAcctBalancePostDate
ON [Financial].[Account] ([CustId],[AcctName])
INCLUDE ([PrtfNo],[AcctNo],[AcctTypeCode],[AcctBalance],[PostDate])
GO
-- Listing 5.10 – Test Query
USE TEST
GO

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

SELECT AVG(ExampleValue)                    AS AVGExampleValue
FROM @AVGMaxExample;
SELECT AVG(ALL ExampleValue)                AS AVGExampleValueALL
FROM @AVGMaxExample;
SELECT AVG(DISTINCT ExampleValue)           AS AVGExampleValueDISTINCT
FROM @AVGMaxExample;

SELECT ValueType,AVG(ExampleValue)          AS AVGExampleValue
FROM @AVGMaxExample
GROUP BY ValueType;
SELECT ValueType,AVG(ALL ExampleValue)      AS AVGExampleValueALL
FROM @AVGMaxExample
GROUP BY ValueType;
SELECT ValueType,AVG(DISTINCT ExampleValue) AS AVGExampleValueDISTINCT
FROM @AVGMaxExample
GROUP BY ValueType;
GO
-- Listing 5.11 – Rolling 3 Day Averages
SELECT YEAR(PostDate)  AS AcctYear
,MONTH(PostDate) AS AcctMonth
	,PostDate
	,CustId
    	,PrtfNo
    	,AcctNo
    	,AcctName
    	,AcctTypeCode
	,AcctBalance
    	,AVG(AcctBalance) OVER(
		PARTITION BY MONTH(PostDate)

	/* uncomment to report on more than 1 year */
	--PARTITION BY YEAR(PostDate),MONTH(PostDate)

		ORDER BY PostDate
	ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
	) AS [3 DayRollingAcctAvg]
FROM APFinance.Financial.Account
WHERE YEAR(PostDate) = 2012

/*******************************************/
/* Uncomment to report on more than 1 year */
/*******************************************/
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
-- Listing 5.12 – Transaction Rollups for EURO Foreign Currency
SELECT YEAR(TransDate)        AS TransYear
,DATEPART(qq,TransDate) AS TransQtr
	,MONTH(TransDate)       AS TransMonth
	,TransDate
      ,Symbol
      ,CustId
	,TransAmount
	,SUM(TransAmount)      AS SumOfTransAmt
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
	,(CASE WHEN TransAmount IS NULL THEN 0 END)DESC
      ,SUM(TransAmount) DESC
	,GROUPING(TransAmount) DESC
GO
-- Listing 5.13 – Suggested Index for GROUPING() Example 
CREATE NONCLUSTERED INDEX [ieTranSymCustBuySell]
ON [Financial].[Transaction] ([Symbol],[CustId],[BuySell])
INCLUDE ([TransDate],[TransAmount])
GO
-- Listing 5.14 – Assemble 24 Hour Ticker Prices
SELECT STRING_AGG('msg start->ticker:' + Ticker 
	+ ',company:' + Company 
	+ ',trade date:' + convert(VARCHAR, TickerDate) 
	+ ',hour:' + convert(VARCHAR, QuoteHour) 
	+ ',price:' + convert(VARCHAR, Quote) + '<-msg stop', '!') + CHAR(10)
FROM MasterData.TickerHistory
WHERE TickerDate = '2015-01-01'
GO
-- Listing 5.15 – Portfolio Standard Deviation Analysis
WITH PortfolioAnalysis (
TradeYear,TradeQtr,TradeMonth,CustId,PortfolioNo,Portfolio,MonthlyValue
)
AS (
SELECT Year					  AS TradeYear
	,DATEPART(qq,SweepDate)         AS TradeQtr
      ,Month				  AS TradeMonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value)			        AS MonthlyValue
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
ORDER BY CustId,Portfolio,TradeYear,TradeQtr,TradeMonth
GO
/* WHERE TradeYear IN(2012,2013)
AND CustId = 'C0000001'
AND Portfolio IN (
	'CASH - FINANCIAL PORTFOLIO',
	'EQUITY - FINANCIAL PORTFOLIO'
	)
*/
-- Listing 5.16 – Setting Up the Example
DECLARE @TradeYearStdev TABLE (
	TradeYear		SMALLINT      NOT NULL,
	TradeQuarter		SMALLINT      NOT NULL,
	TradeMonth		SMALLINT      NOT NULL,
	CustId			VARCHAR(32)   NOT NULL,
	PortfolioNo		VARCHAR(32)   NOT NULL,
	Portfolio		VARCHAR(64)   NOT NULL, 
	MonthlyValue		DECIMAL(10,2) NOT NULL
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
-- Listing 5.17 – Setting up the Example
DECLARE @TradeYearStdev TABLE (
	TradeYear		SMALLINT      NOT NULL,
	TradeQuarter		SMALLINT      NOT NULL,
	TradeMonth		SMALLINT      NOT NULL,
	CustId			VARCHAR(32)   NOT NULL,
	PortfolioNo		VARCHAR(32)   NOT NULL,
	Portfolio		VARCHAR(64)   NOT NULL, 
	MonthlyValue		DECIMAL(10,2) NOT NULL
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
-- Listing 5.18 – Suggested Index
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
-- Listing 5.18 – Create Account Forecast Table

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
FROM [APFinance].[Financial].[Account]
GO
-- Listing 5.19 – Actual Versus Forecast Account Balance Query
SELECT [CustId] 
	,YEAR([PostDate])  AS PostYear
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
-- Listing 5.20 – More Nice Bell Curves
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
FROM [APFinance].[MasterData].[TickerHistory]
WHERE TickerDate = '2015-01-05'
GO
