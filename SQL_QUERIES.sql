-- =====================================================================
-- NETFLIX MOVIES AND TV SHOWS DATA ANALYSIS USING SQL
-- PostgreSQL
-- =====================================================================


-- =====================================================================
-- 15 Business Problems & Solutions
-- =====================================================================

-- 1. Count the number of Movies vs TV Shows
SELECT
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rnk
    FROM RatingCounts
)
SELECT type, rating AS most_frequent_rating
FROM RankedRatings
WHERE rnk = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
-- NOTE: `country` can hold multiple comma-separated countries per row,
-- so it must be split before counting, or one title gets miscounted
-- as belonging to a single combined "country".
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie (by duration, in minutes)
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND duration = (SELECT MAX(duration) FROM netflix WHERE type = 'Movie');
-- NOTE: duration is stored as text (e.g. '90 min'), so a plain MAX() compares
-- strings, not numbers. A numerically correct version:
-- SELECT * FROM netflix
-- WHERE type = 'Movie'
-- ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
-- LIMIT 1;


-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;


-- 9. Count the number of content items in each genre
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC;


-- 10. For India, find each year and the average number of content
--     releases; return the top 5 years with the highest average.
SELECT
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100
    , 2) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in, in the last 10 years
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number
--     of movies produced in India
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
    COUNT(*) AS total_movies
FROM netflix
WHERE country ILIKE '%India%'
  AND type = 'Movie'
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;


-- 15. Categorize content as 'Bad' (description contains 'kill' or
--     'violence') or 'Good' (everything else); count items in each category.
SELECT
    category,
    COUNT(*) AS total_content
FROM (
    SELECT
        CASE
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;


-- =====================================================================
-- End of 15 business problems
-- =====================================================================