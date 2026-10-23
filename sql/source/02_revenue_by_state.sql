--Q1 Revenue (SUM of price) by customer_state for delivered orders. Top 10 states.
select * from customers -- state
select * from order_items  -- price
select * from orders -- order_status ( delivered )

select c.customer_state,sum(oi.price) as revenue from orders o
join customers c on o.customer_id =c.customer_id 
join order_items oi on o.order_id = oi.order_id 
where o.order_status ='delivered' 
group by c.customer_state  order by revenue desc limit 10 ;

-- Q2 How many orders have no review at all? (anti-join)
select count(*) from orders; -- 99441
select count(*) from order_reviews -- 99224

select count(*) from orders o 
join order_reviews t on o.order_id = t.order_id -- 99224

select count(*) from orders o 
left join order_reviews t on o.order_id = t.order_id -- 99992

select 99992-99224 -- 786
--------------Ways 2------------
select count(*) from orders o 
left join order_reviews t on o.order_id = t.order_id 
where t.order_id is null -- 786

-- Q3 Top 10 product categories in English by items sold. Why LEFT JOIN to the translation?

select * from products 
select * from order_items
select * from category_translation 

select ct.product_category_name_english ,  count(*) as sold_item from products p 
left  join category_translation ct on ct.product_category_name = p.product_category_name 
join order_items oi on p.product_id = oi.product_id 
group by ct.product_category_name_english 
order by sold_item desc  limit 10 ;

-- LEFT JOIN helps us retain products even when a translation is missing.

-- Q4 What share of order items were sold by a seller in the same state as the customer?
select * from order_items;
select * from sellers;
select * from customers c 
select * from orders;

select 
(select count(*) from order_items oi 
join orders o on o.order_id =oi.order_id 
join customers c on c.customer_id = o.customer_id 
join sellers s on oi.seller_id = s.seller_id
where s.seller_state = c.customer_state ) * 100.0
/
(select count(*) from order_items oi ) as same_state_share

-- Q5 For 5 orders, show item revenue and payment total side by side — without fan-out.
select * from orders
select * from order_payments

select o.order_id, oi.item_revenue, op.total_payment  from orders o 
join 
(
	select order_id ,sum(price+freight_value) as item_revenue from order_items oi 
	group by oi.order_id 
) oi on oi.order_id = o.order_id 
join 
(
	select order_id, sum(payment_value) as  total_payment from order_payments op 
	group by op.order_id 
) op on op.order_id =o.order_id 
limit 5;

-- Q6 Find orders where payments differ from price + freight by more than 1.00.
select * from order_items; --- price _ frieght_value
select * from order_payments op -- payment_value 

select o.order_id, pf ,total_payment from orders o 
join (
	select order_id, sum(price+freight_value) as pf
	from order_items oi 
	group by order_id  -- 98666
)oi on o.order_id = oi.order_id 
join(
	select order_id , sum(payment_value) as total_payment from order_payments op 
	group by op.order_id 
) op on o.order_id =op.order_id 
where op.total_payment - oi.pf >1 
or oi.pf -op.total_payment >1 

select count(*) from (select o.order_id, pf ,total_payment from orders o 
join (
	select order_id, sum(price+freight_value) as pf
	from order_items oi 
	group by order_id  -- 98666
)oi on o.order_id = oi.order_id 
join(
	select order_id , sum(payment_value) as total_payment from order_payments op 
	group by op.order_id 
) op on o.order_id =op.order_id 
where op.total_payment - oi.pf >1 
or oi.pf -op.total_payment >1 ) --249 

-- Extra 1 Find customers who have placed more than 3 orders.
select * from customers

select c.customer_id ,count (*) from orders o 
join customers c on o.customer_id =c.customer_id 
group by c.customer_id 
having count(*)>3


-- Find sellers whose total product revenue is higher than the average seller revenue.
select * from sellers 
select * from order_items

SELECT seller_id, total_product_revenue
FROM (
    SELECT seller_id, SUM(price) AS total_product_revenue
    FROM order_items
    GROUP BY seller_id
) AS seller_revenue
WHERE total_product_revenue > (
    SELECT AVG(total_product_revenue)
    FROM (
        SELECT seller_id, SUM(price) AS total_product_revenue
        FROM order_items
        GROUP BY seller_id
    ) AS all_seller_revenue
);

-- Two exam answers 
SELECT
    c.customer_state,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;
-----------------------
SELECT
    p.product_category_name,
    COUNT(*) AS items_sold,
    COUNT(DISTINCT oi.seller_id) AS different_sellers
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY items_sold DESC;



