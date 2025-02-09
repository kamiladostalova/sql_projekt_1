--- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH data AS (
    SELECT
        CAST(value AS DECIMAL(10, 2)) AS value
        ,code
        ,name
        ,`year`
        ,TYPE_code
    FROM
        t_kamila_dostalova_project_sql_primary_final
    WHERE
        (year IN (2006, 2018) AND code IS NULL) OR 
        (year IN (2006, 2018) AND code LIKE 111301) OR 
        (year IN (2006, 2018) AND code LIKE 114201)
    ORDER BY name
),
payroll_data AS (
    SELECT
        value AS payroll
        ,year
    FROM data
    WHERE type_code = 'payroll'
),
bread_price AS (
    SELECT
        value AS bread_price
        ,year
    FROM data
    WHERE type_code = 'price' AND code = 111301
),
milk_price AS (
    SELECT
        value AS milk_price
        ,year
    FROM data
    WHERE type_code = 'price' AND code = 114201
)
SELECT
    p.year
    ,p.payroll
    ,b.bread_price
    ,m.milk_price
    ,ROUND(p.payroll / b.bread_price) AS bread_kg
    ,ROUND(p.payroll / m.milk_price) AS milk_l
FROM payroll_data p
JOIN
    bread_price b ON p.YEAR = b.year
JOIN
    milk_price m ON p.YEAR = m.year
ORDER BY p.year;