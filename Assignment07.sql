--*************************************************************************--
-- Title: Assignment07
-- Author: RRoot
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2022-05-28,SSpringer,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_SSpringer')
	 Begin 
	  Alter Database [Assignment07DB_SSpringer] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_SSpringer;
	 End
	Create Database Assignment07DB_SSpringer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_SSpringer;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
/*
-- <Put Your Code Here> --
--Display data from Products Table
Select Top 10 * From vProducts
;
go
--Display only desired columns from Products Table
Select  
	ProductName
	,UnitPrice
From 
	vProducts
;
go
--Add column name aliases
Select 
	ProductName
	,[Price in USD] = UnitPrice
From 
	vProducts
;
go
--Format UnitPrice in USD
Select 
	ProductName
	,[Price in USD] = Format (UnitPrice, 'c')
From 
	vProducts
;
go
*/
--Sort results by Product Name
Go
Select 
	ProductName
	,[Price in USD] = Format (UnitPrice, 'c')
From 
	vProducts
Order By
	ProductName
;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --
/*
-- Display base views of Category and Product tables
Select Top 10 * From vCategories
Select Top 10 * From vProducts
;
go
--Display desired columns from base views of Category and Product tables
Select 
	CategoryName
From vCategories
Select
	ProductName
	,UnitPrice
From vProducts
;
Go
--Add table aliases to desired columns display
Select 
	CategoryName
From vCategories as c
Select
	ProductName
	,UnitPrice
From vProducts as p
;
Go
--Format UnitPrice columns to display as USD
Select 
	CategoryName
	,ProductName
	,[Price] = Format (UnitPrice, 'c')
From vCategories as c
Join
	vProducts as p
	On c.CategoryID = p.CategoryID
;
Go
*/
--Sort results by Category and Product names
Select 
	CategoryName
	,ProductName
	,[Price] = Format (UnitPrice, 'c')
From vCategories as c
Join
	vProducts as p
	On c.CategoryID = p.CategoryID
Order By
	CategoryName
	,ProductName
;
Go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/*
-- <Put Your Code Here> --
-- Display base views of Product and Inventory tables
Select Top 10 * From vProducts
Select Top 10 * From vInventories
;
go
--Display desired columns from base views of Category and Product tables
Select 
	ProductName
From vProducts
Select 
	InventoryDate
	,[InventoryCount] = Count
From vInventories
;
go
--Add table aliases for Category and Product tables
Select 
	ProductName
From vProducts as p
Select 
	InventoryDate
	,[InventoryCount] = Count
From vInventories as i
;
go
--Join desired columns on Category and Product tables
Select 
	ProductName
	,InventoryDate
	,[InventoryCount] = Count
From vProducts as p
Join vInventories as i
	On p.ProductID = i.ProductID
;
go
--Format Date column like 'January, 2017'
Select 
	ProductName
	,[InventoryDate] = DateName(MM,InventoryDate) + ', ' + DateName(Year,InventoryDate)
	,[InventoryCount] = Count
From vProducts as p
Join vInventories as i
	On p.ProductID = i.ProductID
;
go
*/
--Sort results by Product and Date
Select 
	ProductName
	,[InventoryDate] = DateName(MM,InventoryDate) + ', ' + DateName(Year,InventoryDate)
	,[InventoryCount] = Count
From vProducts as p
Join vInventories as i
	On p.ProductID = i.ProductID
Group By
	p.ProductName
	,i.InventoryDate
	,i.Count
;
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/*
-- <Put Your Code Here> --
--Select statement that shows the desired information for the view
Select 
	ProductName
	,[InventoryDate] = DateName(MM,InventoryDate) + ', ' + DateName(Year,InventoryDate)
	,[InventoryCount] = Count
From vProducts as p
Join vInventories as i
	On p.ProductID = i.ProductID
Group By
	p.ProductName
	,i.InventoryDate
	,i.Count
;
go
*/
-- View created called vProductInventories
Create or Alter View vProductInventories
AS
	Select 
		ProductName
		,[InventoryDate] = DateName(MM,InventoryDate) + ', ' + DateName(Year,InventoryDate)
		,[InventoryCount] = Count
	From vProducts as p
	Join vInventories as i
		On p.ProductID = i.ProductID
	Group By
		p.ProductName
		,i.InventoryDate
		,i.Count
;
go

-- Check that it works: Select * From vProductInventories;
Select * From vProductInventories
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
/*
-- <Put Your Code Here> --
-- Display base views of Category and Inventory tables
Select Top 10 * From vCategories
Select Top 10 * From vInventories
;
go
-- Display desired columns from Category and Inventory tables
Select 
	CategoryName
From 
	vCategories
Select 
	InventoryDate
	,[InventoryCount] = Count
From 
	vInventories
;
go
-- Add table aliases to Category and Inventory tables
Select 
	CategoryName
From 
	vCategories as c
Select 
	InventoryDate
	,[InventoryCount] = Count
From 
	vInventories as i
;
go
-- Join desired columns from the Category and Inventory tables
Select 
	CategoryName
	,InventoryDate
	,[InventoryCount] = Count
From 
	vCategories as c
Inner Join
	vProducts as p
	On c.CategoryID = p.CategoryID
Inner Join
	vInventories as i
	On p.ProductID = i.ProductID
;
go
-- Reformat Date
Select 
	CategoryName
	,[InventoryDate] = DateName (MM, InventoryDate) + ', ' + DATENAME (YYYY, InventoryDate)
	,[InventoryCount] = Count
From 
	vCategories as c
Inner Join
	vProducts as p
	On c.CategoryID = p.CategoryID
Inner Join
	vInventories as i
	On p.ProductID = i.ProductID
;
go
-- Sort results by Category and Date
Select 
	CategoryName
	,[InventoryDate] = DateName (MM, InventoryDate) + ', ' + DATENAME (YYYY, InventoryDate)
	,[InventoryCount] = Count
From 
	vCategories as c
Inner Join
	vProducts as p
	On c.CategoryID = p.CategoryID
Inner Join
	vInventories as i
	On p.ProductID = i.ProductID
Order By 
	CategoryName
	,DATEPART (MM, InventoryDate)
;
go
-- Combine counts for each category by month
Select 
	CategoryName
	,[Inventory Date] = DateName (MM, InventoryDate) + ', ' + DATENAME (YYYY, InventoryDate)
	,[InventoryCountbyCategory] = SUM(Count)
From 
	vCategories as c
Inner Join
	vProducts as p
	On c.CategoryID = p.CategoryID
Inner Join
	vInventories as i
	On p.ProductID = i.ProductID
Group by
	CategoryName
	,InventoryDate
Order By 
	CategoryName
	,DATEPART (MM, InventoryDate)
;
go
*/
-- Create view for above select statement
Create or Alter View vCategoryInventories
As
Select Top 100000000
	CategoryName
	,[Inventory Date] = DateName (MM, InventoryDate) + ', ' + DATENAME (YYYY, InventoryDate)
	,[InventoryCountbyCategory] = SUM(Count)
From 
	vCategories as c
Inner Join
	vProducts as p
	On c.CategoryID = p.CategoryID
Inner Join
	vInventories as i
	On p.ProductID = i.ProductID
Group by
	CategoryName
	,InventoryDate
Order By 
	CategoryName
	,DATEPART (MM, InventoryDate)
;
go
-- Check that it works: Select * From vCategoryInventories;

Select * From vCategoryInventories
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.
/*
-- <Put Your Code Here> --
--Add PreviousMonthCount to vProductInventories
Select 
	ProductName
	,InventoryDate
	,[InventoryCount] = Count
	,[PreviousMonthCount] = 
		IIF(DateName(mm, InventoryDate) + ', ' + DateName(yyyy, InventoryDate) = 'January, 2017', 0, Lag(Count) Over (Order By ProductName))
From 
	vProductInventories;
Go
*/
--Create View called vProductInventoriesWithPreviousMonthCounts
Create or Alter View vProductInventoriesWithPreviousMonthCounts
As
Select 
	ProductName
	,InventoryDate
	,InventoryCount
	,[PreviousMonthCount] = 
		IIF(DateName(mm, InventoryDate) + ', ' + DateName(yyyy, InventoryDate) = 'January, 2017', 0, Lag(InventoryCount) Over (Order By ProductName))
From 
	vProductInventories;
Go
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;

Select * From vProductInventoriesWithPreviousMonthCounts
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
/*
-- <Put Your Code Here> --
--Starting with the vProductInventoriesWithPreviousMonthCounts
Select * From vProductInventoriesWithPreviousMonthCounts;
Go
--Add KPI (key performance indicator) column for to vProductInventoriesWithPreviousMonthCounts view
Select
	ProductName
	,InventoryDate 
	,InventoryCount 
	,PreviousMonthCount
	,[CountVsPreviousCountKPI] = Case
	  When [InventoryCount] > [PreviousMonthCount] Then 1
	  When [InventoryCount] = [PreviousMonthCount] Then 0
	  When [InventoryCount] < [PreviousMonthCount] Then -1
	  End
From
	vProductInventoriesWithPreviousMonthCounts
;
go
*/
--Create view for select statement called vProductInventoriesWithPreviousMonthCountsWithKPIs
Create or Alter View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
Select
	ProductName
	,[InventoryDate] 
	,[InventoryCount] 
	,[PreviousMonthCount]
	,[CountVsPreviousCountKPI] = Case
	  When [InventoryCount] > [PreviousMonthCount] Then 1
	  When [InventoryCount] = [PreviousMonthCount] Then 0
	  When [InventoryCount] < [PreviousMonthCount] Then -1
	  End
From
	vProductInventoriesWithPreviousMonthCounts
;
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
Create or Alter Function 
	dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs 
	(@CountVsPreviousCountKPI int)
Returns Table
As
Return 
	Select *
From vProductInventoriesWithPreviousMonthCountsWithKPIs
Where [CountVsPreviousCountKPI] = @CountVsPreviousCountKPI
;
Go
/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/