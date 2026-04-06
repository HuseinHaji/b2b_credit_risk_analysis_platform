-- ===============================================
-- 16_reconciliation_checks.sql
-- Purpose: core arithmetic and business-rule reconciliation
-- ===============================================

-- Due date must not be before invoice date
SELECT *
FROM stg.invoices
WHERE due_date < invoice_date;

-- Total payment per invoice should not exceed gross amount (+ tolerance)
SELECT
    fi.invoice_number,
    fi.gross_amount,
    SUM(fp.payment_amount) AS total_paid
FROM dw.fact_invoice fi
JOIN dw.fact_payment fp ON fi.invoice_key = fp.invoice_key
GROUP BY fi.invoice_number, fi.gross_amount
HAVING SUM(fp.payment_amount) > fi.gross_amount + 0.01;

-- Invoice arithmetic check
SELECT *
FROM dw.fact_invoice
WHERE ROUND(gross_amount - tax_amount - net_amount, 2) <> 0;

-- Payment/customer key consistency
SELECT
    fp.payment_reference,
    fp.customer_key AS payment_customer_key,
    fi.customer_key AS invoice_customer_key
FROM dw.fact_payment fp
JOIN dw.fact_invoice fi ON fp.invoice_key = fi.invoice_key
WHERE fp.customer_key <> fi.customer_key;
