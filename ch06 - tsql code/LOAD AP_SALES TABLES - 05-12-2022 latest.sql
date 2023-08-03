/************************/
/* LOAD AP_SALES TABLES */
/************************/

/*
SELECT 'INSERT INTO [DIM].[Country] VALUES(''' 
	+ [CountryName] + 
	+ ''',''' + [ISO2CountryCode] 
   + ''',''' + [ISO3CountryCode] + ''')'
 FROM [SALES_DW].[DIM].[Country]
 GO
*/

USE [AP_SALES]
GO

/*********************/
/* LOAD DIM.CALENDAR */
/*********************/

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
	CASE 
		WHEN DATEPART(qq,@CurrentDate) = 1 THEN 'Q1'
		WHEN DATEPART(qq,@CurrentDate) = 2 THEN 'Q2'
	WHEN DATEPART(qq,@CurrentDate) = 3 THEN 'Q3'
	WHEN DATEPART(qq,@CurrentDate) = 4 THEN 'Q4'
	END,
	MONTH(@CurrentDate),
	CASE 
		WHEN MONTH(@CurrentDate) = 1 THEN 'JAN'
		WHEN MONTH(@CurrentDate) = 2 THEN 'FEB'
		WHEN MONTH(@CurrentDate) = 3 THEN 'MAR'
		WHEN MONTH(@CurrentDate) = 4 THEN 'APR'
		WHEN MONTH(@CurrentDate) = 5 THEN 'MAY'
		WHEN MONTH(@CurrentDate) = 6 THEN 'JUN'
		WHEN MONTH(@CurrentDate) = 7 THEN 'JUL'
		WHEN MONTH(@CurrentDate) = 8 THEN 'AUG'
		WHEN MONTH(@CurrentDate) = 9 THEN 'SEP'
		WHEN MONTH(@CurrentDate) = 10 THEN 'OCT'
		WHEN MONTH(@CurrentDate) = 11 THEN 'NOV'
		WHEN MONTH(@CurrentDate) = 12 THEN 'DEC'
	END,
	DAY(@CurrentDate)
	);

	SET @CurrentDate = DATEADD(dd,1,@CurrentDate);
END
GO


/********************/
/* LOAD DIM.COUNTRY */
/********************/

TRUNCATE TABLE [DIM].[Country]
GO

INSERT INTO [DIM].[Country] VALUES('Afghanistan','AF','AFG')
INSERT INTO [DIM].[Country] VALUES('Aland Islands','AX','ALA')
INSERT INTO [DIM].[Country] VALUES('Albania','AL','ALB')
INSERT INTO [DIM].[Country] VALUES('Algeria','DZ','DZA')
INSERT INTO [DIM].[Country] VALUES('American Samoa','AS','ASM')
INSERT INTO [DIM].[Country] VALUES('Andorra','AD','AND')
INSERT INTO [DIM].[Country] VALUES('Angola','AO','AGO')
INSERT INTO [DIM].[Country] VALUES('Anguilla','AI','AIA')
INSERT INTO [DIM].[Country] VALUES('Antarctica','AQ','ATA')
INSERT INTO [DIM].[Country] VALUES('Antigua and Barbuda','AG','ATG')
INSERT INTO [DIM].[Country] VALUES('Argentina','AR','ARG')
INSERT INTO [DIM].[Country] VALUES('Armenia','AM','ARM')
INSERT INTO [DIM].[Country] VALUES('Aruba','AW','ABW')
INSERT INTO [DIM].[Country] VALUES('Australia','AU','AUS')
INSERT INTO [DIM].[Country] VALUES('Austria','AT','AUT')
INSERT INTO [DIM].[Country] VALUES('Azerbaijan','AZ','AZE')
INSERT INTO [DIM].[Country] VALUES('Bahamas','BS','BHS')
INSERT INTO [DIM].[Country] VALUES('Bahrain','BH','BHR')
INSERT INTO [DIM].[Country] VALUES('Bangladesh','BD','BGD')
INSERT INTO [DIM].[Country] VALUES('Barbados','BB','BRB')
INSERT INTO [DIM].[Country] VALUES('Belarus','BY','BLR')
INSERT INTO [DIM].[Country] VALUES('Belgium','BE','BEL')
INSERT INTO [DIM].[Country] VALUES('Belize','BZ','BLZ')
INSERT INTO [DIM].[Country] VALUES('Benin','BJ','BEN')
INSERT INTO [DIM].[Country] VALUES('Bermuda','BM','BMU')
INSERT INTO [DIM].[Country] VALUES('Bhutan','BT','BTN')
INSERT INTO [DIM].[Country] VALUES('Bolivia','BO','BOL')
INSERT INTO [DIM].[Country] VALUES('Bosnia and Herzegovina','BA','BIH')
INSERT INTO [DIM].[Country] VALUES('Botswana','BW','BWA')
INSERT INTO [DIM].[Country] VALUES('Bouvet Island','BV','BVT')
INSERT INTO [DIM].[Country] VALUES('Brazil','BR','BRA')
INSERT INTO [DIM].[Country] VALUES('British Indian Ocean Territory','IO','IOT')
INSERT INTO [DIM].[Country] VALUES('British Virgin Islands','VG','VGB')
INSERT INTO [DIM].[Country] VALUES('Brunei Darussalam','BN','BRN')
INSERT INTO [DIM].[Country] VALUES('Bulgaria','BG','BGR')
INSERT INTO [DIM].[Country] VALUES('Burkina Faso','BF','BFA')
INSERT INTO [DIM].[Country] VALUES('Burundi','BI','BDI')
INSERT INTO [DIM].[Country] VALUES('Cambodia','KH','KHM')
INSERT INTO [DIM].[Country] VALUES('Cameroon','CM','CMR')
INSERT INTO [DIM].[Country] VALUES('Canada','CA','CAN')
INSERT INTO [DIM].[Country] VALUES('Cape Verde','CV','CPV')
INSERT INTO [DIM].[Country] VALUES('Cayman Islands','KY','CYM')
INSERT INTO [DIM].[Country] VALUES('Central African Republic','CF','CAF')
INSERT INTO [DIM].[Country] VALUES('Chad','TD','TCD')
INSERT INTO [DIM].[Country] VALUES('Chile','CL','CHL')
INSERT INTO [DIM].[Country] VALUES('China','CN','CHN')
INSERT INTO [DIM].[Country] VALUES('Christmas Island','CX','CXR')
INSERT INTO [DIM].[Country] VALUES('Cocos (Keeling) Islands','CC','CCK')
INSERT INTO [DIM].[Country] VALUES('Colombia','CO','COL')
INSERT INTO [DIM].[Country] VALUES('Comoros','KM','COM')
INSERT INTO [DIM].[Country] VALUES('Congo (Brazzaville)','CG','COG')
INSERT INTO [DIM].[Country] VALUES('Congo, (Kinshasa)','CD','COD')
INSERT INTO [DIM].[Country] VALUES('Cook Islands','CK','COK')
INSERT INTO [DIM].[Country] VALUES('Costa Rica','CR','CRI')
INSERT INTO [DIM].[Country] VALUES('Côte d''Ivoire','CI','CIV')
INSERT INTO [DIM].[Country] VALUES('Croatia','HR','HRV')
INSERT INTO [DIM].[Country] VALUES('Cuba','CU','CUB')
INSERT INTO [DIM].[Country] VALUES('Cyprus','CY','CYP')
INSERT INTO [DIM].[Country] VALUES('Czech Republic','CZ','CZE')
INSERT INTO [DIM].[Country] VALUES('Denmark','DK','DNK')
INSERT INTO [DIM].[Country] VALUES('Djibouti','DJ','DJI')
INSERT INTO [DIM].[Country] VALUES('Dominica','DM','DMA')
INSERT INTO [DIM].[Country] VALUES('Dominican Republic','DO','DOM')
INSERT INTO [DIM].[Country] VALUES('Ecuador','EC','ECU')
INSERT INTO [DIM].[Country] VALUES('Egypt','EG','EGY')
INSERT INTO [DIM].[Country] VALUES('El Salvador','SV','SLV')
INSERT INTO [DIM].[Country] VALUES('Equatorial Guinea','GQ','GNQ')
INSERT INTO [DIM].[Country] VALUES('Eritrea','ER','ERI')
INSERT INTO [DIM].[Country] VALUES('Estonia','EE','EST')
INSERT INTO [DIM].[Country] VALUES('Ethiopia','ET','ETH')
INSERT INTO [DIM].[Country] VALUES('Falkland Islands (Malvinas)','FK','FLK')
INSERT INTO [DIM].[Country] VALUES('Faroe Islands','FO','FRO')
INSERT INTO [DIM].[Country] VALUES('Fiji','FJ','FJI')
INSERT INTO [DIM].[Country] VALUES('Finland','FI','FIN')
INSERT INTO [DIM].[Country] VALUES('France','FR','FRA')
INSERT INTO [DIM].[Country] VALUES('French Guiana','GF','GUF')
INSERT INTO [DIM].[Country] VALUES('French Polynesia','PF','PYF')
INSERT INTO [DIM].[Country] VALUES('French Southern Territories','TF','ATF')
INSERT INTO [DIM].[Country] VALUES('Gabon','GA','GAB')
INSERT INTO [DIM].[Country] VALUES('Gambia','GM','GMB')
INSERT INTO [DIM].[Country] VALUES('Georgia','GE','GEO')
INSERT INTO [DIM].[Country] VALUES('Germany','DE','DEU')
INSERT INTO [DIM].[Country] VALUES('Ghana','GH','GHA')
INSERT INTO [DIM].[Country] VALUES('Gibraltar','GI','GIB')
INSERT INTO [DIM].[Country] VALUES('Greece','GR','GRC')
INSERT INTO [DIM].[Country] VALUES('Greenland','GL','GRL')
INSERT INTO [DIM].[Country] VALUES('Grenada','GD','GRD')
INSERT INTO [DIM].[Country] VALUES('Guadeloupe','GP','GLP')
INSERT INTO [DIM].[Country] VALUES('Guam','GU','GUM')
INSERT INTO [DIM].[Country] VALUES('Guatemala','GT','GTM')
INSERT INTO [DIM].[Country] VALUES('Guernsey','GG','GGY')
INSERT INTO [DIM].[Country] VALUES('Guinea','GN','GIN')
INSERT INTO [DIM].[Country] VALUES('Guinea-Bissau','GW','GNB')
INSERT INTO [DIM].[Country] VALUES('Guyana','GY','GUY')
INSERT INTO [DIM].[Country] VALUES('Haiti','HT','HTI')
INSERT INTO [DIM].[Country] VALUES('Heard and Mcdonald Islands','HM','HMD')
INSERT INTO [DIM].[Country] VALUES('Holy See (Vatican City State)','VA','VAT')
INSERT INTO [DIM].[Country] VALUES('Honduras','HN','HND')
INSERT INTO [DIM].[Country] VALUES('Hong Kong, SAR China','HK','HKG')
INSERT INTO [DIM].[Country] VALUES('Hungary','HU','HUN')
INSERT INTO [DIM].[Country] VALUES('Iceland','IS','ISL')
INSERT INTO [DIM].[Country] VALUES('India','IN','IND')
INSERT INTO [DIM].[Country] VALUES('Indonesia','ID','IDN')
INSERT INTO [DIM].[Country] VALUES('Iran, Islamic Republic of','IR','IRN')
INSERT INTO [DIM].[Country] VALUES('Iraq','IQ','IRQ')
INSERT INTO [DIM].[Country] VALUES('Ireland','IE','IRL')
INSERT INTO [DIM].[Country] VALUES('Isle of Man','IM','IMN')
INSERT INTO [DIM].[Country] VALUES('Israel','IL','ISR')
INSERT INTO [DIM].[Country] VALUES('Italy','IT','ITA')
INSERT INTO [DIM].[Country] VALUES('Jamaica','JM','JAM')
INSERT INTO [DIM].[Country] VALUES('Japan','JP','JPN')
INSERT INTO [DIM].[Country] VALUES('Jersey','JE','JEY')
INSERT INTO [DIM].[Country] VALUES('Jordan','JO','JOR')
INSERT INTO [DIM].[Country] VALUES('Kazakhstan','KZ','KAZ')
INSERT INTO [DIM].[Country] VALUES('Kenya','KE','KEN')
INSERT INTO [DIM].[Country] VALUES('Kiribati','KI','KIR')
INSERT INTO [DIM].[Country] VALUES('Korea (North)','KP','PRK')
INSERT INTO [DIM].[Country] VALUES('Korea (South)','KR','KOR')
INSERT INTO [DIM].[Country] VALUES('Kuwait','KW','KWT')
INSERT INTO [DIM].[Country] VALUES('Kyrgyzstan','KG','KGZ')
INSERT INTO [DIM].[Country] VALUES('Lao PDR','LA','LAO')
INSERT INTO [DIM].[Country] VALUES('Latvia','LV','LVA')
INSERT INTO [DIM].[Country] VALUES('Lebanon','LB','LBN')
INSERT INTO [DIM].[Country] VALUES('Lesotho','LS','LSO')
INSERT INTO [DIM].[Country] VALUES('Liberia','LR','LBR')
INSERT INTO [DIM].[Country] VALUES('Libya','LY','LBY')
INSERT INTO [DIM].[Country] VALUES('Liechtenstein','LI','LIE')
INSERT INTO [DIM].[Country] VALUES('Lithuania','LT','LTU')
INSERT INTO [DIM].[Country] VALUES('Luxembourg','LU','LUX')
INSERT INTO [DIM].[Country] VALUES('Macao, SAR China','MO','MAC')
INSERT INTO [DIM].[Country] VALUES('Macedonia, Republic of','MK','MKD')
INSERT INTO [DIM].[Country] VALUES('Madagascar','MG','MDG')
INSERT INTO [DIM].[Country] VALUES('Malawi','MW','MWI')
INSERT INTO [DIM].[Country] VALUES('Malaysia','MY','MYS')
INSERT INTO [DIM].[Country] VALUES('Maldives','MV','MDV')
INSERT INTO [DIM].[Country] VALUES('Mali','ML','MLI')
INSERT INTO [DIM].[Country] VALUES('Malta','MT','MLT')
INSERT INTO [DIM].[Country] VALUES('Marshall Islands','MH','MHL')
INSERT INTO [DIM].[Country] VALUES('Martinique','MQ','MTQ')
INSERT INTO [DIM].[Country] VALUES('Mauritania','MR','MRT')
INSERT INTO [DIM].[Country] VALUES('Mauritius','MU','MUS')
INSERT INTO [DIM].[Country] VALUES('Mayotte','YT','MYT')
INSERT INTO [DIM].[Country] VALUES('Mexico','MX','MEX')
INSERT INTO [DIM].[Country] VALUES('Micronesia, Federated States of','FM','FSM')
INSERT INTO [DIM].[Country] VALUES('Moldova','MD','MDA')
INSERT INTO [DIM].[Country] VALUES('Monaco','MC','MCO')
INSERT INTO [DIM].[Country] VALUES('Mongolia','MN','MNG')
INSERT INTO [DIM].[Country] VALUES('Montenegro','ME','MNE')
INSERT INTO [DIM].[Country] VALUES('Montserrat','MS','MSR')
INSERT INTO [DIM].[Country] VALUES('Morocco','MA','MAR')
INSERT INTO [DIM].[Country] VALUES('Mozambique','MZ','MOZ')
INSERT INTO [DIM].[Country] VALUES('Myanmar','MM','MMR')
INSERT INTO [DIM].[Country] VALUES('Namibia','NA','NAM')
INSERT INTO [DIM].[Country] VALUES('Nauru','NR','NRU')
INSERT INTO [DIM].[Country] VALUES('Nepal','NP','NPL')
INSERT INTO [DIM].[Country] VALUES('Netherlands','NL','NLD')
INSERT INTO [DIM].[Country] VALUES('Netherlands Antilles','AN','ANT')
INSERT INTO [DIM].[Country] VALUES('New Caledonia','NC','NCL')
INSERT INTO [DIM].[Country] VALUES('New Zealand','NZ','NZL')
INSERT INTO [DIM].[Country] VALUES('Nicaragua','NI','NIC')
INSERT INTO [DIM].[Country] VALUES('Niger','NE','NER')
INSERT INTO [DIM].[Country] VALUES('Nigeria','NG','NGA')
INSERT INTO [DIM].[Country] VALUES('Niue','NU','NIU')
INSERT INTO [DIM].[Country] VALUES('Norfolk Island','NF','NFK')
INSERT INTO [DIM].[Country] VALUES('Northern Mariana Islands','MP','MNP')
INSERT INTO [DIM].[Country] VALUES('Norway','NO','NOR')
INSERT INTO [DIM].[Country] VALUES('Oman','OM','OMN')
INSERT INTO [DIM].[Country] VALUES('Pakistan','PK','PAK')
INSERT INTO [DIM].[Country] VALUES('Palau','PW','PLW')
INSERT INTO [DIM].[Country] VALUES('Palestinian Territory','PS','PSE')
INSERT INTO [DIM].[Country] VALUES('Panama','PA','PAN')
INSERT INTO [DIM].[Country] VALUES('Papua New Guinea','PG','PNG')
INSERT INTO [DIM].[Country] VALUES('Paraguay','PY','PRY')
INSERT INTO [DIM].[Country] VALUES('Peru','PE','PER')
INSERT INTO [DIM].[Country] VALUES('Philippines','PH','PHL')
INSERT INTO [DIM].[Country] VALUES('Pitcairn','PN','PCN')
INSERT INTO [DIM].[Country] VALUES('Poland','PL','POL')
INSERT INTO [DIM].[Country] VALUES('Portugal','PT','PRT')
INSERT INTO [DIM].[Country] VALUES('Puerto Rico','PR','PRI')
INSERT INTO [DIM].[Country] VALUES('Qatar','QA','QAT')
INSERT INTO [DIM].[Country] VALUES('Réunion','RE','REU')
INSERT INTO [DIM].[Country] VALUES('Romania','RO','ROU')
INSERT INTO [DIM].[Country] VALUES('Russian Federation','RU','RUS')
INSERT INTO [DIM].[Country] VALUES('Rwanda','RW','RWA')
INSERT INTO [DIM].[Country] VALUES('Saint Helena','SH','SHN')
INSERT INTO [DIM].[Country] VALUES('Saint Kitts and Nevis','KN','KNA')
INSERT INTO [DIM].[Country] VALUES('Saint Lucia','LC','LCA')
INSERT INTO [DIM].[Country] VALUES('Saint Pierre and Miquelon','PM','SPM')
INSERT INTO [DIM].[Country] VALUES('Saint Vincent and Grenadines','VC','VCT')
INSERT INTO [DIM].[Country] VALUES('Saint-Barthélemy','BL','BLM')
INSERT INTO [DIM].[Country] VALUES('Saint-Martin (French part)','MF','MAF')
INSERT INTO [DIM].[Country] VALUES('Samoa','WS','WSM')
INSERT INTO [DIM].[Country] VALUES('San Marino','SM','SMR')
INSERT INTO [DIM].[Country] VALUES('Sao Tome and Principe','ST','STP')
INSERT INTO [DIM].[Country] VALUES('Saudi Arabia','SA','SAU')
INSERT INTO [DIM].[Country] VALUES('Senegal','SN','SEN')
INSERT INTO [DIM].[Country] VALUES('Serbia','RS','SRB')
INSERT INTO [DIM].[Country] VALUES('Seychelles','SC','SYC')
INSERT INTO [DIM].[Country] VALUES('Sierra Leone','SL','SLE')
INSERT INTO [DIM].[Country] VALUES('Singapore','SG','SGP')
INSERT INTO [DIM].[Country] VALUES('Slovakia','SK','SVK')
INSERT INTO [DIM].[Country] VALUES('Slovenia','SI','SVN')
INSERT INTO [DIM].[Country] VALUES('Solomon Islands','SB','SLB')
INSERT INTO [DIM].[Country] VALUES('Somalia','SO','SOM')
INSERT INTO [DIM].[Country] VALUES('South Africa','ZA','ZAF')
INSERT INTO [DIM].[Country] VALUES('South Georgia and the South Sandwich Islands','GS','SGS')
INSERT INTO [DIM].[Country] VALUES('South Sudan','SS','SSD')
INSERT INTO [DIM].[Country] VALUES('Spain','ES','ESP')
INSERT INTO [DIM].[Country] VALUES('Sri Lanka','LK','LKA')
INSERT INTO [DIM].[Country] VALUES('Sudan','SD','SDN')
INSERT INTO [DIM].[Country] VALUES('Suriname','SR','SUR')
INSERT INTO [DIM].[Country] VALUES('Svalbard and Jan Mayen Islands','SJ','SJM')
INSERT INTO [DIM].[Country] VALUES('Swaziland','SZ','SWZ')
INSERT INTO [DIM].[Country] VALUES('Sweden','SE','SWE')
INSERT INTO [DIM].[Country] VALUES('Switzerland','CH','CHE')
INSERT INTO [DIM].[Country] VALUES('Syrian Arab Republic (Syria)','SY','SYR')
INSERT INTO [DIM].[Country] VALUES('Taiwan, Republic of China','TW','TWN')
INSERT INTO [DIM].[Country] VALUES('Tajikistan','TJ','TJK')
INSERT INTO [DIM].[Country] VALUES('Tanzania, United Republic of','TZ','TZA')
INSERT INTO [DIM].[Country] VALUES('Thailand','TH','THA')
INSERT INTO [DIM].[Country] VALUES('Timor-Leste','TL','TLS')
INSERT INTO [DIM].[Country] VALUES('Togo','TG','TGO')
INSERT INTO [DIM].[Country] VALUES('Tokelau','TK','TKL')
INSERT INTO [DIM].[Country] VALUES('Tonga','TO','TON')
INSERT INTO [DIM].[Country] VALUES('Trinidad and Tobago','TT','TTO')
INSERT INTO [DIM].[Country] VALUES('Tunisia','TN','TUN')
INSERT INTO [DIM].[Country] VALUES('Turkey','TR','TUR')
INSERT INTO [DIM].[Country] VALUES('Turkmenistan','TM','TKM')
INSERT INTO [DIM].[Country] VALUES('Turks and Caicos Islands','TC','TCA')
INSERT INTO [DIM].[Country] VALUES('Tuvalu','TV','TUV')
INSERT INTO [DIM].[Country] VALUES('Uganda','UG','UGA')
INSERT INTO [DIM].[Country] VALUES('Ukraine','UA','UKR')
INSERT INTO [DIM].[Country] VALUES('United Arab Emirates','AE','ARE')
INSERT INTO [DIM].[Country] VALUES('United Kingdom','GB','GBR')
INSERT INTO [DIM].[Country] VALUES('United States','US','USA')
INSERT INTO [DIM].[Country] VALUES('Uruguay','UY','URY')
INSERT INTO [DIM].[Country] VALUES('US Minor Outlying Islands','UM','UMI')
INSERT INTO [DIM].[Country] VALUES('Uzbekistan','UZ','UZB')
INSERT INTO [DIM].[Country] VALUES('Vanuatu','VU','VUT')
INSERT INTO [DIM].[Country] VALUES('Venezuela (Bolivarian Republic)','VE','VEN')
INSERT INTO [DIM].[Country] VALUES('Viet Nam','VN','VNM')
INSERT INTO [DIM].[Country] VALUES('Virgin Islands, US','VI','VIR')
INSERT INTO [DIM].[Country] VALUES('Wallis and Futuna Islands','WF','WLF')
INSERT INTO [DIM].[Country] VALUES('Western Sahara','EH','ESH')
INSERT INTO [DIM].[Country] VALUES('Yemen','YE','YEM')
INSERT INTO [DIM].[Country] VALUES('Zambia','ZM','ZMB')
INSERT INTO [DIM].[Country] VALUES('Zimbabwe','ZW','ZWE')
GO

/***************/
/* DISTRIBUTOR */
/***************/

DROP TABLE IF EXISTS [DIM].[Distributor]
GO

CREATE TABLE DIM.Distributor(
	DistributorKey INTEGER IDENTITY NOT NULL,
	DistributorNo  VARCHAR(8) NOT NULL,
	DistributorName VARCHAR(128) NOT NULL
  )
  GO

  INSERT INTO DIM.Distributor
  VALUES
	('D0000001','Eastern European Fancy Baked Goods'),
	('D0000002','Central European Fancy Baked Goods'),
	('D0000001','Pacific European Fancy Baked Goods');
GO


/*********/
/* STORE */
/*********/

TRUNCATE TABLE [DIM].[Store]
GO

INSERT INTO [DIM].[Store]
VALUES
	('S00001','New York City Store','Eastern Territory'),
	('S00002','Albany City Store','Eastern Territory'),
	('S00003','Syracuse Store','Eastern Territory'),
	('S00004','Binghamton Store','Eastern Territory'),

	('S00005','Chicago Store','Central Territory'),
	('S00006','Indianapolis Store','Central Territory'),
	('S00007','Fort Wayne','Central Territory'),
	('S00008','Minneapolis Store','Central Territory'),

	('S00009','Denver Store','Central Territory'),
	('S00010','Boise Store','Central Territory'),
	('S00011','Grand Fork Store','Central Territory'),
	('S00012','Bismark Store','Central Territory'),

	('S00013','Los Angeles Store','Pacific Territory'),
	('S00014','San Diego Store','Pacific Territory'),
	('S00015','Sacramento Store','Pacific Territory'),
	('S00016','Eureka Store','Pacific Territory');
GO

SELECT * FROM [DIM].[Store]
GO

/*********************/
/* STORE DISTRIBUTOR */
/*********************/

TRUNCATE TABLE DIM.StoreDistributor
GO

INSERT INTO DIM.StoreDistributor
SELECT DISTINCT 1 AS Distributor,
S.[StoreKey],S.StoreNo
FROM [DIM].[Store] S
CROSS JOIN [DIM].[Distributor] D
WHERE S.StoreTerritory LIKE 'Eastern%'
UNION ALL
SELECT 2,S.[StoreKey],S.StoreNo
FROM [DIM].[Store] S
CROSS JOIN [DIM].[Distributor] D
WHERE D.DistributorName = 'Central European Fancy Baked Goods'
AND S.StoreTerritory LIKE 'Central%'
UNION ALL
SELECT 3,S.[StoreKey],S.StoreNo
FROM [DIM].[Store] S
CROSS JOIN [DIM].[Distributor] D
WHERE D.DistributorName = 'Pacific European Fancy Baked Goods'
AND S.StoreTerritory LIKE 'Pacific%'
GO

SELECT * FROM DIM.StoreDistributor
GO


/*********************/
/* LOAD DIM.CUSTOMER */
/*********************/

/***************************************************/
/* NOTE:                                           */
/* A CUSTOMER IS ACTUALLY A SALESPERSON IN A STORE */
/***************************************************/

TRUNCATE TABLE [DIM].[Customer]
GO

DECLARE @FirstName TABLE (
	FName VARCHAR(64) NOT NULL
	);

DECLARE @LastName TABLE (
	LName VARCHAR(64) NOT NULL
	);

INSERT INTO @FirstName VALUES 
	('John'),('Jim'),('Mary'),('Susan'),('Peter'),('Bill'),('Thomas'),('Gwendolyn'),('Debbie'),('Micheal');

INSERT INTO @LastName VALUES
	('Brown'),('Green'),('Smith'),('Smyhte'),('Toscano'),('McNamara'),('OToole'),('OConnel'),('Montana'),('Belvedere');

INSERT INTO [DIM].[Customer]
SELECT 'C0000000',F.FName + ' ' + L.Lname,F.FName,L.Lname,NULL
FROM @FirstName F
CROSS JOIN @Lastname L
GO

UPDATE [DIM].[Customer]
	SET [CustomerNo] = 
	(
	CASE
		WHEN [CustomerKey] BETWEEN 1 AND 9 THEN [CustomerNo] + CONVERT(VARCHAR,[CustomerKey])
		WHEN [CustomerKey] BETWEEN 10 AND 99 THEN SUBSTRING([CustomerNo],1,7) + CONVERT(VARCHAR,[CustomerKey])
		WHEN [CustomerKey] > 99 THEN SUBSTRING([CustomerNo],1,6) + CONVERT(VARCHAR,[CustomerKey])
	END
	)
GO

-- let's take a look

SELECT * FROM [DIM].[Customer]
GO

-- need to assign customers (sales persons) to stores

UPDATE [DIM].[Customer]
	SET [StoreNo] = 
	(
	CASE
		WHEN [CustomerKey] BETWEEN 1 AND 6 THEN 'S00001'
		WHEN [CustomerKey] BETWEEN 7 AND 13 THEN 'S00002'
		WHEN [CustomerKey] BETWEEN 14 AND 20 THEN 'S00003'
		WHEN [CustomerKey] BETWEEN 21 AND 27 THEN 'S00004'
		WHEN [CustomerKey] BETWEEN 28 AND 34 THEN 'S00005'
		WHEN [CustomerKey] BETWEEN 35 AND 41 THEN 'S00006'
		WHEN [CustomerKey] BETWEEN 42 AND 48 THEN 'S00007'
		WHEN [CustomerKey] BETWEEN 49 AND 55 THEN 'S00008'
		WHEN [CustomerKey] BETWEEN 56 AND 62 THEN 'S00009'
		WHEN [CustomerKey] BETWEEN 63 AND 69 THEN 'S00010'
		WHEN [CustomerKey] BETWEEN 70 AND 76 THEN 'S00011'
		WHEN [CustomerKey] BETWEEN 77 AND 83 THEN 'S00012'
	    WHEN [CustomerKey] BETWEEN 84 AND 90 THEN 'S00013'
		WHEN [CustomerKey] BETWEEN 91 AND 95 THEN 'S00014'
		WHEN [CustomerKey] BETWEEN 96 AND 99 THEN 'S00015'
		WHEN [CustomerKey] = 100 THEN 'S00016'
		ELSE '???'
	END
	)
GO

/********************/
/* PRODUCT CATEGORY */
/********************/

TRUNCATE TABLE [DIM].[ProductCategory]
GO

INSERT INTO [DIM].[ProductCategory]
VALUES
	('PC001','Chocolates'),
	('PC002','Cakes'),
	('PC003','Pies'),
	('PC004','Croissants'),
	('PC005','Tarts');
GO

TRUNCATE TABLE [DIM].[ProductSubCategory]
GO

INSERT INTO [DIM].[ProductSubCategory]
VALUES
	('PC001','PSC0010','Dark Chocolates - Small'),
	('PC002','PSC0020','Chocolate Cakes - Small'),
	('PC003','PSC0030','Chocolate Pies - Small'),
	('PC004','PSC0040','Chocolate Croissants - Small'),
	('PC005','PSC0050','Chocolate Tarts - Small'),
	('PC001','PSC0060','Milk Chocolates - Small'),
	('PC002','PSC0070','Vanilla Cakes - Small'),
	('PC003','PSC0080','Pecan Pies - Small'),
	('PC004','PSC0090','Strawberry Croissants - Small'),
	('PC005','PSC0100','Strawberry Tarts - Small'),
	('PC001','PSC0110','Almond Chocolates - Small'),
	('PC002','PSC0120','Cheese Cakes - Small'),
	('PC003','PSC0130','Apple Pies - Small'),
	('PC004','PSC0140','Almond Croissants - Small'),
	('PC005','PSC0150','Fruit Tarts - Small'),
	('PC001','PSC0160','Mocha Chocolates - Small'),
	('PC002','PSC0170','Layer Cakes - Small'),
	('PC003','PSC0180','Cherry Pies - Small'),
	('PC004','PSC0190','Plain Croissants - Small'),
	('PC005','PSC0200','Peach Tarts - Small');
GO

INSERT INTO [DIM].[ProductSubCategory]
VALUES
	('PC001','PSC0011','Dark Chocolates - Medium'),
	('PC002','PSC0021','Chocolate Cakes - Medium'),
	('PC003','PSC0031','Chocolate Pies - Medium'),
	('PC004','PSC0041','Chocolate Croissants - Medium'),
	('PC005','PSC0051','Chocolate Tarts - Medium'),
	('PC001','PSC0061','Milk Chocolates - Medium'),
	('PC002','PSC0071','Vanilla Cakes - Medium'),
	('PC003','PSC0081','Pecan Pies - Medium'),
	('PC004','PSC0091','Strawberry Croissants - Medium'),
	('PC005','PSC0101','Strawberry Tarts - Medium'),
	('PC001','PSC0111','Almond Chocolates - Medium'),
	('PC002','PSC0121','Cheese Cakes - Medium'),
	('PC003','PSC0131','Apple Pies - Medium'),
	('PC004','PSC0141','Almond Croissants - Medium'),
	('PC005','PSC0151','Fruit Tarts - Medium'),
	('PC001','PSC0161','Mocha Chocolates - Medium'),
	('PC002','PSC0171','Layer Cakes - Medium'),
	('PC003','PSC0181','Cherry Pies - Medium'),
	('PC004','PSC0191','Plain Croissants - Medium'),
	('PC005','PSC0201','Peach Tarts - Medium');
GO

INSERT INTO [DIM].[ProductSubCategory]
VALUES
	('PC002','PSC0012','Dark Chocolates - Large'),
	('PC002','PSC0022','Chocolate Cakes - Large'),
	('PC003','PSC0032','Chocolate Pies - Large'),
	('PC004','PSC0042','Chocolate Croissants - Large'),
	('PC005','PSC0052','Chocolate Tarts - Large'),
	('PC002','PSC0062','Milk Chocolates - Large'),
	('PC002','PSC0072','Vanilla Cakes - Large'),
	('PC003','PSC0082','Pecan Pies - Large'),
	('PC004','PSC0092','Strawberry Croissants - Large'),
	('PC005','PSC0102','Strawberry Tarts - Large'),
	('PC002','PSC0112','Almond Chocolates - Large'),
	('PC002','PSC0122','Cheese Cakes - Large'),
	('PC003','PSC0132','Apple Pies - Large'),
	('PC004','PSC0142','Almond Croissants - Large'),
	('PC005','PSC0152','Fruit Tarts - Large'),
	('PC002','PSC0162','Mocha Chocolates - Large'),
	('PC002','PSC0172','Layer Cakes - Large'),
	('PC003','PSC0182','Cherry Pies - Large'),
	('PC004','PSC0192','Plain Croissants - Large'),
	('PC005','PSC0202','Peach Tarts - Large');
GO

SELECT *
FROM [DIM].[ProductSubCategory]
ORDER BY 1,2,3
GO


/****************/
/* LOAD PRODUCT */
/****************/

TRUNCATE TABLE [DIM].[Product];

INSERT INTO [DIM].[Product]
SELECT distinct 'P00000',
	PSC.[ProductSubCategoryName],
	PSC.[ProductCategoryCode],
	PSC.[ProductSubCategoryCode],
	000.00,
	000.00
FROM [DIM].[ProductCategory] PC
JOIN [DIM].[ProductSubCategory] PSC
ON PC.ProductCategoryCode = PSC.ProductCategoryCode
ORDER BY 1,2,3
GO

UPDATE [DIM].[Product] 
SET [ProductNo] = [ProductNo] 
	+ RIGHT([ProductCategoryCode],2)
	+ RIGHT([ProductSubCategoryCode],2)
	+ CONVERT(VARCHAR,ProductKey);

UPDATE [DIM].[Product] 
SET [ProductWholeSalePrice] =
CASE	
	WHEN [ProductName] LIKE '%Large%' THEN 35.00
	WHEN [ProductName] LIKE '%Medium%' THEN 25.00
	WHEN [ProductName] LIKE '%Small%' THEN 15.00
END
GO

-- set retail price as 25% markup
UPDATE [DIM].[Product] 
SET [ProductRetailPrice] = [ProductWholeSalePrice] * 1.25
GO


/********************************/
/* LOAD SALES TRANSACTION TABLE */
/********************************/

-- ran approx 4 minutes
-- generated 11,904,000 row
-- backup DB and dump log after running this!

/*
DROP TABLE IF EXISTS STAGE.SALES_TRANSACTION
GO
*/

TRUNCATE TABLE STAGE.SALES_TRANSACTION
GO

INSERT INTO STAGE.SALES_TRANSACTION
SELECT  C.[CountryName]
      ,C.[ISO2CountryCode]
      ,C.[ISO3CountryCode]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,CAL.CalendarDate
	  ,P.ProductCategoryCode
	  ,P.ProductSubCategoryCode
	  ,P.ProductNo

	  /*
	  ,CASE	
		WHEN [CustomerKey] % 2 = 0 THEN 2
		ELSE 1	  
	   END AS [TransactionQuantity]
	   */

	   ,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10) AS [TransactionQuantity]

	   /*
	   ,CEILING(CONVERT(INT,
	   SUBSTRING(
		CONVERT(VARCHAR,
			RAND(CAL.[DayOfMonth])
			),
			5,
			8
		)
	   )/(CAL.[DayOfMonth] * 100.0)) AS [TransactionQuantity]
	   */

	   -- we should really be using wholesale price
	   -- as our business case tells us that a distributor
	   -- sells to a store and not to the public in which
	   -- case we need to change the UnitRetailPrice name
	   -- to UnitWholeSalePrice. Better yet, include both columns:

 	   --,P.ProductWholeSalePrice AS [UnitWholeSalePrice]
	   --,P.ProductWholeSalePrice * .08 AS [UnitSalesTaxAmount]

	  ,P.ProductRetailPrice AS [UnitRetailPrice]
	  ,P.ProductWholeSalePrice
	  ,P.ProductRetailPrice * .08 AS [UnitSalesTaxAmount]
	  ,0.0 AS [TotalSalesAmount]
--INTO STAGE.SALES_TRANSACTION
FROM [AP_SALES].[DIM].[Country] C WITH (NOLOCK)
CROSS JOIN [DIM].[Customer] CU WITH (NOLOCK)
CROSS JOIN [DIM].[Store] S WITH (NOLOCK)
CROSS JOIN [DIM].[Calendar] CAL WITH (NOLOCK)
CROSS JOIN [DIM].[Product] P WITH (NOLOCK)
WHERE C.[CountryName] LIKE '%United States%'
AND CAL.CalendarDate BETWEEN '1/1/2010' AND '12/31/2012'
AND DAY(CAL.[CalendarDate]) IN (28,29,30,31) -- days orders entered
GO

/***********************************************************************************/
/* change the physical file patch in case your machine has a different disk layout */
/***********************************************************************************/

BACKUP LOG [AP_SALES] 
TO  DISK = N'D:\APRESS_DATABASES\AP_SALES_BACKUP\AP_SALES_BAKUP.LOG' 
WITH NOFORMAT,INIT,  
NAME = N'AP_SALES-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  
STATS = 10
GO


/*************************/
/* LOAD SALES FACT TABLE */
/*************************/

-- now we need to load the fact table with
-- the transactions
-- took 6 min, 25 sec

-- create some indexes to speed things up

DROP INDEX IF EXISTS [STAGE].ieFactCalendarDate
GO

CREATE INDEX ieFactCalendarDate ON
[STAGE].[Sales_Transaction] (
	[CalendarDate])
ON AP_SALES_FG
GO

DROP INDEX IF EXISTS [STAGE].ieCalendarDate
GO

CREATE UNIQUE INDEX ieCalendarDate ON
 [DIM].[Calendar]
	([CalendarDate])
ON AP_SALES_FG
GO


TRUNCATE TABLE [FACT].[Sales]
GO

--DROP TABLE IF EXISTS [FACT].[Sales]
--GO

/*****************************************************/
/* 1 minute, 33 seconds to load if SELECT/INTO used. */
/*****************************************************/

--INSERT INTO [FACT].[Sales]
SELECT DISTINCT CUST.[CustomerKey]
	  ,P.ProductKey
	  ,C.[CountryKey]
	  ,S.StoreKey
	  ,CAL.CalendarKey

      ,ST.[TransactionQuantity]

	 /***************************/
	/* to include whole price: */
	/***************************/
	  ,P.[ProductWholeSalePrice]
      ,ST.[UnitRetailPrice]
      ,ST.[UnitSalesTaxAmount]

	  ,ST.[TransactionQuantity] * 
		P.[ProductWholeSalePrice] 
			+ ST.[UnitSalesTaxAmount] AS [TotalWholeSaleAmount]


      ,ST.[TransactionQuantity] * 
		(ST.[UnitRetailPrice] 
			+ ST.[UnitSalesTaxAmount]) AS [TotalSalesAmount]
INTO [FACT].[Sales]
FROM [STAGE].[SALES_TRANSACTION] ST
	JOIN [DIM].[Customer] CUST WITH (NOLOCK)
ON ST.[CustomerNo] = CUST.CustomerNo
	JOIN [DIM].[Calendar] CAL WITH (NOLOCK)
ON CAL.[CalendarDate] = ST.[CalendarDate]
	JOIN [DIM].[Product] P WITH (NOLOCK)
ON P.ProductNo = ST.[ProductNo]
	JOIN [DIM].[Country] C WITH (NOLOCK)
ON C.CountryName = ST.[CountryName]
	JOIN [DIM].[Store] S WITH (NOLOCK)
ON S.StoreNo = ST.[StoreNo]
WHERE DAY(CAL.[CalendarDate]) IN (28,29,30,31)
AND CAL.CalendarDate BETWEEN '1/1/2010' AND '12/31/2012'
AND [TransactionQuantity] <> 0
GO

CREATE CLUSTERED INDEX ieSalesFact ON
[FACT].[Sales] (
[CalendarKey],
[CountryKey],
[CustomerKey],
[StoreKey],
[ProductKey]
)
ON AP_SALES_FG
GO

-- check for duplicates

SELECT distinct [CustomerKey], [ProductKey], [CountryKey], [StoreKey], [CalendarKey], 
[TransactionQuantity], [TotalSalesAmount], [UnitSalesTaxAmount], [TotalSalesAmount]
,count(*)
FROM [FACT].[Sales] WITH (NOLOCK)
GROUP BY [CustomerKey], [ProductKey], [CountryKey], [StoreKey], [CalendarKey], 
[TransactionQuantity], [TotalSalesAmount], [UnitSalesTaxAmount], [TotalSalesAmount]
HAVING count(*) > 1
GO


-- create stored procedure to generate random values

USE [AP_SALES]
GO

CREATE PROCEDURE [FACT].[usp_RandomFloat]
@RANDOM_VALUE FLOAT OUTPUT, @START_RANGE FLOAT, @STOP_RANGE FLOAT
AS
SET @RANDOM_VALUE = CONVERT (FLOAT, ROUND(UPPER(RAND() * @STOP_RANGE + @START_RANGE), 0));
GO


/*******************************************/
/* BACKUP AND TRUNCATE THE TRANSACTION LOG */
/*******************************************/

/***********************************************************************************/
/* change the physical file patch in case your machine has a different disk layout */
/***********************************************************************************/

BACKUP LOG [AP_SALES] 
TO  DISK = N'D:\APRESS_DATABASES\AP_SALES_BACKUP\AP_SALES_BAKUP.LOG' 
WITH NOFORMAT,INIT,  
NAME = N'AP_SALES-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  
STATS = 10
GO

/********************/
/* Run a test query */
/********************/

-- 1 second, 34,560 rows

SELECT C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate) AS SalesYear
	  ,MONTH(CAL.CalendarDate) AS SalesMonth
	  ,P.ProductCategoryCode
	  ,P.ProductSubCategoryCode
	  ,SUM(FS.[TotalSalesAmount]) AS TotalSales
FROM [FACT].[Sales] FS WITH (NOLOCK)
JOIN [DIM].[Country] C WITH (NOLOCK)
ON C.[CountryKey] = FS.[CountryKey]
JOIN [DIM].[Customer] CU WITH (NOLOCK)
ON CU.[CustomerKey] = FS.[CustomerKey]
JOIN [DIM].[Store] S WITH (NOLOCK)
ON S.[StoreKey] = FS.[StoreKey]
JOIN [DIM].[Calendar] CAL WITH (NOLOCK)
ON CAL.[CalendarKey] = FS.[CalendarKey]
JOIN [DIM].[Product] P WITH (NOLOCK)
ON P.[ProductKey] = FS.[ProductKey]
WHERE CU.CustomerNo = 'C00000005'
--AND CAL.CalendarKey = 2016263
GROUP BY C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate)
	  ,MONTH(CAL.CalendarDate) 
	  ,P.ProductCategoryCode
	  ,P.ProductSubCategoryCode
ORDER BY C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate)
	  ,MONTH(CAL.CalendarDate) 
	  ,P.ProductCategoryCode
	  ,P.ProductSubCategoryCode
GO

DROP INDEX IF EXISTS [FACT].pkFactSales
GO

CREATE CLUSTERED INDEX pkFactSales ON
[FACT].[Sales] (
	[CalendarKey],[CountryKey],[CustomerKey],[ProductKey],[StoreKey])
ON AP_SALES_FG
GO

DROP INDEX IF EXISTS [FACT].pkCalendarKey
GO

CREATE UNIQUE INDEX pkCalendarKey ON
 [DIM].[Calendar]
	(CalendarKey)
ON AP_SALES_FG
GO

SELECT C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate) AS SalesYear
	  ,MONTH(CAL.CalendarDate) AS SalesMonth
	  ,P.ProductCategoryCode
	  ,AVG(FS.[TotalSalesAmount]) AS AvgTotalSales
	  ,SUM(FS.[TotalSalesAmount]) AS SumTotalSales
	  ,MIN(FS.[TotalSalesAmount]) AS MinTotalSales
	  ,MAX(FS.[TotalSalesAmount]) AS MaxTotalSales
FROM [FACT].[Sales] FS
	JOIN [DIM].[Country] C
		ON C.[CountryKey] = FS.[CountryKey]
	JOIN [DIM].[Customer] CU
		ON CU.[CustomerKey] = FS.[CustomerKey]
	JOIN [DIM].[Store] S
		ON S.[StoreKey] = FS.[StoreKey]
	JOIN [DIM].[Calendar] CAL
		ON CAL.[CalendarKey] = FS.[CalendarKey]
	JOIN [DIM].[Product] P
		ON P.[ProductKey] = FS.[ProductKey]
WHERE CU.CustomerNo = 'C00000001'
GROUP BY C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate)
	  ,MONTH(CAL.CalendarDate) 
	  ,P.ProductCategoryCode
ORDER BY C.[CountryName]
	  ,CU.[CustomerNo]
	  ,S.[StoreNo]
	  ,YEAR(CAL.CalendarDate)
	  ,MONTH(CAL.CalendarDate) 
	  ,P.ProductCategoryCode
GO





