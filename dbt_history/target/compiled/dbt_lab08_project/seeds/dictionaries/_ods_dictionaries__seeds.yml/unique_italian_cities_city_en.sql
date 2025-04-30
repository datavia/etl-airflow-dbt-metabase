
    
    

select
    city_en as unique_field,
    count(*) as n_records

from "lab08_db"."ods"."italian_cities"
where city_en is not null
group by city_en
having count(*) > 1


