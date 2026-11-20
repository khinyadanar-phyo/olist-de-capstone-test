
import os
import pandas as pd

from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, URL, text

# 1. Load environment variables
BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env", override=True)
print("DB_USER:", os.getenv("DB_USER"))
print("DB_HOST:", os.getenv("DB_HOST"))
print("DB_PORT:", os.getenv("DB_PORT"))
print("DB_NAME:", os.getenv("DB_NAME"))

# 2. Get database credentials
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# 3. Create database URL
DB_URL = URL.create(
    drivername="postgresql+psycopg2",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database=DB_NAME
)

# 4. Create engine
engine = create_engine(DB_URL) #Create SQLAlchemy engine

# 5. Read Olist cleaned dataset
DATA_DIR = BASE_DIR / os.getenv("DATA_DIR")
INPUT_FILE = DATA_DIR / "olist_orders_dataset.csv"

df = pd.read_csv(INPUT_FILE)

print("Total records:", len(df))

# 6. Load into PostgreSQL
with engine.begin() as conn: #test the actual connection:

    conn.execute(
        text("CREATE SCHEMA IF NOT EXISTS staging")
    )

    df.to_sql( #  to_sql only knows INSERT. It cannot UPDATE an existing order. 
        "stg_delivered_orders",
        conn,
        schema="staging",
        if_exists="replace",
        index=False
    )

print("Data loaded successfully!")

# 7. Verify records
with engine.connect() as conn:

    result = pd.read_sql(
        "SELECT COUNT(*) AS total_rows "
        "FROM staging.stg_delivered_orders",
        conn
    )

    print(result)

engine.dispose()
