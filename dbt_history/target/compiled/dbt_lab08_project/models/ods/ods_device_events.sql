


select
    load_dttm as load_hour,
    (json_data ->> 'click_id')::uuid as click_id,
    (json_data ->> 'device_is_mobile')::bool as device_is_mobile,
    (json_data ->> 'user_domain_id')::uuid as user_domain_id,
    json_data ->> 'os' as os,
    json_data ->> 'os_name' as os_name,
    json_data ->> 'os_timezone' as os_timezone,
    json_data ->> 'device_type' as device_type,
    json_data ->> 'user_custom_id' as user_custom_id
from "lab08_db"."stg"."stg_device_events"


    where load_dttm >= '2025-04-26T12:00:00' and load_dttm < '2025-04-28T09:00:00'
