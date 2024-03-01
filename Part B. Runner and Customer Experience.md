<h1 align='center'> Part B. Runner and Customer Experience </h1>
  
**1.**  How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
    DATE(registration_date - INTERVAL WEEKDAY(registration_date) DAY) + INTERVAL 4 DAY AS starting_week,
    COUNT(runner_id) AS runners
FROM
    runners
GROUP BY week;
  ```
</details>

**Results:**

starting_week|runners|
-------------|-----------------|
2021-01-01|                2|
2021-01-08|                1|
2021-01-15|                1|

**2.**  What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

|Runner_id|avg_pickup_time|
|------------|-
|1|24.833|
|2|40.80
3|10.00|

**3.**  Is there any relationship between the number of pizzas and how long the order takes to prepare?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
    No_of_pizzas, AVG(TD) AS AVG_time
FROM
    CTE
GROUP BY NO_of_pizzas;
  ```
</details>

**Results:**

|No_of_pizzas|AVG_time|
----------|----------|
1	|12.0000
2	|18.0000
3	|29.0000

**4.**  What was the average distance traveled for each customer?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

customer_id|avg_distance|
-----------|------------|
101|       20.00|
102|       18.40|
103|       23.40|
104|       10.00|
105|       25.00|

**5.**  What was the difference between the longest and shortest delivery times for all orders?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
    MAX(CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS UNSIGNED))
    - MIN(CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS UNSIGNED)) AS Duration
FROM
    runner_orders
WHERE
    duration <> 'null';
  ```
</details>

**Results:**

Duration|
--------|
30|

**6.**  What was the average speed for each runner for each delivery and do you notice any trend for these values?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
    R.runner_id,
   R.order_id,
        ROUND(
            AVG(CAST(REPLACE(R.distance, 'km', '') AS DECIMAL(3, 1)))/
        AVG(CAST(REGEXP_REPLACE(R.duration, '[^0-9]', '') AS UNSIGNED)), 2) AS Duration_U
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
  ```
</details>

**Results:**

|runner_id|order_id|Duration|
|----------|-------|----------|
|1|	1|	0.63
|1	|2	|0.74
|1	|3	|0.67
|1	|10	|1.00
|2	|4	|0.59
|2	|7	|1.00
|2	|8	|1.56
|3	|5	|0.67

**7.**  What is the successful delivery percentage for each runner?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

runner_id | successful_delivery_percentage
---------------|-----|
1	|100.00
2	|75.00
3	|50.00



