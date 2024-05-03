#!/usr/bin/env bash

edit_file () {

  ID=$(($2 + 0))
  NUM=$(($3 + 0))

  while IFS=' ' read -ra SPIN; do
    T+=("${SPIN[0]}")
    R+=("${SPIN[1]}")
    A+=("${SPIN[2]}")
    C+=("${SPIN[3]}")
    K+=("${SPIN[4]}")
    I+=("${SPIN[5]}")
    N+=("${SPIN[6]}")
    G+=("${SPIN[7]}")
  done < /tmp/spin.txt

  IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md; unset IFS;
  for ((i=0; i < ${#LINE[@]}; i++)); do
    TEXT="${LINE[$i]}";
    IFS='|'; array=($TEXT); unset IFS;
    if [[ "${array[1]}" == "${NUM}" ]]; then
      FRONT="---\n"
      FRONT+="sort: $i\n"
      FRONT+="spin: $NUM\n"
      FRONT+="span: ${N[$NUM]}\n"
      FRONT+="suit: ${I[$NUM]}\n"  
      FRONT+="description: ${TEXT##*|}\n"
      if [[ $NUM == 31 && $ID != $NUM ]]; then FRONT+="redirect_to: https://www.eq19.com/maps/exponentiation/span17/\n"; fi
      if [[ $NUM == 32 && $ID != $NUM ]]; then FRONT+="redirect_to: https://www.eq19.com/feed/exponentiation/span16/\n"; fi
      if [[ $NUM == 33 && $ID != $NUM ]]; then FRONT+="redirect_to: https://www.eq19.com/lexer/exponentiation/span15/\n"; fi
      if [[ $NUM == 34 && $ID != $NUM ]]; then FRONT+="redirect_to: https://www.eq19.com/parser/exponentiation/span14/\n"; fi
      if [[ $NUM == 35 && $ID != $NUM ]]; then FRONT+="redirect_to: https://www.eq19.com/syntax/exponentiation/span13/\n"; fi
      if [[ $NUM == 37 && $ID != $NUM ]]; then FRONT+="redirect_to: https://www.eq19.com/grammar/exponentiation/span12/\n"; fi
      FRONT+="---\n# ${TEXT%%|*}\n\n"
      sed -i "1s|^|$FRONT|" $1
    fi
  done
  
  if [[ $NUM -lt 2 || $NUM == 18 || $NUM -gt 29 ]]; then
    mv -f $1 ${1%/*}/README.md
    #sed '1,8!d' ${1%/*}/README.md
  fi
}

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

FILE=${1##*/} && SORT=${FILE%.*}
[[ $SORT =~ ^-?[0-9]+$ ]] && edit_file $1 $2 $SORT
