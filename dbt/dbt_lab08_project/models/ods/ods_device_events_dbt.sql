{{ config(materialized='incremental', schema='ods') }}

with sources as (select distinct source_name
				   from mart_ods.ods_device_events_dbt)
select e.source_name,
		left(e.source_name, length(e.source_name)-24) source_pref, -- минус длина строки /device_events.jsonl.zip
       (json_data->>'click_id')::uuid click_id,
	    json_data->>'os' os,
		json_data->>'os_name' os_name,
		json_data->>'os_timezone' os_timezone,
		json_data->>'device_type' device_type,
		(json_data->>'device_is_mobile')::bool device_is_mobile,
		json_data->>'user_custom_id' user_custom_id,
		(json_data->>'user_domain_id')::uuid user_domain_id
  from {{ source ('stg', 'stg_device_events') }} e
  left join sources s 
    on s.source_name = e.source_name
  WHERE s.source_name is null 
