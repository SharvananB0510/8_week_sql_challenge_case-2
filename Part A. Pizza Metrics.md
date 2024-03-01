<h1 align='center'> Part A. Pizza Metrics </h1>  

**1.**  How many pizzas were ordered?
<details>
  <summary>Click to expand answer!</summary>

  ```sql
SELECT 
    COUNT(order_id) as pizzas
FROM
    customer_orders;
  ```
</details>

**Results:**

 pizzas|
----------------|
14|

**2.**  How many unique customer orders were made?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT
	COUNT(DISTINCT order_id) AS unique_orders
FROM
	customer_orders;
  ```
</details>

**Results:**

unique_orders|
-------------|
10|

**3.**  How many successful orders were delivered by each runner?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

runner_id|successful_orders|
---------|-----------------|
1|                4|
2|                3|
3|                1|


**4.**  How many of each type of pizza was delivered?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

pizza_name|No_of_pizzas|
----------|--------------|
Meatlovers|             9|
Vegetarian|             3|

**5.**  How many Vegetarian and Meatlovers were ordered by each customer?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

customer_id|meat_lovers|vegetarian|
-----------|-----------|----------|
101|          2|         0|
102|          2|         1|
103|          3|         1|
104|          3|         0|
105|          0|         1|

**6.**  What was the maximum number of pizzas delivered in a single order?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql

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
  ```
</details>

**Results:**

max_delivered_pizzas|
--------------------|
3|

**7.**  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
        THEN 1
        ELSE 0 END) AS Changes_made,
    SUM(CASE
        WHEN
            (c.exclusions <> 'null'
                AND c.exclusions IS NOT NULL
                AND c.exclusions <> '')
                OR (c.extras <> 'null'
                AND c.extras IS NOT NULL
                AND c.exclusions <> '')
        THEN 0
        ELSE 1 END) AS NO_changes_made
FROM
    customer_orders C
        JOIN
    pizza_names P USING (pizza_id)
        JOIN
    runner_orders R ON R.order_id = C.order_id
WHERE
    R.pickup_time <> 'null'
GROUP BY C.Customer_id;
  ```
</details>

**Results:**

customer_id|Changes_made|NO_changes_made|
-----------|------------|----------|
101|           0|         2|
102|           0|         3|
103|           3|         0|
104|           2|         1|
105|           1|         0|

**8.**  How many pizzas were delivered that had both exclusions and extras?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

Pizzas_with_both|
----------------|
1|

**9.**  What was the total volume of pizzas ordered for each hour of the day?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour, COUNT(order_id)
FROM
    customer_orders
GROUP BY hour
ORDER BY hour;
  ```
</details>

**Results:**

hour_of_day_24h|hour_of_day_12h|
---------------|---------------|
11             |              1|
13             |             3|
18             |            3|
19             |            1|
21             |            3|
23             |             3| 

**10.**  What was the volume of orders for each day of the week?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
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
  ```
</details>

**Results:**

day_of_week|Pizzas|
-----------|----------------|
Wednesday     |               5|
Thursday     |               3|
Friday     |               1|
Saturday   |               5|





