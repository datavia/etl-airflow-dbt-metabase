
    
    

select
    sale_custom_id as unique_field,
    count(*) as n_records

from "lab08_db"."dm"."dm_sales"
where sale_custom_id is not null
group by sale_custom_id
having count(*) > 1


