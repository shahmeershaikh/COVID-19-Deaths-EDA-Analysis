SELECT*
FROM [portfolio Project].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT * 
FROM [portfolio Project].dbo.CovidVaccination
ORDER BY 3,4

-- Select Data That We Are Going To Be Using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [portfolio Project].dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking At Total Cases VS Total Deaths
-- Show Likelihood Of Dying If You Contract Covid In Your Counry

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM [portfolio Project].dbo.CovidDeaths
WHERE location like '%United States%'
and continent is not null
ORDER BY 1,2

-- Looking At The Total Cases Vs Population
-- Show What Percentage Of Population Got Covid

SELECT Location, date, population, total_cases, (total_cases / population)*100 as PercentOfPopulation
FROM [portfolio Project].dbo.CovidDeaths
WHERE location like '%United States%'
and continent is not null
ORDER BY 1,2

-- Looking At Countries With Highest Infection Rate Compared To Population

SELECT Location,  population, MAX(total_cases) as HIghestInfectionCount , MAX((total_cases / population))*100 as PercentPopulationInfected
FROM [portfolio Project].dbo.CovidDeaths
WHERE continent is not null
-- WHERE location like '%United States%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries With Highest Death Count Per Population

SELECT Location, MAX(CAST(total_deaths as INT)) as TotalDeathCounts
FROM [portfolio Project].dbo.CovidDeaths
WHERE continent is not null
-- WHERE location like '%United States%'
GROUP BY Location
ORDER BY TotalDeathCounts DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing The Continent With Highest Death COunt Per Population

SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCounts
FROM [portfolio Project].dbo.CovidDeaths
WHERE continent is not null
-- WHERE location like '%United States%'
GROUP BY continent
ORDER BY TotalDeathCounts DESC


-- BREAKING GLOBAL NUMBERS
SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/ SUM(new_cases) as DeathPercentage
FROM [portfolio Project].dbo.CovidDeaths
WHERE continent is not null
GROUP By date
ORDER BY 1,2

-- BREAKING TOTAL SUM OF GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/ SUM(new_cases) as DeathPercentage
FROM [portfolio Project].dbo.CovidDeaths
WHERE continent is not null
--GROUP By date
ORDER BY 1,2


-- Looking At Total population VS Vaccination
--USE CTE

WITH PopVSVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
--, ( RollingPeopleVaccinated/population)*100
FROM [portfolio Project].dbo.Coviddeaths dea
JOIN [portfolio Project].dbo.CovidVaccination vacc
	ON
dea.Location = vacc.Location
and
dea.date = vacc.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population) * 100 FROM PopVSVacc
ORDER BY 2,3


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccications numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated


SELECT dea.continent, dea.Location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM [portfolio Project].dbo.Coviddeaths dea
JOIN [portfolio Project].dbo.CovidVaccination vacc
	ON
dea.Location = vacc.Location
and
dea.date = vacc.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population) * 100 FROM #PercentPopulationVaccinated
ORDER BY 2,3



-- Creating View To Store Data For Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS 

SELECT dea.continent, dea.Location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM [portfolio Project].dbo.Coviddeaths dea
JOIN [portfolio Project].dbo.CovidVaccination vacc
	ON
dea.Location = vacc.Location
and
dea.date = vacc.date
WHERE dea.continent is not null


SELECT * FROM PercentPopulationVaccinated




