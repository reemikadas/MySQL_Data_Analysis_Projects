USE stolen_vehicles_db;

# Data Source: (Project - Motor Vehicle Thefts) "https://mavenanalytics.io/data-playground?order=date_added%2Cdesc&page=6"

# View the stolen_vehicles table
SELECT * FROM stolen_vehicles;

# View the make_details table
SELECT * FROM make_details;

# View the locations table
SELECT * FROM locations;

# ---Analysis---

# 1. How many stolen vehicles are recorded in the database?
SELECT COUNT(*) AS num_of_stolen_vehicles FROM stolen_vehicles;

# 2. What are the different types of vehicles that were stolen?
SELECT DISTINCT vehicle_type FROM stolen_vehicles;

# 3. How many unique makes (make_id) exist in the dataset?
SELECT COUNT(DISTINCT make_id) AS unique_make FROM stolen_vehicles;

# 4. What is the date range for stolen vehicles?
SELECT MIN(date_stolen) AS start_date, MAX(date_stolen) AS end_date FROM stolen_vehicles;

# 5. Which year had the highest number of thefts?
SELECT YEAR(date_stolen) AS year_of_stolen, COUNT(vehicle_id) AS num_of_thefts FROM stolen_vehicles
GROUP BY year_of_stolen
ORDER BY year_of_stolen DESC
LIMIT 1;

# 6. What is the most common date or period for vehicle thefts?
SELECT date_stolen, COUNT(vehicle_id) AS num_of_thefts FROM stolen_vehicles
GROUP BY date_stolen
ORDER BY num_of_thefts DESC
LIMIT 1;

# 7. What is the monthly trend of vehicle thefts?
SELECT YEAR(date_stolen) AS year_stolen, MONTH(date_stolen) AS month_stolen, COUNT(vehicle_id) AS num_of_thefts
FROM stolen_vehicles
GROUP BY year_stolen, month_stolen
ORDER BY year_stolen, month_stolen;

# 8. Which vehicle_type is most frequently stolen?
SELECT vehicle_type, COUNT(vehicle_id) AS num_of_theft
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_of_theft DESC;

# 9. What are the top 5 most frequently stolen vehicle descriptions?
SELECT vehicle_desc, COUNT(vehicle_id) AS num_of_theft
FROM stolen_vehicles
GROUP BY vehicle_desc
ORDER BY num_of_theft DESC
LIMIT 5;

# 10. Which vehicle colors are most frequently targeted for theft?
SELECT color, COUNT(vehicle_id) AS num_of_theft
FROM stolen_vehicles
GROUP BY color
ORDER BY num_of_theft DESC
LIMIT 1;

# 11. What is the average model year of stolen vehicles by type?
SELECT vehicle_type, ROUND(AVG(model_year),0) AS average_year
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY vehicle_type;

# 12. Which location_id has the highest number of stolen vehicles?
SELECT location_id, COUNT(vehicle_id) AS num_of_theft
FROM stolen_vehicles
GROUP BY location_id
ORDER BY num_of_theft DESC
LIMIT 1;

# 13. Which region or country has the most reported vehicle thefts?
SELECT sv.location_id, l.region, COUNT(sv.vehicle_id) AS num_of_theft
FROM stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY sv.location_id, l.region
ORDER BY num_of_theft DESC
LIMIT 1;

# 14. How does theft frequency correlate with population or density?
SELECT l.region, l.population, COUNT(sv.vehicle_id) AS num_of_theft
FROM stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY l.region, l.population
ORDER BY l.population;

# 15. Which make_name is most frequently associated with thefts?
SELECT md.make_name, COUNT(sv.vehicle_id) AS num_of_theft
FROM stolen_vehicles sv
LEFT JOIN make_details md ON sv.make_id = md.make_id
GROUP BY md.make_name
ORDER BY num_of_theft DESC
LIMIT 1;

# 16. What are the top make_type categories by number of thefts?
SELECT md.make_type, COUNT(sv.vehicle_id) AS num_of_theft
FROM stolen_vehicles sv
LEFT JOIN make_details md ON sv.make_id = md.make_id
WHERE md.make_type IS NOT NULL
GROUP BY md.make_type
ORDER BY num_of_theft DESC;

# 17. Are there vehicle types that are more likely to be stolen in certain regions?
SELECT sv.vehicle_type, l.region, COUNT(sv.vehicle_id) AS num_of_theft
FROM stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY sv.vehicle_type, l.region
ORDER BY num_of_theft DESC;

# 18. What day of the week are vehicles most often and least often stolen?
SELECT DAYOFWEEK(date_stolen) AS day_of_week, DAYNAME(date_stolen) AS days,COUNT(vehicle_id) AS least_num_of_theft
FROM stolen_vehicles
GROUP BY day_of_week, days
ORDER BY least_num_of_theft
LIMIT 1;

SELECT DAYOFWEEK(date_stolen) AS day_of_week, DAYNAME(date_stolen) AS days,COUNT(vehicle_id) AS most_num_of_theft
FROM stolen_vehicles
GROUP BY day_of_week, days
ORDER BY most_num_of_theft DESC
LIMIT 1;

# 19. What types of vehicles are most often and least often stolen? Does this vary by region?
SELECT sv.vehicle_type, l.region, COUNT(sv.vehicle_id) AS num_of_theft
FROM stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY sv.vehicle_type, l.region
ORDER BY num_of_theft;

SELECT l.region, sv.vehicle_type, COUNT(sv.vehicle_id) AS num_of_theft
FROM stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY l.region, sv.vehicle_type
ORDER BY num_of_theft DESC;

# 20. What is the average age of the vehicles that are stolen? Does this vary based on the vehicle type?
SELECT ROUND(AVG(YEAR(date_stolen) - model_year),0) AS avg_age FROM stolen_vehicles;

SELECT vehicle_type, ROUND(AVG(YEAR(date_stolen) - model_year),0) AS avg_age FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY avg_age DESC;

# 21. Which regions have the most and least number of stolen vehicles? What are the characteristics of the regions?
SELECT l.region, l.population, l.density, COUNT(sv.vehicle_id) AS least_num_of_theft
FROM stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY l.region, l.population, l.density
ORDER BY least_num_of_theft
LIMIT 1;

SELECT l.region, l.population, l.density, COUNT(sv.vehicle_id) AS most_num_of_theft
FROM stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY l.region, l.population, l.density
ORDER BY most_num_of_theft DESC
LIMIT 1;
