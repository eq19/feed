#!/usr/bin/env bash

edit_file () {
  
  FILE=${1##*/} && SORT=${FILE%.*}
  if [[ $SORT =~ ^-?[0-9]+$ ]]; then
    
    NUM=$(($SORT + 0))
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
        FRONT+="---\n# ${TEXT%%|*}\n\n"
        sed -i "1s|^|$FRONT|" $1
      fi
    done
  
    if [[ $NUM -lt 2 || $NUM == 18 || $NUM -gt 29 ]]; then
      mv -f $1 ${1%/*}/README.md
      #sed '1,8!d' ${1%/*}/README.md
    fi
  fi
}

rm -rf /tmp/spin.txt && touch /tmp/spin.txt
find . -type f -name 'spin_*.txt' | sort -n -t _ -k 2  | while ((i++)); IFS= read -r f; do sort.sh $f $i; done

cat /tmp/spin.txt
sed -i 's/0. \[\[//g' _Sidebar.md && sed -i 's/\]\]//g' _Sidebar.md
find . -iname '*.md' -print0 | sort -zn | xargs -0 -I '{}' edit_file '{}'
