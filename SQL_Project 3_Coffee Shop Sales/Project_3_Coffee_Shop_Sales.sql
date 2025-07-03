CREATE DATABASE IF NOT EXISTS coffee_sales_db;
USE coffee_sales_db;

-- Add new columns with correct data types
ALTER TABLE coffee_sales
ADD COLUMN transaction_date_clean DATE,
ADD COLUMN transaction_time_clean TIME;

-- Rectify with correct Data Type
SET SQL_SAFE_UPDATES = 0;
UPDATE coffee_sales
SET 
  transaction_date_clean = STR_TO_DATE(transaction_date, '%m/%d/%Y'),
  transaction_time_clean = STR_TO_DATE(transaction_time, '%H:%i:%s');
SET SQL_SAFE_UPDATES = 1;

-- Drop old columns
ALTER TABLE coffee_sales
DROP COLUMN transaction_date,
DROP COLUMN transaction_time;

-- Rename the new columns to original names
ALTER TABLE coffee_sales
CHANGE transaction_date_clean transaction_date DATE,
CHANGE transaction_time_clean transaction_time TIME;

-- Reorder to its Original position
ALTER TABLE coffee_sales
MODIFY COLUMN transaction_date DATE AFTER transaction_id;

ALTER TABLE coffee_sales
MODIFY COLUMN transaction_time TIME AFTER transaction_date;
# ------------------------------------------------------------------------------------------------------------------

# View the Data
SELECT * FROM coffee_sales;

# --- Basic Exploration ---

# 1. How many total transactions are there?
SELECT COUNT(DISTINCT transaction_id) AS total_transactions FROM coffee_sales;
SELECT COUNT(transaction_id) AS total_transactions FROM coffee_sales;

# Note: All transactions are unique. There are no duplicate transaction_id.

# 2. How many unique products are sold?
SELECT COUNT(DISTINCT product_category) AS unique_products FROM coffee_sales;

# 3. How many unique store locations are there and where are they?
SELECT COUNT(DISTINCT store_location) AS num_unique_store FROM coffee_sales;
SELECT DISTINCT store_location AS unique_store FROM coffee_sales;

# 4. What are the unique product categories and product types?
SELECT DISTINCT product_category AS unique_product FROM coffee_sales;
SELECT DISTINCT product_type AS unique_product_type FROM coffee_sales;

# --- Sales Overview ---

# 1. What is the total quantity sold?
SELECT SUM(transaction_qty) AS total_quantity FROM coffee_sales;

# 2. What is the total revenue?
SELECT ROUND(SUM(transaction_qty * unit_price),2) AS total_revenue FROM coffee_sales;

# 3. What is the average transaction value?
SELECT ROUND(AVG(transaction_qty * unit_price),2) AS average_transaction FROM coffee_sales;

# 4. What is the total revenue per day?
SELECT transaction_date, ROUND(SUM(transaction_qty * unit_price),2) AS revenue_each_day
FROM coffee_sales
GROUP BY transaction_date;

# --- Time-Based Analysis ---

# 1. What are the peak transaction hours during the day?
SELECT HOUR(transaction_time) AS transaction_hour, COUNT(transaction_id) AS num_of_transaction
FROM coffee_sales
GROUP BY transaction_hour
ORDER BY num_of_transaction DESC;

# 2. How does revenue vary by hour of the day?
SELECT HOUR(transaction_time) AS transaction_hour, ROUND(SUM(transaction_qty * unit_price),2) AS revenue_per_hour
FROM coffee_sales
GROUP BY transaction_hour
ORDER BY transaction_hour;

# 3. What is the hourly average quantity sold per store?
SELECT store_location, HOUR(transaction_time) AS transaction_hour, ROUND(AVG(transaction_qty),2) AS avg_qty_sold
FROM coffee_sales
GROUP BY store_location, transaction_hour
ORDER BY store_location, transaction_hour;

# 4. What is the trend of transactions across different time windows (morning, afternoon, evening)?
SELECT
CASE
	WHEN (HOUR(transaction_time) >= 6 AND HOUR(transaction_time) < 12) THEN "Morning"
    WHEN (HOUR(transaction_time) >= 12 AND HOUR(transaction_time) < 16) THEN "Afternoon"
    ELSE "Evening"
END AS time_windows,
COUNT(transaction_id) AS num_of_transaction
FROM coffee_sales
GROUP BY  time_windows;

# --- Store Performance ---

# 1. What is the total revenue by each store location?
SELECT store_location, ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY store_location
ORDER BY revenue DESC;

# 2. Which store has the highest number of transactions?
SELECT store_location, COUNT(transaction_id) AS num_of_transaction
FROM coffee_sales
GROUP BY store_location
ORDER BY num_of_transaction DESC
LIMIT 1;

# 3. What is the average basket size per store?
SELECT store_location, ROUND(AVG(transaction_qty), 2) AS avg_basket_size
FROM coffee_sales
GROUP BY store_location
ORDER BY store_location;

# --- Product Insights ---

# 1. Which product categories generate the most revenue?
SELECT product_category, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY product_category
ORDER BY revenue DESC;

# 2. Which product types are most frequently purchased?
SELECT product_type, COUNT(transaction_id) AS num_of_transaction
FROM coffee_sales
GROUP BY product_type
ORDER BY num_of_transaction DESC;

# 3. What is the top-selling product by quantity?
SELECT product_category, product_type, SUM(transaction_qty) AS total_quantity
FROM coffee_sales
GROUP BY product_category, product_type
ORDER BY total_quantity DESC;

# 4. What is the highest revenue-generating product?
SELECT product_category, product_type, ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY product_category, product_type
ORDER BY revenue DESC
LIMIT 1;

# 5. What is the average unit price per category/type?
SELECT product_category, ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM coffee_sales
GROUP BY product_category
ORDER BY avg_unit_price DESC;

SELECT product_type, ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM coffee_sales
GROUP BY product_type
ORDER BY avg_unit_price DESC;

# --- Advance ---

# 1. What is the contribution of each store to overall revenue (%)?
SET @total_revenue = (SELECT ROUND(SUM(transaction_qty * unit_price),2) FROM coffee_sales);

SELECT store_location, ROUND((SUM(transaction_qty * unit_price) / @total_revenue) * 100,2) AS revenue_contribution
FROM coffee_sales
GROUP BY store_location
ORDER BY revenue_contribution DESC;

# 2. What is the revenue split by product category across stores?
SELECT store_location, product_category, ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY store_location, product_category
ORDER BY store_location, revenue DESC;

# 3. Which days of the week tend to be busiest, and why do you think that's the case?
SELECT DAYNAME(transaction_date) AS day_of_week, COUNT(transaction_id) AS num_of_transaction, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY day_of_week
ORDER BY revenue DESC;
# Why> --> Weekdays tends to be busiest due to office work routines

# Which products are sold most and least often? Which drive the most revenue for the business?
SELECT product_category, product_type, SUM(transaction_qty) AS least_qty_sold, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY product_category, product_type
ORDER BY least_qty_sold
LIMIT 1;

SELECT product_category, product_type, SUM(transaction_qty) AS most_qty_sold, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY product_category, product_type
ORDER BY most_qty_sold DESC
LIMIT 1;

# "Green Beans" of product category "Coffee Beans" and "Brewed Chai Tea" from "Tea" category are least and most often sold products respectively. Among the two, "Brewed Chai Tea" contributes more to the revenue.

# Which months have total revenue greater than or equal to the overall average monthly revenue?
SET @avg_monthly_revenue =
							(SELECT ROUND(AVG(revenue),2) FROM (SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
							FROM coffee_sales
							GROUP BY transaction_month) AS s1);

SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS monthly_revenue
FROM coffee_sales
GROUP BY transaction_month
HAVING monthly_revenue > @avg_monthly_revenue;

# Which months have total revenue less than the overall average monthly revenue?
SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS monthly_revenue
FROM coffee_sales
GROUP BY transaction_month
HAVING monthly_revenue < @avg_monthly_revenue;

# Which months contribute the most by revenue?
SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY transaction_month
ORDER BY revenue DESC;

# What is the revenue split by months across stores? Which store generates more revenue and in which month?
SELECT store_location, MONTHNAME(transaction_date) AS transaction_months, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY store_location, transaction_months
ORDER BY store_location, revenue DESC;

# Which store generates more revenue and in which month?
SELECT store_location, MONTHNAME(transaction_date) AS transaction_months, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY store_location, transaction_months
ORDER BY revenue DESC
LIMIT 1;

# Which store generates less revenue and in which month?
SELECT store_location, MONTHNAME(transaction_date) AS transaction_months, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY store_location, transaction_months
ORDER BY revenue
LIMIT 1;