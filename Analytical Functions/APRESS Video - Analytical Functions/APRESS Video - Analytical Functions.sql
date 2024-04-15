/**********************************************/
/* Analytical Functions                       */
/* Created By: Angelo R Bobak                 */
/* Created: 08/15/2023                        */
/* Revised: 02/24/2024                        */
/* Video Demo                                 */
/**********************************************/

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

/*********************************************************************/
/* Prep Work - Create and load salesperson monthly sales performance */
/*********************************************************************/

USE [APSalesVideo]
GO

/****************************/
/* START WITH A CLEAN SLATE */
/****************************/

DROP TABLE IF EXISTS #SalePersonPerformance
GO

DECLARE @SaleSPerformanceYear TABLE (
	PerformanceYear SMALLINT  NOT NULL
	);

INSERT INTO @SalesPerformanceYear VALUES
(2001),(2002),(2003),(2004),(2005),(2006),(2007),(2008),(2009),(2010);

DECLARE @SalesPerformanceMonth TABLE (
	PerformanceMonth SMALLINT  NOT NULL
	);

INSERT INTO @SalesPerformanceMonth VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

DECLARE @SaleSPerson TABLE (
	SalesPersonId VARCHAR(16) NOT NULL
	);

INSERT INTO @SalesPerson VALUES
('S000001'),('S000002'),('S000003'),('S000004'),('S000005'),('S000006'),('S000007'),('S000008'),('S000009'),('S000010');

DROP TABLE IF EXISTS #SalePersonPerformance;

CREATE TABLE #SalePersonPerformance(
	PerformanceYear  SMALLINT     NOT NULL,
	PerformanceMonth SMALLINT      NOT NULL,
	SalesPersonId    VARCHAR(16)   NOT NULL,
	Sales            DECIMAL(10,2) NOT NULL
	);

INSERT INTO #SalePersonPerformance
SELECT SPY.PerformanceYear,SPM.PerformanceMonth,SP.SalesPersonId
	   ,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) *	50.00) AS [MonthlySales]
FROM @SalesPerformanceYear SPY
CROSS JOIN
@SalesPerformanceMonth SPM
CROSS JOIN @SalesPerson SP
ORDER BY 1,2,3
GO

SELECT * FROM #SalePersonPerformance
GO

/*****************************/
/* Example 1 - FIRST_VALUE() */
/*****************************/

USE [APSalesVideo]
GO

SELECT
	PerformanceYear,
	PerformanceMonth,
	SalesPersonId,
	Sales,
	FIRST_VALUE(Sales) OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	) AS FirstValue
FROM #SalePersonPerformance
WHERE PerformanceYear IN(2002,2003)
--AND SaleSPersonId = 'S000001'
AND SaleSPersonId IN('S000001','S000002')
GO


/****************************/
/* Example 2 - LAST_VALUE() */
/****************************/

USE [APSalesVideo]
GO

SELECT
	PerformanceYear
	,PerformanceMonth
	,SalesPersonId
	,Sales
	,FIRST_VALUE(Sales) OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	) AS FirstValue
	,LAST_VALUE(Sales) OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	) AS LastValue
	,LAST_VALUE(Sales) OVER (
		PARTITION BY PerformanceYear
		ORDER BY PerformanceYear
	) AS LastValue
FROM #SalePersonPerformance
WHERE PerformanceYear IN(2002,2003)
AND SaleSPersonId = 'S000001'
GO

/*********************/
/* Example 3 - LAG() */
/*********************/

USE [APSalesVideo]
GO

SELECT
	PerformanceYear,
	PerformanceMonth,
	SalesPersonId,
	Sales,
	LAG(Sales,1,0) OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	) AS PriorMonthSales
FROM #SalePersonPerformance
GO

SELECT
	PerformanceYear,
	PerformanceMonth,
	SalesPersonId,
	Sales,
	LAG(Sales,1,0) OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	) AS PriorMonthSales,
	Sales - 
	LAG(Sales,1,0) OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth,SalesPersonId
	) AS Delta
FROM #SalePersonPerformance
GO

/**********************/
/* Example 4 - LEAD() */
/**********************/

USE [APSalesVideo]
GO

SELECT
	PerformanceYear,
	PerformanceMonth,
	SalesPersonId,
	Sales,
	LEAD(Sales,1,0) OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	) AS LeadMonthSales
FROM #SalePersonPerformance
GO

/******************************/
/* Example 5 - PERCENT_RANK() */
/******************************/

USE [APSalesVideo]
GO

SELECT
	PerformanceYear,
	PerformanceMonth,
	SalesPersonId,
	Sales,
	PERCENT_RANK() OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	) AS PctRankMonthSales1,
	FORMAT(PERCENT_RANK() OVER (
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	),'P') AS PctRankMonthSales
FROM #SalePersonPerformance
WHERE PerformanceYear = 2002
AND SaleSPersonId = 'S000001'
GO

/***************************/
/* Example 6 - CUME_DIST() */
/***************************/

USE [APSalesVideo]
GO

DECLARE @SaleSPerformanceYear TABLE (
	PerformanceYear SMALLINT  NOT NULL
	);

INSERT INTO @SalesPerformanceYear VALUES
(2001),(2002),(2003),(2004),(2005),(2006),(2007),(2008),(2009),(2010);

DECLARE @SalesPerformanceMonth TABLE (
	PerformanceMonth SMALLINT  NOT NULL
	);

INSERT INTO @SalesPerformanceMonth VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

DECLARE @SaleSPerson TABLE (
	SalesPersonId VARCHAR(16) NOT NULL
	);

INSERT INTO @SalesPerson VALUES
('S000001'),('S000002'),('S000003'),('S000004'),('S000005'),('S000006'),('S000007'),('S000008'),('S000009'),('S000010');

DROP TABLE IF EXISTS #SalePersonPerformance;

CREATE TABLE #SalePersonPerformance(
	PerformanceYear  SMALLINT     NOT NULL,
	PerformanceMonth SMALLINT      NOT NULL,
	SalesPersonId    VARCHAR(16)   NOT NULL,
	Sales            DECIMAL(10,2) NOT NULL
	);

INSERT INTO #SalePersonPerformance
SELECT SPY.PerformanceYear,SPM.PerformanceMonth,SP.SalesPersonId
	   ,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) *	50.00) AS [MonthlySales]
FROM @SalesPerformanceYear SPY
CROSS JOIN
@SalesPerformanceMonth SPM
CROSS JOIN @SalesPerson SP
ORDER BY 1,2,3
GO

SELECT
	PerformanceYear
	,PerformanceMonth
	,SalesPersonId
	,Sales
	,FORMAT(PERCENT_RANK() OVER (
		-- uncomment for more years and sales persons
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	),'P') AS PctRank
	,FORMAT(CUME_DIST() OVER (
		-- uncomment for more years and sales persons
		PARTITION BY PerformanceYear,SalesPersonId
		ORDER BY PerformanceMonth
	),'P') AS CumeDist
FROM #SalePersonPerformance
WHERE PerformanceYear IN(2002,2003)
--AND SaleSPersonId = 'S000001'
GO

/*********************************/
/* Example 7 - PERCENTILE_CONT() */
/*********************************/

USE [APSalesVideo]
GO

SELECT
	PerformanceYear
	,PerformanceMonth
	,SalesPersonId
	,Sales
	,PERCENTILE_CONT(.25) 
		WITHIN GROUP (ORDER BY Sales asc)
		OVER(
			PARTITION BY PerformanceYear
		) AS [25th Percentile]
	,PERCENTILE_CONT(.50) 
		WITHIN GROUP (ORDER BY Sales asc)
		OVER(
			PARTITION BY PerformanceYear
		) AS [50th Percentile]
	,PERCENTILE_CONT(.75) 
		WITHIN GROUP (ORDER BY Sales asc)
		OVER(
			PARTITION BY PerformanceYear
		) AS [75th Percentile]
FROM #SalePersonPerformance
WHERE PerformanceYear IN(2002,2003)
AND SaleSPersonId = 'S000001'
GO

/*********************************/
/* Example 8 - PERCENTILE_DISC() */
/*********************************/

USE [APSalesVideo]
GO

SELECT
	PerformanceYear
	,PerformanceMonth
	,SalesPersonId
	,Sales
	,PERCENTILE_DISC(.25) 
		WITHIN GROUP (ORDER BY Sales asc)
		OVER(
			PARTITION BY PerformanceYear
		) AS [25th Percentile]
	,PERCENTILE_DISC(.50) 
		WITHIN GROUP (ORDER BY Sales asc)
		OVER(
			PARTITION BY PerformanceYear
		) AS [50th Percentile]
	,PERCENTILE_DISC(.75) 
		WITHIN GROUP (ORDER BY Sales asc)
		OVER(
			PARTITION BY PerformanceYear
		) AS [75th Percentile]
FROM #SalePersonPerformance
WHERE PerformanceYear IN(2002,2003)
AND SaleSPersonId = 'S000001'
GO

DROP TABLE IF EXISTS #SalePersonPerformance
GO