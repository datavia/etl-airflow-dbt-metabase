{{ config(materialized='incremental', schema='ods') }}

with sources as (select distinct source_name
				   from mart_ods.ods_browser_events_dbt)
select e.source_name,
      left(e.source_name, length(e.source_name)-25) source_pref, -- минус длина строки /browser_events.jsonl.zip
       (json_data->>'event_id')::uuid event_id,
       (json_data->>'event_timestamp')::timestamp event_timestamp,
       json_data->>'event_type' event_type,
       (json_data->>'click_id')::uuid click_id,
       json_data->>'browser_name' browser_name,
       json_data->>'browser_user_agent' browser_user_agent,
       json_data->>'browser_language' browser_language
  from {{ source ('stg', 'stg_browser_events') }} e
  left join sources s 
    on s.source_name = e.source_name
  WHERE s.source_name is null 
