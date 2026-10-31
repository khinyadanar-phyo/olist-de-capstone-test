------------- lab question -------------

-- Q1 . for each seller state, find the 3 sellers who earned the most revenue.

select * from sellers;

select * from order_items; -- price + freight value

-- rank inside each state, highest revenue first, with rank()

-- ties share a rank, so a state can show more than 3 sellers

with total_revenue as (
    select s.seller_id, s.seller_state, sum(oi.price + oi.freight_value) as revenue
    from sellers s
    join order_items oi on s.seller_id = oi.seller_id
    group by s.seller_id, s.seller_state
    order by revenue
)

select seller_id, seller_state, revenue, rank() over (partition by seller_state order by revenue desc)
from total_revenue;

-----------------------

--Q2. for every customer, show the date of their first order and how many orders they placed in total.

with customer_orders as (
    select
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp::date as order_date,
        count(*) over (
            partition by c.customer_unique_id
        ) as total_orders,
        row_number() over (
            partition by c.customer_unique_id
            order by o.order_purchase_timestamp, o.order_id
        ) as rn
    from raw.customers c
    join raw.orders o
        on c.customer_id = o.customer_id
)

select
    customer_unique_id,
    order_id,
    order_date as first_order_date,
    total_orders, rn
from customer_orders
where rn = 1;

-----------------------

--Q3. for each seller, show how their revenue adds up over time, order by order.

with seller_order_revenue as (
    select
        oi.seller_id,
        o.order_id,
        o.order_purchase_timestamp as order_time,
        sum(oi.price + oi.freight_value) as order_revenue
    from raw.order_items oi
    join raw.orders o
        on oi.order_id = o.order_id
    group by
        oi.seller_id,
        o.order_id,
        o.order_purchase_timestamp
)

select
    seller_id,
    order_id,
    order_time,
    order_revenue,
    sum(order_revenue) over (
        partition by seller_id
        order by order_time, order_id
        rows between unbounded preceding and current row
    ) as running_total
from seller_order_revenue
order by seller_id, order_time, order_id;

------------

-- Q 4. what percentage of all money paid came from each payment type?

select * from order_payments op; -- payment_type, payment_value

select
    payment_type,
    sum(payment_value) as total_paid,
    round(
        sum(payment_value) * 100.0 /
        sum(sum(payment_value)) over (),
        2
    ) as percentage
from raw.order_payments
group by payment_type
order by percentage desc;

------------

-- Q5. find the order items whose price is higher than the average price in their product category.

select * from products;

select * from order_items;

with item_category_avg as (
    select
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        p.product_category_name,
        oi.price,
        round(
            avg(oi.price) over (
                partition by p.product_category_name
            ),
            2
        ) as category_avg
    from raw.order_items oi
    join raw.products p
        on oi.product_id = p.product_id
)

select *
from item_category_avg
where price > category_avg
order by product_category_name, price desc;