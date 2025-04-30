
      
  
    

  create  table "lab08_db"."ods_ods"."ods_device_events_dbt"
  
  
    as
  
  (
    

select  load_dttm,

       (json_data->>'click_id')::uuid click_id,
        json_data->>'os' os,
        json_data->>'os_name' os_name,
        json_data->>'os_timezone' os_timezone,
        json_data->>'device_type' device_type,
        (json_data->>'device_is_mobile')::bool device_is_mobile,
        json_data->>'user_custom_id' user_custom_id,
        (json_data->>'user_domain_id')::uuid user_domain_id
  from "lab08_db"."stg"."stg_device_events"


  );
  
  