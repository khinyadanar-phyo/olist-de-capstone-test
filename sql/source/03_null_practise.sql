-- q1. null audit: count nulls in product_category_name and product_weight_g.

select count(*) - count(product_category_name) as null_category,
       count(*) - count(product_weight_g) as null_weight
from products;


-- q2. for each month of purchase, what is the average delivery time, and
-- how many orders (and what percentage) were delivered within 30 days of purchase?

select * from orders;

select
    extract(year from order_purchase_timestamp) as year,
    extract(month from order_purchase_timestamp) as month,
    round(avg(extract(epoch from (
        order_delivered_customer_date - order_purchase_timestamp
    )) / 86400.0)::numeric, 2) as avg_delivery_days,
    count(*) as total_orders,
    count(case
        when order_delivered_customer_date - order_purchase_timestamp
             <= interval '30 days'
        then 1
    end) as within_30_days,
    round(
        count(case
            when order_delivered_customer_date - order_purchase_timestamp
                 <= interval '30 days'
            then 1
        end) * 100.0 / count(*),
        2
    ) as percentage_within_30_days
from orders
where order_status = 'delivered'
group by year, month
order by year, month;


-- q.3 on which day of the week do customers place the most orders? show each weekday's name and number, and the total orders for that day, sorted from busiest to quietest.

select
    extract(dow from order_purchase_timestamp) as weekday_number,
    to_char(order_purchase_timestamp, 'FMDay') as weekday_name,
    count(order_id) as total_orders
from raw.orders
group by
    extract(dow from order_purchase_timestamp),
    to_char(order_purchase_timestamp, 'FMDay')
order by total_orders desc;


-- q.4 what is the total revenue for each product category, shown with its english name? if a category has no english translation, show the original portuguese name instead. if the product has no category at all, show it as 'unknown'.

select
    coalesce(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) as category_name,
    sum(oi.price) as total_revenue
from raw.order_items oi
join raw.products p
    on oi.product_id = p.product_id
left join category_translation t
    on p.product_category_name = t.product_category_name
group by
    coalesce(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    )
order by total_revenue desc;


/* q.5 group delivered orders by delivery speed:

• fast: 7 days or less from purchase to delivery.
• normal: 8 to 14 days.
• slow: 15 to 30 days.
• very slow: more than 30 days.

how many orders fall into each group, and what percentage of the total is each? */

with delivery_groups as (
    select
        order_id,
        case
            when order_delivered_customer_date::date
                 - order_purchase_timestamp::date <= 7
                then 'Fast'
            when order_delivered_customer_date::date
                 - order_purchase_timestamp::date between 8 and 14
                then 'Normal'
            when order_delivered_customer_date::date
                 - order_purchase_timestamp::date between 15 and 30
                then 'Slow'
            else 'Very slow'
        end as delivery_speed
    from raw.orders
    where order_status = 'delivered'
      and order_delivered_customer_date is not null
),

speed_counts as (
    select
        delivery_speed,
        count(*) as total_orders
    from delivery_groups
    group by delivery_speed
)

select
    delivery_speed,
    total_orders,
    round(
        total_orders * 100.0 / sum(total_orders) over (),
        2
    ) as percentage
from speed_counts
order by
    case delivery_speed
        when 'Fast' then 1
        when 'Normal' then 2
        when 'Slow' then 3
        when 'Very slow' then 4
    end;