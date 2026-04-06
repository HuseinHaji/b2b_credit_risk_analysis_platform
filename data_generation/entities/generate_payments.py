import numpy as np
import pandas as pd

RATING_DELAY_PARAMS = {
    "A1": (0.80, -3, 6),
    "A2": (0.78, -1, 8),
    "B1": (0.72, 4, 12),
    "B2": (0.66, 10, 18),
    "C1": (0.58, 18, 28),
    "C2": (0.45, 30, 40),
    "D":  (0.20, 60, 55),
}


def generate_payments(invoices: pd.DataFrame, customers: pd.DataFrame) -> pd.DataFrame:
    customer_rating = customers.set_index("customer_code")["rating_code"].to_dict()
    rows = []
    payment_seq = 1

    for _, inv in invoices.iterrows():
        rating = customer_rating[inv["customer_code"]]
        full_prob, delay_mean, delay_sd = RATING_DELAY_PARAMS[rating]

        if np.random.rand() < 0.08:
            continue

        is_full = np.random.rand() < full_prob
        delay_days = int(np.random.normal(delay_mean, delay_sd))
        payment_date = pd.to_datetime(inv["due_date"]) + pd.Timedelta(days=delay_days)

        if is_full:
            parts = [inv["gross_amount"]]
        else:
            first = round(inv["gross_amount"] * np.random.uniform(0.35, 0.75), 2)
            second = round(inv["gross_amount"] - first, 2)
            parts = [first, second]

        for idx, amount in enumerate(parts):
            part_date = payment_date + pd.Timedelta(days=idx * np.random.randint(7, 25))
            rows.append({
                "payment_reference": f"PAY{payment_seq:09d}",
                "invoice_number": inv["invoice_number"],
                "customer_code": inv["customer_code"],
                "payment_date": part_date.date(),
                "payment_amount": round(amount, 2),
                "payment_method": np.random.choice(["Bank Transfer", "SEPA", "ACH", "Card"]),
                "is_partial_payment": len(parts) > 1,
            })
            payment_seq += 1

    return pd.DataFrame(rows)
