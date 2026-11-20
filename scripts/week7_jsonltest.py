#JSONL (JSON Lines) is one complete JSON object per line, with no surrounding [ ] and no commas between lines
import json
from pathlib import Path

orders = []
file_path = Path(__file__).parent / "week7test.jsonl"

with open(file_path, "r", encoding="utf-8") as f:
   # orders = json.load(f)

    for line in f:
          line = line.strip()
          if not line:
              continue
          orders.append(json.loads(line))

print(orders[0]["order_id"])
for order in orders:
      print(order["order_id"], order["status"])