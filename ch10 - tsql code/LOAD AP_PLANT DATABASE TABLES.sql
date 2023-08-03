USE [AP_PLANT] 
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

TRUNCATE TABLE [DIM].[CALENDAR]
GO

DECLARE @StartDate DATE;
DECLARE @StopDate DATE;
DECLARE @CurrentDate DATE;

SET @StartDate = '01/01/2002'
SET @StopDate = '12/31/2022'

SET @CurrentDate = @StartDate

WHILE (@CurrentDate <= @StopDate) 
BEGIN

INSERT INTO [DIM].[CALENDAR]
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

TRUNCATE TABLE [DIM].[PLANT]
GO

INSERT INTO [DIM].[PLANT]
VALUES
	('PP000001','North Plant','North Electrical Generation Plant'),
	('PP000002','South Plant','South Electrical Generation Plant'),
	('PP000003','East Plant','East Electrical Generation Plant'),
	('PP000004','West Plant','West Electrical Generation Plant');
GO

/*****************************/
/* LOAD EQUIPMENT_TYPE TABLE */
/*****************************/

TRUNCATE TABLE [DIM].[EQUIPMENT_TYPE]
GO

INSERT INTO [DIM].[EQUIPMENT_TYPE]
VALUES
	('01','GENERATOR'),
	('02','MOTOR'),
	('03','TURBINE'),
	('04','VALVE');

SELECT * FROM [DIM].[EQUIPMENT_TYPE]
GO

/***********************/
/* LOAD PLANT LOCATION */
/***********************/

-- each plant has 4 locations

TRUNCATE TABLE [DIM].[LOCATION]
GO

INSERT INTO [DIM].[LOCATION]
VALUES
	-- Plant 1
	('PP000001','LO000001','Boiler Room'),
	('PP000001','LO000002','Turbine Room'),
	('PP000001','LO000003','Generator Room'),
	('PP000001','LO000004','Furnace Room'),
	-- Plant 2
	('PP000002','LO000001','Boiler Room'),
	('PP000002','LO000002','Turbine Room'),
	('PP000002','LO000003','Generator Room'),
	('PP000002','LO000004','Furnace Room'),
	-- Plant 3
	('PP000003','LO000001','Boiler Room'),
	('PP000003','LO000002','Turbine Room'),
	('PP000003','LO000003','Generator Room'),
	('PP000003','LO000004','Furnace Room'),
	-- Plant 4
	('PP000004','LO000001','Boiler Room'),
	('PP000004','LO000002','Turbine Room'),
	('PP000004','LO000003','Generator Room'),
	('PP000004','LO000004','Furnace Room');
GO


/*************************/
/* LOAD GENERATOR TABLE  */
/*************************/

TRUNCATE TABLE [DIM].[GENERATOR]
GO

INSERT INTO [DIM].[GENERATOR]
VALUES
('PP000001','LO000003','P1L3GEN1','GEN00001','Electrical Generator',100.0,1000.00,2400.00,120.0),
('PP000002','LO000003','P2L3GEN2','GEN00002','Electrical Generator',100.0,1000.00,2400.00,120.0),
('PP000003','LO000003','P3L3GEN3','GEN00003','Electrical Generator',100.0,1000.00,2400.00,120.0),
('PP000004','LO000003','P4L3GEN4','GEN00004','Electrical Generator',100.0,1000.00,2400.00,120.0);
GO

SELECT * FROM [DIM].[GENERATOR]
GO

/********************/
/* LOAD MOTOR TABLE */
/********************/

-- Motors are in the furnace rooms as they
-- are required to spon cooling & ventilation fans
-- each plant has 5 Motors

TRUNCATE TABLE [DIM].[MOTOR]
GO

INSERT INTO [DIM].[MOTOR]
VALUES
('PP000001','LO000004','P1L4MOT1','MOT00001','North Ventilation Motor',480.0,700.00),
('PP000002','LO000004','P2L4MOT1','MOT00002','North Ventilation Motor',480.0,700.00),
('PP000003','LO000004','P3L4MOT1','MOT00003','North Ventilation Motor',480.0,700.00),
('PP000004','LO000004','P4L4MOT1','MOT00004','North Ventilation Motor',480.0,700.00),

('PP000001','LO000004','P1L4MOT2','MOT00005','West Ventilation Motor',480.0,700.00),
('PP000002','LO000004','P2L4MOT2','MOT00006','West Ventilation Motor',480.0,700.00),
('PP000003','LO000004','P3L4MOT2','MOT00007','West Ventilation Motor',480.0,700.00),
('PP000004','LO000004','P4L4MOT2','MOT00008','West Ventilation Motor',480.0,700.00),

('PP000001','LO000004','P1L4MOT3','MOT00009','South Ventilation Motor',480.0,700.00),
('PP000002','LO000004','P2L4MOT3','MOT00010','South Ventilation Motor',480.0,700.00),
('PP000003','LO000004','P3L4MOT3','MOT00011','South Ventilation Motor',480.0,700.00),
('PP000004','LO000004','P4L4MOT3','MOT00012','South Ventilation Motor',480.0,700.00),

('PP000001','LO000004','P1L4MOT4','MOT00013','East Ventilation Motor',480.0,700.00),
('PP000002','LO000004','P2L4MOT4','MOT00014','East Ventilation Motor',480.0,700.00),
('PP000003','LO000004','P3L4MOT4','MOT00015','East Ventilation Motor',480.0,700.00),
('PP000004','LO000004','P4L4MOT4','MOT00016','East Ventilation Motor',480.0,700.00);
GO

SELECT * FROM [DIM].[MOTOR]
GO

/**********************/
/* LOAD TURBINE TABLE */
/**********************/

-- each plant has one turbine and it is loaded in location L0000002

TRUNCATE TABLE [DIM].[TURBINE]
GO

INSERT INTO [DIM].[TURBINE]
VALUES
('PP000001','LO000002','P1L4TUR1','TUR00001','Plant 1 Turbine',480.0,120.00,700.00),
('PP000002','LO000002','P2L4TUR1','TUR00002','Plant 2 Turbine',480.0,120.00,700.00),
('PP000003','LO000002','P3L4TUR1','TUR00003','Plant 3 Turbine',480.0,120.00,700.00),
('PP000004','LO000002','P4L4TUR1','TUR00004','Plant 4 Turbine',480.0,120.00,700.00);
GO

SELECT * FROM [DIM].[TURBINE]
GO


/********************/
/* LOAD VALVE TABLE */
/********************/

-- each plant has 4 valves and ithey are in location L0000001,
-- the boiler room

TRUNCATE TABLE [DIM].[VALVE]
GO

INSERT INTO [DIM].[VALVE]
VALUES
('PP000001','LO000001','P1L1VLV1','VLV00001','North Side Boiler Room',500,250),
('PP000002','LO000001','P2L1VLV1','VLV00002','North Side Boiler Room',500,250),
('PP000003','LO000001','P3L1VLV1','VLV00003','North Side Boiler Room',500,250),
('PP000004','LO000001','P4L1VLV1','VLV00004','North Side Boiler Room',500,250),

('PP000001','LO000001','P1L1VLV2','VLV00005','West Side Boiler Room',500,250),
('PP000002','LO000001','P2L1VLV2','VLV00006','West Side Boiler Room',500,250),
('PP000003','LO000001','P3L1VLV2','VLV00007','West Side Boiler Room',500,250),
('PP000004','LO000001','P4L1VLV2','VLV00008','West Side Boiler Room',500,250),

('PP000001','LO000001','P1L1VLV3','VLV00009','South Side Boiler Room',500,250),
('PP000002','LO000001','P2L1VLV3','VLV00010','South Side Boiler Room',500,250),
('PP000003','LO000001','P3L1VLV3','VLV00011','South Side Boiler Room',500,250),
('PP000004','LO000001','P4L1VLV3','VLV00012','South Side Boiler Room',500,250),

('PP000001','LO000001','P1L1VLV4','VLV00013','East Side Boiler Room',500,250),
('PP000002','LO000001','P2L1VLV4','VLV00014','East Side Boiler Room',500,250),
('PP000003','LO000001','P3L1VLV4','VLV00015','East Side Boiler Room',500,250),
('PP000004','LO000001','P4L1VLV4','VLV00016','East Side Boiler Room',500,250);
GO

/****************/
/* MANUFACTURER */
/****************/

TRUNCATE TABLE [DIM].[MANUFACTURER]
GO

INSERT INTO [DIM].[MANUFACTURER]
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
	('MANU012','CUSTOM HEAVY GENERATORS');
GO

/**************************/
/* EQUIPMENT_MANUFACTURER */
/**************************/

TRUNCATE TABLE [DIM].[EQUIPMENT_MANUFACTURER]
GO

INSERT INTO [DIM].[EQUIPMENT_MANUFACTURER]
SELECT  [EQUIPMENT_ID]
	  ,CASE
		WHEN [EQUIPMENT_KEY] BETWEEN 1 AND 9
			THEN 'S0000' + CONVERT(VARCHAR,[EQUIPMENT_KEY])
		ELSE 'S000' + CONVERT(VARCHAR,[EQUIPMENT_KEY])	
	  END AS SERIAL_NO
	  ,SUBSTRING([EQUIPMENT_ID],5,3) AS EQUIP_ABBREV
      ,[EQUIPMENT_TYPE]
	  ,CASE	
	    -- GENERATORS
		WHEN EQUIPMENT_TYPE = '01' AND RIGHT([EQUIPMENT_ID],1) = '1' THEN 'MANU004'
		WHEN EQUIPMENT_TYPE = '01' AND RIGHT([EQUIPMENT_ID],1) = '2' THEN 'MANU008'
		WHEN EQUIPMENT_TYPE = '01' AND RIGHT([EQUIPMENT_ID],1) = '3' THEN 'MANU012'
		WHEN EQUIPMENT_TYPE = '01' AND RIGHT([EQUIPMENT_ID],1) = '4' THEN 'MANU012'

		-- MOTORS
		WHEN EQUIPMENT_TYPE = '02' AND RIGHT([EQUIPMENT_ID],1) = '1' THEN 'MANU003'
		WHEN EQUIPMENT_TYPE = '02' AND RIGHT([EQUIPMENT_ID],1) = '2' THEN 'MANU007'
		WHEN EQUIPMENT_TYPE = '02' AND RIGHT([EQUIPMENT_ID],1) = '3' THEN 'MANU017'
		WHEN EQUIPMENT_TYPE = '02' AND RIGHT([EQUIPMENT_ID],1) = '4' THEN 'MANU011'

		-- TURBINES
		WHEN EQUIPMENT_TYPE = '03' AND LEFT([EQUIPMENT_ID],2) = 'P1' THEN 'MANU002'
		WHEN EQUIPMENT_TYPE = '03' AND LEFT([EQUIPMENT_ID],2) = 'P2' THEN 'MANU006'
		WHEN EQUIPMENT_TYPE = '03' AND LEFT([EQUIPMENT_ID],2) = 'P3' THEN 'MANU010'
		WHEN EQUIPMENT_TYPE = '03' AND LEFT([EQUIPMENT_ID],2) = 'P4' THEN 'MANU010'

		-- VALVE
		WHEN EQUIPMENT_TYPE = '04' AND LEFT([EQUIPMENT_ID],2) = 'P1' THEN 'MANU001'
		WHEN EQUIPMENT_TYPE = '04' AND LEFT([EQUIPMENT_ID],2) = 'P2' THEN 'MANU005'
		WHEN EQUIPMENT_TYPE = '04' AND LEFT([EQUIPMENT_ID],2) = 'P3' THEN 'MANU009'
		WHEN EQUIPMENT_TYPE = '04' AND LEFT([EQUIPMENT_ID],2) = 'P4' THEN 'MANU005'

		ELSE '?????'
	  END AS [MANUFACTURER_ID]
  FROM [AP_PLANT].[DIM].[EQUIPMENT]
  ORDER BY SUBSTRING([EQUIPMENT_ID],5,3)
  GO

/*************/
/* EQUIPMENT */
/*************/

TRUNCATE TABLE [DIM].[EQUIPMENT]
GO

/*
INSERT INTO [DIM].[EQUIPMENT] 
SELECT 
      [PLANT_ID]
      ,[LOCATION_ID]
      ,[EQUIPMENT_ID]
	  ,'04' -- VALVE
FROM [DIM].[VALVE]
UNION
SELECT 
      [PLANT_ID]
      ,[LOCATION_ID]
      ,[EQUIPMENT_ID]
	  ,'02' -- MOTOR
FROM [DIM].[MOTOR]
UNION
SELECT 
      [PLANT_ID]
      ,[LOCATION_ID]
      ,[EQUIPMENT_ID]
	  ,'03' -- TURBINE
FROM [DIM].[TURBINE]
UNION
SELECT 
      [PLANT_ID]
      ,[LOCATION_ID]
      ,[EQUIPMENT_ID]
	  ,'01' -- GENERATOR
FROM [DIM].[GENERATOR]
GO
*/


INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L1VLV1','S00001','VLV','04','MANU001');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L1VLV2','S00002','VLV','04','MANU001');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L1VLV3','S00003','VLV','04','MANU001');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L1VLV4','S00004','VLV','04','MANU001');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L4TUR1','S00005','TUR','03','MANU002');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L3GEN1','S00006','GEN','01','MANU004');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L4MOT1','S00007','MOT','02','MANU003');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L4MOT2','S00008','MOT','02','MANU007');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L4MOT3','S00009','MOT','02','MANU017');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P1L4MOT4','S00010','MOT','02','MANU011');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L1VLV1','S00011','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L1VLV2','S00012','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L1VLV3','S00013','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L1VLV4','S00014','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L4TUR1','S00015','TUR','03','MANU006');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L3GEN2','S00016','GEN','01','MANU008');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L4MOT1','S00017','MOT','02','MANU003');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L4MOT2','S00018','MOT','02','MANU007');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L4MOT3','S00019','MOT','02','MANU017');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P2L4MOT4','S00020','MOT','02','MANU011');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L1VLV1','S00021','VLV','04','MANU009');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L1VLV2','S00022','VLV','04','MANU009');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L1VLV3','S00023','VLV','04','MANU009');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L1VLV4','S00024','VLV','04','MANU009');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L4TUR1','S00025','TUR','03','MANU010');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L3GEN3','S00026','GEN','01','MANU012');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L4MOT1','S00027','MOT','02','MANU003');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L4MOT2','S00028','MOT','02','MANU007');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L4MOT3','S00029','MOT','02','MANU017');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P3L4MOT4','S00030','MOT','02','MANU011');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L1VLV1','S00031','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L1VLV2','S00032','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L1VLV3','S00033','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L1VLV4','S00034','VLV','04','MANU005');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L4TUR1','S00035','TUR','03','MANU010');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L3GEN4','S00036','GEN','01','MANU012');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L4MOT1','S00037','MOT','02','MANU003');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L4MOT2','S00038','MOT','02','MANU007');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L4MOT3','S00039','MOT','02','MANU017');
INSERT INTO [DIM].[EQUIPMENT] VALUES (0,'P4L4MOT4','S00040','MOT','02','MANU011');
GO

/**********************/
/* ALIGN PRIMARY KEYS */
/**********************/

UPDATE [DIM].[EQUIPMENT]
SET EQUIPMENT_KEY = G.[GENERATOR_KEY]
FROM [DIM].[GENERATOR] G
JOIN [DIM].[EQUIPMENT] E
ON G.EQUIPMENT_ID = E.EQUIPMENT_ID
GO

SELECT * 
FROM [DIM].[GENERATOR]
ORDER BY 1
GO

UPDATE [DIM].[EQUIPMENT]
SET EQUIPMENT_KEY = M.[MOTOR_KEY]
FROM [DIM].[MOTOR] M
JOIN [DIM].[EQUIPMENT] E
ON M.EQUIPMENT_ID = E.EQUIPMENT_ID
GO

SELECT * 
FROM [DIM].[MOTOR]
ORDER BY 1
GO

UPDATE [DIM].[EQUIPMENT]
SET EQUIPMENT_KEY = [TURBINE_KEY]
FROM [DIM].[TURBINE] T
JOIN [DIM].[EQUIPMENT] E
ON T.EQUIPMENT_ID = E.EQUIPMENT_ID
GO

SELECT * 
FROM [DIM].[GENERATOR]
ORDER BY 1
GO

UPDATE [DIM].[EQUIPMENT]
SET EQUIPMENT_KEY = V.[VALVE_KEY] 
--SELECT *,V.EQUIPMENT_ID,E.EQUIPMENT_ID
FROM [DIM].[VALVE] V
JOIN [DIM].[EQUIPMENT] E
ON V.EQUIPMENT_ID = E.EQUIPMENT_ID
GO

SELECT * 
FROM [DIM].[VALVE]
GO


/*******************/
/* LOAD FACT TABLE */
/*******************/

USE [AP_PLANT]
GO

--DROP TABLE IF EXISTS [FACT].[EQUIPMENT_FAILURE]
--GO

TRUNCATE TABLE [FACT].[EQUIPMENT_FAILURE]
GO

INSERT INTO [FACT].[EQUIPMENT_FAILURE]
SELECT C.CALENDAR_KEY,
	L.[LOCATION_KEY],
	G.[GENERATOR_KEY] AS EQUIPMENT_KEY,
	1 AS [EQUIPMENT_TYPE_KEY],
	0 AS FAILURE
FROM [DIM].[GENERATOR] G
JOIN [DIM].[LOCATION] L
	ON G.LOCATION_ID = L.LOCATION_ID
CROSS JOIN [DIM].[CALENDAR] C
UNION ALL
SELECT C.CALENDAR_KEY,
	L.[LOCATION_KEY],
	M.[MOTOR_KEY] AS EQUIPMENT_KEY,
	2 AS [EQUIPMENT_TYPE_KEY],
	0 AS FAILURE
FROM [DIM].[MOTOR] M
JOIN [DIM].[LOCATION] L
	ON M.LOCATION_ID = L.LOCATION_ID
CROSS JOIN [DIM].[CALENDAR] C
UNION ALL
SELECT C.CALENDAR_KEY,
	L.[LOCATION_KEY],
	T.[TURBINE_KEY]             AS EQUIPMENT_KEY,
	3 AS [EQUIPMENT_TYPE_KEY],
	0 AS FAILURE
FROM [DIM].[TURBINE] T
JOIN [DIM].[LOCATION] L
	ON T.LOCATION_ID = L.LOCATION_ID
CROSS JOIN [DIM].[CALENDAR] C
UNION ALL
SELECT C.CALENDAR_KEY,
	L.[LOCATION_KEY],
	V.[VALVE_KEY]             AS EQUIPMENT_KEY,
	4 AS [EQUIPMENT_TYPE_KEY],
	0 AS FAILURE
FROM [DIM].[VALVE] V
JOIN [DIM].[LOCATION] L
	ON V.LOCATION_ID = L.LOCATION_ID
CROSS JOIN [DIM].[CALENDAR] C
GO

/**************************************/
/* PROCEDURE TO GENERATE RANDOM VALUE */
/**************************************/

CREATE OR ALTER PROCEDURE [FACT].[usp_RandomFloat]
@RANDOM_VALUE FLOAT OUTPUT, @START_RANGE FLOAT, @STOP_RANGE FLOAT
AS
SET @RANDOM_VALUE = CONVERT (FLOAT, ROUND(UPPER(RAND() * @STOP_RANGE + @START_RANGE), 2));
GO

/*****************************************/
/* PROCEDURE TO GENERATE RANDOM FAILURES */
/*****************************************/

/*****************************************/
/* NOTE - NEED TO GENERATE LESS FAILURES */
/*****************************************/

UPDATE [FACT].[EQUIPMENT_FAILURE] 
SET [FAILURE] = 0
GO

DECLARE @FAILURE INT;

DECLARE @RANDOM_VALUE FLOAT;
DECLARE @START_RANGE FLOAT;
DECLARE @STOP_RANGE FLOAT;

SET @RANDOM_VALUE = 0.0;
SET @START_RANGE = 0.0;
SET @STOP_RANGE = 10.0;

DECLARE EQUIPMENT_FAILURE CURSOR
FOR
SELECT 
	[FAILURE]
FROM [FACT].[EQUIPMENT_FAILURE]
FOR UPDATE OF [FAILURE];

OPEN EQUIPMENT_FAILURE;

FETCH NEXT FROM EQUIPMENT_FAILURE 
INTO @FAILURE;

WHILE @@FETCH_STATUS = 0
BEGIN

-- generate random value betweem 0.00 and 10.00
-- to drive the failure value for the equipment

EXEC [FACT].[usp_RandomFloat] @RANDOM_VALUE OUT,@START_RANGE,@STOP_RANGE;

IF @RANDOM_VALUE < 7.0 
	SET @FAILURE = 0
ELSE IF @RANDOM_VALUE BETWEEN 7.0 AND 8.0
	SET @FAILURE = 1
ELSE IF @RANDOM_VALUE BETWEEN 8.1 AND 9.0
	SET @FAILURE = 2
ELSE SET @FAILURE = 3;

UPDATE [FACT].[EQUIPMENT_FAILURE] 
SET [FAILURE] = @FAILURE
WHERE CURRENT OF EQUIPMENT_FAILURE;

FETCH NEXT FROM EQUIPMENT_FAILURE 
INTO @FAILURE;
END

CLOSE EQUIPMENT_FAILURE;
DEALLOCATE EQUIPMENT_FAILURE;
GO

SET NOCOUNT OFF
GO

/************************/
/* MOTOR FAILURE REPORT */
/************************/

SELECT P.PLANT_ID
	  ,P.PLANT_NAME
	  ,C.CALENDAR_DATE
	  ,L.LOCATION_ID
	  ,L.LOCATION_NAME
      ,EF.[EQUIPMENT_KEY]
	  ,M.[MOTOR_ID]
	  ,ET.EQUIPMENT_TYPE
	  ,ET.EQUIPMENT_DESCRIPTION
	  ,M.[MOTOR_NAME]
      ,EF.[FAILURE]
FROM [FACT].[EQUIPMENT_FAILURE] EF
JOIN [DIM].[CALENDAR] C WITH (NOLOCK)
ON EF.CALENDAR_KEY = C.CALENDAR_KEY
JOIN [DIM].[LOCATION] L WITH (NOLOCK)
ON EF.LOCATION_KEY = L.LOCATION_KEY
JOIN [DIM].[PLANT] P WITH (NOLOCK)
ON L.PLANT_ID = P.PLANT_ID
JOIN [DIM].[MOTOR] M  WITH (NOLOCK)
ON EF.EQUIPMENT_KEY = M.MOTOR_KEY
JOIN [DIM].[EQUIPMENT_TYPE] ET
ON EF.EQUIPMENT_TYPE_KEY = ET.EQUIPMENT_TYPE_KEY
WHERE EF.[FAILURE] > 0
AND [EQUIPMENT_TYPE] = '02'
GO

CREATE UNIQUE CLUSTERED INDEX pkEquipmentFailure 
ON [FACT].[EQUIPMENT_FAILURE] (
	[CALENDAR_KEY],[LOCATION_KEY],[EQUIPMENT_KEY],[EQUIPMENT_TYPE_KEY]
	)
GO

CREATE UNIQUE CLUSTERED INDEX pkCalendarDate
ON [DIM].[CALENDAR] (
	[CALENDAR_KEY]
	)
GO

/************************/
/* VALVE FAILURE REPORT */
/************************/

SELECT P.PLANT_ID
--SELECT DISTINCT P.PLANT_ID
	  ,P.PLANT_NAME
	  ,C.CALENDAR_DATE
	  ,L.LOCATION_ID
	  ,V.LOCATION_ID AS V_LOCATION_ID
	  ,L.LOCATION_NAME
 --     ,EF.[LOCATION_KEY]
--      ,EF.[EQUIPMENT_KEY]
  	  ,ET.EQUIPMENT_TYPE
	  ,ET.EQUIPMENT_DESCRIPTION
	  ,V.VALVE_ID
	  ,V.VALVE_NAME
	  ,V.STEAM_TEMP	  
      ,EF.[EQUIPMENT_TYPE_KEY]
      ,EF.[FAILURE]
FROM [FACT].[EQUIPMENT_FAILURE] EF
JOIN [DIM].[CALENDAR] C WITH (NOLOCK)
ON EF.CALENDAR_KEY = C.CALENDAR_KEY
JOIN [DIM].[LOCATION] L WITH (NOLOCK)
ON EF.LOCATION_KEY = L.LOCATION_KEY
JOIN [DIM].[PLANT] P WITH (NOLOCK)
ON L.PLANT_ID = P.PLANT_ID
JOIN [DIM].[VALVE] V  WITH (NOLOCK)
ON EF.EQUIPMENT_KEY = VALVE_KEY
JOIN [DIM].[EQUIPMENT_TYPE] ET
ON EF.EQUIPMENT_TYPE_KEY = ET.EQUIPMENT_TYPE_KEY
WHERE EF.[FAILURE] > 0
AND [EQUIPMENT_TYPE] = '04'
GO

/**************************/
/* TURBINE FAILURE REPORT */
/**************************/

SELECT P.PLANT_ID
--SELECT DISTINCT P.PLANT_ID
	  ,P.PLANT_NAME
	  ,C.CALENDAR_DATE
	  ,L.LOCATION_ID
	  ,T.LOCATION_ID AS T_LOCATION_ID
	  ,L.LOCATION_NAME
 --     ,EF.[LOCATION_KEY]
 --     ,EF.[EQUIPMENT_KEY]
  	  ,ET.EQUIPMENT_TYPE
	  ,ET.EQUIPMENT_DESCRIPTION
	  ,T.TURBINE_ID
	  ,T.TURBINE_NAME
	  ,T.VOLTAGE
	  ,T.AMPS
	  ,T.RPM
 --     ,EF.[EQUIPMENT_TYPE_KEY]
      ,EF.[FAILURE]
FROM [FACT].[EQUIPMENT_FAILURE] EF
JOIN [DIM].[CALENDAR] C WITH (NOLOCK)
ON EF.CALENDAR_KEY = C.CALENDAR_KEY
JOIN [DIM].[LOCATION] L WITH (NOLOCK)
ON EF.LOCATION_KEY = L.LOCATION_KEY
JOIN [DIM].[PLANT] P WITH (NOLOCK)
ON L.PLANT_ID = P.PLANT_ID
JOIN [DIM].[TURBINE] T  WITH (NOLOCK)
ON EF.EQUIPMENT_KEY = T.TURBINE_KEY
JOIN [DIM].[EQUIPMENT_TYPE] ET
ON EF.EQUIPMENT_TYPE_KEY = ET.EQUIPMENT_TYPE_KEY
WHERE EF.[FAILURE] > 0
AND [EQUIPMENT_TYPE] = '03'
GO

/****************************/
/* GENERATOR FAILURE REPORT */
/****************************/

--SELECT P.PLANT_ID
SELECT DISTINCT P.PLANT_ID
	  ,P.PLANT_NAME
	  ,C.CALENDAR_DATE
	  ,L.LOCATION_ID
	  ,G.LOCATION_ID AS G_LOCATION_ID
	  ,L.LOCATION_NAME
 --     ,EF.[LOCATION_KEY]
 --     ,EF.[EQUIPMENT_KEY]
	  ,ET.EQUIPMENT_TYPE
	  ,ET.EQUIPMENT_DESCRIPTION
	  ,G.GENERATOR_ID
	  ,G.GENERATOR_NAME
	  ,G.KVA
 --     ,EF.[EQUIPMENT_TYPE_KEY]
      ,EF.[FAILURE]
FROM [FACT].[EQUIPMENT_FAILURE] EF
JOIN [DIM].[CALENDAR] C WITH (NOLOCK)
ON EF.CALENDAR_KEY = C.CALENDAR_KEY
JOIN [DIM].[LOCATION] L WITH (NOLOCK)
ON EF.LOCATION_KEY = L.LOCATION_KEY
JOIN [DIM].[PLANT] P WITH (NOLOCK)
ON L.PLANT_ID = P.PLANT_ID
JOIN [DIM].[GENERATOR] G  WITH (NOLOCK)
ON EF.EQUIPMENT_KEY = G.GENERATOR_KEY
JOIN [DIM].[EQUIPMENT_TYPE] ET
ON EF.EQUIPMENT_TYPE_KEY = ET.EQUIPMENT_TYPE_KEY
WHERE EF.[FAILURE] > 0
AND [EQUIPMENT_TYPE] = '01'
GO

-- check for failures per month

SELECT DISTINCT P.PLANT_ID
	  ,P.PLANT_NAME
	  ,[CALENDAR_YEAR]
	  ,[CALENDAR_MONTH]
	  ,L.LOCATION_ID
	  ,G.LOCATION_ID AS G_LOCATION_ID
	  ,L.LOCATION_NAME
	  ,ET.EQUIPMENT_TYPE
	  ,ET.EQUIPMENT_DESCRIPTION
	  ,G.GENERATOR_ID
	  ,G.GENERATOR_NAME
      ,SUM(EF.[FAILURE]) AS FAIL_PER_MONTH
FROM [FACT].[EQUIPMENT_FAILURE] EF
JOIN [DIM].[CALENDAR] C WITH (NOLOCK)
ON EF.CALENDAR_KEY = C.CALENDAR_KEY
JOIN [DIM].[LOCATION] L WITH (NOLOCK)
ON EF.LOCATION_KEY = L.LOCATION_KEY
JOIN [DIM].[PLANT] P WITH (NOLOCK)
ON L.PLANT_ID = P.PLANT_ID
JOIN [DIM].[GENERATOR] G  WITH (NOLOCK)
ON EF.EQUIPMENT_KEY = G.GENERATOR_KEY
JOIN [DIM].[EQUIPMENT_TYPE] ET
ON EF.EQUIPMENT_TYPE_KEY = ET.EQUIPMENT_TYPE_KEY
WHERE EF.[FAILURE] > 0
AND [EQUIPMENT_TYPE] = '01'
GROUP BY  P.PLANT_ID
	  ,P.PLANT_NAME
	  ,[CALENDAR_YEAR]
	  ,[CALENDAR_MONTH]
	  ,L.LOCATION_ID
	  ,G.LOCATION_ID 
	  ,L.LOCATION_NAME
	  ,ET.EQUIPMENT_TYPE
	  ,ET.EQUIPMENT_DESCRIPTION
	  ,G.GENERATOR_ID
	  ,G.GENERATOR_NAME
ORDER BY  P.PLANT_ID
	  ,P.PLANT_NAME
	  ,[CALENDAR_YEAR]
	  ,[CALENDAR_MONTH]
	  ,L.LOCATION_ID
	  ,G.LOCATION_ID 
	  ,L.LOCATION_NAME
	  ,ET.EQUIPMENT_TYPE
	  ,ET.EQUIPMENT_DESCRIPTION
	  ,G.GENERATOR_ID
	  ,G.GENERATOR_NAME
GO

 
















