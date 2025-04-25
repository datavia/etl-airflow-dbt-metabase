{{ config(materialized='incremental', schema='ods') }}

select load_dttm,
       (json_data->>'click_id')::uuid click_id,
        (json_data->>'geo_latitude')::float geo_latitude,
        (json_data->>'geo_longitude')::float geo_longitude,
        json_data->>'geo_country' geo_country,
        json_data->>'geo_timezone' geo_timezone,
        json_data->>'geo_region_name' geo_region_name,
        json_data->>'ip_address' ip_address
  from {{ source ('stg', 'stg_geo_events') }}

{% if is_incremental() %}
WHERE load_dttm > (select coalesce(max(load_dttm), '1900-01-01')
 FROM {{ this }})
{% endif %}


