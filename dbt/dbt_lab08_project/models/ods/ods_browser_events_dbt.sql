{{ config(materialized='incremental', schema='ods') }}

select left(source_name, length(source_name)-25) source_name, -- минус длина строки /browser_events.jsonl.zip
       (json_data->>'event_id')::uuid event_id,
       (json_data->>'event_timestamp')::timestamp event_timestamp,
       json_data->>'event_type' event_type,
       (json_data->>'click_id')::uuid click_id,
       json_data->>'browser_name' browser_name,
       json_data->>'browser_user_agent' browser_user_agent,
       json_data->>'browser_language' browser_language
  from {{ source ('stg', 'stg_browser_events') }}

{% if is_incremental() %}
WHERE source_name not in (select source_name
 FROM {{ this }})
{% endif %}
