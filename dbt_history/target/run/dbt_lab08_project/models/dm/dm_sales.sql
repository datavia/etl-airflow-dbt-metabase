
      insert into "lab08_db"."dm"."dm_sales" ("load_hour", "sale_custom_id", "event_timestamp", "sale_timestamp", "sale_item_cnt", "sale_browser", "sale_platform", "sale_page_before", "sale_source", "sale_utm_campaign", "sale_referer_url", "sale_referer_medium", "sale_utm_content", "sale_geo_country", "sale_geo_region_name", "sale_geo_latitude", "sale_geo_longitude", "sale_hour", "clear_sale_page_before", "sale_geo_region_name_ru", "clear_sale_page_before_ru")
    (
        select "load_hour", "sale_custom_id", "event_timestamp", "sale_timestamp", "sale_item_cnt", "sale_browser", "sale_platform", "sale_page_before", "sale_source", "sale_utm_campaign", "sale_referer_url", "sale_referer_medium", "sale_utm_content", "sale_geo_country", "sale_geo_region_name", "sale_geo_latitude", "sale_geo_longitude", "sale_hour", "clear_sale_page_before", "sale_geo_region_name_ru", "clear_sale_page_before_ru"
        from "dm_sales__dbt_tmp094409322122"
    )


  