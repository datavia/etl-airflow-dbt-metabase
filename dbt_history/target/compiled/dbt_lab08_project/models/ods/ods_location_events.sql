


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
from "lab08_db"."stg"."stg_location_events"


    where load_dttm >= '2025-04-26T12:00:00' and load_dttm < '2025-04-28T09:00:00'
