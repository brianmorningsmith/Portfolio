

/* Data validation

data from https://ourworldindata.org/covid-deaths
data source type: .csv
date range: 1/1/20 - 7/31/21
data fields:

field name - data type
----------------------
iso_code - varchar(50)
continent - varchar(50)
location - varchar(50)
date - date
population - float
total_cases - float
new_cases - float
new_cases_smoothed - float
total_deaths - float
new_deaths - float
new_deaths_smoothed - float
total_cases_per_million - float
new_cases_per_million - float
new_cases_smoothed_per_million - float
total_deaths_per_million - float
new_deaths_per_million - float
new_deaths_smoothed_per_million - float
reproduction_rate - float
icu_patients - float
icu_patients_per_million - float
hosp_patients - float
hosp_patients_per_million - float
weekly_icu_admissions - float
weekly_icu_admissions_per_million - float
weekly_hosp_admissions - float
weekly_hosp_admissions_per_million - float
new_tests - float
total_tests - float
total_tests_per_thousand - float
new_tests_per_thousand - float
new_tests_smoothed - float
new_tests_smoothed_per_thousand - float
positive_rate - float
tests_per_case - float
tests_units - varchar(50)
total_vaccinations - float
people_vaccinated - float
people_fully_vaccinated - float
new_vaccinations - float
new_vaccinations_smoothed - float
total_vaccinations_per_hundred - float
people_vaccinated_per_hundred - float
people_fully_vaccinated_per_hundred - float
new_vaccinations_smoothed_per_million - float
stringency_index - float
population_density - float
median_age - float
aged_65_older - float
aged_70_older - float
gdp_per_capita - float
extreme_poverty - float
cardiovasc_death_rate - float
diabetes_prevalence - float
female_smokers - float
male_smokers - float
handwashing_facilities - float
hospital_beds_per_thousand - float
life_expectancy - float
human_development_index - float
excess_mortality - float

Excel source file handling - confirm figures as numeric
Break data set into 2 files deaths/vaccinations
SQL - import to 2 tables as types string, date and float

Join 2 tables on date 

*/

------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Total Deaths

--Select cd.location
--	,cd.continent
--	,cd.date
--	,cast(total_cases as int) as total_cases
--	,total_deaths
--	,total_deaths/NULLIF(total_cases,0)*100 as death_percentage
--FROM covid_deaths as CD
--Inner Join covid_vaccinations CV on CD.date = CV.date 
--WHERE 
--cd.location like '%states%' AND 
--cd.continent > '0'

------------------------------------------------------------------------------------------------------

-- Looking at Countries with highest infection rate compared to population 

--Select 
--	 cd.Location
--	,cast(cd.population as decimal) as Population
--	,MAX(cd.total_cases) as HighestInfectionCount
--	,cd.total_cases/NULLIF(cd.population, 0)*100 as PercentPopulationInfected
--FROM covid_deaths as CD
--Inner Join covid_vaccinations CV on CD.date = CV.date 
----WHERE cd.location like '%states%'
----AND continent > '0'
--Group by population, total_cases, cd.location
--Order by PercentPopulationInfected desc

------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Population, % of population that caught covid

--Select
--	Location
--	,Date
--	,cast(Population as integer) as Population
--	,cast(total_cases as integer) as Total_Cases
--	,cast(total_cases/NULLIF(cd.population, 0)*100 as decimal(18, 2)) as PercentPopulationInfected
--FROM covid_deaths as CD
--WHERE cd.location like '%states%'
--AND continent continent > '0'
----Order by PercentPopulationInfected desc

------------------------------------------------------------------------------------------------------

--Looking at Countries with Highest Infection Rate compared to population

--Select
--	 Location
--	,Population
--	,Max(total_cases) as HighestInfectionCount
--	,Max((total_cases/Nullif(population, 0))*100) as PercentPopulationInfected
--FROM covid_deaths as CD
----WHERE cd.location like '%states%'
--AND continent > '0'
--Group by Location, Population
--Order by PercentPopulationInfected desc

------------------------------------------------------------------------------------------------------

--Looking at Countries with Highest Death Counts per Population

--Select Location
--	,Max(cast(cd.total_deaths as int)) as TotalDeathCount
--FROM covid_deaths as CD
--Where Continent > '0'
--Group by location
--Order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------

--Looking at Continents with Highest Death Counts per Population (North America is only US)


--Select location
--	,Max(cast(cd.total_deaths as int)) as TotalDeathCount
--FROM covid_deaths as CD
--Where Continent < '1'
--Group by location
--Order by TotalDeathCount desc

------------------------------------------------------------------------------------------------------

--Looking at Global Numbers
                                                                                                           
--Select 
--	 Date
--	,Sum(cast(new_cases as int)) as TotalCases
--	,Sum(cast(new_deaths as int)) as TotalDeaths
--	,Sum(new_deaths/NULLIF(new_cases,0)/1000) as DeathPercentage
--FROM covid_deaths as CD
--Where Continent > '0'
--Group by Date
--Order by Date


------------------------------------------------------------------------------------------------------
--Looking at Global Numbers 

--Select 
--	 Sum(cast(new_cases as float)) as TotalCases
--	,Sum(cast(new_deaths as float)) as TotalDeaths
--	,Sum(cast(new_deaths as float)/NULLIF(new_cases,0)/1000) as DeathPercentage
--FROM covid_deaths as CD
--Where Continent > '0'


------------------------------------------------------------------------------------------------------
-- Looking at Rolling People Vaccinated by Country

--Select 
--	 cd.Continent
--	,cd.Location
--	,cd.Date
--	,Convert(int, cd.population) as Population
--	,cv.New_Vaccinations
--	,Sum(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
--FROM covid_deaths as CD
--Inner Join covid_vaccinations CV on CD.date = CV.date and cd.location = cv.location
--WHERE 
----cd.location like '%states%' AND 
--cd.continent > '0'


------------------------------------------------------------------------------------------------------
--Use CTE

--With Popsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
--as
--(
--Select 
--	 cd.Continent
--	,cd.Location
--	,cd.Date
--	,Convert(int, cd.population) as Population
--	,cv.New_Vaccinations
--	,Sum(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
--FROM covid_deaths CD
--Inner Join covid_vaccinations CV on CD.date = CV.date and cd.location = cv.location
--WHERE 
----cd.location like '%states%' AND 
--cd.continent > '0')
--Select *, (RollingPeopleVaccinated/NULLIF(Population, 0))/1000
--From Popsvac


------------------------------------------------------------------------------------------------------
-- Looking at total Population vs Vaccinations

--Select 
--	 cd.Continent
--	,cd.Location
--	,cd.Date
--	,Convert(int, cd.population) as Population
--	,cv.New_Vaccinations
--	,Sum(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
--FROM covid_deaths CD
--Join covid_vaccinations CV 
--	On CD.date = CV.date 
--	And cd.location = cv.location
--WHERE cd.continent > '0'

------------------------------------------------------------------------------------------------------

-- Temp Table - PercentPoulationVaccinated
	
--DROP TABLE #PercentPopulationVaccinated

--CREATE TABLE #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_Vaccinations numeric,
--RollingPeopleVaccinated numeric
--)
--Insert into #PercentPopulationVaccinated
--Select 
--	 cd.Continent
--	,cd.Location
--	,cd.Date
--	,cd.Population
--	,cv.New_Vaccinations
--	,Sum(convert(int,cv.New_Vaccinations)) 
--	OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
--	From covid_deaths cd
--	Join covid_vaccinations cv
--	On cd.location = cv.location
--	And cd.date = cv.date
--	Where cd.continent > '0'
--	Select *, (RollingPeopleVaccinated/NULLIF(Population, 0))/1000 From #PercentPopulationVaccinated

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

-- Creating Views to store data for later visualizations 

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

--Create View PercentPopulationVaccinated as
--Select 
--	 cd.Continent
--	,cd.Location
--	,cd.Date
--	,Convert(int, cd.population) as Population
--	,cv.New_Vaccinations
--	,Sum(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
--FROM covid_deaths CD
--Join covid_vaccinations CV 
--	On CD.date = CV.date 
--	And cd.location = cv.location
--WHERE cd.continent > '0'

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

--Create View PercentPopulationDeaths as
--Select cd.location
--	,cd.continent
--	,cd.date
--	,cast(total_cases as int) as total_cases
--	,total_deaths
--	,total_deaths/NULLIF(total_cases,0)*100 as death_percentage
--FROM covid_deaths as CD
--Inner Join covid_vaccinations CV on CD.date = CV.date 
--WHERE 
--cd.location like '%states%' AND 
--cd.continent > '0'

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

--Create View PercentPopulationInfected as
--Select 
--	 cd.date
--	,cd.Location
--	,Cast(cd.population as decimal) as Population
--	,Max(cd.total_cases) as HighestInfectionCount
--	,Cast(cd.total_cases as numeric)/NULLIF(cast(cd.population as numeric), 0)*100 as PercentPopulationInfected
--FROM covid_deaths as CD
--Inner Join covid_vaccinations CV on CD.date = CV.date 
--WHERE cd.continent > '0'
--AND cd.location like '%states%'
--Group by cd.location, cd.date, cd.population, cd.total_cases
----Order by cd.location, cd.date
