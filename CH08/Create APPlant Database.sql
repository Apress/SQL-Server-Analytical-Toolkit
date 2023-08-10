USE [master]
GO

CREATE DATABASE [APPlant]
CONTAINMENT = NONE
ON  PRIMARY 
( 
	NAME = N'AP_PLANT_PRIMARY', 
	FILENAME = N'D:\APRESS_DATABASES\AP_PLANT\PRIMARY\AP_PLANT_PRIMARY.mdf' , 
	SIZE = 1024000KB ,
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB
), 
FILEGROUP [AP_PLANT_FG]  DEFAULT
(
	NAME = N'AP_PLANT_DATA', 
	FILENAME = N'D:\APRESS_DATABASES\AP_PLANT\DATA\AP_PLANT_DATA.ndf' , 
	SIZE = 2048000KB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB 
), 
FILEGROUP [AP_PLANT_MEM_FG] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( 
	NAME = N'AP_PLANT_MEME_DATA',
	FILENAME = N'D:\APRESS_DATABASES\AP_PLANT\MEM_DATA\AP_PLANT_MEM_DATA.NDF' ,
	MAXSIZE = UNLIMITED
)
LOG ON 
(
	NAME = N'AP_PLANT_LOG',
	FILENAME = N'D:\APRESS_DATABASES\AP_PLANT\LOGS\AP_PLANT_LOG.ldf',
	SIZE = 1286144KB,
	MAXSIZE = 2048GB,
	FILEGROWTH = 65536KB
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO