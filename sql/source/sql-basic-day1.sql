select * from orders limit 10;
select order_id, order_status as status from orders limit 10;
select distinct order_status as unique_status from orders ;
select count(distinct order_status) as unique_status from orders ;
select order_id, order_status as status from orders where order_status ='delivered';
select distinct order_status as status from orders where order_status <>'canceled';
select distinct customer_state from customers c ;
select distinct customer_state from customers c where c.customer_state in('SP','SC','MG');
select * from order_items  where price between 10 and 50;
select * from customers where customer_city like'%sao';
-- order by one column
select order_id, product_id,price from order_items order by price desc limit 10;
-- order by 2 columns 
select order_id, product_id,price from order_items order by price desc, order_id limit 10;
select price + freight_value as total_price
from order_items order by total_price desc,order_id;

-- Aggregate functions
select count(*) from customers c ;
select count(*) from order_items oi ;
select count(*), order_status from orders group by order_status;

-- Join 
select o.order_id , c.customer_state  from orders o 
inner join customers c on o.customer_id =c.customer_id 

select count(*) from orders o
inner join  order_reviews r on o.order_id = r.order_id

-- orders and order_items cardinality check 
select * from order_items where order_item_id > 3;
select count(*) from order_items where order_id = '00bcee890eba57a9767c7b5ca12d3a1b';--4

-- order_id and order_review cardinality check
select order_id, count(*) from order_reviews 
group by order_id 
having count(*)>2
select * from order_reviews where order_id='03c939fd7fd3b38f8485a0f95798f1f6'

-- step by step checking orders that do not have order_reviews 
select count(*)from orders -- 99441
select count(*)from order_reviews --99224
select 99441-99224 -- 217
select order_id, count(*) from order_reviews 
group by order_id 
having count(*)<1

-- Inner Join 
select count(*) from orders o 
inner join customers c 
on o.customer_id =c.customer_id  --99441 ( because both tables have 99441 rows )

select count(*) from orders o 
inner join order_reviews t 
on o.order_id =t.order_id --99224

select count(*) from order_reviews t --99224
select 99441-99224; -- 217 orders do not have reviews 

-- left Join--
select count(*) from orders o 
inner join order_reviews t 
on o.order_id =t.order_id --99224 (inner join)

select count(*) from orders o 
left join order_reviews t 
on o.order_id =t.order_id --99992

select 99992-99224 -- 768 ( 768 are the orders without reviews )
select count(*) from orders o 
left join order_reviews t 
on o.order_id =t.order_id where t.order_id is null; -- 768


---------------------- CTE----------------------------

WITH revenue_by_state AS (
  SELECT c.customer_state AS state,
         SUM(oi.price) AS revenue
  FROM raw.order_items oi
  JOIN raw.orders o USING (order_id) -- using is same as 
  JOIN raw.customers c USING (customer_id)
  GROUP BY c.customer_state
)
SELECT state, revenue
FROM revenue_by_state
WHERE revenue > 1000000;

-- What is the average order value per delivered order?
select * from orders -- order_status
select * from order_items-- price , freight_value 

with avg_order as (
 select order_id , sum(price+freight_value) as revenue
 from order_items
 group by order_id 
 ),
 delivered as (
 select o.order_id, ov.revenue from orders o 
 join avg_order  ov on o.order_id = ov.order_id 
 where o.order_status = 'delivered'
 )
 select avg(revenue) as avg_revenue from delivered 
 
 
 --------------------------Data type cheching and String ------------------------------------
 
 select column_name,data_type,is_nullable
 from information_schema."columns"
 where table_schema='raw'
 and table_name ='customers'
 order by ordinal_position;
 
 select pg_typeof(customer_id) from customers c limit 3
 
 ---------------------- Casting ----------
 select pg_typeof(order_purchase_timestamp) , cast(order_purchase_timestamp as date)
 as timestamp from orders
 
 ----------------------Audit Null-------------
 select count(*)-count(customer_city ) as check_null  from customers -- 0
 select * from customers
 
 select * from orders where order_delivered_carrier_date is null order by 
 order_delivered_carrier_date desc 
 
 ------------------------- Null Audit------------------
 -------------------Coalesce()------------------
 select * from order_reviews t 
 select order_id,coalesce (review_comment_title,'No review')check
 from order_reviews
 
 ---------------------Nullif()---------
 select count(*) from order_items -- 112650
 select count(*),nullif(count(*),112650) from order_items
 
 
 -------------- Total number of seconds-----
 select extract (EPOCH from order_delivered_customer_date) as total_seconds from orders
 
-- Current date and time
SELECT CURRENT_DATE,     -- today's date
       NOW();            -- timestamptz, start of transaction
 
-- Text -> date / timestamp using a pattern
SELECT TO_DATE('15/03/2018', 'DD/MM/YYYY'),
       TO_TIMESTAMP('2018-03-15 14:05',
                    'YYYY-MM-DD HH24:MI'),
       MAKE_DATE(2018, 3, 15);
 
-- Durations-means “the total number of seconds (EPOCH)
SELECT AGE(order_delivered_customer_date,--how much time passed from
           order_purchase_timestamp)      AS age
     --  EXTRACT(EPOCH from order_delivered_customer_date - order_purchase_timestamp) / 3600 AS hours
FROM raw.orders LIMIT 5;

-- TIMESTAMP (no zone) -> TIMESTAMPTZ -> another zone
SELECT order_purchase_timestamp
         AT TIME ZONE 'America/Sao_Paulo' AS tz_aware, -- setting the time zone
       (order_purchase_timestamp
         AT TIME ZONE 'America/Sao_Paulo')
         AT TIME ZONE 'Asia/Bangkok'      AS bangkok_time -- changing timezone into another timezone
FROM raw.orders LIMIT 5;
 
-- Date spine: one row per day, even with 0 orders
SELECT d::date            AS day,
       COUNT(o.order_id)  AS orders
FROM GENERATE_SERIES('2018-01-01'::timestamp,
                     '2018-01-31'::timestamp,
                     INTERVAL '1 day') AS d
LEFT JOIN raw.orders o
  ON  o.order_purchase_timestamp >= d
  AND o.order_purchase_timestamp <  d + INTERVAL '1 day'
GROUP BY d ORDER BY d;

---------------- STRPOS
select strpos('KhinYadanarPhyo','a')  -- 6 

------------- CTE and window-----------
--  lab Question 1
WITH seller_revenue AS (
    SELECT
        s.seller_state,
        s.seller_id,
        SUM(oi.price+oi.freight_value ) AS revenue
    FROM raw.sellers s
    JOIN raw.order_items oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_state,
        s.seller_id
),
seller_rank AS (
    SELECT
        seller_state,
        seller_id,
        revenue,
        RANK() OVER (PARTITION BY seller_state ORDER BY revenue DESC) AS rnk
    FROM seller_revenue
)
SELECT
    seller_state,
    seller_id,
    revenue,
    rnk
FROM seller_rank
WHERE rnk <= 3
ORDER BY  seller_state ,rnk desc ;

-- lab2 

SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp)::DATE AS first_order_date,
    COUNT(o.order_id) over(partition by c.customer_unique_id)as order_count
FROM raw.customers c
JOIN raw.orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY order_count DESC, c.customer_unique_id;








