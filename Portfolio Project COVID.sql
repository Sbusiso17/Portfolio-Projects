select *
from PortfolioProjectSQL..CovidDeaths$
order by 3,4

--select *
--from PortfolioProjectSQL..CovidVaccinations$
--order by 3,4

----Select data we are going to be using

select Location, date, total_cases, total_deaths, population
from PortfolioProjectSQL..CovidDeaths$
order by 1,2

---- Looking at Total cases vs Total deaths
-- shows the likelihood of dying if you contract covid in S.A 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Pcnt_population_infected
from PortfolioProjectSQL..CovidDeaths$
Where location like '%South Africa%'
order by 1,2

---- Looking at Total cases vs Population
--Shows us the percentage of South Africas population that has Covid
select Location, Population, total_cases, Population, (total_cases/population)*100 as Pcnt_population_infected
from PortfolioProjectSQL..CovidDeaths$
Where Location like '%South Africa%'
order by 1,2


--- Looking at countries with highest infection rate compared to Population
select Location, Population, MAX(total_cases) as Highest_infection_rate, 
MAX((total_cases/population))*100 as Pcnt_population_infected
from PortfolioProjectSQL..CovidDeaths$
group by Location, Population
order by Pcnt_population_infected desc


---- Showing contries with highest death countper population
select Location, MAX(cast(total_deaths as int)) as Total_death_Counts
from PortfolioProjectSQL..CovidDeaths$
Where continent is not null
group by Location
order by Total_death_Counts desc


---- Showing continents with highest death countper population
select location, MAX(cast(total_deaths as int)) as Total_death_Counts
from PortfolioProjectSQL..CovidDeaths$
Where continent is null
group by location
order by Total_death_Counts desc

select continent, MAX(cast(total_deaths as int)) as Total_death_Counts
from PortfolioProjectSQL..CovidDeaths$
Where continent is not null
group by continent
order by Total_death_Counts desc


--GLOBAL NUMBERS

select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))
as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as
DeathPercentage 
from PortfolioProjectSQL..CovidDeaths$
where continent is not null
--Group by date
order by 1,2


--Joined both tables on date and location
--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.
new_vaccinations
from PortfolioProjectSQL..CovidDeaths$ dea
Join PortfolioProjectSQL..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

--Calculating the number of people gettimg vaccinated over time

select dea.continent, dea.location, dea.date, dea.population, vac.
new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) 
as peoplegetingVaccinated
from PortfolioProjectSQL..CovidDeaths$ dea
Join PortfolioProjectSQL..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

--- The numner of people getting vaccinated in each country

select dea.continent, dea.location, dea.date, dea.population, vac.
new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) 
as peoplegetingVaccinated
--(peoplegetingVaccinated/population)*100
from PortfolioProjectSQL..CovidDeaths$ dea
Join PortfolioProjectSQL..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3


-- the % of of people getting vaccinated in each country
-- USE CTE

With PopvsVac( Continent, Location, Date, Population, New_vaccinations, 
peoplegetingVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.
new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) 
as peoplegetingVaccinated

from PortfolioProjectSQL..CovidDeaths$ dea
Join PortfolioProjectSQL..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3
	) 
Select *, (peoplegetingVaccinated/population)*100 as 
perentageofpeoplevaccinated
from PopvsVac


--Creating view to store data for later visualisations

create view perentageofpeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.
new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) 
as peoplegetingVaccinated

from PortfolioProjectSQL..CovidDeaths$ dea
Join PortfolioProjectSQL..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null


create  view peoplegetingVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.
new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.location order by dea.location, dea.date) 
as peoplegetingVaccinated
--(peoplegetingVaccinated/population)*100
from PortfolioProjectSQL..CovidDeaths$ dea
Join PortfolioProjectSQL..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null


create view Highest_infection_rate as

select Location, Population, MAX(total_cases) as Highest_infection_rate, 
MAX((total_cases/population))*100 as Pcnt_population_infected
from PortfolioProjectSQL..CovidDeaths$
group by Location, Population

select * 
from Highest_infection_rate

