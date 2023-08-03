USE APPlant
GO

DROP SCHEMA IF EXISTS Reports
GO

CREATE SCHEMA Reports
GO


/***************************************/
/* Chapter 8 - Plant Database Use Case */
/* Aggregate Functions                 */
/* Created: 08/01/2023                 */
/* Modified: 03/15/2023                */
/***************************************/

/***********************/
/* Aggregate Functions */
/***********************/

/*
•	COUNT()
•	COUNT_BIG() - not covered
•	SUM()
•	MIN() & MAX()
•	AVG()
•	GROUPING()
•	STRING_AGG()
•	STDEV() & STDEVP()
•	VAR() & VARP()
*/
 
/*********************************/
/* LISTING 8.1 - COUNT() & SUM() */
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

SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,E.EquipmentId
	,COUNT(Failure) AS FailureEvents
	,SUM(Failure) AS SumEquipmentFailure
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
	,E.EquipmentId
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*************************************************************************/
/* LET'S INSERT THE RESULTS OF THE ABOVE QUERY INTO A TABLE THAT WE WILL */
/* USE FOR OUR EXAMPLES, ELIMINATING ALL CTE COMPONENTS                  */
/*************************************************************************/

TRUNCATE TABLE Reports.EquipmentFailureStatistics
GO

INSERT INTO Reports.EquipmentFailureStatistics
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,E.EquipmentId
	,CONVERT(INTEGER,COUNT(Failure)) AS CountFailureEvents
	,CONVERT(INTEGER,SUM(Failure)) AS SumEquipmentFailure
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
	,E.EquipmentId
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
GO

/************************************************************************/
/* Create a table that will store 3 days worth of equipment status code */
/* for one piece of equipment so we can use it for failuire analysis in */
/* the MIN()/MAX() sestion below.                                       */
/************************************************************************/

DROP TABLE IF EXISTS  FactTable.EquipmentStatusHistoryByHour
GO

CREATE TABLE FactTable.EquipmentStatusHistoryByHour (
StatusDate DATE NOT NULL,
EquipmentId VARCHAR(8) NOT NULL,
StatusHour SMALLINT,
EquipOnlineStatusCode CHAR(4) NOT NULL
)

TRUNCATE TABLE FactTable.EquipmentStatusHistoryByHour
GO

INSERT INTO FactTable.EquipmentStatusHistoryByHour
VALUES
	('2002-04-02','P3L4MOT1',1,'0001'),
	('2002-04-02','P3L4MOT1',2,'0001'),
	('2002-04-02','P3L4MOT1',3,'0001'),
	('2002-04-02','P3L4MOT1',4,'0001'),
	('2002-04-02','P3L4MOT1',5,'0001'),
	('2002-04-02','P3L4MOT1',6,'0001'),
	('2002-04-02','P3L4MOT1',7,'0001'),
	('2002-04-02','P3L4MOT1',8,'0001'),
	('2002-04-02','P3L4MOT1',9,'0001'),
	('2002-04-02','P3L4MOT1',10,'0001'),
	('2002-04-02','P3L4MOT1',11,'0001'),
	('2002-04-02','P3L4MOT1',12,'0002'),
	('2002-04-02','P3L4MOT1',13,'0002'),
	('2002-04-02','P3L4MOT1',14,'0003'),
	('2002-04-02','P3L4MOT1',15,'0002'),
	('2002-04-02','P3L4MOT1',16,'0002'),
	('2002-04-02','P3L4MOT1',17,'0001'),
	('2002-04-02','P3L4MOT1',18,'0003'),
	('2002-04-02','P3L4MOT1',19,'0001'),
	('2002-04-02','P3L4MOT1',20,'0003'),
	('2002-04-02','P3L4MOT1',21,'0002'),
	('2002-04-02','P3L4MOT1',22,'0001'),
	('2002-04-02','P3L4MOT1',23,'0001'),
	('2002-04-02','P3L4MOT1',24,'0001'),

	('2002-04-11','P3L4MOT1',1,'0001'),
	('2002-04-11','P3L4MOT1',2,'0001'),
	('2002-04-11','P3L4MOT1',3,'0001'),
	('2002-04-11','P3L4MOT1',4,'0001'),
	('2002-04-11','P3L4MOT1',5,'0001'),
	('2002-04-11','P3L4MOT1',6,'0001'),
	('2002-04-11','P3L4MOT1',7,'0003'),
	('2002-04-11','P3L4MOT1',8,'0003'),
	('2002-04-11','P3L4MOT1',9,'0002'),
	('2002-04-11','P3L4MOT1',10,'0001'),
	('2002-04-11','P3L4MOT1',11,'0003'),
	('2002-04-11','P3L4MOT1',12,'0003'),
	('2002-04-11','P3L4MOT1',13,'0002'),
	('2002-04-11','P3L4MOT1',14,'0001'),
	('2002-04-11','P3L4MOT1',15,'0001'),
	('2002-04-11','P3L4MOT1',16,'0001'),
	('2002-04-11','P3L4MOT1',17,'0001'),
	('2002-04-11','P3L4MOT1',18,'0001'),
	('2002-04-11','P3L4MOT1',19,'0001'),
	('2002-04-11','P3L4MOT1',20,'0001'),
	('2002-04-11','P3L4MOT1',21,'0001'),
	('2002-04-11','P3L4MOT1',22,'0001'),
	('2002-04-11','P3L4MOT1',23,'0001'),
	('2002-04-11','P3L4MOT1',24,'0001'),
	
	('2002-04-30','P3L4MOT1',1,'0001'),
	('2002-04-30','P3L4MOT1',2,'0001'),
	('2002-04-30','P3L4MOT1',3,'0001'),
	('2002-04-30','P3L4MOT1',4,'0001'),
	('2002-04-30','P3L4MOT1',5,'0001'),
	('2002-04-30','P3L4MOT1',6,'0001'),
	('2002-04-30','P3L4MOT1',7,'0001'),
	('2002-04-30','P3L4MOT1',8,'0001'),
	('2002-04-30','P3L4MOT1',9,'0001'),
	('2002-04-30','P3L4MOT1',10,'0001'),
	('2002-04-30','P3L4MOT1',11,'0001'),
	('2002-04-30','P3L4MOT1',12,'0001'),
	('2002-04-30','P3L4MOT1',13,'0001'),
	('2002-04-30','P3L4MOT1',14,'0001'),
	('2002-04-30','P3L4MOT1',15,'0001'),
	('2002-04-30','P3L4MOT1',16,'0001'),
	('2002-04-30','P3L4MOT1',17,'0001'),
	('2002-04-30','P3L4MOT1',18,'0001'),
	('2002-04-30','P3L4MOT1',19,'0001'),
	('2002-04-30','P3L4MOT1',20,'0001'),
	('2002-04-30','P3L4MOT1',21,'0001'),
	('2002-04-30','P3L4MOT1',22,'0001'),
	('2002-04-30','P3L4MOT1',23,'0001'),
	('2002-04-30','P3L4MOT1',24,'0001');
	GO

/****************/
/* USING OVER() */
/****************/

DBCC dropcleanbuffers;
CHECKPOINT;

-- turn set statistics io/time on

SET STATISTICS TIME ON
GO

SET STATISTICS IO ON
GO

-- rolling failures by quarter
SELECT
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CountFailureEvents
	,SUM(CountFailureEvents) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS SumCountFailureEvents
	,SumEquipmentFailure
	,SUM(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS SumEquipFailureFailureEvents
	,COUNT(CountFailureEvents) AS CountFailureEvents
	,COUNT(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS CountEquipFailureFailureEvents
FROM Reports.EquipmentFailureStatistics
WHERE PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
GROUP BY 
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,CountFailureEvents
	,SumEquipmentFailure
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/****************************************************/
/* USE THESE QUERIES TO VERIFY COUNT AND SUM TOTALS */
/* BY LOO0KING AT EACH EQUIPMENT FAILURES           */
/****************************************************/

SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,C.CalendarDate
	,P.PlantName
	,L.LocationName
	,E.EquipmentId
	,Failure AS FailureEvent
	,COUNT(Failure) AS CountEquipmentFailure
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
	ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
	ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
	ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
	ON L.PlantId = P.PlantId
WHERE PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,C.CalendarDate
	,P.PlantName
	,L.LocationName
	,E.EquipmentId
	,Failure 
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.CalendarMonth
	,C.CalendarDate
	,P.PlantName
	,L.LocationName
GO

/********************************/
/* LISTING 8.3 - AVG() W/OVER() */
/********************************/

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

SELECT PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,SumEquipmentFailure
	,AVG(CONVERT(DECIMAL(10,2),[SumEquipmentFailure])) OVER (
		PARTITION BY CalendarYear
		ORDER BY CalendarYear,CalendarMonth
	) AS RollingAvgeMon
	,AVG(CONVERT(DECIMAL(10,2),[SumEquipmentFailure])) OVER (
		PARTITION BY CalendarYear,QuarterName
		ORDER BY CalendarYear
	) AS RollingAvgQtr
	,AVG(CONVERT(DECIMAL(10,2),[SumEquipmentFailure])) OVER (
		PARTITION BY CalendarYear
		ORDER BY CalendarYear
	) AS RollingAvgYear
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear IN(2002,2003)
AND Plantname = 'East Plant'
AND LocationName = 'Furnace Room'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO


/**************************************/
/* LISTING 8.4 - MAX()/MIN() W/OVER() */
/**************************************/

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

SELECT PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,SumEquipmentFailure
	,MIN(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS RollingMin
	,MAX(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS RollingMax
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear IN(2002,2003)
AND Plantname = 'East Plant'
AND LocationName = 'Furnace Room'
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/******************************************/
/* Failure Report By Equipment Identifier */
/******************************************/

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

SELECT EF.PlantName
	,EF.LocationName
	,EF.CalendarYear
	,EF.QuarterName
	,EF.MonthName
	,EF.SumEquipmentFailure
	,EF.EquipmentId
	,E.EquipAbbrev
	,MIN(EF.SumEquipmentFailure) OVER (
		PARTITION BY EF.PlantName,EF.LocationName,EF.CalendarYear,EF.QuarterName
		ORDER BY EF.CalendarMonth
	) AS RollingMin
	,MAX(EF.SumEquipmentFailure) OVER (
		PARTITION BY EF.PlantName,EF.LocationName,EF.CalendarYear,EF.QuarterName
		ORDER BY EF.CalendarMonth
	) AS RollingMax
FROM Reports.EquipmentFailureStatistics EF
JOIN [DimTable].[Equipment] E
ON EF.EquipmentId = E.EquipmentId
WHERE EF.CalendarYear IN(2002,2003)
AND EF.Plantname = 'East Plant'
AND EF.LocationName = 'Furnace Room'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/**************************************/
/* Failure Report By Equipment & Date */
/**************************************/

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
	C.CalendarYear
	,C.QuarterName
	,C.CalendarDate
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,E.EquipmentId
	,E.EquipAbbrev
	,M.ManufacturerName
	,Failure AS FailureEvent
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
	ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
	ON EF.EquipmentKey = E.EquipmentKey
JOIN [DimTable].[Manufacturer] M
ON E.ManufacturerKey = M.ManufacturerKey
JOIN DimTable.Location L
	ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
	ON L.PlantId = P.PlantId
WHERE P.PlantName = 'East Plant'
AND L.LocationName = 'Furnace Room'
AND C.CalendarYear = '2002'
AND C.MonthName = 'April'
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.CalendarMonth
	,C.CalendarDate
	,P.PlantName
	,L.LocationName
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/******************************************/
/* Root cause analysis at an hourly level */
/******************************************/

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

SELECT ESBH.StatusDate
      ,ESBH.EquipmentId
	  ,E.EquipAbbrev
	  ,M.MotorName
	  ,M.Rpm
	  ,M.Voltage
      ,ESBH.StatusHour
      ,ESBH.EquipOnlineStatusCode
	  ,EOLSC.EquipOnLineStatusDesc
FROM Reports.EquipmentStatusHistoryByHour ESBH
JOIN DimTable.Equipment E
ON ESBH.EquipmentId = E.EquipmentId
JOIN [DimTable].[Motor] M
ON E.EquipmentId = M.EquipmentId
JOIN [DimTable].[EquipOnlineStatusCode] EOLSC
ON ESBH.EquipOnlineStatusCode = EOLSC.EquipOnlineStatusCode
WHERE ESBH.EquipmentId = 'P3L4MOT1'
--AND StatusDate = '2002-04-02'
AND StatusDate = '2002-04-11'
--AND StatusDate = '2002-04-30'
GO


SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/************************************************************************/
/* Need to check the status each hour for the single piece of equipment */
/************************************************************************/

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

SELECT CV.CalendarDate
	,E.EquipmentId
	,E.EquipAbbrev
    ,EOLSC.[EquipOnlineStatusCode]
	,EOLSC.EquipOnLineStatusDesc
  FROM [APPlant].[FactTable].[EquipmentStatusHistory] ESH
  JOIN DimTable.Equipment E
	ON ESH.EquipmentKey = E.EquipmentKey
JOIN [DimTable].[EquipOnlineStatusCode] EOLSC
ON ESH.EquipOnlineStatusKey = EOLSC.EquipOnlineStatusKey
JOIN DimTable.CalendarView CV
ON ESH.CalendarKey = CV.CalendarKey
WHERE E.EquipmentId = 'P3L4MOT1'
AND CV.CalendarDate IN('2002-04-02','2002-04-11','2002-04-30')
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/****************************/
/* LISTING 8.5 - GROUPING() */
/****************************/

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
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,EquipmentId
	,SumEquipmentFailure
	,SUM(SumEquipmentFailure) AS FailedEquipmentRollup
	,GROUPING(SumEquipmentFailure) AS GroupingLevels
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear = 2002
GROUP BY
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth,
	EquipmentId,SumEquipmentFailure WITH ROLLUP
ORDER BY PlantName,LocationName,CalendarYear,QuarterName,
	CalendarMonth,EquipmentId ASC,
		(
		CASE	
			WHEN SumEquipmentFailure IS NULL THEN 0
		END
	   ) DESC,
	GROUPING(SumEquipmentFailure) DESC
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/************************************/
/* To generate rows for pivot table */
/************************************/

SELECT
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,EquipmentId
	,SumEquipmentFailure
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear = 2002
ORDER BY PlantName,LocationName,CalendarYear,QuarterName,
	CalendarMonth,EquipmentId ASC
GO

/******************************/
/* LISTING 8.6 - STRING_AGG() */
/******************************/

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

-- generate a telemetry feed for turbine hourly temperatures

DROP TABLE IF EXISTS #GeneratorTemperature
GO

DECLARE @Hour TABLE (
SampleHour SMALLINT
);

INSERT INTO @Hour VALUES 
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),
(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24);

SELECT G.PlantId
      ,G.LocationId
      ,G.EquipmentId
      ,G.GeneratorId
      ,G.GeneratorName
	  ,C.CalendarDate
	  ,H.SampleHour
      ,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) * 5) AS Temperature
      ,G.Voltage
  INTO #GeneratorTemperature
  FROM DimTable.Generator G
  CROSS JOIN DimTable.Calendar C
  CROSS JOIN @Hour H
  ORDER BY G.PlantId
      ,G.LocationId
      ,G.EquipmentId
      ,G.GeneratorId
      ,G.GeneratorName
	  ,C.CalendarDate
	  ,H.SampleHour;

SELECT STRING_AGG('<msg start->PlantId:'+ PlantId
       + ',Location:' + LocationId
      + ',Equipment:' + EquipmentId
      + ',GeneratorId:' + GeneratorId
      + ',Generator Name:' + GeneratorName
	  + ',Voltage:' + CONVERT(VARCHAR,Voltage)
	  + ',Temperature:' + CONVERT(VARCHAR,Temperature)
	  + ',Sample Date:' + CONVERT(VARCHAR,CalendarDate)
	  + ',Sample Hour:' + CONVERT(VARCHAR,SampleHour) + '>','!') 
FROM #GeneratorTemperature
WHERE CalendarDate = '2005-11-30'
AND PlantId = 'PP000001'
GROUP BY PlantId
    ,LocationId
    ,EquipmentId
    ,GeneratorId
    ,GeneratorName
    ,CalendarDate
    ,SampleHour
GO

DROP TABLE IF EXISTS #GeneratorTemperature
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*********** EXAMPLE 1 **************/
/* LISTING 8.7 - STDEV() & STDEVP() */
/************************************/

/***************************************************/
/* Here is one you can use to generate bell curves */
/* in Microsoft Excel.                             */
/***************************************************/

/**************/
/* BY QUARTER */
/**************/

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

SELECT PlantName AS Plant
	,LocationName AS Location
	,CalendarYear AS [Year]
	,QuarterName AS [Quarter]
	,MonthName AS [Month]
	,SumEquipmentFailure AS EquipFailure
	,STDEV(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY PlantName,LocationName,CalendarYear
	) AS StdevQtr
	,STDEVP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY PlantName,LocationName,CalendarYear
	) AS StDevpQtr
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear IN(2002,2003)
AND PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
ORDER BY PlantName,LocationName,CalendarYear,CalendarMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*********** EXAMPLE 2 **************/
/* LISTING 8.8 - STDEV() & STDEVP() */
/************************************/

/****************************************************/
/* Here is another one you can use to generate bell */
/* curves in Microsoft Excel.                       */
/****************************************************/

/***********/
/* BY YEAR */
/***********/

-- turn set statistics io/time/profile on

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

SELECT PlantName  AS Plant
	,LocationName AS Location
	,CalendarYear AS [Year]
	,QuarterName  AS [Quarter]
	,MonthName    AS Month
	,SumEquipmentFailure As TotalFailures
	,STDEV(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarYear
	) AS RollingStdev
	,STDEVP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarYear
	) AS RollingStdevp
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear IN(2002,2003)
AND PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
ORDER BY PlantName,LocationName,CalendarYear,CalendarMonth
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/* this will work too!
PARTITION BY CalendarYear
*/

SELECT PlantName  AS Plant
	,LocationName AS Location
	,CalendarYear AS [Year]
	,QuarterName  AS [Quarter]
	,MonthName    AS Month
	,SumEquipmentFailure As TotalFailures
	,STDEV(SumEquipmentFailure) OVER (
		PARTITION BY CalendarYear
		ORDER BY CalendarYear
	) AS RollingStdev
	,STDEVP(SumEquipmentFailure) OVER (
		PARTITION BY CalendarYear
		ORDER BY CalendarYear
	) AS RollingStdevp
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear IN(2002,2003)
AND PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
ORDER BY PlantName,LocationName,CalendarYear,CalendarMonth
GO

/**************************************************************/
/* If you take out the WHERE clause predicates for plant name */
/* and location name you will need the longer PARTITION BY    */
/* clause and also longer ORDER BY clause                     */
/**************************************************************/

/******************/
/* VAR() & VARP() */
/******************/

USE APPlant
GO

/******************/
/* VAR() & VARP() */
/******************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

/**********************************/
/* Listing 8.x - Rolling Variance */
/**********************************/

SELECT PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,SumEquipmentFailure
	,VAR(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS RollingVar
	,VARP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS RollingVarp
FROM [Reports].[EquipmentFailureStatistics]
WHERE CalendarYear IN(2002,2003)
AND PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
ORDER BY PlantName,LocationName,CalendarYear,CalendarMonth
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

-- Try this out, square root of variance generates the standard deviation
/*
,SQRT(
		VAR(SumEquipmentFailure) OVER (
			PARTITION BY PlantName,LocationName,CalendarYear
			ORDER BY CalendarMonth
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) 
	) AS MyRollingStdev
	,STDEV(SumEquipmentFailure) OVER (
			PARTITION BY PlantName,LocationName,CalendarYear
			ORDER BY CalendarMonth
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS RollingStdev
*/

/*************************************/
/* Listing 8.x - Variance By Quarter */
/*************************************/

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

SELECT PlantName AS Plant
	,LocationName AS Location
	,CalendarYear AS [Year]
	,QuarterName AS [Quarter]
	,MonthName AS [Month]
	,SumEquipmentFailure AS EquipFailure
	,VAR(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY PlantName,LocationName,CalendarYear
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) AS VarByQtr
	,VARP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY PlantName,LocationName,CalendarYear
		ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) AS VarpByQtr
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear IN(2002,2003)
AND PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
ORDER BY PlantName,LocationName,CalendarYear,CalendarMonth
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*************************************/
/* Listing 8.x - Variance By Year */
/*************************************/
SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

SELECT PlantName  AS Plant
	,LocationName AS Location
	,CalendarYear AS [Year]
	,QuarterName  AS [Quarter]
	,MonthName    AS Month
	,SumEquipmentFailure As TotalFailures
	,AVG(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarYear
	) AS AvgByYear
	,VAR(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarYear
	) AS VarByYear
	,VARP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarYear
	) AS VarpByYear
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear IN(2002,2003)
AND PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
ORDER BY PlantName,LocationName,CalendarYear,CalendarMonth
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO
/******************************************/
/* LISTING 8.10 - COMPLEX FAILURE PROFILE */
/******************************************/

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

SELECT PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,SumEquipmentFailure
	,AVG(CONVERT(DECIMAL(10,2),SumEquipmentFailure)) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingAvg
	,STDEV(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingStdev
	,STDEVP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingStdevp
	,VAR(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingVar
	,VARP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingVarp
FROM Reports.EquipmentFailureStatistics
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

DROP INDEX IF EXISTS iePlantequipmentFailureProfile
ON Reports.EquipmentFailureStatistics
GO

CREATE INDEX iePlantequipmentFailureProfile
ON Reports.EquipmentFailureStatistics( 
	PlantName
	,LocationName
	,CalendarYear
	,CalendarMonth
	)
GO

DROP INDEX IF EXISTS ieClustPlantequipmentFailureProfile
ON Reports.EquipmentFailureStatistics
GO

CREATE CLUSTERED INDEX ieClustPlantequipmentFailureProfile
ON Reports.EquipmentFailureStatistics( 
	PlantName
	,LocationName
	,CalendarYear
	,CalendarMonth
	)
GO

/***********************************/
/* MEMORY OPTIMIZED TABLE APPROACH */
/***********************************/

USE MASTER
GO

/************************************************/
/* CREATE FILE GROUP FOR MEMORY OPTIMIZED TABLE */
/************************************************/

ALTER DATABASE [APPlant]
ADD FILEGROUP AP_PLANT_MEM_FG
CONTAINS MEMORY_OPTIMIZED_DATA
GO

/*****************************************************/
/* ADD FILE TO FILE GROUP FOR MEMORY OPTIMIZED TABLE */
/*****************************************************/

ALTER DATABASE [APPlant]
ADD FILE
(
    NAME = AP_PLANT_MEME_DATA,
    FILENAME = 'D:\APRESS_DATABASES\AP_PLANT\MEM_DATA\AP_PLANT_MEM_DATA.NDF'
)  
TO FILEGROUP AP_PLANT_MEM_FG
GO

/*************************************/
/* CREATE THE MEMORY OPTIMIZED TABLE */
/*************************************/

USE APPlant
GO

DROP TABLE IF  EXISTS  Reports.EquipmentFailureStatisticsMem
GO

CREATE TABLE Reports.EquipmentFailureStatisticsMem(
	CalendarYear		SMALLINT NOT NULL,
	QuarterName			VARCHAR(11) NULL,
	MonthName			VARCHAR(9) NULL,
	CalendarMonth		SMALLINT NOT NULL,
	PlantName 			VARCHAR(64) NOT NULL,
	LocationName		VARCHAR(128) NOT NULL,
	EquipmentId			VARCHAR(8) NOT NULL,
	CountFailureEvents	INT NULL,
	SumEquipmentFailure INT NULL
INDEX [ieEquipFailStatMem] NONCLUSTERED 
(
	PlantName     ASC,
	LocationName  ASC,
	CalendarYear  ASC,
	CalendarMonth ASC,
	EquipmentId   ASC
)
)WITH (MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO

/***********************************/
/* LOAD THE MEMORY OPTIMIZED TABLE */
/***********************************/

TRUNCATE TABLE Reports.EquipmentFailureStatisticsMem
GO

INSERT INTO Reports.EquipmentFailureStatisticsMem
SELECT * FROM Reports.EquipmentFailureStatistics
GO

/******************************/
/* EXECUTE THE MODIFIED QUERY */
/******************************/

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

SELECT PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,SumEquipmentFailure
	,AVG(CONVERT(DECIMAL(10,2),SumEquipmentFailure)) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingAvg
	,STDEV(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingStdev
	,STDEVP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingStdevp
	,VAR(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingVar
	,VARP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingVarp
FROM Reports.EquipmentFailureStatisticsMem
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*************************/
/* ADDING A WHERE CLAUSE */
/*************************/

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

SELECT PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,CalendarMonth
	,SumEquipmentFailure
	,AVG(CONVERT(DECIMAL(10,2),SumEquipmentFailure)) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingAvg
	,STDEV(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingStdev
	,STDEVP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingStdevp
	,VAR(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingVar
	,VARP(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth
	) AS RollingVarp
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear = 2003
AND PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
--ORDER BY PlantName,LocationName,CalendarYear,CalendarMonth
GO

-- turn set statistics io/time/profile off

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO

/*********************/
/* LARGE TABLE QUERY */
/*********************/

-- listing 8.x - query on 7 million plus row table

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

WITH EquipStatusCTE (
StatusYear,StatusMonth,EquipmentId,EquipAbbrev,
	EquipOnlineStatusCode,EquipOnLineStatusDesc,StatusCount
)
AS (
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
)

SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,EP.LocationId
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,SUM(StatusCount) OVER(
		PARTITION BY ES.EquipmentId,ES.StatusYear
		ORDER BY ES.EquipmentId,ES.StatusYear,ES.StatusMonth
		) AS SumStatusEvent
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,L.LocationId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo
FROM EquipStatusCTE ES
INNER JOIN DimTable.Equipment E
ON ES.EquipmentId = E.EquipmentId
INNER JOIN (
	SELECT PlantId,LocationId,EquipmentId,MotorId AS UnitId,MotorName AS UnitName
	FROM DimTable.Motor
UNION 
	SELECT PlantId,LocationId,EquipmentId,ValveId AS UnitId,'Valve - ' + ValveName AS UnitName
	FROM DimTable.Valve
UNION 
	SELECT PlantId,LocationId,EquipmentId,TurbineId AS UnitId,TurbineName AS UnitName
	FROM DimTable.Turbine
UNION 
	SELECT PlantId,LocationId,EquipmentId,GeneratorId AS UnitId,GeneratorName AS UnitName
	FROM DimTable.Generator
) EP
ON ES.EquipmentId = EP.EquipmentId
INNER JOIN DimTable.Plant P
ON EP.PlantId = P.PlantId
INNER JOIN DimTable.Location L
ON EP.PlantId = L.PlantId
AND EP.LocationId = L.LocationId
WHERE ES.StatusYear = 2002
AND ES.EquipOnlineStatusCode = '0001'
GO

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO


/*
Missing Index Details from SQLQuery7.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (54))
The Query Processor estimates that implementing the following index could improve the query cost by 88.1301%.
*/

/*
USE [APPlant]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Reports].[EquipmentDailyStatusHistoryByHour] ([EquipOnlineStatusCode])
GO
*/

DROP INDEX IF EXISTS ieEquipOnlineStatusCode
ON Reports.EquipmentDailyStatusHistoryByHour
GO

CREATE NONCLUSTERED INDEX ieEquipOnlineStatusCode
ON Reports.EquipmentDailyStatusHistoryByHour(EquipOnlineStatusCode)
GO

/********************************************/
/* Need this table to relpace UNION queries */
/********************************************/

USE [APPlant]
GO

DROP TABLE IF  EXISTS [DimTable].[PlantEquipLocation]
GO

CREATE TABLE [DimTable].[PlantEquipLocation](
	[EquipmentKey] [int] NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](8) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[UnitId] [varchar](8) NOT NULL,
	[UnitName] [varchar](136) NOT NULL
) ON [AP_PLANT_FG]
GO

TRUNCATE TABLE DIMTable.PlantEquipLocation
GO

INSERT INTO DIMTable.PlantEquipLocation
SELECT MotorKey AS EquipmentKey,PlantId,LocationId,EquipmentId,MotorId AS UnitId,MotorName AS UnitName
FROM DimTable.Motor
UNION 
	SELECT ValveKey AS EquipmentKey,PlantId,LocationId,EquipmentId,ValveId AS UnitId,'Valve - ' + ValveName AS UnitName
FROM DimTable.Valve
UNION 
	SELECT TurbineKey AS EquipmentKey, PlantId,LocationId,EquipmentId,TurbineId AS UnitId,TurbineName AS UnitName
FROM DimTable.Turbine
UNION 
	SELECT  GeneratorKey AS EquipmentKey,PlantId,LocationId,EquipmentId,GeneratorId AS UnitId,GeneratorName AS UnitName
FROM DimTable.Generator
GO

/*****************************************/
/* Modified query to reference new table */
/*****************************************/

WITH EquipStatusCTE (
StatusYear,StatusMonth,EquipmentId,EquipAbbrev,
	EquipOnlineStatusCode,EquipOnLineStatusDesc,StatusCount
)
AS (
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
)

SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,EP.LocationId
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,SUM(StatusCount) OVER(
		PARTITION BY ES.EquipmentId,ES.StatusYear
		ORDER BY ES.EquipmentId,ES.StatusYear,ES.StatusMonth
		) AS SumStatusEvent
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,L.LocationId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo  
FROM EquipStatusCTE ES
INNER JOIN DimTable.Equipment E
ON ES.EquipmentId = E.EquipmentId

/**********************************/
/* Replaces all the UNION queries */
/**********************************/

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

/*************************/
/* Report table approach */
/*************************/

USE [APPlant]
GO

DROP TABLE IF  EXISTS Reports.EquipmentRollingMonthlyHourTotals
GO

CREATE TABLE Reports.EquipmentRollingMonthlyHourTotals(
	StatusYear int NULL,
	StatusMonth int NULL,
	EquipmentId varchar(8) NOT NULL,
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

DBCC dropcleanbuffers;
CHECKPOINT;
GO

SET STATISTICS IO ON
GO

SET STATISTICS TIME ON
GO 

SET STATISTICS PROFILE ON
GO

UPDATE STATISTICS Reports.EquipmentRollingMonthlyHourTotals
GO

SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,EP.LocationId
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,SUM(StatusCount) OVER(
		PARTITION BY ES.EquipmentId,ES.StatusYear
		ORDER BY ES.EquipmentId,ES.StatusYear,ES.StatusMonth
		) AS SumStatusEvent
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,L.LocationId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo  
FROM Reports.EquipmentRollingMonthlyHourTotals ES
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

SET STATISTICS IO OFF
GO

SET STATISTICS TIME OFF
GO 

SET STATISTICS PROFILE OFF
GO


/*
Missing Index Details from ch08 - queries V2.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (77))
The Query Processor estimates that implementing the following index could improve the query cost by 64.5282%.
*/

/*
USE [APPlant]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Reports].[EquipmentRollingMonthlyHourTotals] ([StatusYear],[EquipOnlineStatusCode])
INCLUDE ([StatusMonth],[EquipmentId],[EquipAbbrev],[EquipOnLineStatusDesc],[StatusCount])
GO
*/

-- despite creating this index, the query plan tool asks for the same index to be recreated.

DROP INDEX IF EXISTS [ieStatusYearEquipOnlineStatusCode]
ON [Reports].[EquipmentRollingMonthlyHourTotals] 
GO

CREATE NONCLUSTERED INDEX [ieStatusYearEquipOnlineStatusCode]
ON [Reports].[EquipmentRollingMonthlyHourTotals] ([StatusYear],[EquipOnlineStatusCode])
INCLUDE ([StatusMonth],[EquipmentId],[EquipAbbrev],[EquipOnLineStatusDesc],[StatusCount])
GO

/*
Missing Index Details from ch08 - queries V2.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (77))
The Query Processor estimates that implementing the following index could improve the query cost by 64.5282%.
*/

/*
USE [APPlant]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Reports].[EquipmentRollingMonthlyHourTotals] ([StatusYear],[EquipOnlineStatusCode])
INCLUDE ([StatusMonth],[EquipmentId],[EquipAbbrev],[EquipOnLineStatusDesc],[StatusCount])
GO
*/