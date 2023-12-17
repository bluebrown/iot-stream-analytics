#!/usr/bin/env bash
set -o nounset -o errexit -o errtrace -o pipefail

function url() {
  local plugin="$1"
  local version="$2"
  echo "https://d1i4a15mxbxib1.cloudfront.net/api/plugins/confluentinc/$plugin/versions/$version/confluentinc-$plugin-$version.zip"
}

depsfile="connect-lock.txt"
target=vendor

mkdir -p "$target"

while read -r dep; do
  # skip empty lines and comments
  [[ -z "$dep" || "$dep" =~ ^#.*$ ]] && continue

  # determine the plugin and version
  plugin="${dep%%:*}"
  version="${dep##*:}"

  # check if the plugin is already installed
  # it has the pattern confluentinc-$plugin-$version
  if [ -d "$target/confluentinc-$plugin-$version" ]; then
    echo "Plugin $plugin $version already installed"
    continue
  fi

  # if its not installed, download and install it
  url="$(url "$plugin" "$version")"
  echo "Downloading $plugin $version from $url"
  curl -fsS "$url" -o "$plugin.zip"
  unzip -q "$plugin.zip" -d "$target"
  rm "$plugin.zip"

done <"$depsfile"
