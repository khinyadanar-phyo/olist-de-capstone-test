import os, time  # os gets file information, and time measures how long things take.
from pathlib import Path

import pandas as pd  # reads and writes tables of data.
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent   # scripts/ -> project root
load_dotenv(BASE_DIR / ".env")                      # read .env into environment variables

data_dir = os.getenv("DATA_DIR")
output_dir = os.getenv("OUTPUT_DIR")
if not data_dir or not output_dir:
    raise RuntimeError("DATA_DIR and OUTPUT_DIR must be set in the .env file in the project root.")

DATA_DIR = BASE_DIR / data_dir
OUT_DIR = BASE_DIR / output_dir / "compression_test"
OUT_DIR.mkdir(parents=True, exist_ok=True)          # create the output folder if it doesn't exist

mb = lambda p: round(os.path.getsize(p) / 1e6, 1)  # file size in MB, rounded to 1 decimal

csv = DATA_DIR / "olist_geolocation_dataset.csv"
df = pd.read_csv(csv)

gz = OUT_DIR / "geo.csv.gz"
df.to_csv(gz, index=False)  # save as compressed CSV (.gz means gzip)
print("csv", mb(csv), "MB | csv.gz", mb(gz), "MB")

for codec in [None, "snappy", "zstd", "gzip"]:  # loop over compression codecs
    path = OUT_DIR / f"geo_{codec}.parquet"      # each codec gets its own file

    write_start = time.time()
    df.to_parquet(path, compression=codec, index=False)  # time the write
    w = round(time.time() - write_start, 2)              # seconds spent writing

    read_start = time.time()
    pd.read_parquet(path)                                # time the read
    r = round(time.time() - read_start, 2)

    print(codec, mb(path), "MB | write", w, "s | read", r, "s")