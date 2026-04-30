CREATE DATABASE ecommerce_db;
USE ecommerce_db;
SELECT * FROM ecommerce_data;

-- Customers Table 
CREATE TABLE customers AS
SELECT DISTINCT
    customer_id,
    customer_age,
    customer_gender
FROM ecommerce_data;

-- Products Table
CREATE TABLE products AS
SELECT DISTINCT
    product_id,
    category,
    price
FROM ecommerce_data;

-- Orders Table
CREATE TABLE orders AS
SELECT
    order_id,
    customer_id,
    product_id,
    quantity,
    total_amount,
    discount,
    payment_method,
    order_date,
    delivery_time_days,
    region,
    returned,
    shipping_cost,
    profit_margin
FROM ecommerce_data;

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;

-- 1. Total Revenue by Product Category
SELECT 
    p.category,
    ROUND(SUM(o.total_amount),2) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 2. Top 5 Customers by Total Spending
SELECT 
    o.customer_id,
    ROUND(SUM(o.total_amount),2) AS total_spent
FROM orders o
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 5;

-- 3. Revenue by Customer Gender
SELECT 
    c.customer_gender,
    ROUND(SUM(o.total_amount),2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_gender;

-- 4. Average Profit per Category
SELECT 
    p.category,
    ROUND(AVG(o.profit_margin),2) AS avg_profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_profit DESC;

-- 5. Return Rate by Category
SELECT 
    p.category,
    ROUND((SUM(CASE WHEN o.returned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS return_rate
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY return_rate DESC;

-- 6. Top 3 Regions by Revenue
SELECT 
    o.region,
    ROUND(SUM(o.total_amount),2) AS revenue
FROM orders o
GROUP BY o.region
ORDER BY revenue DESC
LIMIT 3;

-- 7. High Discount vs Low Discount Profit Comparison
SELECT 
    CASE 
        WHEN o.discount = 0 THEN 'No Discount'
        WHEN o.discount <= 0.1 THEN 'Low Discount'
        WHEN o.discount <= 0.2 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_category,
    ROUND(AVG(o.profit_margin),2) AS avg_profit
FROM orders o
GROUP BY discount_category;

-- 8. Customer Age Group Analysis (Revenue)
SELECT 
    CASE 
        WHEN c.customer_age < 25 THEN 'Young'
        WHEN c.customer_age BETWEEN 25 AND 45 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    ROUND(SUM(o.total_amount),2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY age_group
ORDER BY revenue DESC;

-- 9. Find Top 3 Customers in Each Category
SELECT *
FROM (
    SELECT 
        p.category,
        o.customer_id,
        ROUND(SUM(o.total_amount),2) AS total_spent,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(o.total_amount) DESC) AS rnk
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, o.customer_id
) ranked
WHERE rnk <= 3;

-- 10. Find Orders with Above Average Profit
SELECT 
    order_id,
    customer_id,
    product_id,
    profit_margin
FROM orders
WHERE profit_margin > (
    SELECT AVG(profit_margin)
    FROM orders
);