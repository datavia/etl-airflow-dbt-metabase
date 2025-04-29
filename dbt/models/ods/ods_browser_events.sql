select
    load_dttm as load_hour,
    (json_data ->> 'event_id')::uuid as event_id,
    (json_data ->> 'event_timestamp')::timestamp as event_timestamp,
    (json_data ->> 'click_id')::uuid as click_id,
    json_data ->> 'event_type' as event_type,
    json_data ->> 'browser_name' as browser_name,
    json_data ->> 'browser_user_agent' as browser_user_agent,
    json_data ->> 'browser_language' as browser_language
from {{ source ('stg', 'stg_browser_events') }}

{% if is_incremental() %}
    where load_dttm > (
        select COALESCE(MAX(load_hour), '1900-01-01')
        from {{ this }}
    )
{% endif %}
