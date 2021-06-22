-- PortfolioProject # 1
-------------------------------------------------------------------------------------

-- Look at Total Cases vs. Population. Percentage of population that got covid
select 
    location,
    date,
    total_cases,
    total_deaths,
    round((total_deaths/total_cases) * 100,2) as "death_percentage"
from 
    PortfolioProject.dbo.covid_deaths
order by
    1,2;
    
-------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population
select
    location,
    population,
    max(total_cases) as "highest_infection_count",
    round(max((total_cases/population)) * 100, 2) as "highest_infection_percentage"
from     
    PortfolioProject.dbo.covid_deaths
group by 
    location,
    population
order by
    4 desc;

-------------------------------------------------------------------------------------

-- Showing Countries with Highest Death Count Per Population
select 
    continent,
    location,
    max(cast(total_deaths as int)) As "total_deaths"
from 
    PortfolioProject.dbo.covid_deaths
where
    continent is not null
group by 
    continent,
    location
order by 
    3 desc; 

-------------------------------------------------------------------------------------

-- Showing continents with the highest death count
select
    continent,
    max(cast(total_deaths as int)) as "total_death_count"
from 
    PortfolioProject.dbo.covid_deaths
where 
    continent is not null
group by 
    continent
order by 
    2 desc;

-------------------------------------------------------------------------------------

-- global numbers
select 
    date,
    sum(cast(new_cases as int)) as "new_cases",
    sum(cast(new_deaths as int)) as "new_deaths"
from 
    PortfolioProject.dbo.covid_deaths
where 
    continent is not null
group by 
    date
order by 
    date asc

-------------------------------------------------------------------------------------

-- looking at total population vs. vaccinations
with pop_vs_vaccinations as (
    select 
        d.continent,
        d.location,
        d.date,
        d.population,
        v.new_vaccinations,
        sum(cast(v.new_vaccinations as float)) over (partition by d.location order by d.location, d.date) as "running_vaccination"
    from 
        PortfolioProject.dbo.covid_deaths as d
    left join
        PortfolioProject.dbo.covid_vaccinations as v on d.location = v.location and d.date = v.date
    where 
        d.continent is not null
)

select 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    running_vaccination,
    (running_vaccination / population) * 100 as "running_vaccination_percentage"
from 
    pop_vs_vaccinations;