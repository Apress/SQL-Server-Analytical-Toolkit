/***************/
/* ch08 - code */
/***************/

/*
COUNT() & SUM()
MAX() & MIN()
AVG()
GROUPING()
STRING_AGG()
STDEV() & STDEVP()
VAR() & VARP()
*/

-- Listing  8.1 – The Re-purposed CTE Component
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
-- Listing  8.1b – Insert into Report Table

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
-- Listing  8.2 – The Report Query, Rolling Failures by Quarter
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
-- Listing  8.3 – Validate Counts and Sums
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
	,COUNT(Failure) AS SumEquipmentFailure
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
-- Listing  8.4 – Plant Failures by Rolling Month, Quarter and Year
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
	) AS RollingAvgMon
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

-- Listing  8.5 – Rolling Minimum and Monthly Plant Failures
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
-- Listing  8.6 – Equipment Failure for Furnace Room, East Plan
SELECT EF.PlantName
	,EF.LocationName
	,EF.CalendarYear
	,EF.QuarterName
	,EF.MonthName
	,EF.SumEquipmentFailure
	,EF.EquipmentId
	,E.EquipAbbrev
	,MIN(EF.SumEquipmentFailure) OVER (
		PARTITION BY EF.PlantName,EF.LocationName,
EF.CalendarYear,EF.QuarterName
		ORDER BY EF.CalendarMonth
	) AS RollingMin
	,MAX(EF.SumEquipmentFailure) OVER (
		PARTITION BY EF.PlantName,EF.LocationName,
EF.CalendarYear,EF.QuarterName
		ORDER BY EF.CalendarMonth
	) AS RollingMax
FROM Reports.EquipmentFailureStatistics EF
JOIN [DimTable].[Equipment] E
ON EF.EquipmentId = E.EquipmentId
WHERE EF.CalendarYear IN(2002,2003)
AND EF.Plantname = 'East Plant'
AND EF.LocationName = 'Furnace Room'
GO
-- Listing  8.7 – Equipment Failure by Date
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
-- Listing  8.8 – Check Equipment Status
SELECT CV.CalendarDate
	,E.EquipmentId
	,E.EquipAbbrev
      ,EOLSC.EquipOnlineStatusCode
	,EOLSC.EquipOnlineStatusDesc
FROM APPlant.FactTable.EquipmentStatusHistory ESH
JOIN DimTable.Equipment E
	ON ESH.EquipmentKey = E.EquipmentKey
JOIN DimTable.EquipOnlineStatusCode EOLSC
ON ESH.EquipOnlineStatusKey = EOLSC.EquipOnlineStatusKey
JOIN DimTable.CalendarView CV
ON ESH.CalendarKey = CV.CalendarKey
WHERE E.EquipmentId = 'P3L4MOT1'
AND CV.CalendarDate IN('2002-04-02','2002-04-11','2002-04-30')
GO

-- Listing  8.9 – Equipment Failure by Hour
SELECT ESBH.StatusDate
      ,ESBH.EquipmentId
	,E.EquipAbbrev
	,M.MotorName
	,M.Rpm
	,M.Voltage
      ,ESBH.StatusHour
      ,ESBH.EquipOnlineStatusCode
	,EOLSC.EquipOnlineStatusDesc
FROM Reports.EquipmentStatusHistoryByHour ESBH
JOIN DimTable.Equipment E
ON ESBH.EquipmentId = E.EquipmentId
JOIN DimTable.Motor M
ON E.EquipmentId = M.EquipmentId
JOIN DimTable.EquipOnlineStatusCode EOLSC
ON ESBH.EquipOnlineStatusCode = EOLSC.EquipOnlineStatusCode
WHERE ESBH.EquipmentId = 'P3L4MOT1'
AND StatusDate = '2002-04-02'
GO

-- Listing  8.10 – Equipment Failure Summary Rollups
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
FROM [Reports].[EquipmentFailureStatistics]
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
-- Listing  8.11 – Pivot Table Query for Microsoft Excel
SELECT
	PlantName
	,LocationName
	,CalendarYear
	,QuarterName
	,MonthName
	,EquipmentId
	,SumEquipmentFailure
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear = 2002
ORDER BY PlantName,LocationName,CalendarYear,QuarterName,
	CalendarMonth,EquipmentId ASC
GO
-- Listing  8.12 – Assemble Temperature Report Data Stream Data
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
	
-- Listing  8.13 – Create the Message Stream
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
-- Listing  8.14 – Quarterly Equipment Failures Rollup
SELECT PlantName    AS Plant
	,LocationName AS Location
	,CalendarYear AS [Year]
	,QuarterName  AS [Quarter]
	,MonthName           AS [Month]
	,SumEquipmentFailure AS EquipFailure
	,STDEV(SumEquipmentFailure) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY PlantName,LocationName,CalendarYear
	) AS StDevQtr
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
-- Listing  8.15 – Yearly Standard Deviation
SELECT PlantName AS Plant
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
-- Listing  8.16 – Rolling Variance by Plant, Location & Year, Month
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
-- Listing  8.17 – Variance Report by Quarter for Plant and Location
SELECT PlantName           AS Plant
	,LocationName        AS Location
	,CalendarYear        AS Year
	,QuarterName         AS Quarter
	,MonthName           AS Month
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
-- Listing  8.18 – Rolling Variance by Year
SELECT PlantName    AS Plant
	,LocationName AS Location
	,CalendarYear AS [Year]
	,QuarterName  AS [Quarter]
	,MonthName    AS Month
	,SumEquipmentFailure As TotalFailures
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
-- Listing  8.19 – Plant Failure Statistical Profile
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
FROM [Reports].[EquipmentFailureStatistics]
GO
CREATE INDEX iePlantequipmentFailureProfile
ON [Reports].[EquipmentFailureStatistics]( 
	PlantName
	,LocationName
	,CalendarYear
	,CalendarMonth
	)
GO
CREATE CLUSTERED INDEX ieClustPlantequipmentFailureProfile
ON Reports.EquipmentFailureStatistics( 
	 PlantName
	,LocationName
	,CalendarYear
	,CalendarMonth
	)
GO

-- Listing  8.20 – Step 1: Create File Group for Memory Optimized Table
/************************************************/
/* CREATE FILE GROUP FOR MEMORY OPTIMIZED TABLE */
/************************************************/

ALTER DATABASE [APPlant]
ADD FILEGROUP AP_PLANT_MEM_FG
CONTAINS MEMORY_OPTIMIZED_DATA
GO
-- Listing  8.21 – Step 2: Add a File to the File Group for the Memory Optimized Table
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
-- Listing  8.22 – Step 3: Create Memory Optimized Table
CREATE TABLE Reports.EquipmentFailureStatisticsMem(
	CalendarYear			SMALLINT     NOT NULL,
	QuarterName			VARCHAR(11)  NOT NULL,
	MonthName			VARCHAR(9)   NOT NULL,
	CalendarMonth		SMALLINT     NOT NULL,
	PlantName 			VARCHAR(64)  NOT NULL,
	LocationName			VARCHAR(128) NOT NULL,
	EquipmentId			VARCHAR(8)   NOT NULL,
	CountFailureEvents		INT 		 NOT NULL,
	SumEquipmentFailure     INT 		 NOT NULL
INDEX [ieEquipFailStatMem] 	NONCLUSTERED 
(
	PlantName     ASC,
	LocationName  ASC,
	CalendarYear  ASC,
	CalendarMonth ASC,
	EquipmentId   ASC
)
)WITH (MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_ONLY )
GO
-- Listing  8.23 – Step 4:  Load the Memory Optimized Table
/***********************************/
/* LOAD THE MEMORY OPTIMIZED TABLE */
/***********************************/

TRUNCATE TABLE Reports.EquipmentFailureStatisticsMem
GO

INSERT INTO Reports.EquipmentFailureStatisticsMem
SELECT * FROM Reports.EquipmentFailureStatistics
GO


-- Listing  8.24 – 7 million Row Window Aggregate Query
WITH EquipStatusCTE (
StatusYear,StatusMonth,EquipmentId,EquipAbbrev,
	EquipOnlineStatusCode,EquipOnLineStatusDesc,StatusCount
)
AS (
SELECT YEAR(ESBH.CalendarDate) AS StatusYear
      ,MONTH(ESBH.CalendarDate) AS StatusMonth
	,ESBH.EquipmentId
	,E.EquipAbbrev
      ,ESBH.EquipOnLineStatusCode
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
      ,ESBH.EquipOnLineStatusCode
	,EOLSC.EquipOnLineStatusDesc
)
-- Listing  8.25 – Equipment Status Code Totals Rollup Query
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
	SELECT PlantId,LocationId,EquipmentId,MotorId AS UnitId,
MotorName AS UnitName
	FROM DimTable.Motor
UNION 
	SELECT PlantId,LocationId,EquipmentId,ValveId AS UnitId,
'Valve - ' + ValveName AS UnitName
	FROM DimTable.Valve
UNION 
	SELECT PlantId,LocationId,EquipmentId,TurbineId AS UnitId,
TurbineName AS UnitName
	FROM DimTable.Turbine
UNION 
	SELECT PlantId,LocationId,EquipmentId,
GeneratorId AS UnitId,GeneratorName AS UnitName
	FROM DimTable.Generator
) EP
ON ES.EquipmentId = EP.EquipmentId
INNER JOIN DimTable.Plant P
ON EP.PlantId = P.PlantId
INNER JOIN DimTable.Location L
ON EP.PlantId = L.PlantId
AND EP.LocationId = L.LocationId
--WHERE ES.StatusYear = 2002
--AND ES.EquipOnlineStatusCode = '0001'
GO


-- Listing  8.26 – Suggested index
/*
Missing Index Details from SQLQuery7.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (54))
The Query Processor estimates that implementing the following index could improve the query cost by 88.1301%.
*/

DROP INDEX IF EXISTS ieEquipOnlineStatusCode
ON Reports.EquipmentDailyStatusHistoryByHour
GO

CREATE NONCLUSTERED INDEX ieEquipOnlineStatusCode
ON Reports.EquipmentDailyStatusHistoryByHour(EquipOnlineStatusCode)
GO

-- Listing  8.27 – Create and Load Association Dimension
DROP TABLE IF EXISTS [DimTable].[PlantEquipLocation]
GO

CREATE TABLE [DimTable].[PlantEquipLocation](
	[EquipmentKey] [int] NOT NULL,
	[PlantId]     [varchar](8) NOT NULL,
	[LocationId]  [varchar](8) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[UnitId]      [varchar](8) NOT NULL,
	[UnitName]    [varchar](136) NOT NULL
) ON [AP_PLANT_FG]
GO

TRUNCATE TABLE DIMTable.PlantEquipLocation
GO

INSERT INTO DIMTable.PlantEquipLocation
SELECT MotorKey AS EquipmentKey,PlantId,LocationId,EquipmentId,
MotorId AS UnitId,MotorName AS UnitName
FROM DimTable.Motor
UNION 
	SELECT ValveKey AS EquipmentKey,PlantId,LocationId,EquipmentId,
ValveId AS UnitId,'Valve - ' + ValveName AS UnitName
FROM DimTable.Valve
UNION 
	SELECT TurbineKey AS EquipmentKey,PlantId,LocationId,EquipmentId,
TurbineId AS UnitId,TurbineName AS UnitName
FROM DimTable.Turbine
UNION 
SELECT GeneratorKey AS EquipmentKey,PlantId,LocationId,EquipmentId,
GeneratorId AS UnitId,GeneratorName AS UnitName
FROM DimTable.Generator
GO
