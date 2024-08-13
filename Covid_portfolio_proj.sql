-- Covid Deaths
-- **COUNTRY WISE**

-- select useful columns
select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not NULL -- null continent means its location is filled by continent value
order by 1,2

-- total_cases vs total_deaths
-- showing the likelihood of dying if you contract covid in the selected country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like 'China'
and continent is not NULL
order by 1,2

-- total_cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as percent_popultion_infected
from PortfolioProject..CovidDeaths
where location like 'China'
and continent is not NULL
order by 1,2

-- countries with highest infection rate compared to population
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as percent_popultion_infected
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location, population
order by percent_popultion_infected desc

-- countries with highest death count
select location, MAX(total_deaths) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by highest_death_count desc


-- **CONTINENT WISE**

-- continent with the highest death count
select continent, MAX(total_deaths) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by highest_death_count desc


-- **GLOBAL WISE**

-- total cases, total deaths, and total death percentage
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/sum(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2


-- joining Covid Vaccinations
-- total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

-- with CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL)
select *, (rolling_people_vaccinated/population)*100 as rolling_percent_ppl_vaccinated
from PopvsVac

-- TEMP TABLE
drop table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric)

insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
-- where dea.continent is not NULL

select *, (rolling_people_vaccinated/population)*100 as rolling_percent_ppl_vaccinated
from #PercentPeopleVaccinated

-- creating views to store data for later visualization
create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)  over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not NULL

select * from PercentPeopleVaccinated