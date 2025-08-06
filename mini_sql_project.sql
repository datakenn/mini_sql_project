--Mini SQL Project by Kennedy Holifield

CREATE TABLE user_submissions(
	id SERIAL PRIMARY KEY,
	user_id BIGINT
	question_id INT,
	points INT,
	submitted_at TIMESTAMP WITH TIME ZONE
	username VARCHAR(50)
);

SELECT * 
FROM user_submissions;

 -- Distinct users and their stats (user_name, total_submissions, points earned)
SELECT
	username,
	COUNT(id) as total_submissions,
	SUM(points) as points_earned	
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC;
-- Daily average points for each user.
SELECT
	--EXTRACT(DAY FROM submitted_at) as day,
	TO_CHAR(submitted_at,'DD-MM') as day,
	username,
	ROUND(AVG(points),2) AS daily_avg_points	
FROM user_submissions
GROUP BY TO_CHAR(submitted_at, 'DD-MM'),
username
ORDER BY username ASC;

-- Top 3 users with the most positive submissions for each day.
WITH daily_submissions AS 
(SELECT
	TO_CHAR(submitted_at,'DD-MM') as daily,
	username,
	SUM(CASE
		WHEN points > 0 THEN 1
	ELSE 0
	END) AS correct_submissions
FROM user_submissions
GROUP BY TO_CHAR(submitted_at, 'DD-MM'),
username
),
user_rank AS
(SELECT 
	daily,
	username,
	correct_submissions,
	DENSE_RANK() OVER(PARTITION BY daily 
	ORDER BY correct_submissions DESC) AS RANK
FROM daily_submissions
)
SELECT
	daily,
	username,
	correct_submissions
FROM user_rank
WHERE rank <= 3;

-- Top 5 users with the highest number of incorrect submissions.
SELECT 
    username,
    SUM(CASE 
		WHEN points < 0 
		THEN 1 
	ELSE 0 
		END) AS incorrect_submissions,
    SUM(CASE 
		WHEN points > 0 
		THEN 1 
	ELSE 0 END) AS correct_submissions,
    SUM(CASE 
		WHEN points < 0 
		THEN points ELSE 0 END) AS incorrect_submissions_points,
    SUM(CASE 
	WHEN points > 0 
	THEN points ELSE 0 END) AS correct_submissions_points_earned,
    	SUM(points) AS points_earned
FROM user_submissions
GROUP BY 1
ORDER BY incorrect_submissions DESC;

-- Top 10 performers for each week.
SELECT *  
FROM (
    SELECT 
        EXTRACT(WEEK FROM submitted_at) AS week_no,
        username,
        SUM(points) AS total_points_earned,
        DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS rank
    FROM user_submissions
    GROUP BY 1, 2
    ORDER BY week_no, total_points_earned DESC
)
WHERE rank <= 10;

