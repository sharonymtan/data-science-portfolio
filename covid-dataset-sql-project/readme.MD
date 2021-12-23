## Data Exploration with SQL and Visualisation with Tableau

Data collected from the [Our World in Data](https://ourworldindata.org/covid-deaths) on 23 Dec 2021.

4 SQL queries that created the tiles on Tableau
```ruby
-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioCovidDataset..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


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

```

[[Click here to access full SQL project file]](https://github.com/sharonymtan/data-science-portfolio/blob/main/covid-dataset-sql-project/COVID%20Portfolio%20Project%20v1.sql)

Tableau Visualisation:
![Tableau dashboard](/assets/images/covid-tableau-dashboard.png)

[Link to tableau public](https://public.tableau.com/app/profile/sharon3988/viz/CovidDashboard_16402299396360/Dashboard1?publish=yes)
