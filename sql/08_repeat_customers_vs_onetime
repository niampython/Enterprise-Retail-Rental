WITH CTE AS
(
    SELECT customername, count(orderid) order_count
    FROM FACTSALES s  
    LEFT JOIN DimCustomers c
    ON c.CustomerID = s.CustomerID
    GROUP BY CustomerName
)

SELECT COUNT(CASE WHEN order_count > 1 THEN CustomerName END) Repeat_Customer,
COUNT(CASE WHEN order_count = 1 THEN CustomerName END) OneTime_Customer
FROM CTE
