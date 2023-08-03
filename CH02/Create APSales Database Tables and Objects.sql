USE [APSales]
GO
/****** Object:  Schema [Demographics]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [Demographics]
GO
/****** Object:  Schema [DIM]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [DIM]
GO
/****** Object:  Schema [DimTable]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [DimTable]
GO
/****** Object:  Schema [FACT]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [FACT]
GO
/****** Object:  Schema [FactTable]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [FactTable]
GO
/****** Object:  Schema [MASTER_DATA]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [MASTER_DATA]
GO
/****** Object:  Schema [SalesReports]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [SalesReports]
GO
/****** Object:  Schema [STAGE]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [STAGE]
GO
/****** Object:  Schema [StagingTable]    Script Date: 7/7/2023 10:49:12 AM ******/
CREATE SCHEMA [StagingTable]
GO
/****** Object:  Table [DimTable].[Customer]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Customer](
	[CustomerKey] [int] IDENTITY(1,1) NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[CustomerFullName] [nvarchar](256) NOT NULL,
	[CustomerFirstName] [nvarchar](256) NOT NULL,
	[CustomerLastName] [nvarchar](256) NOT NULL,
	[StoreNo] [nvarchar](32) NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [DimTable].[Store]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Store](
	[StoreKey] [int] IDENTITY(1,1) NOT NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  View [DimTable].[StoreSalesPerson]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [DimTable].[StoreSalesPerson]
AS
SELECT S.[StoreNo]
      ,S.[StoreName]
      ,S.[StoreTerritory]
	  ,C.CustomerNo AS SalesPersonNo
	  ,C.CustomerLastName AS SalesPersonLastName
	  ,C.CustomerFirstName AS SalesPersonFirstName
	  ,C.CustomerFullName AS SalesPersonFullName
  FROM [APSales].[DimTable].[Store] S
JOIN [DimTable].[Customer] C
ON S.StoreNo = C.StoreNo
-- for debugging
--ORDER BY S.StoreNo,C.CustomerNo
GO
/****** Object:  Table [SalesReports].[YearlySalesReport]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SalesReports].[YearlySalesReport](
	[CustomerFullName] [nvarchar](256) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[ProductName] [nvarchar](256) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductCategoryName] [nvarchar](256) NOT NULL,
	[ProductSubCategoryName] [nvarchar](256) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[TransactionQuantity] [int] NOT NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[UnitRetailPrice] [decimal](10, 2) NOT NULL,
	[UnitSalesTaxAmount] [decimal](10, 2) NOT NULL,
	[TotalWholeSaleAmount] [decimal](10, 2) NULL,
	[TotalSalesAmount] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO
/****** Object:  View [DimTable].[StoreSalesPersonPurchaseActivity]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
ORDER BY SSP.[StoreNo]
      ,SSP.[StoreName]
      ,SSP.[StoreTerritory]
      ,SSP.[SalesPersonNo]
      ,SSP.[SalesPersonLastName]
      ,SSP.[SalesPersonFirstName]
	  ,SSP.[SalesPersonFullName]
	  ,YSP.CalendarDate
	  ,YSP.ProductNo
*/
CREATE VIEW [DimTable].[StoreSalesPersonPurchaseActivity]
AS
SELECT SSP.StoreNo, SSP.StoreName, SSP.StoreTerritory, SSP.SalesPersonNo, SSP.SalesPersonLastName, SSP.SalesPersonFirstName, SSP.SalesPersonFullName, YSP.CalendarDate AS SalesTransactionDate, YSP.ProductNo, YSP.TransactionQuantity, YSP.ProductWholeSalePrice AS WholeSalesPrice, YSP.UnitRetailPrice, YSP.TransactionQuantity * YSP.ProductWholeSalePrice AS TotalPurchaseAmount, 
         YSP.TransactionQuantity * YSP.UnitRetailPrice AS TotalRetailSalesAmount, YSP.TransactionQuantity * YSP.UnitRetailPrice - YSP.TransactionQuantity * YSP.ProductWholeSalePrice AS MarkupSalesAmount
FROM  DimTable.StoreSalesPerson AS SSP INNER JOIN
             (SELECT StoreNo, CustomerFullName, CalendarDate, ProductNo, TransactionQuantity, ProductWholeSalePrice, UnitRetailPrice
           FROM   SalesReports.YearlySalesReport) AS YSP ON SSP.StoreNo = YSP.StoreNo AND SSP.SalesPersonFullName = YSP.CustomerFullName
GO
/****** Object:  Table [StagingTable].[SalesTransaction]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [StagingTable].[SalesTransaction](
	[CountryName] [nvarchar](256) NOT NULL,
	[ISO2CountryCode] [nvarchar](2) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[StoreNo] [nvarchar](32) NULL,
	[CalendarDate] [date] NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[TransactionQuantity] [int] NULL,
	[UnitRetailPrice] [decimal](10, 2) NOT NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[UnitSalesTaxAmount] [decimal](10, 2) NULL,
	[TotalSalesAmount] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO
/****** Object:  View [dbo].[SalesPersonActivityReport-TEST]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SalesPersonActivityReport-TEST]
AS
SELECT YEAR([CalendarDate]) AS SalesYear
	  ,MONTH([CalendarDate]) AS SalesMonth
	  ,'SP-' + [CustomerNo] AS SalesPersonNo
      ,[StoreNo]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductNo]
	  ,[TransactionQuantity]
	  ,[UnitRetailPrice]
	  ,[TotalSalesAmount] AS UnitRetailSaleAmount
      ,SUM([TotalSalesAmount]) AS TotalMonthlyRetailSales
FROM [APSales].[StagingTable].[SalesTransaction]
GROUP BY YEAR([CalendarDate])
	  ,MONTH([CalendarDate])
	  ,[CustomerNo]
      ,[StoreNo]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductNo]
	  ,[TransactionQuantity]
	  ,[UnitRetailPrice]
	  ,[TotalSalesAmount]
/*ORDER BY YEAR([CalendarDate])
	  ,MONTH([CalendarDate])
	  ,[CustomerNo]
      ,[StoreNo]
      ,[ProductCategoryCode]
      ,[ProductSubCategoryCode]
      ,[ProductNo]
	  */
GO
/****** Object:  Table [DimTable].[Calendar]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Calendar](
	[CalendarKey] [int] NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarYear] [nvarchar](32) NOT NULL,
	[CalendarQuarter] [int] NOT NULL,
	[CalendarQuarterAbbrev] [char](2) NOT NULL,
	[CalendarMonth] [int] NOT NULL,
	[CalendarMonthAbbrev] [nvarchar](32) NOT NULL,
	[DayOfMonth] [smallint] NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  View [DimTable].[CalendarView]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [DimTable].[CalendarView]
AS
SELECT [CalendarKey],
       [CalendarYear],
       [CalendarQuarter],
       CASE WHEN [CalendarQuarter] = 1 THEN '1st Quarter' WHEN [CalendarQuarter] = 2 THEN '2nd Quarter' WHEN [CalendarQuarter] = 3 THEN '3rd Quarter' WHEN [CalendarQuarter] = 4 THEN '4th Quarter' END AS Quarter_Name,
       [CalendarMonth],
       CASE WHEN [CalendarMonth] = 1 THEN 'Jan' WHEN [CalendarMonth] = 2 THEN 'Feb' WHEN [CalendarMonth] = 3 THEN 'Mar' WHEN [CalendarMonth] = 4 THEN 'Apr' WHEN [CalendarMonth] = 5 THEN 'May' WHEN [CalendarMonth] = 6 THEN 'Jun' WHEN [CalendarMonth] = 7 THEN 'Jul' WHEN [CalendarMonth] = 8 THEN 'Aug' WHEN [CalendarMonth] = 9 THEN 'Sep' WHEN [CalendarMonth] = 10 THEN 'Oct' WHEN [CalendarMonth] = 11 THEN 'Nov' WHEN [CalendarMonth] = 12 THEN 'Dec' END AS MonthAbbrev,
       CASE WHEN [CalendarMonth] = 1 THEN 'January' WHEN [CalendarMonth] = 2 THEN 'February' WHEN [CalendarMonth] = 3 THEN 'March' WHEN [CalendarMonth] = 4 THEN 'April' WHEN [CalendarMonth] = 5 THEN 'May' WHEN [CalendarMonth] = 6 THEN 'June' WHEN [CalendarMonth] = 7 THEN 'July' WHEN [CalendarMonth] = 8 THEN 'August' WHEN [CalendarMonth] = 9 THEN 'September' WHEN [CalendarMonth] = 10 THEN 'October' WHEN [CalendarMonth] = 11 THEN 'November' WHEN [CalendarMonth] = 12 THEN 'December' END AS [MonthName],
       [CalendarDate]
FROM   [DimTable].[Calendar];

GO
/****** Object:  View [DimTable].[SalesView]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [DimTable].[SalesView]
AS
SELECT   DISTINCT YEAR(CalendarDate) AS Year,
                  DATEPART(qq, CalendarDate) AS Quarter,
                  MONTH(CalendarDate) AS Month,
                  ProductNo,
                  ProductName,
                  ProductCategoryCode,
                  ProductSubCategoryCode,
                  StoreNo,
                  StoreName,
                  SUM(TotalSalesAmount) AS SumTotal
FROM     FactTable.YearlySalesReport WITH (NOLOCK)
GROUP BY YEAR(CalendarDate), MONTH(CalendarDate), DATEPART(qq, CalendarDate), ProductNo, ProductName, ProductCategoryCode, ProductSubCategoryCode, StoreNo, StoreName;

GO
/****** Object:  Table [dbo].[MemorySalesTotals]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MemorySalesTotals](
	[SalesYear] [int] NULL,
	[SalesQuarter] [int] NULL,
	[SalesMonth] [int] NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[StoreNo] [nvarchar](32) NULL,
	[CalendarDate] [date] NOT NULL,
	[SalesTotal] [decimal](21, 2) NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [Demographics].[CustomerPaymentHistory]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Demographics].[CustomerPaymentHistory](
	[CreditYear] [smallint] NOT NULL,
	[CreditQtr] [smallint] NULL,
	[CustomerKey] [int] NOT NULL,
	[CustomerNo] [nvarchar](32) NOT NULL,
	[CustomerFullName] [nvarchar](256) NOT NULL,
	[TotalPaymentsTodate] [int] NOT NULL,
	[30DaysLatePaymentCount] [int] NOT NULL,
	[60DaysLatePaymentCount] [int] NOT NULL,
	[90DaysLatePaymentCount] [int] NOT NULL,
	[Over90DaysLatePaymentCount] [int] NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [DimTable].[Country]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Country](
	[CountryKey] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](256) NOT NULL,
	[ISO2CountryCode] [nvarchar](2) NOT NULL,
	[ISO3CountryCode] [nvarchar](3) NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [DimTable].[Product]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[Product](
	[ProductKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[ProductName] [nvarchar](256) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[ProductRetailPrice] [decimal](10, 2) NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [DimTable].[ProductCategory]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[ProductCategory](
	[ProductCategoryKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductCategoryName] [nvarchar](256) NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [DimTable].[ProductSubCategory]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DimTable].[ProductSubCategory](
	[ProductSubCategoryKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryName] [nvarchar](256) NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [FactTable].[Sales]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FactTable].[Sales](
	[CustomerKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[CountryKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[CalendarKey] [int] NOT NULL,
	[TransactionQuantity] [int] NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[UnitRetailPrice] [decimal](10, 2) NOT NULL,
	[UnitSalesTaxAmount] [decimal](10, 2) NULL,
	[TotalWholeSaleAmount] [decimal](22, 2) NULL,
	[TotalSalesAmount] [decimal](22, 2) NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [SalesReports].[MemorySalesTotals]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SalesReports].[MemorySalesTotals]
(
	[SalesTotalKey] [int] IDENTITY(1,1) NOT NULL,
	[SalesYear] [int] NOT NULL,
	[SalesQuarter] [int] NOT NULL,
	[SalesMonth] [int] NOT NULL,
	[CustomerNo] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StoreNo] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProductNo] [nvarchar](32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CalendarDate] [date] NOT NULL,
	[SalesTotal] [decimal](10, 2) NULL,

INDEX [ieSalesYearStoreNo] NONCLUSTERED 
(
	[SalesYear] ASC,
	[StoreNo] ASC
),
 PRIMARY KEY NONCLUSTERED 
(
	[SalesTotalKey] ASC
)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  Table [SalesReports].[SalesStarReport]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SalesReports].[SalesStarReport](
	[CalendarDate] [date] NOT NULL,
	[CalendarQuarterAbbrev] [char](2) NOT NULL,
	[CalendarMonthAbbrev] [nvarchar](32) NOT NULL,
	[ProductCategoryCode] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL,
	[ProductNo] [nvarchar](32) NOT NULL,
	[ProductName] [nvarchar](256) NOT NULL,
	[CountryName] [nvarchar](256) NOT NULL,
	[ISO2CountryCode] [nvarchar](2) NOT NULL,
	[StoreKey] [nvarchar](3) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL,
	[TransactionQuantity] [int] NOT NULL,
	[ProductWholeSalePrice] [decimal](10, 2) NOT NULL,
	[UnitRetailPrice] [decimal](10, 2) NOT NULL,
	[UnitSalesTaxAmount] [decimal](10, 2) NOT NULL,
	[TotalWholeSaleAmount] [decimal](10, 2) NULL,
	[TotalSalesAmount] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [SalesReports].[YearlySummaryReport]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SalesReports].[YearlySummaryReport](
	[SalesYear] [int] NULL,
	[SalesMonth] [int] NULL,
	[StoreNo] [nvarchar](32) NOT NULL,
	[StoreName] [nvarchar](64) NOT NULL,
	[StoreTerritory] [nvarchar](64) NOT NULL,
	[TotalSales] [decimal](10, 2) NULL
) ON [AP_SALES_FG]
GO
/****** Object:  Table [StagingTable].[CustomerFavoriteProductSubCategories]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [StagingTable].[CustomerFavoriteProductSubCategories](
	[CustomerNo] [nvarchar](32) NOT NULL,
	[ProductSubCategoryCode] [nvarchar](32) NOT NULL
) ON [AP_SALES_FG]
GO
/****** Object:  StoredProcedure [FactTable].[usp_RandomFloat]    Script Date: 7/7/2023 10:49:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [FactTable].[usp_RandomFloat]
@RANDOM_VALUE FLOAT OUTPUT, @START_RANGE FLOAT, @STOP_RANGE FLOAT
AS
SET @RANDOM_VALUE = CONVERT (FLOAT, ROUND(UPPER(RAND() * @STOP_RANGE + @START_RANGE), 0));

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SSP"
            Begin Extent = 
               Top = 15
               Left = 96
               Bottom = 324
               Right = 519
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "YSP"
            Begin Extent = 
               Top = 330
               Left = 96
               Bottom = 639
               Right = 535
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'DimTable', @level1type=N'VIEW',@level1name=N'StoreSalesPersonPurchaseActivity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'DimTable', @level1type=N'VIEW',@level1name=N'StoreSalesPersonPurchaseActivity'
GO
