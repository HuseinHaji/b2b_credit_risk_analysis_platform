-- ===============================================
-- 04_load_staging_tables.sql
-- Purpose: create raw/stg landing structures and normalize source data
-- ===============================================

-- 1) RAW TABLES (CSV landing)
CREATE TABLE IF NOT EXISTS raw.industries (
	industry_code       VARCHAR(20),
	industry_name       VARCHAR(100),
	sector_group        VARCHAR(100),
	risk_weight         NUMERIC(6,3)
);

CREATE TABLE IF NOT EXISTS raw.countries (
	country_code        CHAR(2),
	country_name        VARCHAR(100),
	region_name         VARCHAR(100),
	country_risk_group  VARCHAR(50),
	macro_stress_factor NUMERIC(8,4)
);

CREATE TABLE IF NOT EXISTS raw.ratings (
	rating_code         VARCHAR(10),
	rating_name         VARCHAR(50),
	rating_rank         INTEGER,
	risk_band           VARCHAR(20),
	portfolio_weight    NUMERIC(8,4)
);

CREATE TABLE IF NOT EXISTS raw.customers (
	customer_code               VARCHAR(30),
	customer_name               VARCHAR(200),
	legal_entity_type           VARCHAR(50),
	size_segment                VARCHAR(20),
	annual_revenue_estimate     NUMERIC(18,2),
	employee_count_estimate     INTEGER,
	onboarding_date             DATE,
	status                      VARCHAR(20),
	industry_code               VARCHAR(20),
	country_code                CHAR(2),
	rating_code                 VARCHAR(10),
	credit_limit_amount         NUMERIC(18,2),
	payment_terms_days          INTEGER,
	risk_segment                VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS raw.invoices (
	invoice_number       VARCHAR(40),
	customer_code        VARCHAR(30),
	invoice_date         DATE,
	due_date             DATE,
	currency_code        CHAR(3),
	gross_amount         NUMERIC(18,2),
	tax_amount           NUMERIC(18,2),
	net_amount           NUMERIC(18,2),
	invoice_status       VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS raw.payments (
	payment_reference    VARCHAR(50),
	invoice_number       VARCHAR(40),
	customer_code        VARCHAR(30),
	payment_date         DATE,
	payment_amount       NUMERIC(18,2),
	payment_method       VARCHAR(30),
	is_partial_payment   BOOLEAN
);

CREATE TABLE IF NOT EXISTS raw.exposure_snapshots (
	snapshot_date                DATE,
	customer_code                VARCHAR(30),
	rating_code                  VARCHAR(10),
	credit_limit_amount          NUMERIC(18,2),
	total_outstanding_exposure   NUMERIC(18,2),
	overdue_exposure             NUMERIC(18,2),
	current_exposure             NUMERIC(18,2),
	utilization_ratio            NUMERIC(10,4),
	invoices_open_count          INTEGER,
	overdue_invoices_count       INTEGER
);

CREATE TABLE IF NOT EXISTS raw.aging_snapshots (
	snapshot_date                DATE,
	customer_code                VARCHAR(30),
	total_outstanding_amount     NUMERIC(18,2),
	current_amount               NUMERIC(18,2),
	bucket_1_30_amount           NUMERIC(18,2),
	bucket_31_60_amount          NUMERIC(18,2),
	bucket_61_90_amount          NUMERIC(18,2),
	bucket_91_plus_amount        NUMERIC(18,2)
);

CREATE TABLE IF NOT EXISTS raw.default_events (
	customer_code        VARCHAR(30),
	default_date         DATE,
	rating_code          VARCHAR(10),
	default_type         VARCHAR(50),
	defaulted_amount     NUMERIC(18,2),
	recovered_amount     NUMERIC(18,2),
	recovery_rate        NUMERIC(10,4),
	notes                TEXT
);

-- NOTE: Load CSVs into raw.* tables with COPY/\copy from your environment.
-- Example:
-- \copy raw.customers FROM 'data/raw_exports/customers.csv' WITH (FORMAT csv, HEADER true)

-- 2) STAGING TABLES (clean + typed)
CREATE TABLE IF NOT EXISTS stg.industries (LIKE raw.industries);
CREATE TABLE IF NOT EXISTS stg.countries (LIKE raw.countries);
CREATE TABLE IF NOT EXISTS stg.ratings (LIKE raw.ratings);
CREATE TABLE IF NOT EXISTS stg.customers (LIKE raw.customers);
CREATE TABLE IF NOT EXISTS stg.invoices (LIKE raw.invoices);
CREATE TABLE IF NOT EXISTS stg.payments (LIKE raw.payments);
CREATE TABLE IF NOT EXISTS stg.exposure_snapshots (LIKE raw.exposure_snapshots);
CREATE TABLE IF NOT EXISTS stg.aging_snapshots (LIKE raw.aging_snapshots);
CREATE TABLE IF NOT EXISTS stg.default_events (LIKE raw.default_events);

TRUNCATE TABLE
	stg.industries,
	stg.countries,
	stg.ratings,
	stg.customers,
	stg.invoices,
	stg.payments,
	stg.exposure_snapshots,
	stg.aging_snapshots,
	stg.default_events;

INSERT INTO stg.industries
SELECT DISTINCT
	TRIM(industry_code) AS industry_code,
	TRIM(industry_name) AS industry_name,
	TRIM(sector_group) AS sector_group,
	COALESCE(risk_weight, 1.000) AS risk_weight
FROM raw.industries
WHERE industry_code IS NOT NULL;

INSERT INTO stg.countries
SELECT DISTINCT
	TRIM(country_code) AS country_code,
	TRIM(country_name) AS country_name,
	TRIM(region_name) AS region_name,
	TRIM(country_risk_group) AS country_risk_group,
	COALESCE(macro_stress_factor, 1.0000) AS macro_stress_factor
FROM raw.countries
WHERE country_code IS NOT NULL;

INSERT INTO stg.ratings
SELECT DISTINCT
	TRIM(rating_code) AS rating_code,
	TRIM(rating_name) AS rating_name,
	rating_rank,
	TRIM(risk_band) AS risk_band,
	portfolio_weight
FROM raw.ratings
WHERE rating_code IS NOT NULL;

INSERT INTO stg.customers
SELECT DISTINCT
	TRIM(customer_code) AS customer_code,
	TRIM(customer_name) AS customer_name,
	TRIM(legal_entity_type) AS legal_entity_type,
	UPPER(TRIM(size_segment)) AS size_segment,
	annual_revenue_estimate,
	employee_count_estimate,
	onboarding_date,
	COALESCE(TRIM(status), 'ACTIVE') AS status,
	TRIM(industry_code) AS industry_code,
	TRIM(country_code) AS country_code,
	TRIM(rating_code) AS rating_code,
	COALESCE(credit_limit_amount, 0) AS credit_limit_amount,
	payment_terms_days,
	TRIM(risk_segment) AS risk_segment
FROM raw.customers
WHERE customer_code IS NOT NULL;

INSERT INTO stg.invoices
SELECT DISTINCT
	TRIM(invoice_number) AS invoice_number,
	TRIM(customer_code) AS customer_code,
	invoice_date,
	due_date,
	COALESCE(currency_code, 'EUR') AS currency_code,
	gross_amount,
	COALESCE(tax_amount, 0) AS tax_amount,
	net_amount,
	COALESCE(invoice_status, 'OPEN') AS invoice_status
FROM raw.invoices
WHERE invoice_number IS NOT NULL;

INSERT INTO stg.payments
SELECT DISTINCT
	TRIM(payment_reference) AS payment_reference,
	TRIM(invoice_number) AS invoice_number,
	TRIM(customer_code) AS customer_code,
	payment_date,
	payment_amount,
	payment_method,
	COALESCE(is_partial_payment, FALSE) AS is_partial_payment
FROM raw.payments
WHERE payment_reference IS NOT NULL;

INSERT INTO stg.exposure_snapshots
SELECT DISTINCT
	snapshot_date,
	TRIM(customer_code) AS customer_code,
	TRIM(rating_code) AS rating_code,
	credit_limit_amount,
	total_outstanding_exposure,
	overdue_exposure,
	current_exposure,
	utilization_ratio,
	invoices_open_count,
	overdue_invoices_count
FROM raw.exposure_snapshots
WHERE snapshot_date IS NOT NULL
  AND customer_code IS NOT NULL;

INSERT INTO stg.aging_snapshots
SELECT DISTINCT
	snapshot_date,
	TRIM(customer_code) AS customer_code,
	total_outstanding_amount,
	current_amount,
	bucket_1_30_amount,
	bucket_31_60_amount,
	bucket_61_90_amount,
	bucket_91_plus_amount
FROM raw.aging_snapshots
WHERE snapshot_date IS NOT NULL
  AND customer_code IS NOT NULL;

INSERT INTO stg.default_events
SELECT DISTINCT
	TRIM(customer_code) AS customer_code,
	default_date,
	TRIM(rating_code) AS rating_code,
	TRIM(default_type) AS default_type,
	defaulted_amount,
	COALESCE(recovered_amount, 0) AS recovered_amount,
	recovery_rate,
	notes
FROM raw.default_events
WHERE customer_code IS NOT NULL
  AND default_date IS NOT NULL;
