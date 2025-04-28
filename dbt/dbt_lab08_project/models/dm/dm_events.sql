WITH distinct_clicks AS (
    SELECT DISTINCT
        click_id,
        device_type
    FROM {{ ref('ods_device_events') }}
)

SELECT
    e.load_hour,
    e.event_id,
    e.event_type,
    e.event_timestamp,
    e.browser_name,
    d.device_type,
    EXTRACT(HOUR FROM e.event_timestamp) AS event_hour
FROM {{ ref('ods_browser_events') }} AS e
INNER JOIN distinct_clicks AS d ON e.click_id = d.click_id
{% if is_incremental() %}
    WHERE load_hour > (
        SELECT COALESCE(MAX(load_hour), '1900-01-01')
        FROM {{ this }}
    )
{% endif %}
