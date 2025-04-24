{{ config(materialized='incremental', schema='ods') }}

select left(source_name, length(source_name)-26) source_name, -- минус длина строки /location_events.jsonl.zip
       (json_data->>'event_id')::uuid event_id,
        json_data->>'page_url' page_url,
		json_data->>'page_url_path' page_url_path,
		json_data->>'referer_url' referer_url,
		json_data->>'referer_medium' referer_medium,
		json_data->>'utm_medium' utm_medium,
		json_data->>'utm_source' utm_source,
		json_data->>'utm_content' utm_content,
		json_data->>'utm_campaign' utm_campaign
  from {{ source ('stg', 'stg_location_events') }}

{% if is_incremental() %}
WHERE source_name not in (select source_name
 FROM {{ this }})
{% endif %}
