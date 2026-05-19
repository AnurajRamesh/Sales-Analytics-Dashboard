/*
Sales Schema
Core Tables:

Customer - Customer master data (individuals and stores)
SalesOrderHeader, SalesOrderDetail - Sales transactions
SalesPerson - Sales team information
SalesTerritory - Geographic sales regions
SpecialOffer - Discounts and promotions
Key Relationships: Customers link to Person or Store entities, sales orders connect to products, customers, and territories.
*/


/*
1. Customer Lifetime Value (CLV) Segmentation
Question
Which customers generate the most long-term revenue, and how are they distributed?
*/
SELECT 
    c.CustomerID,
    SUM(soh.TotalDue) AS LifetimeValue,
    COUNT(DISTINCT soh.SalesOrderID) AS TotalOrders,
    MIN(soh.OrderDate) AS FirstPurchase,
    MAX(soh.OrderDate) AS LastPurchase
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh 
    ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY LifetimeValue DESC;


/*
2. Cohort Retention Analysis (Monthly)
Question
Do customers return after their first purchase?
*/
SELECT
c.CustomerID,
COUNT(*) AS NoOfReturnsAfterPurchase
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader soh 
ON c.CustomerID = soh.CustomerID
WHERE PurchaseOrderNumber IS NULL
GROUP BY c.CustomerID
ORDER BY NoOfReturnsAfterPurchase DESC;

WITH cohort AS (
  SELECT 
    CustomerID,
    MIN(DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)) AS cohort_month
  FROM Sales.SalesOrderHeader
  GROUP BY CustomerID
),
activity AS (
  SELECT 
    CustomerID,
    DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS activity_month
  FROM Sales.SalesOrderHeader
)
SELECT 
  c.cohort_month,
  a.activity_month,
  COUNT(DISTINCT a.CustomerID) AS active_customers
FROM cohort c
JOIN activity a 
  ON c.CustomerID = a.CustomerID
GROUP BY c.cohort_month, a.activity_month
ORDER BY 1,2;


/*
3. Revenue Contribution by Territory (Pareto 80/20)
 Question
Which territories generate 80% of revenue?

SELECT DISTINCT(TerritoryID)
FROM Sales.SalesOrderHeader;

SELECT * FROM Sales.SalesOrderHeader;
*/
WITH territory_sales AS (
    SELECT 
        st.Name AS TerritoryName,
        ROUND(SUM(soh.TotalDue), 2) AS Revenue
    FROM Sales.SalesOrderHeader soh
    LEFT JOIN Sales.SalesTerritory st
        ON soh.TerritoryID = st.TerritoryID
    GROUP BY st.Name
)

SELECT 
    TerritoryName,
    Revenue,
    ROUND(
        SUM(Revenue) OVER (ORDER BY Revenue DESC) * 1.0
        / SUM(Revenue) OVER (),
        2
    ) AS cumulative_pct
FROM territory_sales
ORDER BY Revenue DESC;


/*
4. Discount Effectiveness Analysis
 Question
Do discounts actually increase revenue?
*/

SELECT 
    sod.SpecialOfferID,
    ROUND(AVG(sod.UnitPriceDiscount),2) AS AvgDiscount,
    CAST(SUM(sod.LineTotal) AS DECIMAL(11,2)) AS Revenue,
    COUNT(*) AS Orders
FROM Sales.SalesOrderDetail sod
GROUP BY sod.SpecialOfferID
ORDER BY sod.SpecialOfferID;


/*
5. Sales Seasonality (Time Intelligence)
 Question
When do we peak?
*/
SELECT 
YEAR(OrderDate) AS year,
MONTH(OrderDate) AS month,
ROUND(SUM(TotalDue),2) AS revenue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);

/*
6. Salesperson Performance vs Quota
Question
Who is over/under performing?
*/
SELECT 
    TOP 14
    sp.BusinessEntityID,
    SUM(soh.TotalDue) AS Sales,
    sp.SalesQuota,
    SUM(soh.TotalDue) - sp.SalesQuota AS Variance
FROM Sales.SalesPerson sp
JOIN Sales.SalesOrderHeader soh
    ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY sp.BusinessEntityID, sp.SalesQuota
ORDER BY Sales DESC;

/*
7. Average Order Value (AOV) Trend
 Question
Are customers spending more per order over time?
*/
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    AVG(TotalDue) AS AvgOrderValue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);

/*
8. Product demand volatility
Question:
Which products are unstable in demand?
*/
SELECT 
TOP 10
ProductID,
AVG(OrderQty) AS AvgQty,
ROUND(STDEV(OrderQty),2) AS Volatility
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY AvgQty DESC;







