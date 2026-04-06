import numpy as np
import pandas as pd


def generate_exposure_snapshots(
    invoices: pd.DataFrame,
    payments: pd.DataFrame,
    customers: pd.DataFrame,
) -> pd.DataFrame:
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

        open_inv["overdue_amount"] = np.where(
            snapshot_date > open_inv["due_date"],
            open_inv["outstanding_amount"],
            0,
        )
        open_inv["current_amount"] = open_inv["outstanding_amount"] - open_inv["overdue_amount"]
        open_inv["is_overdue"] = (open_inv["overdue_amount"] > 0).astype(int)

        grouped = (
            open_inv.groupby("customer_code", as_index=False)
            .agg(
                total_outstanding_exposure=("outstanding_amount", "sum"),
                overdue_exposure=("overdue_amount", "sum"),
                current_exposure=("current_amount", "sum"),
                invoices_open_count=("invoice_number", "nunique"),
                overdue_invoices_count=("is_overdue", "sum"),
            )
            .assign(snapshot_date=snapshot_date.date())
        )

        rows.append(grouped)

    if not rows:
        return pd.DataFrame(
            columns=[
                "snapshot_date",
                "customer_code",
                "rating_code",
                "credit_limit_amount",
                "total_outstanding_exposure",
                "overdue_exposure",
                "current_exposure",
                "utilization_ratio",
                "invoices_open_count",
                "overdue_invoices_count",
            ]
        )

    out = pd.concat(rows, ignore_index=True)
    meta = customers[["customer_code", "rating_code", "credit_limit_amount"]].copy()
    out = out.merge(meta, on="customer_code", how="left")

    out["utilization_ratio"] = np.where(
        out["credit_limit_amount"] > 0,
        out["total_outstanding_exposure"] / out["credit_limit_amount"],
        0,
    )

    return out[
        [
            "snapshot_date",
            "customer_code",
            "rating_code",
            "credit_limit_amount",
            "total_outstanding_exposure",
            "overdue_exposure",
            "current_exposure",
            "utilization_ratio",
            "invoices_open_count",
            "overdue_invoices_count",
        ]
    ]
