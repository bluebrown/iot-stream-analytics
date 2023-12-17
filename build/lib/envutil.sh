#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

# 1. find all env variable start with prefix
# 2. remove the prefix from the key
# 3. lowercase the key
# 4. replace delimiter with join
# 5. join key and value with assign
function config_from_env() {
  local prefix="${1:-KAFKA}"
  local delimiter="_"
  local join="."
  local assign="="
  env | grep -E "^${prefix}${delimiter}" | while read -r line; do
    key=${line%%"$assign"*}
    value=${line#*"$assign"}
    key=${key#"$prefix""$delimiter"}
    key=${key//$delimiter/$join}
    key=${key,,}
    echo "$key$assign$value"
  done

}

export -f config_from_env

# the inverse of config_from_env
function config_to_env() {
  local prefix="${1:-KAFKA}"
  local delimiter="_"
  local join="."
  local assign="="
  while read -r line; do
    # skip lines that do not start with a key
    if ! [[ "$line" =~ ^[a-zA-Z0-9_]+ ]]; then
      continue
    fi
    key=${line%%"$assign"*}
    value=${line#*"$assign"}
    key=${key//$join/$delimiter}
    key=${key^^}
    key="$prefix$delimiter$key"
    # export this only if the environment variable is not set
    # this allows us to override the default values
    if test -z "${!key:-}"; then
      export "$key=$value"
    fi
  done
}

export -f config_to_env
