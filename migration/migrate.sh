#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

: "${KSQL_URL:=http://localhost:8088}"
: "${S3_URL:=http://localhost:9000}"
: "${S3_ACCESS_KEY:=minio}"
: "${S3_SECRET_KEY:=minio123}"

mc alias set minio "${S3_URL}" "${S3_ACCESS_KEY}" "${S3_SECRET_KEY}"
mc mb minio/kafka || true
envsubst <migration/ksqldb-schema.sql >tmp/ksqldb-schema.sql
ksql -f tmp/ksqldb-schema.sql "${KSQL_URL}" || true
