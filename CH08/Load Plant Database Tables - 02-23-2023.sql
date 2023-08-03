USE [APPlant]
GO

/************************/
/* CREATED: 8/01/2022   */
/* MODIFIED: 08/11/2022 */
/************************/

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


/*************************/
/* LOAD GENERATOR TABLE  */
/*************************/

TRUNCATE TABLE [DimTable].[Generator]
GO

INSERT INTO [DimTable].[Generator]
VALUES
('PP000001','P1L00003','P1L3GEN1','GEN00001','Electrical Generator',100.0,1000.00,2400.00,120.0),
('PP000002','P2L00003','P2L3GEN2','GEN00002','Electrical Generator',100.0,1000.00,2400.00,120.0),
('PP000003','P3L00003','P3L3GEN3','GEN00003','Electrical Generator',100.0,1000.00,2400.00,120.0),
('PP000004','P4L00003','P4L3GEN4','GEN00004','Electrical Generator',100.0,1000.00,2400.00,120.0);
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
('PP000001','P1L00004','P1L4MOT1','MOT00001','North Ventilation Motor',480.0,700.00),
('PP000002','P2L00004','P2L4MOT1','MOT00002','North Ventilation Motor',480.0,700.00),
('PP000003','P3L00004','P3L4MOT1','MOT00003','North Ventilation Motor',480.0,700.00),
('PP000004','P4L00004','P4L4MOT1','MOT00004','North Ventilation Motor',480.0,700.00),

('PP000001','P1L00004','P1L4MOT2','MOT00005','West Ventilation Motor',480.0,700.00),
('PP000002','P2L00004','P2L4MOT2','MOT00006','West Ventilation Motor',480.0,700.00),
('PP000003','P3L00004','P3L4MOT2','MOT00007','West Ventilation Motor',480.0,700.00),
('PP000004','P4L00004','P4L4MOT2','MOT00008','West Ventilation Motor',480.0,700.00),

('PP000001','P1L00004','P1L4MOT3','MOT00009','South Ventilation Motor',480.0,700.00),
('PP000002','P2L00004','P2L4MOT3','MOT00010','South Ventilation Motor',480.0,700.00),
('PP000003','P3L00004','P3L4MOT3','MOT00011','South Ventilation Motor',480.0,700.00),
('PP000004','P4L00004','P4L4MOT3','MOT00012','South Ventilation Motor',480.0,700.00),

('PP000001','P1L00004','P1L4MOT4','MOT00013','East Ventilation Motor',480.0,700.00),
('PP000002','P2L00004','P2L4MOT4','MOT00014','East Ventilation Motor',480.0,700.00),
('PP000003','P3L00004','P3L4MOT4','MOT00015','East Ventilation Motor',480.0,700.00),
('PP000004','P4L00004','P4L4MOT4','MOT00016','East Ventilation Motor',480.0,700.00);
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
('PP000001','P1L00002','P1L4TUR1','TUR00001','Plant 1 Turbine',480.0,120.00,700.00),
('PP000002','P2L00002','P2L4TUR1','TUR00002','Plant 2 Turbine',480.0,120.00,700.00),
('PP000003','P3L00002','P3L4TUR1','TUR00003','Plant 3 Turbine',480.0,120.00,700.00),
('PP000004','P4L00002','P4L4TUR1','TUR00004','Plant 4 Turbine',480.0,120.00,700.00);
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
('PP000001','P1L00001','P1L1VLV1','VLV00001','North Side Boiler Room',500,250),
('PP000002','P2L00001','P2L1VLV1','VLV00002','North Side Boiler Room',500,250),
('PP000003','P3L00001','P3L1VLV1','VLV00003','North Side Boiler Room',500,250),
('PP000004','P4L00001','P4L1VLV1','VLV00004','North Side Boiler Room',500,250),

('PP000001','P1L00001','P1L1VLV2','VLV00005','West Side Boiler Room',500,250),
('PP000002','P2L00001','P2L1VLV2','VLV00006','West Side Boiler Room',500,250),
('PP000003','P3L00001','P3L1VLV2','VLV00007','West Side Boiler Room',500,250),
('PP000004','P4L00001','P4L1VLV2','VLV00008','West Side Boiler Room',500,250),

('PP000001','P1L00001','P1L1VLV3','VLV00009','South Side Boiler Room',500,250),
('PP000002','P2L00001','P2L1VLV3','VLV00010','South Side Boiler Room',500,250),
('PP000003','P3L00001','P3L1VLV3','VLV00011','South Side Boiler Room',500,250),
('PP000004','P4L00001','P4L1VLV3','VLV00012','South Side Boiler Room',500,250),

('PP000001','P1L00001','P1L1VLV4','VLV00013','East Side Boiler Room',500,250),
('PP000002','P2L00001','P2L1VLV4','VLV00014','East Side Boiler Room',500,250),
('PP000003','P3L00001','P3L1VLV4','VLV00015','East Side Boiler Room',500,250),
('PP000004','P4L00001','P4L1VLV4','VLV00016','East Side Boiler Room',500,250);
GO

SELECT *
FROM [DimTable].[Valve]
ORDER BY [PlantId],[LocationId],[EquipmentId],[ValveId]
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
	[EquipmentId]      [varchar](8) NOT NULL,
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













