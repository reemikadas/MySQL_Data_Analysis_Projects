USE stolen_vehicles_db;

# Data Source: (Project - Motor Vehicle Thefts) "https://mavenanalytics.io/data-playground?order=date_added%2Cdesc&page=6"

# View the stolen_vehicles table
SELECT * FROM stolen_vehicles;

# View the make_details table
SELECT * FROM make_details;

# View the locations table
SELECT * FROM locations;

# ---Analysis---

# How many stolen vehicles are recorded in the database?
SELECT COUNT(vehicle_id) AS num_of_stolen_vehicles FROM stolen_vehicles;

-- > 4553 stolen vehicles were recorded

# Check whether the vehicle type contains NULL values
SELECT COUNT(*) AS total_missing_values FROM stolen_vehicles
WHERE vehicle_id IS NULL OR
vehicle_type IS NULL OR
make_id IS NULL OR
model_year IS NULL OR
vehicle_desc IS NULL OR
color IS NULL OR
date_stolen IS NULL OR
location_id IS NULL;

-- > Overall, there are total 44 rows with missing values.

# Removing the rows with missing values and create a temporary table for further analysis
CREATE TEMPORARY TABLE cleaned_stolen_vehicles AS
SELECT * FROM stolen_vehicles
WHERE
vehicle_type IS NOT NULL AND
make_id IS NOT NULL AND
model_year IS NOT NULL AND
vehicle_desc IS NOT NULL AND
color IS NOT NULL;

-- Analysis with Cleaned Data --
SELECT * FROM cleaned_stolen_vehicles;

# How many stolen vehicles are recorded in the database?
SELECT COUNT(*) AS num_of_records FROM cleaned_stolen_vehicles;

-- > Total of 4509 stolen vehicles recorded after handling the missing values.

# What are the different types of vehicles that were stolen and how many?
SELECT DISTINCT vehicle_type FROM cleaned_stolen_vehicles;
SELECT COUNT(DISTINCT vehicle_type) AS num_of_vehicle_type FROM cleaned_stolen_vehicles;

-- > There are 25 unique type of vehicle that were stolen.

# Which Vehicle type stole the most?
SELECT vehicle_type, COUNT(vehicle_type) AS num_of_theft
FROM cleaned_stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_of_theft DESC;

-- > 'Stationwagon' were the most frequently stolen vehicle type, with 944 incidents.

# Verify the total thefts is matching with total records
SELECT SUM(num_of_theft) AS total_thefts FROM (SELECT vehicle_type, COUNT(vehicle_type) AS num_of_theft
FROM cleaned_stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_of_theft DESC) AS s1;

-- > There are total of 4509 vehicles that were stolen and matched with the total records.

# How many unique makes (make_id) exist in the dataset?
SELECT COUNT(DISTINCT make_id) AS unique_makers FROM cleaned_stolen_vehicles;

-- > The stolen vehicles belong to 135 distinct car brands. 

# What is the date range for stolen vehicles?
SELECT MIN(date_stolen) AS start_date, MAX(date_stolen) AS end_date FROM cleaned_stolen_vehicles;

-- > The details of vehicles that were stolen is from "2021-10-07" to "2022-04-06".

# Which year had the highest number of thefts?
SELECT YEAR(date_stolen) AS year_of_stolen, COUNT(vehicle_id) AS num_of_thefts
FROM cleaned_stolen_vehicles
GROUP BY year_of_stolen
ORDER BY year_of_stolen DESC;

-- > 2022 marked the highest number of thefts with 2860

# Which year had the highest percent of thefts?
SET @total_thefts = (SELECT COUNT(*) FROM cleaned_stolen_vehicles);

SELECT YEAR(date_stolen) AS year_of_stolen, ROUND((COUNT(vehicle_id) / @total_thefts) * 100,0) AS theft_ratio_by_year
FROM cleaned_stolen_vehicles
GROUP BY year_of_stolen
ORDER BY theft_ratio_by_year DESC;

-- > 63% of thefts took place in 2022.

# Which month in 2022 contribute the most to theft by volume and proportion?
SET @total_thefts_2022 = (SELECT SUM(num_of_thefts) FROM(SELECT MONTH(date_stolen) AS month_of_theft, COUNT(vehicle_id) AS num_of_thefts
FROM cleaned_stolen_vehicles
WHERE YEAR(date_stolen) = "2022"
GROUP BY month_of_theft
ORDER BY num_of_thefts DESC)AS s1);

SELECT MONTH(date_stolen) AS month_of_theft,
COUNT(vehicle_id) AS num_of_thefts,
ROUND((COUNT(vehicle_id) / @total_thefts_2022) * 100,2) AS theft_ratio_by_month
FROM cleaned_stolen_vehicles
WHERE YEAR(date_stolen) = "2022"
GROUP BY month_of_theft
ORDER BY num_of_thefts DESC;

-- > March, 2022 recorded the highest number of vehicle thefts (1046), contributing 36.57% of the year's total incidents.
-- > However, interpretation for April is limited due to data availability for only four days.

# On which date, the maximum number of theft happened?
SELECT date_stolen, COUNT(vehicle_id) AS num_of_thefts FROM cleaned_stolen_vehicles
GROUP BY date_stolen
ORDER BY num_of_thefts DESC
LIMIT 1;

-- > The highest number of thefts was recorded on April 4th, 2022, with a total of 81 incidents.

# What is the monthly trend of vehicle thefts?
SELECT YEAR(date_stolen) AS year_stolen, MONTH(date_stolen) AS month_stolen, COUNT(vehicle_id) AS num_of_thefts
FROM cleaned_stolen_vehicles
GROUP BY year_stolen, month_stolen
ORDER BY year_stolen, month_stolen;

-- > From the table, it was observed that the number of theft increasing each month and following an upward trend.
-- > However, interpretation for April is limited due to data availability for only four days.

# Out of the highest theft of vehicle type, what are the top 5 most frequently stolen vehicle descriptions?
SELECT vehicle_desc, COUNT(vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles
WHERE vehicle_type = "Stationwagon"
GROUP BY vehicle_desc
ORDER BY num_of_theft DESC
LIMIT 5;

# Which vehicle colors are most frequently targeted for theft?
SELECT color, COUNT(vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles
GROUP BY color
ORDER BY num_of_theft DESC
LIMIT 1;

-- > "Silver" color vehicles are most frequently targeted for theft.

# What is the average model year of stolen vehicles by type?
SELECT vehicle_type, ROUND(AVG(model_year),0) AS average_year
FROM cleaned_stolen_vehicles
GROUP BY vehicle_type
ORDER BY vehicle_type;

# Which location has the highest number of stolen vehicles?
SELECT csv.location_id, l.region, COUNT(csv.vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles csv
LEFT JOIN locations l ON csv.location_id = l.location_id
GROUP BY csv.location_id, l.region
ORDER BY num_of_theft DESC
LIMIT 1;

-- > 'Auckland' recorded the highest number of thefts, totaling 1,620 thefts.

# Which location has the lowest number of stolen vehicles?
SELECT csv.location_id, l.region, COUNT(csv.vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles csv
LEFT JOIN locations l ON csv.location_id = l.location_id
GROUP BY csv.location_id, l.region
ORDER BY num_of_theft
LIMIT 1;

-- > 'Southland' recorded the lowest number of thefts, totaling 26 thefts.

# In which year, Auckland recorded the highest theft?
SELECT YEAR(v.date_stolen) AS year_of_theft, COUNT(v.vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles v
LEFT JOIN locations l ON v.location_id = l.location_id
WHERE l.region = "Auckland"
GROUP BY year_of_theft
ORDER BY num_of_theft DESC;

-- > In 2022, Auckland recorded the highest number of thefts, totaling to 1108.

# Which vehicle type most likely to be stolen at each region?
WITH vehicle_theft_counts AS (
    SELECT 
        l.region,
        sv.vehicle_type,
        COUNT(*) AS theft_count,
        ROW_NUMBER() OVER (PARTITION BY l.region ORDER BY COUNT(*) DESC) AS rn
    FROM cleaned_stolen_vehicles sv
    LEFT JOIN locations l ON sv.location_id = l.location_id
    GROUP BY l.region, sv.vehicle_type
)
SELECT region, vehicle_type, theft_count
FROM vehicle_theft_counts
WHERE rn = 1
ORDER BY theft_count DESC;

# How does theft frequency correlate with population or density?
SELECT l.region, l.population, COUNT(sv.vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles sv
LEFT JOIN locations l ON sv.location_id = l.location_id
GROUP BY l.region, l.population
ORDER BY l.population;

# Which country or countries the theft details are recorded?
SELECT DISTINCT country FROM locations;
 -- > The vehicle theft data has been recorded solely from New Zealand.
 
 # Which regions of New Zealand the thefts occurs?
 SELECT DISTINCT l.region FROM cleaned_stolen_vehicles v
 LEFT JOIN locations l ON v.location_id = l.location_id
 ORDER BY l.region;
 
 -- > The thefts are recorded from 13 regions of New Zealand.

# Which vehicle maker is most frequently associated with thefts?
SELECT m.make_name, COUNT(v.vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles v
LEFT JOIN make_details m ON v.make_id = m.make_id
GROUP BY m.make_name
ORDER BY num_of_theft DESC
LIMIT 1;

-- > Toyota vehicle maker is most frequently associated with thefts, totalling to 716 incidents.

# Toyota's which vehicle type are most frequently associated with thefts?
SELECT v.vehicle_type, COUNT(v.vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles v
LEFT JOIN make_details m ON v.make_id = m.make_id
WHERE m.make_name = "Toyota"
GROUP BY v.vehicle_type
ORDER BY num_of_theft DESC;

-- > Toyota's Stationwagons, Hatchback, and Saloon are at a higher risk of stolen.

# How many categories of vehicles are there and Toyota falls in which category?
SELECT DISTINCT m.make_type FROM cleaned_stolen_vehicles v
LEFT JOIN make_details m ON v.make_id = m.make_id;

SELECT DISTINCT m.make_type FROM cleaned_stolen_vehicles v
LEFT JOIN make_details m ON v.make_id = m.make_id
WHERE m.make_name = "Toyota";

-- > There are 2 categories of vehicle - Standard and Luxury, where Toyota falls in Standard category.

# What are the top make_type categories by number of thefts?
SELECT m.make_type, COUNT(v.vehicle_id) AS num_of_theft, ROUND((COUNT(v.vehicle_id) / @total_thefts) * 100,0) AS theft_ratio
FROM cleaned_stolen_vehicles v
LEFT JOIN make_details m ON v.make_id = m.make_id
GROUP BY m.make_type
ORDER BY num_of_theft DESC;

-- > 96% of Standard category of vehicles are at high risk of getting stolen.

# How many vehicle brands are there in "Standard" Category?
SELECT COUNT(DISTINCT m.make_name) AS standard_count FROM cleaned_stolen_vehicles v
LEFT JOIN make_details m ON v.make_id = m.make_id
WHERE m.make_type = "Standard";

# Which vehicle brands are most frequently associated with thefts by each region?
WITH combined_theft_df AS (
	SELECT 
		l.region,
        m.make_name,
        COUNT(v.vehicle_id) AS num_of_theft,
        ROW_NUMBER() OVER (PARTITION BY l.region ORDER BY COUNT(v.vehicle_id) DESC) AS part_1
    FROM cleaned_stolen_vehicles v
	LEFT JOIN locations l ON v.location_id = l.location_id
	LEFT JOIN make_details m ON v.make_id = m.make_id
    GROUP BY l.region, m.make_name
)
SELECT
region,
make_name,
num_of_theft
FROM combined_theft_df
WHERE part_1 = 1;

# How many regions are there where Toyota brand is stolen the most?
WITH combined_theft_df AS (
	SELECT 
		l.region,
        m.make_name,
        COUNT(v.vehicle_id) AS num_of_theft,
        ROW_NUMBER() OVER (PARTITION BY l.region ORDER BY COUNT(v.vehicle_id) DESC) AS part_1
    FROM cleaned_stolen_vehicles v
	LEFT JOIN locations l ON v.location_id = l.location_id
	LEFT JOIN make_details m ON v.make_id = m.make_id
    GROUP BY l.region, m.make_name
)
SELECT region, make_name, num_of_theft
FROM combined_theft_df
WHERE part_1 = 1 AND make_name = "Toyota"
ORDER BY num_of_theft DESC;

-- > The regions where Toyota is stolen the most are from Auckland, Canterbury, Bay of Plenty, Northland, and Otago.

# Does weekday observed highest volume in theft or weekend?
SELECT
	CASE
		WHEN DAYNAME(date_stolen) IN ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday") THEN "Weekday"
		ELSE "Weekend"
	END AS day_type,
    COUNT(vehicle_id) AS num_of_theft,
    ROUND((COUNT(vehicle_id) / @total_thefts)*100,0) AS theft_ratio
FROM cleaned_stolen_vehicles
GROUP BY day_type
ORDER BY num_of_theft DESC;

# What day of the week are vehicles most often and least often stolen?
SELECT DAYOFWEEK(date_stolen) AS day_of_week, DAYNAME(date_stolen) AS days,COUNT(vehicle_id) AS least_num_of_theft
FROM cleaned_stolen_vehicles
GROUP BY day_of_week, days
ORDER BY least_num_of_theft
LIMIT 1;

SELECT DAYOFWEEK(date_stolen) AS day_of_week, DAYNAME(date_stolen) AS days,COUNT(vehicle_id) AS most_num_of_theft
FROM cleaned_stolen_vehicles
GROUP BY day_of_week, days
ORDER BY most_num_of_theft DESC;

-- > 'Monday' where the number of thefts are high at 759 while 'Saturday' recorded as lowest at 574.

# What types of vehicles are most often and least often stolen? Does this vary by region?
-- Least often stolen by region
WITH vehicle_theft_counts AS (
    SELECT 
        l.region,
        sv.vehicle_type,
        COUNT(*) AS theft_count,
        ROW_NUMBER() OVER (PARTITION BY l.region ORDER BY COUNT(*)) AS least
    FROM cleaned_stolen_vehicles sv
    LEFT JOIN locations l ON sv.location_id = l.location_id
    GROUP BY l.region, sv.vehicle_type
)
SELECT region, vehicle_type, theft_count
FROM vehicle_theft_counts
WHERE least = 1
ORDER BY theft_count;

-- Most often stolen by region
WITH vehicle_theft_counts AS (
    SELECT 
        l.region,
        sv.vehicle_type,
        COUNT(*) AS theft_count,
        ROW_NUMBER() OVER (PARTITION BY l.region ORDER BY COUNT(*) DESC) AS most
    FROM cleaned_stolen_vehicles sv
    LEFT JOIN locations l ON sv.location_id = l.location_id
    GROUP BY l.region, sv.vehicle_type
)
SELECT region, vehicle_type, theft_count
FROM vehicle_theft_counts
WHERE most = 1
ORDER BY theft_count DESC;

# What is the average age of the vehicles that are stolen? Does this vary based on the vehicle type?
SELECT ROUND(AVG(YEAR(date_stolen) - model_year),0) AS avg_age FROM cleaned_stolen_vehicles;

-- > The average age of the vehicles that are stolen is 16 years.

SELECT vehicle_type, ROUND(AVG(YEAR(date_stolen) - model_year),0) AS avg_age, COUNT(vehicle_id) AS num_of_theft
FROM cleaned_stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_of_theft DESC;