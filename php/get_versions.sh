#!/usr/bin/env bash
set -Eeuo pipefail

echo -e "\033[0m\033[33m正在生成 $1 版本 json 文件……\033[37m"

# https://www.php.net/gpg-keys.php
declare -A gpgKeys=(
  [8.1]='528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 39B641343D8C104B2B146DC3F9C39DC0B9698544 F1F692238FBC1666E5A5CCD4199F9DFEF6FFBAFD'
  [7.4]='42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312'
)

# $@：所有参数列表。如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。
# ${#versions[@]}：获取数组的长度
# ${!filetypes[@]}: 获取关联数组的所有键名
# -eq：判断是否相等
# <：命令默认从键盘获得的输入，改成从文件，或者其它打开文件以及设备输入
# >：将一条命令执行结果，重定向其它输出设备（覆盖原有内容）
# >>：将一条命令执行结果，重定向其它输出设备（追加内容）

apiUrl="https://www.php.net/releases/index.php?json&version="

versions=${!gpgKeys[@]}

json='{}'

variants='[]'
# order here controls the order of the library/ file
for suite in buster alpine3.15; do
  for variant in fpm; do
    export suite variant
    variants="$(jq <<<"$variants" --compact-output '. + [ env.suite + "/" + env.variant ]')"
  done
done

for version in $versions; do
  # 字符串转数组，借助 IFS 来处理分隔符
  # @sh：输入经过转义，适合在 POSIX shell 的命令行中使用。如果输入是数组，则输出将是一系列以空格分隔的字符串。
  IFS=$'\n'
  possibles=($(curl -fsSL $apiUrl$version | jq --compact-output --raw-output '[.version,(.source[] | select(.filename | endswith("xz")) | "https://www.php.net/distributions/"+.filename,"https://www.php.net/distributions/"+.filename+".asc",.sha256)] | @sh'))
  unset IFS

  eval "possi=( ${possibles[0]} )"

  fullVersion="${possi[0]}"
  url="${possi[1]}"
  ascUrl="${possi[2]}"
  sha256="${possi[3]}"

  gpgKey="${gpgKeys[$version]}"

  export version fullVersion url ascUrl sha256 gpgKey

  json="$(jq <<<"$json" --compact-output --argjson variants "$variants" '.[env.version]={version:env.fullVersion,url:env.url,ascUrl:env.ascUrl,sha256:env.sha256,gpgKeys:env.gpgKey,variants:$variants}')"
  # 相当于以下写法
  # json="$(echo $json | jq -c '.[env.version]={version:env.fullVersion,url:env.url,ascUrl:env.ascUrl,sha256:env.sha256,gpgKeys:env.gpgKey,}')"
done

jq <<<"$json" --sort-keys . >"$1"_versions.json

echo -e "\033[0m\033[7m\033[32m生成 $1 版本 json 文件成功\033[37m"

source $(dirname $BASH_SOURCE)/apply_templates.sh