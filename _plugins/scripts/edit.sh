#!/usr/bin/env bash

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

edit_file () {
  NUM=$(($2 + 0))
  
  IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
  TEXT="${LINE[$NUM]}" && TITLE=${TEXT%|*}

  cat exponentiation/span18/spin1.txt > /tmp/spin.txt
  [[ $NUM -ge 10 ]] && cat exponentiation/span18/spin2.txt >> /tmp/spin.txt
  [[ $NUM -ge 22 ]] && cat exponentiation/span18/spin3.txt >> /tmp/spin.txt
  [[ $NUM -ge 28 ]] && cat exponentiation/span18/spin4.txt >> /tmp/spin.txt

  while IFS=' ' read -ra SPIN; do
    S+=("${SPIN[0]}")
    P+=("${SPIN[1]}")
    I+=("${SPIN[2]}")
    N+=("${SPIN[3]}")
  done < /tmp/spin.txt

  FRONT="---\n"
  FRONT+="sort: $NUM\n"
  FRONT+="suit: ${S[$NUM]}\n"
  FRONT+="---\n"
  FRONT+="# $TITLE\n\n"

  [[ $NUM -le 9 ]] && sed -i "1s|^|$FRONT|" $1
  if [[ $NUM -lt 2 || $NUM == 9 ]]; then
    mv -f $1 ${1%/*}/README.md
    sed '1,6!d' ${1%/*}/README.md
  fi
}

FILE=${1##*/} && SORT=${FILE%.*}
[[ $SORT =~ ^-?[0-9]+$ ]] && edit_file $1 $SORT
