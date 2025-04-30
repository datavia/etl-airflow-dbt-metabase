select
    load_dttm as load_hour,
    (json_data ->> 'click_id')::uuid as click_id,
    (json_data ->> 'geo_latitude')::float as geo_latitude,
    (json_data ->> 'geo_longitude')::float as geo_longitude,
    json_data ->> 'geo_country' as geo_country,
    json_data ->> 'geo_timezone' as geo_timezone,
    json_data ->> 'geo_region_name' as geo_region_name,
    json_data ->> 'ip_address' as ip_address
from {{ source ('stg', 'stg_geo_events') }}

{% if is_incremental() %}
    where load_dttm >= '{{ start_date }}' and load_dttm < '{{ end_date }}'
{% endif %}
