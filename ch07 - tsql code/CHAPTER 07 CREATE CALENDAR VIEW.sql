USE [AP_SALES]
GO

CREATE VIEW [DIM].[CALENDAR_VIEW]
AS
SELECT [CalendarKey],
       [CalendarYear],
       [CalendarQuarter],
       CASE 
		WHEN [CalendarQuarter] = 1 THEN '1st Quarter' 
		WHEN [CalendarQuarter] = 2 THEN '2nd Quarter' 
		WHEN [CalendarQuarter] = 3 THEN '3rd Quarter' 
		WHEN [CalendarQuarter] = 4 THEN '4th Quarter' 
		END AS QUARTER_NAME,
       [CalendarMonth],
       CASE WHEN [CalendarMonth] = 1 THEN 'Jan' 
	   WHEN [CalendarMonth] = 2 THEN 'Feb' 
	   WHEN [CalendarMonth] = 3 THEN 'Mar' 
	   WHEN [CalendarMonth] = 4 THEN 'Apr' 
	   WHEN [CalendarMonth] = 5 THEN 'May' 
	   WHEN [CalendarMonth] = 6 THEN 'Jun' 
	   WHEN [CalendarMonth] = 7 THEN 'Jul' 
	   WHEN [CalendarMonth] = 8 THEN 'Aug' 
	   WHEN [CalendarMonth] = 9 THEN 'Sep' 
	   WHEN [CalendarMonth] = 10 THEN 'Oct' 
	   WHEN [CalendarMonth] = 11 THEN 'Nov' 
	   WHEN [CalendarMonth] = 12 THEN 'Dec' 
	   END AS MONTH_ABBREV,
       CASE WHEN [CalendarMonth] = 1 THEN 'January' 
	   WHEN [CalendarMonth] = 2 THEN 'February' 
	   WHEN [CalendarMonth] = 3 THEN 'March' 
	   WHEN [CalendarMonth] = 4 THEN 'April' 
	   WHEN [CalendarMonth] = 5 THEN 'May' 
	   WHEN [CalendarMonth] = 6 THEN 'June' 
	   WHEN [CalendarMonth] = 7 THEN 'July' 
	   WHEN [CalendarMonth] = 8 THEN 'August' 
	   WHEN [CalendarMonth] = 9 THEN 'September' 
	   WHEN [CalendarMonth] = 10 THEN 'October' 
	   WHEN [CalendarMonth] = 11 THEN 'November' 
	   WHEN [CalendarMonth] = 12 THEN 'December' 
	   END AS MONTH_NAME,
       [CalendarDate]
FROM   [DIM].[CALENDAR];
GO


