--selecting data from CovidDeaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
order by 1,2

--calculating maximum data
SELECT location, population,  max(total_cases) as HighestInfectionCount, max((total_deaths/population)*100) as InfectedPercentage
FROM PortfolioProject..CovidDeaths$
group by location, population
order by InfectedPercentage desc

--removing null spaces
SELECT location, max(cast(total_deaths as int)) as Deathcount
FROM PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by Deathcount desc

--grouping by continent
SELECT continent, max(cast(total_deaths as int)) as Deathcount
FROM PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by Deathcount desc

--showing total cases, total deaths, total death % (continent wise)
SELECT  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--selecting data from CovidVaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations from  PortfolioProject..CovidVaccinations$ v join PortfolioProject..CovidDeaths$ d
on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3

--joining both tables
select d.continent, d.location, d.date, d.population as pop, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidVaccinations$ v join PortfolioProject..CovidDeaths$ d
on d.location=v.location and d.date=v.date
where d.continent is not null

--calculating rolling people vaccinated
select * , (r.RollingPeopleVaccinated/r.pop)/100
from
(
select d.continent, d.location, d.date, d.population as pop, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidVaccinations$ v join PortfolioProject..CovidDeaths$ d
on d.location=v.location and d.date=v.date
where d.continent is not null
) as r

--creating view (for abstraction and ease of use)
create view PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population as pop, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from  PortfolioProject..CovidVaccinations$ v join PortfolioProject..CovidDeaths$ d
on d.location=v.location and d.date=v.date
where d.continent is not null

--selecting from view
select * from PercentPopulationVaccinated