# Sales Analytics Dashboard – SQL & Power BI



## Project Overview



This project is a Sales Analytics Portfolio built using the Microsoft SQL Server and Power BI on the AdvancedWorks2025 Database.



The objective of this project is to transform raw sales data into actionable business intelligence by analyzing:



* Customer Lifetime Value (CLV)

* Salesperson performance

* Revenue contribution by territories

* Discount effectiveness

* Sales distribution patterns

* Revenue concentration (Pareto 80/20 Analysis)

* Product demand volatility

* Average Order Value Trends

The dashboard enables strategic decision-making by highlighting revenue drivers, high-performing customers and salespersons, and supply-demand patterns.



## Business Objectives

Many organizations generate huge amounts of sales data in a daily basis, but raw transactional data itself does not provide strategic insights.

The business needed answers to critical questions include:

* Which customers generate the maximum long-term revenue?
* Among all the territories, which one contribute to most total sales?
* Does discount really improving revenue?
* Which sales person outperform their quotas?
* How concentrated is the company revenue system?
* Which customers and the regions need special consideration?
* Which products show unstable demand?



## Used Tools



* MS SQL Server Management Studio: Data extraction and transformation
* MS Power BI: Data visualization and creation of dashboards
* DAX: KPI calculations and dynamic metrics
* AdventureWorks2025: Source database
* SSMS: Query development



## Database Schema

Sales Schema: Core tables used

* Sales.Customer: Customer master data
* Sales.SalesOrderHeader: Sales transaction headers
* Sales.SalesOrderDetail: Line-level sales transactions
* Sales.SalesPerson: Sales team performance
* Sales.SalesTerritory: Geographic territories
* Sales.SpecialOffer: Discount and promotion data



## Project Structure



	├── 01_Power_BI_Files

		├── 02_Sales_AdventureWorks2025.pbix

	├── 02_Visualization_Power_BI

		├── Sales_Dashboards.pdf

		├── Sales_Dashboard_1.png

		├── Sales_Dashboard_2.png

	├── 02_Sales_Schema_SQL_Query.sql
	
	├── ReadMe.md





## Business Analysis Performed

# 1. Customer Lifetime Value (CLV) Segmentation
Business Question

Which customers generate the highest long-term revenue?

SQL Analysis:

```sql
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
```




Key Insights



* Identified high-value customers contributing disproportionally to revenue
* Measured customer revenue through purchase history
* Analyzed customer purchasing frequency
* Revealed long-term revenue concentration among a small customer segment



Business Impact

This analysis helps businesses:

* Prioritize highly valuable customers
* Improve retention strategies
* Adopt targeted loyality programs
* Increase customer profitability



# 2. Revenue Contribution by Territory (Pareto 80/20 Analysis)
Business Question

Which territories contribute to the majority of revenue?

SQL Analysis:

```sql
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
```




Key Insights



* Southwest territory generated the highest revenue
* Revenue distribution follows the Pareto principle
* A small number of territories contribute the majority of total sales
* Revenue dependency on key regions was identified


Business Impact

This analysis helps management:

* Focus investments on high-performing territories
* Optimize regional sales strategies
* Reduce dependency risks
* Allocate resources efficiently



# 3. Discount Effectiveness Analysis
Business Question

Do discounts increase sales revenue?

SQL Analysis:

```sql
SELECT 
    sod.SpecialOfferID,
    ROUND(AVG(sod.UnitPriceDiscount),2) AS AvgDiscount,
    CAST(SUM(sod.LineTotal) AS DECIMAL(11,2)) AS Revenue,
    COUNT(*) AS Orders
FROM Sales.SalesOrderDetail sod
GROUP BY sod.SpecialOfferID
ORDER BY sod.SpecialOfferID;
```




Key Insights



* Maximum revenue was generated from products sold with 0% discount
* Heavy discounts did not proportionally increase revenue
* Discounts may reduce profitability without significantly improving sales volume
* Customers may value product demand and quality over discounts


Business Impact

This analysis supports:

* Smarter pricing strategies
* Discount optimization
* Margin protection
* Better promotional planning
* Business Impact




# 4. Salesperson Performance vs Quota
Business Question

Which salespersons are overperforming or underperforming?

SQL Analysis:

```sql
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
```




Key Insights



* Top-performing salesperson generated approximately $11.7M in total sales
* Significant performance gaps exist between salespersons
* Several salespersons exceeded quotas substantially
* Revenue generation is concentrated among a few high performers


Business Impact

This enables:

* Performance benchmarking
* Incentive optimization
* Targeted coaching
* Better quota planning




# 5. Average Order Value (AOV) Trend
Business Question

Are customers spending more per order over time?

SQL Analysis:

```sql
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    AVG(TotalDue) AS AvgOrderValue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);
```




Key Insights

* Early months of **2024 and 2025** show higher revenue
* Average Order Value varies across years, indicating customer purchasing behavior shifts
* Maximum AOV reached in **09/2022**, possibly linked to promotional campaigns or key clients


Business Impact

This analysis:

* Enables targeted pricing strategies by identifying periods of high customer spend  
* Supports forecasting and planning for peak AOV periods  
* Helps evaluate effectiveness of promotions and campaigns  
* Guides marketing and sales initiatives to maximize revenue per order  
* Provides insight for customer segmentation based on spending behavior 





# 6. Product demand volatility
Business Question

Which products are unstable in demand?

SQL Analysis:

```sql
SELECT 
TOP 10
ProductID,
AVG(OrderQty) AS AvgQty,
ROUND(STDEV(OrderQty),2) AS Volatility
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY AvgQty DESC;
```




Key Insights



* Products **863, 867, 864** have relatively high volatility vs average quantities
* Top 10 products dominate sales volume but have varying stability
* Volatile products should be prioritized for **inventory & supply chain optimization**


Business Impact

This analysis:

* Optimizes inventory and supply chain by identifying high-volatility products  
* Helps reduce stockouts or overstock situations for critical SKUs  
* Supports demand forecasting and procurement planning  
* Guides product prioritization for promotions or discounts  
* Improves operational efficiency and working capital management 





# 7. Sales Seasonality (Time Intelligence)
Business Question

When do revenue peak?

SQL Analysis:

```sql
SELECT 
YEAR(OrderDate) AS year,
MONTH(OrderDate) AS month,
ROUND(SUM(TotalDue),2) AS revenue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);
```




Key Insights



* Southwest territory contributes the highest revenue
* Revenue is concentrated among a few high-performing salespersons
* Pareto analysis highlights focus areas for regional investments and quota optimization


Business Impact

This analysis:

* Informs staffing, capacity, and resource allocation for seasonal peaks  
* Supports timing of marketing campaigns and promotional efforts  
* Enables proactive management of high-revenue months  
* Provides insights for financial planning and revenue forecasting  
* Helps identify recurring trends for strategic operational decisions  





## Dashboard 1 Features
<img width="1277" height="717" alt="Sales_Dashboard_1" src="https://github.com/user-attachments/assets/ab9e5286-7b8e-44ac-8593-0b4ac92319e4" />







Power BI Dashboards Include:

Executive KPIs
* Highest Sales Revenue
* Maximum Territory Revenue
* Maximum Revenue at Discount
* Maximum Customer Lifetime Value

Visualizations
* Customer Lifetime Value Scatter Plot
* Territory Revenue Pareto Analysis
* Discount vs Revenue Trend
* Salesperson Performance Ranking
* Revenue Distribution Analysis

Interactive Features
* Drill-down analysis
* Territory-level filtering
* Dynamic KPI cards
* Cross-filtering between visuals

## Business Insights



Customer Insights
* A small number of customers contribute a significant share of long-term revenue
* High-value customers demonstrate repeat purchasing behavior
* Customer revenue concentration suggests strong opportunities for retention programs

Territory Insights
* Southwest territory is the primary revenue driver
* Revenue generation is uneven across regions
* Geographic concentration creates both opportunities and risks

Pricing & Discount Insights
* Revenue peaks at 0% discount levels
* Excessive discounting does not necessarily increase sales
* Margin-focused pricing strategies may outperform aggressive promotions

Sales Team Insights
* Revenue contribution is highly concentrated among top-performing salespersons
* Large variance exists between quota achievement levels
* High performers significantly influence overall sales performance


## Dashboard 2 Features
<img width="1146" height="640" alt="Sales_Dashboard_2" src="https://github.com/user-attachments/assets/85d217e8-b581-4f3b-9998-461f7263662a" />








Power BI Dashboards Include:

Executive KPIs
* Maximum Revenue (Monthly)
* Highest Product Demand Volatility
* Maximum Average Order Value

Visualizations
* Average Order Value (AOV) Scatter Plot by Year
* Product Demand Volatility Scatter Plot
* Revenue by Year & Month Bar Chart

Interactive Features
* Drill-down by month and year
* Product-level filtering
* Dynamic KPI cards
* Cross-filtering between visuals

## Business Insights

### Average Order Value (AOV) Trend Insights
* Variability in average order value across different years
* Peak AOV observed in September 2022
* Early months of 2024 and 2025 show higher revenue

**Business Impact**
* Supports smarter pricing strategies based on customer spending trends
* Highlights periods for targeted promotions
* Provides insights for revenue forecasting

### Product Demand Volatility Insights
* Products 863, 867, 864 exhibit higher volatility relative to average quantities
* Top-selling products have varying stability
* Highlights items with unstable demand that may require inventory attention

**Business Impact**
* Supports inventory planning and supply chain optimization
* Identifies high-risk products for demand forecasting
* Enables data-driven decisions for stock balancing and replenishment

### Sales Seasonality (Time Intelligence) Insights
* Monthly revenue distribution reveals seasonal peaks and troughs
* Highlights months with highest revenue generation
* Shows recurring sales patterns over multiple years

**Business Impact**
* Informs promotional and marketing calendar planning
* Helps anticipate peak demand periods for operational readiness
* Supports capacity and staffing decisions during high-revenue months




## Advanced SQL Concepts Used

This project demonstrates practical implementation of:

* Common Table Expressions (CTEs)
* Window Functions
* Aggregate Functions
* Ranking Logic
* Analytical Queries
* Business KPI Calculations
* Revenue Segmentation
* Pareto Analysis
* Customer Analytics










