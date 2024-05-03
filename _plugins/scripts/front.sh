#!/usr/bin/env bash

edit_file () {

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
      #FRONT+="redirect_to: http://www.eq19.com\n"
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
