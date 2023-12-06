#!/usr/bin/env bash

LINE=$1
FILE=${2##*/}
SORT=${FILE%.*}
NUM=$(($SORT + 0))
TEXT="${LINE[$SORT]}" && TITLE=${TEXT%|*}

sed -i 's/💎:/sort:/g' $2
sed -i 's/🚀:/spin:/g' $2
sed -i 's/🔨:/span:/g' $2
sed -i 's/📂:/suit:/g' $2

cat exponentiation/span18/spin1.txt > /tmp/spin.txt

if [[ $SORT =~ ^-?[0-9]+$ ]]; then
  [[ $NUM -ge 10 ]] && cat exponentiation/span18/spin2.txt >> /tmp/spin.txt
  [[ $NUM -ge 22 ]] && cat exponentiation/span18/spin3.txt >> /tmp/spin.txt
  [[ $NUM -ge 28 ]] && cat exponentiation/span18/spin4.txt >> /tmp/spin.txt
fi

while IFS=' ' read -ra SPIN; do
  S+=("${SPIN[0]}")
  P+=("${SPIN[1]}")
  I+=("${SPIN[2]}")
  N+=("${SPIN[3]}")
done < /tmp/spin.txt

FRONT="---\n"
FRONT+="sort: $SORT\n"
FRONT+="suit: ${S[$SORT]}\n"
FRONT+="---\n"
FRONT+="# $TITLE\n\n"

[[ $SORT =~ ^-?[0-9]+$ && $NUM -le 9 ]] && sed -i "1s|^|$FRONT|" $2
if [[ "$SORT" == "0" || "$SORT" == "1" || "$SORT" == "9" ]]; then
  mv -f $2 ${2%/*}/README.md
  sed '1,6!d' ${2%/*}/README.md
fi
