#!/usr/bin/env bash

FILE=$1

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

PATH=${FILE##*/} && SORT=${PATH%.*}
IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
TITLE=${LINE[2]} && echo "${TITLE%|*}"

if [[ "$SORT" == "2" ]]; then
  sed -i "1s|^|---\nsort: $SORT\n---\n|" $FILE
fi
