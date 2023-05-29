-- In Spreadsheet
-- create a column called “ride_length.” Calculate the length of each ride by subtracting the
-- column “started_at” from the column “ended_at” (for example, =D2-C2) and format as HH:MM:SS using Format > Cells >
-- Time > 37:30:55.

-- Create a column called “day_of_week,” and calculate the day of the week that each ride started using the “WEEKDAY”
-- command (for example, =WEEKDAY(C2,1)) in each file. Format as General or as a number with no decimals, noting that
-- 1 = Sunday and 7 = Saturday

CREATE TABLE tripdata_full AS
SELECT 
        ride_id, 
        rideable_type, 
        started_at, 
        ended_at, 
	    ride_length,
        day_of_week,
	    start_station_name, 
	    start_station_id, 
        end_station_name, 
	    end_station_id, 
        start_lat, 
        start_lng, 
	    end_lat, 
        end_lng, 
        member_casual
FROM
		202201_tripdata
UNION ALL
SELECT 
        ride_id, 
        rideable_type, 
        started_at, 
        ended_at, 
	    ride_length,
        day_of_week,
	    start_station_name, 
	    start_station_id, 
        end_station_name, 
	    end_station_id, 
        start_lat, 
        start_lng, 
	    end_lat, 
        end_lng, 
        member_casual
FROM
		202202_tripdata;

-- Analyze: Calculate TOTAL TRIP
SELECT
    '2022_01' AS Month,
    TotalTrips,
    TotalMemberTrips,
    TotalCasualTrips,
    ROUND((TotalMemberTrips/TotalTrips)*100, 2) AS MemberPercentage,
    ROUND((TotalCasualTrips/TotalTrips)*100, 2) AS CasualPercentage
FROM
    (
    SELECT
        COUNT(ride_id) AS TotalTrips,
        COUNT(IF(member_casual = 'member', 1, NULL)) AS TotalMemberTrips,
        COUNT(IF(member_casual = 'casual', 1, NULL)) AS TotalCasualTrips
    FROM
        `202201_tripdata`
    ) AS subquery
UNION ALL
SELECT
    '2022_02' AS Month,
    TotalTrips,
    TotalMemberTrips,
    TotalCasualTrips,
    ROUND((TotalMemberTrips/TotalTrips)*100, 2) AS MemberPercentage,
    ROUND((TotalCasualTrips/TotalTrips)*100, 2) AS CasualPercentage
FROM
    (
    SELECT
        COUNT(ride_id) AS TotalTrips,
        COUNT(IF(member_casual = 'member', 1, NULL)) AS TotalMemberTrips,
        COUNT(IF(member_casual = 'casual', 1, NULL)) AS TotalCasualTrips
    FROM
        `202202_tripdata`
    ) AS subquery;

-- Analysis: Calculate Min, Max, Average
SELECT
	member_casual,
    SEC_TO_TIME(MIN(TIME_TO_SEC(STR_TO_DATE(ride_length, '%H:%i:%s')))) AS min_ride_length,
    SEC_TO_TIME(MAX(TIME_TO_SEC(STR_TO_DATE(ride_length, '%H:%i:%s')))) AS max_ride_length,
    SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(STR_TO_DATE(ride_length, '%H:%i:%s'))))) AS avg_ride_length
FROM tripdata_full
GROUP BY member_casual;

-- Analysis: Total Trips Per Day
SELECT 
    CASE 
        WHEN day_of_week = 1 THEN "Sunday"
        WHEN day_of_week = 2 THEN "Monday"
        WHEN day_of_week = 3 THEN "Tuesday"
        WHEN day_of_week = 4 THEN "Wednesday"
        WHEN day_of_week = 5 THEN "Thursday"
        WHEN day_of_week = 6 THEN "Friday"
        ELSE "Saturday" 
    END AS day_of_week, 
    COUNT(day_of_week) AS TotalTrips,
    SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS MemberTrips,
    SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS CasualTrips
FROM `tripdata_full` 
GROUP BY day_of_week
ORDER BY TotalTrips DESC;

-- Analysis: Top 5 Start Time of riders
WITH TIME AS (
  SELECT
    member_casual,
    DATE_FORMAT(STR_TO_DATE(started_at, '%m/%d/%Y %H:%i'), '%H') AS Start_time
  FROM
    `tripdata_full`
)
SELECT
  Start_time AS Member_start,
  COUNT(Start_time) AS Total_start_time,
  SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS MemberTrips,
  SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS CasualTrips
FROM
  TIME
GROUP BY
  Start_time
ORDER BY
  Total_start_time DESC
LIMIT
  5;
-- 1. Member
WITH TIME AS (
  SELECT
    member_casual,
    DATE_FORMAT(STR_TO_DATE(started_at, '%m/%d/%Y %H:%i'), '%H') AS Start_time
  FROM
    `tripdata_full`
)
SELECT
  Start_time AS member_start,
  COUNT(Start_time) AS count_start_time
FROM
  TIME
WHERE
  member_casual = 'member'
GROUP BY
  Start_time
ORDER BY
  count_start_time DESC
LIMIT
  5;
-- 2. Casual
WITH TIME AS (
  SELECT
    member_casual,
    DATE_FORMAT(STR_TO_DATE(started_at, '%m/%d/%Y %H:%i'), '%H') AS Start_time
  FROM
    `tripdata_full`
)
SELECT
  Start_time AS member_start,
  COUNT(Start_time) AS count_start_time
FROM
  TIME
WHERE
  member_casual = 'member'
GROUP BY
  Start_time
ORDER BY
  count_start_time DESC
LIMIT
  5;

-- Analysis: Most Rideable Bike Type
SELECT member_casual, rideable_type, COUNT(*) AS count
FROM `tripdata_full`
WHERE rideable_type IN ('electric_bike', 'docked_bike', 'classic_bike')
GROUP BY member_casual, rideable_type
ORDER BY count DESC; 

-- Analysis: Most Station Start
SELECT 
    start_station_name,
    COUNT(DISTINCT ride_id) AS total,
    SUM(CASE WHEN member_casual = 'member' THEN 1 ELSE 0 END) AS member,
    SUM(CASE WHEN member_casual = 'casual' THEN 1 ELSE 0 END) AS casual
FROM 
    `tripdata_full`
GROUP BY 
    start_station_name
ORDER BY 
    total DESC
LIMIT 10;

