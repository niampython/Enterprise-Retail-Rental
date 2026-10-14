SELECT 
    Region, 
    year(OrderDate) year, 
    month(OrderDate) month, 
    FORMAT(sum(quantity*UnitPrice), 'C', 'en-us') TotalSales, 
    RANK() OVER(PARTITION BY year(OrderDate), month(OrderDate)  ORDER BY sum(quantity*UnitPrice) DESC) RegionRank
FROM 
    FactSales s INNER JOIN DimStores st 
ON 
    s.storeid = st.storeid
GROUP BY 
    Region, 
    year(OrderDate) , 
    month(OrderDate)
