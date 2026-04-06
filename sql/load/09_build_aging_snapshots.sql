-- ===============================================
-- 09_build_aging_snapshots.sql
-- Purpose: load monthly customer aging buckets
-- ===============================================

DELETE FROM dw.fact_ar_aging_snapshot;

INSERT INTO dw.fact_ar_aging_snapshot (
    snapshot_date_key,
    snapshot_date,
    customer_key,
    total_outstanding_amount,
    current_amount,
    bucket_1_30_amount,
    bucket_31_60_amount,
    bucket_61_90_amount,
    bucket_91_plus_amount
)
SELECT
    dd.date_key AS snapshot_date_key,
    s.snapshot_date,
    dc.customer_key,
    s.total_outstanding_amount,
    s.current_amount,
    s.bucket_1_30_amount,
    s.bucket_31_60_amount,
    s.bucket_61_90_amount,
    s.bucket_91_plus_amount
FROM stg.aging_snapshots s
JOIN dw.dim_customer dc ON s.customer_code = dc.customer_code
JOIN dw.dim_date dd ON s.snapshot_date = dd.calendar_date
ON CONFLICT (snapshot_date, customer_key) DO UPDATE
SET
    total_outstanding_amount = EXCLUDED.total_outstanding_amount,
    current_amount = EXCLUDED.current_amount,
    bucket_1_30_amount = EXCLUDED.bucket_1_30_amount,
    bucket_31_60_amount = EXCLUDED.bucket_31_60_amount,
    bucket_61_90_amount = EXCLUDED.bucket_61_90_amount,
    bucket_91_plus_amount = EXCLUDED.bucket_91_plus_amount;
