import numpy as np
import pandas as pd

SIZE_SEGMENTS = {
    "SMALL": {"rev_min": 1_000_000, "rev_max": 10_000_000, "base_limit": 50_000},
    "MID":   {"rev_min": 10_000_000, "rev_max": 100_000_000, "base_limit": 250_000},
    "LARGE": {"rev_min": 100_000_000, "rev_max": 500_000_000, "base_limit": 1_000_000},
}

RATING_LIMIT_MULTIPLIER = {
    "A1": 1.40, "A2": 1.20, "B1": 1.00, "B2": 0.85, "C1": 0.65, "C2": 0.45, "D": 0.20
}


def generate_customers(n_customers: int, industries: pd.DataFrame, countries: pd.DataFrame, ratings: pd.DataFrame) -> pd.DataFrame:
    rows = []
    size_choices = ["SMALL", "MID", "LARGE"]
    size_probs = [0.60, 0.30, 0.10]

    for i in range(1, n_customers + 1):
        size = np.random.choice(size_choices, p=size_probs)
        seg = SIZE_SEGMENTS[size]

        industry = industries.sample(1).iloc[0]
        country = countries.sample(1).iloc[0]
        rating = ratings.sample(1, weights=ratings["portfolio_weight"]).iloc[0]

        revenue = float(np.random.uniform(seg["rev_min"], seg["rev_max"]))
        credit_limit = seg["base_limit"] * RATING_LIMIT_MULTIPLIER[rating["rating_code"]] * industry["risk_weight"]
        credit_limit *= np.random.uniform(0.8, 1.2)

        payment_terms_days = int(np.random.choice([30, 45, 60, 90], p=[0.35, 0.25, 0.30, 0.10]))

        rows.append({
            "customer_code": f"CUST{i:05d}",
            "customer_name": f"Customer {i:05d}",
            "legal_entity_type": np.random.choice(["LLC", "GmbH", "SA", "AG", "SARL"]),
            "size_segment": size,
            "annual_revenue_estimate": round(revenue, 2),
            "employee_count_estimate": int(np.random.randint(15, 450) if size == "SMALL" else np.random.randint(250, 2500) if size == "MID" else np.random.randint(1200, 12000)),
            "onboarding_date": pd.Timestamp("2022-01-01") + pd.Timedelta(days=int(np.random.uniform(0, 730))),
            "status": "ACTIVE",
            "industry_code": industry["industry_code"],
            "country_code": country["country_code"],
            "rating_code": rating["rating_code"],
            "credit_limit_amount": round(credit_limit, 2),
            "payment_terms_days": payment_terms_days,
            "risk_segment": "Medium" if rating["risk_band"] == "Medium" else "Low" if rating["risk_band"] == "Low" else "High",
        })

    return pd.DataFrame(rows)
