select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- selecting the data which are usefull for project

select location, date, total_cases,new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases VS Totas Deaths
-- Shows likeihood of dying if you contract covid in your coutry
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2

-- Looking at Toal Cases VS Population
select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2

--Looking at Countries with highest infection rates compared to population
select location, population, MAX(total_cases), MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
group by location,	population
order by PercentagePopulationInfected desc

--Showing Countrie with Highest Death Count per poulation
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- LET'S BREAK THING BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing the cotinents with higher death counts per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
--group by date
order by 1,2



select*
from PortfolioProject..CovidVaccinations


-- LET'S JOIN THE BOTH TABLES

select*
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date

-- Looking at Total Population VS Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as DailyVaccinationProgress
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3 


-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, DailyVaccinationProgress) 
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as DailyVaccinationProgress
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (DailyVaccinationProgress/population)*100
from PopvsVac


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
DailyVaccinationProgress numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as DailyVaccinationProgress
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null

select *, (DailyVaccinationProgress/population)*100 as PerDailyVacProgress
from #PercentPopulationVaccinated




--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

drop view if exists PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as DailyVaccinationProgress
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null


select * 
from #PercentPopulationVaccinated

