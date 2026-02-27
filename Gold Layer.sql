SELECT * FROM silver.crm_cust_info;
-- duplicates checking
SELECT cst_id,COUNT(*) FROM 
(SELECT cst_id,
  ci.cst_key, 
 ci.cst_firstname,
 ci.cst_lastname,
 ci.cst_marital_status,
 ci.cst_gndr,
 ci.cst_create_date,
 ca.bdate,
 ca.gen,
 la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid) t GROUP BY cst_id
HAVING COUNT(*) > 1;



-- creation of gold layer view

CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
 ci.cst_marital_status as marital_status,
 CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
 ELSE COALESCE(ca.gen,'n/a')
 END as gender,
 ci.cst_create_date as create_date,
 ca.bdate as birthdate,
 la.cntry as country
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;

-- CREATION OF GOLD VIEW
DROP VIEW gold.dim_products;
CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key)
 AS product_key,
pn.prd_id as product_id,
pn.prd_key as product_number, 
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as sub_category,
pc.maintenance as maintenance,
pn.prd_cost as product_cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
FROM 
silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;
 
 
 -- 
 DROP VIEW gold.fact_sales;
CREATE VIEW gold.fact_sales AS 
SELECT 
 sd.sls_ord_num as order_number,
 cu.customer_key,
 sd.sls_order_dt as order_date,
 sd.sls_ship_dt as shipping_date,
 sd.sls_due_dt as due_date,
 sd.corrected_sls_sales as sales_amount,
 sd.corrected_sls_price as price,
 sd.sls_quantity as sales_quantity
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
  ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
  ON sd.sls_cust_id = cu.customer_id;
