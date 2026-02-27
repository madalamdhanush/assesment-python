CREATE DATABASE DataWarehouse;
USE DataWarehouse;

CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
USE bronze;
SELECT * FROM cust_info;





CREATE TABLE bronze.crm_cust_info(
cst_id INT, 
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
 cst_lastname VARCHAR(50),
 cst_marital_status VARCHAR(20),
 cst_gndr VARCHAR(50), 
 cst_create_date DATE
);

INSERT INTO bronze.crm_cust_info
SELECT * FROM silver.crm_cust_info;

DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id INT,
 prd_key VARCHAR(50),
 prd_nm VARCHAR(50), 
 prd_cost INT, 
 prd_line VARCHAR(50),
 prd_start_dt VARCHAR(50), 
 prd_end_dt VARCHAR(50)
);


INSERT INTO  bronze.crm_prd_info
SELECT * FROM silver.crm_prd_info;

SELECT * FROM bronze.crm_prd_info;
SELECT * FROM sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num VARCHAR(50),
 sls_prd_key VARCHAR(50),
 sls_cust_id INT,
 sls_order_dt INT,
 sls_ship_dt INT,
 sls_due_dt INT,
 sls_sales INT,
 sls_quantity INT,
 sls_price INT
);

INSERT INTO bronze.crm_sales_details
SELECT * FROM silver.crm_sales_details;
SELECT * FROM  bronze.crm_sales_details;
SELECT * FROM cust_az12;
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
cid VARCHAR(50),
 bdate DATE, 
 gen VARCHAR(50)
);

INSERT INTO bronze.erp_cust_az12
SELECT * FROM silver.erp_cust_az12;

SELECT * FROM bronze.erp_cust_az12;

DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
cid VARCHAR(50),
cntry VARCHAR(50)
);
INSERT INTO bronze.erp_loc_a101
SELECT * FROM silver.erp_loc_a101;
SELECT * FROM bronze.erp_loc_a101;
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
id VARCHAR(50), 
cat  VARCHAR(50),
subcat VARCHAR(50),
maintenance VARCHAR(50)
);
INSERT INTO bronze.erp_px_cat_g1v2
SELECT * FROM silver.erp_px_cat_g1v2;
SELECT * FROM bronze.erp_px_cat_g1v2;





