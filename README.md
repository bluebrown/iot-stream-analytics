# IOT Playground

## Quick Start

First start the stack.

```bash
docker compose up -d
```

After some time, there should be data in the [kafka bucket](http://localhost:9001/browser/kafka). You can authenticate with `minio:minio123`.

Once data is available, execute the python script to fetch the data and load it into a data frame.

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
python ml.py
```

Note that the python script will pivot the data.

```python
dataframe.pivot_table(
  index=["WSTART", "WEND", "DID"],
  columns=["PID"],
  values=["AVG"],
)
```

## Useful Commands

### List Kafka Topics

```bash
docker compose exec kafka kafka-topics.sh --bootstrap-server kafka:9092 --list
```

### Consume Kafka Messages

```bash
docker compose exec kafka kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic mqtt-example
```

### Inspect Message Structure

```bash
bin/ksql.sh -e "print 'device-parameter';"
```

### list Consumer Groups

```bash
docker compose exec kafka kafka-consumer-groups.sh --bootstrap-server localhost:9092 --all-groups --describe
```
