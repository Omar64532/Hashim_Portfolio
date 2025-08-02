# World Life Expectancy Project (Data Cleaning) 

Select *
from world_life_expectancy
;

# Identify duplicate rows based on combination of country and year
Select country, year, concat(country, year), count(concat(country, year)) 
from world_life_expectancy
group by country, year, concat(country, year)
having count(concat(country, year)) > 1
;

# Identify duplicate Row_IDs
Select *
from(
	select Row_ID,
	concat(country, year),
	row_number() Over( partition by concat(country, year) order by concat(country, year)) as row_num
	from world_life_expectancy
    ) as row_table
where row_num > 1
;

#Delete the duplicate rows identified
delete from world_life_expectancy
where
	Row_ID in (
    Select Row_ID
from(
	select Row_ID,
	concat(country, year),
	row_number() Over( partition by concat(country, year) order by concat(country, year)) as row_num
	from world_life_expectancy
    ) as row_table
where row_num > 1
)
;

# Find rows with missing status values
select *
from world_life_expectancy
where Status = ''
;

select distinct(status)
from world_life_expectancy
where Status <> ''
;

# Get a list of countries marked as Developing to help infer missing statuses
select distinct(Country)
from world_life_expectancy
where status = 'Developing'
;

# Fill missing Status values with 'Developing' based on other rows of the same country
update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
set t1.Status = 'Developing'
where t1.Status = ''
and t2.Status <> ''
and t2.Status = 'Developing'
;

# Same logic for Developed Countries as well
update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
set t1.Status = 'Developed'
where t1.Status = ''
and t2.Status <> ''
and t2.Status = 'Developed'
;

select *
from world_life_expectancy
where `Lifeexpectancy` = ''
;

# Estimate missing Life Expectancy using the average of the previous and next year for the same country
select t1.Country, t1.Year, t1.`Lifeexpectancy`, 
t2.Country, t2.Year, t2.`Lifeexpectancy`, 
t3.Country, t3.Year, t3.`Lifeexpectancy`,
round((t2.`Lifeexpectancy` + t3.`Lifeexpectancy`)/2,1)
from world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
    and t1.Year = t2.Year - 1
join world_life_expectancy t3
	on t1.Country = t3.Country
    and t1.Year = t3.Year + 1
where t1.`Lifeexpectancy` = ''
;

# Update missing Life Expectancy values using the calculated average of surrounding years
update world_life_expectancy t1
join world_life_expectancy t2
	on t1.Country = t2.Country
    and t1.Year = t2.Year - 1
join world_life_expectancy t3
	on t1.Country = t3.Country
    and t1.Year = t3.Year + 1
set t1.`Lifeexpectancy` = round((t2.`Lifeexpectancy` + t3.`Lifeexpectancy`)/2,1)
where t1.`Lifeexpectancy` = ''
;









 
 