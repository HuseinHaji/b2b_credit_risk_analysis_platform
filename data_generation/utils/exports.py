from pathlib import Path
import pandas as pd


def export_csv(df: pd.DataFrame, output_dir: str, file_name: str) -> None:
    path = Path(output_dir)
    path.mkdir(parents=True, exist_ok=True)
    df.to_csv(path / file_name, index=False)
