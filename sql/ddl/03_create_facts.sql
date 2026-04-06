CREATE TABLE dw.fact_invoice (
    invoice_key              BIGSERIAL PRIMARY KEY,
    invoice_number           VARCHAR(40) NOT NULL UNIQUE,
    customer_key             BIGINT NOT NULL REFERENCES dw.dim_customer(customer_key),
    invoice_date_key         INTEGER NOT NULL REFERENCES dw.dim_date(date_key),
    due_date_key             INTEGER NOT NULL REFERENCES dw.dim_date(date_key),
    invoice_date             DATE NOT NULL,
    due_date                 DATE NOT NULL,
    currency_code            CHAR(3) NOT NULL DEFAULT 'EUR',
    gross_amount             NUMERIC(18,2) NOT NULL,
    tax_amount               NUMERIC(18,2) NOT NULL DEFAULT 0,
    net_amount               NUMERIC(18,2) NOT NULL,
    invoice_status           VARCHAR(20) NOT NULL,
    created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dw.fact_payment (
    payment_key              BIGSERIAL PRIMARY KEY,
    payment_reference        VARCHAR(50) NOT NULL UNIQUE,
    invoice_key              BIGINT NOT NULL REFERENCES dw.fact_invoice(invoice_key),
    customer_key             BIGINT NOT NULL REFERENCES dw.dim_customer(customer_key),
    payment_date_key         INTEGER NOT NULL REFERENCES dw.dim_date(date_key),
    payment_date             DATE NOT NULL,
    payment_amount           NUMERIC(18,2) NOT NULL,
    payment_method           VARCHAR(30),
    is_partial_payment       BOOLEAN NOT NULL DEFAULT FALSE,
    days_late                INTEGER,
    created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dw.fact_exposure_snapshot (
    exposure_snapshot_key        BIGSERIAL PRIMARY KEY,
    snapshot_date_key            INTEGER NOT NULL REFERENCES dw.dim_date(date_key),
    snapshot_date                DATE NOT NULL,
    customer_key                 BIGINT NOT NULL REFERENCES dw.dim_customer(customer_key),
    rating_key                   BIGINT NOT NULL REFERENCES dw.dim_rating(rating_key),
    credit_limit_amount          NUMERIC(18,2) NOT NULL,
    total_outstanding_exposure   NUMERIC(18,2) NOT NULL,
    overdue_exposure             NUMERIC(18,2) NOT NULL,
    current_exposure             NUMERIC(18,2) NOT NULL,
    utilization_ratio            NUMERIC(10,4) NOT NULL,
    invoices_open_count          INTEGER NOT NULL,
    overdue_invoices_count       INTEGER NOT NULL,
    created_at                   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (snapshot_date, customer_key)
);

CREATE TABLE dw.fact_default_event (
    default_event_key            BIGSERIAL PRIMARY KEY,
    customer_key                 BIGINT NOT NULL REFERENCES dw.dim_customer(customer_key),
    default_date_key             INTEGER NOT NULL REFERENCES dw.dim_date(date_key),
    default_date                 DATE NOT NULL,
    rating_key                   BIGINT NOT NULL REFERENCES dw.dim_rating(rating_key),
    default_type                 VARCHAR(50) NOT NULL,
    defaulted_amount             NUMERIC(18,2) NOT NULL,
    recovered_amount             NUMERIC(18,2) NOT NULL DEFAULT 0,
    recovery_rate                NUMERIC(10,4),
    notes                        TEXT,
    created_at                   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dw.fact_ar_aging_snapshot (
    aging_snapshot_key           BIGSERIAL PRIMARY KEY,
    snapshot_date_key            INTEGER NOT NULL REFERENCES dw.dim_date(date_key),
    snapshot_date                DATE NOT NULL,
    customer_key                 BIGINT NOT NULL REFERENCES dw.dim_customer(customer_key),
    total_outstanding_amount     NUMERIC(18,2) NOT NULL,
    current_amount               NUMERIC(18,2) NOT NULL,
    bucket_1_30_amount           NUMERIC(18,2) NOT NULL,
    bucket_31_60_amount          NUMERIC(18,2) NOT NULL,
    bucket_61_90_amount          NUMERIC(18,2) NOT NULL,
    bucket_91_plus_amount        NUMERIC(18,2) NOT NULL,
    created_at                   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (snapshot_date, customer_key)
);
