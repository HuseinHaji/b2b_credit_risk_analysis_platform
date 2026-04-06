-- ===============================================
-- 10_load_default_events.sql
-- Purpose: load default event facts
-- ===============================================

DELETE FROM dw.fact_default_event;

INSERT INTO dw.fact_default_event (
    customer_key,
    default_date_key,
    default_date,
    rating_key,
    default_type,
    defaulted_amount,
    recovered_amount,
    recovery_rate,
    notes
)
SELECT
    dc.customer_key,
    dd.date_key AS default_date_key,
    s.default_date,
    dr.rating_key,
    s.default_type,
    s.defaulted_amount,
    COALESCE(s.recovered_amount, 0),
    COALESCE(s.recovery_rate,
        CASE
            WHEN s.defaulted_amount = 0 THEN 0
            ELSE COALESCE(s.recovered_amount, 0) / s.defaulted_amount
        END
    ) AS recovery_rate,
    s.notes
FROM stg.default_events s
JOIN dw.dim_customer dc ON s.customer_code = dc.customer_code
JOIN dw.dim_rating dr ON s.rating_code = dr.rating_code
JOIN dw.dim_date dd ON s.default_date = dd.calendar_date;
