
/****************************************************/
/* Chapter 2 - Aggregate Functions - Sales Database */
/* Created BY: Angelo R Bobak                       */
/* Created: 08/04/22                                */
/* Revised: 07/20/2023                              */
/* Production                                       */
/****************************************************/

/***********************/
/* Aggregate Functions */
/***********************/

/*
•	COUNT()
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

USE [APSales]
GO

/**********************************/
/* Listing  2.1 – Suggested Index */
/**********************************/

/*
Missing Index Details from chapter 02 - TSQL code - 09-08-2022.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (63))
The Query Processor estimates that implementing the following index could improve the query cost by 96.4491%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [StagingTable].[SalesTransaction] ([ProductNo])
INCLUDE ([CustomerNo],[StoreNo],[CalendarDate])
GO
*/

/***********************************/
/* COUNT(),MAX(),MIN(),AVG(),SUM() */
/***********************************/

/********************************************/
/* Listing 2.2 - Basic Sales Profile Report */
/********************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SELECT YEAR(CalendarDate) AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	StoreNo,
	ProductNo,
	ProductName,
	COUNT(*) AS NumTransactions,
	MIN(TransactionQuantity) AS MinQuantity,
	MAX(TransactionQuantity) AS MaxQuantity,
	AVG(TransactionQuantity) AS AvgQuantity,
	SUM(TransactionQuantity) AS SumQuantity
FROM SalesReports.YearlySalesReport
WHERE StoreNo = 'S00001'
AND ProductNo = 'P00000022216'
AND YEAR(CalendarDate) = 2010
GROUP BY YEAR(CalendarDate),
	 MONTH(CalendarDate),
	StoreNo,
	ProductNo,
	ProductName
ORDER BY YEAR(CalendarDate),
	 MONTH(CalendarDate),
	StoreNo,
	ProductNo,
	ProductName
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/******************************/
/* Query Plan suggested index */
/******************************/

/*
Missing Index Details from chapter 02 - TSQL code - 09-13-2022 Revised and Shortened.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (55))
The Query Processor estimates that implementing the following index could improve the query cost by 98.9739%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [SalesReports].[YearlySalesReport] ([ProductNo],[StoreNo])
INCLUDE ([ProductName],[CalendarDate],[TransactionQuantity])
GO
*/

-- filling in the names, etc.

DROP INDEX IF EXISTS  ieProductStoreDate
ON SalesReports.YearlySalesReport
GO

CREATE NONCLUSTERED INDEX [ieProductStoreDate]
ON [SalesReports].[YearlySalesReport] ([ProductNo],[StoreNo])
INCLUDE ([ProductName],[CalendarDate],[TransactionQuantity])
GO

/******************************/
/* Listing 2.3 - Using OVER() */
/******************************/

DBCC dropcleanbuffers;
CHECKPOINT;
 
-- turn set statistics io/time on

SET STATISTICS TIME ON
GO

SET STATISTICS IO ON
GO

-- Part 1 the CTE

WITH ProductPurchaseAnaysis (
	PurchaseYear,PurchaseMonth,CalendarDate,StoreNo,CustomerFullName,ProductNo,ItemsPurchased,NumTransactions
)
AS (
SELECT YEAR(CalendarDate) AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	CalendarDate,
	StoreNo,
	CustomerFullName,
	ProductNo,
	TransactionQuantity AS ItemsPurchased,
	COUNT(*) AS NumTransactions
FROM SalesReports.YearlySalesReport
GROUP BY YEAR(CalendarDate) ,
	MONTH(CalendarDate),
	CalendarDate,
	StoreNo,
	CustomerFullName,
	ProductNo,
	ProductName,
	TransactionQuantity
)

/**************************************************/
/* Listing  2.4 – Part 2 – Using Window Functions */
/**************************************************/

SELECT PurchaseYear,PurchaseMonth,CalendarDate,StoreNo,
	CustomerFullName,ProductNo,NumTransactions,
	SUM(NumTransactions) OVER (
		PARTITION BY PurchaseYear,CustomerFullName
		ORDER BY CustomerFullName,PurchaseMonth
	) AS SumTransactions,ItemsPurchased,
	SUM(ItemsPurchased) OVER (
		PARTITION BY PurchaseYear,CustomerFullName
		ORDER BY CustomerFullName,PurchaseMonth
	) AS TotalItems,
	AVG(CONVERT(DECIMAL(10,2),ItemsPurchased)) OVER (
		PARTITION BY PurchaseYear,CustomerFullName
		ORDER BY CustomerFullName,PurchaseMonth
	) AS AvgPurchases,
	MIN(ItemsPurchased) OVER (
		PARTITION BY PurchaseYear,CustomerFullName
		ORDER BY CustomerFullName,PurchaseMonth
	) AS MinPurchases,
	MAX(ItemsPurchased) OVER (
		PARTITION BY PurchaseYear,CustomerFullName
		ORDER BY CustomerFullName,PurchaseMonth
	) AS MaxPurchases
FROM ProductPurchaseAnaysis
WHERE StoreNo = 'S00001'
AND ProductNo = 'P00000022216'
AND PurchaseYear = 2010
AND PurchaseMonth = 1
AND ItemsPurchased > 0
GROUP BY PurchaseYear,PurchaseMonth,CalendarDate,StoreNo,
	CustomerFullName,ProductNo,NumTransactions,ItemsPurchased
ORDER BY CustomerFullName,PurchaseYear,PurchaseMonth,CalendarDate,StoreNo,
	ProductNo,ItemsPurchased
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/*******************/
/* Suggested Index */
/*******************/

/*
Missing Index Details from chapter 02 - TSQL code - 09-13-2022 Revised and Shortened.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (56))
The Query Processor estimates that implementing the following index could improve the query cost by 98.6555%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [SalesReports].[YearlySalesReport] ([ProductNo],[StoreNo],[TransactionQuantity])
INCLUDE ([CustomerFullName],[ProductName],[CalendarDate])
GO
*/

DROP INDEX IF EXISTS [ieProductDateTransQty]
ON [SalesReports].[YearlySalesReport]
GO

CREATE NONCLUSTERED INDEX [ieProductDateTransQty]
ON [SalesReports].[YearlySalesReport] ([ProductNo],[StoreNo],[TransactionQuantity])
INCLUDE ([CustomerFullName],[ProductName],[CalendarDate])
GO

/*********************************************/
/* Listing  2.5 – Generating a Rollup Report */
/*********************************************/

/************/
/* GROUPING */
/************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH StoreProductSalesAnalysis
(TransYear,TransQuarter,TransMonth,TransDate,StoreNo,ProductNo,MonthlySales)
AS
(
SELECT
	YEAR(CalendarDate)        AS TransYear,
	DATEPART(qq,CalendarDate) AS TransQuarter,
	MONTH(CalendarDate)       AS TransMonth,
	CalendarDate              AS TransDate,
	StoreNo,
	ProductNo,
	SUM(TotalSalesAmount)     AS MonthlySales
FROM SalesReports.YearlySalesReport
WHERE YEAR(CalendarDate) = 2011
GROUP BY
	CalendarDate,
	StoreNo,
	ProductNo
/* DEBUG 
ORDER BY YEAR(CalendarDate),
		MONTH(CalendarDate),
		StoreNo,
		ProductNo
*/
) 

SELECT TransYear,
	TransQuarter,
	TransMonth,
	StoreNo,
	ProductNo,
	MonthlySales,
	SUM(MonthlySales) AS SumMonthlySales,
	GROUPING(MonthlySales) AS RollupFlag
FROM StoreProductSalesAnalysis
WHERE TransYear = 2011
AND ProductNo = 'P00000022216'
AND StoreNo = 'S00001'
GROUP BY TransYear,
	TransQuarter,
	TransMonth,
	StoreNo,
	ProductNo,
	MonthlySales WITH ROLLUP
ORDER BY TransYear,
	TransQuarter,
	TransMonth,
	StoreNo,
	ProductNo, 
		(
		CASE	
			WHEN MonthlySales IS NULL THEN 0
		END
	   ) DESC,
	GROUPING(MonthlySales) DESC
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/**************************************/
/* Listing  2.6 – suggested new index */
/**************************************/

/*
Missing Index Details from chapter 02 - TSQL code - 09-13-2022 Revised and Shortened.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (55))
The Query Processor estimates that implementing the following index could improve the query cost by 98.1615%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [SalesReports].[YearlySalesReport] ([ProductNo],[StoreNo])
INCLUDE ([CalendarDate],[TotalSalesAmount])
GO
*/

DROP INDEX IF EXISTS [ieProductNoStoreNoDateTotalSalesAmt]
ON [SalesReports].[YearlySalesReport]
GO

CREATE NONCLUSTERED INDEX [ieProductNoStoreNoDateTotalSalesAmt]
ON [SalesReports].[YearlySalesReport] ([ProductNo],[StoreNo])
INCLUDE ([CalendarDate],[TotalSalesAmount])
GO

/****************************************************/
/* Listing  2.7 – Product Report using STRING_AGG() */
/****************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH CustomerPurchaseAnalysis(PurchaseYear,PurchaseMonth,CustomerNo,ProductNo,PurchaseCount)
AS
(
SELECT DISTINCT
	YEAR(CalendarDate)  AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	CustomerNo,
	ProductNo,
	COUNT(*) AS PurchaseCount
FROM StagingTable.SalesTransaction
GROUP BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	CustomerNo,
	ProductNo
)

SELECT
	PurchaseYear,
	PurchaseMonth,
	CustomerNo,
	STRING_AGG(ProductNo,',') AS ItemsPurchased,
	COUNT(PurchaseCount) AS PurchaseCount
FROM CustomerPurchaseAnalysis
WHERE CustomerNo = 'C00000008'
GROUP BY
	PurchaseYear,
	PurchaseMonth,
	CustomerNo
ORDER BY CustomerNo,
	PurchaseYear,
	PurchaseMonth
GO

/* Validate with:

SELECT DISTINCT
	YEAR(CalendarDate)  AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	CalendarDate,
	CustomerNo,
	ProductNo,
	COUNT(*) AS PurchaseCount
FROM StagingTable.SalesTransaction
WHERE CustomerNo = 'C00000008'
GROUP BY YEAR(CalendarDate),
	MONTH(CalendarDate),
	CalendarDate,
	CustomerNo,
	ProductNo
ORDER BY
	YEAR(CalendarDate),
	MONTH(CalendarDate),
	CalendarDate,
	CustomerNo,
	ProductNo
	GO
*/


-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/*
Missing Index Details from chapter 02 - TSQL code - 09-13-2022 Revised and Shortened.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (55))
The Query Processor estimates that implementing the following index could improve the query cost by 90.0418%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [StagingTable].[SalesTransaction] ([CustomerNo])
INCLUDE ([CalendarDate],[ProductNo])
GO
*/

DROP INDEX IF EXISTS ieCustomerNoDateProductNo
ON [StagingTable].[SalesTransaction]
GO

CREATE NONCLUSTERED INDEX ieCustomerNoDateProductNo
ON [StagingTable].[SalesTransaction] ([CustomerNo])
INCLUDE ([CalendarDate],[ProductNo])
GO

/*****************************************************/
/* Listing  2.8 – Standard Deviation Sales Analysis  */
/*****************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH CustomerPurchaseAnalysis
(PurchaseYear,PurchaseMonth,StoreNo,ProductNo,CustomerNo,TotalSalesAmount)
AS
(
SELECT
	YEAR(CalendarDate)  AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	StoreNo,
	ProductNo,
	CustomerNo,
	SUM(TransactionQuantity * UnitRetailPrice) AS TotalSalesAmount
FROM StagingTable.SalesTransaction
GROUP BY YEAR(CalendarDate),MONTH(CalendarDate),ProductNo,CustomerNo,StoreNo
) 

SELECT
	cpa.PurchaseYear,
	cpa.PurchaseMonth,
	cpa.StoreNo,
	cpa.ProductNo,
	c.CustomerNo,
	CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount) AS TotalSalesAmount,
	AVG(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
	/****************************************************************************************/
	/* Uncomment below in case you want to generate results for multiple customers and year */
	/****************************************************************************************/

	--PARTITION BY cpa.PurchaseYear,c.CustomerNo

	ORDER BY cpa.PurchaseYear,c.CustomerNo
		) AS AvgPurchaseCount,
	STDEV(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		ORDER BY cpa.PurchaseMonth
		) AS StdevTotalSales1,
	STDEVP(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		ORDER BY cpa.PurchaseMonth
		) AS StdevpTotalSales2,
	STDEV(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		) AS StdevTotalSales3,
	STDEVP(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		) AS StdevpYearTotalSales4
FROM CustomerPurchaseAnalysis cpa
JOIN DimTable.Customer c
ON cpa.CustomerNo = c.CustomerNo
WHERE cpa.CustomerNo = 'C00000008'
AND PurchaseYear = 2011
AND ProductNo = 'P00000038114';
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/*********************************************************/
/* Listing  2.9 – Estimated Query Plan - Suggested Index */
/*********************************************************/

/*
Missing Index Details from chapter 02 - TSQL code - 09-08-2022.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (59))
The Query Processor estimates that implementing the following index could improve the query cost by 94.2844%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [StagingTable].[SalesTransaction] ([CustomerNo],[ProductNo])
INCLUDE ([StoreNo],[CalendarDate],[TransactionQuantity],[UnitRetailPrice])
GO
*/

/* Copy code from above and paste and supply name */

DROP INDEX IF EXISTS [CustNoProdNoStoreNoDateQtyPrice]
ON [StagingTable].[SalesTransaction]
GO

CREATE NONCLUSTERED INDEX [CustNoProdNoStoreNoDateQtyPrice]
ON [StagingTable].[SalesTransaction] ([CustomerNo],[ProductNo])
INCLUDE ([StoreNo],[CalendarDate],[TransactionQuantity],[UnitRetailPrice])
GO

/**********************************************/
/* Sample statistics before index was created */
/**********************************************/

/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(11 rows affected)
Table 'Worktable'. Scan count 17, logical reads 124, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Customer'. Scan count 1, logical reads 198, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'SalesTransaction'. Scan count 1, logical reads 704, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 4 ms.

Completion time: 2022-09-27T14:58:39.1310953-04:00
*/

/*********************************************/
/* Sample statistics after index was created */
/*********************************************/

/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(11 rows affected)
Table 'Worktable'. Scan count 17, logical reads 124, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Customer'. Scan count 1, logical reads 198, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'SalesTransaction'. Scan count 1, logical reads 6, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 1 ms.
*/

/**********************************************/
/* Listing  2.10 – Calculating Sales Variance */
/**********************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

WITH CustomerPurchaseAnalysis
(PurchaseYear,PurchaseMonth,StoreNo,ProductNo,CustomerNo,TotalSalesAmount)
AS
(
SELECT
	YEAR(CalendarDate)  AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	StoreNo,
	ProductNo,
	CustomerNo,
	SUM(TransactionQuantity * UnitRetailPrice) AS TotalSalesAmount
FROM StagingTable.SalesTransaction
GROUP BY YEAR(CalendarDate),MONTH(CalendarDate),ProductNo,CustomerNo,StoreNo
) 

SELECT
	cpa.PurchaseYear,
	cpa.PurchaseMonth,
	cpa.StoreNo,
--	cpa.ProductNo,
--	c.CustomerNo,
--	c.CustomerFullName,
	CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount) AS TotalSalesAmount,
	AVG(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		ORDER BY cpa.PurchaseMonth
		) AS AvgPurchaseCount,
	VAR(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		ORDER BY cpa.PurchaseMonth
		) AS VarTotalSales,
	VARP(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		ORDER BY cpa.PurchaseMonth
		) AS VarpTotalSales,
	VAR(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		) AS VarYearTotalSales,
	VARP(CONVERT(DECIMAL(10,2),cpa.TotalSalesAmount)) OVER(
		) AS VarpYearTotalSales
FROM CustomerPurchaseAnalysis cpa
JOIN DimTable.Customer c
ON cpa.CustomerNo = c.CustomerNo
WHERE cpa.CustomerNo = 'C00000008'
AND PurchaseYear = 2011
AND ProductNo = 'P00000038114';
GO

-- turn set statistics io/time off

SET STATISTICS TIME OFF
GO

SET STATISTICS IO OFF
GO

/******************************************************/
/* Listing  2.11 – Average by Year,Month and Customer */
/******************************************************/

WITH CustomerPurchaseAnalysis
(PurchaseYear,PurchaseMonth,CustomerNo,TotalSalesAmount)
AS
(
SELECT
	YEAR(CalendarDate)  AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	CustomerNo,
	SUM(TransactionQuantity * UnitRetailPrice) AS TotalSalesAmount
FROM StagingTable.SalesTransaction
GROUP BY YEAR(CalendarDate),MONTH(CalendarDate),CustomerNo
) 

SELECT
	cpa.PurchaseYear,
	cpa.PurchaseMonth,
	c.CustomerNo,
	c.CustomerFullName,
	cpa.TotalSalesAmount,

	AVG(cpa.TotalSalesAmount) OVER SalesWindow AS AvgTotalSales
FROM CustomerPurchaseAnalysis cpa
JOIN DimTable.Customer c
ON cpa.CustomerNo = c.CustomerNo
WHERE cpa.CustomerNo = 'C00000008'
WINDOW SalesWindow AS (
		PARTITION BY cpa.PurchaseYear
		ORDER BY cpa.PurchaseYear ASC,cpa.PurchaseMonth ASC
		) 
GO

/***********************************/
/* Listing  2.12 – Suggested Index */
/***********************************/

/*
Missing Index Details from SQLQuery2.sql - DESKTOP-CEBK38L.APSales (DESKTOP-CEBK38L\Angelo (66))
The Query Processor estimates that implementing the following index could improve the query cost by 99.0667%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [StagingTable].[SalesTransaction] ([CustomerNo])
INCLUDE ([CalendarDate],[TransactionQuantity],[UnitRetailPrice])
GO
*/

DROP INDEX IF EXISTS [CustomerNoieDateQuantityRetailPrice]
ON [StagingTable].[SalesTransaction]
GO

CREATE NONCLUSTERED INDEX [CustomerNoieDateQuantityRetailPrice]
ON [StagingTable].[SalesTransaction] ([CustomerNo])
INCLUDE ([CalendarDate],[TransactionQuantity],[UnitRetailPrice])
GO

/**********************/
/* BONUS - STAR Query */
/**********************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SELECT C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate) AS SalesYear
	  ,MONTH(CAL.CalendarDate) AS SalesMonth
	  ,P.ProductCategoryCode
	  ,AVG(FS.[TotalSalesAmount]) AS AvgTotalSales
	  ,SUM(FS.[TotalSalesAmount]) AS SumTotalSales
	  ,MIN(FS.[TotalSalesAmount]) AS MinTotalSales
	  ,MAX(FS.[TotalSalesAmount]) AS MaxTotalSales
FROM FactTable.[Sales] FS
	JOIN DimTable.Country C
		ON C.[CountryKey] = FS.[CountryKey]
	JOIN DimTable.Customer CU
		ON CU.[CustomerKey] = FS.[CustomerKey]
	JOIN DimTable.Store S
		ON S.[StoreKey] = FS.[StoreKey]
	JOIN DimTable.[Calendar] CAL
		ON CAL.[CalendarKey] = FS.[CalendarKey]
	JOIN DimTable.[Product] P
		ON P.[ProductKey] = FS.[ProductKey]
WHERE CU.CustomerNo = 'C00000001'
GROUP BY C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate)
	  ,MONTH(CAL.CalendarDate) 
	  ,P.ProductCategoryCode
ORDER BY C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate)
	  ,MONTH(CAL.CalendarDate) 
	  ,P.ProductCategoryCode
GO

-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

/*
Missing Index Details from chapter 02 - TSQL code - 09-13-2022 Revised and Shortened.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APSales (DESKTOP-CEBK38L\Angelo (51))
The Query Processor estimates that implementing the following index could improve the query cost by 57.9181%.
*/

/*
USE [APSales]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [FactTable].[Sales] ([CustomerKey])
INCLUDE ([ProductKey],[CountryKey],[StoreKey],[CalendarKey],[TotalSalesAmount])
GO
*/

DROP INDEX IF EXISTS [ieCustProdCntryStoreDateSalesAmt]
ON [FactTable].[Sales]
GO

CREATE NONCLUSTERED INDEX [ieCustProdCntryStoreDateSalesAmt]
ON [FactTable].[Sales] ([CustomerKey])
INCLUDE ([ProductKey],[CountryKey],[StoreKey],[CalendarKey],[TotalSalesAmount])
GO

/********************************************/
/* Listing 2.13 - Defining Multiple Windows */
/********************************************/

-- run on SQL Server 2022 instance

USE APSales
GO

DBCC dropcleanbuffers;
CHECKPOINT;
 
-- turn set statistics io/time on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO
-- run on SQL Server 2022 Eval License

WITH CustomerPurchaseAnalysis
(PurchaseYear,PurchaseMonth,CustomerNo,TotalSalesAmount)
AS
(
SELECT
	YEAR(CalendarDate)  AS PurchaseYear,
	MONTH(CalendarDate) AS PurchaseMonth,
	CustomerNo,
	SUM(TransactionQuantity * UnitRetailPrice) AS TotalSalesAmount
FROM StagingTable.SalesTransaction
GROUP BY YEAR(CalendarDate),MONTH(CalendarDate),CustomerNo
) 

SELECT
	cpa.PurchaseYear,
	cpa.PurchaseMonth,
	c.CustomerNo,
	c.CustomerFullName,
	cpa.TotalSalesAmount,

	AVG(cpa.TotalSalesAmount) OVER SalesWindow AS AvgTotalSales
FROM CustomerPurchaseAnalysis cpa
JOIN DimTable.Customer c
ON cpa.CustomerNo = c.CustomerNo
WHERE cpa.CustomerNo = 'C00000008'
WINDOW SalesWindow AS (
		PARTITION BY cpa.PurchaseYear
		ORDER BY cpa.PurchaseYear ASC,cpa.PurchaseMonth ASC
		) 
GO

-- turn set statistics io/time off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO

