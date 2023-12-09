#!/usr/bin/env bash

edit_file () {

  NUM=$(($2 + 0))

  while IFS=' ' read -ra SORT; do
    S+=("${SORT[0]}")
    O+=("${SORT[1]}")
    R+=("${SORT[2]}")
    T+=("${SORT[3]}")
  done < /tmp/spin.txt

  FRONT="---\n"
  FRONT+="sort: $NUM\n"
  FRONT+="suit: ${T[$NUM]}\n"
  FRONT+="---\n"
  
  IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md
  TEXT="${LINE[$NUM]}" && TITLE=${TEXT%|*}
  FRONT+="# $TITLE\n\n"

  [[ $NUM -le 9 ]] && sed -i "1s|^|$FRONT|" $1
  if [[ $NUM -lt 2 || $NUM == 9 ]]; then
    mv -f $1 ${1%/*}/README.md
    sed '1,6!d' ${1%/*}/README.md
  fi
}

FILE=${1##*/} && NAME=${FILE%.*}
[[ "$NAME" == "spin_1" ]] && cat $1
