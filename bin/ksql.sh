#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

exec docker run --rm -ti -w /workspace \
  --network iot-stream-analytics_default -v "$PWD:/workspace" \
  docker.io/confluentinc/ksqldb-cli:0.29.0 ksql "$@" -- http://ksqldb:8088
