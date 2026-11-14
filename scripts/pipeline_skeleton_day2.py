import logging, sys

logging.basicConfig(level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[logging.FileHandler("etl.log"), logging.StreamHandler()])
log = logging.getLogger(__name__)

def extract():   log.info("extract"); return [1, 2, 3]
def transform(d): log.info("transform"); return [x * 10 for x in d]
def load(d):     log.info(f"load {len(d)} rows")

def main():
    try:
        load(transform(extract()))
    except Exception:
        log.exception("ETL failed"); sys.exit(1)

if __name__ == "__main__":
    main() 

# Testing the Db connection 
# import os
# from dotenv import load_dotenv

# load_dotenv()        # read .env into environment variables

# DB_USER = os.getenv("DB_USER", "postgres")
# DB_PASSWORD = os.getenv("DB_PASSWORD")   # None if missing
# #confirm yet that your .env variables were loaded correctly.
# print("DB_USER:", DB_USER)
# print("DB_PASSWORD loaded:", DB_PASSWORD is not None)