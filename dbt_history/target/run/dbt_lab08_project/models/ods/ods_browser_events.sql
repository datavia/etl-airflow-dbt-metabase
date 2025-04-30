
      insert into "lab08_db"."ods"."ods_browser_events" ("load_hour", "event_id", "event_timestamp", "click_id", "event_type", "browser_name", "browser_user_agent", "browser_language")
    (
        select "load_hour", "event_id", "event_timestamp", "click_id", "event_type", "browser_name", "browser_user_agent", "browser_language"
        from "ods_browser_events__dbt_tmp145641449233"
    )


  