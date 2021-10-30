
-- SQL Queries for Tableau Project 


-- 1) Impact of COVID-19 across the globe as of 30/09/2021

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortolioProject..CovidDATA
WHERE continent is not null
ORDER BY 1,2

-- 2) COVID-19 related Deaths per day in INDIA 
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM PortolioProject..CovidDATA
WHERE location = 'India'
ORDER BY 1,2

--3) % of people who contracted COVID-19 in INDIA
SELECT Location, date, total_cases, new_cases, population, (total_cases/population)*100 as Percent_Population_Infected
FROM PortolioProject..CovidDATA
WHERE location = 'India'
ORDER BY 1,2

--4) Country with highest infection rate
SELECT Location, MAX(total_cases) as Highest_Infection_Count, population, MAX((total_cases/population))*100 as Infection_Percent
FROM PortolioProject..CovidDATA
WHERE continent is not null
GROUP by location, population
ORDER BY Infection_Percent desc


--5) Country with highest infection rate per day
SELECT Location, population, date, MAX(total_cases) as Highest_Infection_Count,  MAX((total_cases/population))*100 as Infection_Percent
FROM PortolioProject..CovidDATA
WHERE continent is not null
GROUP by location, population, date
ORDER BY Infection_Percent desc



--6) Continent with highest deathcount
SELECT continent, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM (new_cases)*100 as DeathPecentage
FROM PortolioProject..CovidDATA
WHERE continent is not null
GROUP by continent
ORDER by total_deaths desc


--7) Global Numbers per day
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast (new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortolioProject..CovidDATA
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- 8) Global Death%
SELECT SUM(new_cases) as Total_Cases, SUM(cast (new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortolioProject..CovidDATA
WHERE continent is not null
ORDER BY 1,2


-- 9) Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_Vaccination_Count
FROM PortolioProject..CovidDATA as dea
JOIN PortolioProject..CovidVACC as vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
 
 
SELECT dea.continent, dea.location, dea.date,dea.population, MAX(cast(vac.new_vaccinations as int)) as Rolling_Vaccination_Count
FROM PortolioProject..CovidDATA as dea
JOIN PortolioProject..CovidVACC as vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent, dea.location,dea.date,dea.population
ORDER BY 1,2,3

 ---Using CTE
 WITH PopvsVsVacc (Continent, location, date, population,New_vaccinations,Rolling_Vaccination_Count)
as (SELECT dea.continent, dea.location, dea.date,dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_Vaccination_Count
FROM PortolioProject..CovidDATA as dea
JOIN PortolioProject..CovidVACC as vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

Select*, (Rolling_Vaccination_Count/Population)*100
From PopvsVsVacc 



-- Temp Table

DROP Table if exists #Percentage_of_population_vaccinated
Create Table #Percentage_of_population_vaccinated
(Continent nvarchar(255), location nvarchar(255), date datetime, Population numeric,
New_vacccination numeric, Rolling_Vaccination_Count numeric)

Insert into #Percentage_of_population_vaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_Vaccination_Count
FROM PortolioProject..CovidDATA as dea
JOIN PortolioProject..CovidVACC as vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
 
Select*, (Rolling_Vaccination_Count/Population)*100
From #Percentage_of_population_vaccinated



--Creating View for data visualtization 

Create View Percent_population_vaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, 
	vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as Rolling_Vaccination_Count
FROM PortolioProject..CovidDATA as dea
JOIN PortolioProject..CovidVACC as vac
ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null



SELECT*
FROM Percent_population_vaccinated