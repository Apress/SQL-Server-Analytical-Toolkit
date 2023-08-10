Created: 07/20/2023

The first steps are:

Create the folder structures required by the CREATE database statements and use the drive letter
that is available on your laptop or desktop. I used D: drive but maybe some of you only have C:.

/**********/
/* STEP 1 */
/**********/

APFINANCE DATABASE
D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\DATA
D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\LOGS
D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\MEMORYOPT
D:\APRESS_TOOLKIT_DATABASES\AP_FINANCE\PRIMARY

APINVENTORY
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY\DATA
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY\LOGS
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY\MEMORYOPT
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY\PRIMARY

APINVENTORYWAREHOUSE
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY_WAREHOUSE\DATA
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY_WAREHOUSE\LOGS
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY_WAREHOUSE\MEMORYOPT
D:\APRESS_TOOLKIT_DATABASES\AP_INVENTORY_WAREHOUSE\PRIMARY

APPLANT DATABASE
D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\DATA
D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\LOGS
D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\MEMORYOPT
D:\APRESS_TOOLKIT_DATABASES\AP_PLANT\PRIMARY

APSALES
D:\APRESS_TOOLKIT_DATABASES\AP_SALES\DATA
D:\APRESS_TOOLKIT_DATABASES\AP_SALES\LOGS
D:\APRESS_TOOLKIT_DATABASES\AP_SALES\MEMORYOPT
D:\APRESS_TOOLKIT_DATABASES\AP_SALES\PRIMARY

/**********/
/* STEP 2 */
/**********/

Create each database

/**********/
/* STEP 3 */
/**********/

Create database tables and views

/**********/
/* STEP 4 */
/**********/

Load database tables

/**********/
/* STEP 5 */
/**********/

Once you load the database, create a backup and then a backup for
the transaction log. Truncate the log so you reclaim space. These databases can get fairly 
big so monitor space usage.

If you simply do ot have enough space, just modify the scripts that load the large tables
so you have less rows.

/*********/
/* NOTES */
/*********/

Keep in mind that the scripts for each chapter might create a new table
that is not in the original create table and load tables list.

Also, views are created in the chapters that are not included in the 
create table scripts.

If you need to start from scratch, that is, delete all the tables and
views and then reload them, you need to include the tables and views created in 
the chapters other wise you will get some error message if you run the scripts in one go
a second, third, time etc.

If you get errors, they most likely will be cannot drop schema because it is dependent
on a table or view.

Simply add a new DROP TABLE or VIEW IF EXISTS using the table or object name in the error
message and things should work.

Remember, when you need to recreate schema the order is:

drop dependent tables
drop dependent views
drop any other dependent objects like stored procedures and functions

Then you can drop the schema. You will only need to follow these steps 
if you need to recreate the database from scratch.

Always load the inventory database first and then the inventory data warehouse
after.

Once all these steps are completed, you can start testing the queries in the chapter scripts.

Last comment, some examlpes use a TEST database. You can create this on your own.