#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

source /envutil.sh

connect=/opt/kafka/config/connect-standalone.properties
config_to_env "CONNECT" <"$connect"
config_from_env "CONNECT" >"$connect"

connector=/opt/kafka/config/connector.properties
config_to_env "CONNECTOR" <"$connector"
config_from_env "CONNECTOR" >"$connector"

echo "connect config"
cat "$connect"

echo "connector config"
cat "$connector"

# TODO: should run in distributed mode
exec connect-standalone.sh "$connect" "$connector"
