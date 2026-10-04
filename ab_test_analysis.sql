/* 
   Marketing A/B Test Analysis
   Table : marketing_AB
*/

-- 1. Data Quality & Row Count
SELECT COUNT(*) AS total_rows
FROM marketing_AB;

SELECT 
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END)                AS null_user_ids,
    SUM(CASE WHEN test_group NOT IN ('ad', 'psa') THEN 1 ELSE 0 END) AS bad_groups,
    SUM(CASE WHEN converted NOT IN (0, 1) THEN 1 ELSE 0 END)        AS bad_converted,
    MIN(total_ads) AS min_ads,
    MAX(total_ads) AS max_ads
FROM marketing_AB;

-- 2. Group Balance
SELECT 
    test_group,
    COUNT(*) AS users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM marketing_AB
GROUP BY test_group;

-- 3. Conversion Rate by Group
SELECT 
    test_group,
    COUNT(*) AS total_users,
    SUM(CAST(converted AS INT)) AS converted_users,
    ROUND(SUM(CAST(converted AS INT)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct
FROM marketing_AB
GROUP BY test_group;


-- 4. Absolute & Relative Lift   (fixed formatting)
WITH rates AS (
    SELECT 
        test_group,
        CAST(SUM(CAST(converted AS INT)) AS FLOAT) / COUNT(*) AS rate
    FROM marketing_AB
    GROUP BY test_group
)
SELECT 
    ROUND(MAX(CASE WHEN test_group = 'ad'  THEN rate END), 4) AS ad_rate,
    ROUND(MAX(CASE WHEN test_group = 'psa' THEN rate END), 4) AS psa_rate,
    ROUND(
        MAX(CASE WHEN test_group = 'ad'  THEN rate END) 
        - MAX(CASE WHEN test_group = 'psa' THEN rate END), 4
    ) AS absolute_lift,
    ROUND(
        (MAX(CASE WHEN test_group = 'ad'  THEN rate END) 
         / MAX(CASE WHEN test_group = 'psa' THEN rate END) - 1) * 100, 2
    ) AS relative_lift_pct
FROM rates;


-- 5. Counts for Statistical Test
SELECT 
    test_group,
    SUM(CAST(converted AS INT)) AS converted,
    COUNT(*) - SUM(CAST(converted AS INT)) AS not_converted
FROM marketing_AB
GROUP BY test_group;


-- 6. Ads Seen Summary by Group   (fixed PERCENTILE_CONT)
SELECT DISTINCT
    test_group,
    ROUND(AVG(CAST(total_ads AS FLOAT)) OVER (PARTITION BY test_group), 1) AS avg_ads_seen,
    MIN(total_ads) OVER (PARTITION BY test_group) AS min_ads,
    MAX(total_ads) OVER (PARTITION BY test_group) AS max_ads,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_ads)
            OVER (PARTITION BY test_group), 1
    ) AS median_ads
FROM marketing_AB
ORDER BY test_group;


-- 7. Conversion Rate by Ads Volume (ad group only)   ← CLEAN VERSION
WITH buckets AS (
    SELECT 
        CASE 
            WHEN total_ads BETWEEN 1 AND 10   THEN '1-10 ads'
            WHEN total_ads BETWEEN 11 AND 50  THEN '11-50 ads'
            WHEN total_ads BETWEEN 51 AND 100 THEN '51-100 ads'
            ELSE '100+ ads'
        END AS ads_bucket,
        converted
    FROM marketing_AB
    WHERE test_group = 'ad'
)
SELECT 
    ads_bucket,
    COUNT(*) AS users,
    ROUND(SUM(CAST(converted AS INT)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct
FROM buckets
GROUP BY ads_bucket
ORDER BY 
    CASE ads_bucket
        WHEN '1-10 ads'   THEN 1
        WHEN '11-50 ads'  THEN 2
        WHEN '51-100 ads' THEN 3
        WHEN '100+ ads'   THEN 4
    END;


-- 8. Conversion Rate by Day of Week (both groups)
SELECT 
    most_ads_day,
    test_group,
    COUNT(*) AS users,
    SUM(CAST(converted AS INT)) AS conversions,
    ROUND(SUM(CAST(converted AS INT)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct
FROM marketing_AB
GROUP BY most_ads_day, test_group
ORDER BY 
    CASE most_ads_day
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END,
    test_group;


-- 9. Top 5 Hours by Conversion Rate (ad group)
SELECT TOP 5
    most_ads_hour,
    COUNT(*) AS users,
    ROUND(SUM(CAST(converted AS INT)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct
FROM marketing_AB
WHERE test_group = 'ad'
GROUP BY most_ads_hour
ORDER BY conversion_rate_pct ASC;

-- 10. Final Summary Table
SELECT 
    test_group,
    COUNT(*) AS total_users,
    SUM(CAST(converted AS INT)) AS conversions,
    ROUND(SUM(CAST(converted AS INT)) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
    ROUND(AVG(CAST(total_ads AS FLOAT)), 1) AS avg_ads_seen
FROM marketing_AB
GROUP BY test_group;