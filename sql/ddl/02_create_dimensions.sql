CREATE TABLE dw.dim_industry (
    industry_key            BIGSERIAL PRIMARY KEY,
    industry_code           VARCHAR(20) NOT NULL UNIQUE,
    industry_name           VARCHAR(100) NOT NULL,
    sector_group            VARCHAR(100),
    risk_weight             NUMERIC(6,3) NOT NULL DEFAULT 1.000,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dw.dim_country (
    country_key             BIGSERIAL PRIMARY KEY,
    country_code            CHAR(2) NOT NULL UNIQUE,
    country_name            VARCHAR(100) NOT NULL,
    region_name             VARCHAR(100),
    country_risk_group      VARCHAR(50),
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dw.dim_rating (
    rating_key              BIGSERIAL PRIMARY KEY,
    rating_code             VARCHAR(10) NOT NULL UNIQUE,
    rating_name             VARCHAR(50) NOT NULL,
    rating_rank             INTEGER NOT NULL,
    risk_band               VARCHAR(20) NOT NULL,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dw.dim_date (
    date_key                INTEGER PRIMARY KEY,
    calendar_date           DATE NOT NULL UNIQUE,
    day_of_month            INTEGER NOT NULL,
    month_number            INTEGER NOT NULL,
    month_name              VARCHAR(20) NOT NULL,
    quarter_number          INTEGER NOT NULL,
    year_number             INTEGER NOT NULL,
    year_month              VARCHAR(7) NOT NULL,
    is_month_end            BOOLEAN NOT NULL,
    is_quarter_end          BOOLEAN NOT NULL,
    is_year_end             BOOLEAN NOT NULL
);

CREATE TABLE dw.dim_customer (
    customer_key                    BIGSERIAL PRIMARY KEY,
    customer_code                   VARCHAR(30) NOT NULL UNIQUE,
    customer_name                   VARCHAR(200) NOT NULL,
    legal_entity_type               VARCHAR(50),
    size_segment                    VARCHAR(20) NOT NULL,
    annual_revenue_estimate         NUMERIC(18,2),
    employee_count_estimate         INTEGER,
    onboarding_date                 DATE NOT NULL,
    status                          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    industry_key                    BIGINT NOT NULL REFERENCES dw.dim_industry(industry_key),
    country_key                     BIGINT NOT NULL REFERENCES dw.dim_country(country_key),
    rating_key                      BIGINT NOT NULL REFERENCES dw.dim_rating(rating_key),
    credit_limit_amount             NUMERIC(18,2) NOT NULL DEFAULT 0,
    payment_terms_days              INTEGER NOT NULL,
    risk_segment                    VARCHAR(20),
    created_at                      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
