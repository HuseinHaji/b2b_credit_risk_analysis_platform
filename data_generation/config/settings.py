from dataclasses import dataclass

@dataclass(frozen=True)
class Settings:
    seed: int = 42
    start_date: str = "2024-01-01"
    end_date: str = "2025-12-31"
    n_customers: int = 1200
    currency: str = "EUR"
    output_dir: str = "data/raw_exports"

SETTINGS = Settings()
