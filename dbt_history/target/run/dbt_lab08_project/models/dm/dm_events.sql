
      insert into "lab08_db"."dm"."dm_events" ("load_hour", "event_id", "event_type", "event_timestamp", "browser_name", "device_type", "event_hour")
    (
        select "load_hour", "event_id", "event_type", "event_timestamp", "browser_name", "device_type", "event_hour"
        from "dm_events__dbt_tmp145807183807"
    )


  