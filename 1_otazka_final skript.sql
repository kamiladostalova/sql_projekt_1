--- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

SELECT 
    ROUND(value,2) AS value
    ,code
    ,name
    ,year 
    ,type_code
    ,LAG(value, 1) OVER (PARTITION BY code ORDER BY year) AS value_previous_year
    ,value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) AS value_difference
    ,CASE 
        WHEN value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) < 0 THEN '-----'
        WHEN value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) > 0 THEN '+'
        ELSE '0'
    END AS trend_of_values
FROM t_kamila_dostalova_project_sql_primary_final
WHERE code IS NOT NULL AND name IS NOT NULL AND type_code = 'payroll';
