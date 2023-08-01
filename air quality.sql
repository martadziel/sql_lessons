/* Trying to upload table into postico */
DROP TABLE IF EXISTS air_quality

CREATE TABLE air_quality (
    Date STRING,
    TIME STrING,
    CO_GT double precision,
    PT08_S1_CO integer,
    NMHC_GT integer,
    C6H6_GT integer,
    PT08_S2_NMHC integer,
    NOX_GT integer,
    PT08_S3_NOx integer,
    NO2_GT integer,
    PT08_S4_NO2 integer,
    PT08_S5_O3 double precision,
    T double precision,
    RH double precision,
    AH double precision
);	

SELECT
format (date, 'YYYY-MM-DD') as date
FROM AIR_QUALITY

SELECT SUBSTRING(DATE, 7,4) AS YEAR, SUBSTRING(DATE,4,2) AS MONTH,  SUBSTRING(DATE,1,2) AS DAY
, (SUBSTRING(DATE, 7,4) + SUBSTRING(DATE,4,2) +  SUBSTRING(DATE,1,2))
FROM AIR_QUALITY

CREATE VIEW air_quality_clean AS
	SELECT
		TO_TIMESTAMP(
			TIME /*THIS IS THE NAME OF THE COLUMN */, 'HH24.MM.SS' /* , YOU CAN SPECIFY TIME ZONE*/
			) + INTERVAL '2004 YEAR' + INTERVAL '2 MONTHS' + INTERVAL '9 DAY' AS DATETIME
		, TO_DATE(DATE, 'DD/MM/YYYY') AS DATE_1
		/* , RESZTA KOLUMN*/
		, *
FROM air_quality;

-- Question 1: Calculate daily and monthly averages for temperature and absolute humidity

SELECT 
	
	AVG(AIR_QUALITY_CLEAN.T) AS T_AVG
	, AVG(AIR_QUALITY_CLEAN.AH) AS T_AVG
	, EXTRACT(MONTH YEAR FROM DATE_1) AS MONTH /* EXTRACT AS ANOTHER COLUMN THE YEAR AND LATER ON GROUP BY BOTH COLUMNS*/
FROM AIR_QUALITY_CLEAN
GROUP BY MONTH

/* LAG / LEAD FOR ROLLING AVG*/

--Question 2: If I lived in Beijing for the first half of 2004, how much Benzene have I been exposed to (on average)?

SELECT
SUM(C6H6_GT) AS BENZ_SUM
FROM AIR_QUALITY_CLEAN
WHERE datetime >= '2004-01-01 00:00:00' AND datetime < '2004-07-01 00:00:00';

-- Q3: Which day(s) had the highest average tungsten oxide recorded?
-- M: Was not sure if I should add results of those columns together; kept all visible and calculated result on the sum of those
SELECT
	DATE_1
	, MAX(PT08_S3_NOx) AS PTO_S3_MAX
	, MAX(PT08_S4_NO2) AS PTO_S4_MAX
	, (MAX(PT08_S4_NO2 + PT08_S3_NOx)) AS MAX_TOTAL
FROM AIR_QUALITY_CLEAN
GROUP BY DATE_1
ORDER BY MAX_TOTAL DESC

-- Q4: What was the greatest delta (difference) between any two hours in temperature? When did this happen? Hint: Maybe lead or lag is useful here. How would your calculation change if I wanted to know the sharpest change in e.g., 3-hour periods, 6-hour... ?

CREATE VIEW EX_4 AS
SELECT
	  DATETIME
	, T
	, LAG(T/*, 2*/) OVER (ORDER BY DATETIME) AS T_PREVIOUS
	/*, LAG(T, 5) OVER (ORDER BY DATETIME) AS T_6MTHS */
FROM AIR_QUALITY_CLEAN

SELECT *
	, (T - T_PREVIOUS) AS DIFF
FROM EX_4
ORDER BY DIFF DESC

--Q5: Rank the hottest and coldest (averaged out) days, what were the three hottest and coldest? Were there any ties?
--M: TWO QUERIES; ONE WITH VIEWS, ANOTHER WITH CTE

/* LAST ONE: use of lag, arythmetic, order byinside window function part. no 3 should be easy */
DROP VIEW IF EXISTS EX_5

CREATE VIEW EX_5 AS
SELECT
	DATE_1
	, AVG(T) AS AVG_TEMP
	, RANK() OVER (ORDER BY AVG(T) DESC) AS RANK_HOT
	, DENSE_RANK() OVER (ORDER BY AVG(T) DESC) AS UNIQUE_RANK_HOT
	, RANK() OVER (ORDER BY AVG(T) ASC) AS RANK_COLD
	, DENSE_RANK() OVER (ORDER BY AVG(T) ASC) AS UNIQUE_RANK_COLD
FROM AIR_QUALITY_CLEAN
GROUP BY DATE_1

DROP VIEW IF EXISTS EX_6

CREATE VIEW EX_6 AS
SELECT 
	DATE_1
	, AVG_TEMP
	, RANK_HOT
	, RANK_COLD
	, CASE
		WHEN RANK_HOT IN (1,2,3) THEN 1 
		ELSE 0
		END AS TOP_HOT
	, CASE
		WHEN RANK_COLD IN (1,2,3) THEN 1 
		ELSE 0
		END AS TOP_COLD
	, CASE
		WHEN RANK_HOT = RANK_COLD THEN 1
		ELSE 0
		END AS EQUALS
FROM EX_5

SELECT
	DATE_1
	, AVG_TEMP
	, RANK_HOT
	, RANK_COLD
	, TOP_HOT
	, TOP_COLD
	, EQUALS
FROM EX_6
WHERE TOP_HOT = 1 OR TOP_COLD = 1 OR EQUALS = 1

-- ALTERNATIVE QUERY USING CTE

WITH CTE_1 AS (
	SELECT
	DATE_1
	, AVG(T) AS AVG_TEMP
	, RANK() OVER (ORDER BY AVG(T) DESC) AS RANK_HOT
	, DENSE_RANK() OVER (ORDER BY AVG(T) DESC) AS UNIQUE_RANK_HOT
	, RANK() OVER (ORDER BY AVG(T) ASC) AS RANK_COLD
	, DENSE_RANK() OVER (ORDER BY AVG(T) ASC) AS UNIQUE_RANK_COLD
FROM AIR_QUALITY_CLEAN
GROUP BY DATE_1),

	CTE_2 AS (
	SELECT 
	DATE_1
	, AVG_TEMP
	, RANK_HOT
	, RANK_COLD
	, CASE
		WHEN RANK_HOT IN (1,2,3) THEN 1 
		ELSE 0
		END AS TOP_HOT
	, CASE
		WHEN RANK_COLD IN (1,2,3) THEN 1 
		ELSE 0
		END AS TOP_COLD
	, CASE
		WHEN RANK_HOT = RANK_COLD THEN 1
		ELSE 0
		END AS EQUALS
FROM EX_5)

SELECT
	DATE_1
	, AVG_TEMP
	, RANK_HOT
	, RANK_COLD
	, TOP_HOT
	, TOP_COLD
	, EQUALS
FROM EX_6
WHERE TOP_HOT = 1 OR TOP_COLD = 1 OR EQUALS = 1
