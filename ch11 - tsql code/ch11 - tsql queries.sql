/************************/
/* CREATED: 05/09/2022  */
/* MODIFIED: 05/10/2022 */
/************************/

USE [AP_PLANT]
GO

/**********************************/
/* RECIPE 1 - AGGREGATE FUNCTIONS */
/**********************************/

/************************************************/
/* TASK 1 - COUNT(),MIN(),MAX(),AVG(), W/OVER() */
/************************************************/

SELECT
	CAL.CALENDAR_YEAR
	,P.[PLANT_ID]
	,P.[PLANT_NAME]
	,L.LOCATION_ID
	,L.LOCATION_NAME
	,[GENERATOR_ID]

	,COUNT(EF.[FAILURE]) AS FAILURE_EVENTS
	,COUNT_BIG(EF.[FAILURE]) AS BIG_FAILURE_EVENTS
	,MIN(EF.[FAILURE]) AS MIN_FAILURES
	,MAX(EF.[FAILURE]) AS MAX_FAILURES
	,SUM(EF.[FAILURE]) AS SUM_FAILURES
	,AVG(CONVERT(DECIMAL(10,2),EF.[FAILURE])) AS AVG_FAILURES
	,AVG(EF.[FAILURE]) OVER () AS AVG_ALL_YEARS
	,CONVERT(DECIMAL(10,2),SUM(EF.[FAILURE])/CONVERT(DECIMAL(10,2),COUNT(*))) CALC_AVG
FROM [DIM].[PLANT] P
JOIN [DIM].[LOCATION] L
ON P.PLANT_ID = L.PLANT_ID
JOIN [DIM].[GENERATOR] G
ON L.PLANT_ID = G.PLANT_ID
AND L.LOCATION_ID = G.LOCATION_ID
JOIN [DIM].[EQUIPMENT] E
ON G.EQUIPMENT_ID = E.EQUIPMENT_ID
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[CALENDAR] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
WHERE P.PLANT_ID = 'PP000001'
GROUP BY
		CAL.CALENDAR_YEAR,
		P.[PLANT_ID],
		P.[PLANT_NAME],
		L.LOCATION_ID,
		L.LOCATION_NAME,
		[GENERATOR_ID],
		EF.[FAILURE]
ORDER BY
	CAL.CALENDAR_YEAR,
	P.[PLANT_ID],
	P.[PLANT_NAME],
	L.LOCATION_ID,
	L.LOCATION_NAME,
	[GENERATOR_ID]
GO

/************************************************/
/* TASK 2 - COUNT(),MIN(),MAX(),AVG(), W/OVER() */
/************************************************/

SELECT DISTINCT -- NEED DISTINCT
	CAL.CALENDAR_YEAR
	,P.[PLANT_ID]
	,P.[PLANT_NAME]
	,L.LOCATION_ID
	,L.LOCATION_NAME
	,[GENERATOR_ID]

	,COUNT(EF.[FAILURE]) OVER(PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID]) AS FAILURE_EVENTS
	,MIN(EF.[FAILURE])  OVER(PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID])AS MIN_FAILURES
	,MAX(EF.[FAILURE])  OVER(PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID])AS MAX_FAILURES
	,SUM(EF.[FAILURE])  OVER(PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID]) AS SUM_FAILURES
	,CONVERT(DECIMAL(10,2),
		AVG(CONVERT(DECIMAL(10,2),EF.[FAILURE]))  OVER(PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID])
		)AS AVG_FAILURES
--	,CONVERT(DECIMAL(10,2),SUM(EF.[FAILURE])/CONVERT(DECIMAL(10,2),COUNT(*))) CALC_AVG
FROM [DIM].[PLANT] P
JOIN [DIM].[LOCATION] L
ON P.PLANT_ID = L.PLANT_ID
JOIN [DIM].[GENERATOR] G
ON L.PLANT_ID = G.PLANT_ID
AND L.LOCATION_ID = G.LOCATION_ID
JOIN [DIM].[EQUIPMENT] E
ON G.EQUIPMENT_ID = E.EQUIPMENT_ID
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[CALENDAR] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
ORDER BY
	CAL.CALENDAR_YEAR,P.[PLANT_ID],P.[PLANT_NAME],L.LOCATION_ID,L.LOCATION_NAME,[GENERATOR_ID]
GO

/***********************/
/* TASK 3 - GROUPING() */
/***********************/

SELECT DISTINCT
	CAL.CALENDAR_YEAR
	,P.[PLANT_ID]
	,P.[PLANT_NAME]
	,L.LOCATION_ID
	,L.LOCATION_NAME
	,[GENERATOR_ID]
	,EF.[FAILURE]
	,COUNT(EF.[FAILURE]) AS FAILURE_COUNT
	,GROUPING(EF.[FAILURE]) AS [GROUPING_SETS]
FROM [DIM].[PLANT] P
JOIN [DIM].[LOCATION] L
ON P.PLANT_ID = L.PLANT_ID
JOIN [DIM].[GENERATOR] G
ON L.PLANT_ID = G.PLANT_ID
AND L.LOCATION_ID = G.LOCATION_ID
JOIN [DIM].[EQUIPMENT] E
ON G.EQUIPMENT_ID = E.EQUIPMENT_ID
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[CALENDAR] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
WHERE P.PLANT_ID = 'PP000001'
AND CAL.CALENDAR_YEAR = '2002'
GROUP BY
	CAL.CALENDAR_YEAR
	,P.[PLANT_ID]
	,P.[PLANT_NAME]
	,L.LOCATION_ID
	,L.LOCATION_NAME
	,G.[GENERATOR_ID]
	,EF.[FAILURE] WITH ROLLUP
ORDER BY
	CAL.CALENDAR_YEAR,
	P.[PLANT_ID],
	P.[PLANT_NAME],
	L.[LOCATION_ID],
	L.[LOCATION_NAME],
	G.[GENERATOR_ID]
GO

/**************************/
/* TASK 4 - GROUPING SETS */
/**************************/

/*************************/
/* TASK 5 - STRING_AGG() */
/*************************/

SELECT 
	'Total Failures for power plants: ' + STRING_AGG(P.[PLANT_ID],',') + ':' 
	+ CONVERT(VARCHAR, (
	SELECT 
		SUM([FAILURE]) 
	FROM [DIM].[PLANT] P
	JOIN [DIM].[LOCATION] L
	ON P.[PLANT_ID] = L.[PLANT_ID]
	JOIN [FACT].[EQUIPMENT_FAILURE] EF
	ON L.[LOCATION_KEY] = EF.[LOCATION_KEY]
	) 
) AS POWER_PLANT_REPORT
FROM [DIM].[PLANT] P
GO

/********************************************/
/* TASK 6 - STDEV(),STDEVP() & VAR(),VARP() */
/********************************************/

SELECT DISTINCT -- NEED DISTINCT
	CAL.CALENDAR_YEAR
	,CAL.CALENDAR_MONTH
	,UPPER(CAL.MONTH_ABBREV) AS MONTH_ABBREV
	,P.[PLANT_ID]
	,P.[PLANT_NAME]
	,L.LOCATION_ID
	,L.LOCATION_NAME
	,[GENERATOR_ID]
	,SUM(EF.[FAILURE])
	 OVER(PARTITION BY CAL.CALENDAR_YEAR,CAL.CALENDAR_MONTH)
	AS FAILURE
	,CONVERT(DECIMAL(10,2),
		AVG(CONVERT(DECIMAL(10,2),EF.[FAILURE]))  OVER(PARTITION BY CAL.CALENDAR_YEAR)
		)AS [AVG]

	,STDEV(EF.[FAILURE]) OVER(
		PARTITION BY CAL.CALENDAR_YEAR
		) AS [STDEV]
	,STDEVP(EF.[FAILURE]) OVER(
		PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID]
		) AS [STDEVP]
	,VAR(EF.[FAILURE]) OVER(
		PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID]
		) AS [VAR]
	,VARP(EF.[FAILURE]) OVER(
		PARTITION BY CAL.CALENDAR_YEAR,P.[PLANT_ID]
		) AS [VARP]

FROM [DIM].[PLANT] P
JOIN [DIM].[LOCATION] L
ON P.PLANT_ID = L.PLANT_ID
JOIN [DIM].[GENERATOR] G
ON L.PLANT_ID = G.PLANT_ID
AND L.LOCATION_ID = G.LOCATION_ID
JOIN [DIM].[EQUIPMENT] E
ON G.EQUIPMENT_ID = E.EQUIPMENT_ID
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[CALENDAR_VIEW] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
WHERE P.PLANT_ID = 'PP000001'
ORDER BY
	CAL.CALENDAR_YEAR,
	CAL.CALENDAR_MONTH,
	P.[PLANT_ID],
	P.[PLANT_NAME],
	L.LOCATION_ID,
	L.LOCATION_NAME,
	[GENERATOR_ID]
GO

/********************************/
/* RECIPE 2 - RANKING FUNCTIONS */
/********************************/

/*
RANK()
DENSE_RANK()
NTILE()
ROW_NUMBER()
*/

/**********************************/
/* TASK 1 - RANK() & DENSE_RANK() */
/**********************************/

SELECT DISTINCT
	  CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	  ,CAL.[CALENDAR_MONTH] AS FAILURE_MONTH
	  ,E.EQUIP_ABBREV

	  ,SUM(EF.FAILURE) OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],CAL.[CALENDAR_MONTH]
	  ORDER BY CAL.[CALENDAR_YEAR],[CALENDAR_MONTH]	  
	  ) AS SUM_FAILURE
	  ,RANK() OVER(
	  PARTITION BY CAL.[CALENDAR_MONTH],CAL.[CALENDAR_MONTH]
	  ORDER BY CAL.[CALENDAR_YEAR],[CALENDAR_MONTH]	  	  
	  ) AS [RANK]
	  ,DENSE_RANK() OVER(
	  PARTITION BY CAL.[CALENDAR_MONTH],CAL.[CALENDAR_MONTH]
	  ORDER BY CAL.[CALENDAR_YEAR],[CALENDAR_MONTH]	  	  
	  ) AS [DENSE_RANK]
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE CAL.CALENDAR_MONTH = 1
AND L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
GROUP BY CAL.[CALENDAR_YEAR]
	  ,CAL.[CALENDAR_MONTH]
	  ,E.EQUIP_ABBREV
	  ,EF.FAILURE
ORDER BY CAL.[CALENDAR_YEAR]
	  ,CAL.[CALENDAR_MONTH]
GO

/***********************************/
/* TASK 2 - SUM(),RANK() & NTILE() */
/***********************************/

SELECT DISTINCT
	  CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	  ,CAL.[QUARTER_NAME] AS FAILURE_QTR
	   ,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	  ,E.EQUIP_ABBREV
	 ,SUM(EF.FAILURE) OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],
		CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],CAL.[MONTH_ABBREV] 
	  ) AS SUM_FAILURE
	  ,RANK() OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],CAL.[MONTH_ABBREV]  
	  ) AS [RANK]
	  ,NTILE(4) OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],
		CAL.[QUARTER_NAME],
		CAL.[MONTH_ABBREV]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME] 
	  ) AS [NTILE] 
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
ORDER BY
	  CAL.[CALENDAR_YEAR]
	  ,CAL.[QUARTER_NAME]
	  ,CAL.[MONTH_ABBREV]
GO

/***********************************/
/* TASK 4 -  NTILE VS ROW_NUMBER() */
/***********************************/

DECLARE @TILES INT;

SELECT @TILES = COUNT(DISTINCT EQUIPMENT_TYPE)
FROM [DIM].[EQUIPMENT];

SELECT
	[EQUIPMENT_ID], 
	[SERIAL_NO], 
	[EQUIP_ABBREV], 
	[EQUIPMENT_TYPE], 
	[MANUFACTURER_ID],
	NTILE(@TILES) OVER (
	PARTITION BY [EQUIPMENT_TYPE]
		ORDER BY 	[EQUIP_ABBREV]
		) AS TILES
	,ROW_NUMBER() OVER (
	PARTITION BY [EQUIPMENT_TYPE]
		ORDER BY 	[EQUIP_ABBREV],EQUIPMENT_TYPE
		) AS ROW_NUMBER
FROM [DIM].[EQUIPMENT]
GO

/*********************************/
/* TASK 5 - RANK VS DENSE_RANK() */
/*********************************/

SELECT DISTINCT
	  CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	  ,CAL.[QUARTER_NAME] AS FAILURE_QTR
	   ,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	  ,E.EQUIP_ABBREV
	 ,SUM(EF.FAILURE) OVER(
		PARTITION BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],CAL.[MONTH_ABBREV] ASC
	  ) AS SUM_FAILURE
	  ,RANK() OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],CAL.[MONTH_ABBREV] ASC
	  ) AS [RANK]
	  ,DENSE_RANK() OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],CAL.[MONTH_ABBREV] ASC
	  ) AS [DENSE_RANK]
	 
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
ORDER BY
	  CAL.[CALENDAR_YEAR]
	  ,CAL.[QUARTER_NAME]
	  ,CAL.[MONTH_ABBREV]
GO

/**********************************/
/* RECIPE 3 - ANALYTICAL FUNCTIONS */
/**********************************/
/***************/
/* CUME_DIST() */
/***************/

SELECT DISTINCT
	  CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	  ,CAL.[QUARTER_NAME] AS FAILURE_QTR
	  ,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	  ,CAL.CALENDAR_DATE
	  ,E.EQUIP_ABBREV
	  ,EF.FAILURE
	 ,CONVERT(DECIMAL(10,2),CUME_DIST() OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],EF.FAILURE 
	  ) ) AS CUME_DIST
	
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE CAL.CALENDAR_MONTH = 1
AND L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
/*GROUP BY 
	  CAL.[CALENDAR_YEAR]
	  ,CAL.[QUARTER_NAME] 
	   ,CAL.[MONTH_ABBREV] 
	  ,E.EQUIP_ABBREV
	  ,EF.FAILURE*/
ORDER BY
	  CAL.[CALENDAR_YEAR]
	  ,CAL.[QUARTER_NAME]
	  ,CAL.[MONTH_ABBREV]
GO

/*********/
/* LAG() */
/*********/

SELECT
	  FR.FAILURE_YEAR
	  ,FR.FAILURE_QTR
	  ,FR.MONTH_ABBREV
	  ,FR.EQUIP_ABBREV 
	  ,SUM(FR.SUM_FAILURE) OVER(
	  PARTITION BY FR.FAILURE_YEAR,FR.FAILURE_QTR,FR.MONTH_ABBREV
	  ORDER BY FR.FAILURE_YEAR,FR.FAILURE_QTR,FR.MONTH_ABBREV
	  ) AS SUM_FAILURE
	 ,LAG(FR.SUM_FAILURE) OVER(
	  PARTITION BY FR.FAILURE_YEAR,FR.FAILURE_QTR
	  ORDER BY FR.FAILURE_YEAR,FR.FAILURE_QTR,FR.MONTH_ABBREV
	  ) AS PRIOR_MONTH
FROM (
SELECT DISTINCT
	  CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	  ,CAL.[QUARTER_NAME] AS FAILURE_QTR
	   ,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	  ,E.EQUIP_ABBREV AS EQUIP_ABBREV 
	  ,SUM(EF.FAILURE) OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],
		CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],CAL.[MONTH_ABBREV] 
	  ) AS SUM_FAILURE
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
) FR
GO

/**********/
/* LEAD() */
/**********/

SELECT
	  FR.FAILURE_YEAR
	  ,FR.FAILURE_QTR
	  ,FR.MONTH_ABBREV
	  ,FR.EQUIP_ABBREV 
	  ,SUM(FR.SUM_FAILURE) OVER(
	  PARTITION BY FR.FAILURE_YEAR,FR.FAILURE_QTR,FR.MONTH_ABBREV
	  ORDER BY FR.FAILURE_YEAR,FR.FAILURE_QTR,FR.MONTH_ABBREV
	  ) AS SUM_FAILURE
	 ,LEAD(FR.SUM_FAILURE) OVER(
	  PARTITION BY FR.FAILURE_YEAR,FR.FAILURE_QTR
	  ORDER BY FR.FAILURE_YEAR,FR.FAILURE_QTR,FR.MONTH_ABBREV
	  ) AS NEXT_MONTH
FROM (
SELECT DISTINCT
	  CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	  ,CAL.[QUARTER_NAME] AS FAILURE_QTR
	   ,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	  ,E.EQUIP_ABBREV AS EQUIP_ABBREV 
	  ,SUM(EF.FAILURE) OVER(
	  PARTITION BY CAL.[CALENDAR_YEAR],
		CAL.[QUARTER_NAME]
	  ORDER BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME],CAL.[MONTH_ABBREV] 
	  ) AS SUM_FAILURE
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
) FR
GO

/***************/
/* CUME_DIST() */
/***************/

SELECT DISTINCT
	FAILURE_YEAR
	,FAILURE_QTR
	,CALENDAR_MONTH
	,MONTH_ABBREV
	,WEEK_NO
	,EQUIP_ABBREV 
	,SUM_FAILURE
	,CUME_DIST() OVER(
	--  PARTITION BY CAL.[CALENDAR_YEAR],CAL.[QUARTER_NAME]
	  ORDER BY FAILURE_YEAR
		,FAILURE_QTR
		,CALENDAR_MONTH
		,MONTH_ABBREV
		,WEEK_NO
	  ) AS CUME_DIST 
FROM (
SELECT DISTINCT
	CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	,CAL.[QUARTER_NAME] AS FAILURE_QTR
	,CAL.[CALENDAR_MONTH]
	,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	,DATEPART(ww,[CALENDAR_DATE]) AS WEEK_NO
	,E.EQUIP_ABBREV AS EQUIP_ABBREV 
	,SUM(EF.FAILURE) AS SUM_FAILURE
	 
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
	ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
	ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
	ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
	ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
AND CAL.[CALENDAR_YEAR] = 2010
GROUP BY
	CAL.[CALENDAR_YEAR]
	,CAL.[QUARTER_NAME]
	,CAL.[MONTH_ABBREV]
	,CAL.[CALENDAR_MONTH]
	,DATEPART(ww,[CALENDAR_DATE])
	,E.EQUIP_ABBREV
)FR
ORDER BY
	FAILURE_YEAR
	,FAILURE_QTR
	,CALENDAR_MONTH
	,MONTH_ABBREV
	,WEEK_NO
	,EQUIP_ABBREV 
GO

/*******************************/
/*FIRST_VALUE() & LAST_VALUE() */
/*******************************/

SELECT DISTINCT
	FAILURE_YEAR
	,FAILURE_QTR
	,CALENDAR_MONTH
	,MONTH_ABBREV
	,WEEK_NO
	,EQUIP_ABBREV 
	,EQUIPMENT_ID
	,SUM_FAILURE
	,FIRST_VALUE(SUM_FAILURE) OVER(
	  PARTITION BY [FAILURE_YEAR],[FAILURE_QTR],MONTH_ABBREV,WEEK_NO
	  ORDER BY SUM_FAILURE 
	  ) AS FIRST_VALUE
	,LAST_VALUE(SUM_FAILURE) OVER(
	  PARTITION BY [FAILURE_YEAR],[FAILURE_QTR],MONTH_ABBREV,WEEK_NO
	  ORDER BY SUM_FAILURE 
	  ) AS LAST_VALUE
FROM (
SELECT DISTINCT
	CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	,CAL.[QUARTER_NAME] AS FAILURE_QTR
	,CAL.[CALENDAR_MONTH]
	,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	,CAL.[CALENDAR_MONTH_WEEK] AS WEEK_NO
	,E.EQUIP_ABBREV AS EQUIP_ABBREV 
	,E.EQUIPMENT_ID
	,SUM(EF.FAILURE) AS SUM_FAILURE
	 
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
	ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
	ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
	ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
	ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
AND CAL.[CALENDAR_YEAR] = 2010
GROUP BY
	CAL.[CALENDAR_YEAR]
	,CAL.[QUARTER_NAME]
	,CAL.[MONTH_ABBREV]
	,CAL.[CALENDAR_MONTH]
	,CAL.[CALENDAR_MONTH_WEEK]
	,E.EQUIP_ABBREV
	,EQUIPMENT_ID
)FR
ORDER BY
	FAILURE_YEAR
	,FAILURE_QTR
	,CALENDAR_MONTH
	,MONTH_ABBREV
	,WEEK_NO
	,EQUIP_ABBREV
	,EQUIPMENT_ID
GO

/*************************************/
/* PERCENTILE_CONT & PERCENTILE_DISC */
/*************************************/

SELECT DISTINCT
	FAILURE_YEAR
	,FAILURE_QTR
	,MONTH_NO
	,MONTH_ABBREV
	,WEEK_NO
	,EQUIP_ABBREV 
	,SUM(FAILURE) AS SUM_FAILURE
	,CONVERT(DECIMAL(10,2),PERCENTILE_CONT(0.5) -- continuous
		WITHIN GROUP (ORDER BY SUM(FAILURE) )
		OVER(
			PARTITION BY FAILURE_YEAR,FAILURE_QTR,MONTH_NO --,EQUIP_ABBREV
	  )) AS [50_PERCENT_CONT]
	,CONVERT(DECIMAL(10,2),PERCENTILE_DISC(0.50) -- discrete
		WITHIN GROUP (ORDER BY SUM(FAILURE) )
		OVER(
			PARTITION BY FAILURE_YEAR,FAILURE_QTR,MONTH_NO --,EQUIP_ABBREV
	  )) AS [50_PERCENT_DISC]
	 ,CONVERT(DECIMAL(10,2),PERCENTILE_CONT(0.90) -- continuous
		WITHIN GROUP (ORDER BY SUM(FAILURE) )
		OVER(
			PARTITION BY FAILURE_YEAR,FAILURE_QTR,MONTH_NO --,EQUIP_ABBREV
	  )) AS [90_PERCENT_CONT]
	,CONVERT(DECIMAL(10,2),PERCENTILE_DISC(0.90) -- discrete
		WITHIN GROUP (ORDER BY SUM(FAILURE) )
		OVER(
			PARTITION BY FAILURE_YEAR,FAILURE_QTR,MONTH_NO --,EQUIP_ABBREV
	  )) AS [90_PERCENT_DISC]
FROM (
SELECT DISTINCT
	CAL.[CALENDAR_YEAR] AS FAILURE_YEAR
	,CAL.[QUARTER_NAME] AS FAILURE_QTR
	,CAL.[CALENDAR_MONTH] AS MONTH_NO
	,CAL.[MONTH_ABBREV] AS MONTH_ABBREV
	,CAL.[CALENDAR_MONTH_WEEK] AS WEEK_NO
	,CAL.[CALENDAR_DATE]
	,E.EQUIP_ABBREV AS EQUIP_ABBREV 
	,EF.FAILURE AS FAILURE
	 
FROM [DIM].[EQUIPMENT] E
JOIN [FACT].[EQUIPMENT_FAILURE] EF
	ON E.EQUIPMENT_KEY = EF.EQUIPMENT_KEY
JOIN [DIM].[MANUFACTURER] M
	ON E.MANUFACTURER_ID = M.MANUFACTURER_ID
JOIN [DIM].[CALENDAR_VIEW] CAL
	ON EF.CALENDAR_KEY = CAL.CALENDAR_KEY
JOIN [DIM].[LOCATION] L
	ON EF.LOCATION_KEY = L.LOCATION_KEY
WHERE L.LOCATION_NAME = 'Boiler Room'
AND E.EQUIP_ABBREV = 'VLV'
AND E.[EQUIPMENT_TYPE] = '04'
AND M.MANUFACTURER_ID = 'MANU001'
AND L.PLANT_ID = 'PP000001'
AND CAL.[CALENDAR_YEAR] = 2010
)FR
GROUP BY
	FAILURE_YEAR
	,FAILURE_QTR
	,MONTH_NO
	,MONTH_ABBREV
	,WEEK_NO
	,EQUIP_ABBREV 
ORDER BY
	FAILURE_YEAR
	,FAILURE_QTR
	,MONTH_NO
	,WEEK_NO
	,EQUIP_ABBREV
GO