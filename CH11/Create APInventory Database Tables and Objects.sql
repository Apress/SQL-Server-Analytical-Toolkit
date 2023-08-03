USE [APInventory]
GO
/****** Object:  Schema [MasterData]    Script Date: 7/7/2023 11:59:23 AM ******/
CREATE SCHEMA [MasterData]
GO
/****** Object:  Schema [Product]    Script Date: 7/7/2023 11:59:23 AM ******/
CREATE SCHEMA [Product]
GO
/****** Object:  Schema [Reports]    Script Date: 7/7/2023 11:59:23 AM ******/
CREATE SCHEMA [Reports]
GO
/****** Object:  Schema [Tools]    Script Date: 7/7/2023 11:59:23 AM ******/
CREATE SCHEMA [Tools]
GO
/****** Object:  Table [Product].[Warehouse]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Product].[Warehouse](
	[LocId] [varchar](4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[WhName] [varchar](64) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[InvOut] [int] NOT NULL,
	[InvIn] [int] NOT NULL,
	[QtyOnHand] [int] NOT NULL,
	[ReorderLevel] [int] NOT NULL,
	[AsOfYear] [int] NOT NULL,
	[AsOfMonth] [int] NOT NULL,
	[AsOfDate] [varchar](10) NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  View [Product].[WarehouseMonthly]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [Product].[WarehouseMonthly]
AS
SELECT W.[LocId]
      ,W.[InvId]
      ,W.[WhId]
      ,W.[WhName]
      ,W.[ProdId]
      ,W2.InvOut AS InvOut
      ,W2.InvIn AS InvIn
      ,W.[QtyOnHand]
      ,W.[ReorderLevel]
      ,W.[AsOfYear]
      ,W.[AsOfMonth]
      ,W.[AsOfDate]
FROM [Product].[Warehouse] W
JOIN (
	SELECT [LocId]
      ,[InvId]
      ,[WhId]
	  ,[ProdId]
	  ,[AsOfYear]
      ,[AsOfMonth]
	  ,SUM(InvOut) AS InvOut,SUM(InvIn) AS InvIn
	FROM [Product].[Warehouse] 
	GROUP BY [LocId]
      ,[InvId]
      ,[WhId]
	  ,[ProdId]
	  ,[AsOfYear]
      ,[AsOfMonth]
	) W2
ON (
	 W2.[LocId] = W.[LocId]
    AND W2.[InvId] = W.[InvId]
    AND W2.[WhId] = W.[WhId]
	AND W2.[ProdId] = W.[ProdId]
	AND W2.[AsOfYear] = W.[AsOfYear]
    AND W2.[AsOfMonth] = W.[AsOfMonth]
	)
WHERE W.[AsOfDate] = EOMONTH(CONVERT(VARCHAR,YEAR(W.AsOfDate)),(MONTH(W.AsOfDate) - 1))
/*ORDER BY W.[LocId]
      ,W.[InvId]
      ,W.[WhId]
      ,W.[ProdId]
      ,W.[AsOfYear]
      ,W.[AsOfMonth]
      ,W.[AsOfDate]
	*/
GO
/****** Object:  Table [dbo].[ErrorLog]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLog](
	[ErrorNo] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProc] [nvarchar](128) NULL,
	[ErrorLine] [int] NULL,
	[ErrorMsg] [nvarchar](4000) NULL,
	[ErrorDate] [datetime] NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [MasterData].[Calendar]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[Calendar](
	[CalendarKey] [int] NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[CalendarQtr] [int] NULL,
	[CalendarMonth] [int] NULL,
	[CalendarDate] [date] NOT NULL,
	[CalendarTxtQuarter] [char](11) NULL,
	[CalendarTxtMonth] [char](3) NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [MasterData].[Country]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[Country](
	[CountryKey] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](256) NOT NULL,
	[IS02CountryCode] [nvarchar](2) NOT NULL,
	[IS03CountryCode] [nvarchar](3) NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [MasterData].[Location]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[Location](
	[LocKey] [int] IDENTITY(1,1) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[LocName] [varchar](64) NOT NULL,
	[LocCountry] [varchar](64) NOT NULL,
	[LocState] [varchar](64) NOT NULL,
	[LocCity] [varchar](64) NOT NULL,
	[LocAddress] [varchar](64) NOT NULL,
	[LocPostalCode] [varchar](24) NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [MasterData].[LocationOld]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[LocationOld](
	[LocId] [varchar](4) NOT NULL,
	[LocName] [varchar](64) NOT NULL,
	[LocCountry] [varchar](64) NOT NULL,
	[LocState] [varchar](64) NOT NULL,
	[LocCity] [varchar](64) NOT NULL,
	[LocAddress] [varchar](64) NOT NULL,
	[LocPostalCode] [varchar](24) NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [MasterData].[Product]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[Product](
	[ProdId] [varchar](4) NOT NULL,
	[ProdName] [varchar](64) NOT NULL,
	[RetailPrice] [decimal](10, 2) NOT NULL,
	[WholesalePrice] [decimal](10, 2) NOT NULL,
	[ProdType] [varchar](4) NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [MasterData].[ProductType]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MasterData].[ProductType](
	[ProdType] [varchar](4) NOT NULL,
	[ProdTypeName] [varchar](64) NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [Product].[Inventory]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Product].[Inventory](
	[LocId] [varchar](4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[Units] [int] NULL,
	[AsOfDate] [datetime] NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [Product].[InventoryMovementHistory]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Product].[InventoryMovementHistory](
	[InvId] [varchar](4) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[QtyOnHand] [int] NULL,
	[MovementDate] [date] NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [Product].[InventorySalesReport]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Product].[InventorySalesReport](
	[AsOfYear] [int] NOT NULL,
	[AsOfMonth] [int] NOT NULL,
	[AsOfDate] [date] NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[RetailPrice] [money] NOT NULL,
	[InvOutTotal] [int] NULL,
	[SalesTotal] [money] NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [Product].[InventoryTransaction]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Product].[InventoryTransaction](
	[Increment] [int] NULL,
	[Decrement] [int] NULL,
	[MovementDate] [date] NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[LocId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[ProdId] [varchar](4) NOT NULL
) ON [AP_INVENTORY_FG]
GO
/****** Object:  Table [Reports].[InventoryReOrderAlert]    Script Date: 7/7/2023 11:59:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reports].[InventoryReOrderAlert](
	[InventoryYear] [int] NULL,
	[InventoryMonth] [int] NULL,
	[LocId] [varchar](4) NOT NULL,
	[InvId] [varchar](4) NOT NULL,
	[WhId] [varchar](5) NOT NULL,
	[ProdId] [varchar](4) NOT NULL,
	[ItemsRemaining] [int] NULL
) ON [AP_INVENTORY_FG]
GO
