# Architecture Overview

The solution is built as a layered analytics platform:

- `raw` for source CSV exports
- `stg` for staging and normalization
- `dw` for conformed dimensions and facts
- `mart` for reusable KPI views and feature tables
