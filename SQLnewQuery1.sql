Select * From CovidProject..CovidDeaths$
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-----Vaccination Dasaset-----------
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths$ d
JOIN CovidProject..CovidVaccination$ v
ON d.location = v.location AND d.date= v.date
where d.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths$ d
JOIN CovidProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





-- Using Temp Table to perform Calculation on Partition By in previous query


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
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths$ d
JOIN CovidProject..CovidVaccination$ v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--DROP Table if exists #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths$ d
JOIN CovidProject..CovidVaccination$ v

	On d.location = v.location
	and d.date = v.date
where d.continent is not null 


































