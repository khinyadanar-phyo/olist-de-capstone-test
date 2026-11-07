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
