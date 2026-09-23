-- E-Commerce Sales Analysis
-- Database: ecommerce
-- Table: sales

USE ecommerce;

-- 1. DATA OVERVIEW
SELECT COUNT(*) AS total_orders FROM sales;
SELECT * FROM sales LIMIT 10;
SELECT MIN(Order_Date) AS first_order_date, MAX(Order_Date) AS last_order_date FROM sales;
SELECT COUNT(DISTINCT Customer_ID) AS unique_customers FROM sales;
SELECT COUNT(DISTINCT Product) AS unique_products FROM sales;

-- 2. DATA QUALITY CHECKS
SELECT
    COUNT(*) AS total_rows,
    SUM(Order_ID IS NULL) AS null_order_id,
    SUM(Order_Date IS NULL) AS null_order_date,
    SUM(Customer_ID IS NULL) AS null_customer_id,
    SUM(Customer_Name IS NULL) AS null_customer_name,
    SUM(Product IS NULL) AS null_product,
    SUM(Category IS NULL) AS null_category,
    SUM(Region IS NULL) AS null_region,
    SUM(Quantity IS NULL) AS null_quantity,
    SUM(Sales IS NULL) AS null_sales,
    SUM(Discount IS NULL) AS null_discount,
    SUM(Profit IS NULL) AS null_profit
FROM sales;

SELECT Order_ID, COUNT(*) AS order_count
FROM sales
GROUP BY Order_ID
HAVING COUNT(*) > 1;

SELECT
    Order_ID, Order_Date, Customer_ID, Customer_Name, Product,
    Category, Region, Quantity, Sales, Discount, Profit,
    COUNT(*) AS record_count
FROM sales
GROUP BY
    Order_ID, Order_Date, Customer_ID, Customer_Name, Product,
    Category, Region, Quantity, Sales, Discount, Profit
HAVING COUNT(*) > 1;

SELECT * FROM sales WHERE Quantity <= 0;
SELECT * FROM sales WHERE Sales < 0;
SELECT * FROM sales WHERE Profit < 0;
SELECT * FROM sales WHERE Discount < 0 OR Discount > 1;

SELECT DISTINCT Category FROM sales ORDER BY Category;
SELECT DISTINCT Region FROM sales ORDER BY Region;

-- 3. OVERALL BUSINESS PERFORMANCE
SELECT ROUND(SUM(Sales), 2) AS total_sales FROM sales;
SELECT ROUND(SUM(Profit), 2) AS total_profit FROM sales;
SELECT SUM(Quantity) AS total_quantity_sold FROM sales;
SELECT ROUND(AVG(Sales), 2) AS average_order_value FROM sales;
SELECT ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS profit_margin_percent FROM sales;

-- 4. CATEGORY ANALYSIS
SELECT Category, ROUND(SUM(Sales), 2) AS total_sales
FROM sales GROUP BY Category ORDER BY total_sales DESC;

SELECT Category, ROUND(SUM(Profit), 2) AS total_profit
FROM sales GROUP BY Category ORDER BY total_profit DESC;

SELECT
    Category,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS profit_margin_percent
FROM sales
GROUP BY Category
ORDER BY total_sales DESC;

-- 5. PRODUCT ANALYSIS
SELECT Product, SUM(Quantity) AS total_quantity
FROM sales GROUP BY Product ORDER BY total_quantity DESC LIMIT 10;

SELECT Product, ROUND(SUM(Sales), 2) AS total_sales
FROM sales GROUP BY Product ORDER BY total_sales DESC LIMIT 10;

SELECT Product, ROUND(SUM(Profit), 2) AS total_profit
FROM sales GROUP BY Product ORDER BY total_profit DESC LIMIT 10;

SELECT
    Product,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS profit_margin_percent
FROM sales
GROUP BY Product
ORDER BY total_sales DESC;

-- 6. REGIONAL ANALYSIS
SELECT Region, ROUND(SUM(Sales), 2) AS total_sales
FROM sales GROUP BY Region ORDER BY total_sales DESC;

SELECT Region, ROUND(SUM(Profit), 2) AS total_profit
FROM sales GROUP BY Region ORDER BY total_profit DESC;

SELECT
    Region,
    COUNT(*) AS total_orders,
    SUM(Quantity) AS units_sold,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND((SUM(Profit) / NULLIF(SUM(Sales), 0)) * 100, 2) AS profit_margin_percent
FROM sales
GROUP BY Region
ORDER BY total_sales DESC;

-- 7. CUSTOMER ANALYSIS
SELECT Customer_ID, Customer_Name, ROUND(SUM(Sales), 2) AS total_sales
FROM sales
GROUP BY Customer_ID, Customer_Name
ORDER BY total_sales DESC LIMIT 10;

SELECT Customer_ID, Customer_Name, ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Customer_ID, Customer_Name
ORDER BY total_profit DESC LIMIT 10;

-- 8. MONTHLY SALES TREND
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS month,
    ROUND(SUM(Sales), 2) AS monthly_sales
FROM sales
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY month;

SELECT
    DATE_FORMAT(Order_Date, '%Y-%m') AS month,
    ROUND(SUM(Profit), 2) AS monthly_profit
FROM sales
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY month;

-- 9. PRODUCT RANKING
SELECT
    Product,
    ROUND(SUM(Sales), 2) AS total_sales,
    RANK() OVER (ORDER BY SUM(Sales) DESC) AS sales_rank
FROM sales
GROUP BY Product
ORDER BY sales_rank;

-- 10. MONTH-OVER-MONTH ANALYSIS
WITH monthly_sales AS (
    SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS month, SUM(Sales) AS total_sales
    FROM sales
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
)
SELECT
    month,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(LAG(total_sales) OVER (ORDER BY month), 2) AS previous_month_sales,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY month))
        / NULLIF(LAG(total_sales) OVER (ORDER BY month), 0)) * 100, 2
    ) AS mom_growth_percent
FROM monthly_sales
ORDER BY month;

-- 11. DISCOUNT ANALYSIS
SELECT
    Discount,
    COUNT(*) AS total_orders,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit
FROM sales
GROUP BY Discount
ORDER BY Discount;

-- 12. HIGH-VALUE ORDERS
SELECT
    Order_ID, Order_Date, Customer_Name, Product, Category, Region,
    Quantity, ROUND(Sales, 2) AS Sales, ROUND(Profit, 2) AS Profit
FROM sales
ORDER BY Sales DESC
LIMIT 10;
