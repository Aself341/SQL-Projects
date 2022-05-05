Select *
From [Porfolio Project]..Covid_Deaths
order by 3,4

--Select *
--From [Porfolio Project]..Covid_Vaccinations
--order by 3,4

--Select Data to be used

Select Continent, Location, date, total_cases, new_cases, total_deaths, population
From [Porfolio Project]..Covid_Deaths
where continent is not null
order by 1, 2


-- Total Cases vs Total Deaths
-- Calculated field shows chance of death if you catch covid at that time/country

Select Continent, Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Porfolio Project]..Covid_Deaths
Where location like '%states%' and continent is not null
order by 1, 2

-- Total Cases vs Population
-- Calculated field shows percent of population that has contracted Covid
Select Continent, Location, date, Population, total_cases, (total_cases/population)*100 as TotalCovidPercentage
From [Porfolio Project]..Covid_Deaths
Where location like '%states%' and continent is not null
order by 1, 2

--Countries with Highest Infection Rate compared to the Population
Select Continent, Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Porfolio Project]..Covid_Deaths
Where continent is not null
Group by continent, Location, Population
order by PercentPopulationInfected desc

--Countries with highest Death Count compared to Population
Select Continent, Location, Population, Max(cast(total_deaths as int)) as TotalDeaths, Max((total_deaths/Population))*100 as PercentPopulationDied
From[Porfolio Project]..Covid_Deaths
Where continent is not null
Group by continent, Location, Population
Order by TotalDeaths desc

--Continent Breakdown by death count
Select Location, FORMAT(Max(cast(total_deaths as int)), 'N') as TotalDeaths
From[Porfolio Project]..Covid_Deaths
Where continent is null
Group by Location, Population
Order by Max(cast(total_deaths as int)) desc




--Global Breakdowns


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM[Porfolio Project]..Covid_Deaths
where continent is not null
Group by date
Order by 1, 2

--Joining the two tables (death and vaccination data)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.Location 
		Order by dea.location, CONVERT(date, dea.Date)) as RollingVaccinated
FROM [Porfolio Project]..Covid_Deaths dea
Join [Porfolio Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3





--CTE example

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.Location 
		Order by dea.location, CONVERT(date, dea.Date)) as RollingVaccinated
FROM [Porfolio Project]..Covid_Deaths dea
Join [Porfolio Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinated/Population)*100
From PopVsVac

--Temp Table example (Same function as CTE)

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.Location 
		Order by dea.location, CONVERT(date, dea.Date)) as RollingVaccinated
FROM [Porfolio Project]..Covid_Deaths dea
Join [Porfolio Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating views for use in Tableau Visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) 
	OVER (Partition by dea.Location 
		Order by dea.location, CONVERT(date, dea.Date)) as RollingVaccinated
FROM [Porfolio Project]..Covid_Deaths dea
Join [Porfolio Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

--Total Cases VS Deaths
Create View TotalCasesVsTotalDeaths as
Select Continent, Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Porfolio Project]..Covid_Deaths
Where location like '%states%' and continent is not null

-- Total Cases vs Population
Create View TotalCasesVsPopulation as
Select Continent, Location, date, Population, total_cases, (total_cases/population)*100 as TotalCovidPercentage
From [Porfolio Project]..Covid_Deaths
Where location like '%states%' and continent is not null

--Countries with highest infection rate
Create View CountriesWithHighestInfections as
--Countries with Highest Infection Rate compared to the Population
Select Continent, Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Porfolio Project]..Covid_Deaths
Where continent is not null
Group by continent, Location, Population


--Countries with highest Death Count compared to Population
Create View CountriesWithHighestDeaths as
Select Continent, Location, Population, Max(cast(total_deaths as int)) as TotalDeaths, Max((total_deaths/Population))*100 as PercentPopulationDied
From[Porfolio Project]..Covid_Deaths
Where continent is not null
Group by continent, Location, Population


--Continent Breakdown View
Create View ContinentDeathBreakdown as
Select Location, FORMAT(Max(cast(total_deaths as int)), 'N') as TotalDeaths
From[Porfolio Project]..Covid_Deaths
Where continent is null
Group by Location, Population




