USE [APInventory]
GO

/***********************/
/* LOAD CALENDAR TABLE */
/***********************/

TRUNCATE TABLE [MasterData].[Calendar]
GO

DECLARE @StartDate DATE;
DECLARE @StopDate DATE;
DECLARE @CurrentDate DATE;

SET @StartDate = '01/01/2002'
SET @StopDate = '12/31/2022'

SET @CurrentDate = @StartDate

WHILE (@CurrentDate <= @StopDate)
BEGIN

INSERT INTO [MasterData].[Calendar]
VALUES (
CONVERT(INT,
(
CONVERT(VARCHAR,YEAR(@CurrentDate)) +
CONVERT(VARCHAR,DATEPART(qq,@CurrentDate)) +
CONVERT(VARCHAR,MONTH(@CurrentDate)) +
CONVERT(VARCHAR,DAY(@CurrentDate))
)
),
YEAR(@CurrentDate),
DATEPART(qq,@CurrentDate),
MONTH(@CurrentDate),
@CurrentDate
);

SET @CurrentDate = DATEADD(dd,1,@CurrentDate);
END
GO

/********************/
/* LOAD DIM.COUNTRY */
/********************/

TRUNCATE TABLE [MasterData].[Country]
GO

INSERT INTO [MasterData].[Country] VALUES
('Afghanistan','AF','AFG'),
('Aland Islands','AX','ALA'),
('Albania','AL','ALB'),
('Algeria','DZ','DZA'),
('American Samoa','AS','ASM'),
('Andorra','AD','AND'),
('Angola','AO','AGO'),
('Anguilla','AI','AIA'),
('Antarctica','AQ','ATA'),
('Antigua and Barbuda','AG','ATG'),
('Argentina','AR','ARG'),
('Armenia','AM','ARM'),
('Aruba','AW','ABW'),
('Australia','AU','AUS'),
('Austria','AT','AUT'),
('Azerbaijan','AZ','AZE'),
('Bahamas','BS','BHS'),
('Bahrain','BH','BHR'),
('Bangladesh','BD','BGD'),
('Barbados','BB','BRB'),
('Belarus','BY','BLR'),
('Belgium','BE','BEL'),
('Belize','BZ','BLZ'),
('Benin','BJ','BEN'),
('Bermuda','BM','BMU'),
('Bhutan','BT','BTN'),
('Bolivia','BO','BOL'),
('Bosnia and Herzegovina','BA','BIH'),
('Botswana','BW','BWA'),
('Bouvet Island','BV','BVT'),
('Brazil','BR','BRA'),
('British Indian Ocean Territory','IO','IOT'),
('British Virgin Islands','VG','VGB'),
('Brunei Darussalam','BN','BRN'),
('Bulgaria','BG','BGR'),
('Burkina Faso','BF','BFA'),
('Burundi','BI','BDI'),
('Cambodia','KH','KHM'),
('Cameroon','CM','CMR'),
('Canada','CA','CAN'),
('Cape Verde','CV','CPV'),
('Cayman Islands','KY','CYM'),
('Central African Republic','CF','CAF'),
('Chad','TD','TCD'),
('Chile','CL','CHL'),
('China','CN','CHN'),
('Christmas Island','CX','CXR'),
('Cocos (Keeling), Islands','CC','CCK'),
('Colombia','CO','COL'),
('Comoros','KM','COM'),
('Congo (Brazzaville),','CG','COG'),
('Congo, (Kinshasa),','CD','COD'),
('Cook Islands','CK','COK'),
('Costa Rica','CR','CRI'),
('Côte d''Ivoire','CI','CIV'),
('Croatia','HR','HRV'),
('Cuba','CU','CUB'),
('Cyprus','CY','CYP'),
('Czech Republic','CZ','CZE'),
('Denmark','DK','DNK'),
('Djibouti','DJ','DJI'),
('Dominica','DM','DMA'),
('Dominican Republic','DO','DOM'),
('Ecuador','EC','ECU'),
('Egypt','EG','EGY'),
('El Salvador','SV','SLV'),
('Equatorial Guinea','GQ','GNQ'),
('Eritrea','ER','ERI'),
('Estonia','EE','EST'),
('Ethiopia','ET','ETH'),
('Falkland Islands (Malvinas),','FK','FLK'),
('Faroe Islands','FO','FRO'),
('Fiji','FJ','FJI'),
('Finland','FI','FIN'),
('France','FR','FRA'),
('French Guiana','GF','GUF'),
('French Polynesia','PF','PYF'),
('French Southern Territories','TF','ATF'),
('Gabon','GA','GAB'),
('Gambia','GM','GMB'),
('Georgia','GE','GEO'),
('Germany','DE','DEU'),
('Ghana','GH','GHA'),
('Gibraltar','GI','GIB'),
('Greece','GR','GRC'),
('Greenland','GL','GRL'),
('Grenada','GD','GRD'),
('Guadeloupe','GP','GLP'),
('Guam','GU','GUM'),
('Guatemala','GT','GTM'),
('Guernsey','GG','GGY'),
('Guinea','GN','GIN'),
('Guinea-Bissau','GW','GNB'),
('Guyana','GY','GUY'),
('Haiti','HT','HTI'),
('Heard and Mcdonald Islands','HM','HMD'),
('Holy See (Vatican City State),','VA','VAT'),
('Honduras','HN','HND'),
('Hong Kong, SAR China','HK','HKG'),
('Hungary','HU','HUN'),
('Iceland','IS','ISL'),
('India','IN','IND'),
('Indonesia','ID','IDN'),
('Iran, Islamic Republic of','IR','IRN'),
('Iraq','IQ','IRQ'),
('Ireland','IE','IRL'),
('Isle of Man','IM','IMN'),
('Israel','IL','ISR'),
('Italy','IT','ITA'),
('Jamaica','JM','JAM'),
('Japan','JP','JPN'),
('Jersey','JE','JEY'),
('Jordan','JO','JOR'),
('Kazakhstan','KZ','KAZ'),
('Kenya','KE','KEN'),
('Kiribati','KI','KIR'),
('Korea (North),','KP','PRK'),
('Korea (South),','KR','KOR'),
('Kuwait','KW','KWT'),
('Kyrgyzstan','KG','KGZ'),
('Lao PDR','LA','LAO'),
('Latvia','LV','LVA'),
('Lebanon','LB','LBN'),
('Lesotho','LS','LSO'),
('Liberia','LR','LBR'),
('Libya','LY','LBY'),
('Liechtenstein','LI','LIE'),
('Lithuania','LT','LTU'),
('Luxembourg','LU','LUX'),
('Macao, SAR China','MO','MAC'),
('Macedonia, Republic of','MK','MKD'),
('Madagascar','MG','MDG'),
('Malawi','MW','MWI'),
('Malaysia','MY','MYS'),
('Maldives','MV','MDV'),
('Mali','ML','MLI'),
('Malta','MT','MLT'),
('Marshall Islands','MH','MHL'),
('Martinique','MQ','MTQ'),
('Mauritania','MR','MRT'),
('Mauritius','MU','MUS'),
('Mayotte','YT','MYT'),
('Mexico','MX','MEX'),
('Micronesia, Federated States of','FM','FSM'),
('Moldova','MD','MDA'),
('Monaco','MC','MCO'),
('Mongolia','MN','MNG'),
('Montenegro','ME','MNE'),
('Montserrat','MS','MSR'),
('Morocco','MA','MAR'),
('Mozambique','MZ','MOZ'),
('Myanmar','MM','MMR'),
('Namibia','NA','NAM'),
('Nauru','NR','NRU'),
('Nepal','NP','NPL'),
('Netherlands','NL','NLD'),
('Netherlands Antilles','AN','ANT'),
('New Caledonia','NC','NCL'),
('New Zealand','NZ','NZL'),
('Nicaragua','NI','NIC'),
('Niger','NE','NER'),
('Nigeria','NG','NGA'),
('Niue','NU','NIU'),
('Norfolk Island','NF','NFK'),
('Northern Mariana Islands','MP','MNP'),
('Norway','NO','NOR'),
('Oman','OM','OMN'),
('Pakistan','PK','PAK'),
('Palau','PW','PLW'),
('Palestinian Territory','PS','PSE'),
('Panama','PA','PAN'),
('Papua New Guinea','PG','PNG'),
('Paraguay','PY','PRY'),
('Peru','PE','PER'),
('Philippines','PH','PHL'),
('Pitcairn','PN','PCN'),
('Poland','PL','POL'),
('Portugal','PT','PRT'),
('Puerto Rico','PR','PRI'),
('Qatar','QA','QAT'),
('Réunion','RE','REU'),
('Romania','RO','ROU'),
('Russian Federation','RU','RUS'),
('Rwanda','RW','RWA'),
('Saint Helena','SH','SHN'),
('Saint Kitts and Nevis','KN','KNA'),
('Saint Lucia','LC','LCA'),
('Saint Pierre and Miquelon','PM','SPM'),
('Saint Vincent and Grenadines','VC','VCT'),
('Saint-Barthélemy','BL','BLM'),
('Saint-Martin (French part),','MF','MAF'),
('Samoa','WS','WSM'),
('San Marino','SM','SMR'),
('Sao Tome and Principe','ST','STP'),
('Saudi Arabia','SA','SAU'),
('Senegal','SN','SEN'),
('Serbia','RS','SRB'),
('Seychelles','SC','SYC'),
('Sierra Leone','SL','SLE'),
('Singapore','SG','SGP'),
('Slovakia','SK','SVK'),
('Slovenia','SI','SVN'),
('Solomon Islands','SB','SLB'),
('Somalia','SO','SOM'),
('South Africa','ZA','ZAF'),
('South Georgia and the South Sandwich Islands','GS','SGS'),
('South Sudan','SS','SSD'),
('Spain','ES','ESP'),
('Sri Lanka','LK','LKA'),
('Sudan','SD','SDN'),
('Suriname','SR','SUR'),
('Svalbard and Jan Mayen Islands','SJ','SJM'),
('Swaziland','SZ','SWZ'),
('Sweden','SE','SWE'),
('Switzerland','CH','CHE'),
('Syrian Arab Republic (Syria),','SY','SYR'),
('Taiwan, Republic of China','TW','TWN'),
('Tajikistan','TJ','TJK'),
('Tanzania, United Republic of','TZ','TZA'),
('Thailand','TH','THA'),
('Timor-Leste','TL','TLS'),
('Togo','TG','TGO'),
('Tokelau','TK','TKL'),
('Tonga','TO','TON'),
('Trinidad and Tobago','TT','TTO'),
('Tunisia','TN','TUN'),
('Turkey','TR','TUR'),
('Turkmenistan','TM','TKM'),
('Turks and Caicos Islands','TC','TCA'),
('Tuvalu','TV','TUV'),
('Uganda','UG','UGA'),
('Ukraine','UA','UKR'),
('United Arab Emirates','AE','ARE'),
('United Kingdom','GB','GBR'),
('United States','US','USA'),
('Uruguay','UY','URY'),
('US Minor Outlying Islands','UM','UMI'),
('Uzbekistan','UZ','UZB'),
('Vanuatu','VU','VUT'),
('Venezuela (Bolivarian Republic),','VE','VEN'),
('Viet Nam','VN','VNM'),
('Virgin Islands, US','VI','VIR'),
('Wallis and Futuna Islands','WF','WLF'),
('Western Sahara','EH','ESH'),
('Yemen','YE','YEM'),
('Zambia','ZM','ZMB'),
('Zimbabwe','ZW','ZWE');
GO

/**********************/ 
/* PRODUCT_TYPE TABLE */
/**********************/
 
TRUNCATE TABLE [MasterData].[ProductType]
GO

INSERT INTO [MasterData].[ProductType]
VALUES
('PT01','HO Electric Locomotive'),
('PT02','HO Steam Locomotive'),
('PT03','HO Diesel Locomotive'),
('PT04','HO Passenger Car'),
('PT05','HO Freight Car'),
('PT06','N Electric Locomotive'),
('PT07','N Steam Locomotive'),
('PT08','N Diesel Locomotive'),
('PT09','N Passenger Car'),
('PT10','N Freight Car');

SELECT *
FROM [MasterData].[ProductType]
GO

/***********/
/* PRODUCT */
/***********/

TRUNCATE TABLE [MasterData].[Product]
GO

 INSERT INTO [MasterData].[Product] VALUES('P033','French Type 1 Locomotive',175.00,131.25,'PT02');
 INSERT INTO [MasterData].[Product] VALUES('P037','Italian Type 1 Locomotive',170.00,127.50,'PT02');
 INSERT INTO [MasterData].[Product] VALUES('P041','German Type 1 Locomotive',180.00,135.00,'PT02');
 INSERT INTO [MasterData].[Product] VALUES('P045','Swiss Type 1 Locomotive',190.00,142.50,'PT02');
 INSERT INTO [MasterData].[Product] VALUES('P101','French Type 1 Locomotive',175.00,131.25,'PT06');
 INSERT INTO [MasterData].[Product] VALUES('P105','Italian Type 1 Locomotive',170.00,127.50,'PT06');
 INSERT INTO [MasterData].[Product] VALUES('P109','German Type 1 Locomotive',180.00,135.00,'PT06');
 INSERT INTO [MasterData].[Product] VALUES('P113','Swiss Type 1 Locomotive',190.00,142.50,'PT06');
 INSERT INTO [MasterData].[Product] VALUES('P201','French Type 1 Passenger Car',175.00,131.25,'PT04');
 INSERT INTO [MasterData].[Product] VALUES('P205','Italian Type 1 Passenger Car',170.00,127.50,'PT04');
 INSERT INTO [MasterData].[Product] VALUES('P209','German Type 1 Passenger Car',180.00,135.00,'PT04');
 INSERT INTO [MasterData].[Product] VALUES('P213','Swiss Type 1 Passenger Car',190.00,142.50,'PT04');
 GO



/*****************/
/* UPDATE PRICES */
/*****************/

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 175.00,
	[WholesalePrice] = 175.00 * .75
WHERE [ProdName] LIKE 'French%Locomotive%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 170.00,
	[WholesalePrice] = 170.00 * .75
WHERE [ProdName] LIKE 'Italian%Locomotive%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 180.00,
	[WholesalePrice] = 180.00 * .75
WHERE [ProdName] LIKE 'German%Locomotive%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 190.00,
	[WholesalePrice] = 190.00 * .75
WHERE [ProdName] LIKE 'Swiss%Locomotive%'
GO

/***********************************/
/* UPDATE PRICES ON PASSENGER CARS */
/***********************************/

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 175.00,
	[WholesalePrice] = 175.00 * .75
WHERE [ProdName] LIKE 'French%Passenger%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 170.00,
	[WholesalePrice] = 170.00 * .75
WHERE [ProdName] LIKE 'Italian%Passenger%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 180.00,
	[WholesalePrice] = 180.00 * .75
WHERE [ProdName] LIKE 'German%Passenger%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 190.00,
	[WholesalePrice] = 190.00 * .75
WHERE [ProdName] LIKE 'Swiss%Passenger%'
GO

/*********************************/
/* UPDATE PRICES ON FREIGHT CARS */
/*********************************/

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 175.00,
	[WholesalePrice] = 175.00 * .75
WHERE [ProdName] LIKE 'French%Freight%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 170.00,
	[WholesalePrice] = 170.00 * .75
WHERE [ProdName] LIKE 'Italian%Freight%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 180.00,
	[WholesalePrice] = 180.00 * .75
WHERE [ProdName] LIKE 'German%Freight%'
GO

UPDATE [MasterData].[Product]
SET 
	[RetailPrice] = 190.00,
	[WholesalePrice] = 190.00 * .75
WHERE [ProdName] LIKE 'Swiss%Freight%'
GO

SELECT * FROM [MasterData].[Product]
GO

/************/
/* LOCATION */
/************/


TRUNCATE TABLE [MasterData].[Location]
GO

INSERT INTO [MasterData].[Location]
VALUES
('LOC1','Eastern Inventory','United States','New York','Queens','123 New York Avenue','01234'),
('LOC2','Northern Inventory','United States','Maine','Bangor','456 Main Street','01235');

SELECT * 
FROM [MasterData].[Location]
GO

/*************/
/* WAREHOUSE */
/*************/

/*************************************************/
/* USE THIS SCRIPT TO INITIALIZE WAREHOUSE TABLE */
/* FOR THE FIRST TIME.                           */
/*************************************************/

TRUNCATE TABLE [Product].[Warehouse]
GO

/*
LOC_ID	INV_ID	WH_ID
LOC1	INV1	WH111
LOC1	INV1	WH112
LOC1	INV2	WH121
LOC1	INV2	WH122
LOC2	INV1	WH221
LOC2	INV1	WH222
LOC2	INV2	WH221
LOC2	INV2	WH222
*/

DECLARE @Warehouse TABLE (	
	[LocId] VARCHAR(4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[WhName] [varchar](64) NOT NULL
	);

INSERT INTO @Warehouse
VALUES
('LOC1','INV1','WH111','Euro Model Trains: Location 01 - Inventory 01 - Warehouse 01'),
('LOC1','INV1','WH112','Euro Model Trains: Location 01 - Inventory 01 - Warehouse 02'),
('LOC1','INV2','WH121','Euro Model Trains: Location 01 - Inventory 02 - Warehouse 01'),
('LOC1','INV2','WH122','Euro Model Trains: Location 01 - Inventory 02 - Warehouse 02'),
('LOC2','INV1','WH211','Euro Model Trains: Location 02 - Inventory 01 - Warehouse 01'),
('LOC2','INV1','WH212','Euro Model Trains: Location 02 - Inventory 01 - Warehouse 02'),
('LOC2','INV2','WH221','Euro Model Trains: Location 02 - Inventory 02 - Warehouse 01'),
('LOC2','INV2','WH222','Euro Model Trains: Location 02 - Inventory 02 - Warehouse 02');

INSERT INTO [Product].[Warehouse]
SELECT DISTINCT W.[LocId],
    W.[InvId],
	W.[WhId],
	W.[WhName]
	,P.[ProdId]
	,0				AS [InvOut]
	,50				AS [InvIn]
	,50				AS [QtyOnHand]
	,100 			AS [ReOrderLevel]
	,2001			AS [AsOfYear]
	,12			    AS [AsOfMonth]
	,'12-31-2001'	AS [AsOfDate]
	--,RIGHT(W.LocId,1),SUBSTRING(W.Whid,3,1) 
FROM [MasterData].[Location] L
CROSS JOIN @Warehouse W
CROSS JOIN [MasterData].[Product] P
-- get rid of invalid combinations
WHERE RIGHT(W.LocId,1) = SUBSTRING(W.Whid,3,1) 
ORDER BY 1,2,3,4,5
GO

/*************************************************************************/
/* RUN THIS ONCE WAREHOUSE TABLE HAS BEEN INITIALIZED FOR THE FIRST TIME */
/*************************************************************************/

/*************************/
/* INVENTORY TRANSACTION */
/*************************/

-- 1,472,640 rows loaded in 3 sec

/*
LOC_ID	INV_ID	WH_ID
LOC1	INV1	WH111
LOC1	INV1	WH112
LOC1	INV2	WH121
LOC1	INV2	WH122
LOC2	INV1	WH221
LOC2	INV1	WH222
LOC2	INV2	WH221
LOC2	INV2	WH222
*/

-- Each location has two inventories, each inventory has two warehouses

TRUNCATE TABLE [Product].[InventoryTransaction]
GO

INSERT INTO [Product].[InventoryTransaction]
SELECT 
      CONVERT(INT,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	50)) AS [Increment]
	 ,CONVERT(INT,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	50)) AS [DecrementT]
      ,Cal.CalendarDate AS [MovementDate]
	  ,Wh.[InvId]
      ,WH.[LocId]
      ,WH.[WhId]
      ,WH.[ProdId]
  FROM  [Product].[Warehouse] Wh
  CROSS JOIN [MasterData].[Calendar] Cal
  WHERE Cal.CalendarYear > 2001
  GO

  -- invalid combinations - 05/3/2023
DELETE FROM [ApInventory].[Product].[InventoryTransaction]
WHERE InvId = 'INV1'
AND LocId = 'LOC1'
AND WhId = 'WH211'
GO

/*************************/
/* INVENTORY SALE REPORT */
/*************************/

TRUNCATE TABLE Product.InventorySalesReport
GO

INSERT INTO Product.InventorySalesReport
SELECT 
      YEAR(IT.MovementDate) AS AsOfYear
	  ,MONTH(IT.MovementDate) AS AsOfMonth
	  ,IT.MovementDate AS AsOfDate
      ,IT.ProdId
	  ,P.RetailPrice
	  ,SUM(IT.Decrement) AS InvOutTotal
	  ,SUM(IT.Decrement) * P.RetailPrice AS SalesTotal
  FROM Product.InventoryTransaction IT
  JOIN MasterData.Product P
  ON IT.ProdId = P.ProdId
  GROUP BY IT.MovementDate
      ,IT.ProdId
	  ,P.RetailPrice
	  ,IT.Decrement
ORDER BY 
      YEAR(IT.MovementDate)
	  ,MONTH(IT.MovementDate)
	  ,IT.MovementDate
	  ,IT.ProdId
	  GO

DELETE FROM APInventory.Product.InventorySalesReport
WHERE InvOutTotal = 0
GO

/*************/
/* WAREHOUSE */
/*************/

/**************************************/
/* EACH LOCATION HAS TWO INVENTORIES */
/**************************************/

/**************************************/
/* Each location has two inventories. */
/* Each inventory has two warehouses. */
/**************************************/

/*
LOC_ID	INV_ID	WH_ID
LOC1	INV1	WH111
LOC1	INV1	WH112
LOC1	INV2	WH121
LOC1	INV2	WH122
LOC2	INV1	WH221
LOC2	INV1	WH222
LOC2	INV2	WH221
LOC2	INV2	WH222
*/

/**********************************************/
/* DO NOT TRUNCATE TABLE IF YOU WANT TO KEEP  */
/* INITIALIZATION DATA AND MULTI-YEAR HISTORY */
/**********************************************/

/****************************************************/
/* USE TABLE VARIABLE TO DEFINE WAREHOUSE ID & NAME */
/****************************************************/

/****************************************************************/
/* INSERT THE TRANSACTIONS FROM THE INVENTORY TRANSACTION TABLE */
/****************************************************************/

/***********************************************************************/
/* 5/12/2003 - quantities reflect current quantity + (in - out) levels */
/***********************************************************************/

-- this table is pre summarized

/*
DELETE FROM [Product].[Warehouse]
WHERE [AsOfYear] <> 2001
GO
*/

INSERT INTO [Product].[Warehouse]
SELECT I.[LocId],	
	I.[InvId],
	I.[WhId],
	WH.WhName,
	I.ProdId,
	SUM(I.Decrement) AS MonthlyDecr,
	SUM(I.[Increment]) AS MonthlyIncr,
	WH.[QtyOnHand] + (SUM(I.[Increment]) - SUM(I.[Decrement])) AS QtyOnHand,
	100	AS [ReOrderLevel],
    YEAR(I.[MovementDate]),
	MONTH(I.[MovementDate]),
	EOMONTH(CONVERT(VARCHAR,YEAR(I.[MovementDate])),(MONTH(I.[MovementDate]) - 1))
FROM [Product].[InventoryTransaction] I
JOIN (
SELECT DISTINCT [LocId]
      ,[InvId]
      ,[WhId]
      ,[WhName]
	  ,SUM([QtyOnHand]) AS QtyOnHand
	  ,[ProdId]
	  ,[AsOfYear]
	  ,[AsOfMonth]
  FROM [Product].[Warehouse]
  GROUP BY [LocId]
      ,[InvId]
      ,[WhId]
      ,[WhName]
	  ,[ProdId]
	  ,[AsOfYear]
	  ,[AsOfMonth]
) WH
ON (
	I.LocId = WH.LocId
AND I.InvId = WH.InvId
AND I.WhId = WH.WhId
AND I.ProdId = WH.ProdId
AND YEAR(I.MovementDate) = WH.AsOfYear
AND MONTH(I.MovementDate) = WH.AsOfMonth
)
GROUP BY	
	I.[InvId],
	I.[LocId],
	I.[WhId],
	I.ProdId,
	WH.WhName,
	WH.[QtyOnHand],
	YEAR(I.[MovementDate]),
	MONTH(I.[MovementDate])
ORDER BY	
	I.[InvId],
	I.[LocId],
	I.[WhId],
	I.ProdId,
	WH.WhName,
	WH.[QtyOnHand],
	YEAR(I.[MovementDate]),
	MONTH(I.[MovementDate]);
GO

-- delete invalid combinations

DELETE FROM [Product].[Warehouse]
WHERE LocId = 'LOC1' AND WhID LIKE 'WH2%'
GO

DELETE FROM [Product].[Warehouse]
WHERE LocId = 'LOC2' AND WhID LIKE 'WH1%'
GO

SELECT DISTINCT [LocId],[InvId],WhId,count(*)
FROM [Product].[Warehouse]
GROUP BY [LocId],[InvId],WhId
ORDER BY [LocId],[InvId],WhId
GO

-- May 30th, 2023
-- use this to load all months so CTE can sum things up

/*
DELETE FROM [Product].[Warehouse]
WHERE [AsOfYear] <> 2001
GO
*/

INSERT INTO [Product].[Warehouse]
SELECT I.[LocId],	
	I.[InvId],
	I.[WhId],
	W.WhName,
	I.ProdId,
	I.Decrement AS [InvOut],
	I.Increment AS [InvIn],

	SUM((I.Increment - I.Decrement)) OVER (
		PARTITION BY [LocId],[InvId],W.[WhId],[ProdId]
		ORDER BY [MovementDate]
		) + 50 AS QtyOnHand,

	100	AS [ReOrderLevel],
    YEAR(I.[MovementDate]) AS AsOfYear,
	MONTH(I.[MovementDate]) AS AsOfMonth,
	I.[MovementDate]
FROM [Product].[InventoryTransaction] I
JOIN (
	SELECT DISTINCT [WhId],[WhName] FROM [Product].[Warehouse]
	) W
ON I.WhId = W.WhId
ORDER BY	
	I.[InvId],
	I.[LocId],
	I.[WhId],
	I.ProdId,
	I.[MovementDate]
GO

-- carry over prior day's quantity

UPDATE [Product].[Warehouse] 
SET [QtyOnHand]  = (InvIn - InvOut) 
GO

/****************/
/* CHECK IT OUT */
/****************/

DROP INDEX IF EXISTS IeWarehouse ON [Product].[Warehouse]
GO

CREATE CLUSTERED INDEX IeWarehouse ON [Product].[Warehouse](
	[InvId],[LocId],[WhId] ,[ProdId]
	);
GO

SELECT [LocId], 
	[InvId], 
	[WhId], 
	[WhName], 
	[ProdId], 
	[InvOut], 
	[InvIn], 
	[QtyOnHand], 
	[ReorderLevel], 
	[AsOfYear], 
	[AsOfMonth],
	[AsOfDate]
  FROM [Product].[Warehouse]
  WHERE [AsOfYear] IN('2005')
  AND  [InvId] = 'INV1'
  AND  [LocId] = 'LOC1'
  AND  [WhId] = 'WH111'
  AND [ProdId] = 'P033'
  ORDER BY  
	[AsOfYear], 
	[AsOfMonth],
    [LocId], 
	[InvId], 
	[WhId], 
	[WhName], 
	[ProdId]
GO

/**********************/
/* VALIDATION QUERIES */
/**********************/

SELECT [AsOfYear],
	[AsOfMonth],
	[LocId],
	[InvId],
	[ProdId],
	[WhId],
	SUM([QtyOnHand]) AS QTY_ACROSS_WH
FROM [Product].[Warehouse]
GROUP BY [AsOfYear],
	[AsOfMonth],
	[LocId],
	[InvId],
	[ProdId],
	[WhId]
ORDER BY [AsOfYear],
	[AsOfMonth],
	[LocId],
	[InvId],
	[ProdId],
	[WhId]
GO

/*************/
/* INVENTORY */
/*************/

USE [APInventory]
GO

TRUNCATE TABLE [Product].[Inventory]
GO

INSERT INTO [Product].[Inventory]
SELECT [LocId]
      ,[InvId]
      ,[ProdId]
      ,SUM([QtyOnHand]) AS Units
	  ,EOMONTH([AsOfDate]) AS AsOfDate
FROM [Product].[Warehouse]
WHERE [AsOfDate] = EOMONTH([AsOfDate])
GROUP BY [LocId]
      ,[InvId]
      ,[ProdId]
	  ,EOMONTH([AsOfDate])
ORDER BY [LocId]
      ,[InvId]
      ,[ProdId];
GO

/***************/
/* QUICK CHECK */
/***************/

SELECT [LocId]
      ,[InvId]
      ,[ProdId]
      ,[Units]
      ,CONVERT(DATE,[AsOfDate]) AS InventoryDate
FROM [Product].[Inventory]
WHERE ProdId = 'P033'
AND YEAR(AsOfDate) = 2002
AND LocId= 'LOC1'
AND InvId IN('INV1','INV2')
ORDER BY [LocId]
      ,[InvId]
      ,[ProdId]
      ,[Units]
GO
     





