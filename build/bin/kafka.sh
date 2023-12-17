#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

# use the kraft config
config=/opt/kafka/config/kraft/server.properties

# set the kafka config from the environment
# preserving existing config
source /opt/myorg/lib/envutil.sh
config_to_env KAFKA <"$config"
config_from_env KAFKA >"$config"

# kraft needs a cluster id, so generate one if not set
if test -z "${KAFKA_CLUSTER_ID:-}"; then
  KAFKA_CLUSTER_ID=$(kafka-storage.sh random-uuid)
  echo "Generated cluster ID ${KAFKA_CLUSTER_ID}"
else
  echo "Using cluster ID ${KAFKA_CLUSTER_ID}"
fi

export KAFKA_CLUSTER_ID

# format the storage if not already formatted
kafka-storage.sh format -t "${KAFKA_CLUSTER_ID}" -c "$config" --ignore-formatted

# start the netcli server, allowing to execute kafka scripts over a network.
# WARNING: This is only intended for development and testing.
socat -t 60 TCP4-LISTEN:7777,fork,reuseaddr system:/opt/myorg/bin/netcli.sh &

# start the kafka server in the foreground
exec kafka-server-start.sh "$config"
