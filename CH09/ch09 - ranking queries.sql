/****************************************/
/* Chapter 09 - Plant Database Use Case */
/* Ranking/Window Functions             */
/* Created: 08/01/2022                  */
/* Modified: 07/20/2023                 */
/* Production                           */
/****************************************/

/****************************/
/* Ranking/Window Functions */
/****************************/

/*
•	RANK()
•	DENSE_RANK()
•	NTILE()
•	ROW_NUMBER()
*/

USE [APPlant]
GO

/**********/
/* RANK() */
/**********/

/*****************************************************/
/* Listing  9.1 – Ranking Sums of Equipment Failures */
/*****************************************************/

-- returns number of rows before current rows + current row

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
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,[MonthName]
	,SumEquipFailures,
	RANK()  OVER (
	PARTITION BY PlantName,LocationName --,CalendarYear
	ORDER BY SumEquipFailures DESC
	) AS FailureRank

FROM FailedEquipmentCount
WHERE CalendarYear = 2008
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/****************************************************/
/* Listing  9.2 – Perform Ranking on a large table. */
/****************************************************/

DROP TABLE IF  EXISTS Reports.EquipmentRollingMonthlyHourTotals
GO

CREATE TABLE Reports.EquipmentRollingMonthlyHourTotals(
	StatusYear int NULL,
	StatusMonth int NULL,
	EquipmentId varchar(16) NOT NULL,
	EquipAbbrev varchar(3) NULL,
	EquipOnlineStatusCode varchar(4) NOT NULL,
	EquipOnLineStatusDesc varchar(64) NOT NULL,
	StatusCount int NULL
) ON AP_PLANT_FG
GO

TRUNCATE TABLE Reports.EquipmentRollingMonthlyHourTotals
GO

INSERT INTO Reports.EquipmentRollingMonthlyHourTotals
SELECT YEAR(ESBH.CalendarDate) AS StatusYear
      ,MONTH(ESBH.CalendarDate) AS StatusMonth
	  ,ESBH.EquipmentId
	  ,E.EquipAbbrev
      ,ESBH.EquipOnlineStatusCode
	  ,EOLSC.EquipOnLineStatusDesc
	  ,COUNT(*) AS StatusCount
FROM Reports.EquipmentDailyStatusHistoryByHour ESBH
JOIN DimTable.Equipment E
	ON ESBH.EquipmentId = E.EquipmentId
JOIN DimTable.EquipOnlineStatusCode EOLSC
	ON ESBH.EquipOnlineStatusCode = EOLSC.EquipOnlineStatusCode
GROUP BY YEAR(ESBH.CalendarDate)
      ,MONTH(ESBH.CalendarDate)
	  ,ESBH.EquipmentId
	  ,E.EquipAbbrev
      ,ESBH.EquipOnlineStatusCode
	  ,EOLSC.EquipOnLineStatusDesc
GO

/************************************************/
/* How about ranking events on the large table? */
/************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,CASE
		WHEN ES.StatusMonth = 1 THEN 'Jan'
		WHEN ES.StatusMonth = 2 THEN 'Feb'
		WHEN ES.StatusMonth = 3 THEN 'Mar'
		WHEN ES.StatusMonth = 4 THEN 'Apr'
		WHEN ES.StatusMonth = 5 THEN 'May'
		WHEN ES.StatusMonth = 6 THEN 'Jun'
		WHEN ES.StatusMonth = 7 THEN 'Jul'
		WHEN ES.StatusMonth = 8 THEN 'Aug'
		WHEN ES.StatusMonth = 9 THEN 'Sep'
		WHEN ES.StatusMonth = 10 THEN 'Oct'
		WHEN ES.StatusMonth = 11THEN 'Nov'
		WHEN ES.StatusMonth = 12 THEN 'Dec'
		END AS MonthName
	  ,EP.LocationId
	  ,L.LocationName
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,RANK() OVER(
		PARTITION BY ES.EquipmentId --,ES.StatusYear
		ORDER BY ES.EquipmentId ASC,ES.StatusYear ASC,StatusCount DESC
		) AS NoFailureRank
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo  
FROM Reports.EquipmentRollingMonthlyHourTotals ES -- 30,000 rows plus
INNER JOIN DimTable.Equipment E
ON ES.EquipmentId = E.EquipmentId
INNER JOIN [DimTable].[PlantEquipLocation] EP
ON ES.EquipmentId = EP.EquipmentId
INNER JOIN DimTable.Plant P
ON EP.PlantId = P.PlantId
INNER JOIN DimTable.Location L
ON EP.PlantId = L.PlantId
AND EP.LocationId = L.LocationId
WHERE ES.StatusYear = 2002
AND ES.EquipOnlineStatusCode = '0001'
GO

/*
Missing Index Details from SQLQuery8.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (83))
The Query Processor estimates that implementing the following index could improve the query cost by 17.5392%.
*/

/*
USE [APPlant]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Reports].[EquipmentRollingMonthlyHourTotals] ([StatusYear],[EquipmentId],[EquipOnlineStatusCode])
INCLUDE ([StatusMonth],[EquipAbbrev],[EquipOnLineStatusDesc],[StatusCount])
GO
*/

DROP INDEX  IF EXISTS ieStatusYearEquipIdOnlineStat
ON [Reports].[EquipmentRollingMonthlyHourTotals] 
GO

CREATE NONCLUSTERED INDEX ieStatusYearEquipIdOnlineStat
ON [Reports].[EquipmentRollingMonthlyHourTotals] ([StatusYear],[EquipmentId],[EquipOnlineStatusCode])
INCLUDE ([StatusMonth],[EquipAbbrev],[EquipOnLineStatusDesc],[StatusCount])
GO

UPDATE STATISTICS [Reports].[EquipmentRollingMonthlyHourTotals] 
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/************************************************/
/* Listing  9.3 – One Time Load of Report Table */
/************************************************/

/********************************************************************/
/* Use this query to load everything into a large Excel Pivot Table */
/********************************************************************/

SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,CASE
		WHEN ES.StatusMonth = 1 THEN 'Jan'
		WHEN ES.StatusMonth = 2 THEN 'Feb'
		WHEN ES.StatusMonth = 3 THEN 'Mar'
		WHEN ES.StatusMonth = 4 THEN 'Apr'
		WHEN ES.StatusMonth = 5 THEN 'May'
		WHEN ES.StatusMonth = 6 THEN 'Jun'
		WHEN ES.StatusMonth = 7 THEN 'Jul'
		WHEN ES.StatusMonth = 8 THEN 'Aug'
		WHEN ES.StatusMonth = 9 THEN 'Sep'
		WHEN ES.StatusMonth = 10 THEN 'Oct'
		WHEN ES.StatusMonth = 11THEN 'Nov'
		WHEN ES.StatusMonth = 12 THEN 'Dec'
		END AS MonthName
	  ,EP.LocationId
	  ,L.LocationName
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,RANK() OVER(
		PARTITION BY ES.EquipmentId,ES.StatusYear
		ORDER BY ES.EquipmentId ASC,ES.StatusYear ASC,StatusCount DESC
		) AS NoFailureRank
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo  
FROM Reports.EquipmentRollingMonthlyHourTotals ES -- 30,000 rows plus
INNER JOIN DimTable.Equipment E
ON ES.EquipmentId = E.EquipmentId
INNER JOIN [DimTable].[PlantEquipLocation] EP
ON ES.EquipmentId = EP.EquipmentId
INNER JOIN DimTable.Plant P
ON EP.PlantId = P.PlantId
INNER JOIN DimTable.Location L
ON EP.PlantId = L.PlantId
AND EP.LocationId = L.LocationId
GO

/*
Missing Index Details from SQLQuery1.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (54))
The Query Processor estimates that implementing the following index could improve the query cost by 30.6869%.
*/

/*
USE [APPlant]
GO

DROP INDEX IF EXISTS  [<Name of Missing Index, sysname,>]
ON [Reports].[EquipmentRollingMonthlyHourTotals]
GO

CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Reports].[EquipmentRollingMonthlyHourTotals] ([EquipmentId])
INCLUDE ([StatusYear],[StatusMonth],[EquipAbbrev],[EquipOnlineStatusCode],[EquipOnLineStatusDesc],[StatusCount])
GO
*/

/*********************************/
/* One Time Load of Report Table */
/*********************************/

DROP TABLE IF  EXISTS [Reports].[EquipmentMonthlyOnLineStatus]
GO

CREATE TABLE [Reports].[EquipmentMonthlyOnLineStatus](
	[ReportYear] [int] NULL,
	[Reportmonth] [int] NULL,
	[MonthName] [varchar](3) NULL,
	[LocationId] [varchar](16) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[StatusCount] [int] NULL,
	[EquipOnlineStatusCode] [varchar](4) NOT NULL,
	[EquipOnLineStatusDesc] [varchar](64) NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[PlantDescription] [varchar](64) NOT NULL,
	[EquipAbbrev] [varchar](3) NULL,
	[UnitId] [varchar](16) NOT NULL,
	[UnitName] [varchar](136) NOT NULL,
	[SerialNo] [varchar](34) NULL
) ON [AP_PLANT_FG]
GO

TRUNCATE TABLE Reports.EquipmentMonthlyOnLineStatus
GO

INSERT INTO Reports.EquipmentMonthlyOnLineStatus
SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,CASE
		WHEN ES.StatusMonth = 1 THEN 'Jan'
		WHEN ES.StatusMonth = 2 THEN 'Feb'
		WHEN ES.StatusMonth = 3 THEN 'Mar'
		WHEN ES.StatusMonth = 4 THEN 'Apr'
		WHEN ES.StatusMonth = 5 THEN 'May'
		WHEN ES.StatusMonth = 6 THEN 'Jun'
		WHEN ES.StatusMonth = 7 THEN 'Jul'
		WHEN ES.StatusMonth = 8 THEN 'Aug'
		WHEN ES.StatusMonth = 9 THEN 'Sep'
		WHEN ES.StatusMonth = 10 THEN 'Oct'
		WHEN ES.StatusMonth = 11THEN 'Nov'
		WHEN ES.StatusMonth = 12 THEN 'Dec'
		END AS MonthName
	  ,EP.LocationId
	  ,L.LocationName
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo  
-- Created table with:
-- INTO  Reports.EquipmentMonthlyOnLineStatus
FROM Reports.EquipmentRollingMonthlyHourTotals ES -- 30,240 rows plus
INNER JOIN DimTable.Equipment E
ON ES.EquipmentId = E.EquipmentId
INNER JOIN [DimTable].[PlantEquipLocation] EP
ON ES.EquipmentId = EP.EquipmentId
INNER JOIN DimTable.Plant P
ON EP.PlantId = P.PlantId
INNER JOIN DimTable.Location L
ON EP.PlantId = L.PlantId
AND EP.LocationId = L.LocationId
ORDER BY ES.StatusYear
      ,ES.StatusMonth
	  ,EP.LocationId
	  ,ES.EquipmentId
	  ,ES.EquipOnlineStatusCode
	  ,EP.PlantId
GO

/*********************************************/
/* Listing  9.4 – The New and Improved Query */
/*********************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT ReportYear
      ,Reportmonth
	  ,MonthName
	  ,LocationId
	  ,LocationName
	  ,EquipmentId
	  ,StatusCount 
	  ,RANK() OVER(
		PARTITION BY EquipmentId,ReportYear
		ORDER BY LocationId,EquipmentId ASC,ReportYear ASC,StatusCount DESC
		) AS NoFailureRank
	  ,EquipOnlineStatusCode
	  ,EquipOnLineStatusDesc
	  ,PlantId
	  ,PlantName
	  ,PlantDescription
	  ,EquipAbbrev
	  ,UnitId
	  ,UnitName
	  ,SerialNo  
FROM Reports.EquipmentMonthlyOnLineStatus -- 30,240 rows plus
WHERE ReportYear = 2002
AND EquipOnlineStatusCode = '0001'
AND EquipmentId = 'P1L1VLV1'
ORDER BY ReportYear
      ,Reportmonth
	  ,LocationId
	  ,EquipmentId
	  ,EquipOnlineStatusCode
	  ,PlantId
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/************************************/
/* Listing  9.5 – Recommended Index */
/************************************/

/*
Missing Index Details from SQLQuery2.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (54))
The Query Processor estimates that implementing the following index could improve the query cost by 91.7476%.
*/

DROP INDEX IF EXISTS ieEquipmentMonthlyOnLineStatus
ON Reports.EquipmentMonthlyOnLineStatus
GO

CREATE NONCLUSTERED INDEX ieEquipmentMonthlyOnLineStatus
ON Reports.EquipmentMonthlyOnLineStatus (ReportYear,EquipmentId,EquipOnlineStatusCode)
INCLUDE (Reportmonth,MonthName,LocationId,LocationName,StatusCount,EquipOnLineStatusDesc,PlantId,PlantName,PlantDescription,EquipAbbrev,UnitId,UnitName,SerialNo)
GO

/****************/
/* DENSE_RANK() */
/****************/

/****************************************************/
/* Listing  9.6 – RANK() versus DENSE_RANK() Report */
/****************************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT 
	EMOLS.PlantName
	,EMOLS.LocationName
	,EMOLS.ReportYear
	,MSC.CalendarQuarter AS ReportQuarter
	,EMOLS.ReportMonth -- need this for Excel when sorting spreadsheet
	,EMOLS.[MonthName] AS ReportMonth
	,EMOLS.StatusCount
	,EMOLS.EquipOnlineStatusCode
	,EMOLS.EquipOnLineStatusDesc
	-- skips next value in sequence in case of ties
	,RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName,EMOLS.ReportYear,EMOLS.EquipOnlineStatusCode
	ORDER BY EMOLS.StatusCount DESC
	) AS FailureRank

	-- preserves sequence even with ties
	,DENSE_RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName,EMOLS.ReportYear,EMOLS.EquipOnlineStatusCode
	ORDER BY EMOLS.StatusCount DESC
	) AS FailureDenseRank

FROM Reports.EquipmentMonthlyOnLineStatus EMOLS
INNER JOIN (
	SELECT DISTINCT [CalendarYear]
		,[CalendarQuarter]
		,CASE
			WHEN CalendarMonth = 1 THEN 'Jan'
			WHEN CalendarMonth = 2 THEN 'Feb'
			WHEN CalendarMonth = 3 THEN 'Mar'
			WHEN CalendarMonth = 4 THEN 'Apr'
			WHEN CalendarMonth = 5 THEN 'May'
			WHEN CalendarMonth = 6 THEN 'Jun'
			WHEN CalendarMonth = 7 THEN 'Jul'
			WHEN CalendarMonth = 8 THEN 'Aug'
			WHEN CalendarMonth = 9 THEN 'Sep'
			WHEN CalendarMonth = 10 THEN 'Oct'
			WHEN CalendarMonth = 11THEN 'Nov'
			WHEN CalendarMonth = 12 THEN 'Dec'
		END AS CalendarMonthName
	FROM [DimTable].[Calendar]
	) AS MSC
	ON (
	EMOLS.ReportYear = MSC.CalendarYear
	AND EMOLS.MonthName = MSC.CalendarMonthName
	)
WHERE EMOLS.ReportYear = 2002
AND EMOLS.EquipmentId = 'P1L1VLV1'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/**************************************/
/* A Listing  9.7 – A Better Solution */
/**************************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO
 
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO

SET STATISTICS PROFILE ON
GO 

SELECT 
	EMOLS.PlantName
	,EMOLS.LocationName
	,EMOLS.ReportYear
	,CASE
		WHEN EMOLS.[MonthName] = 'Jan' THEN 'Qtr 1'
		WHEN EMOLS.[MonthName] = 'Feb' THEN 'Qtr 1'
		WHEN EMOLS.[MonthName] = 'Mar' THEN 'Qtr 1'
		WHEN EMOLS.[MonthName] = 'Apr' THEN 'Qtr 2'
		WHEN EMOLS.[MonthName] = 'May' THEN 'Qtr 2'
		WHEN EMOLS.[MonthName] = 'Jun' THEN 'Qtr 2'
		WHEN EMOLS.[MonthName] = 'Jul' THEN 'Qtr 3'
		WHEN EMOLS.[MonthName] = 'Aug' THEN 'Qtr 3'
		WHEN EMOLS.[MonthName] = 'Sep' THEN 'Qtr 3'
		WHEN EMOLS.[MonthName] = 'Oct' THEN 'Qtr 4'
		WHEN EMOLS.[MonthName] = 'Nov' THEN 'Qtr 4'
		WHEN EMOLS.[MonthName] = 'Dec' THEN 'Qtr 4'
	END AS CalendarMonthName
	,EMOLS.[MonthName] AS ReportMonth
	,EMOLS.StatusCount
	,EMOLS.EquipOnlineStatusCode
	,EMOLS.EquipOnLineStatusDesc
	-- skips next value in sequence in case of ties
	,RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName,EMOLS.ReportYear,EMOLS.EquipOnlineStatusCode
	ORDER BY StatusCount DESC
	) AS FailureRank

	-- preserves sequence even with ties
	,DENSE_RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName,EMOLS.ReportYear,EMOLS.EquipOnlineStatusCode
	ORDER BY EMOLS.StatusCount DESC
	) AS FailureDenseRank
FROM Reports.EquipmentMonthlyOnLineStatus EMOLS
WHERE EMOLS.ReportYear = 2002
AND EMOLS.EquipmentId = 'P1L1VLV1'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*************************/
/* Try a clustered index */
/*************************/

DROP INDEX IF EXISTS [ieEquipmentMonthlyOnLineStatus] 
ON [Reports].[EquipmentMonthlyOnLineStatus]
GO

CREATE CLUSTERED INDEX [ieEquipmentMonthlyOnLineStatus] ON [Reports].[EquipmentMonthlyOnLineStatus]
(
	[ReportYear] ASC,
	[EquipmentId] ASC,
	[Reportmonth] ASC,
	[MonthName] ASC,
	[LocationId] ASC,
	[LocationName] ASC,
	[EquipOnlineStatusCode] ASC
)
WITH (
	PAD_INDEX = OFF, 
	STATISTICS_NORECOMPUTE = OFF, 
	SORT_IN_TEMPDB = ON,
	DROP_EXISTING = OFF, 
	ONLINE = OFF, 
	ALLOW_ROW_LOCKS = ON, 
	ALLOW_PAGE_LOCKS = ON, 
	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
	) ON [AP_PLANT_FG]
GO

UPDATE STATISTICS [Reports].[EquipmentMonthlyOnLineStatus]
GO

/*****************************************/
/* Generate another estimated query plan */
/* Did it improve the sort costs         */
/*****************************************/

/*********/
/* Bonus */
/*********/

-- this uses a VIEW based on the Calendar dimension
-- that uses case blocks to determine quarter and month names

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
	C.CalendarYear,
	C.QuarterName,
	C.[MonthName],
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
	C.[MonthName],
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
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],
	SumEquipFailures,

	-- skips next value in sequence in case of ties
	RANK()  OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	ORDER BY SumEquipFailures
	) AS FailureRank,

	-- preserves sequence even with ties
	DENSE_RANK()  OVER (
	PARTITION BY PlantName,LocationName,CalendarYear
	ORDER BY SumEquipFailures
	) AS FailureDenseRank

FROM FailedEquipmentCount
WHERE CalendarYear = 2008
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/***********/
/* NTILE() */
/***********/

/*********************************************/
/* Listing  9.8a – First CTE – Summing Logic */
/*********************************************/

-- Run Listing  9.8a - c as one query

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
),

/*************************************/
/* Listing  9.8b – NILE() Bucket CTE */
/*************************************/

FailureBucket (
PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,SumEquipFailures,MonthBucket)
AS (
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,SumEquipFailures,
	NTILE(5)  OVER (
	PARTITION BY PlantName,LocationName
	ORDER BY SumEquipFailures
	) AS MonthBucket
FROM FailedEquipmentCount
WHERE CalendarYear = 2008
)

/**************************************************/
/* Listing  9.8c – Categorize the Failure Buckets */
/**************************************************/

SELECT PlantName,LocationName,CalendarYear,QuarterName,[MonthName],SumEquipFailures,
CASE	
		WHEN MonthBucket = 5 AND SumEquipFailures <> 0 THEN 'Severe Failures'
		WHEN MonthBucket = 4 AND SumEquipFailures <> 0 THEN 'Critical Failures'
		WHEN MonthBucket = 3 AND SumEquipFailures <> 0 THEN 'Moderate Failures'
		WHEN MonthBucket = 2 AND SumEquipFailures <> 0 THEN 'Investigate Failures'
		WHEN MonthBucket = 1 AND SumEquipFailures <> 0 THEN 'Maintenance Failures'
	    WHEN MonthBucket = 1 AND SumEquipFailures = 0 THEN 'No issues to report'
	ELSE 'No Alerts'
END AS AlertMessage
FROM FailureBucket
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/*********************************/
/* Listing  9.9 – Improved Query */
/*********************************/

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
AS (
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,SumEquipmentFailure,
	NTILE(5)  OVER (
	PARTITION BY PlantName,LocationName
	ORDER BY SumEquipmentFailure
	) AS MonthBucket
FROM [Reports].[EquipmentFailureStatistics]
WHERE CalendarYear = 2008
)

SELECT PlantName,LocationName,CalendarYear,QuarterName,[MonthName],SumEquipmentFailure,
CASE	
		WHEN MonthBucket = 5 AND SumEquipmentFailure <> 0 THEN 'Severe Failures'
		WHEN MonthBucket = 4 AND SumEquipmentFailure <> 0 THEN 'Critical Failures'
		WHEN MonthBucket = 3 AND SumEquipmentFailure <> 0 THEN 'Moderate Failures'
		WHEN MonthBucket = 2 AND SumEquipmentFailure <> 0 THEN 'Investigate Failures'
		WHEN MonthBucket = 1 AND SumEquipmentFailure <> 0 THEN 'Maintenance Failures'
	    WHEN MonthBucket = 1 AND SumEquipmentFailure = 0 THEN 'No issues to report'
	ELSE 'No Alerts'
END AS AlertMessage
FROM FailedEquipmentCount 
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

/****************/
/* ROW_NUMBER() */
/****************/

/*****************************************************************/
/* Listing  9.10 – Failure Event Buckets with Bucket Slot Number */
/*****************************************************************/

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
AS (
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,SumEquipmentFailure,
	NTILE(5)  OVER (
	PARTITION BY PlantName,LocationName
	ORDER BY SumEquipmentFailure
	) AS MonthBucket
FROM [Reports].[EquipmentFailureStatistics]
)

SELECT PlantName,LocationName,CalendarYear,QuarterName,[MonthName]
	,CASE	
		WHEN MonthBucket = 5 AND SumEquipmentFailure <> 0 THEN 'Severe Failures'
		WHEN MonthBucket = 4 AND SumEquipmentFailure <> 0 THEN 'Critical Failures'
		WHEN MonthBucket = 3 AND SumEquipmentFailure <> 0 THEN 'Moderate Failures'
		WHEN MonthBucket = 2 AND SumEquipmentFailure <> 0 THEN 'Investigate Failures'
		WHEN MonthBucket = 1  AND SumEquipmentFailure <> 0 THEN 'Maintenance Failures'
	    WHEN MonthBucket = 1  AND SumEquipmentFailure = 0 THEN 'No issues to report'
	ELSE 'No Alerts'
	END AS StatusBucket
	,ROW_NUMBER()  OVER (
		PARTITION BY (
		CASE	
			WHEN MonthBucket = 5 AND SumEquipmentFailure <> 0 THEN 'Severe Failures'
			WHEN MonthBucket = 4 AND SumEquipmentFailure <> 0 THEN 'Critical Failures'
			WHEN MonthBucket = 3 AND SumEquipmentFailure <> 0 THEN 'Moderate Failures'
			WHEN MonthBucket = 2 AND SumEquipmentFailure <> 0 THEN 'Investigate Failures'
			WHEN MonthBucket = 1  AND SumEquipmentFailure <> 0 THEN 'Maintenance Failures'
			WHEN MonthBucket = 1  AND SumEquipmentFailure = 0 THEN 'No issues to report'
		ELSE 'No Alerts'
		END
		)
		ORDER BY SumEquipmentFailure
	) AS BucketEventNumber
	,SumEquipmentFailure AS EquipmentFailures
FROM FailedEquipmentCount 
WHERE CalendarYear IN (2008,2009,2010)
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO 

SELECT DISTINCT * 
FROM [dbo].[CheckTableRowCount]
ORDER BY 1
GO