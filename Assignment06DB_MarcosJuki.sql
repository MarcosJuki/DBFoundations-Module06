--*************************************************************************--
-- Title: Assignment06
-- Author: MarcosJuki
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-13,MarcosJuki,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MarcosJuki')
	 Begin 
	  Alter Database [Assignment06DB_MarcosJuki] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MarcosJuki;
	 End
	Create Database Assignment06DB_MarcosJuki;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MarcosJuki;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
USE Assignment06DB_MarcosJuki;
GO

CREATE
VIEW vw_Categories
WITH SCHEMABINDING
AS
SELECT
  CategoryID
 ,CategoryName
FROM dbo.Categories;
GO

CREATE
VIEW vw_Employees
WITH SCHEMABINDING
AS
SELECT
  EmployeeID
 ,EmployeeFirstName
 ,EmployeeLastName
 ,ManagerID
FROM dbo.Employees;
GO

CREATE
VIEW vw_Inventories
WITH SCHEMABINDING
AS
SELECT
  InventoryID
 ,InventoryDate
 ,EmployeeID
 ,ProductID
 ,[COUNT]
FROM dbo.Inventories;
GO

CREATE
VIEW vw_Products
WITH SCHEMABINDING
AS
SELECT
  ProductID
 ,ProductName
 ,CategoryID
 ,UnitPrice
FROM dbo.Products;
GO

SELECT * FROM vw_Categories;
GO
SELECT * FROM vw_Employees;
GO
SELECT * FROM vw_Inventories;
GO
SELECT * FROM vw_Products;
GO

----------------------------------------------------------------------------------------------------------------------
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
USE Assignment06DB_MarcosJuki;
GO

DENY  SELECT ON dbo.Categories		TO PUBLIC;
GRANT SELECT ON dbo.vw_Categories	TO PUBLIC;

DENY  SELECT ON dbo.Employees		TO PUBLIC;
GRANT SELECT ON dbo.vw_Employees	TO PUBLIC;

DENY  SELECT ON dbo.Inventories		TO PUBLIC;
GRANT SELECT ON dbo.vw_Inventories	TO PUBLIC;

DENY  SELECT ON dbo.Products		TO PUBLIC;
GRANT SELECT ON dbo.vw_Products		TO PUBLIC;
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00
USE Assignment06DB_MarcosJuki;
GO

--SELECT TOP 1000000000
--  C.CategoryName
-- ,P.ProductName
-- ,P.UnitPrice
--FROM dbo.Categories		AS C
-- LEFT JOIN dbo.Products	AS P
-- ON C.CategoryID = P.CategoryID
--ORDER BY C. CategoryName, P.ProductName

CREATE
VIEW vw_ProductsByCategories
AS
SELECT TOP 1000000000
  C.CategoryName
 ,P.ProductName
 ,P.UnitPrice
FROM dbo.vw_Categories		AS C
 LEFT JOIN dbo.vw_Products	AS P
 ON C.CategoryID = P.CategoryID
ORDER BY C. CategoryName, P.ProductName;
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83
USE Assignment06DB_MarcosJuki;
GO

--SELECT TOP 1000000000
--  P.ProductName
-- ,I.InventoryDate
-- ,I.[Count]
--FROM dbo.Products				AS P
-- INNER JOIN dbo.Inventories	AS I
-- ON P.ProductID = I.ProductID
--ORDER BY P.ProductName, I.InventoryDate, I.[Count]

CREATE
VIEW vw_InventoriesByProductsByDates
AS
SELECT TOP 1000000000
  P.ProductName
 ,I.InventoryDate
 ,I.[Count]
FROM dbo.vw_Products			AS P
 INNER JOIN dbo.vw_Inventories	AS I
 ON P.ProductID = I.ProductID
ORDER BY P.ProductName, I.InventoryDate, I.[Count];
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth
USE Assignment06DB_MarcosJuki;
GO

--SELECT DISTINCT TOP 1000000000
--  I.InventoryDate
-- ,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
--FROM dbo.Employees			AS E
-- RIGHT JOIN dbo.Inventories	AS I
-- ON E.EmployeeID = I.EmployeeID
--ORDER BY I.InventoryDate

CREATE
VIEW vw_InventoriesByEmployeesByDates
AS
SELECT DISTINCT TOP 1000000000
  I.InventoryDate
 ,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.vw_Employees			AS E
 RIGHT JOIN dbo.vw_Inventories	AS I
 ON E.EmployeeID = I.EmployeeID
ORDER BY I.InventoryDate
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54
USE Assignment06DB_MarcosJuki;
GO

--SELECT TOP 1000000000
--  C.CategoryName
-- ,P.ProductName
-- ,I.InventoryDate
-- ,I.[Count]
--FROM dbo.Categories			AS C
-- LEFT JOIN dbo.Products		AS P
-- ON C.CategoryID = P.CategoryID
-- LEFT JOIN dbo.Inventories	AS I
-- ON P.ProductID = I.ProductID
--ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]

CREATE
VIEW vw_InventoriesByProductsByCategories
AS
SELECT TOP 1000000000
  C.CategoryName
 ,P.ProductName
 ,I.InventoryDate
 ,I.[Count]
FROM dbo.vw_Categories			AS C
 LEFT JOIN dbo.vw_Products		AS P
 ON C.CategoryID = P.CategoryID
 
 LEFT JOIN dbo.vw_Inventories	AS I
 ON P.ProductID = I.ProductID
ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.[Count];
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan
USE Assignment06DB_MarcosJuki;
GO

--SELECT TOP 1000000000
--  C.CategoryName
-- ,P.ProductName
-- ,I.InventoryDate
-- ,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
--FROM dbo.Categories			AS C
-- LEFT JOIN dbo.Products		AS P
-- ON C.CategoryID = P.CategoryID
-- LEFT JOIN dbo.Inventories	AS I
-- ON P.ProductID = I.ProductID
-- LEFT JOIN dbo.Employees		AS E
-- ON I.EmployeeID = E.EmployeeID
--ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, E.EmployeeFirstName + ' ' + E.EmployeeLastName;
--GO

CREATE
VIEW vw_InventoriesByProductsByEmployees
AS
SELECT TOP 1000000000
  C.CategoryName
 ,P.ProductName
 ,I.InventoryDate
 ,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.vw_Categories			AS C
 LEFT JOIN dbo.vw_Products		AS P
 ON C.CategoryID = P.CategoryID
 
 LEFT JOIN dbo.vw_Inventories	AS I
 ON P.ProductID = I.ProductID
 
 LEFT JOIN dbo.vw_Employees	AS E
 ON I.EmployeeID = E.EmployeeID
ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, E.EmployeeFirstName + ' ' + E.EmployeeLastName;
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
'Chang is not a Beverage, it is a Condiment'
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King
USE Assignment06DB_MarcosJuki;
GO

--SELECT TOP 1000000000
--  C.CategoryName
-- ,P.ProductName
-- ,I.InventoryDate
-- ,I.[Count]
-- ,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
--FROM dbo.Categories			AS C
-- LEFT JOIN dbo.Products		AS P
-- ON C.CategoryID = P.CategoryID
 
-- LEFT JOIN dbo.Inventories	AS I
-- ON P.ProductID = I.ProductID
 
-- LEFT JOIN dbo.Employees	AS E
-- on I.EmployeeID = e.EmployeeID
--WHERE P.ProductName IN ('Chai', 'Chang')	-- Chang is not a Beverage, it is a Condiment
--ORDER BY I.InventoryDate, P.ProductName

CREATE
VIEW vw_InventoriesForChaiAndChangByEmployees
AS
SELECT TOP 1000000000
  C.CategoryName
 ,P.ProductName
 ,I.InventoryDate
 ,I.[Count]
 ,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.vw_Categories			AS C
 LEFT JOIN dbo.vw_Products		AS P
 ON C.CategoryID = P.CategoryID
 
 LEFT JOIN dbo.vw_Inventories	AS I
 ON P.ProductID = I.ProductID
 
 LEFT JOIN dbo.vw_Employees	AS E
 on I.EmployeeID = E.EmployeeID
WHERE P.ProductName IN ('Chai', 'Chang')	-- Chang is not a Beverage, it is a Condiment
ORDER BY I.InventoryDate, P.ProductName;
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan
USE Assignment06DB_MarcosJuki;
GO

--SELECT TOP 1000000000
--  Mgr.EmployeeFirstName + ' ' + Mgr. EmployeeLastName	AS Manager
-- ,Emp.EmployeeFirstName + ' ' + Emp. EmployeeLastName	AS Employee
--FROM dbo.Employees			AS Emp
-- INNER JOIN dbo.Employees		AS Mgr
-- ON Emp.ManagerID = Mgr.EmployeeID
--ORDER BY
-- Mgr.EmployeeFirstName + ' ' + Mgr. EmployeeLastName
--,Emp.EmployeeFirstName + ' ' + Emp. EmployeeLastName;
--GO

CREATE
VIEW vw_EmployeesByManager
AS
SELECT TOP 1000000000
  Mgr.EmployeeFirstName + ' ' + Mgr. EmployeeLastName	AS Manager
 ,Emp.EmployeeFirstName + ' ' + Emp. EmployeeLastName	AS Employee
FROM dbo.vw_Employees			AS Emp
 INNER JOIN dbo.vw_Employees	AS Mgr
 ON Emp.ManagerID = Mgr.EmployeeID
ORDER BY
 Mgr.EmployeeFirstName + ' ' + Mgr. EmployeeLastName
,Emp.EmployeeFirstName + ' ' + Emp. EmployeeLastName;
GO


----------------------------------------------------------------------------------------------------------------------
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID, CategoryName, ProductID,	ProductName, UnitPrice,	InventoryID, InventoryDate, Count, EmployeeID, Employee,        Manager
-- 1,		   Beverages,	 1,			Chai,		 18.00,     1,           2017-01-01,    72,    5,          Steven Buchanan, Andrew Fuller
-- 1,          Beverages,    1,         Chai,        18.00,     78,          2017-02-01,    52,    7,          Robert King,     Steven Buchanan
-- 1,          Beverages,    1,         Chai,        18.00,     155,         2017-03-01,    54,    9,          Anne Dodsworth,  Steven Buchanan
USE Assignment06DB_MarcosJuki;
GO

--SELECT TOP 1000000000
--  C.CategoryID
-- ,C.CategoryName
-- ,P.ProductID
-- ,P.ProductName
-- ,P.UnitPrice
-- ,I.InventoryID
-- ,I.InventoryDate
-- ,I.[Count]
-- ,Emp.EmployeeID
-- ,Emp.EmployeeFirstName + ' ' + Emp. EmployeeLastName	AS Employee
-- ,Mgr.EmployeeFirstName + ' ' + Mgr. EmployeeLastName	AS Manager
--FROM dbo.Categories			AS C
-- LEFT JOIN dbo.Products		AS P
-- ON C.CategoryID = P.ProductID
 
-- LEFT JOIN dbo.Inventories	AS I
-- ON P.ProductID = I.ProductID
 
-- LEFT JOIN dbo.Employees    AS Emp
-- ON I.EmployeeID = Emp.EmployeeID

-- INNER JOIN dbo.Employees	AS Mgr
-- ON Emp.ManagerID = Mgr.EmployeeID
--ORDER BY C.CategoryName;
--GO

CREATE
VIEW vw_InventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 1000000000
  C.CategoryID
 ,C.CategoryName
 ,P.ProductID
 ,P.ProductName
 ,P.UnitPrice
 ,I.InventoryID
 ,I.InventoryDate
 ,I.[Count]
 ,Emp.EmployeeID
 ,Emp.EmployeeFirstName + ' ' + Emp. EmployeeLastName	AS Employee
 ,Mgr.EmployeeFirstName + ' ' + Mgr. EmployeeLastName	AS Manager
FROM dbo.vw_Categories			AS C
 LEFT JOIN dbo.vw_Products		AS P
 ON C.CategoryID = P.ProductID
 
 LEFT JOIN dbo.vw_Inventories	AS I
 ON P.ProductID = I.ProductID
 
 LEFT JOIN dbo.vw_Employees    AS Emp
 ON I.EmployeeID = Emp.EmployeeID

 INNER JOIN dbo.vw_Employees	AS Mgr
 ON Emp.ManagerID = Mgr.EmployeeID
ORDER BY C.CategoryName;
GO


----------------------------------------------------------------------------------------------------------------------
-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vw_Categories]
Select * From [dbo].[vw_Products]
Select * From [dbo].[vw_Inventories]
Select * From [dbo].[vw_Employees]

Select * From [dbo].[vw_ProductsByCategories]
Select * From [dbo].[vw_InventoriesByProductsByDates]
Select * From [dbo].[vw_InventoriesByEmployeesByDates]
Select * From [dbo].[vw_InventoriesByProductsByCategories]
Select * From [dbo].[vw_InventoriesByProductsByEmployees]
Select * From [dbo].[vw_InventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vw_EmployeesByManager]
Select * From [dbo].[vw_InventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/