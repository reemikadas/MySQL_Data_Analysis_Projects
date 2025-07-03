USE restaurant_db;
# Data Source: "https://mavenanalytics.io/data-playground?order=date_added%2Cdesc&pageSize=10&search=Restaurant%20Orders"
# Objective 1: Explore the Menu table

# 1. View the menu_items table
SELECT * FROM menu_items;

# 2. Find the number of items on the menu
SELECT COUNT(menu_item_id) AS num_of_items
FROM menu_items;

# 3. What are the least and most expensive items on the menu?
SELECT Min(price) AS least_expensive, MAX(price) AS most_expensive FROM menu_items;

# 4. How many "Italian" dishes are on the menu?
SELECT COUNT(menu_item_id) AS num_of_italian_dish FROM menu_items
WHERE category = "Italian";

# 5. What are the least and most expensive Italian dishes on the menu?
SELECT Min(price) AS italian_least_expensive, MAX(price) AS italian_most_expensive FROM menu_items
WHERE category = "Italian";

# 6. How many dishes are in each category?
SELECT category, COUNT(menu_item_id) AS num_of_dish FROM menu_items
GROUP BY category;

# 7. What is the average dish price within each category?
SELECT category, ROUND(AVG(price),2) as average_dish_price
FROM menu_items
GROUP BY category;

# --------------------------------------------------------------------------------------------------------
# Objective 2: Explore the Orders table

# 1. View the order_details table
SELECT * FROM order_details;

# 2. What is the date range of the table?
SELECT MIN(order_date) AS start_date, MAX(order_date) AS end_date
FROM order_details;

# 3. How many orders were made with this date range?
SELECT COUNT(DISTINCT order_id) FROM order_details;

SELECT COUNT(DISTINCT order_id) FROM order_details
WHERE order_date BETWEEN "2023-01-01" AND "2023-03-31";

# 4. How many items were ordered within this date range?
SELECT COUNT(*) FROM order_details
WHERE order_date BETWEEN "2023-01-01" AND "2023-03-31";

# 5. Which orders had the most number of items?
SELECT order_id, COUNT(item_id) AS num_item
FROM order_details
GROUP BY order_id
HAVING num_item = 14
ORDER BY num_item DESC;

# 6. How many orders had more than 12 items?
SELECT COUNT(order_id) AS num_order FROM 
(SELECT order_id, COUNT(item_id) AS num_item
FROM order_details
GROUP BY order_id
HAVING num_item > 12
ORDER BY num_item DESC) AS s1;

# --------------------------------------------------------------------------------------------------------
# Objective 3: Analyze Customer Behavior

# 1. Combine the menu_items and order_details tables into a single table
SELECT * FROM order_details o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id;

# 2. What were the least and most ordered items? What categories were they in?
SELECT m.item_name, m.category, COUNT(o.order_details_id) AS least_purchase FROM order_details o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY m.item_name, m.category
ORDER BY least_purchase
LIMIT 1;

SELECT m.item_name, m.category, COUNT(o.order_details_id) AS most_purchase FROM order_details o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY m.item_name, m.category
ORDER BY most_purchase DESC
LIMIT 1;

# 3. What were the top 5 orders that spent the most money?
SELECT o.order_id, SUM(m.price) AS total_price FROM order_details o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
GROUP BY o.order_id
ORDER BY total_price DESC
LIMIT 5;

# 4. View the details of the highest spend order. What insights can you gather from it?
SELECT m.category, COUNT(m.menu_item_id) AS num_items, SUM(m.price) AS total_spend FROM order_details o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE o.order_id = 440
GROUP BY m.category
ORDER BY num_items DESC;

# 5. View the details of the top 5 highest spend orders. What insights can you gather from it?
SELECT o.order_id, m.category, COUNT(m.menu_item_id) AS num_items FROM order_details o
LEFT JOIN menu_items m ON o.item_id = m.menu_item_id
WHERE o.order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY o.order_id, m.category
ORDER BY o.order_id, num_items DESC;