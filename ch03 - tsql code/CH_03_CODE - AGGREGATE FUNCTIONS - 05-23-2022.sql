/*******************************************************/
/* Chapter 3 Examples - SQL Server aggregate functions */
/*******************************************************/

USE TEST
GO

/****************************************/
/* Here are the functions we will cover */
/****************************************/

-- COUNT()
-- COUNT_BIG()
-- SUM()
-- MAX()
-- MIN()
-- AVG()
-- GROUPING()
-- STRING_AGG()
-- STDEV()
-- STDEVP()
-- VAR()
-- VARP()
-- OVER()

/****************/
/* The Data Set */
/****************/

USE TEST
GO

DROP TABLE IF EXISTS AGG_FUNC_EXAMPLE_DATA
GO

/******************************/
/* Listing 3.1 - the data set */
/******************************/

CREATE TABLE AGG_FUNC_EXAMPLE_DATA
(
KEY_COL INTEGER IDENTITY NOT NULL,
CATEGORY VARCHAR(64) NOT NULL,
SALES_AMT DECIMAL(10,2) NOT NULL
)
GO

INSERT INTO AGG_FUNC_EXAMPLE_DATA
VALUES
('Category A',100.00),
('Category A',100.00), -- notice the duplicate
('Category A',120.00),
('Category A',130.00),
('Category B',200.00),
('Category B',200.00), -- notice the duplicate
('Category B',230.00),
('Category B',240.00),
('Category C',300.00),
('Category C',300.00), -- notice the duplicate
('Category C',340.00),
('Category C',350.00),
('Category D',400.00),
('Category D',400.00), -- notice the duplicate
('Category D',420.00),
('Category D',430.00);

SELECT *
FROM AGG_FUNC_EXAMPLE_DATA
GO

/**********/
/* SYNTAX */
/**********/

/*
SELECT COUNT( * | ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

/**************************************/
/* Listing 3.2 - the COUNT() function */
/**************************************/

SELECT COUNT(*) AS COUNT_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT COUNT(ALL SALES_AMT) AS COUNT_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT COUNT(DISTINCT SALES_AMT) AS COUNT_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- let's introduce the CATEGORY column

SELECT CATEGORY,COUNT(ALL SALES_AMT) AS COUNT_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,COUNT(DISTINCT SALES_AMT) AS COUNT_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

/******************************************/
/* Listing 3.3 - the COUNT_BIG() function */
/******************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT COUNT_BIG( * | ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

SELECT COUNT_BIG(*) AS COUNT_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO


SELECT COUNT_BIG(SALES_AMT) AS COUNT_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT COUNT_BIG(ALL SALES_AMT) AS COUNT_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT COUNT_BIG(DISTINCT SALES_AMT) AS COUNT_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- let's add a dimension

SELECT CATEGORY,COUNT_BIG(ALL SALES_AMT)
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,COUNT_BIG(DISTINCT SALES_AMT)
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

/************************************/
/* Listing 3.4 - the SUM() function */
/************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT SUM( ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

SELECT SUM(FAILURE) AS SUM_ALL
FROM FACT.EQUIPMENT_FAILURE
GO

SELECT SUM(ALL FAILURE) AS SUM_ALL
FROM FACT.EQUIPMENT_FAILURE
GO

SELECT SUM(DISTINCT FAILURE) AS SUM_DISTINCT
FROM FACT.EQUIPMENT_FAILURE
GO

-- add the equipment type dimension column
SELECT ET.[EQUIPMENT_DESCRIPTION],SUM(ALL FAILURE) AS SUM_ALL
FROM FACT.EQUIPMENT_FAILURE EF
JOIN [DIM].[EQUIPMENT_TYPE] ET
ON EF.[EQUIPMENT_TYPE_KEY] = ET.[EQUIPMENT_TYPE_KEY]
GROUP BY ET.[EQUIPMENT_DESCRIPTION]
GO

SELECT ET.[EQUIPMENT_DESCRIPTION],SUM(DISTINCT FAILURE) AS SUM_ALL
FROM FACT.EQUIPMENT_FAILURE EF
JOIN [DIM].[EQUIPMENT_TYPE] ET
ON EF.[EQUIPMENT_TYPE_KEY] = ET.[EQUIPMENT_TYPE_KEY]
GROUP BY ET.[EQUIPMENT_DESCRIPTION]
GO

/************************************/
/* Listing 3.5 - the MAX() function */
/************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT MAX(  | ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/


SELECT MAX(SALES_AMT) AS MAX_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT MAX(ALL SALES_AMT) AS MAX_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT MAX(DISTINCT SALES_AMT) AS MAX_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- next two yield same results
SELECT CATEGORY,MAX(ALL SALES_AMT) AS MAX_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,MAX(DISTINCT SALES_AMT) AS MAX_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,MAX(SALES_AMT)  AS MAX_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
HAVING MAX(SALES_AMT) < 400
GO


/************************************/
/* Listing 3.6 - the MIN() function */
/************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT MIN(ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

SELECT MIN(SALES_AMT) AS MIN_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT MIN(ALL SALES_AMT) AS MIN_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT MIN(DISTINCT SALES_AMT) AS MIN_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- next two yield same results
SELECT CATEGORY,MIN(ALL SALES_AMT) AS MIN_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,MIN(DISTINCT SALES_AMT) AS MIN_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,MIN(SALES_AMT)  AS MIN_ALL_SALES
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
HAVING MIN(SALES_AMT) BETWEEN 150 and 400
GO

/************************************/
/* Listing 3.6 - the AVG() function */
/************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT AVG(ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

SELECT AVG(SALES_AMT) AS AVG_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT AVG(ALL SALES_AMT) AS AVG_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT AVG(DISTINCT SALES_AMT) AS AVG_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- next two do not yield same results
SELECT CATEGORY,AVG(ALL SALES_AMT) AS AVG_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,AVG(DISTINCT SALES_AMT) AS AVG_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,
	CONVERT(DECIMAL(10,2),AVG(ALL SALES_AMT)) AS AVG_ALL,
	MAX(ALL SALES_AMT) AS MAX_ALL,
	MIN(ALL SALES_AMT) AS MIN_ALL,
	SUM(ALL SALES_AMT) AS SUM_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO


/************************/
/* MORE EFFICIENT QUERY */
/************************/

SELECT CATEGORY,
	AVG(ALL SALES_AMT) AS AVG_ALL,
	AVG(DISTINCT SALES_AMT) AS AVG_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

/***************************************/
/* Listing 3.7 - the GROUPING function */
/***************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT GROUPING(< column name> ) [Column Alias]
FROM [Table Name]
GROUP BY <column list> WITH ROLLUP
GO
*/

SELECT CATEGORY,SALES_AMT,
	SUM(SALES_AMT) AS SUM_SALES,
	GROUPING(SALES_AMT) AS ROLLUP_POS
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY,SALES_AMT WITH ROLLUP
ORDER BY CATEGORY ASC, GROUPING(SALES_AMT)
GO

/***************************************/
/* Listing 3.8 - the GROUPING function */
/* with CASE block                     */
/***************************************/

SELECT CATEGORY,
	SUB_CATEGORY,
	SALES_AMT,
	SUM(SALES_AMT) AS SUM_SALES,
	CASE
		WHEN GROUPING(SALES_AMT) = 1 THEN 'ROLLUP'
		ELSE 'NOT ROLLED UP' 
	END AS ROLLUP_POS
FROM [dbo].[RANK_FUNC_EXAMPLE_DATA]
GROUP BY 
	CATEGORY,
	SUB_CATEGORY,
	SALES_AMT WITH ROLLUP
ORDER BY CATEGORY ASC,[SUB_CATEGORY] ASC, GROUPING(SALES_AMT)
GO

/*******************************************/
/* Listing 3.9 - the STRING_AGG() function */
/*******************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT STRING_AGG(column name,delimiter) AS [Column Alias]
FROM [Table Name]
GO
*/

SELECT STRING_AGG(CATEGORY,',') AS STRING_AGG_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT DISTINCT STRING_AGG(CATEGORY,',') AS DISTINCT_STRING_AGG
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT STRING_AGG(CATEGORY,',') AS TRICKY_STRING_AGG
FROM (
	SELECT DISTINCT CATEGORY 
	FROM AGG_FUNC_EXAMPLE_DATA
	) AS TEMP_TBL
GO


/***************************************/
/* Listing 3.10 - the STDEV() function */
/***************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT STDEV( * | ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

SELECT STDEV(SALES_AMT) AS STDEV_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT STDEV(ALL SALES_AMT) AS STDEV_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT STDEV(DISTINCT SALES_AMT) AS STDEV_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- next two do not yield same results
SELECT CATEGORY,STDEV(ALL SALES_AMT) AS STDEV_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,STDEV(DISTINCT SALES_AMT) AS STDEV_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

-- Here is how to do it with TSQL

USE TEST
GO

DECLARE @Average FLOAT;

SELECT @Average = AVG(SALES_AMT) 
FROM AGG_FUNC_EXAMPLE_DATA;

SELECT POWER((SALES_AMT - @Average),2) AS SquaredResults
	FROM AGG_FUNC_EXAMPLE_DATA;

SELECT SUM(POWER((SALES_AMT - @Average),2))/(COUNT(*) - 1) AS VARIANCE
	FROM AGG_FUNC_EXAMPLE_DATA;

SELECT SQRT(SUM(POWER((SALES_AMT - @Average),2))/(COUNT(*) - 1)) AS StandardDeviation
	FROM AGG_FUNC_EXAMPLE_DATA
GO

-- check your results above with these results
SELECT
	AVG(SALES_AMT) AS AVG_ALL,
	STDEV(SALES_AMT) AS STDEV,
	VAR(SALES_AMT) AS VAR
FROM AGG_FUNC_EXAMPLE_DATA
GO

/*****************************************************/
/* Listing 3.11 - the MyNormaDistribution() function */
/*****************************************************/

CREATE FUNCTION [dbo].[MyNormalDistribution]
(
@Value DECIMAL (10, 2), @Mean DECIMAL (10, 2), @Stdev DECIMAL (10, 2)
)
RETURNS DECIMAL (10, 2)
AS
BEGIN
    DECLARE @pi AS DECIMAL (10, 2);
    DECLARE @norm_dist AS DECIMAL (10, 6);
    SET @pi = PI();
    SET @norm_dist = (1 / (@Stdev * SQRT(2 * @pi)))
		* EXP(-.5 * POWER(@Value - @Mean, 2) 
			/ POWER(@stdev, 2));
    RETURN @norm_dist;
END
GO

/***************************************************/
/* Listing 3.12 - generating a normal distribution */
/***************************************************/

DECLARE @ValveFailure TABLE (
PLANT VARCHAR(64) NOT NULL,
FAILURES FLOAT NOT NULL
);

INSERT @ValveFailure VALUES
('PLANT 1',10),
('PLANT 1',9),
('PLANT 1',5),
('PLANT 1',7),
('PLANT 1',8),
('PLANT 1',6),
('PLANT 1',3),
('PLANT 1',9),
('PLANT 1',7),
('PLANT 1',4);

DECLARE @Mean FLOAT;
DECLARE @Stdev FLOAT;
DECLARE @Plant FLOAT;

SELECT 
	@stdev = STDEV(FAILURES),
	@mean = AVG(FAILURES)
FROM @ValveFailure;

PRINT 'Mean: ' + CONVERT(VARCHAR,(@Mean));
PRINT 'Stdev: ' + CONVERT(VARCHAR,(@Stdev));

SELECT [PLANT],
	FAILURES,
	[dbo].[MyNormalDistribution] (
		FAILURES,@Mean,@Stdev
		) AS MY_NORM_DIST 
FROM @ValveFailure
ORDER BY [PLANT],FAILURES;
GO


/****************************************/
/* Listing 3.13 - the STDEVP() function */
/****************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT STDEVP( * | ALL | D
ISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/


SELECT STDEVP(SALES_AMT) AS STDEVP_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT STDEVP(ALL SALES_AMT) AS STDEVP_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT STDEVP(DISTINCT SALES_AMT) AS STDEVP_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- next two do not yield same results
SELECT CATEGORY,STDEVP(ALL SALES_AMT) AS STDEVP_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,STDEVP(DISTINCT SALES_AMT) AS STDEVP_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

/*************************************/
/* Listing 3.14 - the VAR() function */
/*************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT VAR( * | ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

SELECT VAR(SALES_AMT) AS VAR_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT VAR(ALL SALES_AMT) AS VAR_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT VAR(DISTINCT SALES_AMT) AS VAR_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- next two do not yield same results
SELECT CATEGORY,VAR(ALL SALES_AMT) AS VAR_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,VAR(DISTINCT SALES_AMT) AS VAR_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

/***************************************************/
/* Listing 3.15 - calculating variance on your own */
/***************************************************/

DECLARE @mean FLOAT;
DECLARE @VAR FLOAT;
DECLARE @count FLOAT;
DECLARE @sumsqr FLOAT;
DECLARE @myVAR FLOAT;

SELECT 
	@mean = AVG(SALES_AMT),
	@var = VAR(SALES_AMT),
	@count = COUNT(*)
FROM AGG_FUNC_EXAMPLE_DATA;

PRINT 'MEAN: ' + CONVERT(VARCHAR,@mean);
PRINT 'VAR: ' + CONVERT(VARCHAR,@var);
PRINT 'COUNT: ' + CONVERT(VARCHAR,@count);

--SELECT (@mean - SALES_AMT),SQUARE(@mean - SALES_AMT) AS Squared
--FROM AGG_FUNC_EXAMPLE_DATA;

--SELECT SUM(SQUARE(@mean - SALES_AMT)) AS SumSquared
--FROM AGG_FUNC_EXAMPLE_DATA;

SELECT @var AS VAR,
	(
	SUM(
		SQUARE(@mean - SALES_AMT) -- difference squared
	   ) -- sum of the differences squared
	)
	/ (@count - 1) -- divide by N - 1
AS MyVar
FROM AGG_FUNC_EXAMPLE_DATA;
GO

/**************************************/
/* Listing 3.16 - the VARP() function */
/**************************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT VARP( * | ALL | DISTINCT ) [Column Alias]
FROM [Table Name] 
GO
*/

SELECT VARP(SALES_AMT) AS VARP_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT VARP(ALL SALES_AMT) AS VARP_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT VARP(DISTINCT SALES_AMT) AS VARP_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GO

-- next two do not yield same results
SELECT CATEGORY,VARP(ALL SALES_AMT) AS VARP_ALL
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

SELECT CATEGORY,VARP(DISTINCT SALES_AMT) AS VARP_DISTINCT
FROM AGG_FUNC_EXAMPLE_DATA
GROUP BY CATEGORY
GO

/***********************************************/
/* Listing 3.17 - calculating VARP on your own */
/***********************************************/

DECLARE @mean FLOAT;
DECLARE @var FLOAT;
DECLARE @varp FLOAT;
DECLARE @count FLOAT;
DECLARE @sumsqr FLOAT;
DECLARE @myVAR FLOAT;
DECLARE @myVARP FLOAT;

SELECT 
	@mean = AVG(SALES_AMT),
	@var = VAR(SALES_AMT),
	@varp = VARP(SALES_AMT),
	@count = COUNT(*)
FROM AGG_FUNC_EXAMPLE_DATA;

PRINT 'MEAN: ' + CONVERT(VARCHAR,@mean);
PRINT 'VAR: ' + CONVERT(VARCHAR,@var);
PRINT 'COUNT: ' + CONVERT(VARCHAR,@count);

SELECT @var AS VAR,
	(
	SUM(
		SQUARE(@mean - SALES_AMT) -- difference squared
	   ) -- sum of the differences squared
	)
	/ (@count - 1) -- divide by N - 1
AS MyVar,
	@varp AS VARP,
	(
	SUM(
		SQUARE(@mean - SALES_AMT) -- difference squared
	   ) -- sum of the differences squared
	)
	/ @count
AS MyVarp
FROM AGG_FUNC_EXAMPLE_DATA;
GO


/*********************************************************/
/* Listing 3.18 - applying OVER() clause with boundaries */
/*********************************************************/

DECLARE @CATEGORY_EXAMPLE TABLE (
CATEGORY CHAR(1) NOT NULL,
VALUE SMALLINT
);

INSERT INTO @CATEGORY_EXAMPLE VALUES
	('A',10),
	('B',20),
	('C',30),
	('D',40),
	('E',50);

--ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

SELECT CATEGORY,[VALUE],
	SUM([VALUE]) OVER(
		--PARTITION BY CATEGORY 
		ORDER BY [VALUE] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS SUM_UNBOUNDED_PRECEEDING_AND_CURRENT
FROM @CATEGORY_EXAMPLE;

-- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
SELECT CATEGORY,[VALUE],
	SUM([VALUE]) OVER(
		--PARTITION BY CATEGORY 
		ORDER BY [VALUE] ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS SUM_UNBOUNDED_PRECEEDING_AND_FOLLOWING
FROM @CATEGORY_EXAMPLE;

-- ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING

SELECT CATEGORY,[VALUE],
	SUM([VALUE]) OVER(
		--PARTITION BY CATEGORY 
		ORDER BY [VALUE] ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
		) SUM_ROWS_BETWEEN_CURRENT_AND_UNBOUNDED_FOLLOWING
FROM @CATEGORY_EXAMPLE;
GO

/**********************************/
/* Listing 3.19 - another example */
/**********************************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column,List
	Aggregate Function ( | ALL ) -- distinct not allowed
	OVER (
	 | PARTITION BY Column List | ORDER BY Column List
	) AS [Column Alias]
FROM [Table Name] 
GO
*/

SELECT [KEY_COL], 
	[CATEGORY],
	SUM(SALES_AMT) OVER() AS SUM_SALES,
	AVG(ALL [SALES_AMT]) OVER() AS AVERAGE
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT [KEY_COL], 
	[CATEGORY],
	SALES_AMT AS SALES_AMT,
	SUM(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT ROWS 
			BETWEEN 
				UNBOUNDED PRECEDING AND CURRENT ROW
		) AS SUM_BY_CAT,
	AVG(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY CATEGORY
		) AS AVG_BY_CAT
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT [KEY_COL], 
	[CATEGORY],
	SALES_AMT AS SALES_AMT,
	SUM(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT ROWS 
			BETWEEN 
				UNBOUNDED PRECEDING AND CURRENT ROW
		) AS SUM_BY_CAT_UNBOUNDED,
	SUM(SALES_AMT) OVER(
		PARTITION BY CATEORY
		ORDER BY SALES_AMT ROWS 
	) AS SUM_BY_CAT,
	AVG(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY CATEGORY
		) AS AVG_BY_CAT
FROM AGG_FUNC_EXAMPLE_DATA
--GROUP BY [KEY_COL],[CATEGORY],SALES_AMT
GO

/***************************************/
/* Listing 3.20 - comparing row frames */
/***************************************/

SELECT [KEY_COL], 
	[CATEGORY],
	SALES_AMT AS SALES_AMT,
	SUM(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT ROWS 
			BETWEEN 
				UNBOUNDED PRECEDING AND CURRENT ROW
		) AS SUM_BY_CAT_UNBOUNDED_PRECEDING_AND_CURRENT,
	SUM(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT ROWS 
			BETWEEN 
				UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS SUM_BY_CAT_UNBOUNDED_PRECEDING_AND_FOLLOWING

FROM AGG_FUNC_EXAMPLE_DATA
GO

/****************************************************/
/* Listing 3.21 - empty OVER() versus framed OVER() */
/****************************************************/

SELECT [KEY_COL], 
	[CATEGORY],
	SUM(SALES_AMT) OVER() AS SUM_SALES,
	AVG(ALL [SALES_AMT]) OVER() AS AVERAGE
FROM AGG_FUNC_EXAMPLE_DATA
GO

SELECT [KEY_COL], 
	[CATEGORY],
	SALES_AMT AS SALES_AMT,
	SUM(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT ROWS 
			BETWEEN 
				UNBOUNDED PRECEDING AND CURRENT ROW
		) AS SUM_BY_CAT,
	AVG(SALES_AMT) OVER(
		PARTITION BY CATEGORY
		ORDER BY CATEGORY
		) AS AVG_BY_CAT
FROM AGG_FUNC_EXAMPLE_DATA
GO


