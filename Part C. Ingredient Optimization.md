<h1 align='center'> Part C. Ingredient Optimization </h1> 

**1.**  What are the standard ingredients for each pizza?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
SELECT 
    PN.pizza_name,
    GROUP_CONCAT(PT.topping_name
        SEPARATOR ',') AS std_ingredients
FROM
    pizza_recipes AS PR
        JOIN
    pizza_toppings PT ON FIND_IN_SET(PT.topping_id,
            REPLACE(PR.toppings, ' ', '')) > 0
        JOIN
    pizza_names AS PN ON PR.pizza_id = PN.pizza_id
GROUP BY PN.pizza_name;
  ```
</details>

**Results:**
pizza_name| std_ingredients
----------|----------
Meatlovers	|Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami
Vegetarian	|Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce

**2.**  What was the most commonly added extra?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH cte AS
     (SELECT substring_index(extras,',', 1) AS extras1 
      FROM customer_orders
     )
SELECT COUNT(topping_name) as commonly_added_extra , topping_name FROM cte JOIN pizza_toppings p ON p.topping_id = cte.extras1
GROUP BY topping_name
LIMIT 1;
  ```
</details>

**Results:**

commonly_added_extra|topping_name|
-------------------|------------
4	|Bacon   |


**3.**  What was the most common exclusion?

<details>
  <summary>Click to expand answer!</summary>

  ##### Answer
  ```sql
WITH cte AS
(SELECT substring_index(exclusions,',', 1) AS exclusions
  FROM customer_orders
  ) 
SELECT COUNT(topping_name) as common_exclusion , topping_name FROM cte JOIN pizza_toppings p ON p.topping_id = cte.exclusions
GROUP BY topping_name 
LIMIT 1;
  ```
</details>

**Results:**

common_exclusion|topping_name|
-------------------|------------
4	|Cheese  |

## Unanswered
4) Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

5) Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

6) What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?



