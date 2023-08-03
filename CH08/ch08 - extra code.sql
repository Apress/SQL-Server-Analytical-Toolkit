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