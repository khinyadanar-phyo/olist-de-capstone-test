-- Q1. NULL audit: count NULLs in product_category_name and product_weight_g.
select count(*)-count(product_category_name) as null_category,
		count(*)-count(product_weight_g)as null_weight from products 


Q2. -- For each month of purchase, what is the average delivery time, and 
-- how many orders (and what percentage) were delivered within 30 days of purchase?
select * from orders 

SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,

    ROUND(AVG(EXTRACT(EPOCH FROM (
        order_delivered_customer_date - order_purchase_timestamp
    )) / 86400.0)::numeric, 2) AS avg_delivery_days,

    COUNT(*) AS total_orders,

    COUNT(CASE
        WHEN order_delivered_customer_date - order_purchase_timestamp
             <= INTERVAL '30 days'
        THEN 1
    END) AS within_30_days,

    ROUND(
        COUNT(CASE
            WHEN order_delivered_customer_date - order_purchase_timestamp
                 <= INTERVAL '30 days'
            THEN 1
        END) * 100.0 / COUNT(*),
        2
    ) AS percentage_within_30_days

FROM orders
WHERE order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;

Q.3On which day of the week do customers place the most orders? Show each weekday’s name and number, and the total orders for that day, sorted from busiest to quietest.


Q.4 What is the total revenue for each product category, shown with its English name? If a category has no English translation, show the original Portuguese name instead. If the product has no category at all, show it as ‘unknown’.



Q.5 Group delivered orders by delivery speed:
• Fast: 7 days or less from purchase to delivery.
• Normal: 8 to 14 days.
• Slow: 15 to 30 days.
• Very slow: more than 30 days.
How many orders fall into each group, and what percentage of the total is each?