SELECT TOP 10 
    CustomerName, 
    Region, 
    COUNT(OrderID) OrderCount,
    FORMAT(SUM(Quantity*UnitPrice), 'C', 'en-US') TotalSales
FROM FactSales s 
    LEFT JOIN DimCustomers c
    ON s.CustomerID = c.CustomerID
    LEFT JOIN DimStores st
    ON s.StoreID = st.StoreID
GROUP BY 
    CustomerName, Region
ORDER BY SUM(Quantity*UnitPrice) DESC
