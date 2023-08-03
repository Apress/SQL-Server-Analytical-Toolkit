-- Listing  9.1 – Ranking Sums of Equipment Failures

WITH FailedEquipmentCount 
(
CalendarYear, QuarterName,[MonthName], CalendarMonth, PlantName, LocationName, SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
)

SELECT
	PlantName
,LocationName
,CalendarYear
,QuarterName
,[MonthName]
,SumEquipFailures
,RANK()  OVER (
		PARTITION BY PlantName,LocationName
		ORDER BY SumEquipFailures DESC
	) AS FailureRank
FROM FailedEquipmentCount
WHERE CalendarYear = 2008
GO
-- Listing  9.2 – Perform Ranking on a large table.
SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,CASE
		WHEN ES.StatusMonth = 1 THEN 'Jan'
		WHEN ES.StatusMonth = 2 THEN 'Feb'
		WHEN ES.StatusMonth = 3 THEN 'Mar'
		WHEN ES.StatusMonth = 4 THEN 'Apr'
		WHEN ES.StatusMonth = 5 THEN 'May'
		WHEN ES.StatusMonth = 6 THEN 'Jun'
		WHEN ES.StatusMonth = 7 THEN 'Jul'
		WHEN ES.StatusMonth = 8 THEN 'Aug'
		WHEN ES.StatusMonth = 9 THEN 'Sep'
		WHEN ES.StatusMonth = 10 THEN 'Oct'
		WHEN ES.StatusMonth = 11THEN 'Nov'
		WHEN ES.StatusMonth = 12 THEN 'Dec'
		END AS MonthName
	  ,EP.LocationId
	  ,L.LocationName
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,RANK() OVER(
		PARTITION BY ES.EquipmentId --,ES.StatusYear
		ORDER BY ES.EquipmentId ASC,ES.StatusYear ASC,StatusCount DESC
		) AS NoFailureRank
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo  
FROM Reports.EquipmentRollingMonthlyHourTotals ES -- 30,000 rows plus
INNER JOIN DimTable.Equipment E
ON ES.EquipmentId = E.EquipmentId
INNER JOIN [DimTable].[PlantEquipLocation] EP
ON ES.EquipmentId = EP.EquipmentId
INNER JOIN DimTable.Plant P
ON EP.PlantId = P.PlantId
INNER JOIN DimTable.Location L
ON EP.PlantId = L.PlantId
AND EP.LocationId = L.LocationId
WHERE ES.StatusYear = 2002
AND ES.EquipOnlineStatusCode = '0001'
GO
-- Listing  9.3 – One Time Load of Report Table
INSERT INTO Reports.EquipmentMonthlyOnLineStatus
SELECT ES.StatusYear AS ReportYear
      ,ES.StatusMonth AS Reportmonth
	  ,CASE
		WHEN ES.StatusMonth = 1 THEN 'Jan'
		WHEN ES.StatusMonth = 2 THEN 'Feb'
		WHEN ES.StatusMonth = 3 THEN 'Mar'
		WHEN ES.StatusMonth = 4 THEN 'Apr'
		WHEN ES.StatusMonth = 5 THEN 'May'
		WHEN ES.StatusMonth = 6 THEN 'Jun'
		WHEN ES.StatusMonth = 7 THEN 'Jul'
		WHEN ES.StatusMonth = 8 THEN 'Aug'
		WHEN ES.StatusMonth = 9 THEN 'Sep'
		WHEN ES.StatusMonth = 10 THEN 'Oct'
		WHEN ES.StatusMonth = 11THEN 'Nov'
		WHEN ES.StatusMonth = 12 THEN 'Dec'
		END AS MonthName
	  ,EP.LocationId
	  ,L.LocationName
	  ,ES.EquipmentId
	  ,StatusCount 
	  ,ES.EquipOnlineStatusCode
	  ,ES.EquipOnLineStatusDesc
	  ,EP.PlantId
	  ,P.PlantName
	  ,P.PlantDescription
	  ,ES.EquipAbbrev
	  ,EP.UnitId
	  ,EP.UnitName
	  ,E.SerialNo  
-- Created table with:
-- INTO  Reports.EquipmentMonthlyOnLineStatus
FROM Reports.EquipmentRollingMonthlyHourTotals ES -- 30,240 rows plus
INNER JOIN DimTable.Equipment E
ON ES.EquipmentId = E.EquipmentId
INNER JOIN [DimTable].[PlantEquipLocation] EP
ON ES.EquipmentId = EP.EquipmentId
INNER JOIN DimTable.Plant P
ON EP.PlantId = P.PlantId
INNER JOIN DimTable.Location L
ON EP.PlantId = L.PlantId
AND EP.LocationId = L.LocationId
ORDER BY ES.StatusYear
      ,ES.StatusMonth
	  ,EP.LocationId
	  ,ES.EquipmentId
	  ,ES.EquipOnlineStatusCode
	  ,EP.PlantId
GO
-- Listing  9.4 – The New and Improved Query
SELECT ReportYear
      ,Reportmonth
	  ,MonthName
	  ,LocationId
	  ,LocationName
	  ,EquipmentId
	  ,StatusCount 
	  ,RANK() OVER(
		PARTITION BY EquipmentId,ReportYear
		ORDER BY LocationId,EquipmentId ASC,ReportYear ASC,
StatusCount DESC
		) AS NoFailureRank
	  ,EquipOnlineStatusCode
	  ,EquipOnLineStatusDesc
	  ,PlantId
	  ,PlantName
	  ,PlantDescription
	  ,EquipAbbrev
	  ,UnitId
	  ,UnitName
	  ,SerialNo  
FROM Reports.EquipmentMonthlyOnLineStatus -- 30,240 rows plus
WHERE ReportYear = 2002
AND EquipOnlineStatusCode = '0001'
AND EquipmentId = 'P1L1VLV1'
ORDER BY ReportYear
      ,Reportmonth
	,LocationId
	,EquipmentId
	,EquipOnlineStatusCode
	,PlantId
GO
-- Listing  9.5 – Recommended Index
/*
Missing Index Details from SQLQuery2.sql - DESKTOP-CEBK38L\GRUMPY2019I1.APPlant (DESKTOP-CEBK38L\Angelo (54))
The Query Processor estimates that implementing the following index could improve the query cost by 91.7476%.
*/
CREATE NONCLUSTERED INDEX ieEquipmentMonthlyOnLineStatus
ON Reports.EquipmentMonthlyOnLineStatus (ReportYear,EquipmentId,EquipOnlineStatusCode)
INCLUDE (
Reportmonth,MonthName,LocationId,LocationName,StatusCount,
EquipOnLineStatusDesc,PlantId,PlantName,PlantDescription,
EquipAbbrev,UnitId,UnitName,SerialNo
)
GO
-- Listing  9.6 – RANK() versus DENSE_RANK() Report
SELECT 
	EMOLS.PlantName
	,EMOLS.LocationName
	,EMOLS.ReportYear
	,MSC.CalendarQuarter AS ReportQuarter
	,EMOLS.[MonthName] AS ReportMonth
	,EMOLS.StatusCount
	,EMOLS.EquipOnlineStatusCode
	,EMOLS.EquipOnLineStatusDesc
	-- skips next value in sequence in case of ties
	,RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName --,EMOLS.ReportYear,
	,EMOLS.EquipOnlineStatusCode
	ORDER BY EMOLS.StatusCount DESC
	) AS FailureRank

	-- preserves sequence even with ties
	,DENSE_RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName --,EMOLS.ReportYear,
	,EMOLS.EquipOnlineStatusCode
	ORDER BY EMOLS.StatusCount DESC
	) AS FailureDenseRank

FROM Reports.EquipmentMonthlyOnLineStatus EMOLS
INNER JOIN (
	SELECT DISTINCT [CalendarYear]
		,[CalendarQuarter]
		,CASE
			WHEN CalendarMonth = 1 THEN 'Jan'
			WHEN CalendarMonth = 2 THEN 'Feb'
			WHEN CalendarMonth = 3 THEN 'Mar'
			WHEN CalendarMonth = 4 THEN 'Apr'
			WHEN CalendarMonth = 5 THEN 'May'
			WHEN CalendarMonth = 6 THEN 'Jun'
			WHEN CalendarMonth = 7 THEN 'Jul'
			WHEN CalendarMonth = 8 THEN 'Aug'
			WHEN CalendarMonth = 9 THEN 'Sep'
			WHEN CalendarMonth = 10 THEN 'Oct'
			WHEN CalendarMonth = 11 THEN 'Nov'
			WHEN CalendarMonth = 12 THEN 'Dec'
		END AS CalendarMonthName
	FROM [DimTable].[Calendar]
	) AS MSC
	ON (
	EMOLS.ReportYear = MSC.CalendarYear
	AND EMOLS.MonthName = MSC.CalendarMonthName
	)
WHERE EMOLS.ReportYear = 2002
AND EMOLS.EquipmentId = 'P1L1VLV1'
GO 
-- Listing  9.7 – A Better Solution
SELECT 
	EMOLS.PlantName
	,EMOLS.LocationName
	,EMOLS.ReportYear
	,CASE
		WHEN EMOLS.[MonthName] = 'Jan' THEN 'Qtr 1'
		WHEN EMOLS.[MonthName] = 'Feb' THEN 'Qtr 1'
		WHEN EMOLS.[MonthName] = 'Mar' THEN 'Qtr 1'
		WHEN EMOLS.[MonthName] = 'Apr' THEN 'Qtr 2'
		WHEN EMOLS.[MonthName] = 'May' THEN 'Qtr 2'
		WHEN EMOLS.[MonthName] = 'Jun' THEN 'Qtr 2'
		WHEN EMOLS.[MonthName] = 'Jul' THEN 'Qtr 3'
		WHEN EMOLS.[MonthName] = 'Aug' THEN 'Qtr 3'
		WHEN EMOLS.[MonthName] = 'Sep' THEN 'Qtr 3'
		WHEN EMOLS.[MonthName] = 'Oct' THEN 'Qtr 4'
		WHEN EMOLS.[MonthName] = 'Nov' THEN 'Qtr 4'
		WHEN EMOLS.[MonthName] = 'Dec' THEN 'Qtr 4'
	END AS CalendarMonthName
	,EMOLS.[MonthName] AS ReportMonth
	,EMOLS.StatusCount
	,EMOLS.EquipOnlineStatusCode
	,EMOLS.EquipOnLineStatusDesc
	-- skips next value in sequence in case of ties
	,RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName,EMOLS.ReportYear,
EMOLS.EquipOnlineStatusCode
	ORDER BY StatusCount DESC
	) AS FailureRank

	-- preserves sequence even with ties
	,DENSE_RANK()  OVER (
	PARTITION BY EMOLS.PlantName,EMOLS.LocationName,EMOLS.ReportYear,
EMOLS.EquipOnlineStatusCode
	ORDER BY EMOLS.StatusCount DESC
	) AS FailureDenseRank
FROM Reports.EquipmentMonthlyOnLineStatus EMOLS
WHERE EMOLS.ReportYear = 2002
AND EMOLS.EquipmentId = 'P1L1VLV1'
GO


-- Listing  9.8a – First CTE – Summing Logic
WITH FailedEquipmentCount 
(
CalendarYear,QuarterName,[MonthName],CalendarMonth,PlantName,LocationName,SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
	,SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId
GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.[MonthName]
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
),

-- Listing  9.8b – NILE() Bucket CTE
FailureBucket (
PlantName,LocationName,CalendarYear,QuarterName,[MonthName],CalendarMonth,SumEquipFailures,MonthBucket)
AS (
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName],
CalendarMonth,SumEquipFailures,
	NTILE(5)  OVER (
	PARTITION BY PlantName,LocationName
	ORDER BY SumEquipFailures
	) AS MonthBucket
FROM FailedEquipmentCount
WHERE CalendarYear = 2008
)

-- Listing  9.8c – Categorize the Failure Buckets
SELECT PlantName,LocationName,CalendarYear,QuarterName,[MonthName],SumEquipFailures,
CASE	
	WHEN MonthBucket = 5 AND SumEquipFailures <> 0 THEN 'Severe Failures'
	WHEN MonthBucket = 4 AND SumEquipFailures <> 0 THEN 'Critical Failures'
	WHEN MonthBucket = 3 AND SumEquipFailures <> 0 THEN 'Moderate Failures'
WHEN MonthBucket = 2 AND SumEquipFailures <> 0 THEN 'Investigate Failures'
	WHEN MonthBucket = 1 AND SumEquipFailures <> 0 THEN 'Maintenance Failures'
WHEN MonthBucket = 1 AND SumEquipFailures = 0 
THEN 'No issues to report'
	ELSE 'No Alerts'
END AS AlertMessage
FROM FailureBucket
GO
-- Listing  9.9 – Improved Query
WITH FailedEquipmentCount 
AS (
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName]
,CalendarMonth,SumEquipmentFailure,
	NTILE(5)  OVER (
	PARTITION BY PlantName,LocationName
	ORDER BY SumEquipmentFailure
	) AS MonthBucket
FROM Reports.EquipmentFailureStatistics
WHERE CalendarYear = 2008
)

SELECT 
PlantName, LocationName, CalendarYear, QuarterName, [MonthName], SumEquipmentFailure,
CASE	
		WHEN MonthBucket = 5 AND SumEquipmentFailure <> 0 
THEN 'Severe Failures'
		WHEN MonthBucket = 4 AND SumEquipmentFailure <> 0 
THEN 'Critical Failures'
		WHEN MonthBucket = 3 AND SumEquipmentFailure <> 0 
THEN 'Moderate Failures'
		WHEN MonthBucket = 2 AND SumEquipmentFailure <> 0 
THEN 'Investigate Failures'
		WHEN MonthBucket = 1 AND SumEquipmentFailure <> 0 
THEN 'Maintenance Failures'
	    WHEN MonthBucket = 1 AND SumEquipmentFailure = 0 
THEN 'No issues to report'
	ELSE 'No Alerts'
END AS AlertMessage
FROM FailedEquipmentCount 
GO
-- Listing  9.10 – Failure Event Buckets with Bucket Slot Number
WITH FailedEquipmentCount 
AS (
SELECT PlantName, LocationName, CalendarYear, QuarterName, [MonthName],
CalendarMonth, SumEquipmentFailure,
	NTILE(5)  OVER (
	PARTITION BY PlantName,LocationName
	ORDER BY SumEquipmentFailure
	) AS MonthBucket
FROM [Reports].[EquipmentFailureStatistics]
)

SELECT PlantName,LocationName,CalendarYear,QuarterName,[MonthName]
	,CASE	
		WHEN MonthBucket = 5 AND SumEquipmentFailure <> 0 
THEN 'Severe Failures'
		WHEN MonthBucket = 4 AND SumEquipmentFailure <> 0 
THEN 'Critical Failures'
		WHEN MonthBucket = 3 AND SumEquipmentFailure <> 0 
THEN 'Moderate Failures'
		WHEN MonthBucket = 2 AND SumEquipmentFailure <> 0 
THEN 'Investigate Failures'
		WHEN MonthBucket = 1  AND SumEquipmentFailure <> 0 
THEN 'Maintenance Failures'
	    	WHEN MonthBucket = 1  AND SumEquipmentFailure = 0 
THEN 'No issues to report'
	ELSE 'No Alerts'
	END AS StatusBucket
	,ROW_NUMBER()  OVER (
	PARTITION BY (
	CASE	
		WHEN MonthBucket = 5 AND SumEquipmentFailure <> 0 
THEN 'Severe Failures'
		WHEN MonthBucket = 4 AND SumEquipmentFailure <> 0 
THEN 'Critical Failures'
		WHEN MonthBucket = 3 AND SumEquipmentFailure <> 0 
THEN 'Moderate Failures'
		WHEN MonthBucket = 2 AND SumEquipmentFailure <> 0 
THEN 'Investigate Failures'
		WHEN MonthBucket = 1  AND SumEquipmentFailure <> 0 
THEN 'Maintenance Failures'
	    	WHEN MonthBucket = 1  AND SumEquipmentFailure = 0 
THEN 'No issues to report'
	ELSE 'No Alerts'
	END
	)
	ORDER BY SumEquipmentFailure
	) AS BucketEventNumber
	,SumEquipmentFailure AS EquipmentFailures
FROM FailedEquipmentCount 
WHERE CalendarYear IN (2008,2009,2010)
GO
