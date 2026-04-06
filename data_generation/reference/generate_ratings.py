import pandas as pd


def generate_ratings() -> pd.DataFrame:
    ratings = [
        {"rating_code": "A1", "rating_name": "A1", "rating_rank": 1, "risk_band": "Low", "portfolio_weight": 0.15},
        {"rating_code": "A2", "rating_name": "A2", "rating_rank": 2, "risk_band": "Low", "portfolio_weight": 0.20},
        {"rating_code": "B1", "rating_name": "B1", "rating_rank": 3, "risk_band": "Medium", "portfolio_weight": 0.25},
        {"rating_code": "B2", "rating_name": "B2", "rating_rank": 4, "risk_band": "Medium", "portfolio_weight": 0.20},
        {"rating_code": "C1", "rating_name": "C1", "rating_rank": 5, "risk_band": "High", "portfolio_weight": 0.12},
        {"rating_code": "C2", "rating_name": "C2", "rating_rank": 6, "risk_band": "High", "portfolio_weight": 0.06},
        {"rating_code": "D",  "rating_name": "D",  "rating_rank": 7, "risk_band": "Very High", "portfolio_weight": 0.02},
    ]
    return pd.DataFrame(ratings)
