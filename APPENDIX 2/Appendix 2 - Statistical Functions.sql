/*************************/
/* Appendix 2            */
/* Statistical Functions */
/* Created: 08/19/2022   */
/* Modified: 07/20/2023  */
/* Production            */
/*************************/

/*************************************/
/* Listing A2.1 – Standard Deviation */
/*************************************/

DECLARE @X FLOAT;
DECLARE @Y FLOAT;

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(10.00),(20.00),(30.00),(35.00),(40.00),(42.00),(44.00)
,(46.00),(48.00),(50.00),(50.00),(48.00),(46.00),(44.00)
,(42.00),(40.00),(35.00),(30.00),(20.00),(10.00);

SELECT ColVal,AVG(ColVal) OVER () AS MEAN,STDEVP(ColVal)
 OVER ()AS STANDARD_DEVIATION
FROM @SampleData
GO

/***************************/
/* Listing A2.2 – Variance */
/***************************/

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(10.00),(20.00),(30.00),(35.00),(40.00),(42.00)
     ,(44.00),(46.00),(48.00),(50.00),(50.00),(48.00),(46.00)
     ,(44.00),(42.00),(40.00),(35.00),(30.00),(20.00),(10.00);
SELECT ColVal
,VAR(ColVal)OVER () AS VARIANCE
,VARP(ColVal) OVER () AS VARIANCEP
FROM @SampleData;
GO

/****************************************************/
/* Listing A2.3 – Calculate the Normal Distribution */
/****************************************************/

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(10.00),(20.00),(30.00),(35.00),(40.00),(42.00),(44.00)
,(46.00),(48.00),(50.00),(50.00),(48.00),(46.00),(44.00)
,(42.00),(40.00),(35.00),(30.00),(20.00),(10.00);

DECLARE @StdDev   FLOAT;
DECLARE @Mean     FLOAT;
DECLARE @Variance FLOAT;

SELECT @StdDev = STDEV(ColVal) OVER() 
FROM @SampleData;

SELECT @Mean = AVG(ColVal) OVER() 
FROM @SampleData;

SELECT @Variance = VAR(ColVal)OVER () 
FROM @SampleData;

SELECT ColVal
	,@StdDev AS STDEV
	,@Mean AS MEAN
	,(1/SQRT(2.0 * PI() * @Variance)) 
		* EXP((-1 * POWER((ColVal - @Mean),2))/(2 * @Variance)) AS NDIST
FROM @SampleData;
GO

/************************************************************/
/* Listing A2.4 – Calculating the Mean for a Small Data Set */
/************************************************************/

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(10.00),(20.00),(30.00),(35.00),(40.00),(42.00),(44.00)
,(46.00),(48.00),(50.00),(50.00),(48.00),(46.00)
,(44.00),(42.00),(40.00),(35.00),(30.00),(20.00),(10.00);

SELECT KeyVal,ColVal,
AVG(ColVal) OVER(ORDER BY KeyVal ASC) AS [Rolling Mean]
FROM @SampleData;
GO

/****************************************************************************/
/* Listing A2.5 – Calculating Median with PERCENTILE_CONT & PERCENTILE_DISC */
/****************************************************************************/

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(10.00),(20.00),(30.00),(35.00),(40.00),(42.00),(44.00)
,(46.00),(48.00),(50.00),(50.00),(48.00),(46.00),(44.00)
,(42.00),(40.00),(35.00),(30.00),(20.00),(10.00);

SELECT KeyVal,ColVal,
	PERCENTILE_CONT(.50) 
WITHIN GROUP(ORDER BY ColVal) OVER()  AS MEDIAN_PCT_CONT,
	PERCENTILE_DISC(.50) 
WITHIN GROUP(ORDER BY ColVal) OVER()  AS MEDIAN_PCT_DISC
FROM @SampleData;
GO

/****************************************************************/
/* Listing A2.6 – Calculating the Mode of a Small Set of Values */
/****************************************************************/

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(10.00),(20.00),(30.00),(30.00),(40.00),(40.00),(40.00),(50.00);

SELECT DISTINCT TOP 1 ColVal AS Mode
FROM @SampleData 
GROUP BY ColVal
HAVING COUNT(*) > 1
ORDER BY ColVal DESC
GO

/********************************/
/* Listing A2.7 – Mode for ties */
/********************************/

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(10.00),(30.00),(30.00),(30.00),(40.00),(40.00),(40.00),(50.00),
(60.00),(70.00),(80.00),(90.00),(90.00),(140.00),(240.00),(350.00);

;WITH ModeCTE(ColVal,Ties)
AS
(
SELECT DISTINCT ColVal AS Mode,COUNT(*) AS Ties
FROM @SampleData 
GROUP BY ColVal
HAVING COUNT(*) > 1
)

SELECT ColVal AS Mode,MAX(Ties) AS MaxTies
FROM ModeCTE
WHERE Ties = (SELECT MAX(Ties) FROM ModeCTE)
GROUP BY ColVal,Ties
GO

/**************************************************************************/
/* Listing A2.8 – Calculating the Geometric Mean of a Small Set of Values */
/**************************************************************************/

DECLARE @Rows           FLOAT;
DECLARE @ResultValue    VARCHAR(256);
DECLARE @ParmDefinition NVARCHAR(500);
DECLARE @Parms          NVARCHAR(500);
DECLARE @Formula        NVARCHAR(500);

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(2.00),(4.00),(6.00),(4.00),(6.00);

SELECT @Rows = COUNT(*) FROM @SampleData;

-- product of the reciprocals
SELECT @Formula = N'SELECT @ResultValueOUT = (' + STRING_AGG(ColVal,'*') + ')' 
FROM @SampleData;

SELECT @Formula

SET @Parms = N'@ResultValueOUT VARCHAR(256) OUTPUT';

EXEC sp_executesql @Formula,@Parms,@ResultValueOUT=@ResultValue OUTPUT;

-- take nth root of final product calculation
SELECT @ResultValue,POWER(@ResultValue,(1/@Rows)) AS GeoMean;
GO

/********************************/
/* Listing A2.9 – Harmonic Mean */
/********************************/

DECLARE @Rows FLOAT;
DECLARE @SampleReciprocol FLOAT;

DECLARE @SampleData TABLE (
	KeyVal SMALLINT IDENTITY NOT NULL,
	ColVal FLOAT
	);

INSERT INTO @SampleData VALUES
(2.00),(4.00),(6.00),(4.00),(6.00);

SELECT @Rows = COUNT(*) FROM @SampleData;

-- generate reciprocal
SELECT 1.0/ColVal
FROM @SampleData

-- sum the reciprocals
SELECT SUM(1.0/ColVal) AS SumRec
FROM @SampleData;

-- generate the average
SELECT (SUM(1.0/ColVal))/@Rows AS AvgSumRec
FROM @SampleData;

-- generate the final reciprocol
SELECT @Rows/(SUM(1.0/ColVal)) AS AvgSumRec
FROM @SampleData;
GO

/******************************************/
/* Listing A2.10 – Weighted Mean ala TSQL */
/******************************************/

DECLARE @CarRating TABLE (
	KeyVal 	SMALLINT IDENTITY NOT NULL,
	CarModel 	VARCHAR(64) NOT NULL,
	Category 	VARCHAR(64) NOT NULL,
	Rating 	FLOAT 	NOT NULL,
	CategoryWeight FLOAT NOT NULL
	);

INSERT INTO @CarRating VALUES
('SuperSport','Fuel Economy',20.0,(1.0/8.0)),
('SuperSport','Color',20.0,(1.0/8.0)),
('SuperSport','Horse Power',30.0,(1.0/2.0)),
('SuperSport','Comfort',10.0,(1.0/8.0)),
('SuperSport','Speed',20.0,(1.0/8.0)),

('SuperEuroSport','Fuel Economy',10.0,(1.0/8.0)),
('SuperEuroSport','Color',10.0,(1.0/8.0)),
('SuperEuroSport','Horse Power',40.0,(1.0/2.0)),
('SuperEuroSport','Comfort',10.0,(1.0/8.0)),
('SuperEuroSport','Speed',30.0,(1.0/8.0));

SELECT CarModel,Category,Rating,CategoryWeight
FROM @CarRating;

SELECT CarModel,Category,(Rating * CategoryWeight) AS WeightedMean
FROM @CarRating;

SELECT DISTINCT CarModel
	,SUM((Rating * CategoryWeight)) OVER (
		PARTITION BY CarModel
		ORDER BY CarModel
		) AS WeightedMean
FROM @CarRating
GO







