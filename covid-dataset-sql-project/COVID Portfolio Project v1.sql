select * 
from PortfolioCovidDataset..CovidDeaths
where continent is not null
order by 3,4


--select * 
--from PortfolioCovidDataset..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioCovidDataset..CovidDeaths 
order by 1,2


-- Looking at Total Cases vs Total Deaths (likelihood of death if contract covid by country)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioCovidDataset..CovidDeaths 
where location like 'Malaysia'
order by 1,2


-- Looking at Total Cases vs Population
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PecentagePopulationInfected
from PortfolioCovidDataset..CovidDeaths 
where location like 'Malaysia'
order by 1,2

-- Looking at country with highest infection rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, max(total_cases/Population)*100 as PecentagePopulationInfected
from PortfolioCovidDataset..CovidDeaths 
--where location like 'Malaysia'
group by Location,population
order by PecentagePopulationInfected desc


-- Looking at Countries with the Highest Deaths Count per Population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioCovidDataset..CovidDeaths 
where continent is not null
group by Location
order by TotalDeathCount desc

-- BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioCovidDataset..CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioCovidDataset..CovidDeaths 
-- where location like 'Malaysia'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioCovidDataset..CovidDeaths dea
join PortfolioCovidDataset..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)

as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioCovidDataset..CovidDeaths dea
join PortfolioCovidDataset..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)

Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- USE TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioCovidDataset..CovidDeaths dea
join PortfolioCovidDataset..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- CREATING VIEW to store data for later visualisations

create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioCovidDataset..CovidDeaths dea
join PortfolioCovidDataset..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

select * from
PercentPopulationVaccinated


/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioCovidDataset..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioCovidDataset..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioCovidDataset..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioCovidDataset..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc




