-- ===============================================
-- 11_create_kpi_views.sql
-- Purpose: reusable KPI views for BI and reporting
-- ===============================================

CREATE SCHEMA IF NOT EXISTS mart;

CREATE OR REPLACE VIEW mart.v_portfolio_monthly_overview AS
SELECT
	fes.snapshot_date,
	SUM(fes.total_outstanding_exposure) AS total_exposure,
	SUM(fes.overdue_exposure) AS overdue_exposure,
	ROUND(
		SUM(fes.overdue_exposure) / NULLIF(SUM(fes.total_outstanding_exposure), 0),
		4
	) AS overdue_ratio,
	AVG(fes.utilization_ratio) AS avg_utilization,
	COUNT(DISTINCT fes.customer_key) AS active_customers
FROM dw.fact_exposure_snapshot fes
GROUP BY fes.snapshot_date;

CREATE OR REPLACE VIEW mart.v_industry_risk_monthly AS
SELECT
	fes.snapshot_date,
	di.industry_name,
	SUM(fes.total_outstanding_exposure) AS total_exposure,
	SUM(fes.overdue_exposure) AS overdue_exposure,
	ROUND(
		SUM(fes.overdue_exposure) / NULLIF(SUM(fes.total_outstanding_exposure), 0),
		4
	) AS overdue_ratio,
	AVG(fes.utilization_ratio) AS avg_utilization
FROM dw.fact_exposure_snapshot fes
JOIN dw.dim_customer dc ON fes.customer_key = dc.customer_key
JOIN dw.dim_industry di ON dc.industry_key = di.industry_key
GROUP BY fes.snapshot_date, di.industry_name;

CREATE OR REPLACE VIEW mart.v_country_risk_monthly AS
SELECT
	fes.snapshot_date,
	c.country_name,
	SUM(fes.total_outstanding_exposure) AS total_exposure,
	SUM(fes.overdue_exposure) AS overdue_exposure,
	ROUND(
		SUM(fes.overdue_exposure) / NULLIF(SUM(fes.total_outstanding_exposure), 0),
		4
	) AS overdue_ratio,
	AVG(fes.utilization_ratio) AS avg_utilization
FROM dw.fact_exposure_snapshot fes
JOIN dw.dim_customer dc ON fes.customer_key = dc.customer_key
JOIN dw.dim_country c ON dc.country_key = c.country_key
GROUP BY fes.snapshot_date, c.country_name;

CREATE OR REPLACE VIEW mart.v_customers_over_limit AS
SELECT
	fes.snapshot_date,
	dc.customer_code,
	dc.customer_name,
	fes.total_outstanding_exposure,
	fes.credit_limit_amount,
	fes.utilization_ratio,
	fes.overdue_exposure
FROM dw.fact_exposure_snapshot fes
JOIN dw.dim_customer dc ON fes.customer_key = dc.customer_key
WHERE fes.utilization_ratio > 1.0000;

CREATE OR REPLACE VIEW mart.v_rating_mix_exposure AS
SELECT
	fes.snapshot_date,
	dr.rating_code,
	dr.risk_band,
	SUM(fes.total_outstanding_exposure) AS total_exposure,
	SUM(fes.overdue_exposure) AS overdue_exposure,
	ROUND(
		SUM(fes.total_outstanding_exposure)
		/ NULLIF(SUM(SUM(fes.total_outstanding_exposure)) OVER (PARTITION BY fes.snapshot_date), 0),
		4
	) AS exposure_share
FROM dw.fact_exposure_snapshot fes
JOIN dw.dim_rating dr ON fes.rating_key = dr.rating_key
GROUP BY fes.snapshot_date, dr.rating_code, dr.risk_band;

CREATE OR REPLACE VIEW mart.v_payment_behavior AS
SELECT
	DATE_TRUNC('month', fp.payment_date)::date AS payment_month,
	dc.customer_code,
	dc.customer_name,
	AVG(fp.days_late) FILTER (WHERE fp.days_late > 0) AS avg_days_late,
	COUNT(*) FILTER (WHERE fp.is_partial_payment) AS partial_payment_count,
	COUNT(*) AS total_payments,
	ROUND(
		COUNT(*) FILTER (WHERE fp.is_partial_payment)::NUMERIC / NULLIF(COUNT(*), 0),
		4
	) AS partial_payment_ratio
FROM dw.fact_payment fp
JOIN dw.dim_customer dc ON fp.customer_key = dc.customer_key
GROUP BY DATE_TRUNC('month', fp.payment_date)::date, dc.customer_code, dc.customer_name;

CREATE OR REPLACE VIEW mart.v_default_summary AS
SELECT
	fde.default_date,
	di.industry_name,
	c.country_name,
	dr.rating_code,
	fde.default_type,
	fde.defaulted_amount,
	fde.recovered_amount,
	fde.recovery_rate
FROM dw.fact_default_event fde
JOIN dw.dim_customer dc ON fde.customer_key = dc.customer_key
JOIN dw.dim_industry di ON dc.industry_key = di.industry_key
JOIN dw.dim_country c ON dc.country_key = c.country_key
JOIN dw.dim_rating dr ON fde.rating_key = dr.rating_key;
