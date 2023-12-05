#!/usr/bin/env bash

echo $1

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

PATH=${1##*/} && SORT=${PATH%.*}
IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
TITLE=${LINE[2]} && echo "${TITLE%|*}"

FRONT="---\n"
FRONT+="sort: SORT\n"
FRONT+="---\n"

[[ "$SORT" == "2" ]] && sed -i "1s|^|$FRONT|" $1
