


with distinct_clicks as (
    select distinct
        click_id,
        device_type
    from "lab08_db"."ods"."ods_device_events"
)

select
    e.load_hour,
    e.event_id,
    e.event_type,
    e.event_timestamp,
    e.browser_name,
    d.device_type,
    EXTRACT(hour from e.event_timestamp) as event_hour
from "lab08_db"."ods"."ods_browser_events" as e
inner join distinct_clicks as d on e.click_id = d.click_id

    where load_hour >= '2025-04-30T08:00:00' and load_hour < '2025-04-30T09:00:00'
