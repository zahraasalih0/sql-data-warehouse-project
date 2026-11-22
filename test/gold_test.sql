-- =============================================================================
-- TEST 1: Data Integration & Standardization Check (Gender)
-- Purpose: Verify the business logic for resolving gender conflicts between CRM and ERP sources.
-- Expected Result: Distinct combinations of gender values where CRM takes precedence if mismatched, 
--                  and nulls are handled gracefully as 'n/a'.
-- =============================================================================
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE 
        WHEN ci.cst_gndr != ca.gen THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;


-- =============================================================================
-- TEST 2: Uniqueness & Duplicate Check (Active Products)
-- Purpose: Ensure there are no duplicate product keys among currently active products (where end date is null).
-- Expected Result: 0 rows (no duplicate prd_key values should exist).
-- =============================================================================
SELECT 
    prd_key,
    COUNT(*) 
FROM (
    SELECT
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pn.prd_end_dt,
        pc.cat,
        pc.maintenance
    FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id
    WHERE prd_end_dt IS NULL -- Filter out all historical data
) t 
GROUP BY prd_key 
HAVING COUNT(*) > 1;


-- =============================================================================
-- TEST 3: Referential Integrity Check (Gold Layer Star Schema)
-- Purpose: Check for orphaned records in the fact_sales table that do not match any product in dim_products.
-- Expected Result: 0 rows (all sales records must link to a valid product dimension).
-- =============================================================================
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL;
