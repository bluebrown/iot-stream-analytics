#!/bin/bash

# Synopsis: netcli.sh
#
# This script is intended to be used with socat
# to execute kafka scripts over a network.
#
# server:
#     socat -t 60 TCP4-LISTEN:7777,fork,reuseaddr system:/opt/myorg/bin/netcli.sh &
# client:
#     echo kafka-topics.sh --list | socat -t 60 tcp:localhost:7777 -
#

# receive the message and parse it into
# individual script arguments
# shellcheck disable=SC2046
set - $(cat - | xargs)

# verify that there is at least one argument
if [ $# -lt 1 ]; then
  echo "No arguments received"
  exit 1
fi

script="$(basename "$1")"
shift

# verify that the script exists
if [ ! -f "/opt/kafka/bin/$script" ]; then
  echo "Script not found: $script"
  exit 1
fi

# execute the script
# TODO: the bootstrap server should be configurable
prog=(
  "/opt/kafka/bin/$script" --bootstrap-server localhost:9092 "$@"
)

exec "${prog[@]}"
