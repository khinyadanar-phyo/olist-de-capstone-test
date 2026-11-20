import os
import shutil
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent   # scripts/ -> project root
load_dotenv(BASE_DIR / ".env")                      # read .env into environment variables

data_dir = os.getenv("DATA_DIR")
if not data_dir:
    raise RuntimeError("DATA_DIR is not set. Add it to the .env file in the project root.")
DATA_DIR = BASE_DIR / data_dir

orders = pd.read_csv(DATA_DIR / "olist_orders_dataset.csv")
items = pd.read_csv(DATA_DIR / "olist_order_items_dataset.csv")
customers = pd.read_csv(DATA_DIR / "olist_customers_dataset.csv")
df = orders.merge(items, on="order_id").merge(customers, on="customer_id")


def count_files(folder):
    """Return the number of files under ``folder``."""
    return sum(len(files) for _, _, files in os.walk(folder))


shutil.rmtree("by_state", ignore_errors=True)
shutil.rmtree("by_city", ignore_errors=True)
df.to_parquet("by_state", partition_cols=["customer_state"], index=False)
df.to_parquet("by_city", partition_cols=["customer_city"], index=False,
              max_partitions=5000)

print("by_state files:", count_files("by_state"))
print("by_city files: ", count_files("by_city"))