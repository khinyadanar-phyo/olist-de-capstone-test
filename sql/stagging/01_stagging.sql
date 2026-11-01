CREATE TABLE staging.sellers (
  seller_id   TEXT PRIMARY KEY,   -- conflict target
  city        TEXT,
  state       TEXT,
  updated_at  TIMESTAMP DEFAULT now()
); -- step1
 
INSERT INTO staging.sellers (seller_id, city, state)
VALUES ('s1', 'campinas', 'SP')
ON CONFLICT (seller_id) DO UPDATE
SET city       = EXCLUDED.city,
    state      = EXCLUDED.state,
    updated_at = now(); -- step 2

select * from sellers -- step 3,5

select * from sellers where seller_id='3442f8959a84dea7ee197c632cb2df15'

INSERT INTO staging.sellers (seller_id, city, state)
SELECT seller_id, seller_city, seller_state
FROM raw.sellers
ON CONFLICT (seller_id) DO UPDATE
SET city       = EXCLUDED.city,
    state      = EXCLUDED.state,
    updated_at = now()
WHERE (staging.sellers.city, staging.sellers.state)
      IS DISTINCT FROM
      (EXCLUDED.city, EXCLUDED.state);
-- step 4, step6( assume that pipeline is fail and run again)
      
select count(*) from sellers -- 3096, after adding demonseller it turned into 3097

DROP TABLE IF EXISTS staging.reviews;
CREATE TABLE staging.reviews (
  review_id    TEXT PRIMARY KEY,
  order_id     TEXT,
  review_score INT,
  answered_at  TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT now()
);
 select count(*) from reviews 
-- E1 · simple UPSERT (fails on purpose)
INSERT INTO staging.reviews (review_id, order_id, review_score, answered_at)
SELECT review_id, order_id, review_score, review_answer_timestamp
FROM raw.order_reviews
ON CONFLICT (review_id) DO UPDATE
SET order_id = EXCLUDED.order_id, review_score = EXCLUDED.review_score,
    answered_at = EXCLUDED.answered_at;
 
-- E2 · why? count the duplicates
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT review_id) AS distinct_reviews
FROM raw.order_reviews;

-- query to solve insert error --
WITH dedup AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY review_id
                            ORDER BY review_answer_timestamp DESC,
                                     order_id) AS rn
  FROM raw.order_reviews
)
INSERT INTO staging.reviews (review_id, order_id, review_score, answered_at)
SELECT review_id, order_id, review_score, review_answer_timestamp
FROM dedup
WHERE rn = 1
ON CONFLICT (review_id) DO UPDATE
SET order_id     = EXCLUDED.order_id,
    review_score = EXCLUDED.review_score,
    answered_at  = EXCLUDED.answered_at,
    updated_at   = now()
WHERE (staging.reviews.order_id, staging.reviews.review_score,
       staging.reviews.answered_at)
      IS DISTINCT FROM
      (EXCLUDED.order_id, EXCLUDED.review_score, EXCLUDED.answered_at);




