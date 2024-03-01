<h1 align='center'>Part D. Pricing & Ratings</h1>

**1.**  If a Meat Lovers pizza costs \$12 and Vegetarian costs \$10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
 SUM(CASE WHEN pizza_id=1 THEN 12
    WHEN pizza_id = 2 THEN 10
    END) AS Total_earnings
 FROM runner_orders r
JOIN customer_orders c ON c.order_id = r.order_id
WHERE r.pickup_time <>  'null';
  ```
</details>

**Results:**

Total_earnings|
---------------------------------|
138|

**2.**  What if there was an additional $1 charge for any pizza extras?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

Extra_price|
------------|
142|

**3.**  The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
DROP TABLE IF EXISTS TABLE ratings;
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
  ```
</details>

**Results:**

order_id|rating|
--------|------|
1	|3
2	|4
3	|5
4	|2
5	|1
6	|3
7	|4
8	|1
9	|3
10|5

**4.**  Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
* customer_id
* order_id
* runner_id
* rating
* order_time
* pickup_time
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**
| customer_id | Total_number_of_pizzas | order_id | runner_id | rating | order_time           | pickup_time          | Duration | Avg_distance | AVG_speed |
|-------------|------------------------|----------|-----------|--------|----------------------|----------------------|----------|--------------|-----------|
| 101         | 1                      | 1        | 1         | 3      | 2020-01-01 18:05:02  | 2020-01-01 18:15:34  | 32.0000  | 20.00        | 0.63      |
| 101         | 1                      | 2        | 1         | 4      | 2020-01-01 19:00:52  | 2020-01-01 19:10:54  | 27.0000  | 20.00        | 0.74      |
| 102         | 2                      | 3        | 1         | 5      | 2020-01-02 23:51:23  | 2020-01-03 00:12:37  | 20.0000  | 13.40        | 0.67      |
| 102         | 1                      | 8        | 2         | 1      | 2020-01-09 23:54:33  | 2020-01-10 00:15:02  | 15.0000  | 23.40        | 1.56      |
| 103         | 3                      | 4        | 2         | 2      | 2020-01-04 13:23:46  | 2020-01-04 13:53:03  | 40.0000  | 23.40        | 0.59      |
| 104         | 1                      | 5        | 3         | 1      | 2020-01-08 21:00:29  | 2020-01-08 21:10:57  | 15.0000  | 10.00        | 0.67      |
| 104         | 2                      | 10       | 1         | 5      | 2020-01-11 18:34:49  | 2020-01-11 18:50:20  | 10.0000  | 10.00        | 1.00      |
| 105         | 1                      | 7        | 2         | 4      | 2020-01-08 21:20:29  | 2020-01-08 21:30:45  | 25.0000  | 25.00        | 1.00      |


**5.**  If a Meat Lovers pizza was \$12 and Vegetarian \$10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometer traveled - how much money does Pizza Runner have left over after these deliveries?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
GROUP BY runner_id
  ```
</details>

**Results:**

| runner_id | pizza_cost | pizza_only | distance_cost |
|-----------|------------|------------|---------------|
| 1         | 43.96      | 70         | 26.04         |
| 2         | 20.42      | 56         | 35.58         |
| 3         | 9.00       | 12         | 3.00          |


<h1 align='center'>Part E. Bonus Question</h1>

**1.**  If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

pizza_id|pizza_name|toppings                             |
--------|----------|-------------------------------------|
1|Meatlovers|1, 2, 3, 4, 5, 6, 8, 10              |
2|Vegetarian|4, 6, 7, 9, 11, 12                   |
3|Supreme   |1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12|

