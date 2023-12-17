#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

: "${KAFKA_NETCLI:=kafka:7777}"
: "${KAFKA_BOOTSTRAP_SERVER:=localhost:9092}"
: "${CONNECT_URL:=http://localhost:8083}"
: "${KSQL_URL:=http://localhost:8088}"
: "${MINIO_URL:=http://localhost:9000}"

function add_connector() {
  local json_file="$1"
  curl -fsS -X POST -H "Content-Type: application/json" \
    --data "@$json_file" "$CONNECT_URL/connectors"
}

function create_topic() {
  local topic="$1"
  echo "kafka-topics.sh --create --replication-factor 1 --partitions 1 --topic $topic" |
    socat -t 60 "tcp:$KAFKA_NETCLI" -
}

## MIGRATION STEPS

# 1. pre create kafka topics

create_topic mqtt-example
create_topic device-parameter
create_topic device-parameter-windowed

# # 2. apply ksql schema

ksql -f migration/ksqldb-schema.sql "${KSQL_URL}" || true

# 3. create minio bucket, if it does not exist

mc alias set minio "${MINIO_URL}" minio minio123
mc mb minio/kafka || true

# 4. create conntors, if they dont exist

connectors=$(curl -s "$CONNECT_URL/connectors")

if [[ $connectors != *"mqtt-source"* ]]; then
  add_connector migration/connect-source-mqtt.json
  echo "Created connector mqtt-source"
fi

if [[ $connectors != *"s3-sink"* ]]; then
  add_connector migration/connect-sink-s3.json
  echo "Created connector s3-sink"
fi
