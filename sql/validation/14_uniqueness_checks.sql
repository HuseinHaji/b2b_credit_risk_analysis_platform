-- ===============================================
-- 14_uniqueness_checks.sql
-- Purpose: detect duplicate natural keys in staging
-- ===============================================

SELECT customer_code, COUNT(*)
FROM stg.customers
GROUP BY customer_code
HAVING COUNT(*) > 1;

SELECT invoice_number, COUNT(*)
FROM stg.invoices
GROUP BY invoice_number
HAVING COUNT(*) > 1;

SELECT payment_reference, COUNT(*)
FROM stg.payments
GROUP BY payment_reference
HAVING COUNT(*) > 1;
