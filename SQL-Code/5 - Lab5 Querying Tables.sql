-- Name: Ali Abbas Ladha



1. List the top 3 states by total volume of dollar sales in the "Accessories" product line.


-- Need to remove outliers:
	/*
	SELECT *
	FROM product
	WHERE product_line = 'Accessories'
	
	
	SELECT state_province, SUM(p.product_price * ol.quantity) , p.product_name, ol.order_id, ol.quantity, p.product_line
	FROM customer c 
	LEFT JOIN order_header oh 
	ON c.customer_id = oh.customer_id 
	LEFT JOIN order_line ol
	ON oh.order_id = ol.order_id 
	LEFT JOIN product p
	ON ol.product_id = p.product_id
	WHERE p.product_line = 'Accessories' AND state_province = 'Indiana'
	GROUP BY state_province, p.product_name, ol.order_id, ol.quantity, p.product_line
	ORDER BY quantity DESC;
	*/

-- outlier found Indiana for water Bottle order id 66829. Quantity is 100,0000
-- filtering to quantity < 10 to remove the outlier


SELECT state_province, SUM(p.product_price * ol.quantity) AS total_volume_of_dollar_sales
FROM customer c 
LEFT JOIN order_header oh 
ON c.customer_id = oh.customer_id 
LEFT JOIN order_line ol
ON oh.order_id = ol.order_id 
LEFT JOIN product p
ON ol.product_id = p.product_id
WHERE p.product_line = 'Accessories'
AND ol.quantity < 10
GROUP BY state_province
ORDER BY total_volume_of_dollar_sales DESC
LIMIT 3;




2. Create a seasonality report with "Winter", "Spring", "Summer", "Fall",  as the seasons. 
List the season, order_type, product line, total quantity, and total dollar amount of sales.  
Sort by product line and then season in chronological order ("Winter", "Spring", "Summer", "Fall").  
You do not need to include the year.  

SELECT 
  CASE 
    WHEN EXTRACT(MONTH FROM oh.order_date) IN (12, 1, 2) THEN '1-Winter'
    WHEN EXTRACT(MONTH FROM oh.order_date) IN (3, 4, 5) THEN '2-Spring'
    WHEN EXTRACT(MONTH FROM oh.order_date) IN (6, 7, 8) THEN '3-Summer'
    ELSE '4-Fall'
  END AS season,
  oh.order_type, 
  p.product_line, 
  SUM(ol.quantity) AS total_quantity, 
  SUM(ol.quantity * p.product_price) AS total_sales
FROM order_line ol
INNER JOIN product p ON ol.product_id = p.product_id
INNER JOIN order_header oh ON ol.order_id = oh.order_id
INNER JOIN customer c ON oh.customer_id = c.customer_id
GROUP BY season, oh.order_type, p.product_line
ORDER BY p.product_line, season;

-- needed to put #s before seasons in order to chronologically organize seasons for sorting


3. Create a query that returns the orders for the fall season of 2023 (October to December) with the following columns (one row per order).  Hint: use a CASE statement

-- order_id
-- order_type
-- number_of_items   (number of items in the order)
-- number_of_accessories   (number of accessories in the order)

SELECT 
  oh.order_id, 
  oh.order_type, 
  COUNT(ol.product_id) AS number_of_items,
  SUM(CASE WHEN p.product_line = 'Accessories' THEN 1 ELSE 0 END) AS number_of_accessories
FROM order_header oh
LEFT JOIN order_line ol ON oh.order_id = ol.order_id
LEFT JOIN product p ON ol.product_id = p.product_id
LEFT JOIN customer c ON oh.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM oh.order_date) = 2023
  AND EXTRACT(MONTH FROM oh.order_date) BETWEEN 10 AND 12
GROUP BY oh.order_id, oh.order_type;


4. Create a query that uses a Common Table Expression (CTE) and a Window Function to find the last (most recent) customer in each state to place an order.  Your query should return the following columns:

-- last_customer_name (split the name into first and last names, use the last name) 
-- state_province
-- (Hints:  Try the RANK function.   Make sure to handle customers with 3 names. )


WITH ranking AS (
  SELECT 
    c.customer_id,
    SPLIT_PART(c.customer_name, ' ', 2) AS last_customer_name,
    c.state_province,
    RANK() OVER (PARTITION BY c.state_province ORDER BY oh.order_date DESC) AS rank 
  FROM customer c
  INNER JOIN order_header oh ON c.customer_id = oh.customer_id
)
SELECT last_customer_name, state_province
FROM ranking
WHERE rank = 1;



5. Create the query from question #4 using a Temporary Table instead of a CTE.  Please include a DROP IF EXISTS statement prior to your statement that creates the Temporary Table.

DROP TABLE IF EXISTS temp_ranked_customers;
CREATE TEMPORARY TABLE temp_ranked_customers AS
WITH ranking AS (
  SELECT 
    c.customer_id,
    SPLIT_PART(c.customer_name, ' ', 2) AS last_customer_name,
    c.state_province,
    RANK() OVER (PARTITION BY c.state_province ORDER BY oh.order_date DESC) AS rank
  FROM customer c
  INNER JOIN order_header oh ON c.customer_id = oh.customer_id
)
SELECT last_customer_name, state_province
FROM ranking
WHERE rank = 1;

SELECT * FROM temp_ranked_customers;


6. Create the query from question #4 using a View instead of a CTE.   Please include a DROP IF EXISTS statement prior to your statement that creates the View.

DROP VIEW IF EXISTS view_rank;

CREATE VIEW view_rank AS
WITH ranking AS (
  SELECT 
    c.customer_id,
    SPLIT_PART(c.customer_name, ' ', 2) AS last_customer_name,
    c.state_province,
    RANK() OVER (PARTITION BY c.state_province ORDER BY oh.order_date DESC) AS rank
  FROM customer c
  INNER JOIN order_header oh ON c.customer_id = oh.customer_id
)
SELECT last_customer_name, state_province
FROM ranking
WHERE rank = 1;
SELECT * FROM view_rank;


7. Create a role named “product_admin” with permissions to SELECT and INSERT records into the product table.   Create a user named “Jose Garcia” who is a member of that role. 

DROP ROLE IF EXISTS product_admin;
CREATE ROLE product_admin;
CREATE USER "Jose Garcia" WITH PASSWORD 'password123';
GRANT product_admin TO "Jose Garcia";

GRANT SELECT, INSERT ON product TO product_admin;




/*
