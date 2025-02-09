--- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji 
--- v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH GDP_data AS (
SELECT 
	REPLACE(`year`, ',', '') AS `year`
	,GDP 
FROM t_kamila_dostalova_project_sql_secondary_final
WHERE country = 'Czech republic'
),
GDP_diff AS (
	SELECT
        REPLACE(`year`, ',', '') AS `year`
        ,`GDP` AS GDP_current_year
        ,LAG(`GDP`, 1) OVER (ORDER BY `year`) AS GDP_previous_year
        ,`GDP` - LAG(`GDP`, 1) OVER (ORDER BY `year`) AS gdp_difference
        ,ROUND(((`GDP` - LAG(`GDP`, 1) OVER (ORDER BY `year`)) / LAG(`GDP`, 1) OVER (ORDER BY `year`)) * 100, 2) AS GDP_difference_percent
FROM GDP_data
),
payroll_data AS (
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
        ,g.GDP_difference_percent
        ,pr.payroll_difference_percent
        ,p.price_difference_percent
    FROM payroll_diff pr
    JOIN price_diff p ON pr.`year` = p.`year`
    JOIN GDP_diff g ON pr.`year` = g.`year` 
)
SELECT
	`year`
	,GDP_difference_percent
   	,payroll_difference_percent 
   	,price_difference_percent 
FROM final_table
ORDER BY `year`;