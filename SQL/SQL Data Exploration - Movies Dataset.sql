-- SQL DATA EXPLORATION ON MOVIES DATASET
-- Dataset Source: https://www.kaggle.com/datasets/danielgrijalvas/movies 
-- Viewing all the tables
select * from PortfolioProject1..movies;
select * from PortfolioProject1..movies_releasedinfo;
select * from PortfolioProject1..movies_runtimeinfo;

-- Movie genres that have over 500 movies sorted in alphabetical order
SELECT genre, COUNT(*) AS genre_count
FROM PortfolioProject1..movies
GROUP BY genre
HAVING COUNT(*) > 500
ORDER BY genre;

--The total revenue for each movie genre category sorted by the highest gross
SELECT genre, SUM(gross) AS total_revenue
FROM PortfolioProject1..movies
GROUP BY genre
ORDER BY total_revenue DESC;

-- Percentage of movies belonging to each rating category
SELECT rating, COUNT(*) AS movie_count,
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM movies) AS movierating_percentage
FROM PortfolioProject1..movies
GROUP BY rating
ORDER BY movierating_percentage;

-- Top 5 production companies based on the average gross revenue of their movies.
SELECT TOP 5 company, ROUND(AVG(gross),2) AS avg_gross
FROM PortfolioProject1..movies
WHERE gross > 0
GROUP BY company
HAVING COUNT(*) >= 5
ORDER BY avg_gross DESC;

-- Stars starting with or having the string 'Chris' in their name
SELECT star
FROM PortfolioProject1..movies
GROUP BY star
HAVING LEN(star) > 10 AND star LIKE 'Chris%';

-- Indian movies and their budget that are over 3 hours 
SELECT m.name, mrt.runtime_hrs, m.budget
FROM PortfolioProject1..movies m JOIN PortfolioProject1..movies_runtimeinfo mrt
ON m.number=mrt.number 
WHERE m.country = 'India' AND mrt.runtime_hrs > 3
ORDER BY runtime_hrs DESC;

-- Thriller movies whose gross value is greater than the average gross value of the thriller movies
SELECT m.name, m.genre, m.gross, r.avg_gross
FROM PortfolioProject1..movies m
JOIN (
    SELECT genre, ROUND(AVG(gross),2) AS avg_gross
    FROM PortfolioProject1..movies
    GROUP BY genre
) r ON m.genre = r.genre
WHERE m.gross > r.avg_gross AND m.genre = 'Thriller'
ORDER BY m.gross DESC;

--Categorizing the movies' budget into low, medium and high budgets and counting the number of movies in each category.
SELECT budget_category, COUNT(*) AS movie_count
FROM (
    SELECT 
        CASE
            WHEN budget > 100000000 THEN 'High Budget'
            WHEN budget > 30000000 THEN 'Medium Budget'
            ELSE 'Low Budget'
        END AS budget_category
    FROM PortfolioProject1..movies
) budget_type
GROUP BY budget_category
ORDER BY movie_count;

-- Movies whose pany is one of the top companies and the movie is considered a high-budget movie.
WITH top_companies AS (
    SELECT company, COUNT(*) AS movie_count
    FROM PortfolioProject1..movies
    GROUP BY company
    HAVING COUNT(*) >= 50
), high_budget_movies AS (
    SELECT name, budget
    FROM PortfolioProject1..movies
    WHERE budget > 100000000 
)
SELECT m.name, c.company, m.genre, CONVERT(varchar(10),(CAST(mri.released_date AS DATE)), 101) AS released_date, m.budget
FROM PortfolioProject1..movies m
JOIN top_companies c ON m.company = c.company
JOIN high_budget_movies hbm ON m.name = hbm.name
JOIN PortfolioProject1..movies_releasedinfo mri ON m.number = mri.number 
ORDER BY m.budget DESC;

--View to display all the movies details together for years in the range of 2000 and 2005

DROP VIEW IF EXISTS MovieDetails
GO
CREATE VIEW MovieDetails as 
SELECT m.name, m.rating, m.genre, m.star, m.country, m.budget, m.gross, r.released_year, r.released_date, rt.runtime_hrs, rt.runtime_mins
FROM PortfolioProject1..movies m
LEFT JOIN PortfolioProject1..movies_releasedinfo r ON m.number = r.number
LEFT JOIN PortfolioProject1..movies_runtimeinfo rt ON m.number = rt.number
WHERE r.released_year BETWEEN 2000 AND 2005;
GO
SELECT * FROM MovieDetails ORDER BY released_year, name;


-- QUERIES USED FOR VISUALIZATION
-- Tableau link: https://public.tableau.com/app/profile/poojitha.g8868/viz/MoviesDashboard_16896344200560/Dashboard1
-- Summarizing the movies dataset
SELECT 
    COUNT(*) AS total_movies,
    COUNT(DISTINCT m.genre) AS no_of_genres,
    COUNT(DISTINCT m.rating) AS types_of_ratings,
	COUNT(DISTINCT m.company) AS no_of_companies,
	ROUND(AVG(rt.runtime_hrs),3) AS average_runtime_hours,
    ROUND(AVG(m.budget),3) AS average_budget,
    ROUND(AVG(m.gross),3) AS average_gross
FROM
PortfolioProject1..movies m
LEFT JOIN PortfolioProject1..movies_runtimeinfo rt ON m.number = rt.number;

-- Average Budget for a movie per country  
SELECT country, ROUND(AVG(budget),3) AS avg_budget
FROM PortfolioProject1..movies
GROUP BY country
ORDER BY country;

-- Number of movies released in each year from 1980 to 2015
SELECT released_year, COUNT(*) AS movie_count
FROM PortfolioProject1..movies_releasedinfo
WHERE released_year BETWEEN 1980 AND 2015
GROUP BY released_year
ORDER BY released_year;

-- Minimum and Maximum hours for movies based on genre
SELECT m.genre, MIN(rt.runtime_hrs) AS min_runtime_hours, MAX(rt.runtime_hrs) AS max_runtime_hours
FROM PortfolioProject1..movies m 
LEFT JOIN PortfolioProject1..movies_runtimeinfo rt ON m.number = rt.number
GROUP BY genre
ORDER BY genre;

-- Top 10 production companies based on the average gross revenue of their movies.
SELECT TOP 10 company, ROUND(AVG(gross),2) AS avg_gross
FROM PortfolioProject1..movies
WHERE gross > 0
GROUP BY company
HAVING COUNT(*) >= 20
ORDER BY avg_gross DESC;

