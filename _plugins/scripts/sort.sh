#!/usr/bin/env bash

edit_file () {

  NUM=$(($1 + 0))

  while IFS=' ' read -ra SORT; do
    S+=("${SORT[0]}")
    O+=("${SORT[1]}")
    R+=("${SORT[2]}")
    T+=("${SORT[3]}")
  done < /tmp/spin.txt

  sed -e 's/$/ '$S'/' -i $1
  
}

FILE=${1##*/} && NAME=${FILE%.*}
[[ "$NAME" == "spin_1" ]] && edit_file $1
