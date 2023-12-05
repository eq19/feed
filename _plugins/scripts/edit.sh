#!/usr/bin/env bash

FILE=${1##*/} && SORT=${FILE%.*}

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
TEXT=${LINE[$SORT]} && TITLE=${TEXT%|*}

while IFS=',' read -ra SPIN; do
  S+=("${SPIN[0]}")
  P+=("${SPIN[1]}")
  I+=("${SPIN[2]}")
  N+=("${SPIN[3]}")
done < exponentiation/span18/spin.csv

FRONT="---\n"
FRONT+="sort: $SORT\n"
FRONT+="suit: ${S[$SORT]}\n"
FRONT+="---\n"
FRONT+="# $TITLE\n"
FRONT+="{% include list.liquid all=true %}\n\n"

[[ "$SORT" == "2" ]] && sed -i "1s|^|$FRONT|" $1
