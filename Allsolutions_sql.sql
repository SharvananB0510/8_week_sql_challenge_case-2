-- A. Pizza Metrics 

-- 1) How many pizzas were ordered?

SELECT 
    COUNT(order_id) as pizzas
FROM
    customer_orders;

-- 2) How many unique customer orders were made?

SELECT COUNT(DISTINCT customer_id) FROM 
customer_orders;

-- 3)How many successful orders were delivered by each runner?

SELECT 
    R.runner_id,
    COUNT(O.order_id) AS Successful_orders
FROM 
    runners R
JOIN 
    runner_orders O USING(runner_id)
WHERE 
    O.pickup_time <> 'null'
GROUP BY 
    R.runner_id;


-- 4) How many of each type of pizza was delivered?

SELECT 
	
    P.pizza_name,
   COUNT( R.order_id) AS No_of_pizzas
FROM 
    customer_orders C
JOIN 
    pizza_names P On P.pizza_id = C.pizza_id
JOIN 
	runner_orders R On R.order_id = C.order_id 
WHERE 
    R.pickup_time <> 'null'
group by 
	P.pizza_name;

-- 5)How many Vegetarian and Meatlovers were ordered by each customer?

Select C.Customer_id,
sum(Case
	When P.Pizza_name  = 'Meatlovers'Then 1 else 0
    end) as MeatLovers,
sum(Case
	When P.Pizza_name  = 'Vegetarian' Then 1 else 0
    end) as Vegetarian
From
	customer_orders C
JOIN
	pizza_names P using(pizza_id)
JOIN 
	runner_orders R On R.order_id = C.order_id 
WHERE 
    R.pickup_time <> 'null'
group by 
C.Customer_id;

-- 6) What was the maximum number of pizzas delivered in a single order?

Select Max_pizzas from(
Select C.order_id,count(C.order_id) as Max_pizzas
,
rank() over( order by count(C.order_id) desc) as Rnk
From
	customer_orders C
JOIN
	pizza_names P using(pizza_id)
JOIN 
	runner_orders R On R.order_id = C.order_id 
WHERE 
    R.pickup_time != 'null'
Group by C.order_id) X
where Rnk = 1;

-- 7)For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
    C.Customer_id,
    SUM(CASE
        WHEN
            (c.exclusions <> 'null'
                AND c.exclusions IS NOT NULL
                AND c.exclusions <> '')
                OR (c.extras <> 'null'
                AND c.extras IS NOT NULL
                AND c.exclusions <> '')
        THEN
            1
        ELSE 0
    END) AS Changes_made,
    SUM(CASE
        WHEN
            (c.exclusions <> 'null'
                AND c.exclusions IS NOT NULL
                AND c.exclusions <> '')
                OR (c.extras <> 'null'
                AND c.extras IS NOT NULL
                AND c.exclusions <> '')
        THEN
            0
        ELSE 1
    END) AS NO_changes_made
FROM
    customer_orders C
        JOIN
    pizza_names P USING (pizza_id)
        JOIN
    runner_orders R ON R.order_id = C.order_id
WHERE
    R.pickup_time <> 'null'
GROUP BY C.Customer_id;

-- 8) How many pizzas were delivered that had both exclusions and extras?

SELECT 
    COUNT(CASE
        WHEN
            (C.exclusions IS NOT NULL
                AND C.exclusions <> 'null'
                AND C.exclusions <> '')
                AND (C.extras IS NOT NULL
                AND C.extras <> 'null'
                AND C.extras <> '')
        THEN
            C.order_id
        ELSE NULL
    END) AS Pizzas_with_both
FROM
    customer_orders C
        JOIN
    pizza_names P USING (pizza_id)
        JOIN
    runner_orders R ON R.order_id = C.order_id
WHERE
    R.pickup_time <> 'null';

-- 9) What was the total volume of pizzas ordered for each hour of the day?

SELECT 
    EXTRACT(HOUR FROM order_time) AS hour, COUNT(order_id)
FROM
    customer_orders
GROUP BY hour
ORDER BY hour;

-- 10) What was the volume of orders for each day of the week?

SELECT 
    DAYNAME(order_time) AS day_of_week, 
    COUNT(order_id) AS Pizzas
FROM
    customer_orders
GROUP BY 
	day_of_week 
    , DAYOFWEEK(order_time)
ORDER BY 
	DAYOFWEEK(order_time);

-- B

-- 1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
    DATE(registration_date - INTERVAL WEEKDAY(registration_date) DAY) + INTERVAL 4 DAY AS week,
    COUNT(runner_id) AS runners
FROM
    runners
GROUP BY week;
 
-- 2) What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT
    R.runner_id,
    AVG(MINUTE(R.pickup_time)) AS avg_time_min
FROM
    runner_orders R
JOIN
    customer_orders C ON R.order_id = C.order_id
WHERE
    R.pickup_time IS NOT NULL
GROUP BY
    R.runner_id;

-- 3) Is there any relationship between the number of pizzas and how long the order takes to prepare?

With CTE as (select 
	count(pizza_id) as NO_of_pizzas,
	TIMESTAMPDIFF(MINUTE, C.order_time, R.pickup_time) as TD
FROM
    runner_orders R
JOIN
    customer_orders C ON R.order_id = C.order_id
WHERE
    R.pickup_time IS NOT NULL and timediff( R.pickup_time,C.order_time) is not null
GROUP BY
    R.order_id,TD
)
SELECT 
    NO_of_pizzas, AVG(TD) AS AVG_time
FROM
    CTE
GROUP BY NO_of_pizzas;


-- 4) What was the average distance travelled for each customer?

SELECT 
    C.customer_id,
    ROUND(AVG(CAST(REPLACE(distance, 'km', '') AS DECIMAL (3 , 1 ))),
            2) AS avg_distance
FROM
    runner_orders R
        JOIN
    customer_orders C ON R.order_id = C.order_id
WHERE
    R.distance <> 'null'
GROUP BY C.customer_id;
    
-- 5) What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS UNSIGNED))
    - MIN(CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS UNSIGNED)) AS Duration
FROM
    runner_orders
WHERE
    duration <> 'null';

-- 6) What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
    R.runner_id,
   R.order_id,
        ROUND(
            AVG(CAST(REPLACE(R.distance, 'km', '') AS DECIMAL(3, 1)))/
        AVG(CAST(REGEXP_REPLACE(R.duration, '[^0-9]', '') AS UNSIGNED)), 2) AS Duration
FROM
    runner_orders R
JOIN
    customer_orders C ON R.order_id = C.order_id
WHERE
    R.distance <> 'null'
GROUP BY 
    R.runner_id, 
    R.order_id
ORDER BY
	 R.runner_id, 
    R.order_id;

-- 7) What is the successful delivery percentage for each runner?

SELECT 
    runner_id,
    ROUND(SUM(CASE
                WHEN pickup_time = 'null' THEN 0
                ELSE 1
            END) / COUNT(order_id),
            2) * 100 AS successful_delivery_percentage
FROM
    runner_orders
GROUP BY runner_id;

-- C
-- 1) What are the standard ingredients for each pizza?

SELECT 
    PN.pizza_name,
    GROUP_CONCAT(PT.topping_name
        SEPARATOR ',') AS std_ingre
FROM
    pizza_recipes AS PR
        JOIN
    pizza_toppings PT ON FIND_IN_SET(PT.topping_id,
            REPLACE(PR.toppings, ' ', '')) > 0
        JOIN
    pizza_names AS PN ON PR.pizza_id = PN.pizza_id
GROUP BY PN.pizza_name;

-- 2)What was the most commonly added extra?

-- DROP TABLE row_split_customer_orders_temp;

WITH cte AS
     (SELECT substring_index(extras,',', 1) AS extras1 
      FROM customer_orders
     )
SELECT COUNT(topping_name) as commonly_added_extra , topping_name FROM cte JOIN pizza_toppings p ON p.topping_id = cte.extras1
GROUP BY topping_name
LIMIT 1;


-- 3) What was the most common exclusion?

WITH cte AS
(SELECT substring_index(exclusions,',', 1) AS exclusions
  FROM customer_orders
  ) 
SELECT COUNT(topping_name) as common_exclusion , topping_name FROM cte JOIN pizza_toppings p ON p.topping_id = cte.exclusions
GROUP BY topping_name 
LIMIT 1;

-- 4) Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


-- 5) Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6) What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- D
-- 1) If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes — how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
 SUM(CASE WHEN pizza_id=1 THEN 12
    WHEN pizza_id = 2 THEN 10
    END) AS Total_earnings
 FROM runner_orders r
JOIN customer_orders c ON c.order_id = r.order_id
WHERE r.pickup_time <>  'null';


-- 2) 
WITH cte AS
(SELECT 
 (CASE WHEN pizza_id=1 THEN 12
    WHEN pizza_id = 2 THEN 10
    END) AS pizza_cost, 
    c.exclusions,
    c.extras
 FROM runner_orders r
JOIN customer_orders c ON c.order_id = r.order_id
WHERE r.pickup_time <>  'null')
SELECT 
 SUM(CASE WHEN extras IS NULL or extras ='' or extras='null' THEN pizza_cost
  WHEN LENGTH(extras) = 1 THEN pizza_cost + 1
        ELSE pizza_cost + 2
        END ) as Extra_price
FROM cte;

-- 3)
CREATE TABLE ratings 
 (order_id INTEGER,
    rating INTEGER);
INSERT INTO ratings
 (order_id ,rating)
VALUES 
(1,3),
(2,4),
(3,5),
(4,2),
(5,1),
(6,3),
(7,4),
(8,1),
(9,3),
(10,5);

select * from ratings;

-- 4) Join every thing

SELECT 
    C.customer_id,
    COUNT(pizza_id) AS Total_number_of_pizzas,
    C.order_id,
    R.runner_id,
    RT.rating,
    C.order_time,
    R.pickup_time,
    AVG(CAST(REGEXP_REPLACE(R.duration, '[^0-9]', '') AS UNSIGNED)) AS Duriation,
    ROUND(AVG(CAST(REPLACE(distance, 'km', '') AS DECIMAL (3 , 1 ))),
            2) AS Avg_distance,
    ROUND(AVG(CAST(REPLACE(R.distance, 'km', '') AS DECIMAL (3 , 1 ))) / AVG(CAST(REGEXP_REPLACE(R.duration, '[^0-9]', '') AS UNSIGNED)),
            2) AS AVG_speed
FROM
    customer_orders C
        JOIN
    runner_orders R ON C.order_id = R.order_id
        JOIN
    ratings RT ON R.order_id = RT.order_id
WHERE
    pickup_time <> 'null'
GROUP BY C.customer_id , C.order_id , R.runner_id , RT.rating , C.order_time , R.pickup_time
ORDER BY C.customer_id;

-- 5) 

SELECT 
    runner_id,
    SUM(CASE
        WHEN pizza_id = 1 THEN 12
        WHEN pizza_id = 2 THEN 10
    END) - SUM((r.distance + 0) * 0.3) AS pizza_cost,
    SUM(CASE
        WHEN pizza_id = 1 THEN 12
        WHEN pizza_id = 2 THEN 10
    END) AS pizza_only,
    (SUM(r.distance + 0) * 0.3) AS distance_cost
FROM
    runner_orders r
JOIN 
	customer_orders c ON c.order_id = r.order_id
WHERE
    pickup_time <> 'null'
GROUP BY runner_id;

-- E Bonous
-- 1.If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?


DROP TABLE IF EXISTS temp_pizza_names;
CREATE TEMPORARY TABLE temp_pizza_names AS (
	SELECT *
  	FROM
  		pizza_runner.pizza_names
);

INSERT INTO temp_pizza_names
VALUES
  (3, 'Supreme');


DROP TABLE IF EXISTS temp_pizza_recipes;
CREATE TABLE temp_pizza_recipes AS (
	SELECT *
  	FROM
  		pizza_runner.pizza_recipes
);

INSERT INTO temp_pizza_recipes
VALUES
  (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
 
SELECT
	t1.pizza_id,
	t1.pizza_name,
	t2.toppings
FROM 
	temp_pizza_names AS t1
JOIN
	temp_pizza_recipes AS t2
ON
	t1.pizza_id = t2.pizza_id;
