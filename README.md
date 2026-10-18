<p align="center">
  <img src="./assets/netflix-logo.png" width="300" alt="Netflix Logo"/>
</p>

<h1 align="center">Netflix Movies and TV Shows Data Analysis using SQL</h1>

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQL-15%20Business%20Problems-blue?style=flat"/>
</p>

## Overview

This project analyzes a dataset of Netflix movies and TV shows using PostgreSQL, answering
15 real business questions about content type, ratings, genres, countries, cast, and
content classification. The goal is to extract meaningful insights from Netflix's catalog
the way a data analyst would -- exactly the kind of exploratory SQL work used in real
analyst interviews and case studies.

## Schema

```sql
CREATE TABLE netflix
(
	show_id	      VARCHAR(5),
	type          VARCHAR(10),
	title	      VARCHAR(250),
	director      VARCHAR(550),
	casts	      VARCHAR(1050),
	country	      VARCHAR(550),
	date_added    VARCHAR(55),
	release_year  INT,
	rating	      VARCHAR(15),
	duration      VARCHAR(15),
	listed_in     VARCHAR(250),
	description   VARCHAR(550)
);
```

## Business Problems & Solutions

All 15 queries live in [`netflix_queries.sql`](./netflix_queries.sql).

1. Count the number of Movies vs TV Shows
2. Find the most common rating for movies and TV shows
3. List all movies released in a specific year (e.g., 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie
6. Find content added in the last 5 years
7. Find all the movies/TV shows by director 'Rajiv Chilaka'
8. List all TV shows with more than 5 seasons
9. Count the number of content items in each genre
10. Find each year and the average number of content releases in India on Netflix; return the top 5 years with the highest average content release
11. List all movies that are documentaries
12. Find all content without a director
13. Find how many movies actor 'Salman Khan' appeared in in the last 10 years
14. Find the top 10 actors who have appeared in the highest number of movies produced in India
15. Categorize content based on the presence of the keywords 'kill' and 'violence' in the description field -- label content containing these keywords as 'Bad' and everything else as 'Good'; count how many items fall into each category

## Key techniques used

- `STRING_TO_ARRAY()` + `UNNEST()` -- splitting comma-separated multi-value fields
  (`country`, `listed_in`, `casts`) into individual rows before aggregating, so a title
  with 3 countries doesn't get undercounted as a single combined group
- `TO_DATE()` -- parsing `date_added` (stored as text) into a real date for date-range filtering
- `SPLIT_PART()` + casting -- extracting the numeric portion out of text fields like
  `'90 min'` or `'3 Seasons'` so they can be compared/sorted numerically, not as strings
- Window functions (`RANK() OVER (PARTITION BY ...)`) -- finding the most frequent rating
  per content type (Pattern 1: Top-N per Group)
- `CASE` + conditional classification -- tagging content as 'Good'/'Bad' based on keyword
  presence in free text (`ILIKE`, case-insensitive pattern matching)
- Scalar subqueries -- computing a percentage of total (Q10's average release ratio)

## Findings & Conclusion

- The dataset skews toward one content type over the other -- Movies vs TV Shows split is
  the first thing this analysis quantifies.
- Content classification by keyword (Q15) is a simple proxy, not a true content-rating
  system -- it only flags the literal words 'kill'/'violence' appearing in the
  **description text**, not actual on-screen content, so it should be read as a rough
  signal, not a certified rating.
- Several fields (`country`, `listed_in`, `casts`) store **multiple comma-separated
  values per row** -- any aggregation on these must account for that, or the counts will
  be wrong (a title with "United States, India" as its country would otherwise count
  as its own unique, miscounted category instead of contributing to both countries).

## How to run

1. Install PostgreSQL (or use any Postgres-compatible environment).
2. Run the `CREATE TABLE` statement at the top of `netflix_queries.sql`.
3. Load the Netflix dataset CSV into the `netflix` table (matching column order).
4. Run any of the 15 numbered queries.

## Project structure

```
netflix-sql-project/
├── assets/
│   └── netflix-logo.png
├── README.md
└── netflix_queries.sql
```
