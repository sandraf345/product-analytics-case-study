-- Product Analytics Case Study
-- SQL Product Metrics
-- ============================================================
-- This file contains SQL analyses used to complement the
-- Python-based activation and retention analysis.
--
-- Source table: events
-- Grain: one row per product interaction event

-- ------------------------------------------------------------
-- 1. EVENT-LEVEL OVERVIEW
-- ------------------------------------------------------------
-- Summarizes total events and unique users by event type.

SELECT
    event_type,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS unique_users
FROM events
GROUP BY event_type
ORDER BY unique_users DESC;


-- ------------------------------------------------------------
-- 2. USER-LEVEL FUNNEL
-- ------------------------------------------------------------
-- Identifies whether each user reached the view, cart,
-- and purchase stages during the observation period.

WITH user_funnel AS (
    SELECT
        user_id,
        MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM events
    GROUP BY user_id
)

SELECT
    COUNT(*) AS total_users,
    SUM(viewed) AS users_viewed,
    SUM(carted) AS users_carted,
    SUM(purchased) AS users_purchased
FROM user_funnel;


-- ------------------------------------------------------------
-- 3. STAGE-REACH FUNNEL CONVERSION
-- ------------------------------------------------------------
-- Measures users who reached multiple funnel stages during
-- the observation period, regardless of exact event order.

WITH user_funnel AS (
    SELECT
        user_id,
        MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM events
    GROUP BY user_id
),

funnel_counts AS (
    SELECT
        SUM(viewed) AS users_viewed,
        SUM(
            CASE
                WHEN viewed = 1 AND carted = 1 THEN 1
                ELSE 0
            END
        ) AS users_viewed_and_carted,
        SUM(
            CASE
                WHEN viewed = 1
                    AND carted = 1
                    AND purchased = 1
                THEN 1
                ELSE 0
            END
        ) AS users_completed_funnel
    FROM user_funnel
)

SELECT
    users_viewed,
    users_viewed_and_carted,
    users_completed_funnel,

    ROUND(
        100.0 * users_viewed_and_carted / users_viewed,
        2
    ) AS view_to_cart_rate,

    ROUND(
        100.0 * users_completed_funnel / users_viewed_and_carted,
        2
    ) AS cart_to_purchase_rate,

    ROUND(
        100.0 * users_completed_funnel / users_viewed,
        2
    ) AS overall_view_to_purchase_rate

FROM funnel_counts;


-- ------------------------------------------------------------
-- 4. SEQUENTIAL USER FUNNEL
-- ------------------------------------------------------------
-- Measures progression through the funnel in chronological
-- order: view -> cart -> purchase.

WITH first_view AS (
    SELECT
        user_id,
        MIN(event_time) AS first_view_time
    FROM events
    WHERE event_type = 'view'
    GROUP BY user_id
),

first_cart_after_view AS (
    SELECT
        e.user_id,
        MIN(e.event_time) AS first_cart_time
    FROM events AS e
    INNER JOIN first_view AS v
        ON e.user_id = v.user_id
    WHERE e.event_type = 'cart'
      AND e.event_time >= v.first_view_time
    GROUP BY e.user_id
),

first_purchase_after_cart AS (
    SELECT
        e.user_id,
        MIN(e.event_time) AS first_purchase_time
    FROM events AS e
    INNER JOIN first_cart_after_view AS c
        ON e.user_id = c.user_id
    WHERE e.event_type = 'purchase'
      AND e.event_time >= c.first_cart_time
    GROUP BY e.user_id
)

SELECT
    (SELECT COUNT(*) FROM first_view)
        AS users_viewed,

    (SELECT COUNT(*) FROM first_cart_after_view)
        AS users_carted_after_view,

    (SELECT COUNT(*) FROM first_purchase_after_cart)
        AS users_purchased_after_cart;


-- ------------------------------------------------------------
-- 5. SEQUENTIAL FUNNEL CONVERSION & DROP-OFF
-- ------------------------------------------------------------
-- Calculates conversion and drop-off rates using the
-- chronological view -> cart -> purchase funnel.

WITH first_view AS (
    SELECT
        user_id,
        MIN(event_time) AS first_view_time
    FROM events
    WHERE event_type = 'view'
    GROUP BY user_id
),

first_cart_after_view AS (
    SELECT
        e.user_id,
        MIN(e.event_time) AS first_cart_time
    FROM events AS e
    INNER JOIN first_view AS v
        ON e.user_id = v.user_id
    WHERE e.event_type = 'cart'
      AND e.event_time >= v.first_view_time
    GROUP BY e.user_id
),

first_purchase_after_cart AS (
    SELECT
        e.user_id,
        MIN(e.event_time) AS first_purchase_time
    FROM events AS e
    INNER JOIN first_cart_after_view AS c
        ON e.user_id = c.user_id
    WHERE e.event_type = 'purchase'
      AND e.event_time >= c.first_cart_time
    GROUP BY e.user_id
),

funnel AS (
    SELECT
        (SELECT COUNT(*) FROM first_view) AS users_viewed,
        (SELECT COUNT(*) FROM first_cart_after_view) AS users_carted,
        (SELECT COUNT(*) FROM first_purchase_after_cart) AS users_purchased
)

SELECT
    users_viewed,
    users_carted,
    users_purchased,

    ROUND(
        100.0 * users_carted / users_viewed,
        2
    ) AS view_to_cart_rate,

    ROUND(
        100.0 * users_purchased / users_carted,
        2
    ) AS cart_to_purchase_rate,

    ROUND(
        100.0 * users_purchased / users_viewed,
        2
    ) AS view_to_purchase_rate,

    ROUND(
        100.0 * (users_viewed - users_carted) / users_viewed,
        2
    ) AS view_to_cart_dropoff,

    ROUND(
        100.0 * (users_carted - users_purchased) / users_carted,
        2
    ) AS cart_to_purchase_dropoff

FROM funnel;