

# Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
# Total orders : Weekday Vs Weekend
# Average payment_value : Weekday Vs Weekend

# Total Number of Orders with review score 5 and payment type as credit card.

# Average number of days taken for order_delivered_customer_date for pet_shop

# Average price and payment values from customers of sao paulo city

# Relationship between shipping days Vs review scores.
# shipping days = order_delivered_customer_date - order_purchase_timestamp


# Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
SELECT kpi1.day_end,
       CONCAT(ROUND(kpi1.total_payment / 
              (SELECT SUM(payment_value) FROM olist_order_payments_dataset) * 100, 2), '%') 
       AS percentage_payment_values
FROM (
    SELECT ord.day_end, 
           SUM(pmt.payment_value) AS total_payment
    FROM olist_order_payments_dataset AS pmt
    JOIN (
        SELECT DISTINCT order_id,
               CASE 
                   WHEN WEEKDAY(order_purchase_timestamp) IN (5,6) THEN "Weekend"
                   ELSE "Weekday"
               END AS day_end
        FROM olist_orders_dataset
    ) AS ord 
    ON ord.order_id = pmt.order_id
    GROUP BY ord.day_end
) AS kpi1;

# Total Number of Orders with review score 5 and payment type as credit card.

select
count(pmt.order_id) as total_orders
from olist_order_payments_dataset pmt 
inner join olist_order_reviews_dataset rev on pmt.order_id = rev.order_id
where rev.review_score = 5 
and pmt.payment_type =  'credit_card' ;

# Average number of days taken for order_delivered_customer_date for pet_shop
SELECT 
    prod.product_category_name,
    ROUND(AVG(DATEDIFF(ord.order_delivered_customer_date, ord.order_purchase_timestamp)), 0) AS Avg_delivery_days
FROM olist_orders_dataset ord
JOIN (
    SELECT 
        product_id, 
        order_id, 
        product_category_name
    FROM olist_products_dataset
    JOIN olist_order_items_dataset USING(product_id)
) AS prod
ON ord.order_id = prod.order_id
WHERE prod.product_category_name = 'Pet_shop'
GROUP BY prod.product_category_name;

# Average price and payment values from customers of sao paulo city
WITH order_item_avg AS (
    SELECT ROUND(Avg(itam.price)) AS average_item_price
    FROM olist_order_items_dataset itam
    JOIN olist_orders_dataset ord ON itam.order_id = ord.order_id
    JOIN olist_customers_dataset cus ON ord.customer_id = cus.customer_id
    WHERE cus.customer_city = "sao paulo"
)
SELECT 
    (SELECT AVG(average_item_price) FROM order_item_avg) AS avg_order_item_price,
    ROUND(AVG(pmt.payment_value)) AS avg_payment_value
FROM olist_order_payments_dataset pmt
JOIN olist_orders_dataset ord ON pmt.order_id = ord.order_id
JOIN olist_customers_dataset cust ON ord.customer_id = cust.customer_id
WHERE cust.customer_city = "sao paulo";

# Relationship between shipping days Vs review scores.
Select
rew.review_score,
round(avg(datediff(ord.order_delivered_customer_date , order_purchase_timestamp)),0) as "avg_Shipping_days"
from olist_orders_dataset as ord 
join olist_order_reviews_dataset as rew on rew.order_id = ord.order_id
group by rew.review_score
order by rew.review_score ; 

