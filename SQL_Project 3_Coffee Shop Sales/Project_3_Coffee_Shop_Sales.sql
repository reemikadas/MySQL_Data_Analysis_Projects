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

# How many total transactions are there?
SELECT COUNT(DISTINCT transaction_id) AS total_transactions FROM coffee_sales;
SELECT COUNT(transaction_id) AS total_transactions FROM coffee_sales;

-- > There are 149116 unique transactions.

# How many unique products are sold?
SELECT COUNT(DISTINCT product_category) AS unique_products FROM coffee_sales;

-- > There are 9 unique products sold by the shops.

# How many unique store locations are there and where are they?
SELECT COUNT(DISTINCT store_location) AS num_unique_store FROM coffee_sales;
SELECT DISTINCT store_location AS unique_store FROM coffee_sales;

-- > There are 3 coffee shops and located at Lower Manhattan, Hell's Kitchen, and Astoria.

# What are the unique product categories and product types?
SELECT DISTINCT product_category AS unique_product FROM coffee_sales;
SELECT DISTINCT product_type AS unique_product_type FROM coffee_sales;

# What is the total quantity sold?
SELECT SUM(transaction_qty) AS total_quantity FROM coffee_sales;

-- > 214,470 of total quantity solds across all the stores.

# What is the total revenue?
SELECT ROUND(SUM(transaction_qty * unit_price),2) AS total_revenue FROM coffee_sales;

-- > $698,812.33 of total revenue earned across all the stores.

# What is the average transaction value?
SELECT ROUND(AVG(transaction_qty * unit_price),2) AS average_transaction FROM coffee_sales;

-- > Average Transactin = $4.69

# What is the total revenue per day?
SELECT transaction_date, ROUND(SUM(transaction_qty * unit_price),2) AS revenue_each_day
FROM coffee_sales
GROUP BY transaction_date;

# What is the business hours of these stores?
SELECT store_location, MIN(HOUR(transaction_time)) AS shift_starts, (MAX(HOUR(transaction_time))+1) AS shift_ends
FROM coffee_sales
GROUP BY store_location;

-- > Lower Manhattan and Hell's Kitchen operating hours = 6:00 AM - 9:00 PM
-- > Astoria's operating hours = 7:00 AM - 8:00 PM

# What are the peak transaction hours during the day?
SELECT HOUR(transaction_time) AS transaction_hour, COUNT(transaction_id) AS num_of_transaction
FROM coffee_sales
GROUP BY transaction_hour
HAVING num_of_transaction > 15000
ORDER BY num_of_transaction DESC;

-- > Peak hours observed during the day between 8:00 AM - 11:00 AM.

# How does revenue vary by hour of the day?
SELECT HOUR(transaction_time) AS transaction_hour, ROUND(SUM(transaction_qty * unit_price),2) AS revenue_per_hour
FROM coffee_sales
GROUP BY transaction_hour
ORDER BY revenue_per_hour DESC;

-- > Major income are earned during the peak hours.

# What is the hourly average quantity sold per store?
SELECT store_location, HOUR(transaction_time) AS transaction_hour, ROUND(AVG(transaction_qty),2) AS avg_qty_sold
FROM coffee_sales
GROUP BY store_location, transaction_hour
ORDER BY store_location, transaction_hour;

# What is the trend of transactions across different time windows (morning, afternoon, evening)? How much transactions are contributed by each?
SELECT
CASE
	WHEN (HOUR(transaction_time) >= 6 AND HOUR(transaction_time) < 12) THEN "Morning"
    WHEN (HOUR(transaction_time) >= 12 AND HOUR(transaction_time) < 16) THEN "Afternoon"
    ELSE "Evening"
END AS time_windows,
COUNT(transaction_id) AS num_of_transaction
FROM coffee_sales
GROUP BY  time_windows;

SET @total_transaction = (SELECT COUNT(transaction_id) AS num_of_transaction FROM coffee_sales);

SELECT
CASE
	WHEN (HOUR(transaction_time) >= 6 AND HOUR(transaction_time) < 12) THEN "Morning"
    WHEN (HOUR(transaction_time) >= 12 AND HOUR(transaction_time) < 16) THEN "Afternoon"
    ELSE "Evening"
END AS time_windows,
ROUND((COUNT(transaction_id) / @total_transaction) * 100,0) AS proportion_transaction
FROM coffee_sales
GROUP BY  time_windows;

-- > 55% of transactions are occured during morning

# Which stores generates more revenue in Morning?
SELECT store_location,
CASE
	WHEN (HOUR(transaction_time) >= 6 AND HOUR(transaction_time) < 12) THEN "Morning"
    WHEN (HOUR(transaction_time) >= 12 AND HOUR(transaction_time) < 16) THEN "Afternoon"
    ELSE "Evening"
END AS time_windows,
ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY  store_location, time_windows
HAVING time_windows = "Morning"
ORDER BY revenue DESC
LIMIT 1;

-- > Lower Manhattan generates more revenue in the morning

# Which stores generates more revenue in Afternoon?
SELECT store_location,
CASE
	WHEN (HOUR(transaction_time) >= 6 AND HOUR(transaction_time) < 12) THEN "Morning"
    WHEN (HOUR(transaction_time) >= 12 AND HOUR(transaction_time) < 16) THEN "Afternoon"
    ELSE "Evening"
END AS time_windows,
ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY  store_location, time_windows
HAVING time_windows = "Afternoon"
ORDER BY revenue DESC
LIMIT 1;

-- > Astoria generates more revenue in the Afternoon

# Which stores generates more revenue in Evening?
SELECT store_location,
CASE
	WHEN (HOUR(transaction_time) >= 6 AND HOUR(transaction_time) < 12) THEN "Morning"
    WHEN (HOUR(transaction_time) >= 12 AND HOUR(transaction_time) < 16) THEN "Afternoon"
    ELSE "Evening"
END AS time_windows,
ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY  store_location, time_windows
HAVING time_windows = "Evening"
ORDER BY revenue DESC
LIMIT 1;

-- > Astoria generates more revenue in the Evening as well

# What is the date range of this data?
SELECT MIN(transaction_date) AS start_date, MAX(transaction_date) AS end_date FROM coffee_sales;

-- > Period of Analysis = 2023-01-01 to 2023-06-30

# What is the total revenue by each store location?
SELECT store_location, ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY store_location
ORDER BY revenue DESC;

-- > Hell's Kitchen leading in sales performance

# Which store has the highest number of transactions?
SELECT store_location, COUNT(transaction_id) AS num_of_transaction
FROM coffee_sales
GROUP BY store_location
ORDER BY num_of_transaction DESC
LIMIT 1;

-- > Hell's Kitchen with 50,735 transactions

# What is the average basket size per store?
SELECT store_location, ROUND(AVG(transaction_qty), 2) AS avg_basket_size
FROM coffee_sales
GROUP BY store_location
ORDER BY store_location;

# Which product categories generate the most revenue?
SELECT product_category, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY product_category
ORDER BY revenue DESC;

-- > Coffee is the top selling product

# Which product types are most frequently purchased?
SELECT product_type, SUM(transaction_qty) AS num_of_purchase
FROM coffee_sales
GROUP BY product_type
ORDER BY num_of_purchase DESC;

-- > Brewed Chai Tea, Gourmet brewed coffee, and Barista expresso are most frequently purchased products

# Which product categories are most frequently purchased?
SELECT product_category, SUM(transaction_qty) AS num_of_purchase
FROM coffee_sales
GROUP BY product_category
ORDER BY num_of_purchase DESC;

-- > Coffee and Tea are most frequently purchased product category

# What is the top-selling product by quantity?
SELECT product_category, product_type, SUM(transaction_qty) AS total_quantity
FROM coffee_sales
GROUP BY product_category, product_type
ORDER BY total_quantity DESC;

-- > Brewed Chai Tea, Gourmet brewed coffee, and Barista expresso are top-selling product by quantity

# Out of the most frequently purchase product category, Which product type is the highest revenue-generating product?
SELECT product_category, product_type, ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY product_category, product_type
ORDER BY revenue DESC;

-- > Out of the most frequently purchased category i.e. coffee, Barista Expresso is the one with highest revenue.

# What is the average unit price per category/type?
SELECT product_category, ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM coffee_sales
GROUP BY product_category
ORDER BY avg_unit_price DESC;

SELECT product_type, ROUND(AVG(unit_price), 2) AS avg_unit_price
FROM coffee_sales
GROUP BY product_type
ORDER BY avg_unit_price DESC;

# What is the contribution of each store to overall revenue (%)?
SET @total_revenue = (SELECT ROUND(SUM(transaction_qty * unit_price),2) FROM coffee_sales);

SELECT store_location, ROUND((SUM(transaction_qty * unit_price) / @total_revenue) * 100,2) AS revenue_contribution
FROM coffee_sales
GROUP BY store_location
ORDER BY revenue_contribution DESC;

-- > Hell's Kitchen contributes the highest with 33.84%, followed closely by Astoria and Lower Manhattan

# What is the revenue split by product category across stores?
SELECT store_location, product_category, ROUND(SUM(transaction_qty * unit_price),2) AS revenue
FROM coffee_sales
GROUP BY store_location, product_category
ORDER BY store_location, revenue DESC;

# Which days of the week tend to be busiest, and why do you think that's the case?
SELECT DAYNAME(transaction_date) AS day_of_week, COUNT(transaction_id) AS num_of_transaction, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY day_of_week
ORDER BY revenue DESC;

-- > Weekdays tends to be the busiest due to office work and college routines

# Which products are sold most and least often? Which drive the most revenue for the business?
SELECT product_category, SUM(transaction_qty) AS least_qty_sold, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY product_category
ORDER BY least_qty_sold
LIMIT 1;

SELECT product_category, SUM(transaction_qty) AS most_qty_sold, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY product_category
ORDER BY most_qty_sold DESC
LIMIT 1;

# "Packaged Chocolate" and "Coffee" are least and most often sold products respectively. Among the two, "Coffee" contributes more to the revenue.

# Which months have total revenue greater than or equal to the overall average monthly revenue?
SET @avg_monthly_revenue =
							(SELECT ROUND(AVG(revenue),2) FROM (SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
							FROM coffee_sales
							GROUP BY transaction_month) AS s1);

SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS monthly_revenue
FROM coffee_sales
GROUP BY transaction_month
HAVING monthly_revenue > @avg_monthly_revenue;

-- > April, May, and June have total revenue greater than or equal to overall average monthly revenue.

# Which months have total revenue less than the overall average monthly revenue?
SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS monthly_revenue
FROM coffee_sales
GROUP BY transaction_month
HAVING monthly_revenue < @avg_monthly_revenue;

-- > January, February, and March have total revenue less than overall average monthly revenue.

# Which months contribute the most by revenue?
SELECT MONTHNAME(transaction_date) AS transaction_month, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY transaction_month
ORDER BY revenue DESC;

-- > June month is contributing the most by revenue

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

-- > Hell's Kitchen generate more revenue in June.

# Which store generates less revenue and in which month?
SELECT store_location, MONTHNAME(transaction_date) AS transaction_months, ROUND(SUM(transaction_qty * unit_price), 2) AS revenue
FROM coffee_sales
GROUP BY store_location, transaction_months
ORDER BY revenue
LIMIT 1;

-- > Astoria generate less revenue in February.