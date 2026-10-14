CREATE SCHEMA reporting;


CREATE VIEW reporting.vw_FactSales AS
SELECT
 *, Quantity * UnitPrice AS TotalSales
FROM dbo.FactSales;

CREATE VIEW reporting.vw_DimCustomers AS
SELECT *
FROM dbo.DimCustomers;

CREATE VIEW reporting.vw_DimProducts AS
SELECT *
FROM dbo.DimProducts;

CREATE VIEW reporting.vw_DimStores AS
SELECT *
FROM dbo.DimStores;

CREATE VIEW reporting.vw_FactInventory AS
SELECT *
FROM dbo.FactInventory;

CREATE VIEW reporting.vw_FactPromotions AS
SELECT *
FROM dbo.FactPromotions;

CREATE VIEW reporting.vw_FactReturns AS
SELECT *
FROM dbo.FactReturns;

CREATE VIEW reporting.vw_Targets AS
SELECT *
FROM dbo.FactTargets;

CREATE VIEW reporting.vw_Inventory AS
SELECT *
FROM dbo.FactInventory;
