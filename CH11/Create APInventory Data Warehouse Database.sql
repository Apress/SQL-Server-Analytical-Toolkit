USE [master]
GO

/*************************************************/
/* Chapter 11,12,13 - APInventory Data Warehouse */
/* Create Database                               */
/* Created: 08/19/2022                           */
/* Modified: 07/19/2023                          */
/* Production Folder                             */
/*************************************************/

CREATE DATABASE [APInventoryWarehouse]
 CONTAINMENT = NONE
 ON  PRIMARY 
( 
NAME = N'AP_INVENTORY_WAREHOUSE_PRIMARY', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY_WAREHOUSE\PRIMARY\AP_INVENTORY_WAREHOUSE_PRIMARY.mdf' ,
SIZE = 1GB, 
MAXSIZE = 2GB, 
FILEGROWTH = 64MB
), 
 FILEGROUP [AP_INVENTORY_WAREHOUSE_FG]  DEFAULT
( 
NAME = N'AP_INVENTORY_WAREHOUSE_DATA', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY_WAREHOUSE\DATA\AP_INVENTORY_WAREHOUSE_DATA.ndf' , 
SIZE = 2GB, 
MAXSIZE = 4GB, 
FILEGROWTH = 64MB
)
LOG ON 
( 
NAME = N'AP_INVENTORY_WAREHOUSE_LOG', 
FILENAME = N'D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY_WAREHOUSE\LOGS\AP_INVENTORY_WAREHOUSE_LOG.ldf' , 
SIZE = 2GB, 
MAXSIZE = 5GB, 
FILEGROWTH = 64MB
)
WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

