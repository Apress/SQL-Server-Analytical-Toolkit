/*****************************************/
/* Chapter 7 - Finance Database Use Case */
/* Analytical Functions                  */
/* Created: 02/23/2023                   */
/* Modified: 07/12/2023                  */
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


/************************/
/* Analytical Functions */
/************************/

/*
•	CUME_DIST()
•	FIRST_VALUE()
•	LAST_VALUE()
•	LAG()
•	LEAD()
•	PERCENT_RANK()
•	PERCENTILE_CONT()
•	PERCENTILE_DISC()
*/

/***************/
/* CUME_DIST() */
/***************/

/***********************************/
/* Listing  7.1 – a Simple Example */
/***********************************/

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

DBCC dropcleanbuffers;
CHECKPOINT;
GO

/*********************************************************************/
/* Listing  7.2 – Monthly Portfolio Cumulative Distribution Analysis */
/*********************************************************************/
 
-- turn set statistics io/time/profile on

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
SELECT Year AS TradeYear
	  ,DATEPART(qq,SweepDate) AS TradeQtr
      ,Month	AS TradeMonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value) AS MonthlyValue
FROM Financial.Portfolio
WHERE Year > 2011
GROUP BY CustId,PortfolioNo
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

/*****************************************/
/* add below for including year analysis */
/*****************************************/
/*
	,CUME_DIST() OVER(
		PARTITION BY Portfolio
		ORDER BY TradeYear,Portfolio
	) AS CumeDistByMonth

WHERE CustId = 'C0000001'
*/

/***********************/
/* Modify WHERE clause */
/***********************/

-- WHERE CustId = 'C0000001'

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***********************/
/* MORE VERBOSE REPORT */
/***********************/

WITH PortfolioAnalysis (
TradeYear,TradeQtr,TradeMonth,CustId,PortfolioNo,Portfolio,
	PortfolioAccountTypeCode,MonthlyValue
)
AS (
SELECT Year AS TradeYear
	  ,DATEPART(qq,SweepDate) AS TradeQtr
      ,Month	AS TradeMonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
	  ,PortfolioAccountTypeCode	  
      ,SUM(Value) AS MonthlyValue
FROM Financial.Portfolio
WHERE Year > 2011
GROUP BY CustId
	  ,PortfolioNo
	  ,Year
      ,Month
	  ,SweepDate
      ,Portfolio
	  ,PortfolioAccountTypeCode
)

SELECT TradeYear
	,CASE 
		WHEN TradeQtr = 1 THEN '1st Qtr'
		WHEN TradeQtr = 2 THEN '2nd Qtr'
		WHEN TradeQtr = 3 THEN '3rd Qtr'
		WHEN TradeQtr = 4 THEN '4th Qtr'
	END AS TradeQtr
	,CASE
		WHEN TradeMonth = 1 THEN 'Jan'
		WHEN TradeMonth = 2 THEN 'Feb'
		WHEN TradeMonth = 3 THEN 'Mar'
		WHEN TradeMonth = 4 THEN 'Apr'
		WHEN TradeMonth = 5 THEN 'May'
		WHEN TradeMonth = 6 THEN 'Jun'
		WHEN TradeMonth = 7 THEN 'Jul'
		WHEN TradeMonth = 8 THEN 'Aug'
		WHEN TradeMonth = 9 THEN 'Sep'
		WHEN TradeMonth = 10 THEN 'Oct'
		WHEN TradeMonth = 11 THEN 'Nov'
		WHEN TradeMonth = 12 THEN 'Dec'
	END AS TradEMonth
	,C.CustId
	,C.CustFname
	,C.CustLname
	,C.IncomeBracket
	,PortfolioNo
	,Portfolio
	,PortfolioAccountTypeCode
	,MonthlyValue
	,CUME_DIST() OVER(
		PARTITION BY Portfolio
		ORDER BY TradeMonth,Portfolio
	) AS CumeDistByQtr
FROM PortfolioAnalysis PA
JOIN [MasterData].[Customer] C
ON PA.CustId = C.CustId
WHERE TradeYear = 2012
AND C.CustId = 'C0000001'
GO

/*************************/
/* Report Table approach */
/*************************/

TRUNCATE TABLE [FinancialReports].[PortfolioMonthlyBalances]
GO

INSERT INTO [FinancialReports].[PortfolioMonthlyBalances]
SELECT Year AS TradeYear
	  ,DATEPART(qq,SweepDate) AS TradeQtr
      ,Month	AS TradeMonth
      ,CustId
      ,PortfolioNo
      ,Portfolio
      ,SUM(Value) AS MonthlyValue
FROM Financial.Portfolio
WHERE Year > 2011
GROUP BY CustId
	  ,PortfolioNo
	  ,Year
      ,Month
	  ,SweepDate
      ,Portfolio
ORDER BY CustId
	  ,PortfolioNo
	  ,Year
      ,Month
	  ,SweepDate
      ,Portfolio
GO

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
FROM [FinancialReports].[PortfolioMonthlyBalances]
WHERE TradeYear = 2012
AND CustId = 'C0000001'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/**********************/
/* Non - CTE approach */
/**********************/

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

SELECT Year AS TradeYear
	,DATEPART(qq,SweepDate) AS TradeQtr
    ,Month
	,CustId
	,PortfolioNo
	,Portfolio
	,SUM(Value)
	,CUME_DIST() OVER(
		PARTITION BY Portfolio
		ORDER BY Month,Portfolio
	) AS CumeDistByMonth
	,CUME_DIST() OVER(
		PARTITION BY Portfolio
		ORDER BY DATEPART(qq,SweepDate),Portfolio
	) AS CumeDistByMonth
FROM Financial.Portfolio
WHERE [Year] = 2012
AND CustId = 'C0000001'
GROUP BY CustId,PortfolioNo
	  ,Year
	  ,DATEPART(qq,SweepDate)
      ,Month
	  ,SweepDate
      ,Portfolio
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/********************************/
/* FIRST_VALUE() & LAST_VALUE() */
/********************************/

/**********************************************************************************/
/* Listing  7.3 – First & Last Account Balances by Year, Customer Sorted by Month */
/**********************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

WITH MonthlyAccountBalances (
AcctYear,AcctMonth,CustId, PrtfNo, AcctNo, AcctName, AcctBalance
)
AS
(
SELECT YEAR(PostDate) AS AcctYear
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

SELECT 	CustId 
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

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*
Missing Index Details from ch07 - Analytical Queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance (DESKTOP-CEBK38L\Angelo (63))
The Query Processor estimates that implementing the following index could improve the query cost by 31.7286%.
*/

/*
USE [APFinance]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Financial].[Account] ([AcctName])
INCLUDE ([CustId],[PrtfNo],[AcctNo],[AcctBalance],[PostDate])
GO
*/

/*******************************************************/
/* Listing  7.4 – Suggested Estimated Query Plan Index */
/*******************************************************/

DROP INDEX IF EXISTS [ieAcctPrtBalancePostDate]
ON [Financial].[Account] 
GO
CREATE NONCLUSTERED INDEX [ieAcctPrtBalancePostDate]
ON [Financial].[Account] ([AcctName])
INCLUDE ([CustId],[PrtfNo],[AcctNo],[AcctBalance],[PostDate])
GO

/*********/
/* LAG() */
/*********/

/*******************************************************************/
/* Listing  7.5 – Using LAG() to Calculate the Last Month Balances */
/*******************************************************************/


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

WITH MonthlyAccountBalances (
AcctYear,AcctMonth,CustId, PrtfNo, AcctNo, AcctName, AcctBalance
)
AS
(
SELECT YEAR(PostDate) AS AcctYear
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

SELECT 	CustId 
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

/********************************************************/
/* To see rolling totals, etc. across all years use the */
/* OVER() clauses below                                 */
/********************************************************/


/*
	,LAG(AcctBalance) OVER (
		PARTITION BY CustId,AcctName
		ORDER BY CustId,AcctYear,AcctMonth,AcctName
	) AS LastMonthBalance
	,AcctBalance - 
		(
		LAG(AcctBalance) OVER (
		PARTITION BY CustId,AcctName
		ORDER BY CustId,AcctYear,AcctMonth,AcctName
		) 
	) AS Change
*/

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/******************************************/
/* CREATE A REPORT TABLE BASED ON THE CTE */
/******************************************/

/*********************************************************************/
/* Listing  7.6 – Creating the Account Monthly Balances Report Table */
/*********************************************************************/

USE [APFinance]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountClustered]
GO

CREATE TABLE [FinancialReports].[AccountClustered](
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10,2) NULL
) ON [AP_FINANCE_FG]
GO

TRUNCATE TABLE FinancialReports.AccountClustered
GO

INSERT INTO FinancialReports.AccountClustered
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,SUM(AcctBalance) AS AcctBalance 
-- INTO FinancialReports.AccountClustered
FROM Financial.Account
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO

/*******************************************************************/
/* Listing  7.7 – Creating the Clustered and Non-Clustered Indexes */
/*******************************************************************/

DROP INDEX IF EXISTS ieYearMonthCustIdPrtfNoAcctNoAcctName
ON FinancialReports.AccountClustered
GO

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

/******************************************************************************************/
/* Listing  7.8 – Using the Account Report Table with Clustered and Non-Clustered Indexes */
/******************************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT
GO
 
-- turn set statistics io/time/profile on
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT 	CustId 
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

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/**********************/
/* BONUS - LAG 1 YEAR */
/**********************/

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

WITH MonthlyAccountBalances (
AcctYear,AcctMonth,CustId, PrtfNo, AcctNo, AcctName, AcctBalance
)
AS
(
SELECT YEAR(PostDate) AS AcctYear
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

SELECT 	CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,AcctBalance
	,LAG(AcctBalance,12,0) OVER (
		PARTITION BY CustId
		ORDER BY AcctName,AcctYear,AcctMonth
	) AS LastYearBalance
FROM MonthlyAccountBalances
WHERE AcctYear >= 2013
AND AcctNAme = 'CASH'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***********************************************************************************/
/* Listing  7.9 – Monthly Account Balance Analysis, Current Years versus Next Year */
/***********************************************************************************/

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
FROM [FinancialReports].[AccountMonthlyBalances]
WHERE AcctYear >= 2013
AND AcctNAme = 'CASH'
GO

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
FROM [FinancialReports].[AccountMonthlyBalances]
WHERE AcctYear >= 2013
AND AcctNAme = 'CASH'
GO

/*****************************/
/* Memory Optimized Strategy */
/*****************************/

/*************************************************/
/* Listing  7.10 – Create Memory Optimized Table */
/*************************************************/

USE [APFinance]
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem]
GO

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,
/*
	INDEX [ieMonthlyAcctBalanceMemory] NONCLUSTERED 
	(
	[AcctYear],
	[AcctMonth],
	[CustId],
	[PrtfNo],
	[AcctNo]
	)
*/
	INDEX [ieMonthlyAcctBalanceMemory] NONCLUSTERED 
	(
	[CustId],
	[AcctYear],
	[AcctMonth],
	[PrtfNo],
	[AcctNo]
	)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/***************************************************/
/* Listing  7.11 – Load the Memory Optimized Table */
/***************************************************/

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem]
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,CONVERT(DECIMAL(10,2),SUM(AcctBalance)) AS AcctBalance
--INTO FinancialReports.AccountMonthlyBalances
FROM Financial.Account
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO

/***************************************************************************/
/* Listing  7.12 – Using LEAD() and LAG() Against a Memory Optimized Table */
/***************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

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

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO 

/***********************************/
/* Includes difference calculation */
/***********************************/

/*
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT 	CustId 
	,AcctYear
	,AcctMonth
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,AcctBalance
	,LEAD(AcctBalance) OVER (
		PARTITION BY CustId,AcctYear,AcctName
		ORDER BY AcctMonth
	) AS NextMonthBalance
	,(
		LEAD(AcctBalance) OVER (
		PARTITION BY CustId,AcctYear,AcctName
		ORDER BY AcctMonth
		) - AcctBalance
	) AS Change
FROM [FinancialReports].[AccountMonthlyBalances]
WHERE AcctYear >= 2013
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS PROFILE OFF
GO
*/

/******************/
/* PERCENT_RANK() */
/******************/

/*******************************************************************/
/* Listing  7.13 – Customer Yearly Account Balance Monthly Ranking */
/*******************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT 	CustId 
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
ORDER BY CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,PERCENT_RANK() OVER (
		PARTITION BY CustId,AcctYear
		ORDER BY CustId,AcctYear,AcctBalance
	) 
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*********************/
/* PERCENTILE_CONT() */
/*********************/

/*********************************************************/
/* Listing  7.14 – Customer Continuous Percentiles Query */
/*********************************************************/

DBCC dropcleanbuffers;
CHECKPOINT
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT 	CustId 
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
--FROM [FinancialReports].[AccountMonthlyBalancesMem]
FROM [FinancialReports].[AccountMonthlyBalances]
WHERE Acctname = 'OPTION'
AND CustId = 'C0000001'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*********************/
/* PERCENTILE_DISC() */
/*********************/

/**************************************************************/
/*  Listing  7.15 – Percentile Discrete, using the CTE Scheme */
/**************************************************************/

/****************************/
/* CTE/QUERY TABLE APPROACH */
/****************************/

DBCC dropcleanbuffers;
CHECKPOINT
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

WITH MonthlyAccountBalances (
AcctYear,AcctMonth,CustId, PrtfNo, AcctNo, AcctName, AcctBalance
)
AS
(
SELECT YEAR(PostDate) AS AcctYear
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

 -- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***************************/
/* suggested missing index */
/***************************/

/*
Missing Index Details from ch07 - Analytical Queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APFinance (DESKTOP-CEBK38L\Angelo (53))
The Query Processor estimates that implementing the following index could improve the query cost by 40.1247%.
*/

/*
USE [APFinance]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Financial].[Account] ([CustId],[AcctName])
INCLUDE ([PrtfNo],[AcctNo],[AcctBalance],[PostDate])
GO
*/

DROP INDEX IF EXISTS [CustIdAcctPortfolioAcctNoBalPostDate]
ON [Financial].[Account] 
GO

CREATE NONCLUSTERED INDEX [CustIdAcctPortfolioAcctNoBalPostDate]
ON [Financial].[Account] ([CustId],[AcctName])
INCLUDE ([PrtfNo],[AcctNo],[AcctBalance],[PostDate])
GO

/*************************/
/* report table approach */
/*************************/

TRUNCATE TABLE Financial.MonthlyAccountAnalysis
GO

INSERT INTO Financial.MonthlyAccountAnalysis
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,SUM(AcctBalance) AS MonthlyBalance
FROM Financial.Account
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId
	,PrtfNo 
	,AcctNo
	,AcctName
ORDER BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId
	,PrtfNo 
	,AcctNo
	,AcctName
GO

DBCC dropcleanbuffers;
CHECKPOINT
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT CustId 
	,AcctYear
	,AcctMonth
	,AcctNo 
	,AcctName 
	,MonthlyBalance
	,PERCENTILE_DISC(.25) 
		WITHIN GROUP (ORDER BY MonthlyBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-25%]
	,PERCENTILE_DISC(.50) 
		WITHIN GROUP (ORDER BY MonthlyBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-50%]
	,PERCENTILE_DISC(.75) 
		WITHIN GROUP (ORDER BY MonthlyBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
		) AS [PercentDisc-75%]
	,PERCENTILE_DISC(.90) 
		WITHIN GROUP (ORDER BY MonthlyBalance)	
		OVER (
		PARTITION BY CustId,AcctYear
	) AS [PercentDisc-90%]
FROM Financial.MonthlyAccountAnalysis
WHERE Acctname = 'OPTION'
AND CustId = 'C0000001'
ORDER BY CustId 
	,AcctYear
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***************************************************/
/* Listing  7.16 – Create 5 Memory Enhanced Tables */
/***************************************************/

/*********************************/
/* CREATE MEMORY ENHANCED TABLES */
/*********************************/

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2011]
GO

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2011]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

	INDEX [ieMonthlyAcctBalanceMemory2011] NONCLUSTERED 
	(
	[CustId],
	[AcctYear],
	[AcctMonth],
	[PrtfNo],
	[AcctNo]
	)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2012]
GO

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2012]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

	INDEX [ieMonthlyAcctBalanceMemory2012] NONCLUSTERED 
	(
	[CustId],
	[AcctYear],
	[AcctMonth],
	[PrtfNo],
	[AcctNo]
	)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2013]
GO

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2013]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

	INDEX [ieMonthlyAcctBalanceMemory2013] NONCLUSTERED 
	(
	[CustId],
	[AcctYear],
	[AcctMonth],
	[PrtfNo],
	[AcctNo]
	)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2014]
GO

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2014]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

	INDEX [ieMonthlyAcctBalanceMemory2014] NONCLUSTERED 
	(
	[CustId],
	[AcctYear],
	[AcctMonth],
	[PrtfNo],
	[AcctNo]
	)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

DROP TABLE IF EXISTS [FinancialReports].[AccountMonthlyBalancesMem2015]
GO

CREATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2015]
(
	[AcctYear] [int] NULL,
	[AcctMonth] [int] NULL,
	[CustId] [varchar](8) NOT NULL,
	[PrtfNo] [varchar](8) NOT NULL,
	[AcctNo] [varchar](64) NOT NULL,
	[AcctName] [varchar](24) NOT NULL,
	[AcctBalance] [decimal](10, 2) NULL,

	INDEX [ieMonthlyAcctBalanceMemory2015] NONCLUSTERED 
	(
	[CustId],
	[AcctYear],
	[AcctMonth],
	[PrtfNo],
	[AcctNo]
	)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/*******************************/
/* LOAD MEMORY ENHANCED TABLES */
/*******************************/

TRUNCATE TABLE [FinancialReports].[AccountMonthlyBalancesMem2011]
GO

/***************************************************/
/* Listing  7.17 Load the 5 Memory Enhanced Tables */
/***************************************************/

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

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2012]
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,CONVERT(DECIMAL(10,2),SUM(AcctBalance)) AS AcctBalance
FROM Financial.Account
WHERE YEAR(PostDate) = 2012
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2013]
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,CONVERT(DECIMAL(10,2),SUM(AcctBalance)) AS AcctBalance
FROM Financial.Account
WHERE YEAR(PostDate) = 2013
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2014]
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,CONVERT(DECIMAL(10,2),SUM(AcctBalance)) AS AcctBalance
FROM Financial.Account
WHERE YEAR(PostDate) = 2014
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2015]
SELECT YEAR(PostDate) AS AcctYear
	,MONTH(PostDate) AS AcctMonth
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName 
	,CONVERT(DECIMAL(10,2),SUM(AcctBalance)) AS AcctBalance
FROM Financial.Account
WHERE YEAR(PostDate) = 2015
GROUP BY YEAR(PostDate)
	,MONTH(PostDate)
	,CustId 
	,PrtfNo 
	,AcctNo 
	,AcctName
GO

/*******************************************/
/* CREATE VIEW FROM MEMORY ENHANCED TABLES */
/*******************************************/

/************************************************************************/
/* Listing  7.19 – Account Balances Report from Memory Table Based View */
/************************************************************************/

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

/************************************************************************/
/* Listing  7.19 – Account Balances Report from Memory Table Based View */
/************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

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


SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

