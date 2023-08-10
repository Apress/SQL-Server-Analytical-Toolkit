USE [master]
GO

/***************************************/
/* Chapter 08,09,10 - APPlant Database */
/* Create Database                     */
/* Created: 08/19/2022                 */
/* Modified: 07/19/2023                */
/* Production Folder                   */
/***************************************/

-- modify sizes as per your available disk storage

CREATE DATABASE [APPlant]
CONTAINMENT = NONE
ON  PRIMARY 
( 
	NAME = N'AP_PLANT_PRIMARY', 
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\PRIMARY\AP_PLANT_PRIMARY.mdf' , 
	SIZE = 1GB,
	MAXSIZE = 2GB, 
	FILEGROWTH = 64MB
), 
FILEGROUP [AP_PLANT_FG]  DEFAULT
(
	NAME = N'AP_PLANT_DATA', 
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\DATA\AP_PLANT_DATA.ndf' , 
	SIZE = 2GB,
	MAXSIZE = 5GB, 
	FILEGROWTH = 64MB 
), 
FILEGROUP [AP_PLANT_MEM_FG] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( 
	NAME = N'AP_PLANT_MEME_DATA',
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\MEMORYOPT\AP_PLANT_MEM_DATA.NDF' ,
	MAXSIZE = UNLIMITED
)
LOG ON 
(
	NAME = N'AP_PLANT_LOG',
	FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\LOGS\AP_PLANT_LOG.ldf',
	SIZE = 2GB,
	MAXSIZE = 5GB, 
	FILEGROWTH = 64MB
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
