SELECT *
FROM czechia_price;

SELECT *
FROM czechia_payroll; 

SELECT 
	sum(value) AS sum
	,calculation_code
FROM czechia_payroll
GROUP BY calculation_code; 

--- tabulka: cena, region, název regionu, položka kód, název položky, rok

SELECT *
FROM czechia_price cp
LEFT JOIN czechia_region cr
	ON cp.region_code = cr.code
;


--- původní tabulka

SELECT 
	ROUND(AVG(value),2) AS price
	,category_code 
	,cpc.name AS category_name
	,region_code
	,cr.name AS region_name 
	,YEAR(date_from) AS year
FROM czechia_price cp
JOIN czechia_price_category cpc
	ON cp.category_code = cpc.code
LEFT JOIN czechia_region cr
	ON cp.region_code = cr.code
WHERE cp.region_code IS NULL
GROUP BY YEAR, category_name, region_name; 

--- konečná tabulka czechia_price

SELECT 
	ROUND(AVG(value),2) AS price
	,category_code 
	,cpc.name AS category_name
	,YEAR(date_from) AS year
FROM czechia_price AS cp
	JOIN czechia_price_category AS cpc
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NULL 
GROUP BY YEAR, category_name; 

--- tabulka: částka, odvětví kód, název odvětví, rok
--- příprava tabulka czechia_payroll

SELECT 
	ROUND(AVG(value),2) AS mzda
	,industry_branch_code AS kod_odvetvi
	,name AS nazev_odvetvi 
	,payroll_year AS rok
	,value_type_code 
	,unit_code 
	,calculation_code 
FROM czechia_payroll
	LEFT JOIN czechia_payroll_industry_branch 
	ON czechia_payroll.industry_branch_code = czechia_payroll_industry_branch.code
WHERE value_type_code = 5958 AND unit_code = 200 AND calculation_code = 100 AND payroll_year BETWEEN 2006 AND 2018
GROUP BY industry_branch_code, payroll_year; 

--- konečná verze czechia pyaroll

SELECT 
	ROUND(AVG(value),2) AS payroll
	,industry_branch_code AS branch_code
	,cpib.name AS branch_name 
	,payroll_year AS year
FROM czechia_payroll cp
	LEFT JOIN czechia_payroll_industry_branch cpib
	ON cp.industry_branch_code = cpib.code
WHERE value_type_code = 5958 AND unit_code = 200 AND calculation_code = 100 AND payroll_year BETWEEN 2006 AND 2018
GROUP BY industry_branch_code, payroll_year; 

--- KONEČNÉ TABULKY

SELECT 
	ROUND(AVG(value),2) AS payroll
	,industry_branch_code AS branch_code
	,cpib.name AS branch_name 
	,payroll_year AS year
FROM czechia_payroll cp
	LEFT JOIN czechia_payroll_industry_branch cpib
	ON cp.industry_branch_code = cpib.code
WHERE value_type_code = 5958 AND unit_code = 200 AND calculation_code = 100 AND payroll_year BETWEEN 2006 AND 2018
GROUP BY industry_branch_code, payroll_year; 

SELECT 
	ROUND(AVG(value),2) AS price
	,category_code 
	,cpc.name AS category_name
	,YEAR(date_from) AS year
FROM czechia_price AS cp
	JOIN czechia_price_category AS cpc
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NULL 
GROUP BY YEAR, category_name; 

--- 1. PROPOJENÍ DVOU KONEČNÝCH TABULEK

WITH mzdy AS 
(SELECT 
	ROUND(AVG(value),2) AS payroll
	,industry_branch_code AS branch_code
	,cpib.name AS branch_name 
	,payroll_year AS year
FROM czechia_payroll cp
	LEFT JOIN czechia_payroll_industry_branch cpib
	ON cp.industry_branch_code = cpib.code
WHERE value_type_code = 5958 AND unit_code = 200 AND calculation_code = 100 AND payroll_year BETWEEN 2006 AND 2018
GROUP BY industry_branch_code, payroll_year)
SELECT * 
	,CASE 
		WHEN year IS NULL THEN 0
		ELSE 'payroll'
	END AS type_code
FROM mzdy; 

WITH ceny AS (
SELECT 
	ROUND(AVG(value),2) AS price
	,category_code 
	,cpc.name AS category_name
	,YEAR(date_from) AS year
FROM czechia_price AS cp
	JOIN czechia_price_category AS cpc
	ON cp.category_code = cpc.code
WHERE cp.region_code IS NULL 
GROUP BY YEAR, category_name) 
SELECT * 
	,CASE 
		WHEN year IS NULL THEN 0
		ELSE 'price'
	END AS type_code
FROM ceny;

--- 2. propojení tabulek

WITH mzdy AS 
	(SELECT 
		ROUND(AVG(value),2) AS value
		,cp.industry_branch_code AS code
		,cpib.name AS name 
		,cp.payroll_year AS YEAR
		,'payroll' AS type_code
	FROM czechia_payroll cp
		LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
	WHERE value_type_code = 5958 AND unit_code = 200 AND calculation_code = 100 AND payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.industry_branch_code, cp.payroll_year),
	ceny AS
	(SELECT 
		ROUND(AVG(value),2) AS value
		,cp.category_code AS code
		,cpc.name AS name
		,YEAR(cp.date_from) AS YEAR
		,'price' AS type_code
	FROM czechia_price cp
		JOIN czechia_price_category cpc ON cp.category_code = cpc.code
	WHERE cp.region_code IS NULL 
	GROUP BY YEAR(cp.date_from), cpc.name)
SELECT *
FROM mzdy
UNION ALL
SELECT *
FROM ceny;

--- vytvořit finální tabulku z příkazu

CREATE TABLE t_Kamila_Dostalova_project_SQL_primary_final AS
WITH mzdy AS 
	(SELECT 
		ROUND(AVG(value),2) AS value
		,cp.industry_branch_code AS code
		,cpib.name AS name 
		,cp.payroll_year AS year
		,'payroll' AS type_code
	FROM czechia_payroll cp
		LEFT JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
	WHERE value_type_code = 5958 AND unit_code = 200 AND calculation_code = 100 AND payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.industry_branch_code, cp.payroll_year),
	ceny AS
	(SELECT 
		ROUND(AVG(value),2) AS value
		,cp.category_code AS code
		,cpc.name AS name
		,YEAR(cp.date_from) AS YEAR
		,'price' AS type_code
	FROM czechia_price cp
		JOIN czechia_price_category cpc ON cp.category_code = cpc.code
	WHERE cp.region_code IS NULL 
	GROUP BY YEAR(cp.date_from), cpc.name)
SELECT *
FROM mzdy
UNION ALL
SELECT *
FROM ceny;

SELECT *
FROM t_kamila_dostalova_project_sql_primary_final; 

ALTER TABLE t_kamila_dostalova_project_sql_primary_final 
CHANGE YEAR year VARCHAR(255);

SELECT *
FROM countries;

SELECT *
FROM economies;

DESCRIBE economies;

--- finální tabulka č. 2

CREATE TABLE t_Kamila_Dostalova_project_SQL_secondary_final AS
SELECT 
	e.country
	,e.GDP 
	,e.gini
	,e.population 
	,e.year AS year
FROM economies e
	JOIN countries c ON e.country = c.country 
WHERE c.continent = 'Europe' AND e.year BETWEEN 2006 AND 2018;

SELECT *
FROM t_kamila_dostalova_project_sql_secondary_final; 


	

--- rozdíly mezi roky
--- vzor

WITH salary_avg AS (
SELECT 
	ROUND(AVG(value),2) AS payroll
	,industry_branch_code 
	,name AS industry_name
	,payroll_year 
FROM t_kamila_dostalova_project_sql_primary_final 
	LEFT JOIN czechia_payroll_industry_branch 
	ON czechia_payroll.industry_branch_code = czechia_payroll_industry_branch.code
WHERE value_type_code = 5958 OR unit_code = 200
GROUP BY industry_branch_code, payroll_year); 

--- final

SELECT *
FROM t_kamila_dostalova_project_sql_primary_final; 

WITH salary_avg AS (
SELECT 
	ROUND(AVG(value),2) AS payroll
	,industry_branch_code 
	,name AS industry_name
	,payroll_year 
FROM t_kamila_dostalova_project_sql_primary_final 
	LEFT JOIN czechia_payroll_industry_branch 
	ON czechia_payroll.industry_branch_code = czechia_payroll_industry_branch.code
WHERE value_type_code = 5958 OR unit_code = 200
GROUP BY industry_branch_code, payroll_year); 

--- nejnižší hodnota pro určité kategorie

SELECT
	date
	,country
	,confirmed
	,FIRST_value(confirmed) OVER (PARTITION BY country ORDER BY confirmed ASC) AS lowest_value
FROM covid19_basic_differences cbd
WHERE confirmed >10
ORDER BY date;

--- vložit do sloupce hodnoty z předešlého řádku
--- vzor

WITH salary_avg AS (
SELECT 
	ROUND(AVG(value),2) AS value
	,industry_branch_code 
	,name AS industry_name
	,payroll_year 
FROM czechia_payroll
	LEFT JOIN czechia_payroll_industry_branch 
	ON czechia_payroll.industry_branch_code = czechia_payroll_industry_branch.code
WHERE value_type_code = 5958 OR unit_code = 200
GROUP BY industry_branch_code, payroll_year)
SELECT *
	,LAG(value) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS previous_year
FROM salary_avg;

--- FINAL

SELECT 
    ROUND(value,0) AS value
    ,code
    ,name
    ,year 
    ,type_code
    ,LAG(value, 1) OVER (PARTITION BY code ORDER BY year) AS value_previous_year
    ,value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) AS value_difference
    ,CASE 
        WHEN value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) < 0 THEN '---'
        WHEN value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) > 0 THEN '+++'
        ELSE '0'
    END AS trend_of_values
FROM t_kamila_dostalova_project_sql_primary_final
WHERE code IS NOT NULL AND name IS NOT NULL AND type_code = 'payroll';

SELECT 
    value,
    code,  
    name, 
    year, 
    type_code, 
    LAG(value, 1) OVER (PARTITION BY code ORDER BY year) AS value_previous_year
    ,value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) AS value_difference,
    CASE 
        WHEN value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) = 0 THEN '---'
        WHEN value - LAG(value, 1) OVER (PARTITION BY code ORDER BY year) > 0 THEN '+++'
        ELSE '000'
    END AS trend_of_values
FROM t_kamila_dostalova_project_sql_primary_final
WHERE code IS NOT NULL AND name IS NOT NULL AND type_code = 'payroll';


SELECT *
FROM t_kamila_dostalova_project_sql_primary_final; 



