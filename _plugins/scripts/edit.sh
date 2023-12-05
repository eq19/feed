#!/usr/bin/env bash

FILE=${1##*/} && SORT=${FILE%.*}

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
IFS=, read -r s p i n < exponentiation/span18/spin.csv
  
TEXT=${LINE[$SORT]} && TITLE=${TEXT%|*}

FRONT="---\n"
FRONT+="sort: $SORT\n"
FRONT+="suit: ${s[$SORT]}\n"
FRONT+="---\n"
FRONT+="# $TITLE\n"
FRONT+="{% include list.liquid all=true %}\n\n"

[[ "$SORT" == "2" ]] && sed -i "1s|^|$FRONT|" $1
