
      insert into "lab08_db"."ods"."ods_device_events" ("load_hour", "click_id", "device_is_mobile", "user_domain_id", "os", "os_name", "os_timezone", "device_type", "user_custom_id")
    (
        select "load_hour", "click_id", "device_is_mobile", "user_domain_id", "os", "os_name", "os_timezone", "device_type", "user_custom_id"
        from "ods_device_events__dbt_tmp141629128435"
    )


  