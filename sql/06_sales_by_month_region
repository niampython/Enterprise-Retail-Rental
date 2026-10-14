SELECT 
    Region, 
    ISNULL(CAST(YEAR(OrderDate) AS VARCHAR), 'Unknown Year') AS Year, 
    ISNULL(CAST(MONTH(OrderDate) AS VARCHAR), 'Unknown Month') AS Month, 
    FORMAT(SUM(Quantity * UnitPrice), 'C', 'en-US') AS 'Total Sales'
FROM [dbo].[FactSales] s 
LEFT JOIN [dbo].[DimStores] st ON s.StoreId = st.StoreID 
WHERE Region IS NOT NULL 
GROUP BY 
    Region, 
    YEAR(OrderDate), 
    MONTH(OrderDate)
ORDER BY year(OrderDate), MONTH(OrderDate)
