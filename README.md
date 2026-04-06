# B2B Credit Risk Analytics Platform

An end-to-end analytics portfolio project that simulates how a trade credit insurer, receivables finance team, or B2B credit control function would monitor portfolio risk, payment behavior, overdue exposure, utilization, and deterioration across customers, industries, and countries.

## What this repository contains

- `data_generation/` — Python scripts to generate synthetic B2B customers, invoices, payments, snapshots, and default events
- `data/` — sample exports and raw CSV output targets
- `sql/` — PostgreSQL DDL, load scripts, mart definitions, and validation checks
- `website/` — Next.js case-study website scaffold for the project
- `docs/` — architecture, business framing, and analytics documentation
- `dashboard_assets/` — dashboard screenshot placeholders and notes

## Getting started

### Python synthetic data generation

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python data_generation/main.py
```

### PostgreSQL warehouse

The SQL folder contains schema creation, load, snapshot derivation, and mart scripts up to an enterprise-style star schema.

### Website

The website is implemented as a Next.js app in `website/`.

## Project goals

- Model a realistic B2B trade receivables portfolio
- Build a warehouse-driven analytics schema in PostgreSQL
- Generate business-relevant KPIs and deterioration signals
- Design a dashboard suite for credit risk monitoring
- Publish a professional public case study website
