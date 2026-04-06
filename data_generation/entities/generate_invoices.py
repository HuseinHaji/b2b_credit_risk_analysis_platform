import numpy as np
import pandas as pd


def generate_invoices(customers: pd.DataFrame, date_range: pd.DatetimeIndex) -> pd.DataFrame:
    rows = []
    invoice_seq = 1

    for _, c in customers.iterrows():
        if c["size_segment"] == "SMALL":
            avg_monthly = 3
            amount_scale = 4_000
        elif c["size_segment"] == "MID":
            avg_monthly = 8
            amount_scale = 12_000
        else:
            avg_monthly = 20
            amount_scale = 35_000

        months = pd.period_range(date_range.min(), date_range.max(), freq="M")

        for period in months:
            n_invoices = np.random.poisson(avg_monthly)
            month_days = pd.date_range(period.start_time, period.end_time, freq="D")

            for _ in range(max(1, n_invoices)):
                invoice_date = pd.to_datetime(np.random.choice(month_days))
                due_date = invoice_date + pd.Timedelta(days=int(c["payment_terms_days"]))
                gross_amount = max(250, np.random.lognormal(mean=np.log(amount_scale), sigma=0.7))
                tax_amount = round(gross_amount * 0.19, 2)
                net_amount = round(gross_amount - tax_amount, 2)

                rows.append({
                    "invoice_number": f"INV{invoice_seq:08d}",
                    "customer_code": c["customer_code"],
                    "invoice_date": invoice_date.date(),
                    "due_date": due_date.date(),
                    "currency_code": "EUR",
                    "gross_amount": round(gross_amount, 2),
                    "tax_amount": tax_amount,
                    "net_amount": net_amount,
                    "invoice_status": "OPEN",
                })
                invoice_seq += 1

    return pd.DataFrame(rows)
