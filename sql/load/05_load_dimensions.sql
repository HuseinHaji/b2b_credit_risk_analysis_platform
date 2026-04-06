-- ===============================================
-- 05_load_dimensions.sql
-- Purpose: load conformed dimensions in dependency order
-- ===============================================

INSERT INTO dw.dim_industry (industry_code, industry_name, sector_group, risk_weight)
SELECT
    s.industry_code,
    s.industry_name,
    s.sector_group,
    s.risk_weight
FROM stg.industries s
ON CONFLICT (industry_code) DO UPDATE
SET
    industry_name = EXCLUDED.industry_name,
    sector_group = EXCLUDED.sector_group,
    risk_weight = EXCLUDED.risk_weight,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO dw.dim_country (country_code, country_name, region_name, country_risk_group)
SELECT
    s.country_code,
    s.country_name,
    s.region_name,
    s.country_risk_group
FROM stg.countries s
ON CONFLICT (country_code) DO UPDATE
SET
    country_name = EXCLUDED.country_name,
    region_name = EXCLUDED.region_name,
    country_risk_group = EXCLUDED.country_risk_group,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO dw.dim_rating (rating_code, rating_name, rating_rank, risk_band)
SELECT
    s.rating_code,
    s.rating_name,
    s.rating_rank,
    s.risk_band
FROM stg.ratings s
ON CONFLICT (rating_code) DO UPDATE
SET
    rating_name = EXCLUDED.rating_name,
    rating_rank = EXCLUDED.rating_rank,
    risk_band = EXCLUDED.risk_band,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO dw.dim_date (
    date_key,
    calendar_date,
    day_of_month,
    month_number,
    month_name,
    quarter_number,
    year_number,
    year_month,
    is_month_end,
    is_quarter_end,
    is_year_end
)
SELECT
    CAST(TO_CHAR(d::date, 'YYYYMMDD') AS INTEGER) AS date_key,
    d::date AS calendar_date,
    EXTRACT(DAY FROM d)::INTEGER AS day_of_month,
    EXTRACT(MONTH FROM d)::INTEGER AS month_number,
    TO_CHAR(d, 'Month')::VARCHAR(20) AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter_number,
    EXTRACT(YEAR FROM d)::INTEGER AS year_number,
    TO_CHAR(d, 'YYYY-MM')::VARCHAR(7) AS year_month,
    (d::date = (DATE_TRUNC('month', d) + INTERVAL '1 month - 1 day')::date) AS is_month_end,
    (d::date = (DATE_TRUNC('quarter', d) + INTERVAL '3 month - 1 day')::date) AS is_quarter_end,
    (d::date = (DATE_TRUNC('year', d) + INTERVAL '1 year - 1 day')::date) AS is_year_end
FROM GENERATE_SERIES(
    (SELECT COALESCE(MIN(invoice_date), DATE '2024-01-01') FROM stg.invoices),
    (SELECT COALESCE(MAX(GREATEST(due_date, invoice_date)), DATE '2025-12-31') FROM stg.invoices),
    INTERVAL '1 day'
) d
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO dw.dim_customer (
    customer_code,
    customer_name,
    legal_entity_type,
    size_segment,
    annual_revenue_estimate,
    employee_count_estimate,
    onboarding_date,
    status,
    industry_key,
    country_key,
    rating_key,
    credit_limit_amount,
    payment_terms_days,
    risk_segment
)
SELECT
    s.customer_code,
    s.customer_name,
    s.legal_entity_type,
    s.size_segment,
    s.annual_revenue_estimate,
    s.employee_count_estimate,
    s.onboarding_date,
    s.status,
    i.industry_key,
    c.country_key,
    r.rating_key,
    s.credit_limit_amount,
    s.payment_terms_days,
    s.risk_segment
FROM stg.customers s
JOIN dw.dim_industry i ON s.industry_code = i.industry_code
JOIN dw.dim_country c ON s.country_code = c.country_code
JOIN dw.dim_rating r ON s.rating_code = r.rating_code
ON CONFLICT (customer_code) DO UPDATE
SET
    customer_name = EXCLUDED.customer_name,
    legal_entity_type = EXCLUDED.legal_entity_type,
    size_segment = EXCLUDED.size_segment,
    annual_revenue_estimate = EXCLUDED.annual_revenue_estimate,
    employee_count_estimate = EXCLUDED.employee_count_estimate,
    onboarding_date = EXCLUDED.onboarding_date,
    status = EXCLUDED.status,
    industry_key = EXCLUDED.industry_key,
    country_key = EXCLUDED.country_key,
    rating_key = EXCLUDED.rating_key,
    credit_limit_amount = EXCLUDED.credit_limit_amount,
    payment_terms_days = EXCLUDED.payment_terms_days,
    risk_segment = EXCLUDED.risk_segment,
    updated_at = CURRENT_TIMESTAMP;
