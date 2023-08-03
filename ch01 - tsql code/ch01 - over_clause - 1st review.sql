USE TEST
GO

/********************************************************/
/* Chapter 1 - Partitions, Frames and the OVER() Clause */
/* Created BY: Angelo R Bobak                           */
/* Created 08/14/2022                                   */
/* Revised 09/05/2022                                   */
/********************************************************/

/*******************************************************/
/* Listing 1.1 - SUM() function with the OVER() clause */
/*******************************************************/

USE TEST
GO

DROP TABLE IF EXISTS OverExample
GO

CREATE TABLE OverExample(
	OrderYear  SMALLINT,
	OrderMonth  SMALLINT,
	SalesAmount DECIMAL(10,2)
	);

TRUNCATE TABLE OverExample
GO

INSERT INTO OverExample VALUES
-- 2010
(2010,1,10000.00),
(2010,2,10000.00),
(2010,2,10000.00),
(2010,3,10000.00),
(2010,4,10000.00),
(2010,5,10000.00),
(2010,6,10000.00),
(2010,6,10000.00),
(2010,7,10000.00),
(2010,7,10000.00),
(2010,7,10000.00),
(2010,8,10000.00),
(2010,8,10000.00),
(2010,9,10000.00),
(2010,10,10000.00),
(2010,11,10000.00),
(2010,12,10000.00),
-- 2011
(2011,1,20000.00),
(2011,2,20000.00),
(2011,2,20000.00),
(2011,3,20000.00),
(2011,4,20000.00),
(2011,5,20000.00),
(2011,6,20000.00),
(2011,6,20000.00),
(2011,7,20000.00),
(2011,7,20000.00),
(2011,7,20000.00),
(2011,8,20000.00),
(2011,8,20000.00),
(2011,9,20000.00),
(2011,10,20000.00),
(2011,11,20000.00),
(2011,12,20000.00);
GO

SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER(
		PARTITION BY OrderYear
		ORDER BY OrderMonth ASC
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS AmountTotal
FROM OverExample
ORDER BY OrderYear,OrderMonth
GO

/*************************************************/
/* Listing 1.2 - SQL Server Named Window feature */
/*************************************************/

-- run in a SQL Server 2022 instance
-- do to Microsoft site to download and install eval license

USE TEST
GO

SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER SalesWindow AS SQPRangeUPCR
FROM OverExample
WINDOW SalesWindow AS (
		PARTITION BY OrderYear
		ORDER BY OrderMonth
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		);
GO

/*****************************************/
/* Listing 1.3 - Creating the test table */
/*****************************************/

CREATE TABLE #TestTable (
	Row SMALLINT,
	[Year]SMALLINT,
	[Month]SMALLINT,
	Amount DECIMAL(10,2)
	);

	INSERT INTO #TestTable VALUES
	-- 2010
	(1,2010,1,10),
	(2,2010,2,10),
	(3,2010,3,10),
	(4,2010,4,10),
	(5,2010,5,10), -- duplicates
	(6,2010,5,10), -- duplicates
	(7,2010,6,10),
	(8,2010,7,10),
	(9,2010,8,10),
	(10,2010,9,10),
	(11,2010,10,10),
	(12,2010,11,10),
	(13,2010,12,10),
	-- 2011
	(14,2011,1,10),
	(15,2011,2,10),
	(16,2011,3,10),
	(17,2011,4,10),
	(18,2011,5,10), -- duplicates
	(19,2011,5,10), -- duplicates
	(20,2011,6,10),
	(21,2011,7,10), -- duplicates
	(22,2011,7,10), -- duplicates
	(23,2011,7,10), -- duplicates
	(24,2011,8,10),
	(25,2011,9,10),
	(26,2011,10,10),
	(27,2011,11,10),
	(28,2011,12,10);
GO

/*************************************************/
/* Listing 1.4 - Range, row, unbounded following */
/*************************************************/

SELECT Row,[Year],[Month],Amount,
	SUM(Amount) OVER (
		PARTITION BY [Year]
		ORDER BY [Month]
		RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
		) AS RollingSalesTotal
	FROM #TestTable
ORDER BY [Year],[Month] ASC 
GO

DROP TABLE #TestTable
GO


/********************************************/
/* Listing 1.5 - Practice table OverExample */
/********************************************/

USE TEST
GO

DROP TABLE IF EXISTS OverExample
GO

CREATE TABLE OverExample(
	OrderYear  SMALLINT,
	OrderMonth  SMALLINT,
	SalesAmount DECIMAL(10,2)
	);

-- in case you need to reload it
TRUNCATE TABLE OverExample
GO

INSERT INTO OverExample VALUES
-- 2010
(2010,1,10000.00),
(2010,2,10000.00),
(2010,2,10000.00),
(2010,3,10000.00),
(2010,4,10000.00),
(2010,5,10000.00),
(2010,6,10000.00),
(2010,6,10000.00),
(2010,7,10000.00),
(2010,7,10000.00),
(2010,7,10000.00),
(2010,8,10000.00),
(2010,8,10000.00),
(2010,9,10000.00),
(2010,10,10000.00),
(2010,11,10000.00),
(2010,12,10000.00),
-- 2011
(2011,1,20000.00),
(2011,2,20000.00),
(2011,2,20000.00),
(2011,3,20000.00),
(2011,4,20000.00),
(2011,5,20000.00),
(2011,6,20000.00),
(2011,6,20000.00),
(2011,7,20000.00),
(2011,7,20000.00),
(2011,7,20000.00),
(2011,8,20000.00),
(2011,8,20000.00),
(2011,9,20000.00),
(2011,10,20000.00),
(2011,11,20000.00),
(2011,12,20000.00);
GO

SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER(
		PARTITION BY OrderYear
		ORDER BY OrderMonth ASC
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS AmountTotal
FROM OverExample
ORDER BY OrderYear,OrderMonth
GO

/****************************/
/* Listing 1.6 - scenario 1 */
/****************************/

SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER (
		-- default widow frame:
	    -- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS NPBNOB,
	SUM(SalesAmount) OVER (
		PARTITION BY OrderYear
		-- default widow frame:
		-- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS PBNOB,
	SUM(SalesAmount) OVER (
		PARTITION BY OrderYear
		ORDER BY OrderMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

		-- default window frame (we overrode it!)
		-- RANGE BETWEEN UNBOUNDED PRECEDDING AND CURRENT ROW
		) AS PBOBUPUF	
FROM OverExample;
GO

/**************************************************************************/
/* Listing 1.7 - Scenario 2 - various default versus window frame clauses */
/**************************************************************************/

SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER (
		ORDER BY OrderYear,OrderMonth
		) AS NPBOB,

	-- sames as PBOBRangeUPCR
	SUM(SalesAmount) OVER (
	    PARTITION BY OrderYear
		ORDER BY OrderMonth
		) AS PBOB,

	SUM(SalesAmount) OVER (
		ORDER BY OrderYear,OrderMonth
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS NPBOBRangeUPCR,

	-- same as PBOB
	SUM(SalesAmount) OVER (
		PARTITION BY OrderYear
		ORDER BY OrderMonth
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS PBOBRangeUPCR
FROM OverExample;
GO

/**********************************************/
/* Listing 1.8 - ROWS versus RANGE comparison */
/**********************************************/

SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER (
		PARTITION BY OrderYear
		ORDER BY OrderMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS POBRowsUPCR,
	
	SUM(SalesAmount) OVER (
		PARTITION BY OrderYear
		ORDER BY OrderMonth
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS PBOBRangeUPCR
FROM OverExample;
GO


/***********************************/
/* Listing 1.9a - without subquery */
/***********************************/

-- create and load test table

USE TEST
GO

DROP TABLE IF EXISTS TestSales 
GO

CREATE TABLE TestSales (
	SalesYear SMALLINT,
	SalesQtr  SMALLINT,
	SalesMonth SMALLINT,
	SalesTotal DECIMAL(10,2)
	);

INSERT INTO TestSales VALUES
(2010,1,1,100.00),
(2010,1,2,100.00),
(2010,1,3,100.00),
(2010,2,4,100.00),
(2010,2,5,100.00),
(2010,2,6,100.00),
(2010,3,7,100.00),
(2010,3,8,100.00),
(2010,3,9,100.00),
(2010,4,10,100.00),
(2010,4,11,100.00),
(2010,4,12,100.00),
(2011,1,1,100.00),
(2011,1,2,100.00),
(2011,1,3,100.00),
(2011,2,4,100.00),
(2011,2,5,100.00),
(2011,2,6,100.00),
(2011,3,7,100.00),
(2011,3,8,100.00),
(2011,3,9,100.00),
(2011,4,10,100.00),
(2011,4,11,100.00),
(2011,4,12,100.00);
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

/**********************************************/
/* This has a Sort Step in plan with 77% cost */
/**********************************************/

WITH YearQtrSales (
	SalesYear,
	SalesQtr,
	SalesMonth, 
	SalesTotal
)
AS
(
SELECT
    SalesYear,
	SalesQtr,
	SalesMonth, 
	SalesTotal
FROM dbo.TestSales
)

SELECT
	SalesYear, 
	SalesQtr, 
	SalesMonth, 
	SalesTotal,
	SUM(SalesTotal) OVER(
		ORDER BY SalesYear,SalesQtr,SalesMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
		) AS RollMonthlySales1
	
FROM YearQtrSales
ORDER BY
	SalesYear, 
	SalesQtr, 
	SalesMonth
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

/********************************/
/* Listing 1.9b - with subquery */
/********************************/

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

/**********************************/
/* This does not have a sort step */
/**********************************/

WITH YearQtrSales (
	SalesYear,
	SalesQtr,
	SalesMonth, 
	SalesTotal
)
AS
(
SELECT
	SalesYear,
	SalesQtr,
	SalesMonth, 
	SalesTotal
FROM dbo.TestSales
)

SELECT
	SalesYear, 
	SalesQtr, 
	SalesMonth, 
	SalesTotal,
	SUM(SalesTotal) OVER(
		ORDER BY (SELECT (1))
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
		) AS RollMonthlySales2
	
FROM YearQtrSales
ORDER BY
	SalesYear, 
	SalesQtr, 
	SalesMonth
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

/************************************************/
/* Listing 1.10 - NAMED WINDOWS SQL SERVER 2022 */
/************************************************/

-- this will only work on the latest 2022 version
-- of SQL Server

USE TEST
GO

SELECT OrderYear
      ,OrderMonth
      ,SUM(SalesAmount) OVER SalesWindow AS TotalSales
FROM dbo.OverExample
WINDOW SalesWindow AS (
	PARTITION BY OrderYear
	ORDER BY OrderMonth
	)
GO

-- also new
SELECT [OrderYear]
      ,[OrderMonth]
	  ,[SalesAmount]
	  ,APPROX_COUNT_DISTINCT([SalesAmount]) AS ACD
      ,APPROX_PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY SalesAmount) AS [APC .5]
	  ,APPROX_PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY CONVERT(INT,SalesAmount)) AS [APD .5]
FROM [Test].[dbo].[OverExample]
GROUP BY [OrderYear]
      ,[OrderMonth]
	  ,[SalesAmount]
ORDER BY [OrderYear]
      ,[OrderMonth]
	  ,[SalesAmount]
GO





