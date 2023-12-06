#!/usr/bin/env bash

FILE=${1##*/}
SORT=${FILE%.*}
NUM=$(($SORT + 0))

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

cat exponentiation/span18/spin1.txt > /tmp/spin.txt
cat exponentiation/span18/spin2.txt >> /tmp/spin.txt

while IFS=' ' read -ra SPIN; do
  S+=("${SPIN[0]}")
  P+=("${SPIN[1]}")
  I+=("${SPIN[2]}")
  N+=("${SPIN[3]}")
done < /tmp/spin.txt

IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
TEXT=${LINE[$SORT]} && TITLE=${TEXT%|*}

FRONT="---\n"
FRONT+="sort: $SORT\n"
FRONT+="suit: ${S[$SORT]}\n"
FRONT+="---\n"
FRONT+="# $TITLE\n\n"

[[ $SORT =~ ^-?[0-9]+$ && $NUM -le 9 ]] && sed -i "1s|^|$FRONT|" $1

if [[ "$SORT" == "0" || "$SORT" == "1" || "$SORT" == "9" ]]; then
  mv -f $1 ${1%/*}/README.md
  sed '1,6!d' ${1%/*}/README.md
fi
