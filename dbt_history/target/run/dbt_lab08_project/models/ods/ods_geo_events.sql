
      insert into "lab08_db"."ods"."ods_geo_events" ("load_hour", "click_id", "geo_latitude", "geo_longitude", "geo_country", "geo_timezone", "geo_region_name", "ip_address")
    (
        select "load_hour", "click_id", "geo_latitude", "geo_longitude", "geo_country", "geo_timezone", "geo_region_name", "ip_address"
        from "ods_geo_events__dbt_tmp101240306946"
    )


  