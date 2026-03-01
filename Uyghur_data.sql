/*
SQL Analysis Report
Dataset: Uyghur_Train
Database: SQLite
Role: Data Scientist
*/

/* 1) Load 50 Random Records
This query retrieves a random sample of 50 records for exploratory data analysis.
*/
SELECT * 
FROM Uyghur_Train
ORDER BY RANDOM()
LIMIT 50;


/* 2) Calculate Average Age
This query computes the mean age to understand central tendency.
*/
SELECT AVG(Age) AS Avg_Age
FROM Uyghur_Train;


/* 3) Gender Distribution
This query counts records by gender to analyze demographic balance.
*/
SELECT Gender, COUNT(*) AS Total
FROM Uyghur_Train
GROUP BY Gender;


/* 4) Average Income by City
This query calculates the average income for each city.
*/
SELECT City, AVG(Monthly_Income_USD) AS Avg_Income
FROM Uyghur_Train
GROUP BY City;


/* 5) Top 10 Highest Income Records
This query retrieves the highest income individuals.
*/
SELECT ID, Monthly_Income_USD
FROM Uyghur_Train
ORDER BY Monthly_Income_USD DESC
LIMIT 10;


/* 6) Target Class Percentage
This query calculates the percentage of positive target values.
*/
SELECT 
    (COUNT(CASE WHEN Target_Score = 1 THEN 1 END) * 100.0) 
    / COUNT(*) AS Target_Rate
FROM Uyghur_Train;


/* 7) Average Target Score by Gender
This query evaluates potential bias across gender categories.
*/
SELECT Gender, AVG(Target_Score) AS Avg_Target
FROM Uyghur_Train
GROUP BY Gender;


/* 8) Count Rural Population
This query counts individuals located in rural areas.
*/
SELECT COUNT(*) AS Rural_Count
FROM Uyghur_Train
WHERE Region_Type = 'Rural';


/* 9) Create Age Categories (Feature Engineering)
This query creates a derived categorical feature based on age ranges.
*/
SELECT ID,
CASE
    WHEN Age < 25 THEN 'Young'
    WHEN Age BETWEEN 25 AND 40 THEN 'Adult'
    ELSE 'Senior'
END AS Age_Group
FROM Uyghur_Train;


/* 10) High Income Filter
This query extracts individuals earning above 1000 USD.
*/
SELECT *
FROM Uyghur_Train
WHERE Monthly_Income_USD > 1000;


/* 11) Average Internet Usage
This query calculates average weekly internet usage.
*/
SELECT AVG(Internet_Usage_Hours_Per_Week) AS Avg_Internet
FROM Uyghur_Train;


/* 12) Rank Cities by Population
This query ranks cities by number of records.
*/
SELECT City, COUNT(*) AS Total
FROM Uyghur_Train
GROUP BY City
ORDER BY Total DESC;


/* 13) Average Cultural Participation
This query computes average cultural participation score.
*/
SELECT AVG(Cultural_Participation_Score)
FROM Uyghur_Train;


/* 14) Top 5 Community Activity Scores
This query retrieves the highest community activity scores.
*/
SELECT ID, Community_Activity_Score
FROM Uyghur_Train
ORDER BY Community_Activity_Score DESC
LIMIT 5;


/* 15) Education Level Distribution
This query counts records by education level.
*/
SELECT Education_Level, COUNT(*)
FROM Uyghur_Train
GROUP BY Education_Level;


/* 16) Detect Income Outliers
This query identifies potential income outliers.
*/
SELECT *
FROM Uyghur_Train
WHERE Monthly_Income_USD > 1400;


/* 17) Average Income by Gender
This query evaluates income differences across genders.
*/
SELECT Gender, AVG(Monthly_Income_USD)
FROM Uyghur_Train
GROUP BY Gender;


/* 18) Create Clean Data View
This query creates a reusable filtered dataset.
*/
CREATE VIEW Clean_Data AS
SELECT *
FROM Uyghur_Train
WHERE Age BETWEEN 18 AND 60
AND Monthly_Income_USD IS NOT NULL;


/* 19) Retrieve Highest Target Scores
This query extracts records with highest target values.
*/
SELECT ID, Target_Score
FROM Uyghur_Train
ORDER BY Target_Score DESC
LIMIT 10;


/* 20) Approximate Income Variance
This query calculates statistical variance using E(X²) − [E(X)]².
*/
SELECT 
AVG(Monthly_Income_USD * Monthly_Income_USD) - 
AVG(Monthly_Income_USD) * AVG(Monthly_Income_USD)
AS Variance_Approx
FROM Uyghur_Train;
