Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data we are going to be using (Omit at end)
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs. total deaths
--Shows likelihood of dying if you contract covid in the U.S
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

--Looking at Total Cases vs. Population
Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

--looking at countries with highest infected rate compared to population
Select location, population, MAX(total_cases) as HighestCaseCount, population, MAX((total_cases/population))*100 as CasePercentage
From PortfolioProject..CovidDeaths
--Where location = 'United States'
Group by location, population
order by 5 desc

--Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location
order by 2 desc

--Broken Down by continent

--Continents by highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
order by 2 desc


--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2

--Total Population vs. vaccines
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Use Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not NULL
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
join CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not NULL


Select *
From PercentPopulationVaccinated
Order by 1,2