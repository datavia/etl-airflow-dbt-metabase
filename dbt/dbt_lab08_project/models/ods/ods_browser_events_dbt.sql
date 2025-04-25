{{ config(materialized='incremental', schema='ods') }}

select load_dttm,
       (json_data->>'event_id')::uuid event_id,
       (json_data->>'event_timestamp')::timestamp event_timestamp,
       json_data->>'event_type' event_type,
       (json_data->>'click_id')::uuid click_id,
       json_data->>'browser_name' browser_name,
       json_data->>'browser_user_agent' browser_user_agent,
       json_data->>'browser_language' browser_language
  from {{ source ('stg', 'stg_browser_events') }}

{% if is_incremental() %}
WHERE load_dttm > (select coalesce(max(load_dttm), '1900-01-01')
 FROM {{ this }})
{% endif %}

