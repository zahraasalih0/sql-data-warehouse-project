select distinct
ci.cst_gndr,
ca.gen,
	case when ci.cst_gndr != ca.gen then ci.cst_gndr
	else coalesce(ca.gen,'n/a')
end as new_gen
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on		  ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on		  ci.cst_key=la.cid


select  prd_key,count(*) from(
select
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
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is null --filter out all historical date
)t group by prd_key 
having count(*)>1
