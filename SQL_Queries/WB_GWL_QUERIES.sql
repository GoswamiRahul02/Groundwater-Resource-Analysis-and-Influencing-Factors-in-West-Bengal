CREATE DATABASE IF NOT EXISTS WB_Groundwater_level;

USE WB_Groundwater_level;

SHOW tables;

SELECT * FROM wb_groundwater_level.wb_groundwater;


select district, meandepth, season,
rank() over (partition by season
order by meandepth desc) as rankno
from wb_groundwater;


Select district,season, round(avg(meandepth),2)as avg_meandepth
from wb_groundwater
where season = "Pre-monsoon"
group by district, season
order by avg_meandepth desc
;


-- HAVING is mainly for filtering aggregated results,
-- like HAVING AVG(meandepth) > 10
SELECT
  district,
  season,
  ROUND(AVG(meandepth), 2) AS avg_meandepth
FROM wb_groundwater
where season = 'Post-monsoon'
GROUP BY district, season
having avg_meandepth > 10
ORDER BY avg_meandepth DESC;


-- Query 2 — District-Level Average Depth Profile
-- Rank all 23 districts by their overall average groundwater depth
-- Highest rank = most water-stressed district over the full 21-year period
SELECT
    District,
    ROUND(AVG(MeanDepth), 2)                    AS avg_depth,
    ROUND(AVG(CASE WHEN Season = 'Pre-Monsoon'  THEN MeanDepth END), 2) AS avg_pre_monsoon_depth,
    ROUND(AVG(CASE WHEN Season = 'Post-Monsoon' THEN MeanDepth END), 2) AS avg_post_monsoon_depth,
    ROUND(MAX(MeanDepth), 2)                    AS worst_depth_ever,
    ROUND(MIN(MeanDepth), 2)                    AS best_depth_ever,
    RANK() OVER (ORDER BY AVG(MeanDepth) DESC)  AS stress_rank
FROM wb_groundwater
GROUP BY District
ORDER BY avg_depth DESC;


SELECT
	District,
    ROUND(AVG(meandepth),3) AS avg_meandepth,
    ROUND(AVG(CASE WHEN season = 'Pre-monsoon' THEN meandepth END),3) AS avg_premonsoon_depth,
    ROUND(AVG(CASE WHEN season = 'Post-monsoon' THEN meandepth END),3) AS avg_postmonsoon_depth,
    ROUND(MAX(meandepth),3) AS worst_meandepth,
    ROUND(Min(meandepth),3) AS best_meandepth,
    RANK() OVER (ORDER BY AVG(meandepth) DESC)
    AS RankNO
    FROM wb_groundwater
    GROUP BY District; 
    
 
-- Decade Wise Comparison
    -- Split the 21-year period into two decades and compare
SELECT
    District,
    Season,
    ROUND(AVG(CASE WHEN Year BETWEEN 2000 AND 2009 THEN MeanDepth END), 2) AS depth_2000s,
    ROUND(AVG(CASE WHEN Year BETWEEN 2010 AND 2020 THEN MeanDepth END), 2) AS depth_2010s,
    ROUND(AVG(CASE WHEN Year BETWEEN 2010 AND 2020 THEN MeanDepth END) -
          AVG(CASE WHEN Year BETWEEN 2000 AND 2009 THEN MeanDepth END), 2)  AS decade_change
FROM wb_groundwater
GROUP BY District, Season
ORDER BY District, Season;
    
    

 -- For Post-Monsoon season: does more rainfall mean shallower depth?
-- A strong negative relationship (high rain = low depth) means healthy recharge response
SELECT
    District,
    ROUND(AVG(Rainfall), 1)                                 AS avg_post_rainfall,
    ROUND(AVG(MeanDepth), 2)                                AS avg_post_depth,
    -- Classify districts by their rainfall-depth relationship
    CASE
        WHEN AVG(Rainfall) > 1500 AND AVG(MeanDepth) < 5   THEN 'High Rain, Shallow (Healthy)'
        WHEN AVG(Rainfall) > 1500 AND AVG(MeanDepth) >= 5  THEN 'High Rain, Still Deep (Over-extracted)'
        WHEN AVG(Rainfall) < 1000 AND AVG(MeanDepth) >= 8  THEN 'Low Rain, Deep (High Stress)'
        WHEN AVG(Rainfall) < 1000 AND AVG(MeanDepth) < 8   THEN 'Low Rain, Managed (Moderate)'
        ELSE 'Moderate'
    END                                                     AS rainfall_depth_category
FROM wb_groundwater
WHERE Season = 'Post-Monsoon'
GROUP BY District
ORDER BY avg_post_rainfall DESC;   
    
    
    
    
    