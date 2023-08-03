/************************/
/* LOAD AP_SALES TABLES */
/************************/

-- Modified Date: 10/05/2022 - update load transactions, fact and sales report table
-- so that customers do not buy all products but just a selected few

USE [APSales]
GO

/**********/
/* STEP 1 */
/**********/

/*************************/
/* LOAD DimTableCalendar */
/*************************/

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

/**********/
/* STEP 2 */
/**********/

/*****************************/
/* LOAD [DimTable].[Country] */
/*****************************/

TRUNCATE TABLE DimTable.Country
GO

INSERT INTO DimTable.Country VALUES('Afghanistan','AF','AFG')
INSERT INTO DimTable.Country VALUES('Aland Islands','AX','ALA')
INSERT INTO DimTable.Country VALUES('Albania','AL','ALB')
INSERT INTO DimTable.Country VALUES('Algeria','DZ','DZA')
INSERT INTO DimTable.Country VALUES('American Samoa','AS','ASM')
INSERT INTO DimTable.Country VALUES('Andorra','AD','AND')
INSERT INTO DimTable.Country VALUES('Angola','AO','AGO')
INSERT INTO DimTable.Country VALUES('Anguilla','AI','AIA')
INSERT INTO DimTable.Country VALUES('Antarctica','AQ','ATA')
INSERT INTO DimTable.Country VALUES('Antigua and Barbuda','AG','ATG')
INSERT INTO DimTable.Country VALUES('Argentina','AR','ARG')
INSERT INTO DimTable.Country VALUES('Armenia','AM','ARM')
INSERT INTO DimTable.Country VALUES('Aruba','AW','ABW')
INSERT INTO DimTable.Country VALUES('Australia','AU','AUS')
INSERT INTO DimTable.Country VALUES('Austria','AT','AUT')
INSERT INTO DimTable.Country VALUES('Azerbaijan','AZ','AZE')
INSERT INTO DimTable.Country VALUES('Bahamas','BS','BHS')
INSERT INTO DimTable.Country VALUES('Bahrain','BH','BHR')
INSERT INTO DimTable.Country VALUES('Bangladesh','BD','BGD')
INSERT INTO DimTable.Country VALUES('Barbados','BB','BRB')
INSERT INTO DimTable.Country VALUES('Belarus','BY','BLR')
INSERT INTO DimTable.Country VALUES('Belgium','BE','BEL')
INSERT INTO DimTable.Country VALUES('Belize','BZ','BLZ')
INSERT INTO DimTable.Country VALUES('Benin','BJ','BEN')
INSERT INTO DimTable.Country VALUES('Bermuda','BM','BMU')
INSERT INTO DimTable.Country VALUES('Bhutan','BT','BTN')
INSERT INTO DimTable.Country VALUES('Bolivia','BO','BOL')
INSERT INTO DimTable.Country VALUES('Bosnia and Herzegovina','BA','BIH')
INSERT INTO DimTable.Country VALUES('Botswana','BW','BWA')
INSERT INTO DimTable.Country VALUES('Bouvet Island','BV','BVT')
INSERT INTO DimTable.Country VALUES('Brazil','BR','BRA')
INSERT INTO DimTable.Country VALUES('British Indian Ocean Territory','IO','IOT')
INSERT INTO DimTable.Country VALUES('British Virgin Islands','VG','VGB')
INSERT INTO DimTable.Country VALUES('Brunei Darussalam','BN','BRN')
INSERT INTO DimTable.Country VALUES('Bulgaria','BG','BGR')
INSERT INTO DimTable.Country VALUES('Burkina Faso','BF','BFA')
INSERT INTO DimTable.Country VALUES('Burundi','BI','BDI')
INSERT INTO DimTable.Country VALUES('Cambodia','KH','KHM')
INSERT INTO DimTable.Country VALUES('Cameroon','CM','CMR')
INSERT INTO DimTable.Country VALUES('Canada','CA','CAN')
INSERT INTO DimTable.Country VALUES('Cape Verde','CV','CPV')
INSERT INTO DimTable.Country VALUES('Cayman Islands','KY','CYM')
INSERT INTO DimTable.Country VALUES('Central African Republic','CF','CAF')
INSERT INTO DimTable.Country VALUES('Chad','TD','TCD')
INSERT INTO DimTable.Country VALUES('Chile','CL','CHL')
INSERT INTO DimTable.Country VALUES('China','CN','CHN')
INSERT INTO DimTable.Country VALUES('Christmas Island','CX','CXR')
INSERT INTO DimTable.Country VALUES('Cocos (Keeling) Islands','CC','CCK')
INSERT INTO DimTable.Country VALUES('Colombia','CO','COL')
INSERT INTO DimTable.Country VALUES('Comoros','KM','COM')
INSERT INTO DimTable.Country VALUES('Congo (Brazzaville)','CG','COG')
INSERT INTO DimTable.Country VALUES('Congo, (Kinshasa)','CD','COD')
INSERT INTO DimTable.Country VALUES('Cook Islands','CK','COK')
INSERT INTO DimTable.Country VALUES('Costa Rica','CR','CRI')
INSERT INTO DimTable.Country VALUES('Côte d''Ivoire','CI','CIV')
INSERT INTO DimTable.Country VALUES('Croatia','HR','HRV')
INSERT INTO DimTable.Country VALUES('Cuba','CU','CUB')
INSERT INTO DimTable.Country VALUES('Cyprus','CY','CYP')
INSERT INTO DimTable.Country VALUES('Czech Republic','CZ','CZE')
INSERT INTO DimTable.Country VALUES('Denmark','DK','DNK')
INSERT INTO DimTable.Country VALUES('Djibouti','DJ','DJI')
INSERT INTO DimTable.Country VALUES('Dominica','DM','DMA')
INSERT INTO DimTable.Country VALUES('Dominican Republic','DO','DOM')
INSERT INTO DimTable.Country VALUES('Ecuador','EC','ECU')
INSERT INTO DimTable.Country VALUES('Egypt','EG','EGY')
INSERT INTO DimTable.Country VALUES('El Salvador','SV','SLV')
INSERT INTO DimTable.Country VALUES('Equatorial Guinea','GQ','GNQ')
INSERT INTO DimTable.Country VALUES('Eritrea','ER','ERI')
INSERT INTO DimTable.Country VALUES('Estonia','EE','EST')
INSERT INTO DimTable.Country VALUES('Ethiopia','ET','ETH')
INSERT INTO DimTable.Country VALUES('Falkland Islands (Malvinas)','FK','FLK')
INSERT INTO DimTable.Country VALUES('Faroe Islands','FO','FRO')
INSERT INTO DimTable.Country VALUES('Fiji','FJ','FJI')
INSERT INTO DimTable.Country VALUES('Finland','FI','FIN')
INSERT INTO DimTable.Country VALUES('France','FR','FRA')
INSERT INTO DimTable.Country VALUES('French Guiana','GF','GUF')
INSERT INTO DimTable.Country VALUES('French Polynesia','PF','PYF')
INSERT INTO DimTable.Country VALUES('French Southern Territories','TF','ATF')
INSERT INTO DimTable.Country VALUES('Gabon','GA','GAB')
INSERT INTO DimTable.Country VALUES('Gambia','GM','GMB')
INSERT INTO DimTable.Country VALUES('Georgia','GE','GEO')
INSERT INTO DimTable.Country VALUES('Germany','DE','DEU')
INSERT INTO DimTable.Country VALUES('Ghana','GH','GHA')
INSERT INTO DimTable.Country VALUES('Gibraltar','GI','GIB')
INSERT INTO DimTable.Country VALUES('Greece','GR','GRC')
INSERT INTO DimTable.Country VALUES('Greenland','GL','GRL')
INSERT INTO DimTable.Country VALUES('Grenada','GD','GRD')
INSERT INTO DimTable.Country VALUES('Guadeloupe','GP','GLP')
INSERT INTO DimTable.Country VALUES('Guam','GU','GUM')
INSERT INTO DimTable.Country VALUES('Guatemala','GT','GTM')
INSERT INTO DimTable.Country VALUES('Guernsey','GG','GGY')
INSERT INTO DimTable.Country VALUES('Guinea','GN','GIN')
INSERT INTO DimTable.Country VALUES('Guinea-Bissau','GW','GNB')
INSERT INTO DimTable.Country VALUES('Guyana','GY','GUY')
INSERT INTO DimTable.Country VALUES('Haiti','HT','HTI')
INSERT INTO DimTable.Country VALUES('Heard and Mcdonald Islands','HM','HMD')
INSERT INTO DimTable.Country VALUES('Holy See (Vatican City State)','VA','VAT')
INSERT INTO DimTable.Country VALUES('Honduras','HN','HND')
INSERT INTO DimTable.Country VALUES('Hong Kong, SAR China','HK','HKG')
INSERT INTO DimTable.Country VALUES('Hungary','HU','HUN')
INSERT INTO DimTable.Country VALUES('Iceland','IS','ISL')
INSERT INTO DimTable.Country VALUES('India','IN','IND')
INSERT INTO DimTable.Country VALUES('Indonesia','ID','IDN')
INSERT INTO DimTable.Country VALUES('Iran, Islamic Republic of','IR','IRN')
INSERT INTO DimTable.Country VALUES('Iraq','IQ','IRQ')
INSERT INTO DimTable.Country VALUES('Ireland','IE','IRL')
INSERT INTO DimTable.Country VALUES('Isle of Man','IM','IMN')
INSERT INTO DimTable.Country VALUES('Israel','IL','ISR')
INSERT INTO DimTable.Country VALUES('Italy','IT','ITA')
INSERT INTO DimTable.Country VALUES('Jamaica','JM','JAM')
INSERT INTO DimTable.Country VALUES('Japan','JP','JPN')
INSERT INTO DimTable.Country VALUES('Jersey','JE','JEY')
INSERT INTO DimTable.Country VALUES('Jordan','JO','JOR')
INSERT INTO DimTable.Country VALUES('Kazakhstan','KZ','KAZ')
INSERT INTO DimTable.Country VALUES('Kenya','KE','KEN')
INSERT INTO DimTable.Country VALUES('Kiribati','KI','KIR')
INSERT INTO DimTable.Country VALUES('Korea (North)','KP','PRK')
INSERT INTO DimTable.Country VALUES('Korea (South)','KR','KOR')
INSERT INTO DimTable.Country VALUES('Kuwait','KW','KWT')
INSERT INTO DimTable.Country VALUES('Kyrgyzstan','KG','KGZ')
INSERT INTO DimTable.Country VALUES('Lao PDR','LA','LAO')
INSERT INTO DimTable.Country VALUES('Latvia','LV','LVA')
INSERT INTO DimTable.Country VALUES('Lebanon','LB','LBN')
INSERT INTO DimTable.Country VALUES('Lesotho','LS','LSO')
INSERT INTO DimTable.Country VALUES('Liberia','LR','LBR')
INSERT INTO DimTable.Country VALUES('Libya','LY','LBY')
INSERT INTO DimTable.Country VALUES('Liechtenstein','LI','LIE')
INSERT INTO DimTable.Country VALUES('Lithuania','LT','LTU')
INSERT INTO DimTable.Country VALUES('Luxembourg','LU','LUX')
INSERT INTO DimTable.Country VALUES('Macao, SAR China','MO','MAC')
INSERT INTO DimTable.Country VALUES('Macedonia, Republic of','MK','MKD')
INSERT INTO DimTable.Country VALUES('Madagascar','MG','MDG')
INSERT INTO DimTable.Country VALUES('Malawi','MW','MWI')
INSERT INTO DimTable.Country VALUES('Malaysia','MY','MYS')
INSERT INTO DimTable.Country VALUES('Maldives','MV','MDV')
INSERT INTO DimTable.Country VALUES('Mali','ML','MLI')
INSERT INTO DimTable.Country VALUES('Malta','MT','MLT')
INSERT INTO DimTable.Country VALUES('Marshall Islands','MH','MHL')
INSERT INTO DimTable.Country VALUES('Martinique','MQ','MTQ')
INSERT INTO DimTable.Country VALUES('Mauritania','MR','MRT')
INSERT INTO DimTable.Country VALUES('Mauritius','MU','MUS')
INSERT INTO DimTable.Country VALUES('Mayotte','YT','MYT')
INSERT INTO DimTable.Country VALUES('Mexico','MX','MEX')
INSERT INTO DimTable.Country VALUES('Micronesia, Federated States of','FM','FSM')
INSERT INTO DimTable.Country VALUES('Moldova','MD','MDA')
INSERT INTO DimTable.Country VALUES('Monaco','MC','MCO')
INSERT INTO DimTable.Country VALUES('Mongolia','MN','MNG')
INSERT INTO DimTable.Country VALUES('Montenegro','ME','MNE')
INSERT INTO DimTable.Country VALUES('Montserrat','MS','MSR')
INSERT INTO DimTable.Country VALUES('Morocco','MA','MAR')
INSERT INTO DimTable.Country VALUES('Mozambique','MZ','MOZ')
INSERT INTO DimTable.Country VALUES('Myanmar','MM','MMR')
INSERT INTO DimTable.Country VALUES('Namibia','NA','NAM')
INSERT INTO DimTable.Country VALUES('Nauru','NR','NRU')
INSERT INTO DimTable.Country VALUES('Nepal','NP','NPL')
INSERT INTO DimTable.Country VALUES('Netherlands','NL','NLD')
INSERT INTO DimTable.Country VALUES('Netherlands Antilles','AN','ANT')
INSERT INTO DimTable.Country VALUES('New Caledonia','NC','NCL')
INSERT INTO DimTable.Country VALUES('New Zealand','NZ','NZL')
INSERT INTO DimTable.Country VALUES('Nicaragua','NI','NIC')
INSERT INTO DimTable.Country VALUES('Niger','NE','NER')
INSERT INTO DimTable.Country VALUES('Nigeria','NG','NGA')
INSERT INTO DimTable.Country VALUES('Niue','NU','NIU')
INSERT INTO DimTable.Country VALUES('Norfolk Island','NF','NFK')
INSERT INTO DimTable.Country VALUES('Northern Mariana Islands','MP','MNP')
INSERT INTO DimTable.Country VALUES('Norway','NO','NOR')
INSERT INTO DimTable.Country VALUES('Oman','OM','OMN')
INSERT INTO DimTable.Country VALUES('Pakistan','PK','PAK')
INSERT INTO DimTable.Country VALUES('Palau','PW','PLW')
INSERT INTO DimTable.Country VALUES('Palestinian Territory','PS','PSE')
INSERT INTO DimTable.Country VALUES('Panama','PA','PAN')
INSERT INTO DimTable.Country VALUES('Papua New Guinea','PG','PNG')
INSERT INTO DimTable.Country VALUES('Paraguay','PY','PRY')
INSERT INTO DimTable.Country VALUES('Peru','PE','PER')
INSERT INTO DimTable.Country VALUES('Philippines','PH','PHL')
INSERT INTO DimTable.Country VALUES('Pitcairn','PN','PCN')
INSERT INTO DimTable.Country VALUES('Poland','PL','POL')
INSERT INTO DimTable.Country VALUES('Portugal','PT','PRT')
INSERT INTO DimTable.Country VALUES('Puerto Rico','PR','PRI')
INSERT INTO DimTable.Country VALUES('Qatar','QA','QAT')
INSERT INTO DimTable.Country VALUES('Réunion','RE','REU')
INSERT INTO DimTable.Country VALUES('Romania','RO','ROU')
INSERT INTO DimTable.Country VALUES('Russian Federation','RU','RUS')
INSERT INTO DimTable.Country VALUES('Rwanda','RW','RWA')
INSERT INTO DimTable.Country VALUES('Saint Helena','SH','SHN')
INSERT INTO DimTable.Country VALUES('Saint Kitts and Nevis','KN','KNA')
INSERT INTO DimTable.Country VALUES('Saint Lucia','LC','LCA')
INSERT INTO DimTable.Country VALUES('Saint Pierre and Miquelon','PM','SPM')
INSERT INTO DimTable.Country VALUES('Saint Vincent and Grenadines','VC','VCT')
INSERT INTO DimTable.Country VALUES('Saint-Barthélemy','BL','BLM')
INSERT INTO DimTable.Country VALUES('Saint-Martin (French part)','MF','MAF')
INSERT INTO DimTable.Country VALUES('Samoa','WS','WSM')
INSERT INTO DimTable.Country VALUES('San Marino','SM','SMR')
INSERT INTO DimTable.Country VALUES('Sao Tome and Principe','ST','STP')
INSERT INTO DimTable.Country VALUES('Saudi Arabia','SA','SAU')
INSERT INTO DimTable.Country VALUES('Senegal','SN','SEN')
INSERT INTO DimTable.Country VALUES('Serbia','RS','SRB')
INSERT INTO DimTable.Country VALUES('Seychelles','SC','SYC')
INSERT INTO DimTable.Country VALUES('Sierra Leone','SL','SLE')
INSERT INTO DimTable.Country VALUES('Singapore','SG','SGP')
INSERT INTO DimTable.Country VALUES('Slovakia','SK','SVK')
INSERT INTO DimTable.Country VALUES('Slovenia','SI','SVN')
INSERT INTO DimTable.Country VALUES('Solomon Islands','SB','SLB')
INSERT INTO DimTable.Country VALUES('Somalia','SO','SOM')
INSERT INTO DimTable.Country VALUES('South Africa','ZA','ZAF')
INSERT INTO DimTable.Country VALUES('South Georgia and the South Sandwich Islands','GS','SGS')
INSERT INTO DimTable.Country VALUES('South Sudan','SS','SSD')
INSERT INTO DimTable.Country VALUES('Spain','ES','ESP')
INSERT INTO DimTable.Country VALUES('Sri Lanka','LK','LKA')
INSERT INTO DimTable.Country VALUES('Sudan','SD','SDN')
INSERT INTO DimTable.Country VALUES('Suriname','SR','SUR')
INSERT INTO DimTable.Country VALUES('Svalbard and Jan Mayen Islands','SJ','SJM')
INSERT INTO DimTable.Country VALUES('Swaziland','SZ','SWZ')
INSERT INTO DimTable.Country VALUES('Sweden','SE','SWE')
INSERT INTO DimTable.Country VALUES('Switzerland','CH','CHE')
INSERT INTO DimTable.Country VALUES('Syrian Arab Republic (Syria)','SY','SYR')
INSERT INTO DimTable.Country VALUES('Taiwan, Republic of China','TW','TWN')
INSERT INTO DimTable.Country VALUES('Tajikistan','TJ','TJK')
INSERT INTO DimTable.Country VALUES('Tanzania, United Republic of','TZ','TZA')
INSERT INTO DimTable.Country VALUES('Thailand','TH','THA')
INSERT INTO DimTable.Country VALUES('Timor-Leste','TL','TLS')
INSERT INTO DimTable.Country VALUES('Togo','TG','TGO')
INSERT INTO DimTable.Country VALUES('Tokelau','TK','TKL')
INSERT INTO DimTable.Country VALUES('Tonga','TO','TON')
INSERT INTO DimTable.Country VALUES('Trinidad and Tobago','TT','TTO')
INSERT INTO DimTable.Country VALUES('Tunisia','TN','TUN')
INSERT INTO DimTable.Country VALUES('Turkey','TR','TUR')
INSERT INTO DimTable.Country VALUES('Turkmenistan','TM','TKM')
INSERT INTO DimTable.Country VALUES('Turks and Caicos Islands','TC','TCA')
INSERT INTO DimTable.Country VALUES('Tuvalu','TV','TUV')
INSERT INTO DimTable.Country VALUES('Uganda','UG','UGA')
INSERT INTO DimTable.Country VALUES('Ukraine','UA','UKR')
INSERT INTO DimTable.Country VALUES('United Arab Emirates','AE','ARE')
INSERT INTO DimTable.Country VALUES('United Kingdom','GB','GBR')
INSERT INTO DimTable.Country VALUES('United States','US','USA')
INSERT INTO DimTable.Country VALUES('Uruguay','UY','URY')
INSERT INTO DimTable.Country VALUES('US Minor Outlying Islands','UM','UMI')
INSERT INTO DimTable.Country VALUES('Uzbekistan','UZ','UZB')
INSERT INTO DimTable.Country VALUES('Vanuatu','VU','VUT')
INSERT INTO DimTable.Country VALUES('Venezuela (Bolivarian Republic)','VE','VEN')
INSERT INTO DimTable.Country VALUES('Viet Nam','VN','VNM')
INSERT INTO DimTable.Country VALUES('Virgin Islands, US','VI','VIR')
INSERT INTO DimTable.Country VALUES('Wallis and Futuna Islands','WF','WLF')
INSERT INTO DimTable.Country VALUES('Western Sahara','EH','ESH')
INSERT INTO DimTable.Country VALUES('Yemen','YE','YEM')
INSERT INTO DimTable.Country VALUES('Zambia','ZM','ZMB')
INSERT INTO DimTable.Country VALUES('Zimbabwe','ZW','ZWE')
GO

/**********/
/* STEP 3 */
/**********/

/*********/
/* STORE */
/*********/

TRUNCATE TABLE DimTable.Store
GO

INSERT INTO DimTable.Store
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

SELECT * FROM DimTable.Store
GO

/**********/
/* STEP 4 */
/**********/

/*****************/
/* LOAD CUSTOMER */
/*****************/

/***************************************************/
/* NOTE:                                           */
/* A CUSTOMER IS ACTUALLY A SALESPERSON IN A STORE */
/***************************************************/

TRUNCATE TABLE DimTable.Customer
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

INSERT INTO DimTable.Customer
SELECT 'C0000000',F.FName + ' ' + L.Lname,F.FName,L.Lname,NULL
FROM @FirstName F
CROSS JOIN @Lastname L
GO

UPDATE DimTable.Customer
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

SELECT * FROM DimTable.Customer
GO

-- need to assign customers (sales persons) to stores

UPDATE DimTable.Customer
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

/**********/
/* STEP 5 */
/**********/

/********************/
/* PRODUCT CATEGORY */
/********************/

TRUNCATE TABLE [DimTable].[ProductCategory]
GO

INSERT INTO [DimTable].[ProductCategory]
VALUES
	('PC001','Chocolates'),
	('PC002','Cakes'),
	('PC003','Pies'),
	('PC004','Croissants'),
	('PC005','Tarts');
GO

/**********/
/* STEP 6 */
/**********/

/***********************/
/* PRODUCT SUBCATEGORY */
/***********************/

TRUNCATE TABLE [DimTable].[ProductSubCategory]
GO

INSERT INTO [DimTable].[ProductSubCategory]
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

INSERT INTO [DimTable].[ProductSubCategory]
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

INSERT INTO [DimTable].[ProductSubCategory]
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
FROM [DimTable].[ProductSubCategory]
ORDER BY 1,2,3
GO

/**********/
/* STEP 7 */
/**********/

/****************/
/* LOAD PRODUCT */
/****************/

TRUNCATE TABLE [DimTable].[Product]
GO

INSERT INTO [DimTable].[Product]
SELECT DISTINCT 'P00000',
	PSC.[ProductSubCategoryName],
	PSC.[ProductCategoryCode],
	PSC.[ProductSubCategoryCode],
	000.00,
	000.00
FROM [DimTable].[ProductCategory] PC
JOIN [DimTable].[ProductSubCategory] PSC
ON PC.ProductCategoryCode = PSC.ProductCategoryCode
ORDER BY 1,2,3
GO

UPDATE [DimTable].[Product]
SET [ProductNo] = [ProductNo] 
	+ RIGHT([ProductCategoryCode],2)
	+ RIGHT([ProductSubCategoryCode],2)
	+ CONVERT(VARCHAR,ProductKey);
GO

-- old
UPDATE [DimTable].[Product]
SET [ProductWholeSalePrice] =
CASE	
	WHEN [ProductName] LIKE '%Large%' THEN 35.00
	WHEN [ProductName] LIKE '%Medium%' THEN 25.00
	WHEN [ProductName] LIKE '%Small%' THEN 15.00
END
GO

-- new
UPDATE [DimTable].[Product]
SET [ProductWholeSalePrice] =
CASE	
	WHEN [ProductName] LIKE '%Large%' THEN 15.00
	WHEN [ProductName] LIKE '%Medium%' THEN 10.00
	WHEN [ProductName] LIKE '%Small%' THEN 7.50
END
GO

-- new set retail price as 25% markup
UPDATE [DimTable].[Product]
SET [ProductRetailPrice] = [ProductWholeSalePrice] * 1.10
GO

-- set retail price as 25% markup
UPDATE [DimTable].[Product]
SET [ProductRetailPrice] = [ProductWholeSalePrice] * 1.25
GO

/**********/
/* STEP 8 */
/**********/

/********************************/
/* LOAD SALES TRANSACTION TABLE */
/********************************/

-- ran approx 57 seconds
-- generated 11,904,000 row
-- backup DB and dump log after running this!

/*
DROP TABLE IF EXISTS [StagingTable].[SalesTransaction]
GO
*/

TRUNCATE TABLE [StagingTable].[SalesTransaction]
GO

INSERT INTO [StagingTable].[SalesTransaction]
SELECT C.[CountryName]
      ,C.[ISO2CountryCode]
      ,C.[ISO3CountryCode]
	  ,CU.[CustomerNo]
	  ,CU.[StoreNo]
	  ,CAL.CalendarDate
	  ,P.ProductCategoryCode
	  ,P.ProductSubCategoryCode
	  ,P.ProductNo

	   ,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	50) AS [TransactionQuantity]


	  ,P.ProductRetailPrice AS [UnitRetailPrice]
	  ,P.ProductWholeSalePrice
	  ,P.ProductRetailPrice * .08 AS [UnitSalesTaxAmount]
	  ,0.0 AS [TotalSalesAmount]
--INTO [StagingTable].[SalesTransaction]
FROM [DimTable].[Country] C          WITH (NOLOCK)
CROSS JOIN DimTable.Customer CU      WITH (NOLOCK)
--CROSS JOIN DimTable.Store S          WITH (NOLOCK)
CROSS JOIN [DimTable].[Calendar] CAL WITH (NOLOCK)
--CROSS JOIN [DimTable].[Product] P    WITH (NOLOCK)
JOIN (
SELECT CFP.[CustomerNo],
	P.[ProductNo], 
	P.[ProductName], 
	P.[ProductCategoryCode], 
	P.[ProductSubCategoryCode], 
	P.[ProductWholeSalePrice],
	P.[ProductRetailPrice]
FROM [APSales].[StagingTable].[CustomerFavoriteProductSubCategories] CFP
JOIN [DimTable].[Product] P
ON CFP.ProductSubCategoryCode = P.ProductSubCategoryCode
) P
ON CU.CustomerNo = P.CustomerNo
WHERE C.[CountryName] LIKE '%United States%'
AND CAL.CalendarDate BETWEEN '1/1/2002' AND '12/31/2022'
AND DAY(CAL.[CalendarDate]) IN (28,29,30,31) -- days orders entered
GO

UPDATE [StagingTable].[SalesTransaction]
SET [TransactionQuantity] = 1
WHERE TransactionQuantity = 0
GO

UPDATE [StagingTable].[SalesTransaction]
SET [TotalSalesAmount] = ([TransactionQuantity] * [UnitRetailPrice])
GO

/**********/
/* STEP 9 */
/**********/

/***********************************************************************************/
/* change the physical file patch in case your machine has a different disk layout */
/***********************************************************************************/

BACKUP LOG [APSales]
TO  DISK = N'D:\APRESS_DATABASES\AP_SALES_BACKUP\AP_SALES_BAKUP.LOG' 
WITH NOFORMAT,INIT,  
NAME = N'AP_SALES-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  
STATS = 10
GO

/***********/
/* STEP 10 */
/***********/

/*************************/
/* LOAD SALES FACT TABLE */
/*************************/

-- now we need to LOAD the fact table with
-- the transactions
-- took 6 min, 25 sec

/*************/
/* STEP 10.1 */
/*************/


-- create some indexes to speed things up

DROP INDEX IF EXISTS [StagingTable].ieFactCalendarDate
GO

CREATE INDEX ieFactCalendarDate ON
 [StagingTable].[SalesTransaction](
	[CalendarDate])
ON AP_SALES_FG
GO

/*************/
/* STEP 10.2 */
/*************/

DROP INDEX IF EXISTS [StagingTable].ieSalesCalendarDate
GO

CREATE UNIQUE INDEX ieSalesCalendarDate ON
 [DimTable].[Calendar]([CalendarDate])
ON AP_SALES_FG
GO

TRUNCATE TABLE [FactTable].[Sales]
GO

/*************/
/* STEP 10.3 */
/*************/

/*******************/
/* LOAD FACT TABLE */
/*******************/

/*
DROP TABLE IF EXISTS [FactTable].[Sales]
GO
*/

/*****************************************************/
/* 1 minute, 33 seconds to LOAD if SELECT/INTO used. */
/*****************************************************/

TRUNCATE TABLE [FactTable].[Sales]
GO

INSERT INTO [FactTable].[Sales]
SELECT DISTINCT Cust.[CustomerKey]
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
--INTO [FactTable].[Sales]
FROM [StagingTable].[SalesTransaction] St
	JOIN DimTable.Customer Cust WITH (NOLOCK)
ON ST.[CustomerNo] = Cust.CustomerNo
	JOIN [DimTable].[Calendar] Cal WITH (NOLOCK)
ON Cal.[CalendarDate] = St.[CalendarDate]
	JOIN [DimTable].[Product] P WITH (NOLOCK)
ON P.ProductNo = St.[ProductNo]
	JOIN DimTable.Country C WITH (NOLOCK)
ON C.CountryName = St.[CountryName]
	JOIN DimTable.Store S WITH (NOLOCK)
ON S.StoreNo = ST.[StoreNo]
GO

/*************/
/* STEP 10.4 */
/*************/

-- this does not work
DROP INDEX IF EXISTS [FactTable].[Sales]
GO

-- this works!
DROP INDEX [ieSalesFact] ON [FactTable].[Sales] WITH ( ONLINE = OFF )
GO

CREATE CLUSTERED INDEX ieSalesFact ON
[FactTable].[Sales](
	[CustomerKey],
	[ProductKey],
	[CountryKey],
	[StoreKey],
	[CalendarKey]
) ON AP_SALES_FG
GO

-- check for duplicates

SELECT distinct [CustomerKey], [ProductKey], [CountryKey], [StoreKey], [CalendarKey], 
[TransactionQuantity], [TotalSalesAmount], [UnitSalesTaxAmount], [TotalSalesAmount],count(*)
FROM [FactTable].[Sales] WITH (NOLOCK)
GROUP BY [CustomerKey], [ProductKey], [CountryKey], [StoreKey], [CalendarKey], 
[TransactionQuantity], [TotalSalesAmount], [UnitSalesTaxAmount], [TotalSalesAmount]
HAVING count(*) > 1
GO

/***********/
/* STEP 11 */
/***********/

/*******************************************/
/* BACKUP AND TRUNCATE THE TRANSACTION LOG */
/*******************************************/

/***********************************************************************************/
/* change the physical file patch in case your machine has a different disk layout */
/***********************************************************************************/

BACKUP LOG [APSales]
TO  DISK = N'D:\APRESS_DATABASES\AP_SALES_BACKUP\AP_SALES_BAKUP.LOG' 
WITH NOFORMAT,INIT,  
NAME = N'AP_SALES-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  
STATS = 10
GO

/***********/
/* STEP 12 */
/***********/

/****************************/
/* Load Yearly Sales Report */
/****************************/

TRUNCATE TABLE [SalesReports].[YearlySalesReport]
GO

INSERT INTO [SalesReports].[YearlySalesReport]
SELECT DISTINCT C.CustomerFullName
    ,ST.[ProductNo]
	,P.ProductName
    ,ST.[ProductCategoryCode]
    ,ST.[ProductSubCategoryCode]
	,PC.ProductCategoryName
	,PSC.ProductSubCategoryName
    ,ST.[ISO3CountryCode]
    ,ST.[StoreNo]
	,S.StoreName
	,S.StoreTerritory
    ,ST.[CalendarDate]
    ,ST.[TransactionQuantity]
    ,ST.[ProductWholeSalePrice]
	,ST.[UnitRetailPrice]
    ,ST.[UnitSalesTaxAmount]
	,(ST.[TransactionQuantity] * ST.[ProductWholeSalePrice]) AS [TotalWholeSaleAmount]
    ,ST.[TotalSalesAmount]
  FROM [APSales].[StagingTable].[SalesTransaction] ST
  JOIN [DimTable].[Customer] C
  ON ST.CustomerNo = C.CustomerNo
  JOIN [DimTable].[Product] P
  ON ST.ProductNo = P.ProductNo
  JOIN [DimTable].[ProductCategory] PC
  ON ST.ProductCategoryCode = PC.ProductCategoryCode
  JOIN [DimTable].[ProductSubCategory] PSC
  ON ST.ProductSubCategoryCode = PSC.ProductSubCategoryCode
  JOIN [DimTable].[Store] S
  ON ST.StoreNo = S.StoreNo
  GO

/***********/
/* STEP 13 */
/***********/

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
FROM [FactTable].[Sales] FS WITH (NOLOCK)
JOIN DimTable.Country C WITH (NOLOCK)
ON C.[CountryKey] = FS.[CountryKey]
JOIN DimTable.Customer CU WITH (NOLOCK)
ON CU.[CustomerKey] = FS.[CustomerKey]
JOIN DimTable.Store S WITH (NOLOCK)
ON S.[StoreKey] = FS.[StoreKey]
JOIN [DimTable].[Calendar] CAL WITH (NOLOCK)
ON CAL.[CalendarKey] = FS.[CalendarKey]
JOIN [DimTable].[Product] P WITH (NOLOCK)
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

/***********/
/* STEP 14 */
/***********/

/***********************/
/* CREATE MORE INDEXES */
/***********************/

DROP INDEX IF EXISTS FactTable.pkFactSales
GO

CREATE INDEX pkFactSales ON
 FactTable.Sales (
	[CalendarKey],[CountryKey],[CustomerKey],[ProductKey],[StoreKey])
ON AP_SALES_FG
GO

DROP INDEX IF EXISTS DimTable.akSalesCalendarKey
GO

DROP INDEX [akSalesCalendarKey] ON [DimTable].[Calendar]
GO


CREATE UNIQUE INDEX akSalesCalendarKey ON
 DimTable.[Calendar]
	(CalendarKey)
ON AP_SALES_FG
GO

/***********/
/* STEP 15 */
/***********/

-- Execute "Display Estimated Execution Plan"

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
FROM FactTable.[Sales] FS
	JOIN DimTable.Country C
		ON C.[CountryKey] = FS.[CountryKey]
	JOIN DimTable.Customer CU
		ON CU.[CustomerKey] = FS.[CustomerKey]
	JOIN DimTable.Store S
		ON S.[StoreKey] = FS.[StoreKey]
	JOIN DimTable.[Calendar] CAL
		ON CAL.[CalendarKey] = FS.[CalendarKey]
	JOIN DimTable.[Product] P
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

/***********/
/* STEP 16 */
/***********/

/****************/
/* DEMOGRAPHICS */
/****************/

/*************/
/* STEP 16.1 */
/*************/

DROP SCHEMA IF EXISTS Demographics
GO

CREATE SCHEMA Demographics
GO

DROP TABLE IF EXISTS  Demographics.CustomerPaymentHistory
GO

CREATE TABLE Demographics.CustomerPaymentHistory
(
[CreditYear]			 SMALLINT NOT NULL,
[CreditQtr]				 SMALLINT,
[CustomerKey]			 INT NOT NULL,
[CustomerNo]             NVARCHAR(32) NOT NULL,
[CustomerFullName]		 NVARCHAR(256) NOT NULL,
[TotalPaymentsTodate]	 INTEGER NOT NULL,
[30DaysLatePaymentCount] INTEGER NOT NULL,
[60DaysLatePaymentCount] INTEGER NOT NULL,
[90DaysLatePaymentCount] INTEGER NOT NULL,
[Over90DaysLatePaymentCount] INTEGER NOT NULL
)
GO

/*************/
/* STEP 16.2 */
/*************/

/***********************************************/
/* LOAD CUSTOMER PAYMENT HISTORY FOR YEAR 2010 */
/***********************************************/

TRUNCATE TABLE Demographics.CustomerPaymentHistory
GO

INSERT INTO Demographics.CustomerPaymentHistory
SELECT 2010,1,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
UNION ALL
SELECT 2010,2,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
SELECT 2010,3,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
SELECT 2010,4,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
GO

/*************/
/* STEP 16.3 */
/*************/

/***********************************************/
/* LOAD CUSTOMER PAYMENT HISTORY FOR YEAR 2011 */
/***********************************************/

INSERT INTO Demographics.CustomerPaymentHistory
SELECT 2011,1,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
UNION ALL
SELECT 2011,2,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
SELECT 2011,3,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
SELECT 2011,4,[CustomerKey],
	[CustomerNo],
	[CustomerFullName],
	100,0,0,0,0
FROM [DimTable].[Customer]
GO

/*************/
/* STEP 16.4 */
/*************/

/***********************************************/
/* GENERATE DELINQUENT LATE PAYMENT STATISTICS */
/***********************************************/

/************/
/* FOR 2010 */
/************/

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 0,
[60DaysLatePaymentCount] = 0,
[90DaysLatePaymentCount] = 0,
[Over90DaysLatePaymentCount] = 0
WHERE [CustomerKey] BETWEEN 1 and 20
AND [CreditYear] = 2010
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 10,
[60DaysLatePaymentCount] = 5,
[90DaysLatePaymentCount] = 1,
[Over90DaysLatePaymentCount] = 0
WHERE [CustomerKey] BETWEEN 21 and 40
AND [CreditYear] = 2010
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 20,
[60DaysLatePaymentCount] = 10,
[90DaysLatePaymentCount] = 5,
[Over90DaysLatePaymentCount] = 0
WHERE [CustomerKey] BETWEEN 41 and 60
AND [CreditYear] = 2010
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 30,
[60DaysLatePaymentCount] = 20,
[90DaysLatePaymentCount] = 10,
[Over90DaysLatePaymentCount] = 5
WHERE [CustomerKey] BETWEEN 61 and 80
AND [CreditYear] = 2010
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 40,
[60DaysLatePaymentCount] = 25,
[90DaysLatePaymentCount] = 20,
[Over90DaysLatePaymentCount] = 10
WHERE [CustomerKey] BETWEEN 81 and 100
AND [CreditYear] = 2010
GO

/************/
/* FOR 2011 */
/************/

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 3,
[60DaysLatePaymentCount] = 0,
[90DaysLatePaymentCount] = 0,
[Over90DaysLatePaymentCount] = 0
WHERE [CustomerKey] BETWEEN 1 and 20
AND [CreditYear] = 2011
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 15,
[60DaysLatePaymentCount] = 5,
[90DaysLatePaymentCount] = 10,
[Over90DaysLatePaymentCount] = 20
WHERE [CustomerKey] BETWEEN 21 and 40
AND [CreditYear] = 2011
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 20,
[60DaysLatePaymentCount] = 14,
[90DaysLatePaymentCount] = 15,
[Over90DaysLatePaymentCount] = 10
WHERE [CustomerKey] BETWEEN 41 and 60
AND [CreditYear] = 2011
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 20,
[60DaysLatePaymentCount] = 20,
[90DaysLatePaymentCount] = 5,
[Over90DaysLatePaymentCount] = 15
WHERE [CustomerKey] BETWEEN 61 and 80
AND [CreditYear] = 2011
GO

UPDATE Demographics.CustomerPaymentHistory
SET [30DaysLatePaymentCount] = 45,
[60DaysLatePaymentCount] = 5,
[90DaysLatePaymentCount] = 10,
[Over90DaysLatePaymentCount] = 2
WHERE [CustomerKey] BETWEEN 81 and 100
AND [CreditYear] = 2011
GO


