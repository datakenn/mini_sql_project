# Gamer SQL Project by Kennedy Holifield

This project contains SQL scripts to analyze user submissions data, focusing on tracking user activity, points earned, and ranking users based on their performance over time.

---

## Overview

The project uses a single table, **user_submissions**, to store user quiz or task submissions, including details like user ID, question ID, points awarded, submission timestamp, and username.

Several queries demonstrate how to:

- Retrieve all submissions
- Aggregate user statistics (**total submissions** and **points earned**)
- Calculate **daily average points** per user
- Identify **daily top performers** based on positive submissions
- Highlight users with the **most incorrect submissions**
- Rank **weekly top performers** based on total points

---

## Database Schema

```sql
CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);



Queries Included

1. Retrieve all submissions

SELECT * FROM user_submissions;

2. Total submissions and points earned

SELECT
    username,
    COUNT(id) AS total_submissions,
    SUM(points) AS points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC;

3. Daily average points per user

SELECT
    TO_CHAR(submitted_at, 'DD-MM') AS day,
    username,
    ROUND(AVG(points), 2) AS daily_avg_points
FROM user_submissions
GROUP BY TO_CHAR(submitted_at, 'DD-MM'), username
ORDER BY username ASC;

4. Top 3 users with the most positive submissions each day

WITH daily_submissions AS (
    SELECT
        TO_CHAR(submitted_at, 'DD-MM') AS daily,
        username,
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions
    FROM user_submissions
    GROUP BY TO_CHAR(submitted_at, 'DD-MM'), username
),
user_rank AS (
    SELECT
        daily,
        username,
        correct_submissions,
        DENSE_RANK() OVER (PARTITION BY daily ORDER BY correct_submissions DESC) AS rank
    FROM daily_submissions
)
SELECT daily, username, correct_submissions
FROM user_rank
WHERE rank <= 3;

5. Top 5 users with the highest number of incorrect submissions

SELECT
    username,
    SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) AS incorrect_submissions,
    SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions,
    SUM(CASE WHEN points < 0 THEN points ELSE 0 END) AS incorrect_submissions_points,
    SUM(CASE WHEN points > 0 THEN points ELSE 0 END) AS correct_submissions_points_earned,
    SUM(points) AS points_earned
FROM user_submissions
GROUP BY username
ORDER BY incorrect_submissions DESC
LIMIT 5;

6. Top 10 performers for each week

SELECT *  
FROM (
    SELECT 
        EXTRACT(WEEK FROM submitted_at) AS week_no,
        username,
        SUM(points) AS total_points_earned,
        DENSE_RANK() OVER (PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS rank
    FROM user_submissions
    GROUP BY week_no, username
) AS weekly_ranks
WHERE rank <= 10;
