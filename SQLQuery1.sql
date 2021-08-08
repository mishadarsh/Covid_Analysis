--LOOKING AT THE POPULATION THAT GOT CONTRACTED WITH COVID

SELECT location, date, population, total_deaths, (total_cases/population)*100 AS covid_populatiuon
FROM..covid_deaths
WHERE location LIKE '%India%'
ORDER BY 1, 2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE
SELECT location, population, MAX(total_cases) AS highest_infection, MAX((total_cases/population))*100 AS covid_populatiuon
FROM..covid_deaths
GROUP BY location, population
ORDER BY covid_populatiuon DESC

-- COUNTRIES WITH HIGHEST DEATH RATE
SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_death
FROM..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death DESC

--BREAKING THINGS BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS highest_death


FROM..covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death DESC

--GLOBAR NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM..covid_deaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- ANALYSING COVID_VACCINATIONS
-- AND USING CTE(COMMON TABLE EXPRESSION)
WITH popvsvac(continent, location, date, population, new_vaccination, rollingpeoplevaccinated) AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(INT , vacc.new_vaccinations)) OVER(PARTITION BY death.location ORDER BY death.location,
death.date) AS rollingpeoplevaccinated
FROM..covid_deaths death
JOIN..covid_vaccinations vacc
ON death.location = vacc.location
AND death.date = vacc.date
WHERE death.continent IS NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100 AS global_vaccination
FROM popvsvac
--ORDER BY 2,3

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(INT , vacc.new_vaccinations)) OVER(PARTITION BY death.location ORDER BY death.location,
death.date) AS rollingpeoplevaccinated
FROM..covid_deaths death
JOIN..covid_vaccinations vacc
ON death.location =  vacc.location
AND death.date = vacc.date
WHERE death.continent IS NOT NULL

SELECT *, (rollingpeoplevaccinated/population)*100 AS global_vaccination
FROM #PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(INT , vacc.new_vaccinations)) OVER(PARTITION BY death.location ORDER BY death.location,
death.date) AS rollingpeoplevaccinated
FROM..covid_deaths death
JOIN..covid_vaccinations vacc
ON death.location =  vacc.location
AND death.date = vacc.date
WHERE death.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
