#Array list in python/access by position: x[0] 
#Object │ {"a": 1}   │ dict   │ key: x["a"]  
import json
from pathlib import Path

file_path = Path(__file__).parent / "week7test.json"

with open(file_path, "r", encoding="utf-8") as f:
    orders = json.load(f)

print(orders[1]["order_id"])
print(orders[1]["items"][0]["price"])

for o in orders:
      total = sum(item["price"] for item in o["items"])
      print(o["order_id"], o["status"], total)