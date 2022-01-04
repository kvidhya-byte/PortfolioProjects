
-- TABLEAU QUERIES
-- Skills: Aggregate Functions, Converting Data Types
-- Queries used to create Tableau visualizations and COVID_19 data dashboard


-- global death percentage from total cases

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- total death count for each continent

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..['covid deaths$']
WHERE continent IS NULL
	  AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 
						   'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- countries with highest infection rates

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopInfected
FROM PortfolioProject..['covid deaths$']
GROUP BY location, population
ORDER BY PercentPopInfected DESC


-- days with highest infection rates by country

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopInfected
FROM PortfolioProject..['covid deaths$']
GROUP BY location, population, date
ORDER BY PercentPopInfected DESC