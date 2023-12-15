#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

config=/opt/kafka/config/kraft/server.properties

source /envutil.sh

config_to_env KAFKA <"$config"
config_from_env KAFKA >"$config"

if test -z "${KAFKA_CLUSTER_ID:-}"; then
  KAFKA_CLUSTER_ID=$(kafka-storage.sh random-uuid)
  echo "Generated cluster ID ${KAFKA_CLUSTER_ID}"
else
  echo "Using cluster ID ${KAFKA_CLUSTER_ID}"
fi

export KAFKA_CLUSTER_ID

kafka-storage.sh format -t "${KAFKA_CLUSTER_ID}" -c "$config" --ignore-formatted

exec kafka-server-start.sh "$config"
