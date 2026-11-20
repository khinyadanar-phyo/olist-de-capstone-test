import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent   # scripts/ -> project root
load_dotenv(BASE_DIR / ".env")                      # read .env into environment variables

data_dir = os.getenv("DATA_DIR")
output_dir = os.getenv("OUTPUT_DIR")
if not data_dir or not output_dir:
    raise RuntimeError("DATA_DIR and OUTPUT_DIR must be set in the .env file in the project root.")

DATA_DIR = BASE_DIR / data_dir
OUT_DIR = BASE_DIR / output_dir / "raw_parquet"
OUT_DIR.mkdir(parents=True, exist_ok=True)  # creates the folder; doesn't fail if it already exists

csv_path = DATA_DIR / "olist_orders_dataset.csv"
parquet_path = OUT_DIR / "olist_orders_dataset.parquet"

pd.read_csv(csv_path).to_parquet(parquet_path, index=False)  # CSV -> Parquet

df = pd.read_parquet(parquet_path)
print(df)
print(df.dtypes)