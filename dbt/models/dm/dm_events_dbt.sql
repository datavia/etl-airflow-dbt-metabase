WITH distinct_clicks AS (
	SELECT DISTINCT
		click_id,
		device_type
	FROM {{ ref('ods_device_events_dbt') }}
)
SELECT
	e.load_hour,
	e.event_id,
	e.event_type,
	e.event_timestamp,
	EXTRACT(HOUR FROM e.event_timestamp) AS event_hour,
	e.browser_name,
	d.device_type
FROM {{ ref('ods_browser_events_dbt') }} e
JOIN distinct_clicks d USING(click_id)
{% if is_incremental() %}
WHERE load_hour > (select coalesce(max(load_hour), '1900-01-01')
 FROM {{ this }})
{% endif %}