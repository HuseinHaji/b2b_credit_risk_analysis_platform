-- ===============================================
-- 06_load_fact_invoices.sql
-- Purpose: load invoice transactions
-- ===============================================

INSERT INTO dw.fact_invoice (
    invoice_number,
    customer_key,
    invoice_date_key,
    due_date_key,
    invoice_date,
    due_date,
    currency_code,
    gross_amount,
    tax_amount,
    net_amount,
    invoice_status
)
SELECT
    s.invoice_number,
    dc.customer_key,
    dd1.date_key AS invoice_date_key,
    dd2.date_key AS due_date_key,
    s.invoice_date,
    s.due_date,
    COALESCE(s.currency_code, 'EUR') AS currency_code,
    s.gross_amount,
    COALESCE(s.tax_amount, 0) AS tax_amount,
    s.net_amount,
    COALESCE(s.invoice_status, 'OPEN') AS invoice_status
FROM stg.invoices s
JOIN dw.dim_customer dc ON s.customer_code = dc.customer_code
JOIN dw.dim_date dd1 ON s.invoice_date = dd1.calendar_date
JOIN dw.dim_date dd2 ON s.due_date = dd2.calendar_date
ON CONFLICT (invoice_number) DO NOTHING;
