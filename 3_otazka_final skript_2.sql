--- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
--- 2. varianta - statistická metoda - medián

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
ranked_price_diff AS (
    SELECT
        name
        ,value_difference_percent
        ,ROW_NUMBER() OVER (PARTITION BY name ORDER BY value_difference_percent) AS row_num
        ,Count(*) OVER (PARTITION BY name) AS total_rows
    FROM price_diff
    WHERE value_previous_year IS NOT NULL
),
median_price_diff AS (
    SELECT
        name
        ,AVG(value_difference_percent) AS median_value_difference_percent
    FROM ranked_price_diff
    WHERE row_num IN (FLOOR((total_rows + 1) / 2)
    ,CEIL((total_rows + 1) / 2))
    GROUP BY name
)
SELECT
    name
    ,ROUND(median_value_difference_percent,2) AS median_value_difference_percent
FROM median_price_diff
ORDER BY median_value_difference_percent;