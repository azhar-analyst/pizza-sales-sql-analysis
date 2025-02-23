-- 🍕 Pizza Sales SQL Analysis Queries

-- 🔹 Basic Queries
-- 1. Retrieve the total number of orders placed
SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders;

-- 2. Calculate the total revenue generated from pizza sales
SELECT SUM(order_details.total_price) AS total_revenue FROM order_details;

-- 3. Identify the highest-priced pizza
SELECT pizzas.pizza_name, pizzas.price 
FROM pizzas 
ORDER BY pizzas.price DESC 
LIMIT 1;

-- 4. Identify the most common pizza size ordered
SELECT pizzas.size, COUNT(*) AS order_count 
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size 
ORDER BY order_count DESC 
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities
SELECT pizzas.pizza_name, SUM(order_details.quantity) AS total_quantity
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_name
ORDER BY total_quantity DESC
LIMIT 5;

-- 🔹 Intermediate Queries
-- 6. Find the total quantity of each pizza category ordered
SELECT pizza_types.category, SUM(order_details.quantity) AS total_quantity
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category;

-- 7. Determine the distribution of orders by hour of the day
SELECT HOUR(orders.order_time) AS order_hour, COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY total_orders DESC;

-- 8. Find the category-wise distribution of pizzas
SELECT pizza_types.category, COUNT(*) AS total_pizzas_sold
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY total_pizzas_sold DESC;

-- 9. Calculate the average number of pizzas ordered per day
SELECT orders.order_date, ROUND(AVG(order_details.quantity),2) AS avg_pizzas_per_day
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id
GROUP BY orders.order_date;

-- 10. Determine the top 3 most ordered pizza types based on revenue
SELECT pizzas.pizza_name, SUM(order_details.total_price) AS revenue_generated
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_name
ORDER BY revenue_generated DESC
LIMIT 3;

-- 🔹 Advanced Queries
-- 11. Calculate the percentage contribution of each pizza type to total revenue
SELECT pizzas.pizza_name, 
       ROUND(SUM(order_details.total_price) * 100 / (SELECT SUM(total_price) FROM order_details), 2) AS revenue_percentage
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_name
ORDER BY revenue_percentage DESC;

-- 12. Analyze the cumulative revenue generated over time
SELECT orders.order_date, 
       SUM(order_details.total_price) OVER (ORDER BY orders.order_date) AS cumulative_revenue
FROM order_details
JOIN orders ON order_details.order_id = orders.order_id;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT category, pizza_name, revenue_generated
FROM (
    SELECT pizza_types.category, pizzas.pizza_name, SUM(order_details.total_price) AS revenue_generated,
           RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.total_price) DESC) AS rank
    FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    GROUP BY pizza_types.category, pizzas.pizza_name
) ranked_pizzas
WHERE rank <= 3;
