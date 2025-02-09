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
