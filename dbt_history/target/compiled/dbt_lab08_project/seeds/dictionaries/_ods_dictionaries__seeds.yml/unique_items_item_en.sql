
    
    

select
    item_en as unique_field,
    count(*) as n_records

from "lab08_db"."ods"."items"
where item_en is not null
group by item_en
having count(*) > 1


