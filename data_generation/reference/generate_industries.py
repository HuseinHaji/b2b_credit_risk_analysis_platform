import pandas as pd


def generate_industries() -> pd.DataFrame:
    industries = [
        {"industry_code": "MFG", "industry_name": "Manufacturing", "sector_group": "Industrial", "risk_weight": 1.00},
        {"industry_code": "WHL", "industry_name": "Wholesale Trade", "sector_group": "Commercial", "risk_weight": 1.08},
        {"industry_code": "CON", "industry_name": "Construction", "sector_group": "Industrial", "risk_weight": 1.15},
        {"industry_code": "FNB", "industry_name": "Food & Beverage", "sector_group": "Consumer", "risk_weight": 0.95},
        {"industry_code": "LOG", "industry_name": "Logistics", "sector_group": "Services", "risk_weight": 1.02},
        {"industry_code": "ELE", "industry_name": "Electronics", "sector_group": "Technology", "risk_weight": 1.04},
        {"industry_code": "CHE", "industry_name": "Chemicals", "sector_group": "Industrial", "risk_weight": 1.12},
        {"industry_code": "RET", "industry_name": "Retail Distribution", "sector_group": "Consumer", "risk_weight": 1.00},
    ]
    return pd.DataFrame(industries)
