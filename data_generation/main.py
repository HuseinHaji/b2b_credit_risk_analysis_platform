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

    export_csv(customers, SETTINGS.output_dir, "customers.csv")
    export_csv(invoices, SETTINGS.output_dir, "invoices.csv")
    export_csv(payments, SETTINGS.output_dir, "payments.csv")


if __name__ == "__main__":
    main()
