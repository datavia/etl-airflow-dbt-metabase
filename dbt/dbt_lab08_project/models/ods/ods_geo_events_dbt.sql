{{ config(materialized='incremental', schema='ods') }}

with sources as (select distinct source_name
				   from mart_ods.ods_geo_events_dbt)
select e.source_name,
	   left(e.source_name, length(e.source_name)-21) source_pref, -- минус длина строки /geo_events.jsonl.zip
       (json_data->>'click_id')::uuid click_id,
	   (json_data->>'geo_latitude')::float geo_latitude,
	   (json_data->>'geo_longitude')::float geo_longitude,
	   json_data->>'geo_country' geo_country,
	   json_data->>'geo_timezone' geo_timezone,
	   json_data->>'geo_region_name' geo_region_name,
	   json_data->>'ip_address' ip_address
  from {{ source ('stg', 'stg_geo_events') }} e
  left join sources s 
    on s.source_name = e.source_name
  WHERE s.source_name is null 
