
/*
===================================================================
DDL Script: Create Bronze Tables
===================================================================
Script Purpose:
This script creates the 'bronze' schema, dropping existing tables
if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
==================================================================
*/
IF OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
 -- U= user
CREATE TABLE bronze.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_material_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);
GO
IF OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id INT,
cst_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);
GO
IF OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);
GO
IF OBJECT_ID ('bronze.erp_cust_az101' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
cid NVARCHAR(50),
bdate NVARCHAR(50),
gen NVARCHAR(50),
);
GO
IF OBJECT_ID ('bronze.erp_loc_az101' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
cid NVARCHAR(50),
cntry NVARCHAR(50),
);
GO
IF OBJECT_ID ('bronze.erp_px_g1v2' , 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_g1v2;
CREATE TABLE bronze.erp_px_g1v2(
id NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR(50),
);
GO
  
EXEC bronze.load_bronze
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
--to take all the load at once
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_time_start DATETIME,@batch_time_end DATETIME;
	--to calculate how much it takes to load the data
	BEGIN TRY
	--for errors
	SET @batch_time_start = GETDATE();
		PRINT '=================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=================================================';

		PRINT '-------------------------------------------------';
		PRINT 'Loading CRM Tables'
		PRINT '-------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		--to not make a duplicate

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		--direct load
		FROM 'C:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>---------------------'
		-- find the first time then the last time and calculate the diffrince between them

		--SELECT * FROM bronze.crm_cust_info
		--SELECT COUNT(*) FROM bronze.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>---------------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data Into: crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>---------------------'
		PRINT '-------------------------------------------------';
		PRINT 'Loading ERP Tables'
		PRINT '-------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>---------------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>---------------------'
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_g1v2';
		TRUNCATE TABLE bronze.erp_px_g1v2;
		PRINT '>> Inserting Data Into: bronze.erp_px_g1v2';
		BULK INSERT bronze.erp_px_g1v2
		FROM 'C:\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
	);
	SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>>---------------------'

	SET @batch_time_end = GETDATE()
	PRINT '=============================================='
	PRINT 'Loading Bronzer Layer Completed';

	PRINT '>> Total load Duration: ' + CAST(DATEDIFF(second, @batch_time_start, @batch_time_end) AS NVARCHAR) + ' seconds';
	PRINT '=============================================='
	END TRY
		BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message'+ERROR_MESSAGE();
		PRINT 'Error Message'+CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message'+CAST (ERROR_STATE() AS NVARCHAR);
		END CATCH
END
