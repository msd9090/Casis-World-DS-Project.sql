/* 1. Missing Prices Imputation (Smart Averaging) */
SELECT C1, C2, C3,
       COALESCE(C6, AVG(C6) OVER(PARTITION BY C3)) AS imputed_price
FROM egypt_food_train;

/* 2. Manual Z-Score for Outlier Detection (Price C6) */
WITH Stats AS (
    SELECT AVG(C6) as mean_p, 
           SQRT(AVG(C6*C6) - AVG(C6)*AVG(C6)) as std_p 
    FROM egypt_food_train
)
SELECT *, (C6 - mean_p) / NULLIF(std_p, 0) as z_score 
FROM egypt_food_train, Stats 
WHERE ABS((C6 - mean_p) / NULLIF(std_p, 0)) > 3;

/* 3. Manual String Cleaning (Region C5) */
SELECT C1, C5,
       UPPER(CASE WHEN INSTR(C5, '_') > 0 
             THEN SUBSTR(C5, 1, INSTR(C5, '_') - 1) 
             ELSE C5 END) AS clean_region
FROM egypt_food_train;

/* 4. Top Popular Ingredients (Mode) per Region */
SELECT C5, C4, freq
FROM (
    SELECT C5, C4, COUNT(*) as freq,
           RANK() OVER(PARTITION BY C5 ORDER BY COUNT(*) DESC) as rnk
    FROM egypt_food_train
    GROUP BY C5, C4
) t WHERE rnk = 1;

/* 5. Data Binning (Price Quantiles) */
SELECT C1, C6, 
       NTILE(5) OVER(ORDER BY C6) AS price_bucket
FROM egypt_food_train
WHERE C6 IS NOT NULL;

/* 6. Gap Analysis in IDs (Sequence Check) */
SELECT C1, next_id, (next_id - C1) as gap
FROM (
    SELECT C1, LEAD(C1) OVER(ORDER BY C1) as next_id
    FROM egypt_food_train
) t WHERE (next_id - C1) > 1;

/* 7. Data Integrity Audit (Sales Sum Validation) */
SELECT 
    SUM(C12) AS current_sum,
    (SELECT SUM(C12) FROM egypt_food_train) AS global_sum,
    CASE WHEN SUM(C12) = (SELECT SUM(C12) FROM egypt_food_train) 
         THEN 'MATCH' ELSE 'MISMATCH' END AS audit_status
FROM egypt_food_train;

/* 8. 7-Day Moving Average for Sales (Trends) */
SELECT C1, C2, C12,
       AVG(C12) OVER(ORDER BY C1 ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as moving_avg
FROM egypt_food_train;

/* 9. Caloric Density Feature Engineering */
SELECT C2, (CAST(C7 AS FLOAT) / NULLIF(C6, 0)) AS calorie_density
FROM egypt_food_train
WHERE C6 > 0 AND C7 IS NOT NULL;

/* 10. Customer Retention (Repeat Orders) */
SELECT C16, C2, COUNT(*) as repeat_count
FROM egypt_food_train
GROUP BY C16, C2
HAVING COUNT(*) > 1;

/* 11. Category Price Variance (Manual Calculation) */
SELECT C3, AVG(C6*C6) - AVG(C6)*AVG(C6) AS manual_variance
FROM egypt_food_train
GROUP BY C3;

/* 12. Cross-Field Integrity (Vegetarian Logic Check) */
SELECT * FROM egypt_food_train
WHERE C9 = 1 AND (C4 LIKE '%Meat%' OR C4 LIKE '%Chicken%');

/* 13. Pareto Analysis (Top 80% Revenue Dishes) */
WITH RankedSales AS (
    SELECT C2, SUM(C12) as sales,
           SUM(SUM(C12)) OVER(ORDER BY SUM(C12) DESC) / (SELECT SUM(C12) FROM egypt_food_train) as ratio
    FROM egypt_food_train
    GROUP BY C2
)
SELECT * FROM RankedSales WHERE ratio <= 0.80;

/* 14. Regional Market Share Percentage */
SELECT C5, 
       ROUND(SUM(C12) * 100.0 / (SELECT SUM(C12) FROM egypt_food_train), 2) || '%' as market_share
FROM egypt_food_train
GROUP BY C5;

/* 15. Ordinal Encoding for Spiciness (C13) */
SELECT C1, C13,
       CASE WHEN UPPER(C13) = 'LOW' THEN 1
            WHEN UPPER(C13) = 'MEDIUM' THEN 2
            WHEN UPPER(C13) = 'HIGH' THEN 3 ELSE 0 END as spice_score
FROM egypt_food_train;

/* 16. Cleaning Priority Score (Data Profiling) */
SELECT C1, 
       ((C6 IS NULL) + (C7 IS NULL) + (C5 LIKE '%_%')) AS clean_score
FROM egypt_food_train
ORDER BY clean_score DESC;

/* 17. Identifying Logical Duplicates */
SELECT C2, C16, C12, COUNT(*) 
FROM egypt_food_train 
GROUP BY C2, C16, C12 
HAVING COUNT(*) > 1;

/* 18. Restaurant Class Benchmarking (Rating C8) */
SELECT C2, C11, C8,
       C8 - AVG(C8) OVER(PARTITION BY C11) as performance_gap
FROM egypt_food_train;

/* 19. Cumulative Sales Percentage */
SELECT C1, C12,
       SUM(C12) OVER(ORDER BY C1) * 100.0 / (SELECT SUM(C12) FROM egypt_food_train) as running_pct
FROM egypt_food_train;

/* 20. Submission Consistency Check */
SELECT COUNT(*) as valid_rows
FROM egypt_food_submission
WHERE C1 IN (SELECT C1 FROM egypt_food_test);
