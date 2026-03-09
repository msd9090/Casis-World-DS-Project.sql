/* 
1️⃣ Average annual income per city
This query calculates the average annual income of economists in each city.
*/

SELECT 
    city,
    AVG(total_annual_income_usd) AS avg_income
FROM economists_train
GROUP BY city
ORDER BY avg_income DESC;


/*
2️⃣ Top 5 economists by income
This query retrieves the five economists with the highest annual income.
*/

SELECT 
    economist_id,
    city,
    field_specialization,
    total_annual_income_usd
FROM economists_train
ORDER BY total_annual_income_usd DESC
LIMIT 5;


/*
3️⃣ Average experience by education level
This query shows the average number of years of experience for each education level.
*/

SELECT 
    education_level,
    AVG(years_experience) AS avg_experience
FROM economists_train
GROUP BY education_level;


/*
4️⃣ Average monthly salary by employer type
This query calculates the average monthly salary for each employer category.
*/

SELECT 
    employer_type,
    AVG(monthly_salary_usd) AS avg_salary
FROM economists_train
GROUP BY employer_type;


/*
5️⃣ Number of economists per specialization
This query counts how many economists work in each field of specialization.
*/

SELECT 
    field_specialization,
    COUNT(*) AS economists_count
FROM economists_train
GROUP BY field_specialization
ORDER BY economists_count DESC;


/*
6️⃣ Top 3 cities with the most economists
This query identifies the cities with the highest number of economists.
*/

SELECT 
    city,
    COUNT(*) AS economists_count
FROM economists_train
GROUP BY city
ORDER BY economists_count DESC
LIMIT 3;


/*
7️⃣ Average number of publications by specialization
This query calculates the average research publications for each economic specialization.
*/

SELECT 
    field_specialization,
    AVG(publications_count) AS avg_publications
FROM economists_train
GROUP BY field_specialization;


/*
8️⃣ Economists with more than 15 years of experience
This query retrieves all economists with significant experience.
*/

SELECT *
FROM economists_train
WHERE years_experience > 15;


/*
9️⃣ Average research grants by education level
This query measures the average amount of research grants received by economists at different education levels.
*/

SELECT 
    education_level,
    AVG(research_grants_usd) AS avg_grants
FROM economists_train
GROUP BY education_level;


/*
🔟 Average annual income by gender
This query compares the income differences between genders.
*/

SELECT 
    gender,
    AVG(total_annual_income_usd) AS avg_income
FROM economists_train
GROUP BY gender;


/*
1️⃣1️⃣ Specialization with the highest average income
This query identifies the economic field with the highest average income.
*/

SELECT 
    field_specialization,
    AVG(total_annual_income_usd) AS avg_income
FROM economists_train
GROUP BY field_specialization
ORDER BY avg_income DESC
LIMIT 1;


/*
1️⃣2️⃣ Average income by experience groups
This query groups economists based on experience levels and calculates average income.
*/

SELECT 
CASE
WHEN years_experience BETWEEN 0 AND 5 THEN '0-5 years'
WHEN years_experience BETWEEN 6 AND 10 THEN '6-10 years'
WHEN years_experience BETWEEN 11 AND 20 THEN '11-20 years'
ELSE '20+ years'
END AS experience_group,
AVG(total_annual_income_usd) AS avg_income
FROM economists_train
GROUP BY experience_group;


/*
1️⃣3️⃣ Economists earning above the overall average income
This query finds economists whose income is higher than the global average.
*/

SELECT *
FROM economists_train
WHERE total_annual_income_usd >
(
SELECT AVG(total_annual_income_usd)
FROM economists_train
);


/*
1️⃣4️⃣ Average working hours by employer type
This query analyzes workload differences across employer types.
*/

SELECT 
    employer_type,
    AVG(working_hours_per_week) AS avg_hours
FROM economists_train
GROUP BY employer_type;


/*
1️⃣5️⃣ Top universities based on graduate income
This query identifies universities whose graduates earn the highest income.
*/

SELECT 
    university_rank,
    AVG(total_annual_income_usd) AS avg_income
FROM economists_train
GROUP BY university_rank
ORDER BY avg_income DESC
LIMIT 3;


/*
1️⃣6️⃣ Rank economists by income within each city
This query uses a window function to rank economists by income inside each city.
*/

SELECT 
    economist_id,
    city,
    total_annual_income_usd,
    RANK() OVER (
        PARTITION BY city
        ORDER BY total_annual_income_usd DESC
    ) AS city_rank
FROM economists_train;


/*
1️⃣7️⃣ Average income per specialization in each city
This query compares income across both specialization and location.
*/

SELECT 
    city,
    field_specialization,
    AVG(total_annual_income_usd) AS avg_income
FROM economists_train
GROUP BY city, field_specialization
ORDER BY city;


/*
1️⃣8️⃣ Highest earning economist in each specialization
This query retrieves economists who have the maximum income in their specialization.
*/

SELECT *
FROM economists_train e
WHERE total_annual_income_usd =
(
SELECT MAX(total_annual_income_usd)
FROM economists_train
WHERE field_specialization = e.field_specialization
);


/*
1️⃣9️⃣ Relationship between publications and income
This query analyzes how research productivity relates to income.
*/

SELECT 
    publications_count,
    AVG(total_annual_income_usd) AS avg_income
FROM economists_train
GROUP BY publications_count
ORDER BY publications_count;


/*
2️⃣0️⃣ Top 10 economists by total calculated income
This query calculates total income from salary, bonuses, and investments.
*/

SELECT 
    economist_id,
    monthly_salary_usd,
    bonuses_usd,
    investment_income_usd,
    
    (monthly_salary_usd*12 +
     bonuses_usd +
     investment_income_usd) AS total_income
    
FROM economists_train
ORDER BY total_income DESC
LIMIT 10;
