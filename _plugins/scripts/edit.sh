#!/usr/bin/env bash

FILE=${1##*/}
SORT=${FILE%.*}

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

while IFS=' ' read -ra SPIN; do
  S+=("${SPIN[0]}")
  P+=("${SPIN[1]}")
  I+=("${SPIN[2]}")
  N+=("${SPIN[3]}")
done < exponentiation/span18/gist.txt

IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
TEXT=${LINE[$SORT]} && TITLE=${TEXT%|*}

FRONT="---\n"
FRONT+="sort: $SORT\n"
FRONT+="suit: ${S[$SORT]}\n"
FRONT+="---\n"
FRONT+="# $TITLE\n\n"

NUM=$(($SORT + 0))
[[ $NUM =~ ^-?[0-9]+$ && $NUM -le 9 ]] && sed -i "1s|^|$FRONT|" $1

if [[ "$NUM" == "0" || $NUM == 1 || $NUM == 9 ]]; then
  mv -f $1 ${1%/*}/README.md
  sed '1,6!d' ${1%/*}/README.md
fi
