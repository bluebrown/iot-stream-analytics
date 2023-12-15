# IOT Playground

## Quick Start

```bash
# start the stack
docker compose up -d

# connect to ksqldb
bin/ksqldb.sh
```

## Useful Commands

### List Kafka Topics

```bash
docker compose exec kafka kafka-topics.sh --bootstrap-server kafka:9092 --list
```

### Consume Kafka Messages

```bash
docker compose exec kafka kcat -b kafka:9092 -t mqtt-example
```

### Inspect Message Structure

```bash
bin/ksql.sh -e "print 'device-parameter';"
```

### list Consumer Groups

```bash
docker compose exec kafka kafka-consumer-groups.sh --bootstrap-server localhost:9092 --all-groups --describe
```
