create database covid_19;

select * from worldometer_data;

select worldometer_data.Country_Region, Population, TotalCases, TotalDeaths, TotalRecovered, ActiveCases, worldometer_data.WHO_Region
from worldometer_data
left join country_wise_latest
on worldometer_data.Country_Region = country_wise_latest.Country_Region;

-- 1. Top 10 country with the most total cases.
select Country_Region, TotalCases
from worldometer_data
order by TotalCases desc
limit 10;

-- 2. Top 10 country by population with the most total cases, deaths and recovered.
select Country_Region, Population, TotalCases, TotalDeaths, TotalRecovered
from worldometer_data
order by Population desc
limit 10;

-- 3. Total cases, deaths and recovered by continent.
select continent, 
        sum(TotalCases) as total_cases, 
        sum(TotalDeaths) as total_deaths, 
        sum(TotalRecovered) as total_recovered
from worldometer_data
group by continent
order by continent;

-- 4. Percentage total cases by country.
select Country_Region, 
        (totalcases/(select sum(totalcases) from worldometer_data)) as total_contribution_cases_percentage
from worldometer_data
order by total_contribution_cases_percentage desc;

select sum(totalcases) from worldometer_data;

-- 5. Percentage total cases by continent.
with total_cases_by_continent as
(
select continent, sum(totalcases) as total_cases
from worldometer_data
group by continent
)

select total_cases_by_continent.continent, 
      total_cases_by_continent.total_cases/(select sum(totalcases) from worldometer_data) as total_contribution_case_percentage
from total_cases_by_continent;

-- 6.Development of total cases monthly based on certain country criteria.
delimiter $$
create procedure total_cases_monthly_by_country
(
in country_name text
)
begin
select month(Date) as months, sum(Confirmed) as total_confirmed 
from full_grouped
where country_region = country_name
group by months
order by months;
end $$
delimiter ;

drop procedure total_cases_monthly_by_country;

call total_cases_monthly_by_country("russia");

-- 7. The highest total cases monthly.
delimiter $$
create procedure total_cases_per_continent
(
in continent_name text
)
begin
select worldometer_data.continent, 
        month(date) as months, 
        sum(confirmed) as total_confirmed, 
        sum(deaths) as total_deaths, 
        sum(recovered) as total_recovered
from worldometer_data
left join full_grouped
on worldometer_data.country_region = full_grouped.country_region
where worldometer_data.continent = continent_name and month(date) is not null
group by worldometer_data.Continent, months
order by months;
end $$
delimiter ;

drop procedure total_cases_per_continent;

call total_cases_per_continent("asia");

-- 8. Percentage deaths and recovered cases by continent.
select continent, 
      sum(TotalDeaths)/sum(TotalCases) as death_percentage, 
      sum(totalrecovered)/sum(TotalCases) as recovered_percentage
from worldometer_data
group by continent
order by continent;
