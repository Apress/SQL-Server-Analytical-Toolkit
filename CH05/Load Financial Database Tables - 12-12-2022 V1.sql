/*****************************/
/* Load APFinance Database   */
/* Create: 8/28/2022         */
/* Modified: 12/12/2022      */
/*****************************/

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
('C0000001','P01C1','A04C1','OPTION ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000002','P01C2','A04C2','OPTION ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000003','P01C3','A04C3','OPTION ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000004','P01C4','A04C4','OPTION ACCOUNT','AT00004',100000.00,'2011-12-31'),
('C0000005','P01C5','A04C5','OPTION ACCOUNT','AT00004',100000.00,'2011-12-31'),
-- SWAP
('C0000001','P01C1','A05C1','OPTION ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000002','P01C2','A05C2','OPTION ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000003','P01C3','A05C3','OPTION ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000004','P01C4','A05C4','OPTION ACCOUNT','AT00005',100000.00,'2011-12-31'),
('C0000005','P01C5','A05C5','OPTION ACCOUNT','AT00005',100000.00,'2011-12-31'),
-- COMMODITY
('C0000001','P01C1','A06C1','OPTION ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000002','P01C2','A06C2','OPTION ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000003','P01C3','A06C3','OPTION ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000004','P01C4','A06C4','OPTION ACCOUNT','AT00006',100000.00,'2011-12-31'),
('C0000005','P01C5','A06C5','OPTION ACCOUNT','AT00006',100000.00,'2011-12-31');
GO

SELECT * FROM [Financial].[Account]
GO

/*************/
/* PORTFOLIO */
/*************/

-- first time

TRUNCATE TABLE [Financial].[Portfolio]
GO

INSERT INTO [Financial].[Portfolio]
VALUES
(2011,12,'C0000001','P01C1','CASH - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000002','P01C2','CASH - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000003','P01C3','CASH - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000004','P01C4','CASH - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000005','P01C5','CASH - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000001','P01C1','EQUITY - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000002','P01C2','EQUITY - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000003','P01C3','EQUITY - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000004','P01C4','EQUITY - FINANCIAL PORTFOLIO',100000.00,'2011-12-31'),
(2011,12,'C0000005','P01C5','EQUITY - FINANCIAL PORTFOLIO',100000.00,'2011-12-31');
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

/************/
/* CALENDAR */
/************/

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
	@CurrentDate
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
/* NEED TO CREDIT CASH ACCOUNT FOR SELL TRANSACTONS        */
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

--SELECT *
--FROM [Financial].[Transaction]

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

CREATE INDEX akDeleteTransactions ON [Financial].[DeleteTransactions](TransKey)
GO

DROP INDEX IF EXISTS akTransactions ON [Financial].[Transaction]
GO

CREATE INDEX akTransactions ON [Financial].[Transaction](TransKey)
GO

DROP TABLE [Financial].DeleteTransactions
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
	  ,A.AcctName + ' - FINANCIAL PORTFOLIO'
	  ,SUM(A.[AcctBalance])
	  ,EOMONTH(A.[PostDate]) AS [SWEEP_DATE]
FROM  [Financial].[Account] A
GROUP BY A.[PostDate]
      ,A.[CustId]
      ,A.[PrtfNo]
	  ,A.AcctName + ' - FINANCIAL PORTFOLIO'
ORDER BY YEAR(A.[PostDate])
	  ,MONTH(A.[PostDate])
      ,A.[CustId]
      ,A.[PrtfNo]
	  ,A.AcctName + ' - FINANCIAL PORTFOLIO'
	  GO

/****************/
/* TEST QUERIES */
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
  FROM [APFinance].[Financial].[Transaction] T
  JOIN [Financial].[TickerSymbols] TS
  ON T.Symbol = TS.Symbol
  GO

SELECT [Year]
      ,[Month]
      ,[CustId]
      ,[PortfolioNo]
      ,[Portfolio]
      ,SUM([Value]) AS PORTFOLIO_BALANCE
  FROM [APFinance].[Financial].[Portfolio]
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

SELECT [Year], [CustId], [PortfolioNo], [Portfolio], SUM([Value]) AS PortfolioBalance
FROM [Financial].[Portfolio]
WHERE CustId = 'C0000001'
GROUP BY [Year], [CustId], [PortfolioNo], [Portfolio]
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


