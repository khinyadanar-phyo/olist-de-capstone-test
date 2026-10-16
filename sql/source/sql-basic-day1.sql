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
