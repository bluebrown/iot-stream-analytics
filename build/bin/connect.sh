#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail
source /opt/myorg/lib/envutil.sh
config=/opt/kafka/config/connect-distributed.properties
config_to_env "CONNECT" <"$config"
config_from_env "CONNECT" >"$config"
exec connect-distributed.sh "$config"
