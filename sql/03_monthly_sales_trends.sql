SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    SUM(Quantity * UnitPrice) AS TotalSales,

    LAG(SUM(Quantity * UnitPrice)) OVER (
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    ) AS PreviousMonthSales,
    SUM(Quantity * UnitPrice) - LAG(SUM(Quantity * UnitPrice)) OVER (
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    ) 'MonthlyDifference',
    CONCAT(CAST(ROUND(
    (SUM(Quantity * UnitPrice) - LAG(SUM(Quantity * UnitPrice)) OVER (
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    ))
    / NULLIF(LAG(SUM(Quantity * UnitPrice)) OVER (
        ORDER BY YEAR(OrderDate), MONTH(OrderDate)
    ), 0) * 100,
    2) AS DECIMAL(10,2)), '%') AS MoMGrowthPct

FROM FactSales
GROUP BY 
    YEAR(OrderDate),
    MONTH(OrderDate)

ORDER BY 
    YEAR(OrderDate),
    MONTH(OrderDate);
