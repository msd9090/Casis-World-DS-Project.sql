/* SQLITE TRAINING SCRIPT FOR B.LABAN DATASET
   Expert Data Scientist Level - 20 Professional Queries
*/

-- 1. Categorize transactions based on sales volume
SELECT Transaction_ID, Total_Sales,
CASE 
  WHEN Total_Sales > 500 THEN 'High Value'
  WHEN Total_Sales BETWEEN 200 AND 500 THEN 'Mid Value'
  ELSE 'Low Value' 
END AS Category_Level
FROM train_data;

-- 2. Calculate Net Profit after deducting Tax and Discounts
SELECT Transaction_ID, 
(Total_Sales - Tax_Amount) * (1 - Discount_Rate) AS Net_Profit 
FROM train_data;

-- 3. Find branches with the most generous average discount rates
SELECT Branch, AVG(Discount_Rate) * 100 AS Avg_Discount_Percent
FROM train_data 
GROUP BY Branch 
ORDER BY Avg_Discount_Percent DESC;

-- 4. Analyze average spending habits across different generations (Age Groups)
SELECT 
CASE WHEN Customer_Age < 20 THEN 'Gen Z' 
     WHEN Customer_Age BETWEEN 20 AND 40 THEN 'Millennials'
     ELSE 'Senior' END AS Age_Group,
AVG(Total_Sales) AS Avg_Spend
FROM train_data
WHERE Customer_Age IS NOT NULL
GROUP BY Age_Group;

-- 5. Identify "Loyal Customers" who visited more than 5 times
SELECT Customer_ID, COUNT(*) AS Visit_Count, SUM(Total_Sales) AS Total_Spent
FROM train_data
GROUP BY Customer_ID
HAVING Visit_Count > 5
ORDER BY Total_Spent DESC;

-- 6. Determine the most popular payment method in each geographical region
SELECT Region, Payment_Method, COUNT(*) AS Method_Usage
FROM train_data
GROUP BY Region, Payment_Method
ORDER BY Region, Method_Usage DESC;

-- 7. Rank top products sold during the night shift (8 PM to Midnight)
SELECT Product_Name, SUM(Total_Sales) AS Night_Sales
FROM train_data
WHERE Hour_of_Day >= 20
GROUP BY Product_Name
ORDER BY Night_Sales DESC;

-- 8. Examine the impact of high heat (>35°C) specifically on Qishtouza sales
SELECT Product_Name, AVG(Quantity) AS Avg_Qty_Sold
FROM train_data
WHERE Temperature_Celsius > 35 AND Product_Name LIKE '%Qishtouza%'
GROUP BY Product_Name;

-- 9. Compare the total revenue generated in Morning vs. Evening shifts
SELECT 
CASE WHEN Hour_of_Day < 12 THEN 'Morning' ELSE 'Evening' END AS Shift,
SUM(Total_Sales) AS Sales_Volume
FROM train_data
GROUP BY Shift;

-- 10. Flag high-revenue branches that suffer from poor customer ratings
SELECT Branch, AVG(Store_Rating) AS Avg_Rate, SUM(Total_Sales) AS Revenue
FROM train_data
GROUP BY Branch
HAVING Avg_Rate < 3 AND Revenue > 10000;

-- 11. Monitor staff efficiency by comparing orders handled to delivery speed
SELECT Staff_ID, COUNT(*) AS Orders_Handled, AVG(Delivery_Time_Min) AS Speed
FROM train_data
GROUP BY Staff_ID
ORDER BY Speed ASC;

-- 12. Determine if long delivery distances negatively impact customer satisfaction
SELECT 
CASE WHEN Delivery_Distance_KM > 10 THEN 'Far' ELSE 'Near' END AS Distance_Range,
AVG(Store_Rating) AS Avg_Rating
FROM train_data
GROUP BY Distance_Range;

-- 13. List the top 3 most trending products at the Mansoura branch
SELECT Product_Name, COUNT(*) AS Popularity
FROM train_data
WHERE Branch = 'Mansoura-Mashaya'
GROUP BY Product_Name
ORDER BY Popularity DESC LIMIT 3;

-- 14. Identify the most frequent Topping choices for Rice Pudding items
SELECT Topping_Type, COUNT(*) AS Topping_Count
FROM train_data
WHERE Product_Name LIKE '%Rice Pudding%'
GROUP BY Topping_Type
ORDER BY Topping_Count DESC;

-- 15. Calculate the percentage share of total company revenue for each branch
SELECT Branch, SUM(Total_Sales) * 100.0 / (SELECT SUM(Total_Sales) FROM train_data) AS Revenue_Share_Percent
FROM train_data
GROUP BY Branch;

-- 16. Extract transactions that exceeded the average sales of their own branch
SELECT t1.Transaction_ID, t1.Branch, t1.Total_Sales
FROM train_data t1
WHERE t1.Total_Sales > (SELECT AVG(Total_Sales) FROM train_data t2 WHERE t2.Branch = t1.Branch);

-- 17. Analyze logistics for long-distance deliveries (>12 KM) by region
SELECT Region, COUNT(*) AS Long_Distance_Orders, AVG(Total_Sales) as Avg_Rev
FROM train_data 
WHERE Delivery_Distance_KM > 12 
GROUP BY Region;

-- 18. Find products that are common between Dubai and Cairo branches
SELECT Product_Name FROM train_data WHERE Branch = 'Dubai-Marina'
INTERSECT
SELECT Product_Name FROM train_data WHERE Branch = 'Cairo-Nasr City';

-- 19. Estimate total tax revenue lost due to promotional discounts
SELECT SUM((Unit_Price * Quantity * Discount_Rate) * 0.14) AS Lost_Tax_Revenue
FROM train_data;

-- 20. Simple listing of product names and their average ratings
SELECT Product_Name, AVG(Store_Rating) AS Average_Rating
FROM train_data
GROUP BY Product_Name;
