update PortfolioProject. .CovidDeaths
set continent = (NULL)
where continent in (' ')

select *
from PortfolioProject. .CovidDeaths
where continent is not NULL
order by 3,4

select *
from PortfolioProject. .CovidDeaths
order by 3,4

--select *
--from PortfolioProject. .CovidVaccinations
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject. .CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject. .CovidDeaths
where Location like '%states%'
and continent is not null
order by 1,2

-- Lokking at Total cases vs Population
--Shows what percentage of population got Covid

select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject. .CovidDeaths
--where Location like '%states%'
order by 1,2

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject. .CovidDeaths
--where Location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject. .CovidDeaths
--where Location like '%states%'
group by Location, population	
order by PercentPopulationInfected DESC

--Showing Countries with Highest Death count per Population
select Location, max(total_deaths) TotalDeathCount 
from PortfolioProject. .CovidDeaths
--where Location like '%states%'
where continent is not NULL
group by Location
order by TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with Highest Death count per Population
select continent, max(total_deaths) TotalDeathCount 
from PortfolioProject. .CovidDeaths
--where Location like '%states%'
where continent is not NULL
group by continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS
alter table PortfolioProject. .CovidDeaths
alter column new_deaths float

select date, sum(new_cases) as total_cases, sum(new_deaths) as totla_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject. .CovidDeaths
--where Location like '%states%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(new_deaths) as totla_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject. .CovidDeaths
--where Location like '%states%'
where continent is not null
---group by date
order by 1,2

---Looking at Total Population vs Vaccinations  

alter table PortfolioProject. .CovidVaccinations
alter column new_vaccinations float

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)
from PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

---USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
from PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--- TEMP TABLE

Create Table #PercentPopulationVaccinated
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
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
from PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
---where dea.continent is not null
---order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.Location, dea.Date) as RollingPeopleVaccinated
---, (RollingPeopleVaccinated/population)*100
from PortfolioProject. .CovidDeaths dea
join PortfolioProject. .CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
---order by 2,3

select *
from PercentPopulationVaccinated