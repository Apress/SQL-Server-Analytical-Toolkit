-- Listing  1.1 – SUM() function with the OVER() clause.
SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER(
		PARTITION BY OrderYear
		ORDER BY OrderMonth ASC
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS AmountTotal
FROM OverExample
ORDER BY OrderYear,OrderMonth
GO


-- Listing  1.2 – SQL Server 2022 Named Window feature
SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER SalesWindow AS SQPRangeUPCR
FROM OverExample
WINDOW SalesWindow AS (
		PARTITION BY OrderYear
		ORDER BY OrderMonth
		RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		);
GO
-- Listing  1.3 – Creating the test table
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
	(5,2010,5,10),
	(6,2010,5,10),
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
	(18,2011,5,10),
	(19,2011,5,10),
	(20,2011,6,10),
	(21,2011,7,10),
	(22,2011,7,10),
	(23,2011,7,10),
	(24,2011,8,10),
	(25,2011,9,10),
	(26,2011,10,10),
	(27,2011,11,10),
	(28,2011,12,10);

-- Listing  1.4 – Range, current row, and unbounded following
SELECT Row,[Year],[Month],Amount,
	SUM(Amount) OVER (
		PARTITION BY [Year]
		ORDER BY [Month]
		RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
		) AS RollingSalesTotal
	FROM #TestTable
ORDER BY [Year],[Month] ASC
GO
-- Listing  1.5 – Practice Table OverExample
CREATE TABLE OverExample(
	OrderYear   SMALLINT,
	OrderMonth  SMALLINT,
	SalesAmount DECIMAL(10,2)
	);

INSERT INTO OverExample VALUES
(2010,1,10000.00),
(2010,2,10000.00),
(2010,2,10000.00),
--missing rows
(2010,8,10000.00),
(2010,8,10000.00),
(2010,9,10000.00),
(2010,10,10000.00),
(2010,11,10000.00),
(2010,12,10000.00),
-- 2011
(2011,1,10000.00),
(2011,2,10000.00),
(2011,2,10000.00),
 --missing rows
(2011,10,10000.00),
(2011,11,10000.00),
(2011,12,10000.00);
GO
-- Listing  1.6 - Scenario 1
SELECT OrderYear,OrderMonth,SalesAmount,
	SUM(SalesAmount) OVER (
		) AS NPBNOB,
	SUM(SalesAmount) OVER (
		PARTITION BY OrderYear
		) AS PBNOB,
	SUM(SalesAmount) OVER (
		PARTITION BY OrderYear
		ORDER BY OrderMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS PBOBUPUF	
FROM OverExample;
GO
-- Listing  1.7 – Scenario 2 - various default versus window frame clauses
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
-- Listing  1.8 – ROWS versus RANGE comparison
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
-- Listing  1.9a – ORDER BY without subquery

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
-- Listing  1.9b – ORDER BY with subquery
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

-- Listing  1.10 – Named Windows
 SELECT OrderYear
      ,OrderMonth
      ,SUM(SalesAmount) OVER SalesWindow AS TotalSales
FROM dbo.OverExample
WINDOW SalesWindow AS (
	PARTITION BY OrderYear
	ORDER BY OrderMonth
	RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	)
GO
