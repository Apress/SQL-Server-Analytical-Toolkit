/****************************************/
/* Chapter 10 - Plant Database Use Case */
/* Analytical Functions                 */
/* Created: 08/01/2022                  */
/* Modified: 07/12/2023                 */
/****************************************/

USE APPlant
GO

/************************/
/* Analytical Functions */
/************************/

/*
•	CUME_DIST()
•	FIRST_VALUE()
•	LAST_VALUE()
•	LAG()
•	LEAD()
•	PERCENT_RANK()
•	PERCENTILE_CONT()
•	PERCENTILE_DISC()
*/

/****************************************************************/
/* Listing  10.1 – Cumulative Distribution Reports for Failures */
/****************************************************************/

-- percent of values less than or equi

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,MonthName,CalendarMonth,PlantName,LocationName,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
)
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,
	MonthName,CalendarMonth
	,SumEquipFailures
	,FORMAT(CUME_DIST() OVER (
	-- use PARTITION BY below for more years, plants and locations
	--	PARTITION BY PlantName,LocationName,CalendarYear
	--	ORDER BY PlantName,LocationName,CalendarYear,SumEquipFailures  
	 
	 ORDER BY SumEquipFailures 
	),'P') AS CumeDist
FROM FailedEquipmentCount
-- remover filter below for more years, plants and locations
WHERE CalendarYear = 2002
AND LocationName = 'Boiler Room'
AND PlantName = 'East Plant'
GO


-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***************************************************************************/
/* Use this query to generate results for all plants, locations and years. */
/* This query can be used to populate a report table so you can create     */
/* a report with Report Builder and publish it to SSRS.                    */
/***************************************************************************/

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,MonthName,CalendarMonth,PlantName,LocationName,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
)
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,
	MonthName,CalendarMonth
	,SumEquipFailures
	,FORMAT(CUME_DIST() OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY PlantName,LocationName,CalendarYear,SumEquipFailures 
	),'P') AS CumeDist
FROM FailedEquipmentCount
-- remover filter below for more years, plants and locations
GO

/****************************************/
/* CREATE A VIEW FOR REPORTING SERVICES */
/****************************************/

SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
GO

/*************************************************************************************/
/* -- Listing  10.2 – First and Last Values for Failures By Plant, Location and Year */
/*************************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,MonthName,CalendarMonth,PlantName,LocationName
,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
)

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName
		,CalendarMonth,SumEquipFailures
	,FIRST_VALUE(SumEquipFailures) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS FirstValue
	,LAST_VALUE(SumEquipFailures) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS LastValue
FROM FailedEquipmentCount
GO


-- turn set statistics io/time/profile on

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***************************************************/
/* Listing  10.3 – Last month’s Equipment Failures */
/***************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,MonthName,CalendarMonth,PlantName,LocationName,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
/* DEBUG ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,P.PlantName
	,L.LocationName
*/
)

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth,
	SumEquipFailures,
	LAG(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS LastFailureSum
	/*,SumEquipFailures - LAG(SumEquipFailures,1,0) OVER
		(
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
		) AS FailureChange */
FROM FailedEquipmentCount
WHERE CalendarYear > 2008
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*****************/
/* An experiment */
/*****************/

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,MonthName,CalendarMonth,PlantName,LocationName,EquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,EF.Failure
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
)

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth,
	SUM(EquipFailures) AS SumEquipFailures,
	LAG(SUM(EquipFailures),1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS LastFailureSum
	/*,SumEquipFailures - LAG(SumEquipFailures,1,0) OVER
		(
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
		) AS FailureChange */
FROM FailedEquipmentCount
WHERE CalendarYear > 2008
GROUP BY
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***************************/
/* Create the report table */
/***************************/

USE [APPlant]
GO

DROP TABLE IF EXISTS Reports.PlantSumEquipFailures
GO

CREATE TABLE Reports.PlantSumEquipFailures(
	CalendarYear smallint NOT NULL,
	QuarterName varchar(11) NULL,
	MonthName varchar(9) NULL,
	CalendarMonth smallint NOT NULL,
	PlantName varchar(64) NOT NULL,
	LocationName varchar(128) NOT NULL,
	SumEquipFailures int NULL
) ON AP_PLANT_FG
GO

/********************************************/
/* Listing  10.4 – Loading the Report Table */
/********************************************/

TRUNCATE TABLE Reports.PlantSumEquipFailures
GO

INSERT INTO Reports.PlantSumEquipFailures
SELECT
	C.CalendarYear,C.QuarterName,C.MonthName,C.CalendarMonth,P.PlantName,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId

-- Here is the daily load
-- use the WHERE clause below to get the current days values.
-- WHERE C.CalendarDate = CONVERT(DATE,GETDATE())

-- Here is the one time get all prior months load
-- use the WHERE clause below to get the all values for the last month.
-- WHERE MONTH(C.CalendarDate) = DATEDIFF(mm,MONTH(CONVERT(DATE,GETDATE())))

GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,P.PlantName
	,L.LocationName
GO

/*********************************************/
/* Listing  10.5 – Querying the Report Table */
/*********************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth,
	SumEquipFailures,
	LAG(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS LastFailureSum
FROM Reports.PlantSumEquipFailures
WHERE CalendarYear > 2008
--WHERE CalendarYear = 2008
--AND CalendarMonth BETWEEN 1 AND 12
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

-- index did not help

DROP INDEX iePlantLagFailures 
ON Reports.PlantSumEquipFailures
GO

CREATE INDEX iePlantLagFailures 
ON Reports.PlantSumEquipFailures (PlantName,LocationName,CalendarYear,QuarterName,CalendarMonth)
INCLUDE (SumEquipFailures)
GO

/***************************************************/
/* -- Listing  10.6 – Equipment Failure Lead Query */
/***************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth,
	SumEquipFailures
	,LEAD(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS NextFailureSum
FROM [Reports].[PlantSumEquipFailures]
WHERE CalendarYear > 2008
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 


/**********************************/
/* MEMORY ENHANCED TABLE APPROACH */
/**********************************/

USE [APPlant]
GO

/********************/
/* CREATE THE TABLE */
/********************/

DROP TABLE IF EXISTS [Reports].[EquipmentMonthlyLeadLagMem]
GO

CREATE TABLE [Reports].[EquipmentMonthlyLeadLagMem]
(
	[PlantName] [varchar](64) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[CalendarYear] [smallint] NOT NULL,
	[QuarterName] [varchar](11) NULL,
	[MonthName] [varchar](9) NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[SumEquipFailures] [int] NULL,
	[NextMonth] [int] NULL,
	[NextMonthDelta] [int] NULL,
	[LastMonth] [int] NULL,
	[LagDelta] [int] NULL

INDEX [ieEquipFailStatMem] NONCLUSTERED 
(
	[PlantName] ASC
	,[LocationName] ASC
	,[CalendarYear] ASC
	,[QuarterName] ASC
	,[MonthName] ASC
	,[CalendarMonth] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/******************/
/* LOAD THE TABLE */
/******************/

DELETE FROM [Reports].[EquipmentMonthlyLeadLagMem]
GO

INSERT INTO [Reports].[EquipmentMonthlyLeadLagMem]
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth,
	SumEquipFailures
	,LEAD(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS NextMonth

	,LEAD(SumEquipFailures,1,0) OVER (
			PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
			ORDER BY CalendarMonth
		) - SumEquipFailures AS NextMonthDelta
	
	,LAG(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS LastMonth

	,LAG(SumEquipFailures,1,0) OVER (
			PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
			ORDER BY CalendarMonth
		) - SumEquipFailures AS LagDelta
FROM [Reports].[PlantSumEquipFailures]
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

/*******************/
/* QUERY THE TABLE */
/*******************/

SELECT
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,SumEquipFailures
	,NextMonth
	,NextMonthDelta
	,LastMonth
	,LagDelta
FROM [Reports].[EquipmentMonthlyLeadLagMem]
GO

SELECT
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,SumEquipFailures
	,NextMonth
	,NextMonthDelta
	,LastMonth
	,LagDelta
FROM [Reports].[EquipmentMonthlyLeadLagMem]
WHERE CalendarYear = 2018
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 


/******************************************************************************/
/* LISTING 10.7 - Listing  10.7 – Percent Rank versus Cumulative Distribution */
/******************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

-- CUME_DIST() function added so you can compare results

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth
	,SumEquipFailures
	,FORMAT(PERCENT_RANK() OVER (
		PARTITION BY CalendarYear,PlantName,LocationName
		ORDER BY CalendarYear,PlantName,LocationName,SumEquipFailures
	),'P') AS PercentRank

	,FORMAT(CUME_DIST() OVER (
		PARTITION BY CalendarYear,PlantName,LocationName
		ORDER BY CalendarYear,PlantName,LocationName,SumEquipFailures
	),'P') AS CumeDist
FROM [Reports].[PlantSumEquipFailures]
/* uncomment WHERE clause for less rows 
WHERE PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
AND CalendarYear = 2002 
*/
--ORDER BY PlantName,LocationName,CalendarYear,QuarterName,CalendarMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***********************************************************************/
/* Listing  10.9 – Percentile continuous analysis for Monthly Failures */
/***********************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

SELECT PlantId
	,LocationId
	,LocationName
	,BoilerName
	,CalendarDate
	,Hour
	,BoilerTemperature
	,PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY BoilerTemperature)
	OVER (
	PARTITION BY CalendarDate
	) AS [PercentCont .25]
	,PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY BoilerTemperature)
	OVER (
	PARTITION BY CalendarDate
	) AS [PercentCont .5]
	,PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY BoilerTemperature)
	OVER (
	PARTITION BY CalendarDate
	) AS [PercentCont .75]
FROM EquipStatistics.BoilerTemperatureHistory
WHERE PlantId = 'PP000002'
AND YEAR(CalendarDate) = 2004
AND BoilerName = 'Boiler 2'
--ORDER BY CalendarDate
--	,Hour
GO

/*
Missing Index Details from ch10 - queries.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (90))
The Query Processor estimates that implementing the following index could improve the query cost by 48.2595%.
*/

/*
USE [APPlant]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [EquipStatistics].[BoilerTemperatureHistory] ([PlantId],[BoilerName])
INCLUDE ([LocationId],[LocationName],[CalendarDate],[Hour],[BoilerTemperature])
GO
*/

/**********************************************************/
/* Listing  10.10 – Suggested Index for Large Table Query */
/**********************************************************/

DROP INDEX IF EXISTS iePlantBoilerLocationDateHour
ON EquipStatistics.BoilerTemperatureHistory
GO

CREATE NONCLUSTERED INDEX [iePlantBoilerLocationDateHour]
ON [EquipStatistics].[BoilerTemperatureHistory] ([PlantId],[BoilerName])
INCLUDE ([LocationId],[LocationName],[CalendarDate],[Hour],[BoilerTemperature])
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*********/
/* BONUS */
/*********/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,MonthName,CalendarMonth,PlantName,LocationName,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear,
	C.QuarterName,
	C.MonthName,
	C.CalendarMonth,
	P.PlantName,
	L.LocationName,
	SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear,
	C.QuarterName,
	C.MonthName,
	C.CalendarMonth,
	P.PlantName,
	L.LocationName
/* DEBUG ORDER BY
	C.CalendarYear,
	C.QuarterName,
	C.MonthName,
	P.PlantName,
	L.LocationName
*/
)

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,
	SumEquipFailures,
	PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
	) AS [PercentCont .25],
	PERCENTILE_CONT(.50) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
	) AS [PercentCont .50],
	PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
	) AS [PercentCont .75]
FROM FailedEquipmentCount
WHERE CalendarYear = 2008
ORDER BY PlantName,LocationName,CalendarYear,QuarterName,CalendarMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/************/
/* BONUS  2 */
/************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

-- remove quarter from partition

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,MonthName,CalendarMonth,PlantName,LocationName,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear,
	C.QuarterName,
	C.MonthName,
	C.CalendarMonth,
	P.PlantName,
	L.LocationName,
	SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear,
	C.QuarterName,
	C.MonthName,
	C.CalendarMonth,
	P.PlantName,
	L.LocationName
/* DEBUG ORDER BY
	C.CalendarYear,
	C.QuarterName,
	C.MonthName,
	P.PlantName,
	L.LocationName
*/
)

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,
	SumEquipFailures,
	PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentCont .25],
	PERCENTILE_CONT(.50) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentCont .50],
	PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentCont .75]
FROM FailedEquipmentCount
WHERE CalendarYear = 2008
ORDER BY PlantName,LocationName,CalendarYear,QuarterName,CalendarMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 


/*******************************************************************************/
/* Listing  10.11 – Percentile Discrete Analysis for Monthly Equipment Failure */
/*******************************************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO 

WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,[MonthName],CalendarMonth,PlantName,LocationName,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
/* DEBUG 
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,P.PlantName
	,L.LocationName
*/
)

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,
	SumEquipFailures
	
	-- actual value form list
	,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .25]
	
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .5]

		,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .75]
FROM FailedEquipmentCount
WHERE CalendarYear = 2008
--ORDER BY PlantName,LocationName,CalendarYear,QuarterName,CalendarMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***********************************/
/* Set up the report able solution */
/***********************************/

/*********************************************/
/* Listing  10.12 – Loading the Report Table */
/*********************************************/

USE [APPlant]
GO

DROP TABLE IF EXISTS [Reports].[EquipFailPctContDisc]
GO

CREATE TABLE [Reports].[EquipFailPctContDisc](
	[CalendarYear] [smallint] NOT NULL,
	[QuarterName] [varchar](11) NULL,
	[MonthName] [varchar](9) NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[SumEquipFailures] [int] NULL
) ON [AP_PLANT_FG]
GO

TRUNCATE TABLE Reports.EquipFailPctContDisc
GO

INSERT INTO Reports.EquipFailPctContDisc
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
--INTO Reports.EquipFailPctContDisc
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,P.PlantName
	,L.LocationName
GO

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

/**********************************************/
/* Listing  10.13 – Modified Percentile Query */
/**********************************************/

SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,
	SumEquipFailures
	
	-- actual value form list
	,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .25]
	
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .5]

		,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .75]
FROM Reports.EquipFailPctContDisc
WHERE CalendarYear = 2008
--ORDER BY PlantName,LocationName,CalendarYear,QuarterName,CalendarMonth
GO
 
SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/******************************************************************/
/* Listing  10.14 – Adding Surrogate Keys to the Equipment Tables */
/******************************************************************/

ALTER TABLE [DimTable].[Generator]
ADD PlantKey INTEGER NULL
GO

ALTER TABLE [DimTable].[Generator]
ADD LocationKey INTEGER NULL
GO

UPDATE [DimTable].[Generator]
SET PlantKey = P.PlantKey
FROM [DimTable].[Generator] G
JOIN [DimTable].[Plant] P
ON G.PlantId = P.PlantId
GO

UPDATE [DimTable].[Generator]
SET LocationKey = P.LocationKey
FROM [DimTable].[Generator] G
JOIN [DimTable].[Location] P
ON G.LocationId = P.LocationId
GO

SELECT * FROM [DimTable].[Generator]
GO


/********************************************************/
/* Here is the solution for the calendar table homework */
/********************************************************/

USE [APPlant]
GO

DROP TABLE IF EXISTS [DimTable].[CalendarEnhanced]
GO

CREATE TABLE [DimTable].[CalendarEnhanced](
	[CalendarKey] [int] NOT NULL,
	[CalendarYear] [smallint] NOT NULL,
	[CalendarQuarter] [smallint] NOT NULL,
	[QuarterName] [varchar](11) NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[MonthAbbrev] [varchar](3) NULL,
	[MonthName] [varchar](9) NULL,
	[CalendarDate] [date] NOT NULL
) ON [AP_PLANT_FG]
GO

/****************************************************************/
/* Here is an index suggested by the estimated query plann tool */
/****************************************************************/

DROP INDEX IF EXISTS ieCalendarYear
ON DimTable.CalendarEnhanced
GO

CREATE NONCLUSTERED INDEX ieCalendarYear
ON DimTable.CalendarEnhanced (CalendarYear)
INCLUDE (CalendarKey,QuarterName,CalendarMonth,MonthName)
GO


/*
TRUNCATE TABLE [DimTable].[CalendarEnhanced]
GO
*/

INSERT INTO [DimTable].[CalendarEnhanced]
SELECT [CalendarKey]
      ,[CalendarYear]
      ,[CalendarQuarter]
      ,[QuarterName]
      ,[CalendarMonth]
      ,[MonthAbbrev]
      ,[MonthName]
      ,[CalendarDate]
FROM [DimTable].[CalendarView]
GO