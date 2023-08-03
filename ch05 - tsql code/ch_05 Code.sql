/********************************************************************/
/* Chapter 5 Examples - Introducing SQL Server Analytical Functions */
/********************************************************************/

USE TEST
GO

/****************************************/
/* Here are the functions we will cover */
/****************************************/

-- CUME_DIST()
-- FIRST_VALUE()
-- LAST_VALUE()
-- LAG()
-- LEAD()
-- PERCENT_RANK()
-- PERCENTILE_CONT()
-- PERCENTILE_DISC()

/****************/
/* The Data Set */
/****************/

USE TEST
GO

DROP TABLE IF EXISTS RANK_FUNC_EXAMPLE_DATA
GO

CREATE TABLE RANK_FUNC_EXAMPLE_DATA
(
KEY_COL INTEGER IDENTITY NOT NULL,
CATEGORY VARCHAR(64) NOT NULL,
SUB_CATEGORY VARCHAR(64) NOT NULL,
SALES_AMT DECIMAL(10,2) NOT NULL
)
GO

TRUNCATE TABLE RANK_FUNC_EXAMPLE_DATA
GO

INSERT INTO RANK_FUNC_EXAMPLE_DATA
VALUES
('Category A','Sub Category AA',100.00),
('Category A','Sub Category AB',100.00), -- tie, same value
('Category A','Sub Category AC',120.00),
('Category A','Sub Category AD',130.00),
('Category B','Sub Category BA',200.00),
('Category B','Sub Category BB',210.00), 
('Category B','Sub Category BC',230.00),
('Category B','Sub Category BD',240.00),
('Category C','Sub Category CA',300.00),
('Category C','Sub Category CB',310.00), 
('Category C','Sub Category CC',340.00),
('Category C','Sub Category CD',350.00),
('Category D','Sub Category DA',400.00),
('Category D','Sub Category DB',410.00), 
('Category D','Sub Category DC',420.00),
('Category D','Sub Category DD',430.00);
GO

/****************/
/* CUME_DIST() */
/****************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	CUME_DIST() OVER (
		PARTITION BY Column
		ORDER BY Column
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	CUME_DIST() OVER (
	--	PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT
		) AS [CUME_DIST],

	CONVERT(DECIMAL(10,4),(
	SELECT CONVERT(DECIMAL(10,4),COUNT(*))
	FROM RANK_FUNC_EXAMPLE_DATA
	WHERE SALES_AMT <= A.SALES_AMT
	) /
	(
	SELECT CONVERT(DECIMAL(10,4),COUNT(*))
	FROM RANK_FUNC_EXAMPLE_DATA
	)
	) AS MY_CUME_DIST
FROM RANK_FUNC_EXAMPLE_DATA A
GO

SELECT A.[CATEGORY], 
[SALES_AMT],
	convert(decimal(10,4),(
	SELECT convert(decimal(10,4),COUNT(*))
	FROM RANK_FUNC_EXAMPLE_DATA
	WHERE SALES_AMT <= A.SALES_AMT
	) /
	(
	SELECT convert(decimal(10,4),COUNT(*))
	FROM RANK_FUNC_EXAMPLE_DATA
	)
	)
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/*****************/
/* FIRST_VALUE() */
/*****************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	FIRST_VALUE(Column) OVER (
		PARTITION BY Column
		ORDER BY Column
		RANGE <Start> <Stop>
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	FIRST_VALUE([SALES_AMT]) OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT
		) AS [LOWEST_SALE]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/*************/
/* EXAMPLE 2 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	FIRST_VALUE([SALES_AMT]) OVER (
		PARTITION BY [CATEGORY] -- partition clause
		ORDER BY SALES_AMT		-- order by clause
		RANGE BETWEEN UNBOUNDED PRECEDING
		AND 
        UNBOUNDED FOLLOWING		-- frame clause
		) AS [LOWEST_SALE]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/****************/
/* LAST_VALUE() */
/****************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	LAST_VALUE(Column) OVER (
		PARTITION BY Column
		ORDER BY Column
		RANGE <Start> <Stop>
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	LAST_VALUE([SALES_AMT]) OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT
		RANGE BETWEEN UNBOUNDED PRECEDING AND 
        UNBOUNDED FOLLOWING
		) AS [TOP_SALE],

	[SALES_AMT] - 
	LAST_VALUE([SALES_AMT]) OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT
		RANGE BETWEEN UNBOUNDED PRECEDING AND 
        UNBOUNDED FOLLOWING
		) AS [DIFFERENCE]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/*********/
/* LAG() */
/*********/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	LAG(Column) OVER (
		PARTITION BY Column -- optional
		ORDER BY Column
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	LAG(SALES_AMT) OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT
		) AS [PRIOR],
	A.[SALES_AMT] -
	LAG(SALES_AMT) OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT
		) AS [DELTA]
FROM RANK_FUNC_EXAMPLE_DATA A
GO


/**********/
/* LEAD() */
/**********/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	LEAD(Column) OVER (
		PARTITION BY Column
		ORDER BY Column
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

/*************/
/* EXAMPLE 1 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	LEAD(SALES_AMT) OVER (
		PARTITION BY [CATEGORY] 
		ORDER BY SALES_AMT
		) AS [NEXT]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

-- interesting results, does the next query make sense
-- future category results are shown in the last
-- row of a partitioin but they refer to a new
-- category.

/*************/
/* EXAMPLE 2 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	LEAD(SALES_AMT) OVER (
	--	PARTITION BY [CATEGORY] 
		ORDER BY SALES_AMT
		) AS [NEXT]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/******************/
/* PERCENT_RANK() */
/******************/

/**********/
/* SYNTAX */
/**********/
/*
SELECT Column List
	PERCENT_RANK() OVER (
		PARTITION BY Column
		ORDER BY Column
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

/*************/
/* EXAMPLE 1 */
/*************/

DECLARE @PCT_RANK_TABLE TABLE (
CATEGORY VARCHAR(32) NOT NULL,
CAT_VALUE DECIMAL(10,2) NOT NULL
);

INSERT INTO @PCT_RANK_TABLE
VALUES 
	('A',1),
	('B',2),
	('C',3),
	('D',4),
	('E',5);
	
SELECT [CATEGORY], [CAT_VALUE],
	CONVERT(DECIMAL(3,2),PERCENT_RANK() OVER (
--		PARTITION BY [CATEGORY]
		ORDER BY CAT_VALUE
		)) AS [PCT_RANK]
FROM @PCT_RANK_TABLE
GO

/*************/
/* EXAMPLE 2 */
/*************/

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	PERCENT_RANK() OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT
		) AS [PCT_RANK]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/*************/
/* EXAMPLE 3 */
/*************/

DECLARE @PCT_RANK_TABLE TABLE (
CATEGORY VARCHAR(32) NOT NULL,
CAT_VALUE DECIMAL(10,2) NOT NULL
);

INSERT INTO @PCT_RANK_TABLE
VALUES 
	('A',98.8),
	('B',88.8),
	('C',108.0),
	('D',68.8),
	('E',97.8),
	('A',70.8),
	('B',85.8),
	('C',90.0),
	('D',58.8),
	('E',38.8),
	('A',98.8),
	('B',88.8),
	('C',18.0),
	('D',28.8),
	('E',37.8),
	('A',75.8),
	('B',25.8),
	('C',45.0),
	('D',56.8),
	('E',38.8);
	
SELECT [CATEGORY], [CAT_VALUE],
	CONVERT(DECIMAL(3,2),PERCENT_RANK() OVER (
		PARTITION BY [CATEGORY]
		ORDER BY CAT_VALUE
		)) AS [PCT_RANK]
FROM @PCT_RANK_TABLE
GO

/*********************/
/* PERCENTILE_CONT() */
/*********************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	PERCENT_CONT( <percentage>) WITHIN GROUP
	(ORDER BY Column)
	OVER 
	(PARTITION BY Column) AS [Column Alias]
FROM [Table Name] 
GO
*/

-- percentile based on continuous distribution
-- i.e. continuous values

/*************/
/* EXAMPLE 1 */
/*************/

DECLARE @PCT_CONT_TABLE TABLE (
CATEGORY VARCHAR(32) NOT NULL,
CAT_VALUE DECIMAL(10,2) NOT NULL
);

INSERT INTO @PCT_CONT_TABLE
VALUES 
	('A',98.8),
	('B',88.8),
	('C',108.0),
	('D',68.8),
	('E',97.8),
	('A',70.8),
	('B',85.8),
	('C',90.0),
	('D',58.8),
	('E',38.8),
	('A',98.8),
	('B',88.8),
	('C',18.0),
	('D',28.8),
	('E',37.8),
	('A',75.8),
	('B',25.8),
	('C',45.0),
	('D',56.8),
	('E',38.8);

DECLARE @percentile FLOAT;

SET @percentile = 0.5;
--SET @percentile = 0.25;
	
SELECT [CATEGORY], [CAT_VALUE],
	CONVERT(FLOAT,PERCENTILE_CONT(@percentile) WITHIN GROUP
			(ORDER BY CAT_VALUE)
		OVER 
		(PARTITION BY CATEGORY)
	--	() -- over the entire data set
		) AS [PCT_CONT]
FROM @PCT_CONT_TABLE
GO

/*************/
/* EXAMPLE 2 */
/*************/

DECLARE @PCT_CONT_TABLE TABLE (
CAT_VALUE DECIMAL(10,2) NOT NULL
);

INSERT INTO @PCT_CONT_TABLE
VALUES 
	(1),
	(2),
	(3),
	(4),
	(6),
	(7),
	(8),
	(9);
	

DECLARE @percentile FLOAT;

SET @percentile = 0.5;
--SET @percentile = 0.25;
	
SELECT AVG([CAT_VALUE]) AS SALES_AVG
FROM @PCT_CONT_TABLE;

SET @percentile = 0.5;
--SET @percentile = 0.25;
	
SELECT CAT_VALUE,
	PERCENTILE_CONT(@percentile) WITHIN GROUP
			(ORDER BY CAT_VALUE)
		OVER 
			() 
		 AS [PCT_CONT]
FROM @PCT_CONT_TABLE
GO

/*********************/
/* PERCENTILE_DISC() */
/*********************/

-- percentile based on discrete distribution
-- i.e. discrete values

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	PERCENT_DISC( <percentage>) WITHIN GROUP
	(ORDER BY Column)
	OVER 
	(PARTITION BY Column) AS [Column Alias]
FROM [Table Name] 
GO
*/

/*************/
/* EXAMPLE 1 */
/*************/

DECLARE @PCT_CONT_TABLE TABLE (
CATEGORY VARCHAR(32) NOT NULL,
CAT_VALUE DECIMAL(10,2) NOT NULL
);

INSERT INTO @PCT_CONT_TABLE
VALUES 
	('A',98.8),
	('B',88.8),
	('C',108.0),
	('D',68.8),
	('E',97.8),
	('A',70.8),
	('B',85.8),
	('C',90.0),
	('D',58.8),
	('E',38.8),
	('A',98.8),
	('B',88.8),
	('C',18.0),
	('D',28.8),
	('E',37.8),
	('A',75.8),
	('B',25.8),
	('C',45.0),
	('D',56.8),
	('E',38.8);

DECLARE @percentile FLOAT;

SET @percentile = 0.5;
--SET @percentile = 0.25;
	
SELECT [CATEGORY], [CAT_VALUE],
	CONVERT(FLOAT,PERCENTILE_DISC(@percentile) WITHIN GROUP
			(ORDER BY CAT_VALUE)
		OVER 
			(PARTITION BY CATEGORY) 
		) AS [PCT_DISC]
FROM @PCT_CONT_TABLE
GO

/*************/
/* EXAMPLE 2 */
/*************/

DECLARE @PCT_DISC_TABLE TABLE (
CAT_VALUE DECIMAL(10,2) NOT NULL
);

INSERT INTO @PCT_DISC_TABLE
VALUES 
	(1),
	(2),
	(2),
	(3),
	(3.8),
	(5.5),
	(6),
	(7),
	(7),
	(8),
	(9),
	(10),
	(12),
	(8.0);
	

DECLARE @percentile FLOAT;

SET @percentile = 0.5;
--SET @percentile = 0.25;
	
SELECT AVG([CAT_VALUE]) AS SALES_AVG
FROM @PCT_DISC_TABLE;

SET @percentile = 0.5;
--SET @percentile = 0.25;
	
SELECT CAT_VALUE,
	CONVERT(DECIMAL(10,2),PERCENTILE_CONT(@percentile) WITHIN GROUP
			(ORDER BY CAT_VALUE)
		OVER 
			() 
		 ) AS [PCT_CONT],
		CONVERT(DECIMAL(10,2),PERCENTILE_DISC(@percentile) WITHIN GROUP
			(ORDER BY CAT_VALUE)
		OVER 
			() 
		 ) AS [PCT_DISC]
FROM @PCT_DISC_TABLE
GO