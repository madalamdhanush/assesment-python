use data_anaytics;
-- gold layer
SELECT * FROM dim_customers;
SELECT * FROM dim_products;
SELECT * FROM fact_sales;
-- Sales per each month with customes and quantity
SELECT 
DATE_FORMAT(order_date,'%Y-%b') as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL  AND order_date <> ' '
GROUP BY DATE_FORMAT(order_date,'%Y-%b') 
ORDER BY DATE_FORMAT(order_date,'%Y-%b');

-- caluclate sales per each month
-- running sales over each time

SELECT 
order_month,
total_sales,
SUM(total_sales) OVER (ORDER BY order_month) AS 
running_total_sales,
avg_price
FROM
(
SELECT
DATE_FORMAT(order_date,'%Y-%b') as order_month,
COUNT(sales_amount) as total_sales,
AVG(price) as avg_price
FROM fact_sales
WHERE DATE_FORMAT(order_date,'%Y-%b') IS NOT NULL OR ' '
GROUP BY DATE_FORMAT(order_date,'%Y-%b')
ORDER BY DATE_FORMAT(order_date,'%Y-%b')
) t; 

-- performance analysis

/* Analyze the yearly performance of products by comparing their sales
*/

-- linking of cutomers and products
SELECT * FROM dim_customers;
SELECT * FROM dim_products;

SELECT d.first_name,d.last_name,p.product_name
FROM dim_customers d
JOIN dim_products p
ON d.customer_key = p.product_key;

WITH yearly_product_sales AS(
SELECT
DATE_FORMAT(f.order_date,'%Y') AS order_year,
d.product_name,
SUM(f.sales_amount) as current_sales
FROM fact_sales f
LEFT JOIN dim_products d
ON f.product_key = d.product_key
WHERE DATE_FORMAT(f.order_date,'%Y') IS NOT NULL OR ' '
GROUP BY DATE_FORMAT(f.order_date,'%Y'),d.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales- AVG(current_sales) 
OVER(PARTITION BY product_name) as  diff_avg,
CASE WHEN current_sales- AVG(current_sales) 
OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
WHEN  current_sales- AVG(current_sales) 
OVER(PARTITION BY product_name) < 0 THEN'Below Avg'
ELSE 'Avg'
END as avg_price_proccured,

-- year-over year sales 

LAG(current_sales) OVER 
(PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales-LAG(current_sales) OVER 
(PARTITION BY product_name ORDER BY order_year) as diff_yr,
CASE WHEN current_sales-LAG(current_sales) OVER 
(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'increasing'
WHEN current_sales-LAG(current_sales) OVER 
(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'decreasinf'
ELSE 'neutral'
END as py_change
FROM yearly_product_sales
ORDER BY 2,1;


-- part to whole anaylsis

-- categories contribute to the most overall sales

SELECT * FROM fact_sales;
SELECT * FROM dim_products;


WITH category_sales AS (
SELECT 
p.category,
SUM(f.sales_amount) as total_sales
FROM  dim_products p
JOIN fact_sales f
ON p.product_key = f.product_key
GROUP BY p.category
)
SELECT category,
total_sales,
SUM(total_sales) OVER () overall_sales,
(total_sales/SUM(total_sales) OVER ()) * 100 AS percentage
FROM category_sales
ORDER BY total_sales DESC;

-- data segementation
/* segement products into cost ranges and 
count how many products fall into each segement
*/


SELECT * FROM dim_products;
SELECT * FROM fact_sales;

WITH product_segment as(
SELECT 
product_key,
product_name,
category,
CASE WHEN cost < 100 THEN 'Below 100'
WHEN cost BETWEEN  100 AND 500 THEN '100-500'
WHEN cost BETWEEN  500 AND 1000 THEN '500-1000'
ELSE 'Above 1000'
END as cost_range
FROM dim_products
)
SELECT 
cost_range,
COUNT(product_key) AS total_product
FROM 
product_segment
GROUP BY cost_range
ORDER BY total_product DESC;

/*
VIP:customers with at least 12 months of history and
 spending more than 5000
Regular: least 12 months and spending less than 5000
New: Customers with lifespan less than 12 months
*/
SELECT * FROM fact_sales;
SELECT * FROM dim_products;
SELECT * FROM dim_customers;

WITH person AS(
SELECT 
c.customer_key,
SUM(f.sales_amount) as total_spending,
MIN(order_date) first_date,
MAX(order_date) last_date,
TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) as lifespan
FROM fact_sales f
LEFT JOIN dim_customers c
ON f.customer_key = c.customer_key
Group BY c.customer_key
)
SELECT  
customer_key,
total_spending,
lifespan,
CASE
WHEN total_spending > 5000 AND lifespan > 12 THEN 'VIP'
WHEN total_spending < 5000 AND lifespan >= 12 THEN 'Regular'
ELSE 'New'
END segements 
FROM person;

-- report
/*
names,ages and transcation details
vip,new and age
total -orders
total sales
total products
lifespan
recency(months scienec last order)
average order values
average monthly spend
*/


-- Names,ages and transcations

CREATE VIEW gold.report_customers as
WITH base_query as(
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) as customer_name,
TIMESTAMPDIFF(YEAR,c.birthdate,CURDATE())  as age
FROM dim_customers c
JOIN fact_sales f
ON c.customer_key = f.customer_key
),
customer_aggregation as(
SELECT 
customer_key,
customer_name,
age ,
customer_number,
COUNT(DISTINCT order_number) as total_orders,
SUM(sales_amount) as total_sales,
SUM(quantity) as total_quantity,
COUNT(DISTINCT product_key) as total_products,
MAX(order_date) as last_order_date,
TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key,
customer_name,
age ,
customer_number
)
SELECT 
customer_key,
customer_name,
age,
CASE 
WHEN age < 20 THEN 'UNDER 20'
WHEN  age between 20 and 29 THEN '20-29'
WHEN  age between 30 and 39 THEN '30-39'
WHEN  age between 40 and 49 THEN '40-49'
ELSE '50 and above'
END as age_group,
CASE 
WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
WHEN  lifespan >= 12 AND total_sales < 5000 THEN 'Regular'
ELSE 'New'
END as customer_segement,
customer_number,
total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
TIMESTAMPDIFF(MONTH,last_order_date,CURDATE()) as recency,
lifespan,
CASE 
WHEN total_sales= 0 THEN 0
ELSE 'total_sales/total_orders' 
END as avg_order_value,
CASE WHEN lifespan = 0 THEN total_sales
ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation ;

-- Customer report

SELECT * FROM gold.report_customers;

-- product report

CREATE VIEW gold.product_report AS
WITH base_query AS(
SELECT 
p.product_name,
p.category,
p.subcategory,
p.cost ,
p.product_key,
f.sales_amount,
f.quantity,
f.price,
f.order_number,
f.order_date,
f.customer_key
FROM dim_products p
LEFT JOIN fact_sales f 
ON p.product_key = f.product_key
WHERE TIMESTAMP(order_date) IS NOT NULL
),

product_aggregation AS(
SELECT 
product_key,
product_name,
category,
subcategory,
cost,
TIMESTAMPDIFF(YEAR,MIN(order_date),MAX(order_date)) AS lifespan,
MAX(order_date) as last_sale_date,
MIN(order_date) as first_sale_date,
COUNT(DISTINCT order_number ) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity
FROM base_query
GROUP BY 
product_key,
product_name,
category,
subcategory,
cost
)

SELECT 
product_key,
product_name,
category,
subcategory,
TIMESTAMPDIFF(MONTH,last_sale_date,CURDATE()) as recency,
CASE 
WHEN total_sales > 100000 THEN 'High range Performer'
WHEN total_sales >=1000 THEN 'Mid Range Performer'
ELSE 'Low performer'
END as product_segement,
cost,
lifespan,
total_orders,
total_quantity,
total_customers
 FROM product_aggregation;