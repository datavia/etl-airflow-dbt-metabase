
      
  
    

  create  table "lab08_db"."ods_ods"."ods_location_events_dbt"
  
  
    as
  
  (
    

select load_dttm,
       (json_data->>'event_id')::uuid event_id,
        json_data->>'page_url' page_url,
        json_data->>'page_url_path' page_url_path,
        json_data->>'referer_url' referer_url,
        json_data->>'referer_medium' referer_medium,
        json_data->>'utm_medium' utm_medium,
        json_data->>'utm_source' utm_source,
        json_data->>'utm_content' utm_content,
        json_data->>'utm_campaign' utm_campaign
  from "lab08_db"."stg"."stg_location_events"


  );
  
  