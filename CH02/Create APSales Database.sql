/**********************/
/* APSales Database   */
/**********************/

/***************************************/
/* Chapter 02,03,04 - APSales Database */
/* Create Database                     */
/* Created: 08/19/2022                 */
/* Modified: 07/18/2023                */
/* Production Folder                   */
/***************************************/

USE [master]
GO

CREATE DATABASE [APSales]
 CONTAINMENT = NONE
ON  PRIMARY 
( 
	NAME = N'AP_SALES_PRIMARY', 
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_SALES\PRIMARY\AP_SALES_PRIMARY.mdf' , 
	SIZE = 1GB, 
	MAXSIZE = 2GB, 
	FILEGROWTH = 64MB
), 
FILEGROUP [AP_SALES_FG]  DEFAULT
(
	NAME = N'AP_SALES_DATA', 
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_SALES\DATA\AP_SALES_DATA.ndf',
	SIZE = 1GB, 
	MAXSIZE = 3GB, 
	FILEGROWTH = 64MB
	), 
FILEGROUP [AP_SALES_MEMOPTpt] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
(
	NAME = N'APSalesMemOpt',
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_SALES\MEMORYOPT\AP_SALES_MEMOPT.mdf',
	MAXSIZE = UNLIMITED
) 
LOG ON 
(
	NAME = N'AP_SALES_LOG',
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_SALES\LOGS\AP_SALES_LOG.ldf',
	SIZE = 2GB, 
	MAXSIZE = 5GB, 
	FILEGROWTH = 64MB
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO




