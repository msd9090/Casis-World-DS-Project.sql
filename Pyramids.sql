-- ============================================
-- Advanced SQL Analysis on tourism_data (SQLite)
-- ============================================

-- Table Schema Assumption:
-- tourism_data(
-- Pyramid_Name, Visitor_Country, Season,
-- Ticket_Cost, Visitors_Per_Year, Avg_Rating, Temperature,
-- Waiting_Time_Min, Spending_USD, Hotels_Nearby, Restaurants_Nearby,
-- Transport_Score, Safety_Score, Cleanliness_Score, Guide_Score,
-- Revisit_Prob, Liked
-- )

---

-- 1. Average rating per pyramid
-- This query calculates the average visitor rating for each pyramid.
SELECT Pyramid_Name, AVG(Avg_Rating) AS avg_rating
FROM tourism_data
GROUP BY Pyramid_Name
ORDER BY avg_rating DESC;

---

-- 2. Top visiting countries
-- Counts how many visitors come from each country.
SELECT Visitor_Country, COUNT(*) AS total_visitors
FROM tourism_data
GROUP BY Visitor_Country
ORDER BY total_visitors DESC;

---

-- 3. Average spending per season
-- Shows how much tourists spend on average in each season.
SELECT Season, AVG(Spending_USD) AS avg_spending
FROM tourism_data
GROUP BY Season;

---

-- 4. Rating vs revisit probability
-- Analyzes how rating affects probability of returning.
SELECT Avg_Rating, AVG(Revisit_Prob) AS avg_revisit
FROM tourism_data
GROUP BY Avg_Rating
ORDER BY Avg_Rating;

---

-- 5. Top 5 highest spenders
-- Retrieves top 5 records with highest tourist spending.
SELECT *
FROM tourism_data
ORDER BY Spending_USD DESC
LIMIT 5;

---

-- 6. Average waiting time per pyramid
-- Measures congestion by pyramid.
SELECT Pyramid_Name, AVG(Waiting_Time_Min) AS avg_wait
FROM tourism_data
GROUP BY Pyramid_Name;

---

-- 7. Overall like ratio
-- Calculates percentage of visitors who liked the experience.
SELECT
SUM(Liked) * 1.0 / COUNT(*) AS like_ratio
FROM tourism_data;

---

-- 8. Safety score impact on satisfaction
-- Shows how safety affects whether visitors liked the experience.
SELECT Safety_Score, AVG(Liked) AS like_rate
FROM tourism_data
GROUP BY Safety_Score
ORDER BY Safety_Score;

---

-- 9. Top 5 countries by average rating
-- Identifies countries with the highest satisfaction.
SELECT Visitor_Country, AVG(Avg_Rating) AS avg_rating
FROM tourism_data
GROUP BY Visitor_Country
ORDER BY avg_rating DESC
LIMIT 5;

---

-- 10. Season + Pyramid performance
-- Combines seasonality and pyramid performance.
SELECT Season, Pyramid_Name, AVG(Avg_Rating) AS avg_rating
FROM tourism_data
GROUP BY Season, Pyramid_Name;

---

-- 11. Covariance (Transport vs Rating)
-- Estimates relationship between transport quality and rating.
SELECT
AVG(Transport_Score * Avg_Rating) -
AVG(Transport_Score) * AVG(Avg_Rating) AS covariance
FROM tourism_data;

---

-- 12. Above-average spenders
-- Finds visitors who spent more than average.
SELECT *
FROM tourism_data
WHERE Spending_USD > (SELECT AVG(Spending_USD) FROM tourism_data);

---

-- 13. Rating distribution
-- Categorizes ratings into High / Medium / Low.
SELECT
CASE
WHEN Avg_Rating >= 4 THEN 'High'
WHEN Avg_Rating >= 3 THEN 'Medium'
ELSE 'Low'
END AS rating_category,
COUNT(*) AS count
FROM tourism_data
GROUP BY rating_category;

---

-- 14. Top 3 countries per pyramid (Window Function)
-- Finds most frequent visitor origins per pyramid.
SELECT *
FROM (
SELECT
Pyramid_Name,
Visitor_Country,
COUNT(*) AS visit_count,
RANK() OVER (
PARTITION BY Pyramid_Name
ORDER BY COUNT(*) DESC
) AS rank_num
FROM tourism_data
GROUP BY Pyramid_Name, Visitor_Country
)
WHERE rank_num <= 3;

---

-- 15. Compare liked vs not liked
-- Compares features between satisfied and unsatisfied visitors.
SELECT
Liked,
AVG(Avg_Rating) AS avg_rating,
AVG(Safety_Score) AS avg_safety,
AVG(Transport_Score) AS avg_transport
FROM tourism_data
GROUP BY Liked;

---

-- 16. Worst experience cases
-- High waiting time with low rating.
SELECT *
FROM tourism_data
ORDER BY Waiting_Time_Min DESC, Avg_Rating ASC
LIMIT 10;

---

-- 17. Revisit probability by country
-- Measures loyalty by country.
SELECT Visitor_Country, AVG(Revisit_Prob) AS revisit_rate
FROM tourism_data
GROUP BY Visitor_Country;

---

-- 18. Hotels impact on rating
-- Analyzes whether more hotels improve experience.
SELECT Hotels_Nearby, AVG(Avg_Rating) AS avg_rating
FROM tourism_data
GROUP BY Hotels_Nearby
ORDER BY Hotels_Nearby;

---

-- 19. High rating but disliked
-- Detects anomalies in user feedback.
SELECT *
FROM tourism_data
WHERE Avg_Rating >= 4 AND Liked = 0;

---

-- 20. Create analytical view
-- Creates a reusable filtered dataset.
CREATE VIEW high_quality_visits AS
SELECT *
FROM tourism_data
WHERE Avg_Rating > 4 AND Safety_Score > 7;

-- ============================================
-- End of Advanced SQL Practice Set
-- ============================================
