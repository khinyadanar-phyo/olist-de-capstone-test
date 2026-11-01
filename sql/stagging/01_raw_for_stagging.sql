                   -- we will undo everything later
 
-- 4a · data changes in the source
UPDATE raw.sellers
SET seller_city = 'curitiba'
WHERE seller_id = '3442f8959a84dea7ee197c632cb2df15';
select * from sellers where seller_id = '3442f8959a84dea7ee197c632cb2df15';
 
-- run the Task 2 UPSERT
 
-- check the changed row
SELECT seller_id, city, state, updated_at
FROM staging.sellers
WHERE seller_id = '3442f8959a84dea7ee197c632cb2df15';

-- 4b · a brand-new seller arrives
INSERT INTO raw.sellers
  (seller_id, seller_zip_code_prefix, seller_city, seller_state)
VALUES ('demo_seller_01', '01001', 'santos', 'SP');
 
select count(*) from order_reviews t  -- 99224
-- run the Task 2 UPSERT
SELECT COUNT(*) FROM staging.sellers;
 
-- one check for everything: does staging match raw?
SELECT COUNT(*) AS rows_differ
FROM raw.sellers r
LEFT JOIN staging.sellers s USING (seller_id)
WHERE (r.seller_city, r.seller_state)
      IS DISTINCT FROM (s.city, s.state);
 
ROLLBACK;
SELECT (SELECT COUNT(*) FROM raw.sellers)     AS raw_rows,
       (SELECT COUNT(*) FROM staging.sellers) AS staging_rows;

