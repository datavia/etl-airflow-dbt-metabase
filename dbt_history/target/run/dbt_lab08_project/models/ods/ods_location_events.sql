
      insert into "lab08_db"."ods"."ods_location_events" ("load_hour", "event_id", "page_url", "page_url_path", "referer_url", "referer_medium", "utm_medium", "utm_source", "utm_content", "utm_campaign")
    (
        select "load_hour", "event_id", "page_url", "page_url_path", "referer_url", "referer_medium", "utm_medium", "utm_source", "utm_content", "utm_campaign"
        from "ods_location_events__dbt_tmp105904397456"
    )


  