WITH unique_devices AS (
SELECT DISTINCT 
	click_id,
	os,
	os_name,
	device_type,
	user_custom_id
FROM {{ ref('ods_device_events_dbt') }}
),
unique_geo AS (
SELECT DISTINCT
	click_id,
	geo_country,
	geo_region_name
FROM {{ ref('ods_geo_events_dbt') }}
),
cte_lead AS (
SELECT
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
    LEAD(page_url_path, 1) OVER w AS next_page_lead1,
    LEAD(page_url_path, 2) OVER w AS next_page_lead2,
    LEAD(page_url_path, 3) OVER w AS next_page_lead3,
    LEAD(event_timestamp, 3) OVER w AS confirmation_timestamp
FROM {{ ref('ods_location_events_dbt') }} ole
JOIN {{ ref('ods_browser_events_dbt') }} obe ON ole.event_id = obe.event_id
JOIN unique_devices ud ON obe.click_id = ud.click_id
JOIN unique_geo ug ON ug.click_id = obe.click_id
WHERE ole.page_url_path != '/home'
{% if is_incremental() %}
AND ole.load_hour > (select coalesce(max(load_hour), '1900-01-01') FROM {{ this }})
AND obe.load_hour > (select coalesce(max(load_hour), '1900-01-01') FROM {{ this }})
{% endif %}
WINDOW w AS (
	PARTITION BY user_custom_id
	ORDER BY event_timestamp
	)
)
SELECT
    load_hour,
	user_custom_id AS sale_custom_id,
	event_timestamp,
	confirmation_timestamp AS sale_timestamp,
	EXTRACT(HOUR FROM confirmation_timestamp) AS sale_hour,
	1 AS sale_item_cnt,
	browser_name AS sale_browser,
	device_type AS sale_platform,
	page_url_path AS sale_page_before,
	REPLACE(page_url_path, '/product_', '') AS clear_sale_page_before,
	utm_source AS sale_source,
	utm_campaign AS sale_utm_campaign,
	referer_url AS sale_referer_url,
	referer_medium AS sale_referer_medium,
	utm_content AS sale_utm_content,
	geo_country AS sale_geo_country,
	geo_region_name AS sale_geo_region_name
FROM cte_lead
WHERE (next_page_lead1, next_page_lead2, next_page_lead3) = ('/cart', '/payment', '/confirmation')
AND page_url_path NOT IN ('/payment', '/cart')
