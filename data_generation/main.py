import pandas as pd

from config.settings import SETTINGS
from reference.generate_countries import generate_countries
from reference.generate_industries import generate_industries
from reference.generate_ratings import generate_ratings
from utils.exports import export_csv
from utils.random_state import set_seed
from entities.generate_customers import generate_customers
from entities.generate_invoices import generate_invoices
from entities.generate_payments import generate_payments
from snapshots.generate_exposure_snapshots import generate_exposure_snapshots
from snapshots.generate_aging_snapshots import generate_aging_snapshots
from snapshots.generate_default_events import generate_default_events


def main() -> None:
    set_seed(SETTINGS.seed)

    industries = generate_industries()
    countries = generate_countries()
    ratings = generate_ratings()

    export_csv(industries, SETTINGS.output_dir, "industries.csv")
    export_csv(countries, SETTINGS.output_dir, "countries.csv")
    export_csv(ratings, SETTINGS.output_dir, "ratings.csv")

    customers = generate_customers(SETTINGS.n_customers, industries, countries, ratings)
    date_range = pd.date_range(SETTINGS.start_date, SETTINGS.end_date, freq="D")
    invoices = generate_invoices(customers, date_range)
    payments = generate_payments(invoices, customers)
    exposure_snapshots = generate_exposure_snapshots(invoices, payments, customers)
    aging_snapshots = generate_aging_snapshots(invoices, payments)
    default_events = generate_default_events(customers, exposure_snapshots, SETTINGS.seed)

    export_csv(customers, SETTINGS.output_dir, "customers.csv")
    export_csv(invoices, SETTINGS.output_dir, "invoices.csv")
    export_csv(payments, SETTINGS.output_dir, "payments.csv")
    export_csv(exposure_snapshots, SETTINGS.output_dir, "exposure_snapshots.csv")
    export_csv(aging_snapshots, SETTINGS.output_dir, "aging_snapshots.csv")
    export_csv(default_events, SETTINGS.output_dir, "default_events.csv")


if __name__ == "__main__":
    main()
