#!/usr/bin/env bash

echo $1
FILE=${1##*/} && SORT=${FILE%.*}

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
TITLE=${LINE[$SORT]} && echo "${TITLE%|*}"

FRONT="---\n"
FRONT+="sort: SORT\n"
FRONT+="---\n"

[[ "$SORT" == "2" ]] && sed -i "1s|^|$FRONT|" $1
