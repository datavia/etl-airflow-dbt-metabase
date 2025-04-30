{% set start_date = var("start_date") %}
{% set end_date = var("end_date") %}

with distinct_clicks as (
    select distinct
        click_id,
        device_type
    from {{ ref('ods_device_events') }}
)

select
    e.load_hour,
    e.event_id,
    e.event_type,
    e.event_timestamp,
    e.browser_name,
    d.device_type,
    EXTRACT(hour from e.event_timestamp) as event_hour
from {{ ref('ods_browser_events') }} as e
inner join distinct_clicks as d on e.click_id = d.click_id
{% if is_incremental() %}
    where load_hour >= '{{ start_date }}' and load_hour < '{{ end_date }}'
{% endif %}
