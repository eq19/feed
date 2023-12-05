#!/usr/bin/env bash

echo $1
s=${1##*/} && echo "${1##*/%.*}"
sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

IFS=$'\n' read -d '' -r -a array < _Sidebar.md
echo ${array[2]};
