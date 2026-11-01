
from datetime import datetime


print("A")          # 1. runs        -> A

def extract():
    print("B")      # 2. skipped: only defined

print("C")          # 3. runs        -> C

extract()           # 4. called now  -> B

print("----------------------------")
a = [1, 2]
b = a            # same object, two names
b.append(3)
print(a)         # [1, 2, 3]

c = a.copy()     # a new object
c.append(4)
print(a)         # [1, 2, 3]  unchanged
print(c)
print("----------------------------")

s = "Delivered"
s.lower()          # returns "delivered" ... and it is lost
s = s.lower()      # keep it: assign the result

t = (1, 2)
#t[0] = 9           # TypeError: tuple does not support item assignment

print("........................................")

x = [1, 2]
y = [1, 2]
x == y        # True   same value
x is y        # False  different objects

value = None
if value is None:      # the standard way
    value = 0.05
print(value)           # 0.05

print("...................................")

# from datetime import datetime

def calc_delivery_days(purchase, delivered):
    """Return days between purchase and delivery."""
    days = (delivered - purchase).days
    return days

start = datetime(2018, 1, 1)
end = datetime(2018, 1, 8)
result = calc_delivery_days(start, end)
print(result)   # 7



