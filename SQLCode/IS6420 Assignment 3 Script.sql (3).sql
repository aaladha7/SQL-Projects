-- By: Ali Abbas Ladha

-- 1. List the ID, name, and price for all products with a greater than the average product price.

SELECT avg(product_price)
FROM product;

SELECT product_id, product_name, product_price
FROM product
WHERE product_price >
	(SELECT AVG(product_price)
	FROM product);

	


-- 2. For each product, list its name and total quantity ordered. Products should be listed in ascending order of the product name.

SELECT p.product_name, SUM(ol.quantity) AS total_quantity
FROM product AS p
LEFT JOIN order_line AS ol
ON p.product_id = ol.product_id
GROUP BY p.product_name
ORDER BY product_name ASC;
	



-- 3. For each product, list its ID and total quantity ordered. Products should be listed in ascending order of total quantity ordered.

SELECT p.product_id, SUM(ol.quantity) AS total_quantity
FROM product AS p
LEFT JOIN order_line AS ol
ON p.product_id = ol.product_id
GROUP BY p.product_id
ORDER BY total_quantity ASC;


-- 4. For each product, list its ID, name and total quantity ordered. Products should be listed in ascending order of the product name.
SELECT p.product_id, p.product_name, SUM(ol.quantity) AS total_quantity
FROM product AS p
LEFT JOIN order_line AS ol
ON p.product_id = ol.product_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_name ASC;


--5. List the email for all customers who have placed 3 or more orders. 
	-- Each customer name should appear exactly once. Customer emails should be sorted in descending alphabetical order.


SELECT DISTINCT c.email AS customers_email_3_or_more_orders, c.customer_name
FROM customer AS c
INNER JOIN order_header AS oh
ON c.customer_id = oh.customer_id
GROUP BY c.email, c.customer_name
HAVING COUNT(order_id) >= 3
ORDER BY c.email DESC;




-- 6. Implement the previous query using a subquery and IN adding the requirement that the customers’ orders have been placed after Oct 5, 2022.



SELECT c.email AS customers_email_3_or_more_orders, c.customer_name
FROM customer AS c
WHERE c.customer_id IN(
	SELECT c.customer_id
	FROM order_header oh
	WHERE order_date > '10-05-2022'
	GROUP BY c.customer_id
	HAVING COUNT(order_id) >= 3)
ORDER BY c.email DESC;



-- 7.For each city, list the number of customers from that city, who have placed at least 2 orders.
	-- Cities are sorted by the number of customers with 2 orders, descending


SELECT c.city, COUNT(DISTINCT c.customer_id) AS "customers with atleast 2 orders"
FROM customer AS c
INNER JOIN order_header AS oh
ON c.customer_id = oh.customer_id
GROUP by c.city
HAVING COUNT(oh.order_id) >=2
ORDER BY COUNT(DISTINCT c.customer_id) DESC;




-- 8. Implement the previous using a subquery and IN.

SELECT c.city, COUNT(DISTINCT c.customer_id)
FROM customer AS c
WHERE customer_id IN(
	SELECT customer_id
	FROM order_header
	GROUP BY customer_id
	HAVING COUNT(order_id) >=2 )
GROUP BY c.city 
ORDER BY COUNT(DISTINCT c.customer_id) DESC;





-- 9. List the ID for all products, which have NOT been ordered on Dec 5, 2023 or before. 
-- Sort your results by the product id in decending order.  Use EXCEPT for this query.


SELECT p.product_id
FROM product AS p
EXCEPT
SELECT ol.product_id
FROM order_line AS ol
INNER JOIN order_header AS oh
ON ol.order_id = oh.order_id
WHERE oh.order_date <= '2023-12-05'
ORDER BY product_id DESC;



-- 10. List the ID for all California customers, who have placed one or more orders in November 2023 or after. 
--Sort the results by the customer id in ascending order.  Use Intersect for this query.  
-- Make sure to look for alternate spellings for California, like "CA"

SELECT c.customer_id
FROM customer AS c
WHERE state_province IN('CA', 'California')
INTERSECT
SELECT oh.customer_id
FROM order_header AS oh
WHERE order_date >= '2023-11-01'
GROUP BY customer_id 
HAVING COUNT(order_id) >= 1
ORDER BY customer_id ASC;





-- 11. Implement the previous query using a subquery and IN.

SELECT c.customer_id
FROM customer AS c
WHERE customer_id IN
	(SELECT customer_id 
	FROM order_header AS oh
	WHERE order_date >= '2023-11-01'
	)
AND state_province IN('CA', 'California')
ORDER BY c.customer_id ASC





-- 12. List the IDs for all California customers along with all customers (regardless where they are from) 
-- who have placed one or more order(s) before December 2022. Sort the results by the customer id in descending order.  
-- Use union for this query.

SELECT c.customer_id
FROM customer AS c
WHERE state_province IN('CA', 'California')
UNION
SELECT c.customer_id
FROM customer AS c
INNER JOIN order_header AS oh
ON c.customer_id = oh.customer_id
WHERE oh.order_date <= '2022-12-01'
GROUP BY c.customer_id
HAVING COUNT(order_id) >=1
ORDER BY customer_id DESC;




-- 13. List the product ID, product name and total quantity ordered for all products with total quantity ordered of less than 5.

SELECT p.product_id, p.product_name, SUM(quantity) AS total_quantity
FROM product AS p
INNER JOIN order_line AS ol
ON p.product_id = ol.product_id 
GROUP BY p.product_id, p.product_name
HAVING SUM(ol.quantity) <5;




-- 14 List the product ID, product name  and total quantity ordered for all products with total quantity ordered greater 
-- 		than 3 and were placed by Illinois customers.  Make sure to look for alternative spellings for Illinois state.




SELECT DISTINCT state_province
FROM customer
WHERE state_province LIKE 'I%'

SELECT p.product_id, p.product_name, SUM(quantity) AS total_quantity
FROM product AS p
INNER JOIN order_line AS ol
ON p.product_id = ol.product_id 
INNER JOIN order_header AS oh
ON ol.order_id = oh.order_id 
INNER JOIN customer AS c
ON oh.customer_id = c.customer_id 
WHERE state_province IN ('Illinois', 'IL')
GROUP BY p.product_id, p.product_name 
HAVING SUM(quantity) > 3;


