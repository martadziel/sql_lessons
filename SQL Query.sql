CREATE TABLE video_game_sales (
    rank integer NOT NULL UNIQUE,
    name text,
    platform text,
    year integer,
    genre text,
    publisher text,
    na_sales double precision,
    eu_sales double precision,
    jp_sales double precision,
    other_sales double precision
);


CREATE UNIQUE INDEX video_game_sales_rank_key ON video_game_sales(rank int4_ops);


-- max japan, gropu by platform, max no of sales > 4

SELECT platform, MAX (jp_sales)
FROM video_game_sales
WHERE jp_sales > 4
GROUP BY platform

SELECT MAX (jp_sales), platform
FROM video_game_sales 
GROUP BY platform
HAVING MAX (jp_sales) > 4

-- top 5% of video game sales ordered by jp_sales, year = 2006, get name, year, jp_sales, cum distribution value in top 5%


CREATE VIEW cume_dist_view AS 
	SELECT 
		jp_sales
		,CUME_DIST() OVER (ORDER BY jp_sales) AS cume_dist
		, year
		, name
	FROM video_game_sales

SELECT 
	jp_sales
	,cume_dist
	, year
	, name
FROM cume_dist_view
WHERE year = 2006 AND cume_dist > 0.95
ORDER BY cume_dist DESC

-- ranking
-- rank total sales, get name of video game, rank number, -> 2 steps, create view; use rank function, which is also view function (over and order by)
-- be careful with platforms - same name but different platform
-- we want to give the rank number; lets ignore the "rank" column in the table


CREATE VIEW Totals AS
	SELECT (na_sales + eu_sales + jp_sales + other_sales) AS Total_sales, name, platform
	FROM video_game_sales

SELECT 
	Total_sales
	, RANK() OVER (ORDER BY Total_sales DESC) AS ranking
	, name
	, platform
FROM Totals 

-- dense_rank() 31, 31, 33 -> 31, 31, 32 or 


-- average, difference

-- name, ppublisher

-- all avg sales na_sales, eu_sales, j_sales, 
-- game name, console, year, avg sales on console

DROP VIEW IF EXISTS EXERCISE_1

CREATE VIEW EXERCISE_1 AS
	SELECT NAME
		, YEAR
		, PLATFORM
		, AVG(NA_SALES) OVER(PARTITION BY PLATFORM, YEAR) AS AVG_NA_SALES
		, NA_SALES
	FROM VIDEO_GAME_SALES
	
SELECT *
		, (NA_SALES - AVG_NA_SALES) AS DIFFERENCE
FROM EXERCISE_1	
ORDER BY DIFFERENCE DESC

SELECT 
	YEAR
	, PLATFORM
	, AVG_NA_SALES
	, NA_SALES
	, (NA_SALES - AVG_NA_SALES) AS DIFFERENCE
FROM EXERCISE_1


-- LAG / LEAD

CREATE TABLE REVENUES (
    DATETIME TIMESTAMP NOT NULL UNIQUE,
    ENTITY INTEGER,
    REVENUE DOUBLE PRECISION
);

INSERT INTO REVENUES (DATETIME, ENTITY, REVENUE)
VALUES
	('2023-03-01 12:00:00', 001, 100)
	,('2023-04-01 12:00:00', 001, 120)
	,('2023-05-01 12:00:00', 001, 150)

SELECT *
FROM REVENUES

SELECT DATETIME
	, REVENUE
	, LAG(REVENUE) OVER (ORDER BY DATETIME) AS REVENUE_0
FROM REVENUES

SELECT DATETIME
	, REVENUE
	, LAG(REVENUE, 2) OVER (ORDER BY DATETIME) AS REVENUE_0
	, LEAD(REVENUE, 2) OVER (ORDER BY DATETIME) AS REVENUE_2
FROM REVENUES

