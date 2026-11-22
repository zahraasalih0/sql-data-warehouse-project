-- =============================================================================
-- EXPLORATION / SAMPLE QUERIES (BRONZE LAYER)
-- Purpose: Preview sample rows from Bronze CRM and ERP tables to inspect raw data,
--          column names, data types, and formatting before building transformations for the Silver Layer.
-- Expected Result: Up to 1,000 rows per preview query.
-- =============================================================================
SELECT TOP (1000) [cst_id]
	,[cst_key]
	,[cst_firstname]
	,[cst_lastname]
	,[cst_material_status]
	,[cst_gndr]
	,[cst_create_date]
FROM [DataWarehouse].[bronze].[crm_cust_info]

SELECT TOP (1000) [prd_id]
      ,[cst_key]
      ,[prd_nm]
      ,[prd_cost]
      ,[prd_line]
      ,[prd_start_dt]
      ,[prd_end_dt]
  FROM [DataWarehouse].[bronze].[crm_prd_info]
SELECT TOP (1000) [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
      ,[sls_order_dt]
      ,[sls_ship_dt]
      ,[sls_due_dt]
      ,[sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].[bronze].[crm_sales_details]

SELECT TOP 1000 * FROM bronze.erp_cust_az12
SELECT TOP 1000 * FROM bronze.crm_cust_info

SELECT TOP 1000 * FROM bronze.erp_loc_a101

SELECT TOP 1000 * FROM bronze.erp_px_g1v2
SELECT TOP 1000 * FROM bronze.crm_prd_info


-- =============================================================================
-- TEST 1: Deduplication Ranking Check (crm_cust_info)
-- Purpose: Rank customer records by cst_create_date descending per cst_id using
--          ROW_NUMBER() to identify the latest record (flag_last = 1) vs. duplicates.
-- Expected Result: All rows with an added 'flag_last' ranking column (unfiltered).
-- =============================================================================
SELECT
*
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
-- new column called (flage_last) to get dates of the cst_id in desc order
FROM bronze.crm_cust_info
--WHERE cst_id = 29449 test
)T-- WHERE flag_last !=1 test
-- WHERE flag_last = 1 AND cst_id = 29449 test


-- =============================================================================
-- TEST 2: Primary Key Null & Duplicate Check (bronze.crm_cust_info)
-- Purpose: Check for NULL customer IDs or duplicate cst_id values in raw Bronze data.
-- Expected Result: 0 rows (no NULLs or duplicates in a clean primary key).
-- =============================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result 

SELECT 
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- =============================================================================
-- TEST 3: Primary Key Null & Duplicate Check (silver.crm_prd_info)
-- Purpose: Verify that prd_id in the Silver products table has no NULLs or duplicates.
-- Expected Result: 0 rows (prd_id should be unique and non-null).
-- =============================================================================
select
prd_id,
count(*)
from silver.crm_prd_info
group by prd_id
having count(*)>1 or prd_id is null


-- =============================================================================
-- TEST 4: Cost Validity Check (NULL or Negative Values)
-- Purpose: Detect invalid product costs (negative or NULL) in silver.crm_prd_info.
-- Expected Result: 0 rows (no negative or NULL product costs).
-- =============================================================================
-- check for nulls or negative numbers
-- expectation no results
select prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null


-- =============================================================================
-- TEST 5: Data Standardization Check (Product Line)
-- Purpose: Inspect distinct prd_line values in silver.crm_prd_info to verify
--          consistent naming and standardization.
-- Expected Result: Distinct list of standardized product line values.
-- =============================================================================
--data standradization &consistency
select distinct prd_line
from silver.crm_prd_info


-- =============================================================================
-- TEST 6: Date Range Logic Check (Product Start vs. End Date)
-- Purpose: Identify records where prd_end_dt occurs earlier than prd_start_dt.
-- Expected Result: 0 rows (end dates should never precede start dates).
-- =============================================================================
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt


-- =============================================================================
-- TEST 7: Date Format & Range Validation (sls_order_dt)
-- Purpose: Find malformed or out-of-range integer dates (not 8 digits, <= 0,
--          or outside 1900-01-01 to 2050-01-01) and preview NULLIF(..., 0).
-- Expected Result: 0 rows (all order dates valid 8-digit YYYYMMDD values in range).
-- =============================================================================
--check for invalid dates

select 
nullif(sls_order_dt,0) sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <= 0
or len(sls_order_dt)!=8 
or sls_order_dt > 20500101
or sls_order_dt<19000101
--12345678
--20101211


-- =============================================================================
-- TEST 8: Chronological Order Check (Order, Ship, and Due Dates)
-- Purpose: Detect sales rows where sls_order_dt is later than sls_ship_dt or
--          sls_due_dt.
-- Expected Result: 0 rows (order date should precede or equal ship and due dates).
-- =============================================================================
--check for invalid date orders 
select
*
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt


-- =============================================================================
-- TEST 9: Invalid Order Date Filter Preview (Sales Details)
-- Purpose: Inspect sales records where sls_order_dt is less than or equal to 0.
-- Expected Result: 0 rows (no non-positive order dates).
-- =============================================================================
-- check data consistency : between sales, quantity and price
-- sales = quantity * price
-- values must not be null,zero or negative
select
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_order_dt <= 0


-- =============================================================================
-- TEST 10: Sales, Quantity & Price Consistency + Cleansing Preview
-- Purpose: Find rows where sls_sales != sls_quantity * sls_price or any of the
--          three fields is NULL, zero, or negative, and preview derived fixes.
-- Expected Result: 0 rows in raw data (any returned rows show anomalies and
--                  proposed corrected sales/price values).
-- =============================================================================
select distinct
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price,

case when sls_sales is null or sls_sales <=0 or sls_sales !=sls_quantity * abs(sls_price)
	then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,

case when sls_price is null or sls_price <=0 
	then sls_sales/nullif(sls_quantity,0)
	else sls_price
end as sls_price
from bronze.crm_sales_details
where sls_sales != sls_quantity*sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
order by sls_sales,sls_quantity,sls_price


-- =============================================================================
-- TEST 11: ERP Customer Cleansing Preview (CID, Birthdate & Gender)
-- Purpose: Preview transformations on bronze.erp_cust_az12 by stripping the
--          'NAS' prefix from cid, nullifying future birthdates (> GETDATE()),
--          and standardizing gender values to 'Male', 'Female', or 'N/A'.
-- Expected Result: Cleaned cid, bdate, and gen columns (with commented checks
--                  for a sample customer ID and orphan keys against silver.crm_cust_info).
-- =============================================================================
select 
case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
	else cid
end as cid,
case when bdate > GETDATE() then null
	else bdate
end as bdate,
case when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
	when upper(trim(gen)) in  ('M', 'MALE') then 'Male'
	else 'N/A'
	end as gen
from bronze.erp_cust_az12
--where cid like '%AW00011000%'
--extra characters NAS
--select * from [silver].[crm_cust_info];
--where case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
--	else cid
--end not in (select distinct cst_key from silver.crm_cust_info)
