USE [master]
GO

/*******************************************/
/* Chapter 11,12,13 - APInventory Database */
/* Create Database                         */
/* Created: 08/19/2022                     */
/* Modified: 07/19/2023                    */
/* Production Folder                       */
/*******************************************/

CREATE DATABASE [APInventory]
 CONTAINMENT = NONE
 ON  PRIMARY 
( 
NAME = N'AP_INVENTORY_PRIMARY', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY\PRIMARY\AP_INVENTORY_PRIMARY.mdf' ,
SIZE = 1GB,
MAXSIZE = 2GB,
FILEGROWTH = 64MB
), 
FILEGROUP [AP_INVENTORY_FG]  DEFAULT
(
NAME = N'AP_INVENTORY_DATA',
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY\DATA\AP_INVENTORY_DATA.ndf' ,
SIZE = 2GB,
MAXSIZE = 5GB,
FILEGROWTH = 64MB
)
LOG ON 
(
NAME = N'AP_INVENTORY_LOG',
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY\LOGS\AP_INVENTORY_LOG.ldf',
SIZE = 2GB,
MAXSIZE = 5GB,
FILEGROWTH = 64MB
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

