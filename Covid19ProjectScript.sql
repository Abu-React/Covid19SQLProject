--Checking and confirming the data frame
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--Picking work data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths
SELECT Location, date, population, (total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%emirates%'
ORDER BY 1,2;

--Looking at Total Cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%emirates'
ORDER BY 1,2;

--Looking at countries with highest infection compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectionRate DESC;

--Showing countries with the highest death count
SELECT Location,MAX(cast(Total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Showing continents with the highest death count
SELECT continent,MAX(cast(Total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global 
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as INT)) AS Total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CountPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS CountPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3;
)
SELECT *, (CountPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp Table

DROP TABLE IF EXISTS #RatePopulationVaccinated
CREATE TABLE #RatePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CountPeopleVaccinated numeric
)
INSERT INTO #RatePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS CountPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 1,2,3;
SELECT *, (CountPeopleVaccinated/Population)*100
FROM #RatePopulationVaccinated


--Creating view for visualization
CREATE VIEW RateVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS CountPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3;


SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';

SELECT *
FROM RateVaccinated