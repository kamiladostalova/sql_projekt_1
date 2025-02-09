--- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10%)?

SELECT *
FROM t_kamila_dostalova_project_sql_primary_final; 


--- 1. část - analýza mzdy
--- výběr potřebných dat

SELECT 
	`year` 
	,value
FROM t_kamila_dostalova_project_sql_primary_final 
WHERE type_code = 'payroll' AND code IS NULL;

--- propočet meziročního rozdílu v %

SELECT
     `year`
     ,`value` AS value_current_year
     ,LAG(`value`, 1) OVER (ORDER BY `year`) AS value_previous_year
     ,`value` - LAG(`value`, 1) OVER (ORDER BY `year`) AS value_difference
     ,ROUND(((`value` - LAG(`value`, 1) OVER (ORDER BY `year`)) / LAG(`value`, 1) OVER (ORDER BY `year`)) * 100, 2) AS value_difference_percent
FROM t_kamila_dostalova_project_sql_primary_final
WHERE type_code = 'payroll' AND code IS NULL;

--- 1. část FINAL

WITH data AS (
    SELECT 
        `year` 
        ,`value`
    FROM t_kamila_dostalova_project_sql_primary_final 
    WHERE type_code = 'payroll' AND code IS NULL
),
payroll_diff AS (
    SELECT
        `year`
        ,`value` AS payroll_current_year
        ,LAG(`value`, 1) OVER (ORDER BY `year`) AS payroll_previous_year
        ,`value` - LAG(`value`, 1) OVER (ORDER BY `year`) AS payroll_difference
        ,ROUND(((`value` - LAG(`value`, 1) OVER (ORDER BY `year`)) / LAG(`value`, 1) OVER (ORDER BY `year`)) * 100, 2) AS payroll_difference_percent
    FROM data
)
SELECT
    `year`
	,payroll_current_year
    ,payroll_difference_percent
FROM payroll_diff
ORDER BY `year`;
	
--- 2. část - analýza potraviny
--- výběr potřebných dat

SELECT
	`year` 
	,ROUND(AVG(value), 2) AS value
FROM t_kamila_dostalova_project_sql_primary_final 
WHERE type_code = 'price'
GROUP BY year;

--- propočet meziročního rozdílu v %

SELECT
	`year`
    ,`value` AS price_current_year
    ,LAG(`value`, 1) OVER (ORDER BY `year`) AS price_previous_year
    ,`value` - LAG(`value`, 1) OVER (ORDER BY `year`) AS price_difference
    ,ROUND(((`value` - LAG(`value`, 1) OVER (ORDER BY `year`)) / LAG(`value`, 1) OVER (ORDER BY `year`)) * 100, 2) AS price_difference_percent
FROM t_kamila_dostalova_project_sql_primary_final
WHERE type_code = 'price' 
GROUP BY year;

--- 2. část FINAL

WITH data AS (
    SELECT
		`year` 
		,ROUND(AVG(value), 2) AS value
	FROM t_kamila_dostalova_project_sql_primary_final 
	WHERE type_code = 'price'
	GROUP BY year
),
price_diff AS (
    SELECT
        `year`
        ,`value` AS price_current_year
        ,LAG(`value`, 1) OVER (ORDER BY `year`) AS price_previous_year
        ,`value` - LAG(`value`, 1) OVER (ORDER BY `year`) AS price_difference
        ,ROUND(((`value` - LAG(`value`, 1) OVER (ORDER BY `year`)) / LAG(`value`, 1) OVER (ORDER BY `year`)) * 100, 2) AS price_difference_percent
    FROM data
)
SELECT
    `year`
	,price_current_year
    ,price_difference_percent
FROM price_diff
ORDER BY `year`;


--- 3. část spojení (1. a 2. část)

WITH payroll_data AS (
    SELECT
        `year`
        ,`value`
    FROM t_kamila_dostalova_project_sql_primary_final
    WHERE type_code = 'payroll' AND code IS NULL
),
payroll_diff AS (
    SELECT
        `year`
        ,`value` AS payroll_current_year
        ,LAG(`value`, 1) OVER (ORDER BY `year`) AS payroll_previous_year
        ,`value` - LAG(`value`, 1) OVER (ORDER BY `year`) AS payroll_difference
        ,ROUND(((`value` - LAG(`value`, 1) OVER (ORDER BY `year`)) / LAG(`value`, 1) OVER (ORDER BY `year`)) * 100, 2) AS payroll_difference_percent
    FROM payroll_data
),
price_data AS (
    SELECT
        `year`
        ,ROUND(AVG(value), 2) AS value
    FROM t_kamila_dostalova_project_sql_primary_final
    WHERE type_code = 'price'
    GROUP BY `year`
),
price_diff AS (
    SELECT
        `year`
        ,`value` AS price_current_year
        ,LAG(`value`, 1) OVER (ORDER BY `year`) AS price_previous_year
        ,`value` - LAG(`value`, 1) OVER (ORDER BY `year`) AS price_difference
        ,ROUND(((`value` - LAG(`value`, 1) OVER (ORDER BY `year`)) / LAG(`value`, 1) OVER (ORDER BY `year`)) * 100, 2) AS price_difference_percent
    FROM price_data
),
final_table AS (
    SELECT
        pr.`year`
        ,pr.payroll_difference_percent
        ,p.price_difference_percent
        ,ABS(p.price_difference_percent - pr.payroll_difference_percent) AS difference_between_percent
    FROM payroll_diff pr
    JOIN price_diff p ON pr.`year` = p.`year`
)
SELECT
    `year`
    ,difference_between_percent
FROM final_table
WHERE difference_between_percent >5
ORDER BY `year`;