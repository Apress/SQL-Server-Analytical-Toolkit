/**********************/
/* CHAPTER 02 QUERIES */
/**********************/

USE TEST
GO

/**********************************************/
/* Listing 2.1 The COUNT() function in action */
/**********************************************/

DECLARE @CUSTOMER_PRODUCT TABLE (
CUSTOMER_ID     VARCHAR(32) NOT NULL,
PRODUCT_ID      VARCHAR(32) NOT NULL,
PRODUCTS_BOUGHT SMALLINT NOT  NULL
);

INSERT INTO @CUSTOMER_PRODUCT VALUES
	('C0001','P0001',10),
	('C0001','P0002',20),
	('C0002','P0002',1),
	('C0002','P0003',5),
	('C0003','P0003',20),
	('C0003','P0004',5),
	('C0003','P0005',4);

SELECT COUNT(*) AS ROW_COUNT
FROM @CUSTOMER_PRODUCT;

SELECT COUNT(DISTINCT CUSTOMER_ID) AS CUST_COUNT
FROM @CUSTOMER_PRODUCT;

SELECT COUNT(DISTINCT PRODUCT_ID) AS PROD_COUNT
FROM @CUSTOMER_PRODUCT;

SELECT CUSTOMER_ID,COUNT(PRODUCT_ID) AS PRODUCTS_BOUGHT
FROM @CUSTOMER_PRODUCT
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID;
GO

USE TEST
GO

/*****************************************/
/* Listing 2.2 Other Aggregate Functions */
/*****************************************/

DECLARE @CUSTOMER_PRODUCT TABLE (
CUSTOMER_ID     VARCHAR(32) NOT NULL,
PRODUCT_ID      VARCHAR(32) NOT NULL,
PRODUCTS_BOUGHT SMALLINT NOT  NULL
);

INSERT INTO @CUSTOMER_PRODUCT VALUES
	('C0001','P0001',10),
	('C0001','P0002',20),
	('C0002','P0002',1),
	('C0002','P0003',5),
	('C0003','P0003',20),
	('C0003','P0004',5),
	('C0003','P0005',4);

SELECT SUM(PRODUCTS_BOUGHT) AS ITEMS_BOUGHT
FROM @CUSTOMER_PRODUCT;

SELECT CUSTOMER_ID,
SUM(PRODUCTS_BOUGHT) AS ITEMS_BOUGHT,
MAX(PRODUCTS_BOUGHT) AS MAX_BOUGHT,
MIN(PRODUCTS_BOUGHT) AS MIN_BOUGHT,
AVG(PRODUCTS_BOUGHT) AS AVG_BOUGHT
FROM @CUSTOMER_PRODUCT
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID;

SELECT 
SUM(PRODUCTS_BOUGHT) AS ITEMS_BOUGHT,
MAX(PRODUCTS_BOUGHT) AS MAX_BOUGHT,
MIN(PRODUCTS_BOUGHT) AS MIN_BOUGHT,
AVG(PRODUCTS_BOUGHT) AS AVG_BOUGHT
FROM @CUSTOMER_PRODUCT
GO

/***************************************/
/* Listing 2.3 RANK() vs. DENSE_RANK() */
/***************************************/

DECLARE @SALES_RANK TABLE (
ROW_NO INTEGER IDENTITY NOT NULL,
[YEAR] INTEGER NOT NULL,
SALES_PERSON VARCHAR(8) NOT NULL,
TOTAL_SALES MONEY NOT NULL
);

INSERT INTO @SALES_RANK VALUES 
(2010,'John',11000.00),
(2010,'Steven',10000.00),
(2010,'Mary',9000.00),
(2010,'Sally',8000.00),
(2010,'Carlos',7000.00),
(2010,'Pierre',7000.00),
(2010,'Gunter',5000.00),
(2010,'Luigi',4000),
(2010,'Nigel',3000),
(2010,'Patrick',2000),
(2010,'Debbie',1000);

SELECT ROW_NO,[YEAR],SALES_PERSON,TOTAL_SALES,
	RANK() OVER(ORDER BY TOTAL_SALES DESC) AS [RANK],
	DENSE_RANK() OVER (ORDER BY TOTAL_SALES DESC) AS [DENSE_RANK]
FROM @SALES_RANK
GO

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

/**********************************/
/* Listing 2.4 - NTILE() Function */
/**********************************/

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

/***************************************/
/* Listing 2.5 - ROW_NUMBER() Function */
/***************************************/

DECLARE @tile SMALLINT;
SET @tile = 2

SELECT A.[KEY_COL], A.[CATEGORY],A.[SUB_CATEGORY],[SALES_AMT],
	ROW_NUMBER() OVER (
		PARTITION BY CATEGORY
		ORDER BY SALES_AMT
		) AS TILE
FROM RANK_FUNC_EXAMPLE_DATA A
GO

/*****************************************/
/* Listing 2.6 - PERCENT_RANK() Function */
/*****************************************/


DECLARE @PCT_RANK_EXAMPLE TABLE(
CATEGORY CHAR(1) NOT NULL,
[VALUE] SMALLINT NOT NULL
);

INSERT INTO @PCT_RANK_EXAMPLE VALUES
('A',10.00),
('B',30.00),
('C',70.00),
('D',60.00),
('E',90.00),
('F',70.00),
('G',70.00),
('H',70.00),
('I',80.00),
('J',12.00);


SELECT CATEGORY,[VALUE],
	CONVERT(DECIMAL(10,4),PERCENT_RANK() OVER (
		ORDER BY [VALUE]
		)) AS PCT_RANK
FROM @PCT_RANK_EXAMPLE
GO

/*******************************************/
/* Listing 2.7 - PERCENTILE_DISC() example */
/*******************************************/

DECLARE @TRAIN_SALES TABLE (
	CUST_ID VARCHAR(64) NOT NULL,
	PROD_DESC VARCHAR(64) NOT NULL,
	QUANTITY INTEGER NOT NULL,
	TOTAL_COST MONEY
	);

INSERT INTO @TRAIN_SALES VALUES
('CUST_001','Electric Locomotive',10,1000.00),
('CUST_002','Electric Locomotive',5,500.00),
('CUST_003','Electric Locomotive',7,450.00),
('CUST_004','Electric Locomotive',2,200.00),
('CUST_005','Electric Locomotive',3,150.00);

SELECT CUST_ID,PROD_DESC,QUANTITY,TOTAL_COST
    ,PERCENTILE_DISC(0.0) WITHIN GROUP (ORDER BY QUANTITY)   
     OVER () AS [% DISCRETE]
	,PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY QUANTITY)   
     OVER () AS [%25 DISCRETE]
	,PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY QUANTITY)   
     OVER () AS [%50 DISCRETE]
	,PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY QUANTITY)   
     OVER () AS [%75 DISCRETE]
FROM @TRAIN_SALES
GO

/*******************************************/
/* Listing 2.8 - PERCENTILE_CONT() example */
/*******************************************/

DECLARE @VALVE_TEMP TABLE (
	VALVE_ID VARCHAR(64) NOT NULL,
	SAMPLE_HOUR SMALLINT,
	TEMPERATURE FLOAT
	);

INSERT INTO @VALVE_TEMP VALUES
('@VALVE_001',1,1000.00),
('@VALVE_001',2,500.00),
('@VALVE_001',3,450.00),
('@VALVE_001',4,200.00),
('@VALVE_001',5,1000.00),
('@VALVE_001',6,500.00),
('@VALVE_001',7,450.00),
('@VALVE_001',8,200.00),
('@VALVE_001',9,1000.00),
('@VALVE_001',10,500.00),
('@VALVE_001',11,450.00),
('@VALVE_001',12,200.00),
('@VALVE_001',13,1000.00),
('@VALVE_001',14,500.00),
('@VALVE_001',15,450.00),
('@VALVE_001',16,200.00),
('@VALVE_001',17,1000.00),
('@VALVE_001',18,500.00),
('@VALVE_001',19,450.00),
('@VALVE_001',20,200.00),
('@VALVE_001',21,1000.00),
('@VALVE_001',22,500.00),
('@VALVE_001',23,450.00),
('@VALVE_001',24,200.00);

SELECT VALVE_ID,SAMPLE_HOUR,TEMPERATURE
    ,PERCENTILE_CONT(0.0) WITHIN GROUP (ORDER BY SAMPLE_HOUR)   
     OVER () AS [% CONTINUOUS]
	,PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY SAMPLE_HOUR)   
     OVER () AS [%25 CONTINUOUS]
	,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY SAMPLE_HOUR)   
     OVER () AS [%50 CONTINUOUS]
	,PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SAMPLE_HOUR)   
     OVER () AS [%75 CONTINUOUS]
FROM @VALVE_TEMP
GO

