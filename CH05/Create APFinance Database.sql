USE [master]
GO

/************************/
/* APFinance Database   */
/************************/

/*****************************************/
/* Chapter 05,06,07 - APFinance Database */
/* Create Database                       */
/* Created: 08/19/2022                   */
/* Modified: 07/19/2023                  */
/* Production Folder                     */
/*****************************************/

CREATE DATABASE [APFinance]
 CONTAINMENT = NONE
 ON  PRIMARY 
( 
NAME = N'AP_FINANCE_PRIMARY', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\PRIMARY\AP_FINANCE_PRIMARY.mdf' , 
SIZE = 1GB, 
MAXSIZE = 2GB, 
FILEGROWTH = 64KB 
), 
FILEGROUP [AccountBalances2011] 
(
NAME = N'AccountBalances2011', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA\AccountBalances2011.ndf' , 
SIZE = 500MB, 
MAXSIZE = 1GB, 
FILEGROWTH = 64KB
), 
FILEGROUP [AccountBalances2012] 
(
NAME = N'AccountBalances2012', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA\AccountBalances2012.ndf' , 
SIZE = 500MB, 
MAXSIZE = 1GB, 
FILEGROWTH = 64KB
), 
FILEGROUP [AccountBalances2013] 
( 
NAME = N'AccountBalances2013', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA\AccountBalances2013.ndf' , 
SIZE = 500MB, 
MAXSIZE = 1GB, 
FILEGROWTH = 64KB
), 
FILEGROUP [AccountBalances2014] 
(
NAME = N'AccountBalances2014',
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA\AccountBalances2014.ndf' , 
SIZE = 500MB, 
MAXSIZE = 1GB, 
FILEGROWTH = 64KB
), 
FILEGROUP [AccountBalances2015] 
(
NAME = N'AccountBalances2015', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA\AccountBalances2015.ndf' , 
SIZE = 500MB, 
MAXSIZE = 1GB, 
FILEGROWTH = 64KB
), 
FILEGROUP [AP_FINANCE_FG]  DEFAULT
(
NAME = N'AP_FINANCE_DATA',
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA\AP_FINANCE_DATA.ndf',
SIZE = 2GB, 
MAXSIZE = 4GB, 
FILEGROWTH = 64KB
), 
FILEGROUP [AP_FINANCE_MEM_OPT_FG] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
(
NAME = N'AP_FINANCE_MEM_OPT_F1',
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\MEMORYOPT\AP_FINANCE_MEM_OPT_F1.NDF',
MAXSIZE = UNLIMITED
)
 LOG ON 
( 
NAME = N'AP_FINANCE_LOG',
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\LOGS\AP_FINANCE_LOG.ldf',
SIZE = 2GB,
MAXSIZE = 5GB,
FILEGROWTH = 128KB
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

