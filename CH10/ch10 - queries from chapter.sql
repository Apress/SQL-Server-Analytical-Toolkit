-- Listing  10.1 –Cumulative Distribution Reports for Failures
WITH FailedEquipmentCount 
(
CalendarYear, QuarterName, MonthName, CalendarMonth, PlantName, LocationName, SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
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
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
)
SELECT
	PlantName, LocationName, CalendarYear, QuarterName,
MonthName, CalendarMonth
	,SumEquipFailures
	,FORMAT(CUME_DIST() OVER (
	 ORDER BY SumEquipFailures 
	),'P') AS CumeDist
FROM FailedEquipmentCount
WHERE CalendarYear = 2002
AND LocationName = 'Boiler Room'
AND PlantName = 'East Plant'
GO
-- Listing  10.2 – First and Last Values for Failures By Plant, Location and Year
WITH FailedEquipmentCount 
(
CalendarYear, QuarterName, MonthName, CalendarMonth, PlantName, LocationName, SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
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
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
)

SELECT PlantName, LocationName, CalendarYear, QuarterName, MonthName,   CalendarMonth, SumEquipFailures
	,FIRST_VALUE(SumEquipFailures) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS FirstValue
	,LAST_VALUE(SumEquipFailures) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS LastValue
FROM FailedEquipmentCount
GO
-- Listing  10.3 – Last month’s Equipment Failures
WITH FailedEquipmentCount 
(
CalendarYear, QuarterName, MonthName, CalendarMonth, PlantName, LocationName, SumEquipFailures
)
AS (
SELECT
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
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
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
)
SELECT
PlantName, LocationName, CalendarYear, QuarterName, MonthName, CalendarMonth, SumEquipFailures,
	LAG(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName, LocationName, CalendarYear, QuarterName
		ORDER BY CalendarMonth
	) AS LastFailureSum
FROM FailedEquipmentCount
WHERE CalendarYear > 2008
GO
-- Listing  10.4 – Loading the Report Table
INSERT INTO Reports.PlantSumEquipFailures
SELECT
C.CalendarYear, C.QuarterName, C.MonthName, C.CalendarMonth, P.PlantName,L.LocationName, SUM(EF.Failure) AS SumEquipFailures
FROM DimTable.CalendarView C
JOIN FactTable.EquipmentFailure EF
ON C.CalendarKey = EF.CalendarKey
JOIN DimTable.Equipment E
ON EF.EquipmentKey = E.EquipmentKey
JOIN DimTable.Location L
ON L.LocationKey = EF.LocationKey
JOIN DimTable.Plant P
ON L.PlantId = P.PlantId

-- Here is the daily load
-- use the WHERE clause below to get the current day's values.
-- WHERE C.CalendarDate = CONVERT(DATE,GETDATE())

-- Here is the one time get all prior months load
-- use the WHERE clause below to get the all values for the last month.
-- WHERE MONTH(C.CalendarDate) = DATEDIFF(mm,MONTH(CONVERT(DATE,GETDATE())))

GROUP BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,C.CalendarMonth
	,P.PlantName
	,L.LocationName
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,P.PlantName
	,L.LocationName
GO
-- Listing  10.5 – Querying the Report Table
SELECT
	PlantName, LocationName, CalendarYear, QuarterName, 
MonthName, CalendarMonth, SumEquipFailures,
	LAG(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS LastFailureSum
FROM Reports.PlantSumEquipFailures
WHERE CalendarYear > 2008
GO
-- Listing  10.6 – Equipment Failure Lead Query
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName
,CalendarMonth,SumEquipFailures
	,LEAD(SumEquipFailures,1,0) OVER (
		PARTITION BY PlantName,LocationName,CalendarYear,QuarterName
		ORDER BY CalendarMonth
	) AS NextFailureSum
FROM [Reports].[PlantSumEquipFailures]
WHERE CalendarYear > 2008
GO
-- Listing  10.7 – Percent Rank versus Cumulative Distribution
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth
	,SumEquipFailures
	,FORMAT(PERCENT_RANK() OVER (
		PARTITION BY CalendarYear,PlantName,LocationName
		ORDER BY CalendarYear,PlantName,LocationName,SumEquipFailures
	),'P') AS PercentRank

	,FORMAT(CUME_DIST() OVER (
		PARTITION BY CalendarYear,PlantName,LocationName
		ORDER BY CalendarYear,PlantName,LocationName,SumEquipFailures
	),'P') AS CumeDist
FROM [Reports].[PlantSumEquipFailures]
GO
-- Listing  10.8 – Adding a WHERE clause
SELECT
	PlantName,LocationName,CalendarYear,QuarterName,MonthName,CalendarMonth
	,SumEquipFailures
	,FORMAT(PERCENT_RANK() OVER (
		PARTITION BY CalendarYear,PlantName,LocationName
		ORDER BY CalendarYear,PlantName,LocationName,SumEquipFailures
	),'P') AS PercentRank

	,FORMAT(CUME_DIST() OVER (
		PARTITION BY CalendarYear,PlantName,LocationName
		ORDER BY CalendarYear,PlantName,LocationName,SumEquipFailures
	),'P') AS CumeDist
FROM [Reports].[PlantSumEquipFailures]
WHERE PlantName = 'East Plant'
AND LocationName = 'Boiler Room'
AND CalendarYear = 2002 
GO
-- Listing  10.9 – Percentile continuous analysis for Monthly Failures
SELECT PlantId
	,LocationId
	,LocationName
	,BoilerName
	,CalendarDate
	,Hour
	,BoilerTemperature
	,PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY BoilerTemperature)
	OVER (
	PARTITION BY CalendarDate
	) AS [PercentCont .25]
	,PERCENTILE_CONT(.5) WITHIN GROUP (ORDER BY BoilerTemperature)
	OVER (
	PARTITION BY CalendarDate
	) AS [PercentCont .5]
	,PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY BoilerTemperature)
	OVER (
	PARTITION BY CalendarDate
	) AS [PercentCont .75]
FROM EquipStatistics.BoilerTemperatureHistory
WHERE PlantId = 'PP000002'
AND YEAR(CalendarDate) = 2004
AND BoilerName = 'Boiler 2'
GO
-- Listing  10.10 – Suggested Index for Large Table Query
CREATE NONCLUSTERED INDEX [iePlantBoilerLocationDateHour]
ON [EquipStatistics].[BoilerTemperatureHistory] ([PlantId],[BoilerName])
INCLUDE ([LocationId],[LocationName],[CalendarDate],[Hour],[BoilerTemperature])
GO
-- Listing  10.11 – Percentile Discrete Analysis for Monthly Equipment Failure
WITH FailedEquipmentCount 
(
CalendarYear, QuarterName, [MonthName], CalendarMonth, PlantName, LocationName, SumEquipFailures
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
	PlantName,LocationName,CalendarYear,QuarterName,[MonthName]
,CalendarMonth,SumEquipFailures
	
	-- actual value form list
	,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY SumEquipFailures)
		OVER (
			PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .25]
	
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY SumEquipFailures)
		OVER (
			PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .5]

	,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY SumEquipFailures)
		OVER (
			PARTITION BY PlantName,LocationName,CalendarYear
	) AS [PercentDisc .75]
FROM FailedEquipmentCount
WHERE CalendarYear = 2008
GO
-- Listing  10.12 – Loading the Report Table
INSERT INTO Reports.EquipFailPctContDisc
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
ORDER BY
	C.CalendarYear
	,C.QuarterName
	,C.MonthName
	,P.PlantName
	,L.LocationName
GO
-- Listing  10.13 – Modified Percentile Query
SELECT
	PlantName,LocationName,CalendarYear,QuarterName
,[MonthName],CalendarMonth,SumEquipFailures
	
	-- actual value from list
	,PERCENTILE_DISC(.25) WITHIN GROUP (ORDER BY SumEquipFailures)
		OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		) AS [PercentDisc .25]
	
	,PERCENTILE_DISC(.5) WITHIN GROUP (ORDER BY SumEquipFailures)
		OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		) AS [PercentDisc .5]

	,PERCENTILE_DISC(.75) WITHIN GROUP (ORDER BY SumEquipFailures)
	OVER (
		PARTITION BY PlantName,LocationName,CalendarYear
		) AS [PercentDisc .75]
FROM Reports.EquipFailPctContDisc
WHERE CalendarYear = 2008
GO
-- Listing  10.14 – Adding Surrogate Keys to the Equipment Tables
ALTER TABLE [DimTable].[Generator]
ADD PlantKey INTEGER NULL
GO

ALTER TABLE [DimTable].[Generator]
ADD LocationKey INTEGER NULL
GO

UPDATE [DimTable].[Generator]
SET PlantKey = P.PlantKey
FROM [DimTable].[Generator] G
JOIN [DimTable].[Plant] P
ON G.PlantId = P.PlantId
GO

UPDATE [DimTable].[Generator]
SET LocationKey = P.LocationKey
FROM [DimTable].[Generator] G
JOIN [DimTable].[Location] P
ON G.LocationId = P.LocationId
GO

SELECT * FROM [DimTable].[Generator]
GO
