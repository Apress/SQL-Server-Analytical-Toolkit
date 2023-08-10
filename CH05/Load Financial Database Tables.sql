/*****************************************/
/* Chapter 05,06,07 - APFinance Database */
/* Load Tables                           */
/* Created: 08/19/2022                   */
/* Modified: 07/19/2023                  */
/* Production                            */
/*****************************************/

/************************/
/* APFinance Database   */
/************************/

USE [APFinance]
GO

SET NOCOUNT ON
GO

/*****************************************/
/* Chapter 05,06,07 - APFinance Database */
/* Load Tables                           */
/* Created: 08/19/2022                   */
/* Modified: 07/18/2023                  */
/*****************************************/

/******************/
/* TICKER SYMBOLS */
/******************/

TRUNCATE TABLE [Financial].[TickerSymbols]
GO
 
 INSERT INTO [Financial].[TickerSymbols]
    VALUES 
	-- EQUITIES/STOCKS
	('AA','Alcoa','TT00002'), 
    ('AAL','American Airlines Group','TT00002'), 
    ('BSBR','Banco Santander Brasil','TT00002'), 
    ('GPL','Great Panther Mining','TT00002'), 
    ('GP','GreenPower Motor Company','TT00002'), 
    ('GPOR','Gulfport Energy','TT00002'),
	-- FX - Foreign Exchange
	('EURO','European Euro','TT00004'), 
    ('GBP','British Pound','TT00004'), 
    ('INR','Indian Rupee','TT00004'), 
    ('JPY','Japanese Yen','TT00004'), 
    ('SEK','Swedish Krona','TT00004'), 
	-- COMMODITIES FUTURES
	('GC=F','Gold','TT00006'), 
    ('SI=F','Silver','TT00006'), 
    ('HG=F','Copper','TT00006'), 
    ('CL=F','Crude Oil','TT00006'), 
    ('PL=F','Platinum','TT00006'), 
    ('CC=F','Cocoa','TT00006'), 
	-- CASH - MONEY MARKET
	('JPST','JPMorgan Ultra-Short Income ETF','TT00001'), 
    ('LDSF','First Trust Low Duration Strategic Focus ETF','TT00001'), 
    ('MUST','Columbia Multi-Sector Municipal Income ETF','TT00001'), 
    ('LSAT','Leadshares Alphafactor Tactical Focused ETF','TT00001'), 
    ('ARCM','Arrow Reserve Capitol Management ETF','TT00001'), 
    ('SPCX','SPAC and New Issue ETF','TT00001'), 
	('BOB','Merlyn.AI Dest-of-Breed Core Momentum ETF','TT00001'), 

	-- CASH - CHECKING
	('CHECKING','Customer Checking Account','TT00001'),

	-- INTEREST RATE SWAPS
	('USDSB3L2Y=','USD 2 Years Interest Rate Swap','TT00005'), 
    ('SWAADY10.RT','I/R Swap 10 - Year','TT00005'), 
    ('LIBOR OIS','LIBOR Overnight Index Swap','TT00005'), 
    ('SJB','ProShares Short High Yield','TT00005'), 
    ('SGOV','iShares 0-3 Month Treasury Bond ETF','TT00005'), 
    ('MARB','First Trust Merger Arbitrage ETF','TT00005'), 
	('RRH','Advocate Rising Rate Hedge ETF','TT00005'),
	-- OPTIONS (Last Price, Strike Price, Bid, Ask, Change,Volatility
	('PG111022C00060000','PG - Proctor & Gmble','TT00003'),
	('SPX141122P00019500','SPX - Standard & Poors 500','TT00003'),
	('LAMR150117C00052500','LAMR - Lamar Advertising Company','TT00003'),
	('AAPL131101C00470000','AAPL - Apple','TT00003'),
	('MSFT220422C0016000','MSFT - Microsoft Corporation','TT00003');
	GO

SELECT * FROM [Financial].[TickerSymbols]
GO

/********************/
/* TRANSACTION TYPE */
/********************/

TRUNCATE TABLE [MasterData].[TransactionType]
GO

INSERT INTO [MasterData].[TransactionType]
VALUES 
	('TT00001','CASH'),
	('TT00002','EQUITY'),
	('TT00003','OPTION'),
	('TT00004','FX'),
	('TT00005','SWAP'),
	('TT00006','COMMODITY');
GO

SELECT * FROM [MasterData].[TransactionType]
GO

/**************************/
/* PORTFOLIO_ACCOUNT_TYPE */
/**************************/

TRUNCATE TABLE [MasterData].[PortfolioAccountType]
GO

INSERT INTO [MasterData].[PortfolioAccountType]
(PortfolioAccountTypeCode,PortfolioAccountTypeName)
VALUES
('P01','CASH - FINANCIAL PORTFOLIO'),
('P02','EQUITY - FINANCIAL PORTFOLIO'),
('P03','OPTION - FINANCIAL PORTFOLIO'),
('P04','FX - FINANCIAL PORTFOLIO'),
('P05','SWAP - FINANCIAL PORTFOLIO'),
('P06','COMMODITY - FINANCIAL PORTFOLIO');
GO

/****************************/
/* TRANSACTION_ACCOUNT_TYPE */
/****************************/

/**************/
/* LINK TABLE */
/**************/

TRUNCATE TABLE [MasterData].[TransactionAccountType]
GO

INSERT INTO [MasterData].[TransactionAccountType]
VALUES 
	('TT00001','AT00001','CASH'),
	('TT00002','AT00002','EQUITY'),
	('TT00003','AT00003','OPTION'),
	('TT00004','AT00004','FX'),
	('TT00005','AT00005','SWAP'),
	('TT00006','AT00006','COMMODITY');
GO

SELECT * FROM [MasterData].[TransactionAccountType]
GO

/****************/
/* ACCOUNT TYPE */
/****************/

TRUNCATE TABLE [MasterData].[AccountType]
GO

INSERT INTO [MasterData].[AccountType]
VALUES 
	('AT00001','CASH'),
	('AT00002','EQUITY'),
	('AT00003','OPTION'),
	('AT00004','FX'),
	('AT00005','SWAP'),
	('AT00006','COMMODITY');
GO

SELECT * FROM [MasterData].[AccountType]
GO

/***********/
/* ACCOUNT */
/***********/

-- INITIAL DEPOSITS

TRUNCATE TABLE  [Financial].[Account]
GO

INSERT INTO  [Financial].[Account]
VALUES
-- CASH
('C0000001','P01C1','A01C1','CASH ACCOUNT','AT00001',100000.00,'2011-12-31'),
('C0000002','P01C2','A01C2','CASH ACCOUNT','AT00001',100000.00,'2011-12-31'),
('C0000003','P01C3','A01C3','CASH ACCOUNT','AT00001',100000.00,'2011-12-31'),
('C0000004','P01C4','A01C4','CASH ACCOUNT','AT00001',100000.00,'2011-12-31'),
('C0000005','P01C5','A01C5','CASH ACCOUNT','AT00001',100000.00,'2011-12-31'),
-- EQUITY
('C0000001','P01C1','A02C1','EQUITY ACCOUNT','AT00002',100000.00,'2011-12-31'),
('C0000002','P01C2','A02C2','EQUITY ACCOUNT','AT00002',100000.00,'2011-12-31'),
('C0000003','P01C3','A02C3','EQUITY ACCOUNT','AT00002',100000.00,'2011-12-31'),
('C0000004','P01C4','A02C4','EQUITY ACCOUNT','AT00002',100000.00,'2011-12-31'),
('C0000005','P01C5','A02C5','EQUITY ACCOUNT','AT00002',100000.00,'2011-12-31'),
-- OPTION
('C0000001','P01C1','A03C1','OPTION ACCOUNT','AT00003',100000.00,'2011-12-31'),
('C0000002','P01C2','A03C2','OPTION ACCOUNT','AT00003',100000.00,'2011-12-31'),
('C0000003','P01C3','A03C3','OPTION ACCOUNT','AT00003',100000.00,'2011-12-31'),
('C0000004','P01C4','A03C4','OPTION ACCOUNT','AT00003',100000.00,'2011-12-31'),
('C0000005','P01C5','A03C5','OPTION ACCOUNT','AT00003',100000.00,'2011-12-31'),
-- FX
('C0000001','P01C1','A04C1','FX ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000002','P01C2','A04C2','FX ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000003','P01C3','A04C3','FX ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000004','P01C4','A04C4','FX ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000005','P01C5','A04C5','FX ACCOUNT','AT00004',100000.00,'2011-12-31'),
-- SWAP
('C0000001','P01C1','A05C1','SWAP ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000002','P01C2','A05C2','SWAP ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000003','P01C3','A05C3','SWAP ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000004','P01C4','A05C4','SWAP ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000005','P01C5','A05C5','SWAP ACCOUNT','AT00005',100000.00,'2011-12-31'),
-- COMMODITY
('C0000001','P01C1','A06C1','COMMODITY ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000002','P01C2','A06C2','COMMODITY ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000003','P01C3','A06C3','COMMODITY ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000004','P01C4','A06C4','COMMODITY ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000005','P01C5','A06C5','COMMODITY ACCOUNT','AT00006',100000.00,'2011-12-31');
GO

SELECT * FROM [Financial].[Account]
GO

/*************/
/* PORTFOLIO */
/*************/

-- initial first load

TRUNCATE TABLE [Financial].[Portfolio]
GO

INSERT INTO [Financial].[Portfolio]
VALUES
(2011,12,'C0000001','P01C1','P01','CASH - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000002','P01C2','P01','CASH - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000003','P01C3','P01','CASH - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000004','P01C4','P01','CASH - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000005','P01C5','P01','CASH - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000001','P01C1','P02','EQUITY - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000002','P01C2','P02','EQUITY - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000003','P01C3','P02','EQUITY - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000004','P01C4','P02','EQUITY - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31'),
(2011,12,'C0000005','P01C5','P02','EQUITY - FINANCIAL PORTFOLIO',100000.00,0.0,'2011-12-31');
GO

SELECT * FROM [Financial].[Portfolio]
GO

/************/
/* CUSTOMER */
/************/

TRUNCATE TABLE [MasterData].[Customer]
GO

INSERT INTO [MasterData].[Customer]
VALUES
('C0000001','Smith','John',250000.00,'150K - 250K'),
('C0000002','Brown','Karen',125000.00,'100K - 150K'),
('C0000003','Carruthers','Sherlock',550000.00,'500K - 1000K'),
('C0000004','Balducci','Mario',750000.00,'500K - 1000K'),
('C0000005','Escargot','Pierre',250000.00,'150K - 250K');
GO

SELECT * FROM [MasterData].[Customer]
GO

/************/
/* CALENDAR */
/************/

-- Note: text quarter and month values will be loaded in query script

SET NOCOUNT ON
GO

TRUNCATE TABLE [MasterData].[Calendar]
GO

DECLARE @StartDate DATE;
DECLARE @StopDate DATE;
DECLARE @CurrentDate DATE;

SET @StartDate = '01/01/2012'
SET @StopDate = '12/31/2015'

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
	@CurrentDate,
	NULL,NULL
);

SET @CurrentDate = DATEADD(dd,1,@CurrentDate);
END
GO

SELECT * FROM [MasterData].[Calendar]
GO

SET NOCOUNT OFF
GO

/****************************/
/* CUSTOMER TICKER SYMBOLS */
/***************************/

TRUNCATE TABLE [MasterData].[CustomerTickerSymbols]
GO

INSERT INTO [MasterData].[CustomerTickerSymbols]
SELECT C.[CustId],T.Symbol,[TransactionTypeCode],'Y' AS CustTradesInFlag
FROM [MasterData].[Customer] C
CROSS JOIN [Financial].[TickerSymbols] T
GO

UPDATE [MasterData].[CustomerTickerSymbols]
SET [CustTradesInFlag] = (
	CASE
	WHEN [CustId] = 'C0000001' AND [CustSymbolKey] % 2 = 0 THEN 'N'
	WHEN [CustId] = 'C0000002' AND [CustSymbolKey] % 3 = 0 THEN 'N'
	WHEN [CustId] = 'C0000003' AND [CustSymbolKey] % 4 = 0 THEN 'N'
	WHEN [CustId] = 'C0000004' AND [CustSymbolKey] % 5 = 0 THEN 'N'
	WHEN [CustId] = 'C0000005' AND [CustSymbolKey] % 6 = 0 THEN 'N'
	WHEN Symbol = 'CHECKING' THEN 'Y'
	ELSE 'Y'
	END )
GO

SELECT * 
FROM [MasterData].[CustomerTickerSymbols]
ORDER BY [CustId], 
	[Symbol]
GO

/******************************/
/* TICKER PRICE RANGE HISTORY */
/******************************/

DROP TABLE IF EXISTS #TickerLowHi
GO

WITH TickerCTE (Ticker,Company,TickerDate,[Low])
AS (
SELECT TS.Symbol AS [Ticker]
      ,TS.Name AS [Company]
      ,C.[CalendarDate] AS [TickerDate]
      ,	UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10.00) + 100.00 AS  [Low]
  FROM [Financial].[TickerSymbols] TS
  CROSS JOIN [MasterData].[Calendar] C
  )

  SELECT Ticker,
	Company,
	TickerDate,
	[Low],
	[Low] + UPPER (CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10.00) AS [High]
INTO #TickerLowHi
FROM TickerCTE;

INSERT INTO [MasterData].[TickerPriceRangeHistory]
SELECT Ticker,
	Company,
	TickerDate,
	[Low],
	CASE
		WHEN [High] < [Low] THEN [Low]
	ELSE [High]
	END AS [High],
	(
	CASE
		WHEN [High] < [Low] THEN [Low]
	ELSE [High]
	END 
	) - [Low] AS Spread
FROM #TickerLowHi;

DROP TABLE IF EXISTS #TickerLowHi
GO

SELECT * FROM [MasterData].[TickerPriceRangeHistory]
ORDER BY [Ticker],[TickerDate]
GO

/*************************************/
/* TICKER PRICE RANGE HISTORY DETAIL */
/*************************************/

TRUNCATE TABLE [MasterData].[TickerPriceRangeHistoryDetail]
GO

INSERT INTO [MasterData].[TickerPriceRangeHistoryDetail]
SELECT YEAR([TickerDate]) AS QuoteYear
	,DATEPART(qq,[TickerDate]) AS QuoteQtr
	,DATEPART(mm,[TickerDate]) AS QuoteMonth
	,DATEPART(ww,[TickerDate]) AS QuoteWeek
	,[TickerDate]
	,[Ticker]
    ,[Company]
    ,[Low]
    ,[High]
    ,[Spread]
FROM [MasterData].[TickerPriceRangeHistory]
GO

/******************/
/* TICKER HISTORY */
/******************/

DECLARE @Hour TABLE (QuoteHour SMALLINT);

INSERT INTO @Hour VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24);


INSERT INTO [MasterData].[TickerHistory]
SELECT [Ticker]
    ,[Company]
	,[TickerDate]
	,QuoteHour
    ,UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10.00) + 100.00 
FROM [MasterData].[TickerPriceRangeHistoryDetail]
CROSS JOIN @Hour
ORDER BY [Ticker]
    ,[Company]
	,[TickerDate]
	,QuoteHour
GO

/***************/
/* TRANSACTION */
/***************/

SET NOCOUNT ON
GO

TRUNCATE TABLE [Financial].[Transaction]
GO

INSERT INTO [Financial].[Transaction]
SELECT
	Cal.[CalendarDate] AS [TransDate],
	S.[Symbol]		   AS [Symbol],
	UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10.00) + 100.00 AS [Price],
	ROUND(UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10.00),0) AS [Quantity],
	0.00 AS [TransAmount],
	Prtfl.CustId,
	Prtfl.PrtfNo,
	Prtfl.AcctTypeCode,
	Prtfl.AcctNo,
	CASE
		WHEN Prtfl.AcctTypeCode = 'AT00001' THEN 'C' -- credit account
	ELSE 'B' 
	END AS [BuySell],
	S.TransactionTypeCode
FROM [MasterData].[Calendar] Cal WITH (NOLOCK)
CROSS JOIN (
	SELECT DISTINCT [CustId],[PrtfNo],[AcctNo],[AcctTypeCode]
	FROM [Financial].[Account] WITH (NOLOCK)
	) Prtfl
JOIN [MasterData].[CustomerTickerSymbols] S WITH (NOLOCK)
ON (
Prtfl.AcctTypeCode = REPLACE(S.[TransactionTypeCode],'TT','AT')
AND Prtfl.CustId = S.CustId
AND S.[CustTradesInFlag] = 'Y'
)
WHERE Prtfl.AcctTypeCode = REPLACE(S.[TransactionTypeCode],'TT','AT')
ORDER BY Cal.[CalendarDate]
GO

INSERT INTO [Financial].[Transaction]
SELECT
	Cal.[CalendarDate] AS [TransDate],
	S.[Symbol]		   AS [Symbol],
	UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10.00) + 100.00 AS [Price],
	ROUND(UPPER (
		CONVERT(INT,CRYPT_GEN_RANDOM(1)
			) /	10.00),0) AS [Quantity],
	0.00 AS [TransAmount],
	Prtfl.CustId,
	Prtfl.PrtfNo,
	Prtfl.AcctTypeCode,
	Prtfl.AcctNo,
	CASE 
	WHEN Prtfl.AcctTypeCode = 'AT00001' THEN 'D' -- debit account
	ELSE 'S' 
	END AS [BuySell],
	S.TransactionTypeCode
FROM [MasterData].[Calendar] Cal WITH (NOLOCK)
CROSS JOIN (
	SELECT DISTINCT [CustId],[PrtfNo],[AcctNo],[AcctTypeCode]
	FROM [Financial].[Account] WITH (NOLOCK)
	) Prtfl
JOIN [MasterData].[CustomerTickerSymbols] S WITH (NOLOCK)
ON (
Prtfl.AcctTypeCode = REPLACE(S.[TransactionTypeCode],'TT','AT')
AND Prtfl.CustId = S.CustId
AND S.[CustTradesInFlag] = 'Y'
)
WHERE Prtfl.AcctTypeCode = REPLACE(S.[TransactionTypeCode],'TT','AT')
ORDER BY Cal.[CalendarDate]
GO

SET NOCOUNT OFF
GO

/*************************************/
/* Both these queries took <1 minute */
/*************************************/

UPDATE [Financial].[Transaction]
SET [TransAmount] = [Price] * [Quantity] 
WHERE [BuySell] = 'B';
GO

UPDATE [Financial].[Transaction]
SET [TransAmount] = -1 * ([Price] * [Quantity])
WHERE [BuySell] = 'S';
GO

UPDATE [Financial].[Transaction]
SET [TransAmount] = [Price] * [Quantity] 
WHERE [BuySell] = 'C';
GO

UPDATE [Financial].[Transaction]
SET [TransAmount] = -1 * ([Price] * [Quantity])
WHERE [BuySell] = 'D';
GO

/***********************************************************/
/* NEED TO CREDIT CASH ACCOUNT FOR SELL TRANSACTIONS       */
/* BECAUSE CUSTOMER DEPOSITS CASH AFTER SELLING INSTRUMENT */
/***********************************************************/

INSERT INTO [Financial].[Transaction]
SELECT [TransDate]
      ,[Symbol]
      ,ABS([TransAmount]) AS [Price]
      ,1 AS [Quantity]
      ,ABS([TransAmount]) AS [TransAmount]
      ,[CustId]
      ,[PortfolioNo]
	  ,'AT00001'
      ,'A01' + LEFT(CustId,1) + RIGHT(CustId,1) AS [AcctNo]
      ,'C'
      ,'TT00001' AS [TransTypeCode]
 FROM [Financial].[Transaction]
WHERE [BuySell] = 'S'
ORDER BY [TransDate]
      ,[Symbol]
      ,[CustId]
      ,[PortfolioNo]
GO

/*****************************************************/
/* NEED TO DEBIT CASH ACCOUNT FOR SELL TRANSACTONS   */ 
/* BECAUSE CUSTOMER WITHDRAWS CASH TO BUY INSTRUMENT */
/*****************************************************/

INSERT INTO [Financial].[Transaction]
SELECT [TransDate]
      ,[Symbol]
      ,[TransAmount] AS [Price]
      ,1 AS [Quantity]
      ,-1 * [TransAmount]
      ,[CustId]
      ,[PortfolioNo]
	  ,'AT00001'
      ,'A01' + LEFT(CustId,1) + RIGHT(CustId,1) AS [AcctNo]
      ,'D' AS [BuySell]
      ,'TT00001' AS [TransTypeCode]
  FROM [Financial].[Transaction]
WHERE [BuySell] = 'B'
ORDER BY [TransDate]
      ,[Symbol]
      ,[CustId]
      ,[PortfolioNo]
GO

-- need to delete these as
-- we buy and sell FX
-- but to not debit or credit like cash

DELETE FROM [Financial].[Transaction]
WHERE [TransTypeCode] <> 'TT00004'
AND Symbol IN (
	SELECT symbol 
	FROM [Financial].[TickerSymbols]
	WHERE [TransactionTypeCode] = 'TT00004'
	)
GO

-- delete trades that are not checking or savings account
-- but have buy/sell flags of D or C for Debit or Credit

--SELECT T.*,S.[TransactionTypeCode]
--FROM [Financial].[Transaction] T

DELETE FROM [Financial].[Transaction] 
FROM [Financial].[Transaction] T
JOIN [Financial].[TickerSymbols] S
ON T.[Symbol] = S.[Symbol]
AND T.[TransTypeCode] <> S.[TransactionTypeCode]
WHERE T.BuySell IN ('D','C')
GO

SET NOCOUNT OFF
GO

DROP INDEX IF EXISTS akDeleteTransactions ON [Financial].[DeleteTransactions]
GO

DROP INDEX IF EXISTS akTransactions ON [Financial].[Transaction]
GO

CREATE INDEX akTransactions ON [Financial].[Transaction](TransKey)
GO

-- CHECK FOR DUPLICATES

-- 388626
SELECT COUNT(*) FROM [Financial].[Transaction]
GO

-- 388626
SELECT DISTINCT COUNT(*) FROM [Financial].[Transaction]
GO

/***********/
/* ACCOUNT */
/***********/

/**********************************************/
/* Update Account Table with new Transactions */
/**********************************************/

-- in case you neede to reload after loading tranactions

DELETE FROM [Financial].[Account]
WHERE [PostDate] > '2011-12-31'
GO

INSERT INTO [Financial].[Account]
SELECT 
      T.[CustId]
      ,T.[PortfolioNo]
      ,T.[AcctNo]
	  ,AT.[AcctTypeName]
      ,REPLACE(T.[TransTypeCode],'TT','AT') AS [AcctTypeCode]
	  ,SUM(T.[TransAmount]) AS [AcctBalance]
	  ,T.[TransDate] AS [PostDate]
FROM  [Financial].[Transaction] T
JOIN [MasterData].[AccountType] AT
ON REPLACE(T.[TransTypeCode],'TT','AT') = AT.[AcctTypeCode]
GROUP BY
      T.[CustId]
      ,T.[PortfolioNo]
      ,T.[AcctNo]
	  ,AT.[AcctTypeName]
      ,T.[TransTypeCode]
	  ,T.[TransDate]
ORDER BY
	  T.[TransDate]
      ,T.[CustId]
      ,T.[PortfolioNo]
      ,T.[AcctNo]
	  ,AT.[AcctTypeName]
	  ,T.[TransTypeCode]
	  GO

SELECT * 
FROM [Financial].[Account]
GO

-- CHECK FOR DUPLICATES

SELECT count(*) 
FROM [Financial].[Account]
GO

SELECT DISTINCT COUNT(*)
FROM [Financial].[Account]
GO

/*************/
/* PORTFOLIO */
/*************/

/****************************************************************/
/* IF YOU TRUNCATE, INITIAL DATA WILL BE LOST FROM EARLIER STEP */
/****************************************************************/

/*
TRUNCATE TABLE [TRADE].[PORTFOLIO]
GO
*/

/********************/
/* SUBSEQUENT LOADS */
/********************/

DELETE FROM [Financial].[Portfolio]
WHERE [SweepDate] > '12/31/2011'
GO

INSERT INTO [Financial].[Portfolio]
SELECT YEAR(A.[PostDate]) AS PostYear
	  ,MONTH(A.[PostDate]) AS PostMonth
      ,A.[CustId]
      ,A.[PrtfNo]
	  ,PAT.[PortfolioAccountTypeCode]
	  ,A.AcctName + ' - FINANCIAL PORTFOLIO'
	  ,SUM(A.[AcctBalance])
	  ,0.0 AS RollingBalance -- to be calculated in scripts
	  ,EOMONTH(A.[PostDate]) AS [SWEEP_DATE]
FROM  [Financial].[Account] A
JOIN [MasterData].[PortfolioAccountType] PAT
ON A.AcctName + ' - FINANCIAL PORTFOLIO' = PAT.PortfolioAccountTypeName
GROUP BY YEAR(A.[PostDate])
	  ,MONTH(A.[PostDate])
      ,A.[CustId]
      ,A.[PrtfNo]
	  ,PAT.[PortfolioAccountTypeCode]
	  ,A.AcctName + ' - FINANCIAL PORTFOLIO'
	  ,EOMONTH(A.[PostDate])
ORDER BY YEAR(A.[PostDate])
	  ,MONTH(A.[PostDate])
      ,A.[CustId]
      ,A.[PrtfNo]
	  ,A.AcctName + ' - FINANCIAL PORTFOLIO'
	  GO

SELECT * FROM [Financial].[Portfolio]
ORDER BY 1,2,3,5
GO

-- CHECK FOR DUPLICATES

SELECT COUNT(*) FROM [Financial].[Portfolio]
GO

SELECT DISTINCT COUNT(*) FROM [Financial].[Portfolio]
GO

/**********************/
/* PORTFOLIO MOVEMENT */
/**********************/

TRUNCATE TABLE [Financial].[PortfolioMovement]
GO

INSERT INTO [Financial].[PortfolioMovement]
SELECT [Year]
      ,[Month]
      ,[CustId]
      ,[PortfolioNo]
      ,[PortfolioAccountTypeCode]
      ,[Portfolio]
      ,[Value]
      ,[SweepDate]
  FROM [Financial].[Portfolio]
  ORDER BY [Year]
      ,[Month]
      ,[CustId]
      ,[PortfolioNo]
GO

/****************/
/*  QUERIES */
/****************/

/*************************************************/
/* validate that symbols match transaction codes */
/*************************************************/

SELECT [TransDate]
      ,T.[Symbol]
      ,[Price]
      ,[Quantity]
      ,[TransAmount]
      ,[CustId]
      ,[PortfolioNo]
      ,[AcctNo]
	  ,TS.TransactionTypeCode
      ,[BuySell]
      ,[TransTypeCode]
  FROM [Financial].[Transaction] T
  JOIN [Financial].[TickerSymbols] TS
  ON T.Symbol = TS.Symbol
  GO

SELECT [Year]
      ,[Month]
      ,[CustId]
      ,[PortfolioNo]
      ,[Portfolio]
      ,SUM([Value]) AS PORTFOLIO_BALANCE
  FROM [Financial].[Portfolio]
  WHERE CustId = 'C0000001'
 GROUP BY [Year]
      ,[Month]
      ,[CustId]
      ,[PortfolioNo]
      ,[Portfolio]
ORDER BY [CustId]
      ,[PortfolioNo]
      ,[Portfolio]
	  ,[Year]
      ,[Month]
GO

SELECT *
FROM [Financial].[Portfolio]
WHERE CustId = 'C0000001'
ORDER BY [Year]
	,[Month]
	,[CustId]
	,[PortfolioNo]
GO

SELECT [Year], [CustId], [PortfolioNo],[PortfolioAccountTypeCode],[Portfolio], SUM([Value]) AS PortfolioBalance
FROM [Financial].[Portfolio]
WHERE CustId = 'C0000001'
GROUP BY [Year], [CustId], [PortfolioNo],[PortfolioAccountTypeCode],[Portfolio]
ORDER BY [Year]
	,[CustId]
	,[PortfolioNo]
GO

SELECT [Year], [CustId], SUM([Value]) AS PortfolioBalance
FROM [Financial].[Portfolio]
WHERE CustId = 'C0000001'
GROUP BY [Year], [CustId]
ORDER BY [Year]
	,[CustId]
GO

/****************************/
/* ACCOUNT MONTHLY BALANCES */
/****************************/

TRUNCATE TABLE [FinancialReports].[AccountMonthlyBalances]
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalances]
SELECT YEAR([PostDate]) AS [AcctYear]
	  ,MONTH(PostDate) AS [AcctMonth]
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
	  ,SUM([AcctBalance]) AS [AcctBalance]
FROM [Financial].[Account]
GROUP BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
ORDER BY [AcctName]
	  ,[CustId]
	  ,YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[PrtfNo]
      ,[AcctNo]
     
GO

SELECT * FROM [FinancialReports].[AccountMonthlyBalances]
GO

/******************************************************/
/* ACCOUNT MONTHLY BALANCES MEMORY TABLES 2011 - 2015 */
/******************************************************/

DELETE FROM [FinancialReports].[AccountMonthlyBalancesMem2011]
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2011]
SELECT YEAR([PostDate]) AS [AcctYear]
	  ,MONTH(PostDate) AS [AcctMonth]
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
	  ,SUM([AcctBalance]) AS [AcctBalance]
FROM [Financial].[Account]
WHERE YEAR([PostDate]) = 2011
GROUP BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
ORDER BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
GO

DELETE FROM [FinancialReports].[AccountMonthlyBalancesMem2012]
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2012]
SELECT YEAR([PostDate]) AS [AcctYear]
	  ,MONTH(PostDate) AS [AcctMonth]
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
	  ,SUM([AcctBalance]) AS [AcctBalance]
FROM [Financial].[Account]
WHERE YEAR([PostDate]) = 2012
GROUP BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
ORDER BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
GO

DELETE FROM [FinancialReports].[AccountMonthlyBalancesMem2013]
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2013]
SELECT YEAR([PostDate]) AS [AcctYear]
	  ,MONTH(PostDate) AS [AcctMonth]
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
	  ,SUM([AcctBalance]) AS [AcctBalance]
FROM [Financial].[Account]
WHERE YEAR([PostDate]) = 2013
GROUP BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
ORDER BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
GO

DELETE FROM [FinancialReports].[AccountMonthlyBalancesMem2014]
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2014]
SELECT YEAR([PostDate]) AS [AcctYear]
	  ,MONTH(PostDate) AS [AcctMonth]
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
	  ,SUM([AcctBalance]) AS [AcctBalance]
FROM [Financial].[Account]
WHERE YEAR([PostDate]) = 2014
GROUP BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
ORDER BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
GO

DELETE FROM [FinancialReports].[AccountMonthlyBalancesMem2015]
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem2015]
SELECT YEAR([PostDate]) AS [AcctYear]
	  ,MONTH(PostDate) AS [AcctMonth]
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
	  ,SUM([AcctBalance]) AS [AcctBalance]
FROM [Financial].[Account]
WHERE YEAR([PostDate]) = 2015
GROUP BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
ORDER BY YEAR([PostDate])
	  ,MONTH(PostDate)
	  ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
GO

DELETE FROM [FinancialReports].[AccountMonthlyBalancesMem]
GO

INSERT INTO [FinancialReports].[AccountMonthlyBalancesMem]
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2011]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2012]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2013]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2014]
UNION ALL
SELECT [AcctYear]
      ,[AcctMonth]
      ,[CustId]
      ,[PrtfNo]
      ,[AcctNo]
      ,[AcctName]
      ,[AcctBalance]
FROM [FinancialReports].[AccountMonthlyBalancesMem2015]
GO

SELECT * FROM [FinancialReports].[AccountMonthlyBalancesMem]
GO

/*************************/
/* CheckTable Row Counts */
/*************************/

SELECT DISTINCT * FROM [dbo].[CheckTableRowCount]
ORDER BY 1
GO

SET NOCOUNT OFF
GO



