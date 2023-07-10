select *
from PortfolioProject#1..CovidDeaths
order by 3,4

--select *
--from PortfolioProject#1..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject#1..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Death
-- shows likelyhood of dying if you contrac Covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject#1..CovidDeaths
where location like 'Ukraine'
order by 1,2

-- Looking at Total Cases vs Population
-- What percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as IllPercentage
from PortfolioProject#1..CovidDeaths
where location like 'Ukraine'
order by 1,2

-- Looking country with highest Infection rate compared to population

Select location, population, max (total_cases) as HighestInfCount, Max ((total_cases/population))*100 as PercentPopulInfected
from PortfolioProject#1..CovidDeaths
group by location, population
order by 4 desc

-- Showing Countries with highest death count per population
Select location, population, max (cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject#1..CovidDeaths
where continent is not Null --doesnt show the hole continents as location
group by location, population
order by TotalDeathCount desc

-- lets break it down by continent
--Select location, max (cast (total_deaths as int)) as TotalDeathCount
--from PortfolioProject#1..CovidDeaths
--where continent is Null 
--group by location
--order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, max (cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject#1..CovidDeaths
where continent is not Null 
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select  sum (new_cases) as total_cases, sum(cast(new_deaths as int))as total_death, 
sum(cast(new_deaths as int))/sum (new_cases)*100 as DeathPercentage
from PortfolioProject#1..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking for total population vs vaccinations 
With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject#1..CovidDeaths as dea
 join PortfolioProject#1..CovidVaccinations as vac
   on dea.location=vac.location
   and dea.date=vac.date
   where dea.continent is not null
  -- order by 2,3
   )
   select *, (RollingPeopleVaccinated/population)*100
   from  PopvsVac



   --Temp Table
 drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject#1..CovidDeaths as dea
 join PortfolioProject#1..CovidVaccinations as vac
   on dea.location=vac.location
   and dea.date=vac.date
 --  where dea.continent is not null
  -- order by 2,3

  select *, (RollingPeopleVaccinated/population)*100
   from  #PercentPopulationVaccinated


   -- Create view to store data for later visualizations

   create view PercentPopulationVaccinated as
     select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject#1..CovidDeaths as dea
 join PortfolioProject#1..CovidVaccinations as vac
   on dea.location=vac.location
   and dea.date=vac.date
 where dea.continent is not null
  -- order by 2,3

  select * from PercentPopulationVaccinated