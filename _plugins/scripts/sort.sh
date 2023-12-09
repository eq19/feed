#!/usr/bin/env bash

edit_file () {

  while ((i++)); IFS=' ' read -ra SORT; do

    SPIN="${i}"
   
    S+=("${SORT[0]}") && SPIN+=" ${SORT[0]}"
    O+=("${SORT[1]}") && SPIN+=" ${SORT[1]}"
    R+=("${SORT[2]}") && SPIN+=" ${SORT[2]}"
    T+=("${SORT[3]}") && SPIN+=" ${SORT[3]}"
    
    echo "${SPIN} ${SORT[0]}" >> /tmp/spin.txt

  done < $1

  cat /tmp/spin.txt
  
}

FILE=${1##*_} && NAME=${FILE%.*}
[[ $(($NAME + 0)) == 1 ]] && edit_file $1
