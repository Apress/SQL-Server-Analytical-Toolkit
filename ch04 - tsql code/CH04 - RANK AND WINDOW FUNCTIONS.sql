/***********************************************************/
/* Chapter 4 Examples - SQL Server rank & window functions */
/***********************************************************/

USE TEST
GO

/****************************************/
/* Here are the functions we will cover */
/****************************************/

-- RANK()
-- DENSE_RANK()
-- NTILE()
-- ROW_NUMBER()

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
('Category A','Sub Category AA',100.00), -- tie, same value
('Category A','Sub Category AA',120.00),
('Category A','Sub Category AA',130.00),
('Category B','Sub Category BB',200.00),
('Category B','Sub Category BB',210.00), 
('Category B','Sub Category BB',230.00),
('Category B','Sub Category BB',240.00),
('Category C','Sub Category CC',300.00),
('Category C','Sub Category CC',310.00), 
('Category C','Sub Category CC',340.00),
('Category C','Sub Category CC',350.00),
('Category D','Sub Category DD',400.00),
('Category D','Sub Category DD',410.00), 
('Category D','Sub Category DD',420.00),
('Category D','Sub Category DD',430.00);
GO

/**********/
/* RANK() */
/**********/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	RANK() OVER (
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
	RANK() OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT DESC
		) AS [RANK]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

-- top 10 sales report

SELECT TOP 10 A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	RANK() OVER (
		ORDER BY SALES_AMT DESC
		) AS [RANK]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/****************/
/* DENSE_RANK() */
/****************/

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	DENSE_RANK() OVER (
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
	DENSE_RANK() OVER (
		PARTITION BY [CATEGORY]
		ORDER BY SALES_AMT DESC
		) AS [DENSE_RANK]
FROM RANK_FUNC_EXAMPLE_DATA A
GO

SELECT A.[KEY_COL], A.[CATEGORY], [SALES_AMT],
	DENSE_RANK() OVER (
		ORDER BY SALES_AMT DESC
		) AS [DENSE_RANK]
FROM RANK_FUNC_EXAMPLE_DATA A
GO


/***********/
/* NTILE() */
/***********/

/*************/
/* EXAMPLE 1 */
/*************/

TRUNCATE TABLE RANK_FUNC_EXAMPLE_DATA
GO

INSERT INTO RANK_FUNC_EXAMPLE_DATA
VALUES
('Category A','Sub Category AA',100.00),
('Category A','Sub Category AB',110.00), 
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

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	NTILE(< number of tiles>) OVER (
		PARTITION BY Column
		ORDER BY Column
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

DECLARE @tile SMALLINT;
SET @tile = 4

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	NTILE(@tile) OVER (
	--	PARTITION BY CATEGORY
		ORDER BY SALES_AMT
		) AS TILE
FROM RANK_FUNC_EXAMPLE_DATA A
GO


DECLARE @tile SMALLINT;
SET @tile = 4

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	NTILE(@tile) OVER (
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT
		) AS TILE
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/*************/
/* EXAMPLE 2 */
/*************/

TRUNCATE TABLE RANK_FUNC_EXAMPLE_DATA
GO

INSERT INTO RANK_FUNC_EXAMPLE_DATA
VALUES
('Category A','Sub Category AA',100.00),
('Category A','Sub Category AB',410.00), 
('Category A','Sub Category AC',320.00),
('Category A','Sub Category AD',130.00),

('Category B','Sub Category BA',800.00),
('Category B','Sub Category BB',210.00), 
('Category B','Sub Category BC',430.00),
('Category B','Sub Category BD',740.00),

('Category C','Sub Category CA',300.00),
('Category C','Sub Category CB',910.00), 
('Category C','Sub Category CC',640.00),
('Category C','Sub Category CD',350.00),

('Category D','Sub Category DA',500.00),
('Category D','Sub Category DB',410.00), 
('Category D','Sub Category DC',320.00),
('Category D','Sub Category DD',730.00);

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	NTILE(4) OVER (
		ORDER BY SALES_AMT
		) AS BUCKET,
	CASE
		WHEN NTILE(4) OVER (
		ORDER BY SALES_AMT
		) = 1 THEN 'BUCKET 1'
		WHEN NTILE(4) OVER (
		ORDER BY SALES_AMT
		) = 2 THEN 'BUCKET 2'
		WHEN NTILE(4) OVER (
		ORDER BY SALES_AMT
		) = 3 THEN 'BUCKET 3'
		WHEN NTILE(4) OVER (
		ORDER BY SALES_AMT
		) = 4 THEN 'BUCKET 4'
	END AS BUCKET_NAME
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/****************/
/* ROW_NUMBER() */
/****************/

/*************/
/* EXAMPLE 1 */
/*************/

TRUNCATE TABLE RANK_FUNC_EXAMPLE_DATA
GO

INSERT INTO RANK_FUNC_EXAMPLE_DATA
VALUES
('Category A','Sub Category AA',100.00),
('Category A','Sub Category AB',110.00), 
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

/**********/
/* SYNTAX */
/**********/

/*
SELECT Column List
	ROW_NUMBER() OVER (
		PARTITION BY Column
		ORDER BY Column
		) AS [Column Alias]
FROM [Table Name] 
GO
*/

/****************************/
/* EXAMPLE 1  - listing 4.6 */
/****************************/

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	ROW_NUMBER() OVER (
		ORDER BY SALES_AMT ASC
		) AS MY_ROW_NO
FROM RANK_FUNC_EXAMPLE_DATA A
GO

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	ROW_NUMBER() OVER (
		PARTITION BY A.[CATEGORY]
		ORDER BY SALES_AMT ASC
		) AS MY_ROW_NO
FROM RANK_FUNC_EXAMPLE_DATA A
GO

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	ROW_NUMBER() OVER (
		PARTITION BY [CATEGORY],[SUB_CATEGORY]
		ORDER BY SALES_AMT ASC
		) AS MY_ROW_NO
FROM RANK_FUNC_EXAMPLE_DATA A
GO


/****************************/
/* EXAMPLE 2  - listing 4.7 */
/****************************/

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	ROW_NUMBER() OVER (
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT ASC
		) AS MY_ROW_NO
FROM RANK_FUNC_EXAMPLE_DATA A
GO

