-- NETFLIX DATA ANALYSIS PROJECT.
SELECT * FROM database_shubh.netflix;
select count(*) from netflix;

-- 15 BUSSINESS PROBLEMS AND SOLUTIONS.--

-- 1.Count the number of Movies vs TV Showsnetflix
 SELECT type, count(*) as counting from netflix
 group by 1;
 
 -- 2.Find the most common rating for movies and TV shows.
 select type,rating, count(type),rank() over (partition by type order by count(type) desc) from netflix 
 group by 1,2
 order by 3 desc;
 

 
 -- 3.List all movies released in a specific year.
-- first we delete all the rows which have error in release year
SELECT release_year 
FROM netflix
WHERE STR_TO_DATE(release_year, '%d-%m-%Y') IS NULL;

delete from netflix where
release_year=' Dr. Dre' or
release_year=' Nse Ikpe-Etim' or
release_year=' Charles Rocket' or
release_year='United States' or
release_year=' Álvaro Cervantes' or
release_year=' Imanol Arias' or
release_year=' Francis Weddey' or 
release_year=' Peter Ferriero' or 
release_year=' Marquell Manning' or
release_year=' Nick Kroll' or
release_year=' Ted Ferguson' or
release_year=' Kristen Johnston';

UPDATE netflix  
SET release_year = STR_TO_DATE(release_year, '%d-%m-%Y');

-- 3.List all movies released in a specific year.(eg.2020)
select type,Year(release_year),title from netflix
where type='movie' and year(release_year)=2020
order by 1 desc;

-- 4.Find the top 5 countries with the most content on Netflix
select country, count(*) from netflix
group by 1
order by 2 desc
limit 5;

-- 5.Identify the longest movie or TV show duration 
SELECT type, title,
    cast(SUBSTRING_INDEX(duration, ' ', 1) as unsigned) AS duration,
    SUBSTRING_INDEX(duration, ' ', -1) AS duration_unit
FROM netflix 
order by 3 desc;

-- 6.Find content added in the last 5 years
-- first we update the date into real format-
set sql_safe_updates=0;
update netflix
set date_added = str_to_date(date_added,'%d-%m-%Y');
-- solution of 6th question. 
select * from netflix where
date_added>= current_date-interval 5 year
order by date_added desc;

-- 7.Find all the movies/TV shows by director 'Rajiv Chilaka'
select * from netflix 
where director like '%Rajiv chilaka%';

-- 8.List all TV shows with more than 5 seasons
select title,type,
cast(substring_index(duration,' ',1) as unsigned)
 from netflix 
where type= 'TV SHOW'
and cast(substring_index(duration,' ',1) as unsigned)>5 
order by 3;

-- 9.Count the number of content items in each genre. 
select count(*), listed_in from netflix;

SELECT genre, COUNT(*) AS total_count
FROM (
    SELECT TRIM(JSON_UNQUOTE(value)) AS genre
    FROM netflix,
         JSON_TABLE(
             REPLACE(CONCAT('["', REPLACE(listed_in, ',', '","'), '"]'),
                     '" "', '","'),
             '$[*]' COLUMNS (value JSON PATH '$')
         ) AS genres
) AS all_genres
GROUP BY genre
ORDER BY total_count DESC;

-- 10.Find the average release year for content produced in a specific country.
SELECT jt.value as country,round(avg(year(release_year)),0) as avg_release_year
FROM netflix,
JSON_TABLE(
    CONCAT('["', REPLACE(netflix.country, ',', '","'), '"]'),
    '$[*]' COLUMNS (value varchar(100) PATH '$')
) as jt
group by 1 order by 2;
-- count of these rows..
select count(*) from (SELECT jt.value,round(avg(year(release_year)),0) as avg_release_date
FROM netflix,
JSON_TABLE(
    CONCAT('["', REPLACE(netflix.country, ',', '","'), '"]'),
    '$[*]' COLUMNS (value varchar(100) PATH '$')
) as jt group by 1) as hero;

-- 11.list all movies that are documentries..
select * from netflix where
listed_in like '%documentaries%';

-- 12.Find how many movies actor 'Salman Khan' appeared in last 10 years
select * from netflix where
release_year>current_date - interval 10 year
and cast like '%salman khan%'
order by release_year desc;

-- 13.Find the top 10 actors who have appeared in the highest number of movies produced in Netflix.
SELECT jt.value as casts, COUNT(*) as number_of_movies
FROM netflix
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(REPLACE(TRIM(netflix.cast), '"',''), ',', '","'), '"]'),
    '$[*]' COLUMNS (value VARCHAR(100) PATH '$')
) AS jt
WHERE netflix.cast IS NOT NULL AND netflix.cast <> ''
GROUP BY jt.value
ORDER BY COUNT(*) DESC
limit 10;

-- 14.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
-- → Label  content containing these keywords as 'Bad' and all other content as 'Good'.
-- → Show how many items fall into each category.

-- 1st part
SELECT 
    *,
    CASE
        WHEN
            description LIKE '%kill%'
                OR description LIKE '%violence%'
        THEN
            'bad_content'
        ELSE 'good_content'
    END category
FROM
    netflix;

-- 2nd part
SELECT 
    category, COUNT(*)
FROM
    (SELECT 
        *,
            CASE
                WHEN
                    description LIKE '%kill%'
                        OR description LIKE '%violence%'
                THEN
                    'bad_content'
                ELSE 'good_content'
            END category
    FROM
        netflix) AS jt
GROUP BY 1;

-- THANK YOU...... 













 