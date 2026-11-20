import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent   # scripts/ -> project root
load_dotenv(BASE_DIR / ".env")                      # read .env into environment variables

DATA_DIR = BASE_DIR / os.getenv("DATA_DIR", "data/raw")

orders = pd.read_csv(
    DATA_DIR / "olist_orders_dataset.csv",
    encoding="utf-8",
    dtype={"order_id": "string",
           "customer_id": "string",
           "order_status": "category"},
    parse_dates=["order_purchase_timestamp",
                 "order_approved_at",
                 "order_estimated_delivery_date"],
)

customers = pd.read_csv(
    DATA_DIR / "olist_customers_dataset.csv",
    dtype={"customer_zip_code_prefix": "string"},
)

orders.info()