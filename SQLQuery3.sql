Select *
From PortfolioProject..CovidDeaths
Order by 1,2

Select *
From PortfolioProject..CovidVaccinations
oRDER bY 1,2 

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at total cases Vs Total Deaths
--Shows likelihood of dying of covid in your country
SELECT 
    location,date,total_cases,total_deaths,
    CASE 
        WHEN TRY_CONVERT(float, total_cases) = 0 THEN 0 
        ELSE (TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases)) * 100 
    END AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
	WHERE location like 'Kenya'
ORDER BY 1,2
    
	--Looking At Total Cases Vs Population 
	--Shows what percentage of population got covid

	Select location,date,Population,total_cases,
    CASE 
        WHEN TRY_CONVERT(float, total_cases) = 0 THEN 0 
        ELSE (TRY_CONVERT(float, total_cases) / TRY_CONVERT(float, population)) * 100 
    END AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
	WHERE location like 'Kenya'
ORDER BY 1,2

--Looking at Countries with highest Infecton Rate Compared to Population

Select location,population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Group by location,population
Order by PercentPopulationInfected desc
    
 --Showing countries with the highest death count per population

 SELECT location, Max(cast(Total_deaths as float)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
Where continent is not Null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent,Max(cast(Total_deaths as float)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY  continent
ORDER BY TotalDeathCount DESC;

--Showing continents with the highest death count per population

SELECT continent,Max(cast(Total_deaths as float)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY  continent
ORDER BY TotalDeathCount DESC;

--looking at total population vs vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location,dea.date;


--USE CTE
WITH PoPVsVac (continent,location,date,population,new_vaccinations,cumulative_vaccinations)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location,dea.date
)
select *,(cumulative_vaccinations/population)*100
from PoPVsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulatonVaccinated
Create Table #PercentPopulatonVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Cumulative_Vaccinations numeric,
)
insert into #PercentPopulatonVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location,dea.date

select *,(cumulative_vaccinations/population)*100
from #PercentPopulatonVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulatonVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
 
 select *
 from PercentPopulatonVaccinated