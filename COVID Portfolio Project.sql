-- COVID-19 DATA EXPLORATION
-- Skills: Joins, Aggregate Functions, Converting Data Types, CTEs, Temp Tables, Creating Views


-- select covid death data

SELECT *
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
order by 3, 4


-- select covid vaccination data

SELECT *
FROM PortfolioProject..['covid vaccinations$']
order by 3, 4


-- select data to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['covid deaths$']
order by 1, 2


-- total cases vs. total deaths by country
-- likelihood of death by country

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE Location like '%states%'
order by 1, 2


-- total cases vs. population
-- percentage of population that got covid

SELECT Location, date, total_cases, population, (total_cases / population) * 100 AS InfectedPercentage
FROM PortfolioProject..['covid deaths$']
WHERE Location = 'United States'
order by 1, 2


-- countries with highest infected rate

SELECT Location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopInfected
FROM PortfolioProject..['covid deaths$']
group by Location
order by PercentPopInfected DESC



-- BY CONTINENT

-- countries with highest death rate

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
group by Location
order by TotalDeathCount DESC


-- continents with highest death counts

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..['covid deaths$']
WHERE continent is null AND Location != 'Upper middle income'
	AND Location != 'High income'
	AND Location != 'Lower middle income'
	AND Location != 'Low income'
group by Location
order by TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int)) / SUM(new_cases) * 100 AS GlobalDeathPercentage-- , total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
group by date
order by 1, 2


-- Global Death Percentage overall

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int)) / SUM(new_cases) * 100 AS GlobalDeathPercentage-- , total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
order by 1, 2



-- total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..['covid deaths$'] dea
JOIN PortfolioProject..['covid vaccinations$'] vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3



-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVacCount)
AS
-- total population vs vaccinations
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
													 ORDER BY dea.location, dea.date) AS RollingVacCount
FROM PortfolioProject..['covid deaths$'] dea
JOIN PortfolioProject..['covid vaccinations$'] vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingVacCount / Population) * 100
FROM PopvsVac




-- TEMP table

CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(200),
Location nvarchar(200),
Date datetime,
Population numeric,
New_Vac numeric,
RollingVacCount numeric
)

INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
													 ORDER BY dea.location, dea.date) AS RollingVacCount
FROM PortfolioProject..['covid deaths$'] dea
JOIN PortfolioProject..['covid vaccinations$'] vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingVacCount / Population) * 100
FROM #PercentPopVaccinated



-- View for visualizations

CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
													 ORDER BY dea.location, dea.date) AS RollingVacCount
FROM PortfolioProject..['covid deaths$'] dea
JOIN PortfolioProject..['covid vaccinations$'] vac
	ON dea.Location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *
FROM PercentPopVaccinated


-- death rate by country as view

CREATE VIEW CountryDeathRate AS
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
group by Location
--order by TotalDeathCount DESC
