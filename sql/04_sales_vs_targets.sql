WITH actuals AS(
SELECT 
    Region, 
    YEAR(OrderDate) AS Year, 
    MONTH(OrderDate)  AS Month, 
    SUM(Quantity * UnitPrice) 'Total Sales'
FROM [dbo].[FactSales] s 
LEFT JOIN [dbo].[DimStores] st ON s.StoreId = st.StoreID 
WHERE Region IS NOT NULL 
GROUP BY 
    Region, 
    YEAR(OrderDate), 
    MONTH(OrderDate)
)

SELECT 
    a.Region, 
    a.Year, 
    Month, 
    a.[Total Sales],
    RevenueTarget, 
    ([Total Sales] - [RevenueTarget]) Variance, 
    CONCAT(CAST((([Total Sales] - [RevenueTarget])/ [RevenueTarget])*100 AS INT), '%') 'Variance%'
FROM actuals a LEFT JOIN FactTargets t 
ON a.Region = t.Region and a.Year = year(t.TargetMonth) and a.Month = month(t.TargetMonth)
WHERE RevenueTarget IS NOT NULL
ORDER BY Year, Month
