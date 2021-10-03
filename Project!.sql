-- Looking at the data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by location,date


-- Probability of death if you contract the virus

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location = 'Canada'
order by location,date

-- Total Cases vs Population

-- What percentage of the Canadian Population got covid

SELECT location, date, total_cases, Population, (total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Canada'
order by location,date

--Look at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as MaxInfectedPercentage
FROM PortfolioProject..CovidDeaths
group by location, population
order by MaxInfectedPercentage desc

--How many people died, death count per country

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not Null 
group by location
order by TotalDeathCount desc

--death count per continent

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is Null 
group by location
order by TotalDeathCount desc

--Global Numbers of new cases per day and new deaths per daay

SELECT date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM [dbo].[CovidDeaths]
Where continent is not null
group by date
order by date

--Looking at total population vs vaccinations

--- Use CTE
With PopvsVac (Continent,Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)


SELECT *, (PeopleVaccinated/population)*100 as PropVaccinated
From PopvsVac
order by location, Date


-- Accurate results as of Sep 29 2021 of people vaccinated.
Drop table percentpopvac
Create Table PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinated numeric)

Insert into PercentPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
From [dbo].[CovidDeaths] dea join [dbo].CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

alter table percentpopvac
drop column date

select location, max(peoplevaccinated) as CurrentVaccinated, max(population) as Population, max(peoplevaccinated)/max(Population)*100 as PercentVaccinated_Sep29
from PercentPopVac
group by Location
having  max(peoplevaccinated)/max(Population)*100  < 100
order by Location


-- Global Numbers Covid

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int)) / sum(new_cases) * 100 as DeathPercent
From [dbo].CovidDeaths
where continent is not null


-- Creating Views 

-- Tells how many people are vaccinated in each country as of the date
Create View Count_of_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

--Tells the current vaccinated and the proportion of the population vaccinated as of Sep 29 2021

Create view PercentVacc as
select location, max(peoplevaccinated) as CurrentVaccinated, max(population) as Population, 
max(peoplevaccinated)/max(Population)*100 as PercentVaccinated_Sep29
from PercentPopVac
group by Location
--having  max(peoplevaccinated)/max(Population)*100  < 100





























