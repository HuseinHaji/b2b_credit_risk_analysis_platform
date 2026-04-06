-- ===============================================
-- 17_snapshot_validation.sql
-- Purpose: validate snapshot-level consistency
-- ===============================================

-- Exposure snapshot arithmetic
SELECT *
FROM dw.fact_exposure_snapshot
WHERE ROUND(total_outstanding_exposure - (overdue_exposure + current_exposure), 2) <> 0;

-- Aging buckets must sum to total outstanding
SELECT *
FROM dw.fact_ar_aging_snapshot
WHERE ROUND(
    total_outstanding_amount
    - (current_amount + bucket_1_30_amount + bucket_31_60_amount + bucket_61_90_amount + bucket_91_plus_amount),
    2
) <> 0;

-- Snapshot date should map to dim_date month-end for generated snapshot facts
SELECT fes.*
FROM dw.fact_exposure_snapshot fes
JOIN dw.dim_date dd ON fes.snapshot_date_key = dd.date_key
WHERE dd.is_month_end = FALSE;

SELECT fas.*
FROM dw.fact_ar_aging_snapshot fas
JOIN dw.dim_date dd ON fas.snapshot_date_key = dd.date_key
WHERE dd.is_month_end = FALSE;

-- Utilization sanity check
SELECT *
FROM dw.fact_exposure_snapshot
WHERE utilization_ratio < 0 OR utilization_ratio > 10;
