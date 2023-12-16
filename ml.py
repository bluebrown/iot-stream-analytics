import pandas as pd
from minio import Minio
import io

client = Minio("localhost:9000", "minio", "minio123", secure=False)

objects = client.list_objects("kafka", recursive=True, prefix="topics/device-parameter-windowed/")

files = [o.object_name for o in objects]

if len(files) == 0:
    print("No files found")
    exit(1)

res = client.get_object("kafka", files[len(files)-1])

raw = pd.read_parquet(io.BytesIO(res.read()))

pivot = raw.pivot_table(index=["WSTART", "WEND", "DID"], columns=["PID"], values=["AVG"])

print("----------")
print("[raw data]")
print(raw.head(3))
print()
print("--------------")
print("[pivoted data]")
print(pivot.head(9))
