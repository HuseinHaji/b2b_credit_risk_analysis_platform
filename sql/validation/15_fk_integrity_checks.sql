-- ===============================================
-- 15_fk_integrity_checks.sql
-- Purpose: key mapping integrity from staging to dimensions/facts
-- ===============================================

SELECT s.*
FROM stg.customers s
LEFT JOIN dw.dim_industry i ON s.industry_code = i.industry_code
WHERE i.industry_key IS NULL;

SELECT s.*
FROM stg.customers s
LEFT JOIN dw.dim_country c ON s.country_code = c.country_code
WHERE c.country_key IS NULL;

SELECT s.*
FROM stg.customers s
LEFT JOIN dw.dim_rating r ON s.rating_code = r.rating_code
WHERE r.rating_key IS NULL;

SELECT s.*
FROM stg.invoices s
LEFT JOIN dw.dim_customer dc ON s.customer_code = dc.customer_code
WHERE dc.customer_key IS NULL;

SELECT s.*
FROM stg.payments s
LEFT JOIN dw.fact_invoice fi ON s.invoice_number = fi.invoice_number
WHERE fi.invoice_key IS NULL;
