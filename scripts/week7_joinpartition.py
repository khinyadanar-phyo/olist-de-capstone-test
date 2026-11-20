import os
import shutil
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
CSV_PATH = DATA_DIR / "olist_orders_dataset.csv"
OUT_DIR = BASE_DIR / output_dir / "sales_by_month"

# Read the CSV, then convert the timestamp column to datetime explicitly
df = pd.read_csv(CSV_PATH)
df["order_purchase_timestamp"] = pd.to_datetime(df["order_purchase_timestamp"], errors="coerce")

# Check for values that could not be parsed
bad = df["order_purchase_timestamp"].isna().sum()
print(bad, "unparseable timestamps")
if bad:
    df = df.dropna(subset=["order_purchase_timestamp"])  # drop them so they don't create a 'NaN' partition

# Create the partition column, e.g. 2018-01
df["purchase_month"] = df["order_purchase_timestamp"].dt.strftime("%Y-%m")

# Write partitioned Parquet (clear old output first so reruns don't duplicate rows)
shutil.rmtree(OUT_DIR, ignore_errors=True)
df.to_parquet(OUT_DIR, partition_cols=["purchase_month"], index=False)

# Read everything back
all_sales = pd.read_parquet(OUT_DIR)
print("all rows:", len(all_sales))

# Read only one month (the main benefit): orders purchased in 2018-01
jan = pd.read_parquet(OUT_DIR, filters=[("purchase_month", "==", "2018-01")])
print("2018-01 rows:", len(jan))