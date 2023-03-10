select *
From PortfolioProject..CovidDeaths 
where continent is not null
Order by 3,4

--select *
--From PortfolioProject..Covidvaccinations 
--Order by 3,4

--Select Data that we are going to be using

Select Location,date,total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths 
order by 1,2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%nigeria%'
order by 1,2


--Looking at the total cases vs population
--Shows what Percentage of Population got covid

Select Location,date,total_cases, population, (total_cases/Population)*100 as PercentagePopulationinfected
From PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
order by 1,2

--looking at countries with the highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectioncount, Max((total_cases/Population))*100 as PercentagePopulationinfected
From PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
Group by location,Population
Order by PercentagePopulationinfected desc

--Showing the countries with the highest death count per population

Select Location, population, Max(cast(total_deaths as int)) as Highestdeathcount, Max((total_deaths/Population))*100 as PercentagePopulationdeaths
From PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
where continent is not null
Group by location,Population
Order by Highestdeathcount  desc

--BREAKING THINGS DOWN BY CONTINENTS
Select continent, Max(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
where continent is  not null
Group by continent
Order by Totaldeathcount  desc


--SHOWING GLOBAL NUMBERS

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage    --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%nigeria%'
where continent is not null
--Group by date 
order by 1,2


--total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac (continent, location, date, population, New_Vaccinations, rollingpeoplevaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)
From PopvsVac 



--Temp Table

drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated 

--Creating views to store data for later visualization

drop view if exists PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
From PercentPopulationVaccinated