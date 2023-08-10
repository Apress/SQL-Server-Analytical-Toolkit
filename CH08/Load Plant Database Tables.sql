USE [APPlant]
GO

/*************************************/
/* Chapter 08,09,10 - Plant Database */
/* Load Tables                       */
/* Created: 08/19/2022               */
/* Modified: 07/20/2023              */
/* Production                        */
/*************************************/

SET NOCOUNT ON
GO

-- consider turning NOCOUNT on
-- if you do not want to see the 1 row affected message
-- once the code executes, turn NOCOUNT off

/*
SET NOCOUNT ON
GO

-- TSQL script

SET NOCOUNT OFF
GO
*/

/***********************/
/* LOAD CALENDAR TABLE */
/***********************/

TRUNCATE TABLE [DimTable].[Calendar]
GO

DECLARE @StartDate DATE;
DECLARE @StopDate DATE;
DECLARE @CurrentDate DATE;

SET @StartDate = '01/01/2002'
SET @StopDate = '12/31/2022'

SET @CurrentDate = @StartDate

WHILE (@CurrentDate <= @StopDate) 
BEGIN

INSERT INTO [DimTable].[Calendar]
VALUES (
CONVERT(INT,
	(
	CONVERT(VARCHAR,YEAR(@CurrentDate)) +
	CONVERT(VARCHAR,DATEPART(qq,@CurrentDate)) +
	CONVERT(VARCHAR,MONTH(@CurrentDate)) +
	CONVERT(VARCHAR,DAY(@CurrentDate))
	)
),
@CurrentDate,
YEAR(@CurrentDate),
DATEPART(qq,@CurrentDate),
MONTH(@CurrentDate),
DAY(@CurrentDate)
);

SET @CurrentDate = DATEADD(dd,1,@CurrentDate);
END
GO

SELECT * FROM [DimTable].[Calendar]
GO

/**************/
/* LOAD PLANT */
/**************/

TRUNCATE TABLE [DimTable].[Plant]
GO

INSERT INTO [DimTable].[Plant]
VALUES
	('PP000001','North Plant','North Electrical Generation Plant'),
	('PP000002','South Plant','South Electrical Generation Plant'),
	('PP000003','East Plant','East Electrical Generation Plant'),
	('PP000004','West Plant','West Electrical Generation Plant');
GO

/*****************************/
/* LOAD EQUIPMENT_TYPE TABLE */
/*****************************/

TRUNCATE TABLE [DimTable].[EquipmentType]
GO

INSERT INTO [DimTable].[EquipmentType]
VALUES
	('01','GENERATOR'),
	('02','MOTOR'),
	('03','TURBINE'),
	('04','VALVE');

SELECT * FROM [DimTable].[EquipmentType]
GO

/***********************/
/* LOAD PLANT LOCATION */
/***********************/

-- each plant has 4 locations

TRUNCATE TABLE [DimTable].[Location]
GO

INSERT INTO [DimTable].[Location]
VALUES
	-- Plant 1
	('PP000001','P1L00001','Boiler Room'),
	('PP000001','P1L00002','Turbine Room'),
	('PP000001','P1L00003','Generator Room'),
	('PP000001','P1L00004','Furnace Room'),
	-- Plant 2
	('PP000002','P2L00001','Boiler Room'),
	('PP000002','P2L00002','Turbine Room'),
	('PP000002','P2L00003','Generator Room'),
	('PP000002','P2L00004','Furnace Room'),
	-- Plant 3
	('PP000003','P3L00001','Boiler Room'),
	('PP000003','P3L00002','Turbine Room'),
	('PP000003','P3L00003','Generator Room'),
	('PP000003','P3L00004','Furnace Room'),
	-- Plant 4
	('PP000004','P4L00001','Boiler Room'),
	('PP000004','P4L00002','Turbine Room'),
	('PP000004','P4L00003','Generator Room'),
	('PP000004','P4L00004','Furnace Room')
GO

SELECT * FROM [DimTable].[Location]
GO


/*************************/
/* LOAD GENERATOR TABLE  */
/*************************/

TRUNCATE TABLE [DimTable].[Generator]
GO

INSERT INTO [DimTable].[Generator]
VALUES
('PP000001','P1L00003','P1L3GEN1','GEN00001','Electrical Generator',100.0,1000.00,2400.00,120.0,NULL,NULL),
('PP000002','P2L00003','P2L3GEN2','GEN00002','Electrical Generator',100.0,1000.00,2400.00,120.0,NULL,NULL),
('PP000003','P3L00003','P3L3GEN3','GEN00003','Electrical Generator',100.0,1000.00,2400.00,120.0,NULL,NULL),
('PP000004','P4L00003','P4L3GEN4','GEN00004','Electrical Generator',100.0,1000.00,2400.00,120.0,NULL,NULL);
GO

SELECT * FROM [DimTable].[Generator]
GO

-- load more generators by modifying existing data
-- equipment and generator id will be longer than 8!

INSERT INTO [DimTable].[Generator]
SELECT [PlantId]
      ,[LocationId]
      ,SUBSTRING([EquipmentId],1,7) + CONVERT(VARCHAR,[GeneratorKey] + 4) AS EquipmentId
      ,SUBSTRING([GeneratorId],1,7) + CONVERT(VARCHAR,[GeneratorKey] + 4) AS GeneratorId
      ,[GeneratorName]
      ,250 AS [Temperature]
      ,[Voltage]/2 AS [Voltage]
      ,[Kva]/2 AS [Kva]
      ,[Amp]/2 AS [Amp]
	  ,NULL,NULL
FROM [DimTable].[Generator]
GO


/*
UNION ALL
SELECT [PlantId]
      ,[LocationId]
      ,SUBSTRING([EquipmentId],1,7) + CONVERT(VARCHAR,[GeneratorKey] + 8) AS EquipmentId
      ,SUBSTRING([GeneratorId],1,7) + CONVERT(VARCHAR,[GeneratorKey] + 8) AS GeneratorId
      ,[GeneratorName]
      ,200 AS [Temperature]
      ,[Voltage]/4 AS [Voltage]
      ,[Kva]/4 AS [Kva]
      ,[Amp]/4 AS [Amp]
FROM [DimTable].[Generator]
GO
*/

/********************/
/* LOAD MOTOR TABLE */
/********************/

-- Motors are in the furnace rooms as they
-- are required to spon cooling & ventilation fans
-- each plant has 5 Motors

TRUNCATE TABLE [DimTable].[Motor]
GO

INSERT INTO [DimTable].[Motor]
VALUES
('PP000001','P1L00004','P1L4MOT1','MOT00001','North Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000002','P2L00004','P2L4MOT1','MOT00002','North Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000003','P3L00004','P3L4MOT1','MOT00003','North Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000004','P4L00004','P4L4MOT1','MOT00004','North Ventilation Motor',480.0,700.00,NULL,NULL),

('PP000001','P1L00004','P1L4MOT2','MOT00005','West Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000002','P2L00004','P2L4MOT2','MOT00006','West Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000003','P3L00004','P3L4MOT2','MOT00007','West Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000004','P4L00004','P4L4MOT2','MOT00008','West Ventilation Motor',480.0,700.00,NULL,NULL),

('PP000001','P1L00004','P1L4MOT3','MOT00009','South Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000002','P2L00004','P2L4MOT3','MOT00010','South Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000003','P3L00004','P3L4MOT3','MOT00011','South Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000004','P4L00004','P4L4MOT3','MOT00012','South Ventilation Motor',480.0,700.00,NULL,NULL),

('PP000001','P1L00004','P1L4MOT4','MOT00013','East Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000002','P2L00004','P2L4MOT4','MOT00014','East Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000003','P3L00004','P3L4MOT4','MOT00015','East Ventilation Motor',480.0,700.00,NULL,NULL),
('PP000004','P4L00004','P4L4MOT4','MOT00016','East Ventilation Motor',480.0,700.00,NULL,NULL);
GO

SELECT * FROM [DimTable].[Motor]
ORDER BY [PlantId],[LocationId]
GO

/**********************/
/* LOAD TURBINE TABLE */
/**********************/

-- each plant has one turbine and it is loaded in location L0000002

TRUNCATE TABLE [DimTable].[Turbine]
GO

INSERT INTO [DimTable].[Turbine]
VALUES
('PP000001','P1L00002','P1L4TUR1','TUR00001','Plant 1 Turbine',480.0,120.00,700.00,NULL,NULL),
('PP000002','P2L00002','P2L4TUR1','TUR00002','Plant 2 Turbine',480.0,120.00,700.00,NULL,NULL),
('PP000003','P3L00002','P3L4TUR1','TUR00003','Plant 3 Turbine',480.0,120.00,700.00,NULL,NULL),
('PP000004','P4L00002','P4L4TUR1','TUR00004','Plant 4 Turbine',480.0,120.00,700.00,NULL,NULL);
GO

SELECT * FROM [DimTable].[Turbine]
GO


/********************/
/* LOAD VALVE TABLE */
/********************/

-- each plant has 4 valves and ithey are in location L0000001,
-- the boiler room

TRUNCATE TABLE [DimTable].[Valve]
GO

INSERT INTO [DimTable].[Valve]
VALUES
('PP000001','P1L00001','P1L1VLV1','VLV00001','North Side Boiler Room',500,250,NULL,NULL),
('PP000002','P2L00001','P2L1VLV1','VLV00002','North Side Boiler Room',500,250,NULL,NULL),
('PP000003','P3L00001','P3L1VLV1','VLV00003','North Side Boiler Room',500,250,NULL,NULL),
('PP000004','P4L00001','P4L1VLV1','VLV00004','North Side Boiler Room',500,250,NULL,NULL),

('PP000001','P1L00001','P1L1VLV2','VLV00005','West Side Boiler Room',500,250,NULL,NULL),
('PP000002','P2L00001','P2L1VLV2','VLV00006','West Side Boiler Room',500,250,NULL,NULL),
('PP000003','P3L00001','P3L1VLV2','VLV00007','West Side Boiler Room',500,250,NULL,NULL),
('PP000004','P4L00001','P4L1VLV2','VLV00008','West Side Boiler Room',500,250,NULL,NULL),

('PP000001','P1L00001','P1L1VLV3','VLV00009','South Side Boiler Room',500,250,NULL,NULL),
('PP000002','P2L00001','P2L1VLV3','VLV00010','South Side Boiler Room',500,250,NULL,NULL),
('PP000003','P3L00001','P3L1VLV3','VLV00011','South Side Boiler Room',500,250,NULL,NULL),
('PP000004','P4L00001','P4L1VLV3','VLV00012','South Side Boiler Room',500,250,NULL,NULL),

('PP000001','P1L00001','P1L1VLV4','VLV00013','East Side Boiler Room',500,250,NULL,NULL),
('PP000002','P2L00001','P2L1VLV4','VLV00014','East Side Boiler Room',500,250,NULL,NULL),
('PP000003','P3L00001','P3L1VLV4','VLV00015','East Side Boiler Room',500,250,NULL,NULL),
('PP000004','P4L00001','P4L1VLV4','VLV00016','East Side Boiler Room',500,250,NULL,NULL);
GO

SELECT *
FROM [DimTable].[Valve]
ORDER BY [PlantId],[LocationId],[EquipmentId],[ValveId]
GO

/*
ALTER TABLE [DimTable].[Generator]
ADD PlantKey INTEGER NULL
GO

ALTER TABLE [DimTable].[Generator]
ADD LocationKey INTEGER NULL
GO
*/

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

/*
ALTER TABLE [DimTable].[Motor]
ADD PlantKey INTEGER NULL
GO

ALTER TABLE [DimTable].[Motor]
ADD LocationKey INTEGER NULL
GO
*/

UPDATE [DimTable].[Motor]
SET PlantKey = P.PlantKey
FROM [DimTable].[Motor] M
JOIN [DimTable].[Plant] P
ON M.PlantId = P.PlantId
GO

UPDATE [DimTable].[Motor]
SET LocationKey = P.LocationKey
FROM [DimTable].[Motor] M
JOIN [DimTable].[Location] P
ON M.LocationId = P.LocationId
GO

SELECT * FROM [DimTable].[Motor]
GO

/*
ALTER TABLE [DimTable].[Turbine]
ADD PlantKey INTEGER NULL
GO

ALTER TABLE [DimTable].[Turbine]
ADD LocationKey INTEGER NULL
GO
*/

UPDATE [DimTable].[Turbine]
SET PlantKey = P.PlantKey
FROM [DimTable].[Turbine] T
JOIN [DimTable].[Plant] P
ON T.PlantId = P.PlantId
GO

UPDATE [DimTable].[Turbine]
SET LocationKey = P.LocationKey
FROM [DimTable].[Turbine] T
JOIN [DimTable].[Location] P
ON T.LocationId = P.LocationId
GO

SELECT * FROM [DimTable].[Turbine]
GO

/*
ALTER TABLE [DimTable].[Valve]
ADD PlantKey INTEGER NULL
GO

ALTER TABLE [DimTable].[Valve]
ADD LocationKey INTEGER NULL
GO
*/

UPDATE [DimTable].[Valve]
SET PlantKey = P.PlantKey
FROM [DimTable].[Valve] V
JOIN [DimTable].[Plant] P
ON V.PlantId = P.PlantId
GO

UPDATE [DimTable].[Valve]
SET LocationKey = P.LocationKey
FROM [DimTable].[Valve] V
JOIN [DimTable].[Location] P
ON V.LocationId = P.LocationId
GO

SELECT * FROM [DimTable].[Valve]
GO


/****************/
/* MANUFACTURER */
/****************/

TRUNCATE TABLE [DimTable].[Manufacturer]
GO

INSERT INTO [DimTable].[Manufacturer]
VALUES
	('MANU001','ACME VALVES AND PIPES'),
	('MANU002','ACME TURBINES'),
	('MANU003','ACME INDUSTRIAL MOTOR'),
	('MANU004','ACME HEAVY GENERATORS'),

	('MANU005','COUNTRY VALVES AND PIPES'),
	('MANU006','MOE''S INDUSTRIAL TURBINES'),
	('MANU007','CITY ENGINEERING INDUSTRIAL MOTOR'),
	('MANU008','CUSTOM HEAVY GENERATORS'),
	
	('MANU009','COUNTRY VALVES AND PIPES'),
	('MANU010','MOE''s INDUSTRIAL TURBINES'),
	('MANU011','CITY ENGINEERING INDUSTRIAL MOTOR'),
	('MANU012','CUSTOM HEAVY GENERATORS'),
	('MANU017','INDUSTRIAL HEAVY GENERATORS');
GO

SELECT *
FROM [DimTable].[Manufacturer]
GO


/*************/
/* EQUIPMENT */
/*************/

/* need to update 

CREATE TABLE [DimTable].[Equipment](
	[EquipmentKey]     [int] NOT NULL,
	[EquipmentId]      [varchar](16) NOT NULL,
	[SerialNo]         [varchar](34) NULL,
	[EquipAbbrev]      [varchar](3) NULL,
	[EquipmentTypeKey] [int] NOT NULL,
	[ManufacturerKey]  [int] NOT NULL
) ON [AP_PLANT_FG]
GO


SELECT [GeneratorKey], 
	[EquipmentId], 'SN-' + [EquipmentId], 
	'GEN',[EquipmentTypeKey],[ManufacturerKey]
FROM [DimTable].[Generator]
*/

TRUNCATE TABLE [DimTable].[Equipment]
GO

INSERT INTO [DimTable].[Equipment]
SELECT [GeneratorKey], 
	[EquipmentId], 'SN-' + [EquipmentId], 
	'GEN', 1,4
FROM [DimTable].[Generator]
UNION ALL
SELECT [TurbineKey],[EquipmentId],'SN-'+ [EquipmentId],
	'TUR',3,2
FROM [DimTable].[Turbine]
UNION ALL
SELECT [MotorKey],
	[EquipmentId],'SN-'+ [EquipmentId],
	'MOT',2,11
FROM [DimTable].[Motor]
UNION ALL
SELECT [ValveKey],
	[EquipmentId],'SN-' + [EquipmentId],'VLV',
	4,5
FROM [DimTable].[Valve]
GO

SELECT * FROM [DimTable].[Equipment]
GO

/*******************/
/* LOAD FACT TABLE */
/*******************/

USE [APPlant]
GO

/**************************/
/* Runs in 4 seconds      */
/* Generates 306,800 rows */
/**************************/

TRUNCATE TABLE [FactTable].[EquipmentFailure]
GO

INSERT INTO [FactTable].[EquipmentFailure]
/*
EquipmentTypeKey	EquipmentType	EquipmentDescription
1	                01	            GENERATOR
2	                02	            MOTOR
3	                03	            TURBINE
4	                04	            VALVE
*/

SELECT C.[CalendarKey]
	,L.LocationKey
--	,L.LocationId
--	,G.LocationId
	,G.GeneratorKey
--	,G.EquipmentId
	,1 AS [EquipmentTypeKey]
	,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	40) AS Failure
FROM [DimTable].[Generator] G
JOIN [DimTable].[Location] L
ON G.LocationId = L.LocationId
CROSS JOIN [DimTable].[Calendar] C
WHERE G.GeneratorId = 'GEN00002'
AND (
	DAY(C.[CalendarDate]) IN (4,9,15) 
--	AND YEAR(C.[CalendarDate]) IN (2002,2004,2006,2007)
	)
UNION ALL
SELECT C.CalendarKey
	,L.LocationKey
	,M.MotorKey
	,2 AS EquipmentTypeKey
	,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	50) AS Failure

FROM [DimTable].[Motor] M
JOIN [DimTable].[Location] L
ON M.LocationId = L.LocationId
CROSS JOIN [DimTable].[Calendar] C
WHERE M.MotorId IN ('MOT00003','MOT00005','MOT00009','MOT000012')
AND (
	DAY(C.[CalendarDate]) IN (2,11,30) 
--	AND YEAR(C.[CalendarDate]) IN (2011,2017,2020)
	)
UNION ALL
SELECT C.CalendarKey
	,L.LocationKey
	,T.TurbineKey
	,3 AS [TurbineKey]
	,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	50) AS Failure

FROM [DimTable].[Turbine] T
JOIN [DimTable].[Location] L
ON T.LocationId = L.LocationId
CROSS JOIN [DimTable].[Calendar] C
WHERE T.TurbineId = 'TUR00003'
AND C.CalendarDate IN ('2002-10-01','2007-08-05','2011-11-05','2015-09-05','2018-2-05')
UNION ALL
SELECT C.CalendarKey
	,L.LocationKey
	,V.ValveKey
	,4 AS EquipmentTypeKey
	,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	45) AS Failure

FROM [DimTable].[Valve] V
JOIN [DimTable].[Location] L
ON V.LocationId = L.LocationId
CROSS JOIN [DimTable].[Calendar] C
WHERE V.ValveId IN ('VLV00005','VLV00009','VLV00004','VLV00015')
AND (
	DAY(C.[CalendarDate]) IN (2,17,30) 
--	AND YEAR(C.[CalendarDate]) IN (2008,2013,2017)
	)
GO

/*****************/
/* Check out IDs */
/*****************/

SELECT [GeneratorId]
FROM [APPlant].[DimTable].[Generator]
UNION ALL
SELECT [TurbineId]
FROM [APPlant].[DimTable].[Turbine]
UNION ALL
SELECT [MotorId]
FROM [APPlant].[DimTable].[Motor]
UNION ALL
SELECT [ValveId]
FROM [APPlant].[DimTable].[Valve]
GO

/******************************************/
/* Load EquipmentDailyStatusHistoryByHour */
/******************************************/

TRUNCATE TABLE [Reports].[EquipmentDailyStatusHistoryByHour]
GO

-- this eats up a lot of log space (8 million rows)

DECLARE @DayHour TABLE (DayHour SMALLINT);

INSERT INTO @DayHour
VALUES 
	(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),
	(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24);

TRUNCATE TABLE [Reports].[EquipmentDailyStatusHistoryByHour];

INSERT INTO [Reports].[EquipmentDailyStatusHistoryByHour]
SELECT C.[CalendarDate]
	,DH.DayHour
	,E.EquipmentId
	,E.SerialNo
	,ET.EquipmentType
	,M.ManufacturerId
	,M.ManufacturerName
--	,'0001' AS [EquipOnlineStatusCode]
--	,CASE
--		WHEN ABS(CHECKSUM(NewId())) % 11 < 3 THEN '0003'
--		WHEN ABS(CHECKSUM(NewId())) % 11 BETWEEN 3 AND 9 THEN '0001'
--		ELSE '0002'
	-- OR  CRYPT_GEN_RANDOM(2) % 10000
	-- CRYPT_GEN_RANDOM(2) % 100
	--END AS [EquipOnlineStatusCode]
	,CASE
		WHEN CRYPT_GEN_RANDOM(2) % 100 < 5 THEN '0003'
		WHEN CRYPT_GEN_RANDOM(2) % 100 BETWEEN 6 AND 95 THEN '0001'
		ELSE '0002'
	-- OR  CRYPT_GEN_RANDOM(2) % 10000

	-- CRYPT_GEN_RANDOM(2) % 100
	--https://stackoverflow.com/questions/5003028/how-can-i-fill-
	--a-column-with-random-numbers-in-sql-i-get-the-same-value-in-ever

	END AS [EquipOnlineStatusCode]
--INTO [Reports].[EquipmentDailyStatusHistoryByHour]
FROM [DimTable].[Calendar] C
CROSS JOIN  @DayHour DH
CROSS JOIN [DimTable].[Equipment] E
JOIN [DimTable].[EquipmentType] ET
	ON E.EquipmentTypeKey = ET.EquipmentTypeKey
JOIN [DimTable].[Manufacturer] M
	ON E.ManufacturerKey = M.ManufacturerKey
GO

/*
check

SELECT [CalendarDate]
      ,[DayHour]
      ,[EquipmentId]
      ,[SerialNo]
      ,[EquipmentType]
      ,[ManufacturerId]
      ,[ManufacturerName]
      ,[EquipOnlineStatusCode]
  FROM [Reports].[EquipmentDailyStatusHistoryByHour]
GO

SELECT EDSBH.[EquipOnlineStatusCode],EOLSC.[EquipOnLineStatusDesc], FORMAT(count(*)/7363200.00,'P')
FROM [Reports].[EquipmentDailyStatusHistoryByHour] EDSBH
JOIN [DimTable].[EquipOnlineStatusCode] EOLSC
ON EDSBH.[EquipOnlineStatusCode] = EOLSC.[EquipOnlineStatusCode]
GROUP BY EDSBH.[EquipOnlineStatusCode],EOLSC.[EquipOnLineStatusDesc]
GO

*/

DROP INDEX IF EXISTS pkDateHourEquipId 
ON [Reports].[EquipmentDailyStatusHistoryByHour]
GO

CREATE UNIQUE CLUSTERED INDEX pkDateHourEquipId 
ON [Reports].[EquipmentDailyStatusHistoryByHour]([CalendarDate],[DayHour],[EquipmentId])
GO

/*************************************/
/* Load EquipmentStatusHistoryByHour */
/*************************************/

TRUNCATE TABLE [Reports].[EquipmentStatusHistoryByHour]
GO

INSERT INTO [Reports].[EquipmentStatusHistoryByHour]
SELECT [CalendarDate]
	,[EquipmentId]
	,[DayHour]
	,[EquipOnlineStatusCode]
--INTO [Reports].[EquipmentStatusHistoryByHour]
FROM [Reports].[EquipmentDailyStatusHistoryByHour]
ORDER BY [CalendarDate]
	,[EquipmentId]
	,[DayHour]
GO

/*******************************/
/* Load EquipmentStatusHistory */
/*******************************/


TRUNCATE TABLE [APPlant].[FactTable].[EquipmentStatusHistory]
GO

INSERT INTO [APPlant].[FactTable].[EquipmentStatusHistory]
SELECT DISTINCT E.EquipmentKey
	,C.CalendarKey
	--,C.[CalendarDate]
	--,E.[EquipmentId]
	,ESC.EquipOnlineStatusKey
	,CASE
		WHEN ESHBH.[EquipOnlineStatusCode] = '0001' THEN 'Y'
		ELSE 'N'
	END AS [EquipOnlineStatus]
FROM [Reports].[EquipmentStatusHistoryByHour] ESHBH
JOIN [DimTable].[Equipment] E
ON ESHBH.EquipmentId = E.EquipmentId
JOIN [DimTable].[Calendar] C
ON ESHBH.StatusDate = C.CalendarDate
JOIN [DimTable].[EquipOnlineStatusCode] ESC
ON ESHBH.EquipOnlineStatusCode = ESC.EquipOnlineStatusCode
ORDER BY C.CalendarKey
	--,C.[CalendarDate]
	--,E.[EquipmentId]
	,E.EquipmentKey
	,ESC.EquipOnlineStatusKey
	,CASE
		WHEN ESHBH.[EquipOnlineStatusCode] = '0001' THEN 'Y'
		ELSE 'N'
	END
GO

/******************************/
/* Load EquipOnlineStatusCode */
/******************************/

TRUNCATE TABLE [DimTable].[EquipOnlineStatusCode]
GO

INSERT INTO [DimTable].[EquipOnlineStatusCode]
VALUES
('0001','On line - normal operation'),
('0002','Off line - maintenance'),
('0003','Off line - fault');
GO

/***************************/
/* Load PlantEquipLocation */
/***************************/

DROP TABLE IF EXISTS [DimTable].[PlantEquipLocation]
GO

CREATE TABLE [DimTable].[PlantEquipLocation](
	[EquipmentKey] [int] NOT NULL,
	[PlantId]     [varchar](16) NOT NULL,
	[LocationId]  [varchar](16) NOT NULL,
	[EquipmentId] [varchar](16) NOT NULL,
	[UnitId]      [varchar](16) NOT NULL,
	[UnitName]    [varchar](136) NOT NULL
) ON [AP_PLANT_FG]
GO

TRUNCATE TABLE DimTable.PlantEquipLocation
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

/************************************/
/* Introducing the Boiler Equipment */
/************************************/

DECLARE @Hour TABLE (
	[Hour] SMALLINT
);

INSERT INTO @Hour VALUES
	(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),
	(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24);

DECLARE @Boiler TABLE (
	BoilerName VARCHAR(64)
);

INSERT INTO @Boiler VALUES('Boiler 1'),('Boiler 2'),('Boiler 3'),('Boiler 4');

TRUNCATE TABLE EquipStatistics.BoilerTemperatureHistory;

INSERT INTO EquipStatistics.BoilerTemperatureHistory
SELECT [LocationKey]
	,[PlantId]
	,[LocationId]
	,[LocationName]
	,B.BoilerName
	,C.CalendarDate
	,H.Hour
	,CONVERT(FLOAT,(UPPER(
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) * 10.30))) AS BoilerTemperature
FROM [DimTable].[Location]
CROSS APPLY
(SELECT BoilerName FROM @Boiler) B
CROSS JOIN [DimTable].[Calendar] C
CROSS JOIN  @Hour H
WHERE LocationName = 'Boiler Room'
GO

/*********************/
/* Enhanced Calendar */
/*********************/

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

USE [APPlant]
GO

DROP VIEW IF EXISTS [DimTable].[CalendarView]
GO

CREATE VIEW [DimTable].[CalendarView]
AS
SELECT [CalendarKey],
	[CalendarYear],
    [CalendarQuarter],
    CASE 
		WHEN [CalendarQuarter] = 1 THEN '1st Quarter' 
		WHEN [CalendarQuarter] = 2 THEN '2nd Quarter' 
		WHEN [CalendarQuarter] = 3 THEN '3rd Quarter' 
		WHEN [CalendarQuarter] = 4 THEN '4th Quarter' 
	END AS QuarterName,
    [CalendarMonth],
    CASE 
		WHEN [CalendarMonth] = 1 THEN 'Jan' 
		WHEN [CalendarMonth] = 2 THEN 'Feb' 
		WHEN [CalendarMonth] = 3 THEN 'Mar' 
		WHEN [CalendarMonth] = 4 THEN 'Apr' 
		WHEN [CalendarMonth] = 5 THEN 'May' 
		WHEN [CalendarMonth] = 6 THEN 'Jun' 
		WHEN [CalendarMonth] = 7 THEN 'Jul' 
		WHEN [CalendarMonth] = 8 THEN 'Aug' 
		WHEN [CalendarMonth] = 9 THEN 'Sep' 
		WHEN [CalendarMonth] = 10 THEN 'Oct' 
		WHEN [CalendarMonth] = 11 THEN 'Nov' 
		WHEN [CalendarMonth] = 12 THEN 'Dec' 
	END AS MonthAbbrev,
    CASE 
		WHEN [CalendarMonth] = 1 THEN 'January' 
		WHEN [CalendarMonth] = 2 THEN 'February' 
		WHEN [CalendarMonth] = 3 THEN 'March' 
		WHEN [CalendarMonth] = 4 THEN 'April' 
		WHEN [CalendarMonth] = 5 THEN 'May' 
		WHEN [CalendarMonth] = 6 THEN 'June' 
		WHEN [CalendarMonth] = 7 THEN 'July' 
		WHEN [CalendarMonth] = 8 THEN 'August' 
		WHEN [CalendarMonth] = 9 THEN 'September' 
		WHEN [CalendarMonth] = 10 THEN 'October' 
		WHEN [CalendarMonth] = 11 THEN 'November' 
		WHEN [CalendarMonth] = 12 THEN 'December' 
	END AS [MonthName],
    [CalendarDate]
FROM [DimTable].[Calendar];
GO

DROP INDEX IF EXISTS ieCalendarYear
ON DimTable.CalendarEnhanced
GO

CREATE NONCLUSTERED INDEX ieCalendarYear
ON DimTable.CalendarEnhanced (CalendarYear)
INCLUDE (CalendarKey,QuarterName,CalendarMonth,MonthName)
GO

TRUNCATE TABLE [DimTable].[CalendarEnhanced]
GO

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

/*****************************************/
/* EQUIPMENT ROLLING MONTHLY HOUR TOTALS */
/*****************************************/

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

SELECT * FROM Reports.EquipmentRollingMonthlyHourTotals
GO

/****************************/
/* EquipFailureManufacturer */
/****************************/

USE [APPlant]
GO

TRUNCATE TABLE [Reports].[EquipFailureManufacturer]
GO

DECLARE @EquipFailureManufacturer TABLE (
	Manufacturer VARCHAR(256) NOT NULL,
	Equipment VARCHAR(256) NOT NULL,
	NormalTemp DECIMAL(10,2) NOT NULL
	);

DECLARE @Plantlocation TABLE (
	Plant VARCHAR(256) NOT NULL,
	Location VARCHAR(256) NOT NULL
	);

INSERT INTO @PlantLocation VALUES
('Plant 1','Boiler Room'),
('Plant 1','Turbine Room'),
('Plant 1','Generator Room'),
('Plant 1','Transformer Room'),
('Plant 1','Valve Room'),

('Plant 2','Boiler Room'),
('Plant 2','Turbine Room'),
('Plant 2','Generator Room'),
('Plant 2','Transformer Room'),
('Plant 2','Valve Room'),

('Plant 3','Boiler Room'),
('Plant 3','Turbine Room'),
('Plant 3','Generator Room'),
('Plant 3','Transformer Room'),
('Plant 3','Valve Room'),

('Plant 4','Boiler Room'),
('Plant 4','Turbine Room'),
('Plant 4','Generator Room'),
('Plant 4','Transformer Room'),
('Plant 4','Valve Room');

INSERT INTO @EquipFailureManufacturer VALUES
	('Tony''s Motors','200V Motor',200.00),
	('Central Motors','200V Motor',200.00),
	('State Motors','200V Motor',200.00),
	('Top Motors','200V Motor',200.00),
	('Best Motors','200V Motor',200.00);

INSERT INTO [Reports].[EquipFailureManufacturer]
SELECT PL.Plant
	,PL.Location
	,EFM.Manufacturer
	,EFM.Equipment
	,CAL.CalendarDate
	,CONVERT(DECIMAL(10,2),UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	100)) AS TempAlert
	,CONVERT(DECIMAL(10,2),UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	2) * 2) AS OverUnderTemp
	,EFM.NormalTemp
--INTO Reports.EquipFailureManufacturer
FROM @EquipFailureManufacturer EFM
CROSS JOIN @PlantLocation PL
CROSS JOIN DimTable.Calendar CAL
ORDER BY EFM.Manufacturer
	,EFM.Equipment
	,CAL.CalendarDate
GO

UPDATE Reports.EquipFailureManufacturer
SET OverUnderTemp = 0
WHERE TempAlert = 0
GO

SELECT [Plant]
      ,[Location]
      ,[Manufacturer]
      ,[Equipment]
      ,[CalendarDate]
      ,[TempAlert]
      ,[OverUnderTemp]
      ,[NormalTemp]
	  ,[OverUnderTemp] + [NormalTemp] AS TempDelta
  FROM [APPlant].[Reports].[EquipFailureManufacturer]
GO


SET NOCOUNT OFF
GO

CREATE OR ALTER VIEW CheckTableRowCount
AS
SELECT t.name,P.rows
FROM sys.tables T
JOIN sys.partitions P
ON T.object_id = P.object_id
GO

/*************************/
/* Check Table Row Count */
/*************************/

SELECT DISTINCT * FROM CheckTableRowCount
GO

