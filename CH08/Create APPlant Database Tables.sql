USE [APPlant]
GO

/***************************************/
/* Chapter 08,09,10 - APPlant Database */
/* Create Database Tables              */
/* Created: 08/19/2022                 */
/* Modified: 07/20/2023                */
/* Production                          */
/***************************************/

/**************/
/* DROP VIEWS */
/**************/

DROP VIEW  IF EXISTS [EquipReports].[EquipmentFailureReportView]
GO

DROP VIEW  IF EXISTS [dbo].[PlantEquipmentReport]
GO

DROP VIEW  IF EXISTS [Reports].[SumFailuresLead]
GO

DROP VIEW  IF EXISTS [Reports].[CumeDistFailures]
GO

DROP VIEW  IF EXISTS [dbo].[ReportsCumeDistFailures]
GO

DROP VIEW  IF EXISTS [DimTable].[CalendarView]
GO

/***************/
/* Drop Tables */
/***************/

DROP TABLE  IF EXISTS [Reports].[PlantSumEquipFailures]
GO

DROP TABLE  IF EXISTS [Reports].[EquipmentStatusHistoryByHour]
GO

DROP TABLE  IF EXISTS [FactTable].[EquipmentStatusHistoryByHour]
GO

DROP TABLE  IF EXISTS [Reports].[EquipmentRollingMonthlyHourTotals]
GO

DROP TABLE  IF EXISTS [Reports].[EquipmentMonthlyOnLineStatus]
GO

DROP TABLE  IF EXISTS [Reports].[EquipmentFailureStatistics]
GO

DROP TABLE  IF EXISTS [Reports].[EquipmentFailureStatisticsMem]
GO

DROP TABLE  IF EXISTS [Reports].[EquipmentMonthlyLeadLagMem]
GO

DROP TABLE  IF EXISTS [Reports].[EquipmentDailyStatusHistoryByHour]
GO

DROP TABLE  IF EXISTS [Reports].[EquipFailureManufacturer]
GO

DROP TABLE  IF EXISTS [Reports].[EquipFailPctContDisc]
GO

DROP TABLE  IF EXISTS [FactTable].[EquipmentStatusHistory]
GO

DROP TABLE  IF EXISTS [FactTable].[EquipmentFailure]
GO

DROP TABLE  IF EXISTS [EquipStatistics].[BoilerTemperatureHistory]
GO

DROP TABLE  IF EXISTS [DimTable].[Valve]
GO

DROP TABLE  IF EXISTS [DimTable].[Turbine]
GO

DROP TABLE  IF EXISTS [DimTable].[PlantEquipLocation]
GO

DROP TABLE  IF EXISTS [DimTable].[Plant]
GO

DROP TABLE  IF EXISTS [DimTable].[Motor]
GO

DROP TABLE  IF EXISTS [DimTable].[Manufacturer]
GO

DROP TABLE  IF EXISTS [DimTable].[Location]
GO

DROP TABLE  IF EXISTS [DimTable].[Generator]
GO

DROP TABLE  IF EXISTS [DimTable].[EquipOnlineStatusCode]
GO

DROP TABLE  IF EXISTS [DimTable].[EquipmentType]
GO

DROP TABLE  IF EXISTS [DimTable].[Equipment]
GO

DROP TABLE  IF EXISTS [DimTable].[CalendarEnhanced]
GO

DROP TABLE  IF EXISTS [DimTable].[Calendar]
GO

/***************/
/* Drop Schema */
/***************/

DROP SCHEMA IF EXISTS [DataCollection] 
GO

CREATE SCHEMA [DataCollection]
GO

DROP SCHEMA IF EXISTS [DimTable] 
GO

DROP SCHEMA IF EXISTS [DimTable]
GO

CREATE SCHEMA [DimTable]
GO

DROP SCHEMA IF EXISTS [EquipReports] 
GO

CREATE SCHEMA [EquipReports]
GO

DROP SCHEMA IF EXISTS [EquipStatistics]
GO

CREATE SCHEMA [EquipStatistics]
GO

DROP SCHEMA IF EXISTS [FactTable]
GO

CREATE SCHEMA [FactTable]
GO

DROP SCHEMA IF EXISTS [PlantFinance] 
GO

CREATE SCHEMA [PlantFinance]
GO

DROP SCHEMA IF EXISTS [Reports] 
GO

CREATE SCHEMA [Reports]
GO

DROP SCHEMA IF EXISTS [Tools]
GO

CREATE SCHEMA [Tools]
GO

/*****************/
/* Create Tables */
/*****************/

/*********************/
/* EQUIPMENT FAILURE */
/*********************/

CREATE TABLE [FactTable].[EquipmentFailure](
	[CalendarKey] [int] NOT NULL,
	[LocationKey] [int] NOT NULL,
	[EquipmentKey] [int] NOT NULL,
	[EquipmentTypeKey] [int] NOT NULL,
	[Failure] [int] NOT NULL
) ON [AP_PLANT_FG]
GO

/*********************/
/* EQUIPMENT CALENDAR */
/*********************/

CREATE TABLE [DimTable].[Calendar](
	[CalendarKey] [int] NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarYear] [smallint] NOT NULL,
	[CalendarQuarter] [smallint] NOT NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[CalendarDay] [smallint] NOT NULL
) ON [AP_PLANT_FG]
GO

/*************/
/* EQUIPMENT */
/*************/

CREATE TABLE [DimTable].[Equipment](
	[EquipmentKey] [int] NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[SerialNo] [varchar](34) NULL,
	[EquipAbbrev] [varchar](3) NULL,
	[EquipmentTypeKey] [int] NOT NULL,
	[ManufacturerKey] [int] NOT NULL
) ON [AP_PLANT_FG]
GO

/******************/
/* EQUIPMENT TYPE */
/******************/

CREATE TABLE [DimTable].[EquipmentType](
	[EquipmentTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[EquipmentType] [varchar](2) NOT NULL,
	[EquipmentDescription] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO

/*********/
/* VALVE */
/*********/

CREATE TABLE [DimTable].[Valve](
	[ValveKey] [int] IDENTITY(4000,1) NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[ValveId] [varchar](16) NOT NULL,
	[ValveName] [varchar](128) NOT NULL,
	[SteamTemp] [float] NOT NULL,
	[SteamPsi] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO

/*********/
/* MOTOR */
/*********/

CREATE TABLE [DimTable].[Motor](
	[MotorKey] [int] IDENTITY(3000,1) NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[MotorId] [varchar](16) NOT NULL,
	[MotorName] [varchar](128) NOT NULL,
	[Voltage] [float] NOT NULL,
	[Rpm] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO

/***********/
/* TURBINE */
/***********/

CREATE TABLE [DimTable].[Turbine](
	[TurbineKey] [int] IDENTITY(2000,1) NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[TurbineId] [varchar](16) NOT NULL,
	[TurbineName] [varchar](128) NOT NULL,
	[Voltage] [float] NOT NULL,
	[Amps] [float] NOT NULL,
	[Rpm] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO

/*************/
/* GENERATOR */
/*************/

CREATE TABLE [DimTable].[Generator](
	[GeneratorKey] [int] IDENTITY(1000,1) NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[GeneratorId] [varchar](16) NOT NULL,
	[GeneratorName] [varchar](128) NOT NULL,
	[Temperature] [float] NOT NULL,
	[Voltage] [float] NOT NULL,
	[Kva] [float] NOT NULL,
	[Amp] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO

/*********/
/* PLANT */
/*********/

CREATE TABLE [DimTable].[Plant](
	[PlantKey] [int] IDENTITY(1,1) NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[PlantDescription] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO

/************/
/* LOCATION */
/************/

CREATE TABLE [DimTable].[Location](
	[LocationKey] [int] IDENTITY(1,1) NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[LocationName] [varchar](128) NOT NULL
) ON [AP_PLANT_FG]
GO

/***************************/
/* PLANT EQUIPMERNT REPORT */
/***************************/

CREATE VIEW [dbo].[PlantEquipmentReport]
AS
SELECT C.CalendarYear,
       C.CalendarQuarter,
       C.CalendarMonth,
       C.[CalendarDate],
       L.PlantId,
       L.LocationName,
       E.EquipmentId,
       G.GeneratorId AS GeneratorId,
       M.MotorId,
       M.MotorName,
       T.TurbineId,
       T.TurbineName,
       V.ValveId,
       V.ValveName,
       ET.EquipmentDescription,
       EF.[Failure]
FROM   [APPlant].[FactTable].[EquipmentFailure] AS EF
       INNER JOIN
       [DimTable].[Calendar] AS C
       ON EF.CalendarKey = C.CalendarKey
       INNER JOIN
       [DimTable].[Equipment] AS E
       ON EF.EquipmentKey = E.EquipmentKey
       LEFT OUTER JOIN
       [DimTable].[Generator] AS G
       ON E.EquipmentId = G.EquipmentId
       LEFT OUTER JOIN
       [DimTable].[MOTOR] AS M
       ON E.EquipmentId = M.EquipmentId
       LEFT OUTER JOIN
       [DimTable].[Turbine] AS T
       ON E.EquipmentId = T.EquipmentId
       LEFT OUTER JOIN
       [DimTable].[Valve] AS V
       ON E.EquipmentId = V.EquipmentId
       INNER JOIN
       [DimTable].[Location] AS L
       ON EF.LocationKey = L.LocationKey
       INNER JOIN
       [DimTable].[EquipmentType] AS ET
       ON EF.EquipmentTypeKey = ET.EquipmentType
       INNER JOIN
       [DimTable].[Plant] AS P
       ON L.PlantId = P.PlantId;

GO

/*********************************/
/* EQUIPMENT ON LINE STATUS CODE */
/*********************************/

CREATE TABLE [DimTable].[EquipOnlineStatusCode](
	[EquipOnlineStatusKey] [int] IDENTITY(1,1) NOT NULL,
	[EquipOnlineStatusCode] [char](4) NOT NULL,
	[EquipOnLineStatusDesc] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO

/****************************/
/* EQUIPMENT STATUS HISTORY */
/****************************/

CREATE TABLE [FactTable].[EquipmentStatusHistory](
	[EquipmentKey] [int] NOT NULL,
	[CalendarKey] [int] NOT NULL,
	[EquipOnlineStatusKey] [int] NOT NULL,
	[EquipOnlineStatus] [char](1) NOT NULL
) ON [AP_PLANT_FG]
GO

/*********************/
/* CALENDAR ENHANCED */
/*********************/

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

/****************/
/* MANUFACTURER */
/****************/

CREATE TABLE [DimTable].[Manufacturer](
	[ManufacturerKey] [int] IDENTITY(1,1) NOT NULL,
	[ManufacturerId] [varchar](16) NOT NULL,
	[ManufacturerName] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO

/****************************/
/* PLANT EQUIPMENT LOCATION */
/****************************/

CREATE TABLE [DimTable].[PlantEquipLocation](
	[EquipmentKey] [int] NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[UnitId] [varchar](16) NOT NULL,
	[UnitName] [varchar](136) NOT NULL
) ON [AP_PLANT_FG]
GO

/******************************/
/* BOILER TEMPERATURE HISTORY */
/******************************/

CREATE TABLE [EquipStatistics].[BoilerTemperatureHistory](
	[LocationKey] [int] NOT NULL,
	[PlantId] [varchar](16) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[BoilerName] [varchar](64) NULL,
	[CalendarDate] [date] NOT NULL,
	[Hour] [smallint] NULL,
	[BoilerTemperature] [float] NULL
) ON [AP_PLANT_FG]
GO

/****************************/
/* EQUIP FAIL PCT CONT DISC */
/****************************/

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

/******************************/
/* EQUIP FAILURE MANUFACTURER */
/******************************/

CREATE TABLE [Reports].[EquipFailureManufacturer](
	[Plant] [varchar](256) NOT NULL,
	[Location] [varchar](256) NOT NULL,
	[Manufacturer] [varchar](256) NOT NULL,
	[Equipment] [varchar](256) NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[TempAlert] [decimal](10, 2) NULL,
	[OverUnderTemp] [decimal](10, 2) NULL,
	[NormalTemp] [decimal](10, 2) NOT NULL
) ON [AP_PLANT_FG]
GO

/******************************************/
/* EQUIPMENT DAILY STATUS HISTORY BY HOUR */
/******************************************/

CREATE TABLE [Reports].[EquipmentDailyStatusHistoryByHour](
	[CalendarDate] [date] NOT NULL,
	[DayHour] [smallint] NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[SerialNo] [varchar](34) NULL,
	[EquipmentType] [varchar](2) NOT NULL,
	[ManufacturerId] [varchar](16) NOT NULL,
	[ManufacturerName] [varchar](64) NOT NULL,
	[EquipOnlineStatusCode] [varchar](4) NOT NULL
) ON [AP_PLANT_FG]
GO

/********************************/
/* EQUIPMENT FAILURE STATISTICS */
/********************************/

CREATE TABLE [Reports].[EquipmentFailureStatistics](
	[CalendarYear] [smallint] NOT NULL,
	[QuarterName] [varchar](11) NULL,
	[MonthName] [varchar](9) NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[CountFailureEvents] [int] NULL,
	[SumEquipmentFailure] [int] NULL
) ON [AP_PLANT_FG]
GO

/***********************************/
/* EQUIPMENT MONTHLY ONLINE STATUS */
/***********************************/

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

/*****************************************/
/* EQUIPMENT ROLLING MONTHLY HOUR TOTALS */
/*****************************************/

CREATE TABLE [Reports].[EquipmentRollingMonthlyHourTotals](
	[StatusYear] [int] NULL,
	[StatusMonth] [int] NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[EquipAbbrev] [varchar](3) NULL,
	[EquipOnlineStatusCode] [varchar](4) NOT NULL,
	[EquipOnLineStatusDesc] [varchar](64) NOT NULL,
	[StatusCount] [int] NULL
) ON [AP_PLANT_FG]
GO

/************************************/
/* EQUIPMENT STATUS HISTORY BY HOUR */
/************************************/

CREATE TABLE [Reports].[EquipmentStatusHistoryByHour](
	[StatusDate] [date] NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[StatusHour] [smallint] NULL,
	[EquipOnlineStatusCode] [char](4) NOT NULL
) ON [AP_PLANT_FG]
GO

/****************************/
/* PLANT SUM EQUIP FAILURES */
/****************************/

CREATE TABLE [Reports].[PlantSumEquipFailures](
	[CalendarYear] [smallint] NOT NULL,
	[QuarterName] [varchar](11) NULL,
	[MonthName] [varchar](9) NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[SumEquipFailures] [int] NULL
) ON [AP_PLANT_FG]
GO

/****************************/
/* PLANT EQUIPMENT LOCATION */
/****************************/

DROP TABLE IF  EXISTS [DimTable].[PlantEquipLocation]
GO

CREATE TABLE [DimTable].[PlantEquipLocation](
	[EquipmentKey] [int] NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](16) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[UnitId] [varchar](16) NOT NULL,
	[UnitName] [varchar](136) NOT NULL
) ON [AP_PLANT_FG]
GO

/************************************/
/* EQUIPMENT STATUS HISTORY BY HOUR */
/************************************/

DROP TABLE IF EXISTS  FactTable.EquipmentStatusHistoryByHour
GO

CREATE TABLE FactTable.EquipmentStatusHistoryByHour (
StatusDate DATE NOT NULL,
EquipmentId VARCHAR(16) NOT NULL,
StatusHour SMALLINT,
EquipOnlineStatusCode CHAR(4) NOT NULL
)
GO

/*********/
/* VIEWS */
/*********/

/*****************/
/* CALENDAR VIEW */
/*****************/

CREATE VIEW [DimTable].[CalendarView]
AS
SELECT [CalendarKey],
       [CalendarYear],
       [CalendarQuarter],
       CASE WHEN [CalendarQuarter] = 1 THEN '1st Quarter' WHEN [CalendarQuarter] = 2 THEN '2nd Quarter' WHEN [CalendarQuarter] = 3 THEN '3rd Quarter' WHEN [CalendarQuarter] = 4 THEN '4th Quarter' END AS QuarterName,
       [CalendarMonth],
       CASE WHEN [CalendarMonth] = 1 THEN 'Jan' WHEN [CalendarMonth] = 2 THEN 'Feb' WHEN [CalendarMonth] = 3 THEN 'Mar' WHEN [CalendarMonth] = 4 THEN 'Apr' WHEN [CalendarMonth] = 5 THEN 'May' WHEN [CalendarMonth] = 6 THEN 'Jun' WHEN [CalendarMonth] = 7 THEN 'Jul' WHEN [CalendarMonth] = 8 THEN 'Aug' WHEN [CalendarMonth] = 9 THEN 'Sep' WHEN [CalendarMonth] = 10 THEN 'Oct' WHEN [CalendarMonth] = 11 THEN 'Nov' WHEN [CalendarMonth] = 12 THEN 'Dec' END AS MonthAbbrev,
       CASE WHEN [CalendarMonth] = 1 THEN 'January' WHEN [CalendarMonth] = 2 THEN 'February' WHEN [CalendarMonth] = 3 THEN 'March' WHEN [CalendarMonth] = 4 THEN 'April' WHEN [CalendarMonth] = 5 THEN 'May' WHEN [CalendarMonth] = 6 THEN 'June' WHEN [CalendarMonth] = 7 THEN 'July' WHEN [CalendarMonth] = 8 THEN 'August' WHEN [CalendarMonth] = 9 THEN 'September' WHEN [CalendarMonth] = 10 THEN 'October' WHEN [CalendarMonth] = 11 THEN 'November' WHEN [CalendarMonth] = 12 THEN 'December' END AS [MonthName],
       [CalendarDate]
FROM   [DimTable].[Calendar];

GO

/******************************/
/* REPORTS CUME DIST FAILURES */
/******************************/

CREATE VIEW [dbo].[ReportsCumeDistFailures] 
AS
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
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth
	,SumEquipFailures
	,FORMAT(CUME_DIST() OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth,SumEquipFailures 
	),'P') AS CumeDist
FROM FailedEquipmentCount
GO


/******************/
/* EQUIPMENT TYPE */
/******************/

CREATE VIEW [Reports].[CumeDistFailures] 
AS
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
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth
	,SumEquipFailures
	,FORMAT(CUME_DIST() OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		ORDER BY CalendarMonth,SumEquipFailures 
	),'P') AS CumeDist
FROM FailedEquipmentCount
GO

/*********************/
/* SUM FAILURES LEAD */
/*********************/

CREATE VIEW [Reports].[SumFailuresLead]
AS
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,C.CalendarDate
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
/*ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,P.PlantName
	,L.LocationName*/

GO

/**********************************/
/* EQUIPMENT FAILURES REPORT VIEW */
/**********************************/

CREATE VIEW [EquipReports].[EquipmentFailureReportView]
AS
SELECT ESH.EquipmentKey
	,C.CalendarDate
	,E.EquipmentId
	,E.EquipAbbrev
    ,ESH.CalendarKey
    ,ESH.EquipOnlineStatusKey
    ,ESH.EquipOnlineStatus
	,EOLSC.EquipOnlineStatusCode
	,EOLSC.EquipOnLineStatusDesc
FROM FactTable.EquipmentStatusHistory ESH
JOIN [DimTable].[Equipment] E
ON ESH.EquipmentKey = E.EquipmentKey
JOIN [DimTable].[Calendar] C
ON ESH.CalendarKey = C.CalendarKey
JOIN [DimTable].[EquipOnlineStatusCode] EOLSC
ON ESH.EquipOnlineStatusKey = EOLSC.EquipOnlineStatusKey
AND E.EquipAbbrev = 'TUR'
--ORDER BY E.EquipmentId,C.CalendarDate
GO


/***************************/
/* CHECK COLUMN DATA TYPES */
/***************************/

-- USE THIS TO MAKE SURE COLUMNS LIKE ID COLUMNS HAVE THE SAME LENGTH

CREATE OR ALTER VIEW dbo.CheckColumndataTypes
AS
SELECT t.name AS TableName,c.name AS ColumnName,c.max_length AS ColLength,ot.name
FROM sys.tables t
JOIN sys.columns c
ON t.object_id = C.object_id
JOIN sys.types ot
ON c.system_type_id = ot.system_type_id
GO

SELECT DISTINCT * FROM dbo.CheckColumndataTypes
ORDER BY 2
GO

/*************************/
/* CHECK TABLE ROW COUNT */
/*************************/

CREATE OR ALTER VIEW CheckTableRowCount
AS
SELECT t.name,P.rows
FROM sys.tables T
JOIN sys.partitions P
ON T.object_id = P.object_id
GO

