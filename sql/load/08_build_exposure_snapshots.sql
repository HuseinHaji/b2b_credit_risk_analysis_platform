-- ===============================================
-- 08_build_exposure_snapshots.sql
-- Purpose: load monthly customer exposure snapshots
-- ===============================================

DELETE FROM dw.fact_exposure_snapshot;

INSERT INTO dw.fact_exposure_snapshot (
    snapshot_date_key,
    snapshot_date,
    customer_key,
    rating_key,
    credit_limit_amount,
    total_outstanding_exposure,
    overdue_exposure,
    current_exposure,
    utilization_ratio,
    invoices_open_count,
    overdue_invoices_count
)
SELECT
    dd.date_key AS snapshot_date_key,
    s.snapshot_date,
    dc.customer_key,
    dr.rating_key,
    s.credit_limit_amount,
    s.total_outstanding_exposure,
    s.overdue_exposure,
    s.current_exposure,
    s.utilization_ratio,
    s.invoices_open_count,
    s.overdue_invoices_count
FROM stg.exposure_snapshots s
JOIN dw.dim_customer dc ON s.customer_code = dc.customer_code
JOIN dw.dim_rating dr ON s.rating_code = dr.rating_code
JOIN dw.dim_date dd ON s.snapshot_date = dd.calendar_date
ON CONFLICT (snapshot_date, customer_key) DO UPDATE
SET
    rating_key = EXCLUDED.rating_key,
    credit_limit_amount = EXCLUDED.credit_limit_amount,
    total_outstanding_exposure = EXCLUDED.total_outstanding_exposure,
    overdue_exposure = EXCLUDED.overdue_exposure,
    current_exposure = EXCLUDED.current_exposure,
    utilization_ratio = EXCLUDED.utilization_ratio,
    invoices_open_count = EXCLUDED.invoices_open_count,
    overdue_invoices_count = EXCLUDED.overdue_invoices_count;
