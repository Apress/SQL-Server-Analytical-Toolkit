/************************/
/* CREATED: 05/11/2022  */
/* MODIFIED: 05/14/2022 */
/************************/

USE [AP_SALES]
GO

/********************/
/* DUPLICATE CHECK */
/********************/

-- SHOULD RETURN 11,592,286 ROWS IN BOTH CASES

SELECT DISTINCT COUNT(*),'DISTINCT'
FROM [FACT].[Sales] WITH (NOLOCK)
UNION
SELECT DISTINCT COUNT(*),'NON DISTINCT'
FROM [FACT].[Sales] WITH (NOLOCK)
GO

/**************************************************/
/* NOTE: loading this table takes a long time.   */
/* Better to drop table and load with SELECT/INTO */
/**************************************************/

/*
TRUNCATE TABLE [FACT].[YearlySalesReport]
GO

DROP TABLE IF EXISTS [FACT].[YearlySalesReport]
GO
*/

-- We will use this table for our analysis
-- to cut out the complex joins

-- 3 minute 47 seconds to load

--INSERT INTO [FACT].[YearlySalesReport]
SELECT distinct CUST.CustomerFullName
	,P.[ProductNo]
	,P.[ProductName]
	,P.[ProductCategoryCode]
	,P.[ProductSubCategoryCode]
	,PC.ProductCategoryName
	,PSC.ProductSubCategoryName
	,CNTRY.ISO3CountryCode
	,ST.StoreNo
	,ST.StoreName
	,ST.StoreTerritory
	,CAL.CalendarDate
    ,S.[TransactionQuantity]
	,S.[ProductWholeSalePrice]
	,S.[UnitRetailPrice]
	,S.[UnitSalesTaxAmount]
	,S.[TotalWholeSaleAmount]
	,S.[TotalSalesAmount]
INTO [FACT].[YearlySalesReport]
FROM [FACT].[Sales] S
JOIN [DIM].[Customer] CUST
ON S.CustomerKey = CUST.CustomerKey
JOIN [DIM].[Product] P
ON S.ProductKey = P.ProductKey
JOIN [DIM].[ProductCategory] PC
ON P.ProductCategoryCode = PC.ProductCategoryCode
JOIN [DIM].[ProductSubCategory] PSC
ON P.ProductSubCategoryCode = PSC.ProductSubCategoryCode
JOIN [DIM].[Country] CNTRY
ON S.CountryKey = CNTRY.CountryKey
JOIN [DIM].[Store] ST
ON S.StoreKey = ST.StoreKey
JOIN [DIM].[Calendar] CAL
ON S.CalendarKey = CAL.CalendarKey
GO

/*******************************************/
/* BACKUP AND TRUNCATE THE TRANSACTION LOG */
/*******************************************/

/*******************************************************/
/* change the physical file patch in case your machine */
/* has a different disk layout                         */
/*******************************************************/

BACKUP LOG [AP_SALES] 
TO  DISK = N'D:\APRESS_DATABASES\AP_SALES_BACKUP\AP_SALES_BAKUP.LOG' 
WITH NOFORMAT,INIT,  
NAME = N'AP_SALES-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  
STATS = 10
GO


/**********************************/
/* RECIPE 1 - AGGREGATE FUNCTIONS */
/**********************************/

USE [AP_SALES]
GO

/*******************************************/
/* LISTING 7.1 - COUNT(),MIN(),MAX(),AVG() */
/*******************************************/

/**************************************/
/* TASK 1 - COUNT(),MIN(),MAX(),AVG() */
/**************************************/

-- 1 seconds 

SELECT --YEAR([CalendarDate]) AS ReportingYear
	  --,MONTH([CalendarDate]) AS ReportingMonth
	  [CustomerFullName]
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductCategoryName]
	  ,[ProductSubCategoryName]
	  ,COUNT([TotalSalesAmount]) AS TransactionCount
	  ,COUNT_BIG([TotalSalesAmount]) AS BigTransactionCount
      ,SUM([TotalSalesAmount]) AS TotalMonthlySales
	  ,AVG([TotalSalesAmount]) AS AverageMonthlySales
	  ,MIN([TotalSalesAmount]) AS MinimumMonthlySales
	  ,MAX([TotalSalesAmount]) AS MaximumMonthlySales
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE StoreName = 'Binghamton Store'
--AND CustomerFullName = 'John Brown'
--AND ProductName = 'Almond Chocolates - Small'
AND YEAR([CalendarDate]) = 2010
AND MONTH([CalendarDate]) = 1
GROUP BY --[CalendarDate]
	[CustomerFullName]
    ,[ProductNo]
    ,[ProductName]
    ,[ProductCategoryCode]
    ,[ProductSubCategoryCode]
    ,[ProductCategoryName]
	,[ProductSubCategoryName]
ORDER BY
 --   YEAR([CalendarDate])
--	,MONTH([CalendarDate]) 
	[CustomerFullName]
    ,[ProductNo]
 GO

/************************************************/
/* TASK 2 - COUNT(),MIN(),MAX(),AVG(), W/OVER() */
/************************************************/

/****************************************************/
/* LISTING 7.2 - COUNT(),MIN(),MAX(),AVG() W/OVER() */
/****************************************************/

SELECT DISTINCT YEAR([CalendarDate]) AS ReportingYear
	  ,MONTH([CalendarDate]) AS ReportingMonth
	  ,[CustomerFullName]
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductCategoryName]
	  ,[ProductSubCategoryName]

	  ,COUNT([TotalSalesAmount]) OVER (
	  PARTITION BY 
		YEAR([CalendarDate]),
		MONTH([CalendarDate]),
		CustomerFullName,
		ProductNo
	  ORDER BY YEAR([CalendarDate])
	  ) AS TotalTransactions

      ,SUM([TotalSalesAmount]) OVER (
	  PARTITION BY 
		YEAR([CalendarDate]),
		MONTH([CalendarDate]),
		CustomerFullName,
		ProductNo
	  ORDER BY YEAR([CalendarDate])
	  ) AS TotalMonthlySales

      ,AVG([TotalSalesAmount]) OVER (
	    PARTITION BY 
		YEAR([CalendarDate]),
		MONTH([CalendarDate]),
		CustomerFullName,
		ProductNo
	  ORDER BY YEAR([CalendarDate])
	  ) AS AverageMonthlySales

	  ,MIN([TotalSalesAmount]) OVER (
	    PARTITION BY 
		YEAR([CalendarDate]),
		MONTH([CalendarDate]),
		CustomerFullName,
		ProductNo
	  ORDER BY YEAR([CalendarDate])
	  ) AS MinimumMonthlySales

	  ,MAX([TotalSalesAmount]) OVER (
	    PARTITION BY 
		YEAR([CalendarDate]),
		MONTH([CalendarDate]),
		CustomerFullName,
		ProductNo
	  ORDER BY YEAR([CalendarDate])
	  ) AS MaximumMonthlySales
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE StoreName = 'Binghamton Store'
--AND CustomerFullName = 'John Brown'
AND ProductName = 'Almond Chocolates - Small'
AND YEAR([CalendarDate]) = 2010
AND MONTH([CalendarDate]) = 1
--AND CustomerFullName = 'Bill Belvedere'
ORDER BY
   YEAR([CalendarDate])
	,MONTH([CalendarDate]) 
	,[CustomerFullName]
    ,[ProductNo]
  
GO

/***************************************/
/* TASK 3 - GROUPING SETS W/GROUPING() */
/***************************************/

/*******************************************/
/* LISTING 7.3 - GROUPING SETS /W/GROUPING */
/*******************************************/

SELECT DISTINCT YEAR([CalendarDate]) AS ReportingYear
	  ,MONTH([CalendarDate]) AS ReportingMonth
	  ,[CustomerFullName]
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductCategoryName]
	  ,[ProductSubCategoryName]
      ,SUM([TotalSalesAmount]) AS TotalMonthlySales 
	  ,GROUPING ([TotalSalesAmount]) AS SalesGroupingSets
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE StoreName = 'Binghamton Store'
AND ProductName = 'Almond Chocolates - Small'
AND YEAR([CalendarDate]) = 2010
AND MONTH([CalendarDate]) = 1
AND CustomerFullName = 'Bill Belvedere'
GROUP BY YEAR([CalendarDate])
	  ,MONTH([CalendarDate]) 
	  ,[CustomerFullName]
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductCategoryName]
	  ,[ProductSubCategoryName]
	  ,[TotalSalesAmount] WITH ROLLUP 
ORDER BY
     YEAR([CalendarDate])
	,MONTH([CalendarDate]) 
	,[CustomerFullName]
    ,[ProductNo]
    ,[ProductName]
    ,[ProductCategoryCode]
    ,[ProductSubCategoryCode]
    ,[ProductCategoryName]
	,[ProductSubCategoryName]
	,SUM([TotalSalesAmount]) 
GO

/********************************************/
/* TASK 4 - STDEV(),STDEVP() & VAR(),VARP() */
/********************************************/

/**********************************/
/* LISTING 7.4 - STDEV(),STDEVP() */
/**********************************/


-- TIME TO CREATE ON 11 MILLION ROWS PLUS: 1 MIN,35 SEC

DROP INDEX IF EXISTS [FACT].ieSalesSTDEV  
GO

CREATE INDEX ieSalesSTDEV on [FACT].[YearlySalesReport](
	[TotalSalesAmount],[CalendarDate],[ProductNo]
	)
GO

DROP INDEX IF EXISTS [FACT].ieProdCatDate 
GO

-- 31 seconds
CREATE INDEX ieProdCatDate on [FACT].[YearlySalesReport]
(ProductCategoryCode,CalendarDate)
GO

SELECT YEAR(MIN([CalendarDate])),YEAR(MAX([CalendarDate]))
FROM [FACT].[YearlySalesReport]
GO

/****************************************/
/* LISTING 7.5 - SUM(),STDEV(),STDEVP() */
/****************************************/

-- included SUM() for export to EXCEL

/**************************/
/* SUM(),STDEV(),STDEVP() */
/**************************/

SELECT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[StoreNo]
      ,[StoreName]
      ,[StoreTerritory]
      ,SUM([TotalSalesAmount]) AS [SUM]
	  ,STDEV([TotalSalesAmount]) AS [STDEV]
	  ,STDEVP([TotalSalesAmount]) AS [STDEVP]
FROM [AP_SALES].[FACT].[YearlySalesReport]
WHERE YEAR(CalendarDate) BETWEEN 2011 AND 2020
AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND ProductNo = 'P0000001103'
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[StoreNo]
      ,[StoreName]
      ,[StoreTerritory]
ORDER BY 
      [ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[StoreNo]
      ,[StoreName]
      ,[StoreTerritory]
      ,YEAR(CalendarDate)
	  ,MONTH(CalendarDate)
GO

/****************************/
/* QUERY EXECUTION TIME: 15 */
/****************************/

/*************************************************/
/* LISTING 7.6 - NEXTED QUERY FOR OVER() EXAMPLE */
/*************************************************/

/**********/
/* OVER() */
/**********/

-- use this as the nested table
-- this runs in 1 second

SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
ORDER BY YEAR(CalendarDate)
	,MONTH(CalendarDate) 
GO

/***********************************/
/* LISTING 7.7 - QUERY WITH OVER() */
/***********************************/

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[SUM] AS SALES
      ,STDEV([SUM]) OVER (
		PARTITION BY  [YEAR]
		ORDER BY  [YEAR],[MONTH]
	  ) AS STDEV
	  ,CONVERT(DECIMAL(10,2),STDEVP([SUM]) OVER (
		PARTITION BY  [YEAR]
		ORDER BY [YEAR],[MONTH]
	  )) AS STDEVP
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
ORDER BY
   [YEAR],[MONTH]
GO

/******************************************/
/* LISTING 7.8 - VAR() & VARP() NO OVER() */
/******************************************/

/******************/
/* VAR() & VARP() */
/******************/

SELECT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[StoreNo]
      ,[StoreName]
      ,[StoreTerritory]
      ,SUM([TotalSalesAmount]) AS [SUM]
	  ,VAR([TotalSalesAmount]) AS [VAR]
	  ,VARP([TotalSalesAmount]) AS [VARP]
FROM [AP_SALES].[FACT].[YearlySalesReport]
WHERE YEAR(CalendarDate) BETWEEN 2011 AND 2020
AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND ProductNo = 'P0000001103'
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
      ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[StoreNo]
      ,[StoreName]
      ,[StoreTerritory]
ORDER BY 
      [ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[StoreNo]
      ,[StoreName]
      ,[StoreTerritory]
      ,YEAR(CalendarDate)
	  ,MONTH(CalendarDate)
GO

/********************************************/
/* LISTING 7.9 - VAR() & VARP() WITH OVER() */
/********************************************/

/**********/
/* OVER() */
/**********/

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[SUM] AS SALES
      ,VAR([SUM]) OVER (
		PARTITION BY  [YEAR]
		ORDER BY  [YEAR],[MONTH]
	  ) AS [VAR]
	  ,VARP([SUM]) OVER (
		PARTITION BY  [YEAR]
		ORDER BY [YEAR],[MONTH]
	  ) AS [VARP]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
ORDER BY
   [YEAR],[MONTH]
GO

/********************************/
/* RECIPE 2 - RANKING FUNCTIONS */
/********************************/

/****************************************/
/* LISTING 7.10 - RANK() & DENSE_RANK() */
/****************************************/

/**********************************/
/* TASK 1 - RANK() & DENSE_RANK() */
/**********************************/

SELECT  [YEAR] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[TotalSales] AS CurrentMonth
      ,RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[TotalSales] DESC
		) AS [Ranking]
		,DENSE_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[TotalSales] DESC
		) AS [Dense Ranking]

FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,DATEPART(qq,CalendarDate) AS [Quarter]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [TotalSales]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
ORDER BY [Year],[Month]
GO

/*************************************************/
/* LISTING 7.11 - RANK() & DENSE_RANK() W/OVER() */
/*************************************************/

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[QUARTER] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[SUM] AS SALES
      ,RANK() OVER (
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [SUM] DESC
	  ) AS [QTR_RANK]
	  ,DENSE_RANK() OVER (
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [SUM] DESC
	  ) AS [QTR_DENSE_RANK]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,DATEPART(qq,CalendarDate) AS [QUARTER]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
--AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
GO

/********************/
/* TASK 2 - NTILE() */
/********************/

/**************************************/
/* LISTING 7.12 - NTILE() WITH OVER() */
/**************************************/

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[QUARTER] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[SUM] AS SALES
      ,NTILE(4) OVER (
		PARTITION BY  [YEAR]
		ORDER BY [QUARTER] ASC
	  ) AS [NTILE]
	  ,DENSE_RANK() OVER (
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [SUM] DESC
	  ) AS [QTR_DENSE_RANK]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,DATEPART(qq,CalendarDate) AS [QUARTER]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
--AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
GO

/*************************/
/* TASK 3 - ROW_NUMBER() */
/*************************/

/*******************************************/
/* LISTING 7.13 - ROW_NUMBER() WITH OVER() */
/*******************************************/

SELECT DISTINCT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[SUM] AS SALES
      ,ROW_NUMBER() OVER (
		PARTITION BY  [YEAR],[StoreNo]
		ORDER BY [SUM] DESC
	  ) AS [ROW_NUMBER]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo IN('S00014','S00015')
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
GO

/**********************************/
/* RECIPE 3 - WINDOWING FUNCTIONS */
/**********************************/

/************************/
/* TASK 1 - CUME_DIST() */
/************************/

/******************************************/
/* LISTING 7.14 - CUME_DIST() WITH OVER() */
/******************************************/


/******************/
/* TASK 2 - LAG() */
/******************/

/************************************/
/* LISTING 7.15 - LAG() WITH OVER() */
/************************************/

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[QUARTER] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
	  ,[SUM] AS CurrentMonth
      ,LAG([SUM]) OVER (
		PARTITION BY  [YEAR],[QUARTER]
	ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) AS LastMonth
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,DATEPART(qq,CalendarDate) AS [QUARTER]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
--AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
ORDER BY [YEAR],[QUARTER],[MONTH]
GO

/************************************/
/* LISTING 7.16 - LAG() & SOME MATH */
/************************************/

-- ADD DELTA AND PERCENTAGE CHANGE

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[QUARTER] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
	  ,[SUM] AS CurrentMonth
      ,LAG([SUM]) OVER (
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) AS PriorMonth

	  ,[SUM] - LAG([SUM]) OVER (
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) AS Change

		-- (current - next) / current)
	  ,((
	  [SUM] - LAG([SUM]) OVER ( -- this is next month
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) -- this is current month
		) / [SUM]) * 100 AS [%Change]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,DATEPART(qq,CalendarDate) AS [QUARTER]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
--AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
ORDER BY [YEAR],[QUARTER],[MONTH]
GO

/*************************/
/* LISTING 7.17 - LEAD() */
/*************************/

/*******************/
/* TASK 3 - LEAD() */
/*******************/

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[QUARTER] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
	  ,[SUM] AS CurrentMonth
      ,LEAD([SUM]) OVER (
		PARTITION BY  [YEAR],[QUARTER]
	ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) AS NextMonth
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,DATEPART(qq,CalendarDate) AS [QUARTER]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
--AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
ORDER BY [YEAR],[QUARTER],[MONTH]
GO

-- ADD DELTA AND PERCENTAGE CHANGE

/*************************************/
/* LISTING 7.18 - LEAD() & SOME MATH */
/*************************************/

SELECT DISTINCT [YEAR] AS ReportingYear
	  ,[MONTH] AS ReportingMonth
	  ,[QUARTER] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
	  ,[SUM] AS CurrentMonth
      ,LEAD([SUM]) OVER (
		PARTITION BY  [YEAR],[QUARTER]
	ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) AS NextMonth

	  ,LEAD([SUM]) OVER (
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) - [SUM] AS Change

		-- (current - next) / current)
	  ,(
	  LEAD([SUM]) OVER ( -- this is next month
		PARTITION BY  [YEAR],[QUARTER]
		ORDER BY [YEAR],[QUARTER],[MONTH] ASC
		) - [SUM] -- this is current month
		) / [SUM] AS [%Change]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
	,DATEPART(qq,CalendarDate) AS [QUARTER]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [SUM]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
--AND MONTH(CalendarDate) BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
WHERE [ProductCategoryCode] = 'PC001'
ORDER BY [YEAR],[QUARTER],[MONTH]
GO

/**********************************************/
/* TASK 4 - PERCENTILE_CONT & PERCENTILE_DISC */
/**********************************************/

/**************************************************/
/* TASK 5 - PERCENTILE_CONT() & PERCENTILE_DISC() */
/**************************************************/

/******************************************************/
/* LISTING 7.19 - PERCENTILE_CONT & PERCENTILE_DISC() */
/******************************************************/

SELECT  [YEAR] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[TotalSales] AS CurrentMonth
	  ,PERCENTILE_CONT(.50) 
	  WITHIN GROUP (ORDER BY [TotalSales])
	  OVER (
		PARTITION BY [Year],[Month]
		)   AS [% Continuous]
	 ,PERCENTILE_DISC(.50) 
	  WITHIN GROUP (ORDER BY [TotalSales])
	  OVER (
		PARTITION BY [Year],[Month]
		)   AS [% Discreet]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,DATEPART(qq,CalendarDate) AS [Quarter]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [TotalSales]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
ORDER BY [Year],[Month]
GO

/**************************/
/* TASK 6 - FIRST_VALUE() */
/**************************/

/********************************/
/* LISTING 7.20 - FIRST_VALUE() */
/********************************/

-- show lowest selling store for a product

SELECT  [YEAR] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[TotalSales] AS CurrentMonth
      ,FIRST_VALUE([StoreNo]) OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[TotalSales] ASC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS LowestSeller

FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,DATEPART(qq,CalendarDate) AS [Quarter]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [TotalSales]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
ORDER BY [Year],[Month]
GO


/*************************/
/* TASK 7 - LAST_VALUE() */
/*************************/

/*******************************/
/* LISTING 7.21 - LAST_VALUE() */
/*******************************/

SELECT  [YEAR] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[TotalSales] AS CurrentMonth
      ,LAST_VALUE([StoreNo]) OVER (
		PARTITION BY [Year],[MONTH]
		ORDER BY [Year],[Month],[TotalSales] ASC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS HighestSeller

FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,DATEPART(qq,CalendarDate) AS [Quarter]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [TotalSales]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
ORDER BY [Year],[Month]
GO

/*************************/
/* TASK 8 - PERCENT_RANK */
/*************************/

/*********************************/
/* LISTING 7.22 - PERCENT_RANK() */
/*********************************/

-- 41 seconds

SELECT  [YEAR] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
	  ,[TotalSales] AS CurrentMonth
	  ,CONVERT(DECIMAL(10,2),PERCENT_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[TotalSales] ASC
		) )  AS [% Ranking]
	  ,CONVERT(DECIMAL(10,2),RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [TotalSales] DESC
		) )  AS [SalesRank]
	  ,CONVERT(DECIMAL(10,2),DENSE_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [TotalSales] DESC
		) )  AS [SalesDenseRank]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,DATEPART(qq,CalendarDate) AS [Quarter]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [TotalSales]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
GO

/***************/
/* CUME_DIST() */
/***************/

/******************************/
/* LISTING 7.23 - CUME_DIST() */
/******************************/

SELECT  [YEAR] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[TotalSales] AS CurrentMonth
	  ,PERCENTILE_CONT(.50) 
	  WITHIN GROUP (ORDER BY [TotalSales])
	  OVER (
		PARTITION BY [Year],[Month]
		)   AS [% Continuous]
	 ,CUME_DIST() 
	  OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[TotalSales] ASC
		) AS [Cumulative Distribution]
FROM (
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,DATEPART(qq,CalendarDate) AS [Quarter]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [TotalSales]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND YEAR(CalendarDate) BETWEEN 2011 AND 2020
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
) ST
ORDER BY [Year],[Month]
GO


