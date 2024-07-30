USE mentorness;
SHOW TABLES;
SELECT *FROM pizzas;
-- --Q1: The total number of order place
SELECT DISTINCT
    COUNT(order_id) AS total_orders
FROM
    orders; 
-- Q2: The total revenue generated from pizza sales 
SELECT 
    SUM(d.quantity * p.price) AS total_revene
FROM
    details d
        JOIN
    pizzas p ON d.pizza_id = p.pizza_id;
SELECT *FROM pizzas;

SELECT 
    p.name, pp.price
FROM
    pizzas pp
        JOIN
    pizza_type p ON p.pizza_type_id = pp.pizza_type_id
ORDER BY pp.price DESC
LIMIT 1;
-- Q4: The most common pizza size ordered. 
SELECT DISTINCT
    size AS 'most common pizza size'
FROM
    pizzas
GROUP BY size
ORDER BY COUNT(*) DESC
LIMIT 1;


-- Q5: The top 5 most ordered pizza types along their quantities. 
SELECT 
    t.category AS 'Pizaa Type',
    SUM(d.quantity) AS total_quantity
FROM pizza_type t
JOIN pizzas p ON t.pizza_type_id = p.pizza_type_id
JOIN details d ON p.pizza_id = d.pizza_id
GROUP BY t.category
ORDER BY total_quantity DESC
LIMIT 5;

-- Q6: The quantity of each pizza categories ordered. 
SELECT 
    t.name, SUM(d.quantity) AS total_quantity
FROM  pizza_type t
        JOIN pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN details d ON p.pizza_id = d.pizza_id
GROUP BY t.name;

-- Q7: The distribution of orders by hours of the day. 
SELECT 
     EXTRACT(HOUR FROM time)AS order_hour, 
     COUNT(d.order_id)AS order_COUNT
FROM orders o
       JOIN details d ON o.order_id=d.order_id
GROUP bY order_hour
ORDER BY order_hour;

SHOW TABLES;
SELECT *FROM orders;
-- Q8: The category-wise distribution of pizzas. 
SELECT 
	t.category ,COUNT(p.pizza_id)AS order_count
FROM pizza_type t 
	JOIN pizzas p ON t.pizza_type_id=p.pizza_type_id
	JOIN details d ON d.pizza_id=p.pizza_id
GROUP BY t.category;

-- Q9: The average number of pizzas ordered per day.
with CTE as (
SELECT  
	DATE(time) AS order_date,COUNT(*) AS daily_order_count
FROM orders GROUP BY order_date)
SELECT 
	ROUND(AVG(daily_order_count),0)
			AS 'Average order per day' FROM CTE ;
-- Q10: Top 3 most ordered pizza type base on revenue. 
SELECT 
	t.name As 'Pizaa Type',SUM(d.quantity*p.price) As total_revenue
FROM pizza_type t
	JOIN pizzas p ON t.pizza_type_id=p.pizza_type_id
	JOIN details d ON p.pizza_id= d.pizza_id
GROUP BY t.name
ORDER BY total_revenue
 DESC LIMIT 3;
 
-- Q11: The percentage contribution of each pizza type to revenue. 
-- revenue contribution = each revenue/total revenue *100
WITH CTE AS (
SELECT t.name, SUM(d.quantity*p.price) AS revenue
FROM pizza_type t
	JOIN pizzas p ON t.pizza_type_id=p.pizza_type_id
	JOIN details d ON p.pizza_id= d.pizza_id
GROUP BY t.name)
SELECT name ,
	ROUND(revenue/(SELECT SUM(revenue) FROm CTE ) *100,0)As 
														contribution_Percentage FROM CTE 
GROUP BY name
ORDER BY contribution_Percentage DESC;
-- Q12: The cumulative revenue generated over time.
 
WITH CTE AS (SELECT o.date AS sale_date,SUM(p.price * d.quantity) AS revenue
    FROM pizzas p 
    JOIN details d ON p.pizza_id = d.pizza_id
    JOIN orders o ON o.order_id = d.order_id
    GROUP BY o.date
)
SELECT 
	sale_date,
	SUM(revenue) OVER (ORDER BY sale_date) AS cumulative_revenue
FROM  CTE
	ORDER BY sale_date;

-- Q13: The top 3 most ordered pizza type based on revenue for each pizza category. 

WITH ranked_pizzas AS (
SELECT t.name,t.category,
SUM(d.quantity * p.price) AS total_revenue,
RANK() OVER (PARTITION BY t.category ORDER BY SUM(d.quantity * p.price) DESC)
 AS rnk
    FROM pizza_type t
JOIN pizzas p ON t.pizza_type_id=p.pizza_type_id
JOIN details d ON p.pizza_id= d.pizza_id
group by t.name,t.category)
SELECT name,category,
total_revenue
FROM ranked_pizzas WHERE rnk<=3
;