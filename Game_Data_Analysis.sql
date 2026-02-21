-- 1. Using Common Table Expressions (CTE) for cleaner logic
-- Purpose: Isolates high-level players to simplify further analysis without using nested subqueries.
WITH HighLevelPlayers AS (
    SELECT Player_ID, XP_Total FROM Cosmic_Blocks WHERE Player_Level > 90
)
SELECT * FROM HighLevelPlayers WHERE XP_Total > 1000000;

-- 2. Smart Null Handling with COALESCE
-- Purpose: Replaces missing values (NaN) with 0 to prevent calculation errors in the model.
SELECT Player_ID, COALESCE(Mana_Remaining, 0) as Adjusted_Mana 
FROM Cosmic_Blocks;

-- 3. Calculating Z-Score to Detect Outliers
-- Purpose: Identifies extreme values (Whales or AFK) by calculating how many standard deviations a value is from the mean.
SELECT Player_ID, Gold_Balance,
       (Gold_Balance - avg_gold) / stddev_gold as z_score
FROM Cosmic_Blocks, 
     (SELECT AVG(Gold_Balance) as avg_gold, STDEV(Gold_Balance) as stddev_gold FROM Cosmic_Blocks);

-- 4. Data Binning (Quantiles) using NTILE
-- Purpose: Divides the 100,000 players into 4 equal groups (Quartiles) based on their XP.
SELECT Player_ID, XP_Total, NTILE(4) OVER (ORDER BY XP_Total DESC) as XP_Tier
FROM Cosmic_Blocks;

-- 5. Ranking within Regions (Window Function)
-- Purpose: Ranks players by XP within each specific Save Zone/Region.
SELECT Player_ID, Save_Region, XP_Total,
       RANK() OVER (PARTITION BY Save_Region ORDER BY XP_Total DESC) as Region_Rank
FROM Cosmic_Blocks;

-- 6. Logical Data Validation
-- Purpose: Finds data corruption where a high-level player has suspiciously low XP.
SELECT Player_ID FROM Cosmic_Blocks 
WHERE Player_Level > 50 AND XP_Total < 1000;

-- 7. Simple Moving Average (SMA)
-- Purpose: Analyzes play patterns by averaging playtime across rows to smooth out fluctuations.
SELECT Player_ID, Playtime_Hours,
       AVG(Playtime_Hours) OVER (ORDER BY Player_ID ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) as SMA_5
FROM Cosmic_Blocks;

-- 8. Manual One-Hot Encoding (CASE Statement)
-- Purpose: Converts categorical text data (Device_Type) into binary numbers for Machine Learning.
SELECT Player_ID,
       CASE WHEN Device_Type = 'PC' THEN 1 ELSE 0 END as Is_PC,
       CASE WHEN Device_Type = 'Mobile' THEN 1 ELSE 0 END as Is_Mobile
FROM Cosmic_Blocks;

-- 9. Identifying the "Top 1%" (Whales)
-- Purpose: Selects players whose gold balance is higher than the 99th percentile.
SELECT Player_ID, Gold_Balance 
FROM Cosmic_Blocks 
WHERE Gold_Balance > (SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY Gold_Balance) FROM Cosmic_Blocks);

-- 10. Pivot Table Simulation (Conditional Aggregation)
-- Purpose: Summarizes device distribution across different difficulty levels in one row.
SELECT Difficulty,
       COUNT(CASE WHEN Device_Type = 'PC' THEN 1 END) as PC_Count,
       COUNT(CASE WHEN Device_Type = 'Console' THEN 1 END) as Console_Count
FROM Cosmic_Blocks GROUP BY Difficulty;

-- 11. Efficient Filtering with EXISTS
-- Purpose: Faster alternative to the "IN" clause for large datasets (100k+ rows).
SELECT * FROM Cosmic_Blocks t1
WHERE EXISTS (SELECT 1 FROM High_Score_Table t2 WHERE t1.Player_ID = t2.Player_ID);

-- 12. Cumulative Sum (Running Total)
-- Purpose: Calculates the total gold accumulated across all player IDs progressively.
SELECT Player_ID, Gold_Balance,
       SUM(Gold_Balance) OVER (ORDER BY Player_ID) as Running_Total_Gold
FROM Cosmic_Blocks;

-- 13. Gap Analysis (Missing IDs)
-- Purpose: Identifies missing numbers in the sequence of Player_IDs to check for data loss.
SELECT Player_ID + 1 FROM Cosmic_Blocks mo
WHERE NOT EXISTS (SELECT NULL FROM Cosmic_Blocks mi WHERE mi.Player_ID = mo.Player_ID + 1);

-- 14. Conditional Non-Equi Join
-- Purpose: Joins a rewards table based on a range (Player_Level >= Min_Level) instead of an exact match.
SELECT a.*, b.Reward_Name 
FROM Cosmic_Blocks a
LEFT JOIN Rewards b ON a.Player_Level >= b.Min_Level;

-- 15. Statistical Correlation Calculation
-- Purpose: Measures the relationship strength between Enemies Killed and Bosses Defeated.
SELECT (AVG(Enemies_Killed * Bosses_Defeated) - AVG(Enemies_Killed) * AVG(Bosses_Defeated)) / 
       (STDEV(Enemies_Killed) * STDEV(Bosses_Defeated)) as Correlation
FROM Cosmic_Blocks;

-- 16. Recursive CTE (Growth Hierarchy)
-- Purpose: Navigates mentor-apprentice relationships to map a player's social tree.
WITH RECURSIVE Hierarchy AS (
    SELECT Mentor_ID, Apprentice_ID FROM Players_Rel
    UNION ALL
    SELECT h.Mentor_ID, p.Apprentice_ID FROM Hierarchy h JOIN Players_Rel p ON h.Apprentice_ID = p.Mentor_ID
)
SELECT * FROM Hierarchy;

-- 17. Stratified Random Sampling
-- Purpose: Takes a balanced sample of 100 rows per "Outcome" to avoid bias in the test set.
SELECT * FROM (
  SELECT *, ROW_NUMBER() OVER(PARTITION BY Game_Outcome ORDER BY RANDOM()) as rn
  FROM Cosmic_Blocks
) WHERE rn <= 100;

-- 18. Deduplication (Row Removal)
-- Purpose: Keeps only one record for each Player_ID, deleting accidental duplicates.
DELETE FROM Cosmic_Blocks 
WHERE rowid NOT IN (SELECT MIN(rowid) FROM Cosmic_Blocks GROUP BY Player_ID);

-- 19. Full Outer Join Emulation
-- Purpose: Combines all records from two tables even when no match exists (Workaround for SQLite).
SELECT * FROM TableA LEFT JOIN TableB ON TableA.id = TableB.id
UNION
SELECT * FROM TableA RIGHT JOIN TableB ON TableA.id = TableB.id;

-- 20. Conditional Partial Indexing
-- Purpose: Optimizes query speed by indexing only "Active" players, reducing index size.
CREATE INDEX idx_active_players ON Cosmic_Blocks (Player_Level, XP_Total) WHERE Game_Outcome = 'Active';
