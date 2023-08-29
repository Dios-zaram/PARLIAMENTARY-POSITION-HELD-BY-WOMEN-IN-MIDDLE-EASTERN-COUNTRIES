--Create the Middle eastern countries population
CREATE TABLE ME_countries(Country VARCHAR,
						 Year INT,
						 Population NUMERIC);

--Create the female middle eastern countries parliament
CREATE TABLE Female_ME_parliament(Country VARCHAR,
						  Year INT,
						  Last_Election_Date VARCHAR,
						  Value NUMERIC);
						 
--insert values
COPY ME_countries FROM 'C:\Program Files\PostgreSQL\15\data\data_copy\Middle Eastern countries.csv'
DELIMITER ',' CSV HEADER;

--insert values
COPY Female_ME_parliament FROM
'C:\Program Files\PostgreSQL\15\data\data_copy\African women in parliament.csv'
DELIMITER ',' CSV HEADER;


--select values
select * from ME_countries;

select * from Female_ME_parliament;

--update country name for the both table
Update ME_countries set country = 'Yemen' where country ='Yemen, Rep.'
Update ME_countries set country = 'Iran' where country = 'Iran, Islamic Rep.'
Update Female_ME_parliament set country = 'Iran' where country = 'Iran (Islamic Republic of)'
Alter table Female_ME_parliament rename column Year to year;
--Cleaning tables
Delete from ME_countries where year is null;
Delete from Female_ME_parliament where year < 2015;


--Analysis
select m.country, m.year, m.population, f.value::int from ME_countries as m inner join
Female_ME_parliament as f using(country,year)
order by country desc, year desc
/* Is really amazing with the growth of women that held parliamentary postions in UAE, each
year there is growth. 2015 the number was 18, 2019 it grew to 23 and in 2022 it skyrocketed to
50. While the United Arab Emirates (UAE) does have a cultural and religious context that 
might seem conservative in terms of gender roles, it's important to note that the UAE has
also taken steps to promote women's participation in various sectors, including politics.

Other countries like Isreal,Iraq,Cyprus,Bahrain and Saudi Arabia a little similarity.
While Qatar drop from 10 to 4 is alarming. Kuwait drop from 6 in 2020 to 2 in 2022 is also 
alarming. Finaly, Yemen no human base on the dataset have held a parliament postion from 2015
-2022 Why? 

While Yemen has ratified international human rights treaties, including the
Convention on the Elimination of All Forms of Discrimination Against Women (CEDAW), 
domestic laws and policies may not fully reflect these commitments. Legal barriers,
such as discriminatory family laws and 
inheritance practices, can impact women's ability to engage in politics and public life
https://www2.ohchr.org/english/bodies/hrc/docs/ngos/
Yemen's%20darkside-discrimination_Yemen_HRC101.pdf.*/

--create temp table
drop table if exists Both_tables;
create temp table Both_tables as(select * from Me_countries as m inner join 
								 Female_ME_parliament as f using(country,year))

select * from Both_tables where country='United Arab Emirates';

--minus population from women post held number by countries
with cte as (select distinct country,sum(population) as total_population,
			 sum(value) as total_held from Both_tables group by country)

select cte.country, cte.total_population,round(cte.total_held) as total_held
from Both_tables as b inner join cte using(country) group by total_population,
cte.country, total_held order by total_held desc;
 /*The Middle East analysis reveals that from 2015 to 2022, UAE, despite its diverse
 beliefs, saw 213 women hold parliamentary positions among its total population of 
55,362,288. In contrast, Israel and Iraq, with populations of 54,447,300 and 
250,498,731 respectively, had 159 women each in such positions. Oman, with a 
population of 27,035,869, had 11 women representatives, while Yemen had only 1, 
emphasizing significant population disparities in parliamentary representation.
 */


--highest and lowest population with women position held by country
select country, year, max(population) max, cast(value as int) from Both_tables group by country
, value, year order by max desc;
/*Analyzing the data, Iran stands out as the Middle Eastern country with the 
highest population in 2022, reaching 88,550,570, yet only 6 women held positions 
in parliament. Following closely is Iraq, with a population of 44,496,122, where 
29 women held parliamentary positions. On the other end, Cyprus, with the smallest 
population, had 13 women holding parliamentary positions. */

--Average for each country
select country,round(avg(value)) avg_positionheld,
round(percentile_cont(0.5) within group(order by value)) as median_positionheld
from both_tables group by country order by avg_positionheld desc;
/* it shows that UAE have a high average and median of 35 & 36 follow by Isreal and Iraq 
with 27 & 26 respectively and yemen wih 0 average*/

----Average for each year
select year,ceil(sum(value)) total,round(avg(value)) avg_positionheld,
round(percentile_cont(0.5) within group(order by value)) as median_positionheld
from both_tables group by year order by avg_positionheld desc
/* In the 2020 women held more parliamentary position, shift front to 2022 and we are short 
of 10 numbers. The dataset shows that as the world is becoming more modernalized, women have
the right to be voted for too. */

--Last election held in each country with total parliament postions held
select country, last_election_date, cast(sum(value) as int) total from Female_ME_parliament
group by country, last_election_date order by total desc;
/* The most recent election in the UAE with the highest total of 213 women was 
in October 2019, whereas in Yemen, the last election was held in April 2003, 
resulting in a total of 1 woman elected. */

--total
select country,year, sum(value) from both_table group by cube(year,country);

--calculate difference between current row and previous value
select country, year, value, value-lag(value) over(partition by year) as difference 
from both_table order by country desc, year desc

