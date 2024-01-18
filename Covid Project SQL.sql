select * from PortfolioProject..CovidDeath
where continent is not null  
order by 3,4

--select * from PortfolioProject..CovidVaccination
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null 
order by location,date

-- resumé type de nos donnees
USE PortfolioProject;

EXEC sp_help 'CovidDeath';
-- changer type d'une colonne  


ALTER TABLE PortfolioProject..CovidDeath
ALTER COLUMN total_cases float

ALTER TABLE PortfolioProject..CovidDeath
ALTER COLUMN total_deaths float

ALTER TABLE PortfolioProject..CovidDeath
ALTER COLUMN total_cases_per_million float

ALTER TABLE PortfolioProject..CovidDeath
ALTER COLUMN total_deaths_per_million float

ALTER TABLE PortfolioProject..CovidDeath
ALTER COLUMN reproduction_rate float
--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract in your country
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeath
where continent is not null and location like '%states%'
order by location,date

--Looking at Total cases vs Population
--Shows what percentage of population got Covid

select location, date, population, total_cases,   (total_cases/population)*100 as PercentagePopulationInfection
from PortfolioProject..CovidDeath
--where location like '%states%'
where continent is not null 
order by location,date

-- Looking at countries with highest infection rate compared to Population

select location,population, Max(total_cases) AS HighestInfecctionCount, MAX((total_cases/population))*100  as PercentagePopulationInfection
from PortfolioProject..Covid Death
where continent is not null 
group by location,population
order by PercentagePopulationInfection DESC

--Showing Countries with highest Death count per population 

select location,population, Max(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100  as PercentagePopulationDeath
from PortfolioProject..CovidDeath
where continent is not null 
group by location,population
order by PercentagePopulationDeath DESC

--Lets break things down by continent

select location, Max(total_deaths) AS TotalDeathCount
from PortfolioProject..CovidDeath
where continent is null 
group by LOCATION
order by TotalDeathCount DESC

--Showing continents with the hightest death count per population 

select location, Max(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100  as PercentagePopulationDeath
from PortfolioProject..CovidDeath
where continent is null 
group by LOCATION
order by PercentagePopulationDeath DESC

--Global Numbers

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null
group by date, total_cases, total_deaths
order by date desc

--Numbers per Date
--cumul
SELECT date, total_cases_CumulPerDate, total_deaths_CumulPerDate, (total_deaths_CumulPerDate/total_cases_CumulPerDate)*100 AS DeathPercentage
FROM (
    SELECT date, SUM(total_cases) AS total_cases_CumulPerDate, SUM(total_deaths) AS total_deaths_CumulPerDate
    FROM PortfolioProject..CovidDeath
    WHERE continent IS NOT NULL
    GROUP BY date
) AS subquery
ORDER BY Date

--par jour sans cumul
SELECT date, SUM(new_cases) AS total_cases_perDate, SUM(new_deaths) AS total_deaths_perDate, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
    FROM PortfolioProject..CovidDeath
    WHERE continent IS NOT NULL and new_cases is not null
    GROUP BY date
    ORDER BY Date

--supprimer une ligne incohérente 
DELETE FROM PortfolioProject..CovidDeath
WHERE date = '2020-01-05';

--Looking at Total Population vs Vaccinations

ALTER TABLE PortfolioProject..CovidVaccination
alter column new_vaccinations float

--USE CTE

with PopulationsvsVaccinations (continent, location,date, population, new_vaccinations, CumulVaccinationsPerDate)
AS
(
 SELECT d.continent, d.location,d.date, d.population, v.new_vaccinations,
 SUM(v.new_vaccinations) OVER (partition by d.location order by d.location, d.date) AS CumulVaccinationsPerDate
 --, (CumulVaccinationsPerDate/population)*100 
From PortfolioProject..CovidDeath AS d
JOIN PortfolioProject..CovidVaccination AS v
	ON d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
)

select *, (CumulVaccinationsPerDate/population)*100
from PopulationsvsVaccinations


--TEMP TABLE
DROP TABLE IF exists #PercentpopulationVaccination
CREATE TABLE #PercentpopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
CumulVaccinationsPerDate numeric
)

INSERT INTO #PercentpopulationVaccination
 SELECT d.continent, d.location,d.date, d.population, v.new_vaccinations,
 SUM(v.new_vaccinations) OVER (partition by d.location order by d.location, d.date) AS CumulVaccinationsPerDate
 --, (CumulVaccinationsPerDate/population)*100 
From PortfolioProject..CovidDeath AS d
JOIN PortfolioProject..CovidVaccination AS v
	ON d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3

select *, (CumulVaccinationsPerDate/population)*100
from #PercentpopulationVaccination 