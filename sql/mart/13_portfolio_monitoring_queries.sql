-- ===============================================
-- 13_portfolio_monitoring_queries.sql
-- Purpose: reusable analytical query library
-- ===============================================

-- Query 1: monthly portfolio overview
SELECT
    snapshot_date,
    SUM(total_outstanding_exposure) AS total_exposure,
    SUM(overdue_exposure) AS overdue_exposure,
    ROUND(SUM(overdue_exposure) / NULLIF(SUM(total_outstanding_exposure), 0), 4) AS overdue_ratio,
    AVG(utilization_ratio) AS avg_utilization
FROM dw.fact_exposure_snapshot
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- Query 2: top 20 customers by current exposure
SELECT
    fes.snapshot_date,
    dc.customer_code,
    dc.customer_name,
    fes.total_outstanding_exposure,
    fes.overdue_exposure,
    fes.utilization_ratio
FROM dw.fact_exposure_snapshot fes
JOIN dw.dim_customer dc ON fes.customer_key = dc.customer_key
WHERE fes.snapshot_date = (SELECT MAX(snapshot_date) FROM dw.fact_exposure_snapshot)
ORDER BY fes.total_outstanding_exposure DESC
LIMIT 20;

-- Query 3: customers with worsening overdue trend
WITH ranked AS (
    SELECT
        customer_key,
        snapshot_date,
        overdue_exposure,
        LAG(overdue_exposure, 1) OVER (PARTITION BY customer_key ORDER BY snapshot_date) AS prev_1,
        LAG(overdue_exposure, 2) OVER (PARTITION BY customer_key ORDER BY snapshot_date) AS prev_2
    FROM dw.fact_exposure_snapshot
)
SELECT
    dc.customer_code,
    dc.customer_name,
    r.snapshot_date,
    r.overdue_exposure,
    r.prev_1,
    r.prev_2
FROM ranked r
JOIN dw.dim_customer dc ON r.customer_key = dc.customer_key
WHERE r.overdue_exposure > COALESCE(r.prev_1, 0)
  AND COALESCE(r.prev_1, 0) > COALESCE(r.prev_2, 0)
ORDER BY r.overdue_exposure DESC;

-- Query 4: over-limit customers
SELECT
    fes.snapshot_date,
    dc.customer_code,
    dc.customer_name,
    fes.total_outstanding_exposure,
    fes.credit_limit_amount,
    fes.utilization_ratio
FROM dw.fact_exposure_snapshot fes
JOIN dw.dim_customer dc ON fes.customer_key = dc.customer_key
WHERE fes.utilization_ratio > 1
ORDER BY fes.utilization_ratio DESC;

-- Query 5: defaults by industry and rating
SELECT
    di.industry_name,
    dr.rating_code,
    COUNT(*) AS default_count,
    SUM(fde.defaulted_amount) AS defaulted_amount
FROM dw.fact_default_event fde
JOIN dw.dim_customer dc ON fde.customer_key = dc.customer_key
JOIN dw.dim_industry di ON dc.industry_key = di.industry_key
JOIN dw.dim_rating dr ON fde.rating_key = dr.rating_key
GROUP BY di.industry_name, dr.rating_code
ORDER BY defaulted_amount DESC;
