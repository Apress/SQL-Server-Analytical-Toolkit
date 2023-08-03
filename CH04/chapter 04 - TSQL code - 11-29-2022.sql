USE APSales
GO

-- Created by: Angelo R Bobak
-- Create Date: 08/04/22
-- Modified Date: 11/29/2022
-- added simple examples for each function
-- added gap and island example

/*********************************************/
/* Chapter 4 - Sales Data Warehouse Use Case */
/* Ranking/Window Functions                  */
/*********************************************/

/****************************/
/* Ranking/Window Functions */
/****************************/

/****************************************/
/* LISTING 4.1 - Simple Example for all */
/****************************************/

/*
RANK(),PERCENT_RANK(), ROW_NUMBER(),DENSE_RANK() AND NTILE()
*/

/***************/
/* two way tie */
/***************/


DECLARE @ExampleValues TABLE (
	TestKey VARCHAR(8) NOT NULL,
	TheValue SMALLINT NOT NULL
	);

INSERT INTO @ExampleValues VALUES
('ONE',1),('TWO',2),('THREE',3),('FOUR',4),('FOUR',4),('SIX',6),('SEVEN',7),('EIGHT',8),('NINE',9),('TEN',10);

SELECT
	TestKey,
	TheValue,
	ROW_NUMBER() OVER(ORDER BY TheValue) AS RowNo, 
	RANK() OVER(ORDER BY TheValue) AS ValueRank, 
	DENSE_RANK() OVER(ORDER BY TheValue) AS DenseRank, 
	PERCENT_RANK() OVER(ORDER BY TheValue) AS ValueRank,
	FORMAT(PERCENT_RANK() OVER(ORDER BY TheValue),'P') AS ValueRankAsPct 
FROM @ExampleValues;
GO

/***************************/
/* Here is another example */
/***************************/

/*****************/
/* three way tie */
/*****************/

DECLARE @ExampleValues TABLE (
	TestKey VARCHAR(8) NOT NULL,
	TheValue SMALLINT NOT NULL
	);

INSERT INTO @ExampleValues VALUES
('ONE',1),('TWO',2),('THREE',3),('FOUR',4),('FOUR',4),('FOUR',4),('SEVEN',7),('EIGHT',8),('NINE',9),('TEN',10);

SELECT
	TestKey,
	TheValue,
	ROW_NUMBER() OVER(ORDER BY TheValue) AS RowNo, 
	RANK() OVER(ORDER BY TheValue) AS ValueRank, 
	DENSE_RANK() OVER(ORDER BY TheValue) AS DenseRank, 
	PERCENT_RANK() OVER(ORDER BY TheValue) AS ValueRank,
	FORMAT(PERCENT_RANK() OVER(ORDER BY TheValue),'P') AS ValueRankAsPct 
FROM @ExampleValues;
GO

/****************/
/* four way tie */
/****************/

DECLARE @ExampleValues TABLE (
	TestKey VARCHAR(8) NOT NULL,
	TheValue SMALLINT NOT NULL
	);

INSERT INTO @ExampleValues VALUES
('ONE',1),('TWO',2),('THREE',3),('FOUR',4),('FOUR',4),('FOUR',4),('FOUR',4),('EIGHT',8),('NINE',9),('TEN',10);

SELECT
	TestKey,
	TheValue,
	ROW_NUMBER() OVER(ORDER BY TheValue) AS RowNo, 
	RANK() OVER(ORDER BY TheValue) AS ValueRank, 
	DENSE_RANK() OVER(ORDER BY TheValue) AS DenseRank, 
	PERCENT_RANK() OVER(ORDER BY TheValue) AS ValueRank,
	FORMAT(PERCENT_RANK() OVER(ORDER BY TheValue),'P') AS ValueRankAsPct 
FROM @ExampleValues;
GO

/******************************/
/* LISTING 4.2 - SIMPLE NTILE */
/******************************/

/***********/
/* NTILE() */
/***********/

-- 3 buckets with uneven set of rows

DECLARE @SalesPersonBonusStructure TABLE (
	SalesPersonNo VARCHAR(4) NOT NULL,
	SalesYtd MONEY NOT NULL
	);

INSERT INTO @SalesPersonBonusStructure VALUES
('S001',2500.00),
('S002',2250.00),
('S003',2000.00),
('S004',1950.00),
('S005',1800.00),
('S006',1750.00),
('S007',1700.00),
('S008',1500.00),
('S009',1250.00),
('S010',1000.00);

-- Care must be taken how you sort (ASC or DESC)

SELECT SalesPersonNo,
	SalesYtd,
	NTILE(3) OVER(ORDER BY SalesYtd DESC) AS BonusBucket,
	CASE
		WHEN (NTILE(3) OVER(ORDER BY SalesYtd DESC)) = 1 THEN 'Award $500.00 Bonus'
		WHEN (NTILE(3) OVER(ORDER BY SalesYtd DESC)) = 2 THEN 'Award $250.00 Bonus'
		WHEN (NTILE(3) OVER(ORDER BY SalesYtd DESC)) = 3 THEN 'Award $150.00 Bonus'
	END AS BonusAward
FROM @SalesPersonBonusStructure
GO

/***************/
/* Using a CTE */
/***************/

DECLARE @SalesPersonBonusStructure TABLE (
	SalesPersonNo VARCHAR(4) NOT NULL,
	SalesYtd MONEY NOT NULL
	);

INSERT INTO @SalesPersonBonusStructure VALUES
('S001',2500.00),
('S002',2250.00),
('S003',2000.00),
('S004',1950.00),
('S005',1800.00),
('S006',1750.00),
('S007',1700.00),
('S008',1500.00),
('S009',1250.00),
('S010',1000.00);

-- Care must be taken how you sort (ASC or DESC)

WITH TeamAwards (SalesPersonNo,SalesYTD,BonusBucket)
AS
(
SELECT SalesPersonNo,
	SalesYtd,
	NTILE(3) OVER(ORDER BY SalesYtd DESC) AS BonusBucket
	FROM @SalesPersonBonusStructure
)

SELECT SalesPersonNo,
	SalesYtd,
	BonusBucket,
	CASE
		WHEN BonusBucket = 1 THEN 'Award $500.00 Bonus'
		WHEN BonusBucket= 2 THEN 'Award $250.00 Bonus'
		WHEN BonusBucket= 3 THEN 'Award $150.00 Bonus'
	END AS BonusAward
FROM TeamAwards
GO

/*******************/
/* Another Example */
/*******************/

-- 4 buckets with even set of rows

DECLARE @SalesPersonBonusStructure TABLE (
	SalesPersonNo VARCHAR(4) NOT NULL,
	SalesYtd MONEY NOT NULL
	);

INSERT INTO @SalesPersonBonusStructure VALUES
('S001',2500.00),
('S002',2250.00),
('S003',2000.00),
('S004',1950.00),
('S005',1800.00),
('S006',1750.00),
('S007',1700.00),
('S008',1500.00),
('S009',1250.00),
('S010',1000.00),
('S011',1250.00),
('S012',1000.00);;

SELECT SalesPersonNo,
	SalesYtd,
	NTILE(4) OVER(ORDER BY SalesYtd DESC) AS BonusBucket,
	CASE
		WHEN (NTILE(4) OVER(ORDER BY SalesYtd DESC)) = 1 THEN 'Award $500.00 Bonus'
		WHEN (NTILE(4) OVER(ORDER BY SalesYtd DESC)) = 2 THEN 'Award $250.00 Bonus'
		WHEN (NTILE(4) OVER(ORDER BY SalesYtd DESC)) = 3 THEN 'Award $150.00 Bonus'
		WHEN (NTILE(4) OVER(ORDER BY SalesYtd DESC)) = 4 THEN 'Award $100.00 Bonus'
	END AS BonusAward
FROM @SalesPersonBonusStructure
GO

/******************************************/
/* LISTING 4.3 - RANK() VS PERCENT_RANK() */
/******************************************/

-- returns number of rows before current row + current row

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH CustomerRanking (
	CalendarYear,CalendarMonth,CustomerFullName,TotalSales
	)
AS
(
SELECT CalendarYear,
	CalendarMonth,
	CustomerFullName,
	SUM(TotalSalesAmount) AS TotalSales
FROM SalesReports.YearlySalesReport YSR
JOIN DimTable.Calendar C
ON YSR.CalendarDate = C.CalendarDate
GROUP BY C.CalendarYear,
	C.CalendarMonth,
	CustomerFullName
)

SELECT 
	CalendarYear,
	CalendarMonth,
	CustomerFullName,
	FORMAT(TotalSales,'C') AS TotalSales,
	RANK()
		OVER (
--		PARTITION BY CalendarYear
		ORDER BY TotalSales
	) AS Rank,
	PERCENT_RANK()
		OVER (
--		PARTITION BY CalendarYear
		ORDER BY TotalSales
	) * 100.00 AS PctRank
FROM CustomerRanking
WHERE CalendarYear = 2011
AND CalendarMonth = 1
ORDER BY
	RANK() OVER (
		PARTITION BY CalendarYear
		ORDER BY TotalSales
	) DESC
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/*
Missing Index Details from chapter 04 - TSQL code - 10-05-2022.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (52))
The Query Processor estimates that implementing the following index could improve the query cost by 97.7452%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [SalesReports].[YearlySalesReport] ([CalendarDate])
INCLUDE ([CustomerFullName],[TotalSalesAmount])
GO
*/ 

DROP INDEX [CalendarCustNameTotalSales]
ON [SalesReports]
GO

CREATE NONCLUSTERED INDEX [CalendarCustNameTotalSales]
ON [SalesReports].[YearlySalesReport] ([CalendarDate])
INCLUDE ([CustomerFullName],[TotalSalesAmount])
GO


/**************************************/
/* Create index on Calendar dimension */
/**************************************/

DROP INDEX IF EXISTS ieYearMonthDate ON DimTable.Calendar
GO

CREATE NONCLUSTERED INDEX ieYearMonthDate ON DimTable.Calendar
(
	CalendarYear,CalendarMonth,CalendarDate ASC
)WITH (
	PAD_INDEX = OFF, 
	STATISTICS_NORECOMPUTE = OFF, 
	SORT_IN_TEMPDB = OFF, 
	DROP_EXISTING = OFF, 
	ONLINE = OFF, 
	ALLOW_ROW_LOCKS = ON, 
	ALLOW_PAGE_LOCKS = ON, 
	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
	) ON AP_SALES_FG
GO


/****************************************/
/* LISTING 4.4 - RANK() vs DENSE_RANK() */
/*****************************************/

-- returns number of rows before current rows + current row with no gaps

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

-- need to add some duplicates

WITH CustomerRanking (
	CalendarYear,CalendarMonth,CustomerFullName,TotalSales
	)
AS
(
SELECT YEAR(CalendarDate),
	MONTH(CalendarDate),
	CustomerFullName,

	-- add one duplicate value on the fly
	CASE 
		WHEN CustomerFullName = 'Jim OConnel' THEN 17018.75
		ELSE SUM(TotalSalesAmount) 
	END AS TotalSales
FROM SalesReports.YearlySalesReport
GROUP BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	CustomerFullName
)

SELECT 
	CalendarYear,
	CalendarMonth,
	CustomerFullName,
	FORMAT(TotalSales,'C') AS TotalSales,
	RANK()
		OVER (
		ORDER BY TotalSales
	) AS Rank,
	DENSE_RANK()
		OVER (
		ORDER BY TotalSales
	) AS DenseRank
FROM CustomerRanking
WHERE CalendarYear = 2011
AND CalendarMonth = 1
ORDER BY
	DENSE_RANK() OVER (
		PARTITION BY CalendarYear
		ORDER BY TotalSales
	) DESC
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/******************************************/
/* BONUS - generate results for tow years */
/******************************************/

WITH CustomerRanking (
	CalendarYear,CalendarMonth,CustomerFullName,TotalSales
	)
AS
(
SELECT YEAR(CalendarDate),
	MONTH(CalendarDate),
	CustomerFullName,

	-- add one duplicate value on the fly
	CASE 
		WHEN CustomerFullName = 'Jim OConnel' THEN 17018.75
		ELSE SUM(TotalSalesAmount) 
	END AS TotalSales
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
	RANK()
		OVER (
		PARTITION BY CalendarYear
		ORDER BY TotalSales
	) AS Rank,
	DENSE_RANK()
		OVER (
		PARTITION BY CalendarYear
		ORDER BY TotalSales
	) AS DenseRank
FROM CustomerRanking
WHERE CalendarYear IN(2011,2012)
AND CalendarMonth = 1
ORDER BY
	DENSE_RANK() OVER (
		PARTITION BY CalendarYear
		ORDER BY TotalSales
	) DESC
GO


/*************************/
/* LISTING 4.5 - NTILE() */
/*************************/

DBCC dropcleanbuffers;
CHECKPOINT;

-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

/*********************************************/
/* Example: divide delinquent accounts among */
/* a number of collection anaysts by using   */
/* the values of 90 day delinquent accounts. */
/*********************************************/

DECLARE @NumTiles INT;

SELECT @NumTiles = COUNT(DISTINCT [90DaysLatePaymentCount])
FROM Demographics.CustomerPaymentHistory
WHERE [90DaysLatePaymentCount] > 0;

SELECT CreditYear,
	CreditQtr,
	CustomerNo, 
	CustomerFullName, 
	SUM([90DaysLatePaymentCount]) AS Total90DayDelinquent,
	NTILE(@NumTiles) OVER (
		PARTITION BY CreditYear,CreditQtr
		ORDER BY CreditQtr,CustomerNo
		) AS CreditAnaystBucket, 

	CASE NTILE(@NumTiles) OVER (
		PARTITION BY CreditYear,CreditQtr
		ORDER BY CreditQtr,CustomerNo
		)
		WHEN 1 THEN 'Assign to Collection Analyst 1'
		WHEN 2 THEN 'Assign to Collection Analyst 2'
		WHEN 3 THEN 'Assign to Collection Analyst 3'
		WHEN 4 THEN 'Assign to Collection Analyst 4'
		WHEN 5 THEN 'Assign to Collection Analyst 5'
	END AS CreditAnalystAssignment

FROM Demographics.CustomerPaymentHistory
WHERE [90DaysLatePaymentCount] > 0
GROUP BY CreditYear,
	CreditQtr,
	CustomerNo, 
	CustomerFullName 
ORDER BY  CreditYear,
	CreditQtr,
	CustomerNo,
	SUM([90DaysLatePaymentCount]) DESC
	GO


-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/******************************/
/* LISTING 4.6 - ROW_NUMBER() */
/******************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time on
 
SET STATISTICS TIME ON
GO

SET STATISTICS IO ON
GO

WITH StoreProductAnalysis
(TransYear,TransMonth,TransQtr,StoreNo,ProductNo,ProductsBought)
AS
(
SELECT
	YEAR(CalendarDate)  AS TransYear,
	MONTH(CalendarDate) AS TransMonth,
	DATEPART(qq,CalendarDate) AS TransQtr,
	StoreNo,
	ProductNo,
	SUM(TransactionQuantity) AS ProductsBought
FROM StagingTable.SalesTransaction
GROUP BY YEAR(CalendarDate),
		MONTH(CalendarDate),
		DATEPART(qq,CalendarDate),
		StoreNo,
		ProductNo
) 

SELECT
	spa.TransYear,
	spa.TransMonth,
	spa.StoreNo,
	spa.ProductNo,
--	p.ProductName,
	spa.ProductsBought,
	SUM(spa.ProductsBought) OVER(
		PARTITION BY spa.StoreNo,spa.TransYear
		ORDER BY spa.TransMonth
		) AS RunningTotal,
	ROW_NUMBER() OVER(
		PARTITION BY spa.StoreNo,spa.TransYear
		ORDER BY spa.TransMonth
		) AS EntryNoByMonth,
	ROW_NUMBER() OVER(
		PARTITION BY spa.StoreNo,spa.TransYear,TransQtr
		ORDER BY spa.TransMonth
		) AS EntryNoByQtr,
	ROW_NUMBER() OVER(
		ORDER BY spa.TransYear,spa.StoreNo
		) AS EntryNoByYear
FROM StoreProductAnalysis spa
JOIN DimTable.Product p
ON spa.ProductNo = p.ProductNo
WHERE spa.TransYear IN(2011,2012)
AND spa.StoreNo IN ('S00009','S00010')
AND spa.ProductNo = 'P00000011129'
/*
ORDER BY spa.StoreNo,
	spa.TransYear,
	spa.TransMonth,
	spa.ProductNo
*/
GO
-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/**************************/
/* Create suggested index */
/**************************/

DROP INDEX IF EXISTS eProductStoreSales ON StagingTable.SalesTransaction
GO

CREATE NONCLUSTERED INDEX ieProductStoreSales 
ON StagingTable.SalesTransaction(ProductNo,StoreNo) 
INCLUDE (CalendarDate,TransactionQuantity)
GO

/*******************************/
/* LISTING 4.7 - ISLAND & GAPS */
/*******************************/

/****************************************/
/* LISTING 4.a - LOADING THE TEST TABLE */
/****************************************/

/* 
The trick to this puzzle is to find out a way to generate so sort
of category names so we can use them in a group by clause to
extract the minimum start date and maximum end dates of the islands
or gaps.

In this scenario we are tracking whether or not a salesperson generated
sales over a 31 day period. Some sales amounts for set to zero for
1 or more days so these gaps in sales can be one day, two days or more.

Same can be said for the islands of days sales were generated.

Some first steps that need to occur:
Add a column to identify the start days of islands or gap
Add a column that will contain a unique number so for each set of islands and gap we
can generate category names for the group by that look something like this:
ISLAND1, ISLND2, etc.
GAP1,GAP2, etc.

Once these categories have bee correctly assigned to each row the start ad stop 
days are easily pulled out with the MIN()/MAX() aggregate functions.
*/

USE TEST
GO

/*****************************/
/* What sales islands exist? */
/* What sales gaps exist?    */
/*****************************/

DROP TABLE IF EXISTS SalesPersonLog
GO

CREATE TABLE SalesPersonLog (
	SalesPersonId VARCHAR(8),
	SalesDate     DATE,
	SalesAmount	  DECIMAL(10,2),
	IslandGapGroup VARCHAR(8)
	);

TRUNCATE TABLE SalesPersonLog
GO

INSERT INTO SalesPersonLog
SELECT 'SP001',
	[CalendarDate],
	UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
	)) AS SalesAmount,
	'ISLAND'
FROM APSales.[DimTable].[Calendar]
WHERE [CalendarYear] = 2010
AND [CalendarMonth] = 10
GO

/********************/
/* Set up some gaps */
/********************/

UPDATE SalesPersonLog
SET SalesAmount = 0,
IslandGapGroup = 'GAP'
WHERE SalesDate BETWEEN '2010-10-5' AND '2010-10-6'
GO

UPDATE SalesPersonLog
SET SalesAmount = 0,
IslandGapGroup = 'GAP'
WHERE SalesDate BETWEEN '2010-10-11' AND '2010-10-16'
GO

UPDATE SalesPersonLog
SET SalesAmount = 0,
IslandGapGroup = 'GAP'
WHERE SalesDate BETWEEN '2010-10-22' AND '2010-10-23'
GO

-- Just in case the random sales value generator
-- set sales to 0 but the update labelled it as an ISLAND

UPDATE SalesPersonLog
SET IslandGapGroup = 'GAP'
WHERE SalesAmount = 0
GO

SELECT * FROM SalesPersonLog
GO

/* OLD
SELECT SalesPersonId,GroupName,SUM(SalesAmount) AS TotalSales,
MIN(StartDate) AS StartDate,MAX(StartDate) AS EndDate,
CASE WHEN SUM(SalesAmount) <> 0 THEN 'Working, finally!' ELSE 'Goofing off again!'
END AS Reason
FROM (
	SELECT SalesPersonId,SalesAmount,
		IslandGapGroup + CONVERT(VARCHAR,(SUM(IslandGapStartFlag) 
			OVER(ORDER BY SalesDate) )) AS GroupName,
		SalesDate AS StartDate,PreviousSalesDate AS EndDate,
		SUM(IslandGapStartFlag) OVER(ORDER BY SalesDate) AS GroupId
	FROM
	(
		SELECT ROW_NUMBER() OVER(ORDER BY SalesDate) AS RowNumber,
			SalesPersonId,
			SalesAmount,
			IslandGapGroup ,
			SalesDate,
			LAG(SalesDate) OVER(ORDER BY SalesDate) AS PreviousSalesDate,
			CASE
				WHEN LAG(SalesDate) OVER(ORDER BY SalesDate) IS NULL
					OR (LAG(SalesAmount) OVER(ORDER BY SalesDate) <> 0
					AND SalesAmount = 0) THEN 1
				WHEN (LAG(SalesAmount) OVER(ORDER BY SalesDate) = 0
					AND SalesAmount <> 0) THEN 1
				ELSE 0 
			END AS IslandGapStartFlag,

			CASE
				WHEN LAG(SalesDate) OVER(ORDER BY SalesDate) IS NULL
					OR (LAG(SalesAmount) OVER(ORDER BY SalesDate) <> 0
					AND SalesAmount = 0) THEN ROW_NUMBER() OVER(ORDER BY SalesDate)
				WHEN (LAG(SalesAmount) OVER(ORDER BY SalesDate) = 0
					AND SalesAmount <> 0) THEN ROW_NUMBER() OVER(ORDER BY SalesDate)
				ELSE 0 
			END AS IslandGapGroupId
		FROM SalesPersonLog
	) T1
)T2
GROUP BY SalesPersonId,GroupName
ORDER BY StartDate
GO

*/

SELECT SalesPersonId,
	GroupName,
	SUM(SalesAmount) AS TotalSales,
	MIN(StartDate) AS StartDate,
	MAX(StartDate) AS EndDate,
	CASE 
		WHEN SUM(SalesAmount) <> 0 THEN 'Working, finally!' 
		ELSE 'Goofing off again!'
	END AS Reason
FROM (
	SELECT SalesPersonId,
		SalesAmount,
		IslandGapGroup + CONVERT(VARCHAR,(SUM(IslandGapGroupId) 
			OVER(ORDER BY StartDate) )) AS GroupName,
		StartDate,
		PreviousSalesDate AS EndDate
	FROM 
	(
		SELECT ROW_NUMBER() OVER(ORDER BY SalesDate) AS RowNumber,
			SalesPersonId,
			SalesAmount,
			IslandGapGroup,
			/* OR
			CASE WHEN SalesAmount = 0 THEN 'GAP'
				ELSE 'ISLAND'
			END AS IslandGapGroup,
			*/
			SalesDate AS StartDate,
			LAG(SalesDate) OVER(ORDER BY SalesDate) AS PreviousSalesDate,

			CASE
				WHEN LAG(SalesDate) OVER(ORDER BY SalesDate) IS NULL
					OR (LAG(SalesAmount) OVER(ORDER BY SalesDate) <> 0
					AND SalesAmount = 0) THEN ROW_NUMBER() OVER(ORDER BY SalesDate)
				WHEN (LAG(SalesAmount) OVER(ORDER BY SalesDate) = 0
					AND SalesAmount <> 0) THEN ROW_NUMBER() OVER(ORDER BY SalesDate)
				ELSE 0 
			END AS IslandGapGroupId
		FROM SalesPersonLog
	) T1
)T2
GROUP BY SalesPersonId,GroupName
ORDER BY StartDate
GO


