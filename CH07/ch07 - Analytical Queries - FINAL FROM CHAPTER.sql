

-- Listing  7.1 – a Simple Example
USE TEST
GO

DECLARE @CumDistDemo TABLE (
	Col1 VARCHAR(8),
	ColValue INTEGER
	);

INSERT INTO @CumDistDemo VALUES
('AAA',1),
('BBB',2),
('CCC',3),
('DDD',4),
('EEE',5),
('FFF',6),
('GGG',7),
('HHH',8),
('III',9),
('JJJ',10)

SELECT Col1,ColValue,
	CUME_DIST() OVER(
		ORDER BY ColValue
	) AS CumeDistValue,
	A.RowCountLE,
	B.TotalRows,
	CONVERT(DECIMAL(10,2),A.RowCountLE) 
		/ CONVERT(DECIMAL(10,2),B.TotalRows) AS MyCumeDist
FROM @CumDistDemo CDD
CROSS APPLY (
	SELECT COUNT(*) AS RowCountLE FROM @CumDistDemo 
WHERE ColValue <= CDD.ColValue
	) A
CROSS APPLY (
	SELECT COUNT(*) AS TotalRows FROM @CumDistDemo
	) B
GO
-- Listing  7.2 – Monthly Portfolio Cumulative Distribution Analysis
WITH PortfolioAnalysis (
TradeYear,TradeQtr,TradeMonth,CustId,PortfolioNo,Portfolio,MonthlyValue
)
AS (
SELECT Year AS TradeYear
	,DATEPART(qq,SweepDate) AS TradeQtr
      ,Month	            		AS TradeMonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value)             AS MonthlyValue
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
	,CUME_DIST() OVER(
		PARTITION BY Portfolio
		ORDER BY TradeMonth,Portfolio
	) AS CumeDistByMonth
	,CUME_DIST() OVER(
		PARTITION BY Portfolio
		ORDER BY TradeQtr,Portfolio
	) AS CumeDistByMonth
FROM PortfolioAnalysis
WHERE TradeYear = 2012
AND CustId = 'C0000001'
GO
-- Listing  7.3 – First & Last Account Balances by Year, Customer Sorted by Month
WITH MonthlyAccountBalances (
AcctYear,AcctMonth,CustId, PrtfNo, AcctNo, AcctName, AcctBalance
)
AS
(
SELECT YEAR(PostDate)  AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,SUM(AcctBalance)
FROM Financial.Account
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
)

SELECT CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,AcctBalance

	,FIRST_VALUE(AcctBalance) OVER (
		PARTITION BY AcctYear,CustId
		ORDER BY AcctMonth
		ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
	) AS FirstValueBalance

	,LAST_VALUE(AcctBalance) OVER (
		PARTITION BY AcctYear,CustId
		ORDER BY AcctMonth
		ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
	) AS LastValueBalanceCRUF

	,FIRST_VALUE(AcctBalance) OVER (
		PARTITION BY AcctYear,CustId
		ORDER BY AcctMonth
	    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS FirstValueBalanceUPCR

	,LAST_VALUE(AcctBalance) OVER (
		PARTITION BY AcctYear,CustId
		ORDER BY AcctMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS LastValueBalanceUPCR
FROM MonthlyAccountBalances
WHERE AcctYear >= 2013
AND AcctNAme = 'CASH'
ORDER BY CustId 
	,AcctYear
	,AcctName
	,AcctMonth
	GO
-- Listing  7.4 – Suggested Estimated Query Plan Index
CREATE NONCLUSTERED INDEX [ieAcctPrtBalancePostDate]
ON [Financial].[Account] ([AcctName])
INCLUDE ([CustId],[PrtfNo],[AcctNo],[AcctBalance],[PostDate])
GO
-- Listing  7.5 – Using LAG() to Calculate the Last Month Balances
SELECT CustId
	,AcctYear
	,AcctMonth
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,AcctBalance
	,LAG(AcctBalance) OVER (
		PARTITION BY CustId,AcctYear,AcctName
		ORDER BY AcctMonth
	) AS LastMonthBalance
	,AcctBalance - 
		(
		LAG(AcctBalance) OVER (
		PARTITION BY CustId,AcctYear,AcctName
		ORDER BY AcctMonth
		) 
	) AS Change
FROM MonthlyAccountBalances
WHERE AcctYear >= 2013
GO
-- Listing  7.6 – Creating the Account Monthly Balances Report Table
CREATE SCHEMA FinancialReports
GO

SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,SUM(AcctBalance) AS AcctBalance 
INTO FinancialReports.AccountClustered
FROM Financial.Account
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO
-- Listing  7.7 – Creating the Clustered and Non-Clustered Indexes
CREATE CLUSTERED INDEX ieYearMonthCustIdPrtfNoAcctNoAcctName
ON FinancialReports.AccountClustered (
[AcctYear],[AcctMonth],[CustId],[PrtfNo],[AcctNo],[AcctBalance]
)
GO

CREATE INDEX ieCustIdAcctYearAcctMonthAcctNameAcctName
ON FinancialReports.AccountClustered (
[CustId],[AcctYear],[AcctName],[AcctMonth]
)
GO
-- Listing  7.8 – Using the Account Report Table with Clustered and Non-Clustered Indexes

SELECT CustId 
	,AcctYear
	,AcctMonth
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,AcctBalance
	,LAG(AcctBalance) OVER (
		PARTITION BY CustId,AcctYear,AcctName
		ORDER BY AcctMonth
	) AS LastMonthBalance
	,AcctBalance - 
		(
		LAG(AcctBalance) OVER (
		PARTITION BY CustId,AcctYear,AcctName
		ORDER BY AcctMonth
		) 
	) AS Change
FROM FinancialReports.AccountClustered
WHERE AcctYear >= 2013
GO

-- Listing  7.9 – Monthly Account Balance Analysis, Current Years versus Next Year

SELECT CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,AcctBalance
	,LEAD(AcctBalance,12,0) OVER (
		PARTITION BY CustId
		ORDER BY AcctName,AcctYear,AcctMonth
	) AS NextYearBalance
FROM MonthlyAccountBalances
WHERE AcctYear >= 2013
AND AcctNAme = 'CASH'
GO
-- Listing  7.10 – Create Memory Optimized Table
CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem]
(
	[AcctYear]    [int] NULL,
	[AcctMonth]   [int] NULL,
	[CustId]      [varchar](8) NOT NULL,
	[PrtfNo]      [varchar](8) NOT NULL,
	[AcctNo]      [varchar](64) NOT NULL,
	[AcctName]    [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

	INDEX [ieMonthlyAcctBalanceMemory] NONCLUSTERED 
	(
	[AcctYear],
	[AcctMonth],
	[CustId],
	[PrtfNo],
	[AcctNo]
	)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO
-- Listing  7.11 – Load the Memory Optimized Table
INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem]
SELECT YEAR(PostDate)  AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,CONVERT(DECIMAL(10,2),SUM(AcctBalance)) AS AcctBalance
FROM Financial.Account
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO

-- Listing  7.12 – Using LEAD() and LAG() Against a Memory Optimized Table

SELECT CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,AcctBalance
	,LEAD(AcctBalance,12,0) OVER (
		PARTITION BY CustId
		ORDER BY AcctName,AcctYear,AcctMonth
	) AS NextYearBalance
	,LAG(AcctBalance,12,0) OVER (
		PARTITION BY CustId
		ORDER BY AcctName,AcctYear,AcctMonth
	) AS LastYearBalance
FROM [FinancialReports].[AccountMonthlyBalancesMem]
WHERE AcctYear >= 2013
AND AcctNAme = 'CASH'
GO
-- Listing  7.13 – Customer Yearly Account Balance Monthly Ranking
SELECT CustId 
	,AcctYear
	,[AcctMonth]
	,AcctNo 
	,AcctName 
	,AcctBalance
	,PERCENT_RANK() OVER (
		PARTITION BY CustId,AcctYear,AcctMonth
		ORDER BY AcctBalance DESC
	) AS PercentRank
	,DENSE_RANK() OVER (
		PARTITION BY CustId,AcctYear,AcctMonth
		ORDER BY AcctBalance DESC
	) AS DenseRank
	,RANK() OVER (
		PARTITION BY CustId,AcctYear,AcctMonth
		ORDER BY AcctBalance DESC
	) AS Rank
FROM [FinancialReports].[AccountMonthlyBalancesMem]
WHERE AcctYear >= 2013
GO
-- Listing  7.14 – Customer Continuous Percentiles Query
SELECT CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,AcctBalance
	,PERCENTILE_CONT(.25) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentCont-25%]
	,PERCENTILE_CONT(.50) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentCont-50%]
	,PERCENTILE_CONT(.75) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentCont-75%]
	,PERCENTILE_CONT(.90) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
	) AS [PercentCont-90%]
FROM [FinancialReports].[AccountMonthlyBalancesMem]
WHERE Acctname = 'OPTION'
AND CustId = 'C0000001'
GO

-- Listing  7.15 – Percentile Discrete, using the CTE Scheme
WITH MonthlyAccountBalances (
AcctYear,AcctMonth,CustId, PrtfNo, AcctNo, AcctName, AcctBalance
)
AS
(
SELECT YEAR(PostDate)  AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,SUM(AcctBalance)
FROM Financial.Account
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId
	,PrtfNo 
	,AcctNo
	,AcctName
)

SELECT CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,AcctBalance
	,PERCENTILE_DISC(.25) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-25%]
	,PERCENTILE_DISC(.50) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-50%]
	,PERCENTILE_DISC(.75) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-75%]
	,PERCENTILE_DISC(.90) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
	) AS [PercentDisc-90%]
FROM FinancialReports.AccountMonthlyBalances
WHERE Acctname = 'OPTION'
AND CustId = 'C0000001'
ORDER BY CustId 
	,AcctYear
GO

-- Listing  7.16 – Create 5 Memory Enhanced Tables
CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2011]
(
	[AcctYear]    [int] NULL,
	[AcctMonth]   [int] NULL,
	[CustId]      [varchar](8) NOT NULL,
	[PrtfNo]      [varchar](8) NOT NULL,
	[AcctNo]      [varchar](64) NOT NULL,
	[AcctName]    [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NOT NULL,

	INDEX [ieMonthlyAcctBalanceMemory2011] NONCLUSTERED 
	(
	[CustId],
	[AcctYear],
	[AcctMonth],
	[PrtfNo],
	[AcctNo]
	)
)WITH (MEMORY_OPTIMIZED = ON,DURABILITY = SCHEMA_ONLY)
GO
-- Listing  7.17 Load the 5 Memory Enhanced Tables
INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2011]
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,CONVERT(DECIMAL(10,2),SUM(AcctBalance)) AS AcctBalance
FROM Financial.Account
WHERE YEAR(PostDate) = 2011
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO
-- Listing  7.18 – Create View based on the 5 Memory Enhanced Tables
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
-- Listing  7.19 – Account Balances Report from Memory Table Based View
SELECT CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,AcctBalance
	,PERCENTILE_DISC(.25) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-25%]
	,PERCENTILE_DISC(.50) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-50%]
	,PERCENTILE_DISC(.75) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-75%]
	,PERCENTILE_DISC(.90) 
		WITHIN GROUP (ORDER BY AcctBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
	) AS [PercentDisc-90%]
FROM [FinancialReports].[AccountMonthlyBalancesMemView]
WHERE Acctname = 'OPTION'
AND CustId = 'C0000001'
ORDER BY CustId 
	,AcctYear
GO
