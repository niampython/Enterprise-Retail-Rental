CREATE TABLE [dbo].[Customers]
(
CustomerID VARCHAR(50) NOT NULL PRIMARY KEY,
CustomerName VARCHAR(50),
Email VARCHAR(50),
Segment VARCHAR(50),
State VARCHAR(10),
City VARCHAR(50),
SignupDate Date,
Status VARCHAR(50)
);


CREATE TABLE FactInventory
(
SnapshotDate Date,
StoreID Varchar(50),
ProductID Varchar(50),
OnHandQty INT,
ReorderPoint INT,
LeadTimeDays INT,
ABCClass Varchar(5)
);


CREATE TABLE DimProducts
(
ProductID VARCHAR(50) PRIMARY KEY,
ProductName VARCHAR(100),
Category VARCHAR(500),
Brand VARCHAR(50),
UnitCost DECIMAL(10,2),
ListPrice DECIMAL(10,2),
Status VARCHAR(50),
LaunchDate DATE 
);


CREATE TABLE DimStores
(
StoreID VARCHAR(50) PRIMARY KEY,	
StoreName	VARCHAR(100), 
Region	VARCHAR(50),
State	VARCHAR(10),
City	VARCHAR(50),
Address	VARCHAR(100),
ZipCode	VARCHAR(50),
OpenDate DATE,
Status VARCHAR(50)
);


CREATE TABLE FactReturns
(
ReturnID 	VARCHAR(50) PRIMARY KEY,
SalesLineID	VARCHAR(50),
OrderID	VARCHAR(50),
ReturnDate	DATE,
ProductID	VARCHAR(50),
ReturnQty	INT,
ReturnReason	VARCHAR(50),
ReturnStatus VARCHAR(50)
);


CREATE TABLE FactPromotions
(
PromotionID	VARCHAR(50) PRIMARY KEY,
PromotionName	VARCHAR(100),
StartDate	DATE,
EndDate	    DATE,
DiscountPct	DECIMAL(10,2),
CategoryScope VARCHAR(50)
);

CREATE TABLE FactTargets
(
TargetMonth	Date,
Region	VARCHAR(50),
RevenueTarget	DECIMAL(10,2),
MarginTargetPct	DECIMAL(10,2),
OrderTarget INT
);

CREATE TABLE FactSales 
(
SalesLineID VARCHAR(50),
OrderID	VARCHAR(50),
OrderDate	DATE,
CustomerID	VARCHAR(50),
ProductID	VARCHAR(50),
StoreID	VARCHAR(50),
Quantity	INT,
UnitPrice	DECIMAL(10,2),
DiscountPct	DECIMAL(10,2),
PromotionID	VARCHAR(50),
SalesChannel	VARCHAR(50),
PaymentMethod VARCHAR(50)
);



