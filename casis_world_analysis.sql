/*******************************************************************************
   Project: Hybrid Ninja & Data Science Analysis
   Author: Mahmoud Saad
   Dataset: train.csv (70,000 Rows, 16 Columns)
   Description: Senior-Level SQL Portfolio for Data Cleaning and Advanced Analytics.
*******************************************************************************/

-- =============================================================================
-- PHASE 1: DATA QUALITY & INTEGRITY (CLEANING THE TRAPS)
-- =============================================================================

-- 1. Identifying Outliers in Experience Points
-- Uses Z-Score logic to find extreme values (like 888,888) that disrupt training.
SELECT * FROM train
WHERE ABS(Experience_Points - (SELECT AVG(Experience_Points) FROM train)) > 
      (3 * (SELECT STDEV(Experience_Points) FROM train));

-- 2. Contextual Health Imputation
-- Replaces NULL values in Health_Status with the average of the same Experience_Level.
SELECT Entity_ID, Experience_Level, 
       COALESCE(Health_Status, AVG(Health_Status) OVER(PARTITION BY Experience_Level)) AS Clean_Health
FROM train;

-- 3. Uniqueness and Integrity Check
-- Ensures no duplicate Entity_IDs exist in the 70k dataset.
SELECT Entity_ID, COUNT(*) 
FROM train 
GROUP BY Entity_ID 
HAVING COUNT(*) > 1;

-- 4. Tracking Data Corruption (Data Void Error)
-- Identifies which DL Frameworks are most associated with corrupted archetype labels.
SELECT DL_Framework, COUNT(*) AS Error_Count
FROM train
WHERE Archetype = 'DATA_VOID_ERROR'
GROUP BY DL_Framework;

-- 5. Range Constraint Validation
-- Ensures Success_Probability remains within the logical 0 to 1 boundaries.
SELECT * FROM train 
WHERE Success_Probability < 0 OR Success_Probability > 1;


-- =============================================================================
-- PHASE 2: ADVANCED TECH STACK ANALYTICS
-- =============================================================================

-- 6. Python-PyTorch Synergy Score
-- Calculates the average success when combining Python with PyTorch across all Realms.
SELECT Realm, AVG(Success_Probability) AS Synergy_Win_Rate
FROM train
WHERE Programming_Language = 'Python' AND DL_Framework = 'PyTorch'
GROUP BY Realm
ORDER BY Synergy_Win_Rate DESC;

-- 7. Power-to-Stamina Efficiency
-- Identifies the most efficient entities by calculating the Mana/Stamina ratio.
SELECT Entity_ID, (Mana_Level / NULLIF(Stamina, 0)) AS Efficiency_Ratio
FROM train
WHERE Stamina > 0
ORDER BY Efficiency_Ratio DESC LIMIT 100;

-- 8. Ranking Top Viz Experts per Level
-- Finds the top 3 entities with the highest Mana for each Experience_Level.
SELECT * FROM (
    SELECT *, RANK() OVER(PARTITION BY Experience_Level ORDER BY Mana_Level DESC) AS Rank
    FROM train
) WHERE Rank <= 3;

-- 9. Model Architecture Performance
-- Analyzes which Architecture (Transformer, CNN, etc.) is most successful in Lava_Core.
SELECT Model_Architecture, AVG(Success_Probability) AS Performance
FROM train
WHERE Realm = 'Lava_Core'
GROUP BY Model_Architecture
ORDER BY Performance DESC;

-- 10. Mana Level Quartile Segmentation
-- Segments the 70,000 entities into 4 equal groups for performance tiering.
SELECT Entity_ID, Mana_Level, NTILE(4) OVER(ORDER BY Mana_Level) AS Mana_Quartile
FROM train;


-- =============================================================================
-- PHASE 3: DEEP STATISTICAL INSIGHTS
-- =============================================================================

-- 11. Success Correlation by Mana Buckets
-- Groups Mana values into 100-point buckets to see the correlation with Success.
SELECT ROUND(Mana_Level, -2) AS Mana_Bucket, AVG(Success_Probability) AS Success_Trend
FROM train 
GROUP BY 1 ORDER BY 1;

-- 12. Identifying "Underdog" Entities
-- Filters for characters with Low Health (<15) but very High Success (>0.85).
SELECT * FROM train 
WHERE Health_Status < 15 AND Success_Probability > 0.85;

-- 13. Synergy: Abilities & Spirit Animals
-- Analyzes the performance of Special Abilities when paired with specific animals.
SELECT Special_Ability, Spirit_Animal, AVG(Success_Probability) as Synergy_Score
FROM train
GROUP BY 1, 2
HAVING COUNT(*) > 50;

-- 14. Cumulative Performance Tracking
-- Tracks the running total of Success across the Entity_ID sequence.
SELECT Entity_ID, Success_Probability, 
       SUM(Success_Probability) OVER(ORDER BY Entity_ID) AS Running_Total
FROM train;

-- 15. Tech-Diversity Score per Realm
-- Ranks realms by the number of unique combinations of Language + Framework.
SELECT Realm, COUNT(DISTINCT Programming_Language || DL_Framework) AS Tech_Diversity
FROM train
GROUP BY Realm;


-- =============================================================================
-- PHASE 4: SENIOR REPORTING & DRIFT ANALYSIS
-- =============================================================================

-- 16. Train-Test Distribution Drift
-- Compares Model Architecture percentages between train and test to ensure consistency.
SELECT Model_Architecture, (COUNT(*) * 100.0 / 70000) AS Pct FROM train GROUP BY 1
UNION ALL
SELECT Model_Architecture, (COUNT(*) * 100.0 / 30000) AS Pct FROM test GROUP BY 1;

-- 17. The "Elite Architect" Filter
-- Extracts Lead/Architect level entities using Julia/C++ with Success > 0.9.
SELECT * FROM train
WHERE Experience_Level IN ('Lead', 'Architect')
  AND Programming_Language IN ('Julia', 'C++')
  AND Success_Probability > 0.9;

-- 18. Simulated Performance Impact
-- Simulates the effect of a 20% Mana boost for all RNN model users.
SELECT Model_Architecture, 
       AVG(CASE WHEN Model_Architecture = 'RNN' THEN Success_Probability * 1.2 ELSE Success_Probability END) AS Sim_Success
FROM train GROUP BY Model_Architecture;

-- 19. Experience Gap Analysis (Lag)
-- Detects abnormal jumps in Experience_Points between consecutive entities.
SELECT Entity_ID, Experience_Points, 
       Experience_Points - LAG(Experience_Points) OVER(ORDER BY Entity_ID) AS Exp_Gap
FROM train LIMIT 100;

-- 20. MASTER TECHNICAL SUMMARY
-- The final executive summary, cleaning outliers and corrupted data on the fly.
SELECT 
    Programming_Language, 
    DL_Framework, 
    COUNT(*) AS Total_Users, 
    AVG(Mana_Level) AS Avg_Energy, 
    AVG(Success_Probability) AS Final_Score
FROM train
WHERE Archetype != 'DATA_VOID_ERROR' 
  AND Experience_Points BETWEEN 0 AND 20000
GROUP BY Programming_Language, DL_Framework
ORDER BY Final_Score DESC;
