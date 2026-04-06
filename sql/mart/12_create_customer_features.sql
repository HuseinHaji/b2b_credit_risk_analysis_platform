-- ===============================================
-- 12_create_customer_features.sql
-- Purpose: customer-level monthly risk features
-- ===============================================

DROP TABLE IF EXISTS mart.customer_risk_features_monthly;

CREATE TABLE mart.customer_risk_features_monthly AS
WITH pay AS (
    SELECT
        fp.customer_key,
        DATE_TRUNC('month', fp.payment_date)::date AS payment_month,
        fp.days_late,
        fp.payment_date,
        fp.invoice_key
    FROM dw.fact_payment fp
),
inv AS (
    SELECT
        fi.customer_key,
        DATE_TRUNC('month', fi.invoice_date)::date AS invoice_month,
        fi.invoice_key,
        fi.due_date,
        fi.gross_amount
    FROM dw.fact_invoice fi
),
late_3m AS (
    SELECT
        p.customer_key,
        p.payment_month AS month_key,
        AVG(CASE WHEN p.days_late > 0 THEN p.days_late END) AS avg_days_late_3m,
        STDDEV_POP(p.days_late) AS payment_volatility_6m
    FROM pay p
    GROUP BY p.customer_key, p.payment_month
),
overdue_6m AS (
    SELECT
        fes.customer_key,
        DATE_TRUNC('month', fes.snapshot_date)::date AS month_key,
        CASE WHEN fes.total_outstanding_exposure = 0 THEN 0
             ELSE fes.overdue_exposure / fes.total_outstanding_exposure END AS overdue_exposure_ratio,
        fes.utilization_ratio
    FROM dw.fact_exposure_snapshot fes
),
activity_6m AS (
    SELECT
        i.customer_key,
        i.invoice_month AS month_key,
        COUNT(*) AS invoice_frequency
    FROM inv i
    GROUP BY i.customer_key, i.invoice_month
),
severity_6m AS (
    SELECT
        fp.customer_key,
        DATE_TRUNC('month', fp.payment_date)::date AS month_key,
        MAX(CASE WHEN fp.days_late > 0 THEN fp.days_late ELSE NULL END) AS max_days_past_due_6m
    FROM dw.fact_payment fp
    GROUP BY fp.customer_key, DATE_TRUNC('month', fp.payment_date)::date
),
base AS (
    SELECT
        o.customer_key,
        o.month_key,
        l.avg_days_late_3m,
        o.overdue_exposure_ratio,
        o.utilization_ratio,
        l.payment_volatility_6m,
        a.invoice_frequency,
        s.max_days_past_due_6m,
        LAG(o.overdue_exposure_ratio, 1) OVER (PARTITION BY o.customer_key ORDER BY o.month_key) AS prev_overdue_ratio_1,
        LAG(o.overdue_exposure_ratio, 2) OVER (PARTITION BY o.customer_key ORDER BY o.month_key) AS prev_overdue_ratio_2,
        fes.total_outstanding_exposure,
        AVG(fes.total_outstanding_exposure) OVER (
            PARTITION BY o.customer_key
            ORDER BY o.month_key
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) AS avg_exposure_prev_3m,
        dc.industry_key
    FROM overdue_6m o
    LEFT JOIN late_3m l
        ON o.customer_key = l.customer_key
       AND o.month_key = l.month_key
    LEFT JOIN activity_6m a
        ON o.customer_key = a.customer_key
       AND o.month_key = a.month_key
    LEFT JOIN severity_6m s
        ON o.customer_key = s.customer_key
       AND o.month_key = s.month_key
    JOIN dw.fact_exposure_snapshot fes
      ON fes.customer_key = o.customer_key
     AND DATE_TRUNC('month', fes.snapshot_date)::date = o.month_key
    JOIN dw.dim_customer dc
      ON o.customer_key = dc.customer_key
),
industry_overdue AS (
    SELECT
        DATE_TRUNC('month', fes.snapshot_date)::date AS month_key,
        dc.industry_key,
        SUM(fes.overdue_exposure) / NULLIF(SUM(fes.total_outstanding_exposure), 0) AS industry_overdue_ratio
    FROM dw.fact_exposure_snapshot fes
    JOIN dw.dim_customer dc ON fes.customer_key = dc.customer_key
    GROUP BY DATE_TRUNC('month', fes.snapshot_date)::date, dc.industry_key
)
SELECT
    b.customer_key,
    b.month_key,
    b.avg_days_late_3m,
    b.overdue_exposure_ratio,
    b.utilization_ratio,
    b.payment_volatility_6m,
    b.invoice_frequency,
    b.max_days_past_due_6m,
    CASE
        WHEN b.overdue_exposure_ratio > COALESCE(b.prev_overdue_ratio_1, 0)
         AND COALESCE(b.prev_overdue_ratio_1, 0) > COALESCE(b.prev_overdue_ratio_2, 0)
        THEN 1
        WHEN COALESCE(b.avg_days_late_3m, 0) >= 20 THEN 1
        ELSE 0
    END AS recent_deterioration_flag,
    CASE
        WHEN io.industry_overdue_ratio IS NULL OR io.industry_overdue_ratio = 0 THEN NULL
        ELSE b.overdue_exposure_ratio / io.industry_overdue_ratio
    END AS sector_relative_risk,
    CASE
        WHEN b.avg_exposure_prev_3m IS NULL OR b.avg_exposure_prev_3m = 0 THEN NULL
        ELSE b.total_outstanding_exposure / b.avg_exposure_prev_3m - 1
    END AS exposure_growth_rate
FROM base b
LEFT JOIN industry_overdue io
  ON b.month_key = io.month_key
 AND b.industry_key = io.industry_key;

CREATE INDEX IF NOT EXISTS idx_customer_risk_features_monthly_key
ON mart.customer_risk_features_monthly (customer_key, month_key);
