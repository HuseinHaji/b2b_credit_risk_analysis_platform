import numpy as np
import pandas as pd


def generate_aging_snapshots(invoices: pd.DataFrame, payments: pd.DataFrame) -> pd.DataFrame:
    inv = invoices.copy()
    pay = payments.copy()

    inv["invoice_date"] = pd.to_datetime(inv["invoice_date"])
    inv["due_date"] = pd.to_datetime(inv["due_date"])
    pay["payment_date"] = pd.to_datetime(pay["payment_date"])

    month_ends = pd.date_range(inv["invoice_date"].min(), inv["invoice_date"].max(), freq="ME")

    rows = []
    for snapshot_date in month_ends:
        paid_to_snapshot = (
            pay.loc[pay["payment_date"] <= snapshot_date]
            .groupby("invoice_number", as_index=False)
            .agg(paid_to_snapshot=("payment_amount", "sum"))
        )

        open_inv = inv.loc[inv["invoice_date"] <= snapshot_date].merge(
            paid_to_snapshot,
            how="left",
            on="invoice_number",
        )
        open_inv["paid_to_snapshot"] = open_inv["paid_to_snapshot"].fillna(0)
        open_inv["outstanding_amount"] = (open_inv["gross_amount"] - open_inv["paid_to_snapshot"]).clip(lower=0)
        open_inv = open_inv.loc[open_inv["outstanding_amount"] > 0].copy()

        if open_inv.empty:
            continue

        days_past_due = (snapshot_date.normalize() - open_inv["due_date"].dt.normalize()).dt.days

        open_inv["current_amount"] = np.where(days_past_due <= 0, open_inv["outstanding_amount"], 0)
        open_inv["bucket_1_30_amount"] = np.where(
            (days_past_due >= 1) & (days_past_due <= 30), open_inv["outstanding_amount"], 0
        )
        open_inv["bucket_31_60_amount"] = np.where(
            (days_past_due >= 31) & (days_past_due <= 60), open_inv["outstanding_amount"], 0
        )
        open_inv["bucket_61_90_amount"] = np.where(
            (days_past_due >= 61) & (days_past_due <= 90), open_inv["outstanding_amount"], 0
        )
        open_inv["bucket_91_plus_amount"] = np.where(days_past_due >= 91, open_inv["outstanding_amount"], 0)

        grouped = (
            open_inv.groupby("customer_code", as_index=False)
            .agg(
                total_outstanding_amount=("outstanding_amount", "sum"),
                current_amount=("current_amount", "sum"),
                bucket_1_30_amount=("bucket_1_30_amount", "sum"),
                bucket_31_60_amount=("bucket_31_60_amount", "sum"),
                bucket_61_90_amount=("bucket_61_90_amount", "sum"),
                bucket_91_plus_amount=("bucket_91_plus_amount", "sum"),
            )
            .assign(snapshot_date=snapshot_date.date())
        )

        rows.append(grouped)

    if not rows:
        return pd.DataFrame(
            columns=[
                "snapshot_date",
                "customer_code",
                "total_outstanding_amount",
                "current_amount",
                "bucket_1_30_amount",
                "bucket_31_60_amount",
                "bucket_61_90_amount",
                "bucket_91_plus_amount",
            ]
        )

    out = pd.concat(rows, ignore_index=True)
    return out[
        [
            "snapshot_date",
            "customer_code",
            "total_outstanding_amount",
            "current_amount",
            "bucket_1_30_amount",
            "bucket_31_60_amount",
            "bucket_61_90_amount",
            "bucket_91_plus_amount",
        ]
    ]
