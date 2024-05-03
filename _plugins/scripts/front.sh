#!/usr/bin/env bash

edit_file () {

  NUM=$(($2 + 0))

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

  FRONT="---\n"
  FRONT+="sort: $NUM\n"
  FRONT+="spin: ${G[$NUM]}\n"
  FRONT+="span: ${N[$NUM]}\n"
  FRONT+="suit: ${I[$NUM]}\n"
  
  IFS=$'\n' read -d '' -r -a LINE < _Sidebar.md; TEXT="${LINE[$NUM]}"; unset IFS;
  IFS=':'; arrIN=($TEXT); unset IFS;
  
  FRONT+="description: ${TEXT##*|}\n"
  #FRONT+="redirect_to: http://www.eq19.com\n"
  FRONT+="---\n# ${TEXT%%|*}\n\n"

  #[[ $NUM -le 19 ]] && sed -i "1s|^|$FRONT|" $1
  if [[ $NUM -lt 2 || $NUM == 18 || $NUM -gt 29 ]]; then
    mv -f $1 ${1%/*}/README.md
    sed '1,8!d' ${1%/*}/README.md
  fi
}

sed -i 's/💎:/sort:/g' $1
sed -i 's/🚀:/spin:/g' $1
sed -i 's/🔨:/span:/g' $1
sed -i 's/📂:/suit:/g' $1

FILE=${1##*/} && SORT=${FILE%.*}
[[ $SORT =~ ^-?[0-9]+$ ]] && edit_file $1 $SORT
