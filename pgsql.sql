select * from walmart

Business Problems
---Q.1 Find different payment method and number of transactions, number of qty sold

SELECT payment_method,SUM(quantity) AS quantity_sold,
COUNT(*) AS no_of_transactions
FROM walmart
GROUP BY payment_method

-- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
WITH highest_rated_category AS
(
SELECT category,branch,
AVG(rating) as average_rating,
RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC)AS rank_category
FROM walmart
GROUP BY category,branch
) 
SELECT * 
FROM highest_rated_category
WHERE rank_category=1

-- Q.3 Identify the busiest day for each branch based on the number of transactions
WITH Busiest_Day AS
(
SELECT branch,
TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') AS Day_Name,
COUNT(*) AS No_Of_Transactions,
RANK()OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY 1,2
)
SELECT * 
FROM Busiest_Day
WHERE rank=1


-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
SELECT 
	 payment_method,
	 -- COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating

SELECT category,city,
AVG(rating) as average_rating,
MIN(rating) as min_rating,
MAX(rating) as max_rating
FROM walmart
GROUP BY 1,2

-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT category,
SUM(total_amount) AS total_revenue,
SUM(unit_price * quantity * profit_margin) as total_profit
FROM walmart
GROUP BY 1

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
WITH common_payment
AS
(
SELECT branch,payment_method,
COUNT(*) AS total_tras,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC ) AS rank
FROM walmart
GROUP BY 1,2
)
SELECT * 
FROM common_payment
WHERE rank=1


-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
SELECT branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time
FROM walmart
GROUP BY 1,2

-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100



WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total_amount) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total_amount) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5