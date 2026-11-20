/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
      This stored procedure does not accept any parameters or return any values.

Usage Example:
   EXEC Silver.load_silver;
===============================================================================
*/
create or alter procedure silver.load_silver as
begin
 DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        -- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
print '>> Truncating Table: silver.crm_cust_info'
truncate table silver.crm_cust_info
print '>> inserting data into: silver.crm_cust_info'
INSERT INTO silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date

)
SELECT 
cst_id,
cst_key,
TRIM (cst_firstname) AS cst_firstname,
TRIM (cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'N/A'
END cst_gndr,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	ELSE 'N/A'
END cst_marital_status,
cst_create_date
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t WHERE flag_last = 1
SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

 -- Loading silver.crm_prd_info
SET @start_time = GETDATE();
print '>> Truncating Table: silver.crm_prd_info'
truncate table silver.crm_prd_info
print '>> inserting data into: silver.crm_prd_info'
insert into silver.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt,
dwh_creat_date
)

SELECT 
	prd_id ,
	replace(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, --extract cat id
	SUBSTRING(prd_key, 7, len(prd_key)) as prd_key, -- extract product key
	-- لان النهاية مختلفة مو مثل الي قبله
	prd_nm,
	isnull(prd_cost,0) as prd_cost,
	case upper(trim(prd_line))
	    when 'M' then 'Mountain'
		when 'R' then 'Road'
		when 'S' then 'Other Sales'
		when 'T' then 'Touring'
		else 'N/A'
	end as prd_line, -- map product line code to descriptive values
cast(prd_start_dt as date) as prd_start_dt,
cast(LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date)as prd_end_dt
   --  calculate end date as one day before the next start date
FROM bronze.crm_prd_info
SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

--WHERE SUBSTRING(prd_key, 7, len(prd_key)) in
--(SELECT sls_prd_key from bronze.crm_sales_details)
--to check the product
--WHERE replace(SUBSTRING(prd_key,1,5),'-','_') NOT IN
--(SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)
-- shows '_' inested of '-' so we will change the key to '_'
 SET @start_time = GETDATE();
print '>> Truncating Table: silver.crm_sales_details'
truncate table silver.crm_sales_details
print '>> inserting data into: silver.crm_sales_details'
insert into silver.crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)

select
sls_ord_num,
sls_prd_key,
sls_cust_id,
case when sls_order_dt = 0
or len(sls_order_dt)!=8 then null
else cast(cast( sls_order_dt as varchar)as date)
end as sls_order_dt,
case when sls_ship_dt = 0
or len(sls_ship_dt)!=8 then null
else cast(cast( sls_ship_dt as varchar)as date)
end as sls_ship_dt,
case when sls_due_dt = 0
or len(sls_due_dt)!=8 then null
else cast(cast( sls_due_dt as varchar)as date)
end as sls_due_dt,
case when sls_sales is null or sls_sales <=0 or sls_sales !=sls_quantity * abs(sls_price)
	then sls_quantity * abs(sls_price)
	else sls_sales
end as sls_sales,
sls_quantity,
case when sls_price is null or sls_price <=0 
	then sls_sales/nullif(sls_quantity,0)
	else sls_price
end as sls_price
from bronze.crm_sales_details
 SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';
 SET @start_time = GETDATE();
print '>> Truncating Table: silver.erp_cust_az12'
truncate table silver.erp_cust_az12
print '>> inserting data into: silver.erp_cust_az12'
insert into silver.erp_cust_az12(cid,bdate,gen)
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
 SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

--where cid like '%AW00011000%'
--extra characters NAS
--select * from [silver].[crm_cust_info];
--where case when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
--	else cid
--end not in (select distinct cst_key from silver.crm_cust_info)
 SET @start_time = GETDATE();
print '>> Truncating Table: silver.erp_loc_a101'
truncate table silver.erp_loc_a101
print '>> inserting data into: silver.erp_loc_a101'
insert into silver.erp_loc_a101(cid,cntry)
select
replace(cid,'-','')cid,
case when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) in ('US','USA') then 'United States'
	when trim(cntry) = '' or cntry is null then 'N/A'
	else trim(cntry)
end as cntry
from bronze.erp_loc_a101
 SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

--where replace(cid,'-','') not in 
--(select cst_key from silver.crm_cust_info)
 SET @start_time = GETDATE();
print '>> Truncating Table: silver.erp_px_g1v2'
truncate table silver.erp_px_g1v2
print '>> inserting data into: silver.erp_px_g1v2'
insert into silver.erp_px_g1v2(id,cat,subcat,maintenance)

select 
id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2
 SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
SET @batch_end_time = GETDATE();
        PRINT '=========================================='
        PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '=========================================='

    END TRY
    BEGIN CATCH
        PRINT '=========================================='
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================='
    END CATCH
end
