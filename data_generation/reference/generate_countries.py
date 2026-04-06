import pandas as pd


def generate_countries() -> pd.DataFrame:
    countries = [
        {"country_code": "DE", "country_name": "Germany", "region_name": "Western Europe", "country_risk_group": "Stable", "macro_stress_factor": 1.00},
        {"country_code": "FR", "country_name": "France", "region_name": "Western Europe", "country_risk_group": "Stable", "macro_stress_factor": 1.02},
        {"country_code": "IT", "country_name": "Italy", "region_name": "Southern Europe", "country_risk_group": "Moderate", "macro_stress_factor": 1.10},
        {"country_code": "ES", "country_name": "Spain", "region_name": "Southern Europe", "country_risk_group": "Moderate", "macro_stress_factor": 1.08},
        {"country_code": "NL", "country_name": "Netherlands", "region_name": "Western Europe", "country_risk_group": "Stable", "macro_stress_factor": 0.98},
        {"country_code": "PL", "country_name": "Poland", "region_name": "Central Europe", "country_risk_group": "Moderate", "macro_stress_factor": 1.12},
        {"country_code": "SE", "country_name": "Sweden", "region_name": "Northern Europe", "country_risk_group": "Stable", "macro_stress_factor": 0.96},
        {"country_code": "CZ", "country_name": "Czech Republic", "region_name": "Central Europe", "country_risk_group": "Moderate", "macro_stress_factor": 1.09},
    ]
    return pd.DataFrame(countries)
