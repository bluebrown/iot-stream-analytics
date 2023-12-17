# IOT Playground

## Quick Start

First start the stack:

```bash
bin/install.sh # download connect plugins
docker compose up -d # boot the system
docker compose logs migration -f # observe the migration
```

After a few minutes, there should be data in the [kafka
bucket](http://localhost:9001/browser/kafka). You can authenticate with
`minio:minio123`.

Once data is available, you can use the [notebook](./notebook.ipynb), to
visualize it.

While you are waiting, you can inspect the system. For example try some of the
below commands.

## Useful Commands

### List Kafka Topics

```bash
docker compose exec kafka kafka-topics.sh \
  --bootstrap-server kafka:9092 --list
```

### Consume Kafka Messages

```bash
docker compose exec kafka kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 --topic mqtt
```

### Inspect Message Structure

```bash
bin/ksql.sh -e "print 'device-parameter';"
```

### list Consumer Groups

```bash
docker compose exec kafka kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 --all-groups --describe
```
