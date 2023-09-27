SELECT *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

SELECT *
From PortfolioProject1..CovidVaccinations
order by 3,4

--Select Data that we are going to be using
Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject1..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
Select Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercent
From PortfolioProject1..CovidDeaths
Where continent is not null AND location like '%states%'
order by 1,2

--Looking at Ttoal Cases vs Population
--Shows the percentage of population got covid
Select Location,date,total_cases,population,(total_cases/population)*100 as CovidPercent
From PortfolioProject1..CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location,population,MAX(total_cases)as HighestInfection,MAX((total_cases/population))*100 as CovidPercent
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by location, population
order by CovidPercent desc

--Break things down by continent

--Showing Countries with Highest Death Count per Population
Select location,MAX(total_deaths)as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers
Select date,SUM(new_cases)as total cases,SUM(new_deaths) as total deaths,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
From PortfolioProject1..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by date
order by 1,2

With PopvsVac (continent, location,date, population,new_vaccinations,RollingVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinated
From PortfolioProject1..CovidVaccinations vac
Join PortfolioProject1..CovidDeaths dea
	On vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
)
--USE CTE
Select *,(RollingVaccinated/population)*100 as VaccinatedPercent
From PopvsVac

-- TEMP Table
Drop Table if exists #VaccinatedPercent
Create Table #VaccinatedPercent
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric
)
Insert into #VaccinatedPercent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinated
From PortfolioProject1..CovidVaccinations vac
Join PortfolioProject1..CovidDeaths dea
	On vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null

Select *,(RollingVaccinated/population)*100 as VaccinatedPercent
From  #VaccinatedPercent

--Creating View to store data for viz
Create View VaccinatedPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingVaccinated
From PortfolioProject1..CovidVaccinations vac
Join PortfolioProject1..CovidDeaths dea
	On vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null

Select *
From VaccinatedPopulation