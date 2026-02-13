/*******************************************************************************
 * PROJECT: TACTICAL COMBAT FOOTBALL (THE IRON LEAGUE)
 * DATA SCIENCE & ADVANCED ANALYTICS QUERIES (Professional Edition)
 * AUTHOR: MAHMOUD SAAD
 *******************************************************************************/

-- 1. Z-SCORE CALCULATION (Relative Power per Team)
-- Purpose: Identify elite players who deviate from their team's average power.
SELECT Entity_ID, Team_Name, Player_Role,
       (CAST(Combat_Power AS FLOAT) - Avg_Power) / NULLIF(SQRT(Avg_Power_Sq - (Avg_Power * Avg_Power)), 0) AS Power_ZScore
FROM (
    SELECT Entity_ID, Team_Name, Player_Role, CAST(Combat_Power AS FLOAT) AS Combat_Power,
           AVG(CAST(Combat_Power AS FLOAT)) OVER(PARTITION BY Team_Name) AS Avg_Power,
           AVG(CAST(Combat_Power AS FLOAT) * CAST(Combat_Power AS FLOAT)) OVER(PARTITION BY Team_Name) AS Avg_Power_Sq
    FROM combat_football_train
    WHERE Combat_Power != 'Combat_Power' -- Skip header if treated as data
) AS stats;

--------------------------------------------------------------------------------

-- 2. ONE-HOT ENCODING (Categorical to Numerical)
-- Purpose: Prepare data for ML models by converting roles into binary indicators.
SELECT Entity_ID, 
       CASE WHEN Player_Role = 'Tactical Striker' THEN 1 ELSE 0 END AS Is_Striker,
       CASE WHEN Player_Role = 'Heavy Defender' THEN 1 ELSE 0 END AS Is_Defender
FROM combat_football_train WHERE Entity_ID != 'Entity_ID';

--------------------------------------------------------------------------------

-- 3. COMBAT EXPERIENCE INDEX
-- Purpose: Combine Years of Service and Armor into a custom feature.
SELECT Entity_ID, 
       (CAST(Years_of_Service AS FLOAT) * CAST(Armor_Rating AS FLOAT)) / 100.0 AS Experience_Index
FROM combat_football_train 
WHERE Years_of_Service != '999' AND Years_of_Service != 'Years_of_Service';

--------------------------------------------------------------------------------

-- 4. DATA DRIFT DETECTION
-- Purpose: Compare Mean Power across Train and Test datasets.
SELECT 'Train' as Dataset_Type, AVG(CAST(Combat_Power AS FLOAT)) as Mean_Power 
FROM combat_football_train WHERE Combat_Power != 'Combat_Power'
UNION ALL
SELECT 'Test' as Dataset_Type, AVG(CAST(Combat_Power AS FLOAT)) as Mean_Power 
FROM combat_football_test WHERE Combat_Power != 'Combat_Power';

--------------------------------------------------------------------------------

-- 5. DECILE SEGMENTATION
-- Purpose: Rank players into 10 groups based on Win Probability.
SELECT Entity_ID, Win_Probability, 
       NTILE(10) OVER(ORDER BY CAST(Win_Probability AS FLOAT) DESC) AS Win_Decile
FROM combat_football_train WHERE Win_Probability != 'Win_Probability';

--------------------------------------------------------------------------------

-- 6. MULTIVARIATE ANOMALY DETECTION
-- Purpose: Find suspicious high-power players using standard gear.
SELECT * FROM combat_football_train 
WHERE CAST(Combat_Power AS INT) > 90 
  AND Equipment_Tier LIKE '%Standard%' 
  AND Entity_ID != 'Entity_ID';

--------------------------------------------------------------------------------

-- 7. ROLLING AVERAGE (Performance Smoothing)
-- Purpose: See power trends within each team.
SELECT Entity_ID, Team_Name, Combat_Power,
       AVG(CAST(Combat_Power AS FLOAT)) OVER(PARTITION BY Team_Name ORDER BY Entity_ID ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS Rolling_Avg
FROM combat_football_train WHERE Combat_Power != 'Combat_Power';

--------------------------------------------------------------------------------

-- 8. PERCENTILE RANKING (Tactical IQ Rank)
-- Purpose: Globally rank players based on their intelligence score.
SELECT Entity_ID, Tactical_IQ, 
       PERCENT_RANK() OVER(ORDER BY CAST(Tactical_IQ AS FLOAT)) AS IQ_Percentile
FROM combat_football_train WHERE Tactical_IQ != 'Tactical_IQ';

--------------------------------------------------------------------------------

-- 9. LEADER-GAP ANALYSIS
-- Purpose: Distance between each player and the strongest in their role.
SELECT Entity_ID, Player_Role, Combat_Power, 
       MAX(CAST(Combat_Power AS FLOAT)) OVER(PARTITION BY Player_Role) - CAST(Combat_Power AS FLOAT) AS Gap_To_Leader
FROM combat_football_train WHERE Combat_Power != 'Combat_Power';

--------------------------------------------------------------------------------

-- 10. MISSING DATA PATTERN ANALYSIS
-- Purpose: Percentage of missing Health Integrity records per team.
SELECT Team_Name, 
       SUM(CASE WHEN Health_Integrity IS NULL OR Health_Integrity = '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Missing_Health_Pct
FROM combat_football_train GROUP BY Team_Name;

--------------------------------------------------------------------------------

-- 11. WEIGHT OF EVIDENCE (WoE) SIMULATION
-- Purpose: Statistical strength of battle arenas.
SELECT Battle_Arena, 
       AVG(CAST(Win_Probability AS FLOAT)) / (SELECT AVG(CAST(Win_Probability AS FLOAT)) FROM combat_football_train WHERE Win_Probability != 'Win_Probability') AS Arena_WoE
FROM combat_football_train WHERE Battle_Arena != 'Battle_Arena' GROUP BY Battle_Arena;

--------------------------------------------------------------------------------

-- 12. CLASS BALANCE VERIFICATION
-- Purpose: Check distribution of Archetype Classes to avoid model bias.
SELECT Archetype_Class, COUNT(*) as Frequency,
       COUNT(*) * 1.0 / (SELECT COUNT(*) FROM combat_football_train WHERE Archetype_Class != 'Archetype_Class') as Class_Ratio
FROM combat_football_train WHERE Archetype_Class != 'Archetype_Class' GROUP BY Archetype_Class;

--------------------------------------------------------------------------------

-- 13. DATA BINNING (Aggression Levels)
-- Purpose: Categorize continuous index into Tactical Classes.
SELECT Entity_ID, 
       CASE WHEN CAST(Aggression_Index AS FLOAT) < 0.3 THEN 'Strategic' 
            WHEN CAST(Aggression_Index AS FLOAT) < 0.7 THEN 'Balanced' 
            ELSE 'Berserker' END AS Tactical_Class
FROM combat_football_train WHERE Aggression_Index != 'Aggression_Index';

--------------------------------------------------------------------------------

-- 14. TEAM CONSISTENCY (Variance Analysis)
-- Purpose: Identify which teams have the most spread-out power levels.
SELECT Team_Name, 
       AVG(CAST(Combat_Power AS FLOAT)*CAST(Combat_Power AS FLOAT)) - (AVG(CAST(Combat_Power AS FLOAT))*AVG(CAST(Combat_Power AS FLOAT))) as Power_Variance
FROM combat_football_train WHERE Combat_Power != 'Combat_Power' GROUP BY Team_Name;

--------------------------------------------------------------------------------

-- 15. MODEL-READY CLEANING (Imputation)
-- Purpose: Handle nulls and fix outliers (Years_of_Service) for the final model.
SELECT Entity_ID, Team_Name,
       COALESCE(NULLIF(Health_Integrity, ''), '50.0') as Imputed_Health,
       CASE WHEN Years_of_Service = '999' THEN '0' ELSE Years_of_Service END as Normalized_Years
FROM combat_football_train WHERE Entity_ID != 'Entity_ID';

--------------------------------------------------------------------------------

-- 16. EXPECTED TACTICAL VALUE (ETV)
-- Purpose: Projected success value based on combat power.
SELECT Team_Name, SUM(CAST(Combat_Power AS FLOAT) * CAST(Win_Probability AS FLOAT)) as Team_ETV
FROM combat_football_train WHERE Combat_Power != 'Combat_Power' GROUP BY Team_Name;

--------------------------------------------------------------------------------

-- 17. COVARIANCE CALCULATION
-- Purpose: Measure relationship between Combat Power and Win Probability.
SELECT (AVG(CAST(Combat_Power AS FLOAT) * CAST(Win_Probability AS FLOAT)) - AVG(CAST(Combat_Power AS FLOAT)) * AVG(CAST(Win_Probability AS FLOAT))) as Power_Win_Covariance
FROM combat_football_train WHERE Combat_Power != 'Combat_Power';

--------------------------------------------------------------------------------

-- 18. DATA UNIQUENESS CHECK
-- Purpose: Integrity check for duplicate IDs.
SELECT Entity_ID, COUNT(*) FROM combat_football_train GROUP BY Entity_ID HAVING COUNT(*) > 1;

--------------------------------------------------------------------------------

-- 19. CLUSTERING FEATURE AGGREGATION
-- Purpose: Extract mean features for K-Means clustering.
SELECT Team_Name, 
       AVG(CAST(Combat_Power AS FLOAT)) as Mean_Power, 
       AVG(CAST(Tactical_IQ AS FLOAT)) as Mean_IQ, 
       AVG(CAST(Armor_Rating AS FLOAT)) as Mean_Armor
FROM combat_football_train WHERE Combat_Power != 'Combat_Power' GROUP BY Team_Name;

--------------------------------------------------------------------------------

-- 20. GLOBAL DATA INTEGRITY SCORE
-- Purpose: Quantify the overall completeness of the dataset.
SELECT (COUNT(NULLIF(Health_Integrity, '')) * 1.0 / COUNT(*)) as Integrity_Score
FROM combat_football_train WHERE Entity_ID != 'Entity_ID';
