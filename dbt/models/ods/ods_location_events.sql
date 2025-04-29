select
    load_dttm as load_hour,
    (json_data ->> 'event_id')::uuid as event_id,
    json_data ->> 'page_url' as page_url,
    json_data ->> 'page_url_path' as page_url_path,
    json_data ->> 'referer_url' as referer_url,
    json_data ->> 'referer_medium' as referer_medium,
    json_data ->> 'utm_medium' as utm_medium,
    json_data ->> 'utm_source' as utm_source,
    json_data ->> 'utm_content' as utm_content,
    json_data ->> 'utm_campaign' as utm_campaign
from {{ source ('stg', 'stg_location_events') }}

{% if is_incremental() %}
    where load_dttm > (
        select coalesce(max(load_hour), '1900-01-01')
        from {{ this }}
    )
{% endif %}
