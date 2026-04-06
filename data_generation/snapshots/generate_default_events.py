import random

import pandas as pd


RATING_DEFAULT_BASE = {
    "A1": 0.002,
    "A2": 0.004,
    "B1": 0.010,
    "B2": 0.020,
    "C1": 0.060,
    "C2": 0.120,
    "D": 0.300,
}


def generate_default_events(
    customers: pd.DataFrame,
    exposure_snapshots: pd.DataFrame,
    seed: int = 42,
) -> pd.DataFrame:
    random.seed(seed)

    if exposure_snapshots.empty:
        return pd.DataFrame(
            columns=[
                "customer_code",
                "default_date",
                "rating_code",
                "default_type",
                "defaulted_amount",
                "recovered_amount",
                "recovery_rate",
                "notes",
            ]
        )

    snaps = exposure_snapshots.copy()
    snaps["snapshot_date"] = pd.to_datetime(snaps["snapshot_date"])

    rows = []
    for _, customer in customers.iterrows():
        customer_code = customer["customer_code"]
        rating_code = customer["rating_code"]
        base_prob = RATING_DEFAULT_BASE.get(rating_code, 0.01)

        cs = snaps.loc[snaps["customer_code"] == customer_code].sort_values("snapshot_date")
        if cs.empty:
            continue

        latest = cs.iloc[-1]
        overdue_ratio = (
            latest["overdue_exposure"] / latest["total_outstanding_exposure"]
            if latest["total_outstanding_exposure"] > 0
            else 0
        )
        utilization = latest["utilization_ratio"]
        overdue_trend = cs["overdue_exposure"].pct_change().fillna(0).tail(3).mean()

        default_probability = base_prob
        default_probability += min(0.25, overdue_ratio * 0.60)
        default_probability += min(0.20, max(0.0, utilization - 0.65) * 0.40)
        default_probability += max(0.0, overdue_trend * 0.15)
        default_probability = min(default_probability, 0.45)

        if random.random() > default_probability:
            continue

        default_date = (latest["snapshot_date"] + pd.Timedelta(days=random.randint(2, 28))).date()
        defaulted_amount = round(
            min(latest["total_outstanding_exposure"], float(customer["credit_limit_amount"]) * 0.9),
            2,
        )
        recovered_amount = round(defaulted_amount * random.uniform(0.05, 0.42), 2)

        rows.append(
            {
                "customer_code": customer_code,
                "default_date": default_date,
                "rating_code": rating_code,
                "default_type": random.choice(["Insolvency", "Payment Failure", "Write-off"]),
                "defaulted_amount": defaulted_amount,
                "recovered_amount": recovered_amount,
                "recovery_rate": round(recovered_amount / defaulted_amount if defaulted_amount > 0 else 0, 4),
                "notes": "Simulated event based on utilization and overdue deterioration.",
            }
        )

    return pd.DataFrame(rows)
