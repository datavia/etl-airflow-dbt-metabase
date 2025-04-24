{{ config(materialized='incremental', schema='ods') }}

with sources as (select distinct source_name
				   from mart_ods.ods_location_events_dbt)
select e.source_name,
       left(e.source_name, length(e.source_name)-26) source_pref, -- минус длина строки /location_events.jsonl.zip
       (json_data->>'event_id')::uuid event_id,
        json_data->>'page_url' page_url,
		json_data->>'page_url_path' page_url_path,
		json_data->>'referer_url' referer_url,
		json_data->>'referer_medium' referer_medium,
		json_data->>'utm_medium' utm_medium,
		json_data->>'utm_source' utm_source,
		json_data->>'utm_content' utm_content,
		json_data->>'utm_campaign' utm_campaign
  from {{ source ('stg', 'stg_location_events') }} e
  left join sources s 
    on s.source_name = e.source_name
  WHERE s.source_name is null 
