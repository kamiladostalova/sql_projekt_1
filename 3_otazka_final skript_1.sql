--- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- 1. varianta - statistická metoda - průměr z průměrů


WITH data AS (
    SELECT
		CAST(value AS DECIMAL(10, 2)) AS value
    	,code
	    ,name
    	,year
	    ,type_code
	FROM t_kamila_dostalova_project_sql_primary_final
	WHERE type_code = 'price'
),
price_diff AS (
    SELECT
        name
        ,year
        ,value AS value_current_year
        ,LAG(value, 1) OVER (PARTITION BY name ORDER BY year) AS value_previous_year
        ,value - LAG(value, 1) OVER (PARTITION BY name ORDER BY year) AS value_difference
        ,ROUND(((value - LAG(value, 1) OVER (PARTITION BY name ORDER BY year)) / LAG(value, 1) OVER (PARTITION BY name ORDER BY year)) * 100, 2) AS value_difference_percent
	FROM data
),
avg_price_diff AS (
    SELECT
        name
        ,AVG(value_difference_percent) AS avg_value_difference_percent
    FROM price_diff
    WHERE value_previous_year IS NOT NULL
    GROUP BY name
)
SELECT
    name
    ,ROUND(avg_value_difference_percent, 2) AS avg_value_difference_percent
FROM avg_price_diff
ORDER BY avg_value_difference_percent;

