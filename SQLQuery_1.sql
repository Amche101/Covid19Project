-- SELECT* 
-- FROM COVID19..[Covid-Death]
-- Order By 3,4

-- SELECT* 
-- FROM COVID19..[Covid-Vaccinations]
-- Order By 3,4

-- Changing Column data types so division will not return 0:
        -- Alter table COVID19..[Covid-Death] alter column total_deaths FLOAT

--Selecitng the data that we need from covid-death
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM COVID19..[Covid-Death]
Order By 1,2

--Taking a look at Total Cases vs. Total Death (For states)
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercent
FROM COVID19..[Covid-Death]
WHERE location like '%state%'
Order By 1,2

-- Taking a look at the percentage of population that got covid (For states)
SELECT Location, date, total_deaths, population, total_cases, (total_cases / population)*100 as CasePercentage
FROM COVID19..[Covid-Death]
WHERE location like '%state%'
Order By 1,2


-- What country has the highest infection rate?
SELECT Location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases / population))*100 as InfectionRate
FROM COVID19..[Covid-Death]
GROUP BY Location, population
Order By InfectionRate DESC

-- Which country has the highest death count?
SELECT Location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths / population))*100 as DeathRate
FROM COVID19..[Covid-Death]
WHERE continent is not NULL
GROUP BY Location, population
Order By TotalDeathCount DESC

-- Showing the continent with highest death Count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM COVID19..[Covid-Death]
WHERE continent is NULL
GROUP BY location
Order By TotalDeathCount DESC

-- Global Numbers Daily
-- Had to change the vaiables to float otherwise it won't work
SELECT date, SUM(new_cases) as TotalCasesPerDay, SUM(new_deaths) as TotalDeathsPerDay, (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))) * 100 as DeathPercentage
FROM COVID19..[Covid-Death]
WHERE continent is not null
GROUP BY date
Order By 1,2


-- Looking at total Population vs Vaccination
-- Using CTE

With OpoVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
        SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccination
FROM COVID19..[Covid-Vaccinations] v JOIN COVID19..[Covid-Death] d ON v.location = d.location and v.date = d.date
WHERE d.continent is not null
--order by 2,3
)
SELECT *, (cast(RollingPeopleVaccination as float)/cast(population as int) )* 100
From OpoVsVac


-- Using TEMP Table!!
DROP Table if EXISTS #PercentPopVacc
Create Table #PercentPopVacc 
(
continent NVARCHAR(225),
location NVARCHAR(225),
date DATETIME,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert INTO #PercentPopVacc
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
        SUM(v.new_vaccinations) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccination
FROM COVID19..[Covid-Vaccinations] v JOIN COVID19..[Covid-Death] d ON v.location = d.location and v.date = d.date
WHERE d.continent is not null

SELECT *, (cast(p.RollingPeopleVaccinated as float)/cast(population as float) )* 100 as VaccinationPercentage
From #PercentPopVacc p 

-- Creating View to Storee data for later visualizations?



