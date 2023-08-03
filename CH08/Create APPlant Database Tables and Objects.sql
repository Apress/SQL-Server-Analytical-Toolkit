USE [APPlant]
GO
/****** Object:  Schema [DataCollection]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [DataCollection]
GO
/****** Object:  Schema [DimTable]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [DimTable]
GO
/****** Object:  Schema [EquipReports]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [EquipReports]
GO
/****** Object:  Schema [EquipStatistics]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [EquipStatistics]
GO
/****** Object:  Schema [FactTable]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [FactTable]
GO
/****** Object:  Schema [PlantFinance]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [PlantFinance]
GO
/****** Object:  Schema [Reports]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [Reports]
GO
/****** Object:  Schema [Tools]    Script Date: 7/7/2023 11:51:27 AM ******/
CREATE SCHEMA [Tools]
GO

CREATE TABLE [FactTable].[EquipmentFailure](
	[CalendarKey] [int] NOT NULL,
	[LocationKey] [int] NOT NULL,
	[EquipmentKey] [int] NOT NULL,
	[EquipmentTypeKey] [int] NOT NULL,
	[Failure] [int] NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Calendar]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Calendar](
	[CalendarKey] [int] NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarYear] [smallint] NOT NULL,
	[CalendarQuarter] [smallint] NOT NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[CalendarDay] [smallint] NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Equipment]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Equipment](
	[EquipmentKey] [int] NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[SerialNo] [varchar](34) NULL,
	[EquipAbbrev] [varchar](3) NULL,
	[EquipmentTypeKey] [int] NOT NULL,
	[ManufacturerKey] [int] NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[EquipmentType]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[EquipmentType](
	[EquipmentTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[EquipmentType] [varchar](2) NOT NULL,
	[EquipmentDescription] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Valve]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Valve](
	[ValveKey] [int] IDENTITY(4000,1) NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](8) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[ValveId] [varchar](8) NOT NULL,
	[ValveName] [varchar](128) NOT NULL,
	[SteamTemp] [float] NOT NULL,
	[SteamPsi] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Motor]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Motor](
	[MotorKey] [int] IDENTITY(3000,1) NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](8) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[MotorId] [varchar](8) NOT NULL,
	[MotorName] [varchar](128) NOT NULL,
	[Voltage] [float] NOT NULL,
	[Rpm] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Turbine]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Turbine](
	[TurbineKey] [int] IDENTITY(2000,1) NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](8) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[TurbineId] [varchar](8) NOT NULL,
	[TurbineName] [varchar](128) NOT NULL,
	[Voltage] [float] NOT NULL,
	[Amps] [float] NOT NULL,
	[Rpm] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Generator]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Generator](
	[GeneratorKey] [int] IDENTITY(1000,1) NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](8) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[GeneratorId] [varchar](8) NOT NULL,
	[GeneratorName] [varchar](128) NOT NULL,
	[Temperature] [float] NOT NULL,
	[Voltage] [float] NOT NULL,
	[Kva] [float] NOT NULL,
	[Amp] [float] NOT NULL,
	[PlantKey] [int] NULL,
	[LocationKey] [int] NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Plant]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Plant](
	[PlantKey] [int] IDENTITY(1,1) NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[PlantDescription] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[Location]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Location](
	[LocationKey] [int] IDENTITY(1,1) NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](8) NOT NULL,
	[LocationName] [varchar](128) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  View [dbo].[PlantEquipmentReport]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  View [DimTable].[CalendarView]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  View [dbo].[ReportsCumeDistFailures]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
/****** Object:  View [Reports].[CumeDistFailures]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
/****** Object:  View [Reports].[SumFailuresLead]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
/****** Object:  Table [DimTable].[EquipOnlineStatusCode]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[EquipOnlineStatusCode](
	[EquipOnlineStatusKey] [int] IDENTITY(1,1) NOT NULL,
	[EquipOnlineStatusCode] [char](4) NOT NULL,
	[EquipOnLineStatusDesc] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [FactTable].[EquipmentStatusHistory]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FactTable].[EquipmentStatusHistory](
	[EquipmentKey] [int] NOT NULL,
	[CalendarKey] [int] NOT NULL,
	[EquipOnlineStatusKey] [int] NOT NULL,
	[EquipOnlineStatus] [char](1) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  View [EquipReports].[EquipmentFailureReportView]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [EquipReports].[EquipmentFailureReportView]
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
/****** Object:  Table [DimTable].[CalendarEnhanced]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [DimTable].[Manufacturer]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Manufacturer](
	[ManufacturerKey] [int] IDENTITY(1,1) NOT NULL,
	[ManufacturerId] [varchar](8) NOT NULL,
	[ManufacturerName] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[PlantBudget]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[PlantBudget](
	[PlantBudgetKey] [smallint] IDENTITY(1,1) NOT NULL,
	[CalendarYear] [smallint] NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[Budget] [decimal](10, 2) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [DimTable].[PlantEquipLocation]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [DimTable].[PlantExpenseCategory]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[PlantExpenseCategory](
	[PlantExpenseCategoryKey] [smallint] IDENTITY(1,1) NOT NULL,
	[ExpenseCategoryCode] [char](2) NOT NULL,
	[ExpenseCategoryDesc] [varchar](64) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [EquipStatistics].[BoilerTemperatureHistory]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EquipStatistics].[BoilerTemperatureHistory](
	[LocationKey] [int] NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[LocationId] [varchar](8) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[BoilerName] [varchar](64) NULL,
	[CalendarDate] [date] NOT NULL,
	[Hour] [smallint] NULL,
	[BoilerTemperature] [float] NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [FactTable].[EquipmentStatusHistoryByHourOld]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FactTable].[EquipmentStatusHistoryByHourOld](
	[StatusDate] [date] NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[StatusHour] [smallint] NULL,
	[EquipOnlineStatusCode] [char](4) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [FactTable].[PlantExpense]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FactTable].[PlantExpense](
	[CalendarDateKey] [int] NOT NULL,
	[PlantKey] [int] NOT NULL,
	[PlantExpenseCategoryKey] [int] NOT NULL,
	[ExpenseAmount] [decimal](10, 2) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [Reports].[EquipFailPctContDisc]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/****** Object:  Table [Reports].[EquipFailureManufacturer]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [Reports].[EquipmentDailyStatusHistoryByHour]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reports].[EquipmentDailyStatusHistoryByHour](
	[CalendarDate] [date] NOT NULL,
	[DayHour] [smallint] NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[SerialNo] [varchar](34) NULL,
	[EquipmentType] [varchar](2) NOT NULL,
	[ManufacturerId] [varchar](8) NOT NULL,
	[ManufacturerName] [varchar](64) NOT NULL,
	[EquipOnlineStatusCode] [varchar](4) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [Reports].[EquipmentFailureStatistics]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reports].[EquipmentFailureStatistics](
	[CalendarYear] [smallint] NOT NULL,
	[QuarterName] [varchar](11) NULL,
	[MonthName] [varchar](9) NULL,
	[CalendarMonth] [smallint] NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[CountFailureEvents] [int] NULL,
	[SumEquipmentFailure] [int] NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [Reports].[EquipmentMonthlyOnLineStatus]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reports].[EquipmentMonthlyOnLineStatus](
	[ReportYear] [int] NULL,
	[Reportmonth] [int] NULL,
	[MonthName] [varchar](3) NULL,
	[LocationId] [varchar](8) NOT NULL,
	[LocationName] [varchar](128) NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[StatusCount] [int] NULL,
	[EquipOnlineStatusCode] [varchar](4) NOT NULL,
	[EquipOnLineStatusDesc] [varchar](64) NOT NULL,
	[PlantId] [varchar](8) NOT NULL,
	[PlantName] [varchar](64) NOT NULL,
	[PlantDescription] [varchar](64) NOT NULL,
	[EquipAbbrev] [varchar](3) NULL,
	[UnitId] [varchar](8) NOT NULL,
	[UnitName] [varchar](136) NOT NULL,
	[SerialNo] [varchar](34) NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [Reports].[EquipmentRollingMonthlyHourTotals]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reports].[EquipmentRollingMonthlyHourTotals](
	[StatusYear] [int] NULL,
	[StatusMonth] [int] NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[EquipAbbrev] [varchar](3) NULL,
	[EquipOnlineStatusCode] [varchar](4) NOT NULL,
	[EquipOnLineStatusDesc] [varchar](64) NOT NULL,
	[StatusCount] [int] NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [Reports].[EquipmentStatusHistoryByHour]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reports].[EquipmentStatusHistoryByHour](
	[StatusDate] [date] NOT NULL,
	[EquipmentId] [varchar](8) NOT NULL,
	[StatusHour] [smallint] NULL,
	[EquipOnlineStatusCode] [char](4) NOT NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  Table [Reports].[PlantSumEquipFailures]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [Reports].[TempSensorLog]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reports].[TempSensorLog](
	[BoilerId] [varchar](24) NULL,
	[SensorId] [varchar](24) NULL,
	[ReadingHour] [smallint] NULL,
	[Temperature] [decimal](10, 2) NULL,
	[IslandGapGroup] [varchar](8) NULL
) ON [AP_PLANT_FG]
GO
/****** Object:  StoredProcedure [FactTable].[usp_RandomFloat]    Script Date: 7/7/2023 11:51:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [FactTable].[usp_RandomFloat]
@RANDOM_VALUE FLOAT OUTPUT, @START_RANGE FLOAT, @STOP_RANGE FLOAT
AS
SET @RANDOM_VALUE = CONVERT (FLOAT, ROUND(UPPER(RAND() * @STOP_RANGE + @START_RANGE), 2));

GO
