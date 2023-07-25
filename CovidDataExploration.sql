-- 1) Selection of the data that will be used for the rest of the project
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM sql_tuto.coviddeaths
ORDER BY 1,2;

-- 2) Percent ratio between the number of cases and the number of deaths by country
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) as DeathPercentage
FROM sql_tuto.coviddeaths
ORDER BY DeathPercentage DESC;

-- 3) Total cases compared to the total population
SELECT location, date, total_cases, population, ((total_cases/population) * 100) as CasePercentage
FROM sql_tuto.coviddeaths
ORDER BY CasePercentage DESC;

-- 4) Ranking of countries with the highest contamination rate
SELECT location, population, MAX(total_cases) as InfectionCount, MAX((total_cases/population) * 100) as PopulationInfected
FROM sql_tuto.coviddeaths
GROUP BY location, population
ORDER BY PopulationInfected DESC;

-- 5) Ranking of countries with the highest death count per population
--    total_deaths is text type in the .csv import file
--    so we have to convert it into integer

SELECT location, MAX(CAST(total_deaths as UNSIGNED)) as DeathCount
FROM sql_tuto.coviddeaths
GROUP BY location
ORDER BY DeathCount DESC;

-- 6) Ranking of continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as UNSIGNED)) as DeathCount
FROM sql_tuto.coviddeaths
GROUP BY continent
ORDER BY DeathCount DESC;

-- 7) GLOBAL NUMBERS

-- a) Emergence of first covid cases/deaths
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as UNSIGNED)) as total_deaths,
SUM(CAST(new_deaths as UNSIGNED))/SUM(new_cases) * 100 as DeathPercentage
FROM sql_tuto.coviddeaths
GROUP BY date;

-- b) date with the highest deaths count
SELECT date, CAST(total_deaths as UNSIGNED) as total_deaths
FROM sql_tuto.coviddeaths
ORDER BY total_deaths DESC
LIMIT 1;

-- COVID VACCINATIONS

SELECT * FROM sql_tuto.coviddeaths dea
JOIN sql_tuto.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

-- 1) Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM sql_tuto.coviddeaths dea
JOIN sql_tuto.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY CAST(vac.new_vaccinations as UNSIGNED) DESC;

-- 2) Calculate, for each day and each place, the total number of vaccinations
-- that have been carried out up to that date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM sql_tuto.coviddeaths dea
JOIN sql_tuto.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY RollingPeopleVaccinated DESC;

-- Retrieve the percentage of the population vaccinated up to each date for each location,
-- considering all vaccinations done up to that date
-- using CTE !

WITH PopsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM sql_tuto.coviddeaths dea
JOIN sql_tuto.covidvaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY RollingPeopleVaccinated DESC)
SELECT *, (RollingPeopleVaccinated / population) * 100 as PercentageVaccinatedPopulation
FROM PopsVac;
