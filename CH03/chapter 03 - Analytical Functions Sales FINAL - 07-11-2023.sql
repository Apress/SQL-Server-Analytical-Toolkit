USE APSales
GO

/*********************************************/
/* Chapter 3 - Sales Data Warehouse Use Case */
/* Analytical Functions                      */
/*********************************************/

/*****************************************************/
/* Chapter 3 - Analytical Functions - Sales Database */
/* Created BY: Angelo R Bobak                        */
/* Created: 08/04/22                                 */
/* Revised: 07/11/2023                               */
/*****************************************************/

/*
• CUME_DIST()
• FIRST_VALUE()
• LAST_VALUE()
• LAG()
• LEAD()
• PERCENT_RANK()
• PERCENTILE_CONT()
• PERCENTILE_DISC()
*/

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

/************************************/
/* Listing  3.1a – a Simple Example */
/************************************/ 

/***************/
/* CUME_DIST() */
/***************/

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

/******************************************************/
/* Listing  3.1b – The CUME_DIST() function in action */
/******************************************************/ 

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

/******************/
/* PERCENT_RANK() */
/******************/

/************************************************/
/* Listing  3.2 – A Simple Percent Rank Example */
/************************************************/

DECLARE @CumeDistDemo TABLE (
	Col1     VARCHAR(8),
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

SELECT Col1,ColValue,A.RowCountLTE AS MyRank,
	RANK() OVER(
		ORDER BY ColValue
	    ) AS SQLRank,

	PERCENT_RANK() OVER(
		ORDER BY ColValue
	) AS PCTRank,

	/* current value rank - 1 /data sample total row count - 1 */
	(RANK() OVER(
		ORDER BY ColValue
	    ) - 1.0) / CONVERT(DECIMAL(10,2),(
SELECT COUNT(*) AS SampleRowCount 
FROM @CumeDistDemo) - 1.0
) AS MyPctRank
FROM @CumeDistDemo CDD
CROSS APPLY (
	SELECT COUNT(*) AS RowCountLTE FROM @CumeDistDemo 
WHERE ColValue <= CDD.ColValue
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

/********************************************************/
/* Listing  3.3 – The PERCENT_RANK() Function in Action */
/********************************************************/

/******************/
/* PERCENT_RANK() */
/******************/

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

/**************************/
/* MEMORY ENHANCED TABLES */
/**************************/

--Step 1: check compatibility level.

/********************************************/
/* Listing  3.4 – Check Compatibility Level */
/********************************************/

SELECT d.compatibility_level
FROM sys.databases as d
WHERE d.name = Db_Name();
GO


--Step 2: set parameter MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT to ON.

/***********************************************************/
/* Listing  3.5 – Set Memory Optimized Elevate to Snapshot */
/***********************************************************/

ALTER DATABASE [APSAles]
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
GO

--Step 3 -Next, add a dedicated file group for memory optimized data by running the
--following command.

/***********************************************************/
/* Listing  3.6 – Add File Group for Memory Optimized Data */
/***********************************************************/

ALTER DATABASE APSales
ADD FILEGROUP APSalesMemOptimized CONTAINS MEMORY_OPTIMIZED_DATA;
GO

-- Step 4: create a dedicated file for memory optimized tables. 

/***********************************************/
/* Listing  3.7 – Add a file to the file group */
/***********************************************/

ALTER DATABASE APSales 
ADD FILE (
name='APSalesMemoOptData', 
filename=N'D:\APRESS_DATABASES\AP_SALES\MEMORYOPT\AP_SALES_MEMOPT.mdf'
)
TO FILEGROUP APSAlesMemOptimized
GO

--Step 5: create the memory optimized table.

/************************************************/
/* Listing  3.8 – Create Memory Optimized Table */
/************************************************/

CREATE TABLE [SalesReports].[MemorySalesTotals](
	[SalesTotalKey] INTEGER NOT NULL IDENTITY PRIMARY KEY NONCLUSTERED,
	[SalesYear]    [int] NOT NULL,
	[SalesQuarter] [int] NOT NULL,
	[SalesMonth]   [int] NOT NULL,
	[CustomerNo]   [nvarchar](32)   NOT NULL,
	[StoreNo]      [nvarchar](32)   NULL,
	[CalendarDate] [date]           NOT NULL,
	[SalesTotal]   [decimal](21, 2) NULL
) 
WITH (
	MEMORY_OPTIMIZED = ON,
      DURABILITY = SCHEMA_AND_DATA
	);
GO

--Step 6: check that it was created.

/*****************************************************************/
/* Listing  3.9 – Check the Filegroups and Database_files Tables */
/*****************************************************************/
SELECT g.name, g.type_desc, f.physical_name
FROM sys.filegroups g JOIN sys.database_files f 
ON g.data_space_id = f.data_space_id
WHERE g.type = 'FX' AND f.type = 2
GO

--Step 7: Load the Memory Optimized Table.

/***************************************************/
/* Listing  3.10 – Load the Memory Optimized Table */
/***************************************************/

INSERT INTO [SalesReports].[MemorySalesTotals]
SELECT YEAR(CalendarDate)        AS SalesYear
	,DATEPART(qq,CalendarDate) AS SalesQuarter
	,MONTH(CalendarDate)       AS SalesMonth
	,ST.CustomerNo
,ST.StoreNo
,ST.CalendarDate
,SUM(ST.UnitRetailPrice * ST.TransactionQuantity) AS SalesTotal
FROM StagingTable.SalesTransaction ST
GROUP BY ST.CustomerNo
	,ST.StoreNo
	,ST.CalendarDate
	,ST.UnitRetailPrice
	,ST.TransactionQuantity
GO

--Step 8: Check estimated query plan.

--Step 9: Run the Query.

/****************************************************/
/* Listing  3.11 – Query the Memory Optimized Table */
/****************************************************/

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
	,PERCENT_RANK() OVER (
		PARTITION BY SalesYear
		ORDER BY SUM(SalesTotal) 
	) AS PctRank
FROM [SalesReports].[MemorySalesTotals]
WHERE SalesYear IN(2010,2011)
AND CustomerNo = 'C00000001'
GROUP BY SalesYear
	,SalesQuarter
	,SalesMonth
	,CustomerNo
GO

--Step 10: - create the suggested index.

/**********************************************/
/* Listing  3.12 – Create the Suggested Index */
/**********************************************/

ALTER TABLE SalesReports.MemorySalesTotals
ADD INDEX ieCustNoSaleYearMemTable
NONCLUSTERED (CustomerNo,SalesYear)
GO

--Step 11: - Create a Second Estimated Index Plan
--Step 12: - Re-run the query and make sure all statistics are turned on

/********************************/
/* FIRST_VALUE() & LAST_VALUE() */
/********************************/

/***********************************************************************/
/* Listing  3.13 – The FIRST_VALUE() & LAST_VALUE() Function in Action */
/***********************************************************************/

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

/******************/
/* LAG() & LEAD() */
/******************/

/*********************************************************/
/* Listing  3.14 – The LAG() & LEAD() Function in Action */
/*********************************************************/

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

/***************************************************************************/
/* Listing  3.16 The PERCENTILE_CONT()& PERCENTILE_DISC Function in Action */
/***************************************************************************/

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

/*****************************************/
/* PERCENTILE_CONT() & PERCENTILE_DISC() */
/*****************************************/

/***************************************************************/
/* Listing  3.17 – Percentile Continuous and Discrete Analysis */
/***************************************************************/

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

/***********************************/
/* Listing  3.18 – Suggested Index */
/***********************************/

/*
Missing Index Details from chapter 03 - TSQL code - new - 10-06-2022.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (52))
The Query Processor estimates that implementing the following index could improve the query cost by 87.5919%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [SalesReports].[YearlySalesReport] ([StoreNo])
INCLUDE ([StoreName],[StoreTerritory],[CalendarDate],[TotalSalesAmount])
GO
*/

CREATE NONCLUSTERED INDEX ieStoreTerritoryDateTotalSales 
ON [SalesReports].[YearlySalesReport] ([StoreNo])
INCLUDE ([StoreName],[StoreTerritory],[CalendarDate],[TotalSalesAmount])
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

/********************************************/
/* Listing  3.20 –Querying the Report Table */
/********************************************/

DBCC dropcleanbuffers
CHECKPOINT;
GO

SET STATISTICS TIME ON
GO

SET STATISTICS IO ON
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

/**************************************************/
/* Listing  3.21 – Index to Support Report Table. */
/**************************************************/

CREATE NONCLUSTERED INDEX [ieYearlySalesStoreTerritorySummary]
ON [SalesReports].[YearlySummaryReport] ([StoreNo],[SalesYear])
INCLUDE ([SalesMonth],[StoreName],[StoreTerritory],[TotalSales])
GO





