#!/usr/bin/env bash
set -Eeuo pipefail

echo -e "\033[0m\033[33m正在生成 $1 对应版本 Dockerfile 文件……\033[37m"

versions="$(jq --raw-output 'keys | join(" ")' "$1"_versions.json)"

for version in $versions; do
  export version

  variants="$(jq --raw-output '.[env.version].variants | join(" ")' "$1"_versions.json)"

  for dir in $variants; do

    path="$(dirname $BASH_SOURCE)/$version/$dir"

    mkdir -p $path

    case "$dir" in
    *"alpine"*)
      tmp="$(echo ${dir%%/*} | cut -b 7-)"
      from="alpine:"$tmp;;
    *"buster"*) from="debian:buster-slim" ;;
    *) from="*" ;;
    esac
    export from

    awk -f $(dirname $BASH_SOURCE)/template.awk -v TYPE="$1" Docker-"$1"-linux.template >$path/Dockerfile
  done

  echo -e "\033[0m\033[7m\033[32m生成 $1 $version 版本 Dockerfile 完成\033[37m"

  unset version

done
