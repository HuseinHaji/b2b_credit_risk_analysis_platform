-- ===============================================
-- 07_load_fact_payments.sql
-- Purpose: load payment transactions and derive days_late
-- ===============================================

INSERT INTO dw.fact_payment (
    payment_reference,
    invoice_key,
    customer_key,
    payment_date_key,
    payment_date,
    payment_amount,
    payment_method,
    is_partial_payment,
    days_late
)
SELECT
    s.payment_reference,
    fi.invoice_key,
    dc.customer_key,
    dd.date_key,
    s.payment_date,
    s.payment_amount,
    s.payment_method,
    COALESCE(s.is_partial_payment, FALSE) AS is_partial_payment,
    (s.payment_date - fi.due_date) AS days_late
FROM stg.payments s
JOIN dw.fact_invoice fi ON s.invoice_number = fi.invoice_number
JOIN dw.dim_customer dc ON s.customer_code = dc.customer_code
JOIN dw.dim_date dd ON s.payment_date = dd.calendar_date
ON CONFLICT (payment_reference) DO NOTHING;
