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

-- 1 second 

SELECT --YEAR([CalendarDate]) AS ReportingYear
	  '2010 - ' + CV.[MONTH_NAME] AS ReportingMonth
	  ,[CustomerFullName]
      ,[ProductName]
      ,[ProductCategoryName]
	  ,[ProductSubCategoryName]
	  ,COUNT([TotalSalesAmount]) AS TransactionCount
	  ,COUNT_BIG([TotalSalesAmount]) AS BigTransactionCount
      ,SUM([TotalSalesAmount]) AS TotalMonthlySales
	  ,AVG([TotalSalesAmount]) AS AverageMonthlySales
	  ,MIN([TotalSalesAmount]) AS MinimumMonthlySales
	  ,MAX([TotalSalesAmount]) AS MaximumMonthlySales
FROM [FACT].[YearlySalesReport] YSR WITH (NOLOCK)
JOIN [DIM].[CALENDAR_VIEW] CV
ON CV.[CalendarDate] = YSR.[CalendarDate]
WHERE StoreName = 'Binghamton Store'
AND CustomerFullName = 'John Brown'
AND ProductCategoryName = 'Chocolates'
AND CV.[CalendarYear] = 2010
AND CV.[CalendarMonth] = 1
GROUP BY --[CalendarDate]
	[CustomerFullName]
    ,[ProductNo]
    ,[ProductName]
    ,[ProductCategoryName]
	,[ProductSubCategoryName]
	,CV.Month_Name
ORDER BY
 --   YEAR([CalendarDate])
	CV.Month_Name
	,[CustomerFullName]
    ,[ProductNo]
 GO

 /***********/
 /* BONUS 1 */
 /***********/

 SELECT CV.CalendarYear AS ReportingYear
	  ,CV.Quarter_Name AS ReportingQuarter
	  ,CV.[Month_Name] AS ReportingMonth
      ,[ProductName]
      ,[ProductCategoryName]
	  ,[ProductSubCategoryName]
	  ,COUNT([TotalSalesAmount]) AS TransactionCount
	  ,COUNT_BIG([TotalSalesAmount]) AS BigTransactionCount
      ,SUM([TotalSalesAmount]) AS TotalMonthlySales
	  ,AVG([TotalSalesAmount]) AS AverageMonthlySales
	  ,MIN([TotalSalesAmount]) AS MinimumMonthlySales
	  ,MAX([TotalSalesAmount]) AS MaximumMonthlySales
FROM [FACT].[YearlySalesReport] YSR WITH (NOLOCK)
JOIN [DIM].[CALENDAR_VIEW] CV
ON CV.[CalendarDate] = YSR.[CalendarDate]
WHERE StoreName = 'Binghamton Store'
AND ProductCategoryName = 'Chocolates'
GROUP BY CV.CalendarYear 
	,CV.Quarter_Name 
	,CV.[MONTH_NAME] 
    ,[ProductName]
    ,[ProductCategoryName]
	,[ProductSubCategoryName]
ORDER BY
CV.CalendarYear 
	,CV.Quarter_Name 
	,CV.[MONTH_NAME] 
    ,[ProductName]
    ,[ProductCategoryName]
	,[ProductSubCategoryName]
 GO

 /***********/
 /* BONUS 2 */
 /***********/

 SELECT CV.CalendarYear AS ReportingYear
	  ,CV.Quarter_Name
      ,[ProductName]
      ,COUNT([TotalSalesAmount]) AS YearlyPurchases
FROM [FACT].[YearlySalesReport] YSR WITH (NOLOCK)
JOIN [DIM].[CALENDAR_VIEW] CV
ON CV.[CalendarDate] = YSR.[CalendarDate]
WHERE StoreName = 'Binghamton Store'
AND ProductCategoryName = 'Chocolates'
AND ProductName = 'Almond Chocolates - Medium'
GROUP BY CV.CalendarYear 
	,CV.Quarter_Name
    ,[ProductName]
ORDER BY
	CV.CalendarYear 
	,CV.Quarter_Name
    ,[ProductName]
 GO


/************************************************/
/* TASK 2 - COUNT(),MIN(),MAX(),AVG(), W/OVER() */
/************************************************/

/****************************************************/
/* LISTING 7.2 - COUNT(),MIN(),MAX(),AVG() W/OVER() */
/****************************************************/

SELECT DISTINCT CV.CalendarYear AS ReportingYear
	  ,CV.Quarter_Name
	  ,CV.Month_Name
	  ,CV.CalendarMonth
      ,[ProductName]

	  ,COUNT([TotalSalesAmount]) OVER (
	 	PARTITION BY CV.CalendarYear,CV.Quarter_Name,CV.Month_Name
		ORDER BY CV.CalendarYear
		) AS SalesCount
      ,SUM([TotalSalesAmount]) OVER (
	  PARTITION BY CV.CalendarYear,CV.Quarter_Name,CV.Month_Name
	  ORDER BY CV.CalendarYear
	  ) AS TotalMonthlySales
      ,AVG([TotalSalesAmount]) OVER (
	 	PARTITION BY CV.CalendarYear,CV.Quarter_Name,CV.Month_Name
		ORDER BY CV.CalendarYear
	  ) AS AverageMonthlySales
	  ,MIN([TotalSalesAmount]) OVER (
	 	PARTITION BY CV.CalendarYear,CV.Quarter_Name,CV.Month_Name
		ORDER BY CV.CalendarYear
	  ) AS MinimumMonthlySales
	  ,MAX([TotalSalesAmount]) OVER (
	 	PARTITION BY CV.CalendarYear,CV.Quarter_Name,CV.Month_Name
		ORDER BY CV.CalendarYear
	  ) AS MaximumMonthlySales
FROM [FACT].[YearlySalesReport] YSR WITH (NOLOCK)
JOIN [DIM].[CALENDAR_VIEW] CV
ON CV.[CalendarDate] = YSR.[CalendarDate]
WHERE StoreName = 'Binghamton Store'
AND ProductName = 'Almond Chocolates - Medium'
AND CV.CalendarYear = 2010
ORDER BY CV.CalendarYear
    ,CV.Quarter_Name
	,CV.CalendarMonth
	,CV.Month_Name
    ,[ProductName]
GO

/***************************************/
/* TASK 3 - GROUPING SETS W/GROUPING() */
/***************************************/

/******************************************/
/* LISTING 7.3 - GROUPING SETS W/GROUPING */
/******************************************/

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

/********************************/
/* LISTING 7.4 - HELPER INDEXES */
/********************************/

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

CREATE INDEX ieDate on [FACT].[YearlySalesReport]
(CalendarDate)
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
      ,[ProductName]
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
      ,[ProductName]
 ORDER BY 
      YEAR(CalendarDate)
	  ,MONTH(CalendarDate)
	  ,[ProductName]
GO

/****************************/
/* QUERY EXECUTION TIME: 15 */
/****************************/

/****************************************************/
/* LISTING 7.6 - VIEW FOR ALL EXAMPLES USING OVER() */
/****************************************************/

CREATE OR ALTER VIEW DIM.SALES_VIEW
AS
SELECT DISTINCT YEAR(CalendarDate) AS [Year]
	,MONTH(CalendarDate) AS [Month]
	,DATEPART(qq,CalendarDate) AS [Quarter]
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,SUM([TotalSalesAmount]) AS [Sum]
FROM [FACT].[YearlySalesReport] WITH (NOLOCK)
GROUP BY YEAR(CalendarDate)
	,MONTH(CalendarDate)
	,DATEPART(qq,CalendarDate)
	,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
GO

SELECT * FROM  DIM.SALES_VIEW
GO


/*****************************************************/
/* LISTING 7.7 - SUM() WITH & WITHOUT OVER() EXAMPLE */
/*****************************************************/

/**********/
/* OVER() */
/**********/

SELECT DISTINCT  'WITH OVER' AS [OVER USED],
    [Year] AS SalesYear
	,[Month] AS SalesMonth
	,[StoreName]
    ,[ProductName]
    ,SUM([Sum]) OVER (
		PARTITION BY [Year],[Month],[StoreName]
		ORDER BY [Sum]
	) AS TotalSalesAmount
FROM [DIM].[Sales_View] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND [Month] BETWEEN 1 AND 12
AND StoreNo = 'S00014'
UNION ALL
SELECT DISTINCT 'WITHOUT OVER()'
    ,[Year] AS SalesYear
	,[Month] AS SalesMonth
	,[StoreName]
    ,[ProductName]
    ,SUM([Sum]) AS TotalSalesAmount
FROM [DIM].[Sales_View] WITH (NOLOCK)
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND [Month] BETWEEN 1 AND 12
AND StoreNo = 'S00014'
GROUP BY [Year]
	,[Month]
	,[StoreName]
    ,[ProductName]
ORDER BY [Year],[Month]
GO

/**********/
/* TASK 8 */
/**********/

/**********************************************/
/* LISTING 7.8 - STDEV(),STDEVP() WITH OVER() */
/**********************************************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
      ,[ProductName]
	  ,[StoreName]
	  ,[Sum] AS Sales
	  ,STDEV([Sum]) OVER () AS OverAll
      ,STDEV([Sum]) OVER (
		PARTITION BY [Year]
		ORDER BY  [Sum]
	  ) AS [Stdev]
	  ,STDEVP([Sum]) OVER (
		PARTITION BY [Year]
		ORDER BY  [Sum]
	  ) AS [Stdevp]
FROM DIM.SALES_VIEW 
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] = 2011 
AND [Month] BETWEEN 1 AND 12
AND StoreNo = 'S00014'
ORDER BY
   [Year],[Month]
GO

/******************************************/
/* LISTING 7.9 - VAR() & VARP() NO OVER() */
/******************************************/

/******************/
/* VAR() & VARP() */
/******************/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT YEAR(CalendarDate) AS [YEAR]
	,MONTH(CalendarDate) AS [MONTH]
      ,[StoreName]
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
      ,[StoreName]
ORDER BY 
      YEAR(CalendarDate)
	  ,MONTH(CalendarDate)
      ,[StoreName]
GO

/*************/
/* EXAMPLE 2 */
/*************/

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
/* LISTING 7.10 - VAR() & VARP() WITH OVER() */
/********************************************/

/**********/
/* OVER() */
/**********/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreName]
	  ,[Sum] AS SALES
      ,VAR([Sum]) OVER (
		PARTITION BY [Year]
		ORDER BY  [Year],[Month]
	  ) AS VAR
	  ,VARP([Sum]) OVER (
		PARTITION BY [Year]
		ORDER BY  [Year],[Month]
	  ) AS VARP
FROM DIM.SALES_VIEW 
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] = 2011 
AND StoreNo = 'S00014'
ORDER BY
   [Year],[Month],[StoreName]
GO

/*************/
/* EXAMPLE 2 */
/*************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[Sum] AS SALES
      ,VAR([Sum]) OVER (
		PARTITION BY [Year]
		ORDER BY  [Year],[Month]
	  ) AS VAR
	  ,VARP([Sum]) OVER (
		PARTITION BY [Year]
		ORDER BY  [Year],[Month]
	  ) AS VARP
FROM DIM.SALES_VIEW 
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND [Month] BETWEEN 1 AND 12
AND StoreNo = 'S00014'
ORDER BY
   [Year],[Month]
GO

/********************************/
/* RECIPE 2 - RANKING FUNCTIONS */
/********************************/

/**********************************/
/* TASK 1 - RANK() & DENSE_RANK() */
/**********************************/

/*************************************************/
/* LISTING 7.11 - RANK() & DENSE_RANK() W/OVER() */
/*************************************************/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT [Year]    AS ReportingYear
	  ,[Quarter] AS ReportingQuarter
	  ,[StoreName]
	  ,[CurrentMonth] AS CurrentMonth
      ,RANK() OVER (
		PARTITION BY [Year],[Quarter]
		ORDER BY [CurrentMonth] DESC
		) AS [Ranking]
	  ,DENSE_RANK() OVER (
		PARTITION BY [Year],[Quarter]
		ORDER BY [CurrentMonth] DESC
		) AS [Dense Ranking]
FROM (
SELECT [Year] 
	  ,[Quarter]
	  ,[StoreName]
	  ,SUM([Sum]) AS CurrentMonth
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year]  = 2011 
GROUP BY [Year] 
	  ,[Quarter]
	  ,[StoreName]
) SALES_VIEW
--ORDER BY [Year],[Quarter]
GO

/*************/
/* EXAMPLE 2 */
/*************/


SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[Quarter]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[Sum] DESC
		) AS [Ranking]
		,DENSE_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[Sum] DESC
		) AS [Dense Ranking]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year]  BETWEEN 2011 AND 2020
ORDER BY [Year],[Quarter],[Month]
GO

/********************/
/* TASK 2 - NTILE() */
/********************/

/**************************************/
/* LISTING 7.12 - NTILE() WITH OVER() */
/**************************************/

-- tile by territory
-- but does not quite work out!

SELECT S.[StoreNo], 
	S.[StoreName], 
	S.[StoreTerritory],
	T.[TotalSalesAmount]  AS SalesYTD,
	NTILE(4) OVER(
		ORDER BY S.[StoreNo]
		) AS [TerritoryBucket]
FROM [DIM].[Store] S
JOIN ( -- took 36 seconds
	SELECT StoreNo,SUM([TotalSalesAmount]) AS TotalSalesAmount
	FROM [FACT].[YearlySalesReport]
	GROUP BY StoreNo
	) T
ON S.StoreNo = T.[StoreNo]
GO

-- tile by year
SELECT [Year] AS ReportingYear
	  ,[Quarter] AS ReportingQuarter
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,NTILE(2) OVER(
		ORDER BY [Year],[Quarter],[Month]
		) AS [YearPartition]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year]  BETWEEN 2011 AND 2020
ORDER BY [Year],[Month]
GO

SELECT [Year] AS ReportingYear
	  ,[Quarter] AS ReportingQuarter
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,NTILE(4) OVER (
		PARTITION BY  [Year]
		ORDER BY [Quarter] ASC
	  ) AS [Ntile]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year]  BETWEEN 2011 AND 2020
ORDER BY [Year],[Month]
GO

/*************************/
/* TASK 3 - ROW_NUMBER() */
/*************************/

/*******************************************/
/* LISTING 7.13 - ROW_NUMBER() WITH OVER() */
/*******************************************/

SELECT DISTINCT [Year] AS ReportingYear
	  ,[Quarter] AS ReportingQuarter
	  ,[Month] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
      ,[ProductCategoryCode]
     ,[ProductSubCategoryCode]
	  ,[StoreNo]
	  ,[StoreName]
	  ,[SUM] AS SALES
      ,ROW_NUMBER() OVER (
		PARTITION BY  [Year],[Quarter],[Month]
		ORDER BY [Year],[Quarter],[Month] --,[Sum] ASC
	  ) AS [ROW_NUMBER]
FROM DIM.SALES_VIEW
WHERE ProductCategoryCode = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND [Month] BETWEEN 1 AND 12
AND StoreNo IN('S00013','S00014','S00015','S00016')
GO

/***********************************/
/* TASK 4 - ROW_NUMBER() EXAMPLE 2 */
/***********************************/

/*****************************************/
/* LISTING 7.14 - ROW_NUMBER() EXAMPLE 2 */
/*****************************************/

SELECT [Year] AS ReportingYear
	  ,[Quarter] AS ReportingQuarter
	  ,[Month] AS ReportingMonth
	  ,[StoreName]
	  ,[SUM] AS SALES
     ,ROW_NUMBER() OVER (
		ORDER BY [Year],[Quarter],[Month] ASC
	  ) AS [ROW_NUMBER] 
FROM DIM.SALES_VIEW
WHERE [Year] BETWEEN 2011 AND 2020
ORDER BY ROW_NUMBER() OVER (
		ORDER BY [Year],[Quarter],[Month] ASC
	  )
GO

/**********************************/
/* RECIPE 3 - WINDOWING FUNCTIONS */
/**********************************/

/************************************/
/* TASK 1 - CUME_DIST() WITH OVER() */
/************************************/

/******************************************/
/* LISTING 7.15 - CUME_DIST() WITH OVER() */
/******************************************/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT [Year] AS ReportingYear
	  ,[Quarter]
	  ,[Month]
	  ,[StoreNo]
	  ,[Sum] AS TotalQTRSAles
		,CUME_DIST() OVER (
		PARTITION BY [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) AS [CUME_DIST]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year]  = 2011
AND StoreNo = 'S00015'
GO

/*************/
/* EXAMPLE 2 */
/*************/

-- over two years

SELECT [Year] AS ReportingYear
	  ,[Quarter]
	  ,[Month]
	  ,[StoreNo]
	  ,[Sum] AS TotalQTRSAles
		,CUME_DIST() OVER (
--		PARTITION BY [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) AS [CUME_DIST]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] IN(2011,2012)
AND StoreNo = 'S00015'
GO

/******************/
/* TASK 2 - LAG() */
/******************/

/************************************/
/* LISTING 7.16 - LAG() WITH OVER() */
/************************************/

SELECT DISTINCT [Year] AS ReportingYear
	  ,[Quarter] AS ReportingQuarter
	  ,[Month] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
	  ,[SUM] AS CurrentMonth
      ,LAG([SUM]) OVER (
		PARTITION BY [Year],[Quarter]
		ORDER BY [Year],[Quarter],[Month] ASC
		) AS LastMonth
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND StoreNo = 'S00014'
ORDER BY [YEAR],[QUARTER],[MONTH]
GO

/************************************/
/* LISTING 7.17 - LAG() & SOME MATH */
/************************************/

-- ADD DELTA AND PERCENTAGE CHANGE
SELECT DISTINCT [Year] AS ReportingYear
	  ,[Quarter] AS ReportingQuarter
	  ,[Month] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,LAG([Sum]) OVER (
		PARTITION BY  [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) AS PriorMonth

	  ,[SUM] - LAG([SUM]) OVER (
		PARTITION BY  [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) AS Change

		-- (current - next) / current)
	  ,((
	  [SUM] - LAG([SUM]) OVER ( -- this is next month
		PARTITION BY [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) -- this is current month
		) / [Sum]) * 100 AS [%Change]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND StoreNo = 'S00014'
ORDER BY [Year],[Quarter],[Month]
GO

/*******************/
/* TASK 3 - LEAD() */
/*******************/

/*************************/
/* LISTING 7.18 - LEAD() */
/*************************/

SELECT DISTINCT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[Quarter] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
	  ,[SUM] AS CurrentMonth
      ,LEAD([SUM]) OVER (
		PARTITION BY [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) AS NextMonth
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND StoreNo = 'S00014'
ORDER BY [Year],[Quarter],[Month]
GO

-- ADD DELTA AND PERCENTAGE CHANGE

/*************************************/
/* LISTING 7.18 - LEAD() & SOME MATH */
/*************************************/

SELECT DISTINCT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[Quarter] AS ReportingQuarter
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,LEAD([Sum]) OVER (
		PARTITION BY  [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) AS NextMonth

	  ,LEAD([Sum]) OVER (
		PARTITION BY  [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) - [Sum] AS Change

	  ,(
	  LEAD([Sum]) OVER ( -- this is next month
		PARTITION BY  [Year]
		ORDER BY [Year],[Quarter],[Month] ASC
		) - [Sum] -- this is current month
		) / [Sum] AS [%Change]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND StoreNo = 'S00014'
ORDER BY [Year],[Quarter],[Month]
GO

/**********************************************/
/* TASK 4 - PERCENTILE_CONT & PERCENTILE_DISC */
/**********************************************/

/******************************************************/
/* LISTING 7.19 - PERCENTILE_CONT & PERCENTILE_DISC() */
/******************************************************/

/*********************/
/* PRECENTILE_CONT() */
/*********************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreName]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
	  ,PERCENTILE_CONT(.25) 
	  WITHIN GROUP (ORDER BY [Sum])
	  OVER (
		PARTITION BY [Year]
		)   AS [25% Continuous]
			  ,PERCENTILE_CONT(.50) 
	  WITHIN GROUP (ORDER BY [Sum])
	  OVER (
		PARTITION BY [Year]
		)   AS [50% Continuous]
			  ,PERCENTILE_CONT(.75) 
	  WITHIN GROUP (ORDER BY [Sum])
	  OVER (
		PARTITION BY [Year]
		)   AS [75% Continuous]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2012
AND StoreName = 'New York City Store'
ORDER BY [Year],[Month]
GO

/*********************/
/* PRECENTILE_DISC() */
/*********************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreName]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
	  ,PERCENTILE_DISC(.25) 
	  WITHIN GROUP (ORDER BY [Sum])
	  OVER (
		PARTITION BY [Year]
		)   AS [25% DiscContinuous]
			  ,PERCENTILE_DISC(.50) 
	  WITHIN GROUP (ORDER BY [Sum])
	  OVER (
		PARTITION BY [Year]
		)   AS [50% DiscContinuous]
			  ,PERCENTILE_DISC(.75) 
	  WITHIN GROUP (ORDER BY [Sum])
	  OVER (
		PARTITION BY [Year]
		)   AS [75% DiscContinuous]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2012
AND StoreName = 'New York City Store'
ORDER BY [Year],[Month]
GO

/**************************/
/* TASK 6 - FIRST_VALUE() */
/**************************/

/********************************/
/* LISTING 7.20 - FIRST_VALUE() */
/********************************/

-- show lowest selling store for a product

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,FIRST_VALUE([StoreNo]) OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[Sum] ASC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS LowestSeller
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] BETWEEN 2011 AND 2020
AND StoreName IN('New York City Store','Albany City Store')
ORDER BY [Year],[Month]
GO

/*************************/
/* TASK 7 - LAST_VALUE() */
/*************************/

/*******************************/
/* LISTING 7.21 - LAST_VALUE() */
/*******************************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,LAST_VALUE([StoreNo]) OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[Sum] ASC
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS HighestSeller
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] = 2011
AND StoreName IN('New York City Store','Albany City Store','Minneapolis Store')
ORDER BY [Year],[Month]
GO

/*********/
/* BONUS */
/*********/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
      ,FIRST_VALUE([StoreNo]) OVER (
		PARTITION BY [Year]--,[Month]
		ORDER BY [Year],[Month],[Sum] ASC
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

		) AS LowestSeller
	  ,LAST_VALUE([StoreNo]) OVER (
		PARTITION BY [Year]--,[Month]
		ORDER BY [Year],[Month],[Sum] ASC
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS HighestSeller
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] = 2011 
ORDER BY [Year],[Month]
GO

/*************************/
/* TASK 8 - PERCENT_RANK */
/*************************/

/*********************************/
/* LISTING 7.22 - PERCENT_RANK() */
/*********************************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreName]
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
	  ,CONVERT(DECIMAL(10,2),PERCENT_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[Sum] ASC
		) )  AS [% Ranking]
	  ,CONVERT(DECIMAL(10,2),RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Sum] DESC
		) )  AS [SalesRank]
	  ,CONVERT(DECIMAL(10,2),DENSE_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Sum] DESC
		) )  AS [SalesDenseRank]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND [Year] = 2011
AND [Month] = 1
AND StoreName = 'New York City Store';
GO 

/*********/
/* BONUS */
/*********/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[ProductNo]
      ,[ProductName]
	  ,[Sum] AS CurrentMonth
	  ,CONVERT(DECIMAL(10,2),PERCENT_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Year],[Month],[Sum] ASC
		) )  AS [% Ranking]
	  ,CONVERT(DECIMAL(10,2),RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Sum] DESC
		) )  AS [SalesRank]
	  ,CONVERT(DECIMAL(10,2),DENSE_RANK() OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Sum] DESC
		) )  AS [SalesDenseRank]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] = 2011
AND StoreName IN(
	'New York City Store','Albany City Store','Minneapolis Store'
	)
GO 

/*************************/
/*  TASK 9 - CUME_DIST() */
/*************************/

/************/
/* REMINDER */
/************/

DECLARE @CUME_DIST_EXAMPLE TABLE (
ROW_KEY INT		IDENTITY (1,1) NOT NULL,
COL_VALUE		FLOAT NOT NULL
);

INSERT INTO @CUME_DIST_EXAMPLE VALUES
(10.0),
(11.0),
(14.0),
(15.0),
(20.0),
(21.0),
(22.0),
(23.0),
(24.0),
(25.0);

DECLARE @NUM_ROWS FLOAT;
SET @NUM_ROWS = 10;

SELECT ROW_KEY,
	COL_VALUE,CUME_DIST() OVER( ORDER BY ROW_KEY) AS CUME_DIST,
	(
		SELECT count(*) 
		FROM @CUME_DIST_EXAMPLE
		WHERE COL_VALUE <= A.COL_VALUE
	)/@NUM_ROWS	AS MY_CUME_DIST
FROM @CUME_DIST_EXAMPLE A
GO

/*************************/
/* LET'S INTRODUCE A TIE */
/*************************/

DECLARE @CUME_DIST_EXAMPLE TABLE (
ROW_KEY INT		IDENTITY (1,1) NOT NULL,
COL_VALUE		FLOAT NOT NULL
);

INSERT INTO @CUME_DIST_EXAMPLE VALUES
(10.0),
(11.0),
(14.0),
(15.0),
(20.0),
(25.0),
(22.0),
(23.0),
(24.0),
(25.0);

DECLARE @NUM_ROWS FLOAT;
SET @NUM_ROWS = 10;

SELECT ROW_KEY,
	COL_VALUE,CUME_DIST() OVER( ORDER BY ROW_KEY) AS CUME_DIST,
	(
		SELECT count(*) 
		FROM @CUME_DIST_EXAMPLE
		WHERE COL_VALUE <= A.COL_VALUE
	)/@NUM_ROWS	AS MY_CUME_DIST,
	ROW_KEY/@NUM_ROWS AS WORKS_WITH_TIES
FROM @CUME_DIST_EXAMPLE A
ORDER BY A.COL_VALUE
GO


/******************************/
/* LISTING 7.23 - CUME_DIST() */
/******************************/

SELECT [Year] AS ReportingYear
	  ,[Month] AS ReportingMonth
	  ,[StoreNo]
	  ,[StoreName]
	  ,[Sum] AS CurrentMonth
	 ,CUME_DIST() 
	  OVER (
		PARTITION BY [Year],[Month]
		ORDER BY [Sum] ASC
		) AS [Cumulative Distribution]
FROM DIM.SALES_VIEW
WHERE [ProductCategoryCode] = 'PC001'
AND ProductNo = 'P0000001103'
AND [Year] = 2011 
AND [Month] = 1
GO


