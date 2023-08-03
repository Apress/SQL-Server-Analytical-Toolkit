DROP TABLE IF EXISTS [dbo].[ErrorLog]
GO

CREATE TABLE [dbo].[ErrorLog](
	[ErrorNo]		[int] NULL,
	[ErrorSeverity]	[int] NULL,
	[ErrorState]	[int] NULL,
	[ErrorProc]		[nvarchar](128) NULL,
	[ErrorLine]		[int] NULL,
	[ErrorMsg]		[nvarchar](4000) NULL,
	[ErrorDate]		[datetime]
)
GO

INSERT INTO [dbo].[ErrorLog]
SELECT  
       ERROR_NUMBER()		AS [ERROR_NO]  
      ,ERROR_SEVERITY()	    AS [ERROR_SEVERITY]
      ,ERROR_STATE()		AS [ERROR_STATE]  
      ,ERROR_PROCEDURE()	AS [ERROR_PROC] 
      ,ERROR_LINE()		AS [ERROR_LINE] 
      ,ERROR_MESSAGE()	AS [ERROR_MSG]
	,GETDATE()			AS [ERROR_DATE];  
GO
