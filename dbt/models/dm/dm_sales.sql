with unique_devices as (
    select distinct
        click_id,
        os,
        os_name,
        device_type,
        user_custom_id
    from {{ ref('ods_device_events') }}
),

unique_geo as (
    select distinct
        click_id,
        geo_country,
        geo_region_name,
        geo_latitude,
        geo_longitude
    from {{ ref('ods_geo_events') }}
),

cte_lead as (
    select
        obe.load_hour,
        event_timestamp,
        event_type,
        page_url,
        page_url_path,
        referer_url,
        referer_medium,
        utm_medium,
        utm_source,
        utm_content,
        utm_campaign,
        browser_name,
        browser_user_agent,
        browser_language,
        os,
        os_name,
        user_custom_id,
        device_type,
        geo_country,
        geo_region_name,
        geo_latitude,
        geo_longitude,
        LEAD(page_url_path, 1) over w as next_page_lead1,
        LEAD(page_url_path, 2) over w as next_page_lead2,
        LEAD(page_url_path, 3) over w as next_page_lead3,
        LEAD(event_timestamp, 3) over w as confirmation_timestamp
    from {{ ref('ods_location_events') }} as ole
    inner join
        {{ ref('ods_browser_events') }} as obe
        on ole.event_id = obe.event_id
    inner join unique_devices as ud on obe.click_id = ud.click_id
    inner join unique_geo as ug on obe.click_id = ug.click_id
    where
        ole.page_url_path != '/home'
        {% if is_incremental() %}
            and ole.load_hour
            > (select COALESCE(MAX(load_hour), '1900-01-01') from {{ this }})
            and obe.load_hour
            > (select COALESCE(MAX(load_hour), '1900-01-01') from {{ this }})
        {% endif %}
    window w as (
        partition by user_custom_id
        order by event_timestamp
    )
)

select
    load_hour,
    user_custom_id as sale_custom_id,
    event_timestamp,
    confirmation_timestamp as sale_timestamp,
    1 as sale_item_cnt,
    browser_name as sale_browser,
    device_type as sale_platform,
    page_url_path as sale_page_before,
    utm_source as sale_source,
    utm_campaign as sale_utm_campaign,
    referer_url as sale_referer_url,
    referer_medium as sale_referer_medium,
    utm_content as sale_utm_content,
    geo_country as sale_geo_country,
    geo_region_name as sale_geo_region_name,
    geo_latitude as sale_geo_latitude,
    geo_longitude as sale_geo_longitude,
    EXTRACT(hour from confirmation_timestamp) as sale_hour,
    REPLACE(page_url_path, '/product_', '') as clear_sale_page_before,
    COALESCE(ic.city_ru, '') as sale_geo_region_name_ru,
    COALESCE(i.item_ru, '') as clear_sale_page_before_ru
from cte_lead
left join {{ ref('italian_cities') }} as ic on ic.city_en = geo_region_name
left join
    {{ ref('items') }} as i
    on i.item_en = REPLACE(page_url_path, '/product_', '')
where
    (next_page_lead1, next_page_lead2, next_page_lead3)
    = ('/cart', '/payment', '/confirmation')
    and page_url_path not in ('/payment', '/cart', '/confirmation')
