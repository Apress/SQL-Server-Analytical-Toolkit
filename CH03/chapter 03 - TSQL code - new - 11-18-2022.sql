USE APSales
GO

-- Created by: Angelo R Bobak
-- Create Date: 08/04/22
-- Modified Date: 11/18/2022 

/*********************************************/
/* Chapter 3 - Sales Data Warehouse Use Case */
/* Analytical Functions                      */
/*********************************************/

/***********************************************/
/* customer product monthly sales for analysis */
/***********************************************/

-- run this query to examine the data

SELECT YEAR([CalendarDate]) AS SalesYear,
	MONTH([CalendarDate]) AS SalesMonth,
	[CustomerFullName],
    [ProductNo],
    SUM([TotalSalesAmount]) AS MonthlyProductSales
  FROM [APSales].[SalesReports].[YearlySalesReport]
GROUP BY YEAR([CalendarDate]),
	MONTH([CalendarDate]),
	[CustomerFullName],
    [ProductNo]
ORDER BY YEAR([CalendarDate]),
	MONTH([CalendarDate]),
	[CustomerFullName],
    [ProductNo]
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

/******************************/
/* Listing 3.1a - CUME_DIST() */
/******************************/ 

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
('JJJ',10);

/************************************/
/* Formula: CD = (NLT)/(N)           */
/* where N = number of rows in the   */
/* data set. NLT number of rows less */
/* than the current row value        */
/************************************/

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
	-- count of rows less thatn or equest to current row
	SELECT COUNT(*) AS RowCountLE FROM @CumDistDemo WHERE ColValue <= CDD.ColValue
	) A
CROSS APPLY (
	SELECT COUNT(*) AS TotalRows FROM @CumDistDemo
	) B
GO

/*****************************/
/* Listing 3.1b - CUME_DIST() */
/*****************************/ 

-- turn set statistics io/time on

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH CustSales (
SalesYear,SalesQuarter,SalesMonth,CustomerNo,StoreNo,CalendarDate,SalesTotal
)
AS
(
SELECT YEAR(CalendarDate) AS SalesYear
	,DATEPART(qq,CalendarDate) AS SalesQuarter
	,MONTH(CalendarDate) AS SalesMonth
	,ST.CustomerNo,
	ST.StoreNo,
	ST.CalendarDate,
	SUM(ST.UnitRetailPrice * ST.TransactionQuantity) AS SalesTotal
FROM StagingTable.SalesTransaction ST
GROUP BY ST.CustomerNo
	,ST.StoreNo
	,ST.CalendarDate
	,ST.UnitRetailPrice
	,ST.TransactionQuantity
)
SELECT SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
	,SUM(SalesTotal) AS MonthlySalesTotal
	,CUME_DIST() OVER (
		PARTITION BY SalesYear
		ORDER BY SUM(SalesTotal) 
	) AS CumeDist
FROM CustSales
WHERE SalesYear IN(2010,2011)
AND CustomerNo = 'C00000001'
GROUP BY SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/**********************************************************/
/* Try your own index strategy when using a staging table */
/**********************************************************/

SELECT YEAR(CalendarDate) AS SalesYear
	,DATEPART(qq,CalendarDate) AS SalesQuarter
	,MONTH(CalendarDate) AS SalesMonth
	,ST.CustomerNo,
	ST.StoreNo,
	ST.CalendarDate,
	(ST.UnitRetailPrice * ST.TransactionQuantity) AS SalesTotal
INTO TestCumDist
FROM StagingTable.SalesTransaction ST
GROUP BY ST.CustomerNo
	,ST.StoreNo
	,ST.CalendarDate
	,ST.UnitRetailPrice
	,ST.TransactionQuantity
GO

CREATE INDEX ieSalesDateCustStore ON StagingTable.SalesTransaction
(CalendarDate,CustomerNo,StoreNo) INCLUDE (UnitRetailPrice,TransactionQuantity)
GO

-- turn set statistics io/time on

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SELECT SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
	,SUM(SalesTotal) AS MonthlySalesTotal
	,CUME_DIST() OVER (
		PARTITION BY SalesYear
		ORDER BY SUM(SalesTotal) 
	) AS CumeDist
FROM TestCumDist
WHERE SalesYear IN(2010,2011)
AND CustomerNo = 'C00000001'
GROUP BY SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

CREATE NONCLUSTERED INDEX [CDCustYearQtrMonTotal>]
ON [dbo].[TestCumDist] ([CustomerNo],[SalesYear])
INCLUDE ([SalesQuarter],[SalesMonth],[SalesTotal])
GO

/**********************************************************/
/* Now run the query plan and query to check out statiscs */
/* against the prior query.                               */
/**********************************************************/

/************/
/* Clean Up */
/************/

DROP INDEX ieSalesDateCustStore ON StagingTable.SalesTransaction
GO

DROP INDEX [CDCustYearQtrMonTotal>] ON [dbo].[TestCumDist]
GO

DROP TABLE TestCumDist
GO


/********************************/
/* Listing 3.2 - PERCENT_RANK() */
/********************************/

/*********************************/
/* SIMPLE PERCENT_RANK() EXAMPLE */
/*********************************/

-- and introducing the rank() function

DECLARE @CumeDistDemo TABLE (
	Col1 VARCHAR(8),
	ColValue DECIMAL(10,2)
	);

INSERT INTO @CumeDistDemo VALUES
('AAA',1.0),
('BBB',2.0),
('CCC',3.0),
('DDD',4.0),
('EEE',5.0),
('FFF',6.0),
('GGG',7.0),
('HHH',8.0),
('III',9.0),
('JJJ',10.0)

SELECT Col1,ColValue,A.RowCountLT AS MyRank,
	ROW_NUMBER() OVER(
		ORDER BY ColValue 
	    ) AS RowNumberAsRank,

	RANK() OVER(
		ORDER BY ColValue
	    ) AS SQLRank,

	PERCENT_RANK() OVER(
		ORDER BY ColValue
	) AS PCTRank,

	/* current value rank - 1 /sample total row count - 1 */
	(RANK() OVER(
		ORDER BY ColValue
	    ) - 1.0) / CONVERT(DECIMAL(10,2),(SELECT COUNT(*) AS SampleRowCount FROM @CumeDistDemo) - 1.0) AS MyPctRank
FROM @CumeDistDemo CDD
CROSS APPLY (
	SELECT COUNT(*) AS RowCountLT FROM @CumeDistDemo WHERE ColValue <= CDD.ColValue
	) A
GO


/*********/
/* BONUS */
/*********/

DECLARE @CumeDistDemo TABLE (
	Col1 VARCHAR(8),
	ColValue DECIMAL(10,2)
	);

INSERT INTO @CumeDistDemo VALUES
('AAA',1.0),
('BBB',2.0),
('CCC',3.0),
('DDD',4.0),
('EEE',5.0),
('FFF',6.0),
('GGG',7.0),
('HHH',8.0),
('III',9.0),
('JJJ',10.0);

SELECT Col1,ColValue,A.RowCountLTE AS MyRank,
	ROW_NUMBER() OVER(
		ORDER BY ColValue
	    ) AS RowNumberAsRank,

	RANK() OVER(
		ORDER BY ColValue
	    ) AS SQLRank,

	FORMAT(
		PERCENT_RANK() OVER(
		ORDER BY ColValue
		),'P'
	) AS PCTRank,

	/* current value rank - 1 /sample total row count - 1 */
	FORMAT((RANK() OVER(
		ORDER BY ColValue
	    ) - 1.0) / 
			CONVERT(DECIMAL(10,2),(
				SELECT COUNT(*) AS SampleRowCount FROM @CumeDistDemo
					) - 1.0),'P') AS MyPctRank,

	/* current value rank - 1 /sample total row count - 1 */
	FORMAT(
	(RowCountLTE - 1.0) / 
			CONVERT(DECIMAL(10,2),(
				SELECT COUNT(*) AS SampleRowCount FROM @CumeDistDemo
					) - 1.0),'P') AS MyPctRank2
FROM @CumeDistDemo CDD
CROSS APPLY (
	SELECT COUNT(*) AS RowCountLTE FROM @CumeDistDemo WHERE ColValue <= CDD.ColValue
	) A
GO

/********************************/
/* Listing 3.3 - PERCENT_RANK() */
/********************************/

/************************/
/* BACK TO OUR SALES DW */
/************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH CustSales (
SalesYear,SalesQuarter,SalesMonth,CustomerNo,StoreNo,CalendarDate,SalesTotal
)
AS
(
SELECT YEAR(CalendarDate) AS SalesYear
	,DATEPART(qq,CalendarDate) AS SalesQuarter
	,MONTH(CalendarDate) AS SalesMonth
	,ST.CustomerNo,
	ST.StoreNo,
	ST.CalendarDate,
	SUM((ST.TotalSalesAmount)) AS SalesTotal
FROM StagingTable.SalesTransaction ST
GROUP BY ST.CustomerNo
	,ST.StoreNo
	,ST.CalendarDate
)

SELECT SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
	,SUM(SalesTotal) AS MonthlySalesTotal
	,CUME_DIST() OVER ( 
		PARTITION BY SalesYear
		ORDER BY SUM(SalesTotal) 
	) AS CumeDist
	,PERCENT_RANK() OVER (
		PARTITION BY SalesYear
		ORDER BY SUM(SalesTotal) 
	) AS PctRank
FROM CustSales
WHERE SalesYear IN(2010,2011)
AND CustomerNo = 'C00000001'
GROUP BY SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

-- index suggested by query plan

CREATE NONCLUSTERED INDEX ieCustomerStoreDateAmount
ON [StagingTable].[SalesTransaction] ([CustomerNo])
INCLUDE ([StoreNo],[CalendarDate],[TotalSalesAmount])
GO

/*******************/
/* MY PERCENT RANK */
/********************/

SELECT 
	SalesYear,
	SalesMonth,
	CustomerNo,
	FORMAT(SalesTotal,'C') AS SalesTotal,
	RANK()
		OVER (
--		PARTITION BY SalesYear
		ORDER BY SalesTotal
	) AS Rank,
	PERCENT_RANK()
		OVER (
--		PARTITION BY SalesYear
		ORDER BY SalesTotal
	)  AS PctRank,
	/* MyRank/total row count + 1 */
	MyRank,
	RowCountInSet,
	(MyRank - 1.0)/(RowCountInSet - 1.0) AS MyPctRank

FROM [SalesReports].[MemorySalesTotals] MS
CROSS APPLY (
	SELECT COUNT(*) + 1.0 AS MyRank
	FROM [SalesReports].[MemorySalesTotals] 
	WHERE SalesTotal < MS.SalesTotal
	AND SalesYear = 2011
	AND SalesMonth = 1
	AND CustomerNo  = 'C00000024'
	) A
CROSS APPLY (
	SELECT CONVERT(DECIMAL(10,2),COUNT(*) * 1.0) AS RowCountInSet
	FROM [SalesReports].[MemorySalesTotals] 
	WHERE SalesYear = 2011
	AND SalesMonth = 1
	AND CustomerNo  = 'C00000024'
	) B
WHERE SalesYear = 2011
AND SalesMonth = 1
AND CustomerNo  = 'C00000024'
GO

/**********************************************/
/* Listing 3.3 - FIRST_VALUE() & LAST_VALUE() */
/**********************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SELECT SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
	,SUM(SalesTotal) AS MonthlySalesTotal
	,FIRST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
	) AS SalesTotalFirstValue
	,LAST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
	) AS SalesTotalLastValue
	,FIRST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
	) -
	LAST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
	) AS Change
	,CASE
		WHEN (FIRST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
		) -
	LAST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
		)) > 0 THEN 'Sales Increase'
		WHEN (FIRST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
		) -
	LAST_VALUE(SUM(SalesTotal)) OVER (
		PARTITION BY SalesYear
		ORDER BY SalesMonth
		)) < 0 THEN 'Sales Decrease'
		ELSE 'No change'
	END AS [Sales Performance]
FROM [SalesReports].[MemorySalesTotals]
WHERE SalesYear IN(2010,2011)
AND CustomerNo = 'C00000001'
GROUP BY SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/*****************************************************************/
/* Try adding this index and rerun the estimated query plan tool */
/*****************************************************************/

ALTER TABLE [SalesReports].[MemorySalesTotals]
ADD INDEX ieSalesYearQuarterMonth(SalesYear,SalesQuarter,SalesMonth)
GO

/********************************/
/* Listing 3.4 - LAG() & LEAD() */
/********************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SELECT
	SalesYear,
	SalesQuarter,
	SalesMonth,
	StoreNo,
	ProductNo,
	CustomerNo,
	CalendarDate AS SalesDate,
	SalesTotal,
	LAG(SalesTotal) OVER (
		PARTITION BY SalesYear,CustomerNo,ProductNo
		ORDER BY SalesMonth,CustomerNo,ProductNo,CalendarDate
	) AS LastMonthlySales,

	LEAD(SalesTotal) OVER (
		PARTITION BY SalesYear,CustomerNo,ProductNo
		ORDER BY SalesMonth,CustomerNo,ProductNo,CalendarDate
	) AS NextMonthylSales

FROM [SalesReports].[MemorySalesTotals]
WHERE StoreNO = 'S00005' 
AND SalesYear = 2002
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/*******************/
/* Suggested Index */
/*******************/

USE [APSales]
GO
ALTER TABLE [SalesReports].[MemorySalesTotals]
ADD INDEX ieSalesYearStoreNo
NONCLUSTERED ([SalesYear],[StoreNo])
GO

/*********************************************************************************/
/* Try out the bonus queries below and run through the performance anaysis tools */
/* and techniques used in the chapter.                                           */
/*********************************************************************************/

/*********/
/* BONUS */
/*********/

WITH StoreYearlySales
(CalendarYear,CalendarMonth,StoreNo,StoreName,StoreTerritory,ProductName,MonthlySales)
AS
(
SELECT YEAR(CalendarDate),
	MONTH(CalendarDate),
	StoreNo,
	StoreName,
	StoreTerritory,
	ProductName,
	SUM(TotalSalesAmount) 
FROM SalesReports.YearlySalesReport
GROUP BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	StoreNo,
	StoreName,
	StoreTerritory,
	ProductName
/* for debugging
ORDER BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	StoreNo,
	StoreName,
	StoreTerritory
*/
) 

SELECT
	CalendarYear,
	CalendarMonth,
	StoreNo,
	StoreName,
	StoreTerritory,
	ProductName,
	MonthlySales,

	LAG(MonthlySales,11,0) OVER (
		PARTITION BY CalendarYear
		ORDER BY CalendarMonth
	) AS BOYSales
FROM StoreYearlySales
WHERE ProductName = 'Strawberry Tarts - Small'
AND StoreNAme = 'Chicago Store'
ORDER BY
	CalendarYear,
	CalendarMonth,
	StoreNo,
	StoreName,
	StoreTerritory
GO

/***********/
/* BONUS 2 */
/***********/

WITH StoreYearlySales
(CalendarYear,CalendarMonth,StoreNo,StoreName,StoreTerritory,ProductName,MonthlySales)
AS
(
SELECT YEAR(CalendarDate),
	MONTH(CalendarDate),
	StoreNo,
	StoreName,
	StoreTerritory,
	ProductName,
	SUM(TotalSalesAmount) 
FROM SalesReports.YearlySalesReport
GROUP BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	StoreNo,
	StoreName,
	StoreTerritory,
	ProductName
/* for debugging
ORDER BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	StoreNo,
	StoreName,
	StoreTerritory
*/
) 

SELECT
	CalendarYear,
	CalendarMonth,
	StoreNo,
	StoreName,
	StoreTerritory,
	ProductName,
	MonthlySales,

	-- within the year boundary only
	LEAD(MonthlySales,11,0) OVER (
		PARTITION BY CalendarYear
		ORDER BY CalendarMonth
	) AS EndOfYearSales,

	-- jumps year boundary
	LEAD(MonthlySales,12,0) OVER (
		ORDER BY CalendarYear,CalendarMonth
	) AS NextMonthSales

FROM StoreYearlySales
WHERE ProductName = 'Strawberry Tarts - Small'
AND StoreNAme = 'Chicago Store'
ORDER BY
	CalendarYear,
	CalendarMonth,
	StoreNo,
	StoreName,
	StoreTerritory
GO

/********************  EXAMPLE  ************************/
/* Listing 3.5 - PERCENTILE_CONT() & PERCENTILE_DISC() */
/********************  EXAMPLE  ************************/

DBCC dropcleanbuffers;
CHECKPOINT;
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO
 
DECLARE @ExampleValues TABLE (
	TestKey VARCHAR(8) NOT NULL,
	TheValue SMALLINT NOT NULL
	);

INSERT INTO @ExampleValues VALUES
('ONE',1),('TWO',2),('THREE',3),('FOUR',4),('SIX',6),('SEVEN',7),('EIGHT',8),('NINE',9),('TEN',10),('TWELVE',12);

SELECT
	TestKey,TheValue,
	PERCENTILE_CONT(.5) 
	WITHIN GROUP (ORDER BY TheValue)
	OVER() AS PctCont, -- continuous
	PERCENTILE_DISC(.5) 
	WITHIN GROUP (ORDER BY TheValue)
	OVER() AS PctDisc -- discrete
FROM @ExampleValues
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO


/*******************************************************/
/* Listing 3.6 - PERCENTILE_CONT() & PERCENTILE_DISC() */
/*******************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH StoreSalesAnalysis (
	SalesYear,SalesMonth,StoreNo,StoreName ,StoreTerritory,TotalSales
)
AS (
SELECT YEAR(CalendarDate) AS SalesYear
	  ,MONTH(CalendarDate) AS SalesMonth
      ,StoreNo
      ,StoreName
      ,StoreTerritory
      ,SUM(TotalSalesAmount) AS TotalSales
FROM APSales.SalesReports.YearlySalesReport
GROUP BY YEAR(CalendarDate)
	  ,MONTH(CalendarDate)
      ,StoreNo
      ,StoreName
      ,StoreTerritory
)

SELECT SalesYear,
	SalesMonth,
	StoreNo,
	StoreName,
	StoreTerritory,
	FORMAT(TotalSales,'C') AS TotalSales,
	FORMAT(PERCENTILE_CONT(.5) 
		WITHIN GROUP (ORDER BY TotalSales)
		OVER (
		PARTITION BY SalesYear
	    ) ,'C'
	) AS PctCont,
	FORMAT(PERCENTILE_DISC(.5) 
		WITHIN GROUP (ORDER BY TotalSales)
		OVER (
		PARTITION BY SalesYear
	    ) ,'C'
	) AS PctDisc
FROM StoreSalesAnalysis
WHERE SalesYear IN(2010,2011)
AND StoreNo = 'S00004'
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

DROP INDEX IF EXISTS [ieStoreTerritoryDateTotalSales] 
ON [SalesReports].[YearlySalesReport]
GO

CREATE NONCLUSTERED INDEX [ieStoreTerritoryDateTotalSales]
ON [SalesReports].[YearlySalesReport] ([StoreNo])
INCLUDE ([StoreName],[StoreTerritory],[CalendarDate],[TotalSalesAmount])
GO

/*********/
/* BONUS */
/*********/

WITH CustomerRanking (
	CalendarYear,CalendarMonth,CustomerFullName,TotalSales
	)
AS
(
SELECT YEAR(CalendarDate),
	MONTH(CalendarDate),
	CustomerFullName,
	SUM(TotalSalesAmount) AS TotalSales
FROM SalesReports.YearlySalesReport
GROUP BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	CustomerFullName
/* DEBUGGING 
ORDER BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	CustomerFullName
*/
)

SELECT 
	CalendarYear,
	CalendarMonth,
	CustomerFullName,
	FORMAT(TotalSales,'C') AS TotalSales,
	FORMAT(PERCENTILE_CONT(.25) 
		WITHIN GROUP (ORDER BY TotalSales)
		OVER (
		PARTITION BY CalendarYear,CalendarMonth
	    ) ,'C'
	) AS [PctCont %25],
	FORMAT(PERCENTILE_CONT(.50) 
		WITHIN GROUP (ORDER BY TotalSales)
		OVER (
		PARTITION BY CalendarYear,CalendarMonth
	    ) ,'C'
	) AS [PctCont %50],
	FORMAT(PERCENTILE_CONT(.75) 
		WITHIN GROUP (ORDER BY TotalSales)
		OVER (
		PARTITION BY CalendarYear,CalendarMonth
	    ) ,'C'
	) AS [PctCont %75]
FROM CustomerRanking
WHERE CalendarYear IN(2010,2011)
ORDER BY
	CalendarYear,
	CalendarMonth,
	CustomerFullName,
	TotalSales	
GO

/************************/
/* USING A REPORT TABLE */
/************************/

USE [APSales]
GO

-- create the report table

DROP TABLE IF EXISTS [SalesReports].[YearlySummaryReport]
GO

CREATE TABLE [SalesReports].[YearlySummaryReport](
	[SalesYear] [int] NULL,
	[SalesMonth] [int] NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL,
	[TotalSales] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO

-- load the report table

TRUNCATE TABLE APSales.SalesReports.YearlySummaryReport
GO

INSERT INTO APSales.SalesReports.YearlySummaryReport
SELECT YEAR(CalendarDate) AS SalesYear
	  ,MONTH(CalendarDate) AS SalesMonth
      ,StoreNo
      ,StoreName
      ,StoreTerritory
      ,SUM(TotalSalesAmount) AS TotalSales
FROM APSales.SalesReports.YearlySalesReport
GROUP BY YEAR(CalendarDate)
	  ,MONTH(CalendarDate)
      ,StoreNo
      ,StoreName
      ,StoreTerritory
GO

-- create supporting index

CREATE NONCLUSTERED INDEX [ieYearlySalesStoreTerritorySummary]
ON [SalesReports].[YearlySummaryReport] ([StoreNo],[SalesYear])
INCLUDE ([SalesMonth],[StoreName],[StoreTerritory],[TotalSales])
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS TIME ON
GO

SET STATISTICS IO ON
GO

-- run the modified query

UPDATE STATISTICS [SalesReports].[YearlySummaryReport]
GO

SELECT SalesYear,
	SalesMonth,
	StoreNo,
	StoreName,
	StoreTerritory,
	FORMAT(TotalSales,'C') AS TotalSales,
	FORMAT(PERCENTILE_CONT(.5) 
		WITHIN GROUP (ORDER BY TotalSales)
		OVER (
		PARTITION BY SalesYear
	    ) ,'C'
	) AS PctCont,
	FORMAT(PERCENTILE_DISC(.5) 
		WITHIN GROUP (ORDER BY TotalSales)
		OVER (
		PARTITION BY SalesYear
	    ) ,'C'
	) AS PctDisc
FROM APSales.SalesReports.YearlySummaryReport
WHERE SalesYear IN(2010,2011)
AND StoreNo = 'S00004'
GO

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO




