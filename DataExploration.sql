SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4

--Select data to be worked with.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Comparing total cases to total deaths.
-- Can show how likely you are to die of COVID-19.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 FatalityRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Comparing total cases to the population. 
-- Shows the percentage of people in the population who were infected at that time.
SELECT location, date, total_cases, population, (total_cases/population)*100 PercentInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1, 2

-- Comparing countries with highest infection rate compared to Population
SELECT location, MAX(total_cases) HighestInfectionCount, population, (MAX(total_cases)/population) * 100 HighestInfectionRate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'
GROUP BY location, population
ORDER BY HighestInfectionRate DESC

-- Comparing countries with highest deaths compared to Population
SELECT location, MAX(cast(total_deaths as int)) HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%Nigeria%'
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Grouping by continent
SELECT continent, MAX(cast(total_deaths as int)) HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%Nigeria%'
GROUP BY continent
ORDER BY HighestDeathCount  DESC

--Global Numbers based on date
SELECT date, SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 fatality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1, 2

--To view the total amount of cases and deaths, and overall death rate.
SELECT SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 fatality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2

-- Joining the tables together.
SELECT cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations
FROM PortfolioProject..CovidDeaths cdeaths
JOIN PortfolioProject..CovidVaccinations cvacs
	ON cdeaths.location = cvacs.location
	AND cdeaths.date = cvacs.date
WHERE cdeaths.continent is NOT NULL
ORDER BY 1, 2 

-- To evaluate total per country.

-- Create CTE
With PopsVac(Continent, Location, Date, Population, new_vaccinations, CumulativeNoOfPeopleVaccinated) 
as
(
SELECT cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations, 
SUM(cast(cvacs.new_vaccinations as int)) OVER (Partition by cdeaths.location Order by cdeaths.location, cdeaths.date) CumulativeNoOfPeopleVaccinated
FROM PortfolioProject..CovidDeaths cdeaths
JOIN PortfolioProject..CovidVaccinations cvacs
	ON cdeaths.location = cvacs.location
	AND cdeaths.date = cvacs.date
WHERE cdeaths.continent is NOT NULL
)
SELECT *, (CumulativeNoOfPeopleVaccinated/Population)*100 CumulativePercentage
FROM PopsVac
ORDER BY 1,2


--Temp table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeNoOfPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations, 
SUM(cast(cvacs.new_vaccinations as int)) OVER (Partition by cdeaths.location Order by cdeaths.location, cdeaths.date) CumulativeNoOfPeopleVaccinated
FROM PortfolioProject..CovidDeaths cdeaths
JOIN PortfolioProject..CovidVaccinations cvacs
	ON cdeaths.location = cvacs.location
	AND cdeaths.date = cvacs.date
WHERE cdeaths.continent is NOT NULL
ORDER BY 1, 2

SELECT *, (CumulativeNoOfPeopleVaccinated/Population)*100 CumulativePercentage
FROM #PercentPopulationVaccinated

--Creating views

CREATE VIEW PercentPopVaccinated AS
SELECT cdeaths.continent, cdeaths.location, cdeaths.date, cdeaths.population, cvacs.new_vaccinations, 
SUM(cast(cvacs.new_vaccinations as int)) OVER (Partition by cdeaths.location Order by cdeaths.location, cdeaths.date) CumulativeNoOfPeopleVaccinated
FROM PortfolioProject..CovidDeaths cdeaths
JOIN PortfolioProject..CovidVaccinations cvacs
	ON cdeaths.location = cvacs.location
	AND cdeaths.date = cvacs.date
WHERE cdeaths.continent is NOT NULL