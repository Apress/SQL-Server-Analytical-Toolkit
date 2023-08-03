USE [APPlant]
GO

CREATE SCHEMA DataCollection
GO

TRUNCATE TABLE DataCollection.EquipFailureManufacturer;
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

INSERT INTO DataCollection.EquipFailureManufacturer
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
FROM @EquipFailureManufacturer EFM
CROSS JOIN @PlantLocation PL
CROSS JOIN DimTable.Calendar CAL
ORDER BY EFM.Manufacturer
	,EFM.Equipment
	,CAL.CalendarDate
GO

UPDATE DataCollection.EquipFailureManufacturer
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
  FROM [APPlant].[DataCollection].[EquipFailureManufacturer]
GO

	
