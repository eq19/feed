#!/usr/bin/env bash
# Structure: Cell Types – Modulo 6
# https://www.hexspin.com/proof-of-confinement/

set_target() {
  
  # Get Structure
  if [[ "$2" == *"github.io"* ]]; then
    [[ -n "$ID" ]] && SPIN=$( echo $ID | sed 's/.* //')
    IFS=', '; array=($(pinned_repos.rb ${OWNER} | yq eval -P | sed "s/ /, /g"))
  else
    HEADER="Accept: application/vnd.github+json"
    echo ${INPUT_TOKEN} | gh auth login --with-token
    PATTERN="sort_by(.created_at)|.[] | select(.public==true).files.[].raw_url"
    gh api -H "${HEADER}" /users/eq19/gists --jq "${PATTERN}" > /tmp/gist_files
    gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /maps/_includes/workdir/main &>/dev/null
    gh gist clone 5b26b3cd8dc42d94ef240496ad56a54f /maps/_includes/workdir/test &>/dev/null
    IFS=', '; array=($(gh api -H "${HEADER}" /user/orgs  --jq '.[].login' | sort -uf | yq eval -P | sed "s/ /, /g"))
  fi
  
  # Iterate the Structure
  printf -v array_str -- ',,%q' "${array[@]}"
  if [[ ! "${array_str},," =~ ",,$1,," ]]; then SPAN=0; echo ${array[0]}
  elif [[ "${array[-1]}" == "$1" ]]; then SPAN=${#array[@]}; echo $2 | sed "s|${OWNER}.github.io|${ENTRY}.github.io|g"
  else
    for ((i=0; i < ${#array[@]}; i++)); do
      if [[ "${array[$i]}" == "$1" && "$i" -lt "${#array[@]}-1" ]]; then SPAN=$(( $i + 1 )); echo ${array[$SPAN]}; fi
    done
  fi
  
  # Generate id from the Structure
  [[ -z "$SPIN" ]] && if [[ "$1" != "$2" ]]; then SPIN=0; else SPIN=7; fi || SPIN=$(( 6*SPIN+SPIN ))
  [[ -z "$2" ]] && echo $(( $SPAN )) || return $(( $SPAN + $SPIN ))
}

jekyll_build() {

  git config --global user.name "${GITHUB_ACTOR}" && git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  git config --global --add safe.directory ${GITHUB_WORKSPACE} && rm -rf .github && mv /maps/.github . && git add .
  git commit -m "update workflow" > /dev/null && git push > /dev/null 2>&1

  echo -e "\n$hr\nWORKSPACE\n$hr"
  cd /maps && mv _includes/workdir/* .
  if [[ $1 == *"github.io"* ]]; then OWNER=$2; mv _assets assets; fi
  NR=$3 && [[ $1 == "eq19.github.io" ]] && NR=$( tail -n 1 /tmp/gist_files ) || NR=$(cat /tmp/gist_files | awk "NR==$(( NR+1 ))")

  wget -O README.md ${NR} &>/dev/null && ls -al .
  find . -type f -name "*.md" -exec sed -i 's/💎:/sort:/g' {} +

  echo -e "\n$hr\nCONFIG\n$hr"
  sed -i "1s|^|target_repository: ${OWNER}/$1\n|" _config.yml
  sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" _config.yml
  sed -i "1s|^|ID: $(( $3 + 30 ))\n|" _config.yml && cat _config.yml

  echo -e "\n$hr\nBUILD\n$hr"
  # https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  REMOTE_REPO="https://${GITHUB_ACTOR}:${INPUT_TOKEN}@github.com/${OWNER}/$1.git"
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --profile -t -p _plugins/gems
  
  cd _site && touch .nojekyll && mv /maps/README.md .
  [[ $1 == "eq19.github.io" ]] && echo "www.eq19.com" > CNAME
  git init --initial-branch=master > /dev/null && git remote add origin ${REMOTE_REPO}
  git add . && git commit -m "jekyll build" > /dev/null && git push --force ${REMOTE_REPO} master:gh-pages

  echo -e "\n$hr\nDEPLOY\n$hr"
  ls -al
}

# https://unix.stackexchange.com/a/615292/158462
[[ ${GITHUB_REPOSITORY} != *"github.io"* ]] && ENTRY=$(set_target ${OWNER} ${GITHUB_ACTOR}) || ID=$(set_target ${OWNER} ${ID})
TARGET_REPOSITORY=$(set_target $(basename ${GITHUB_REPOSITORY}) ${OWNER}.github.io)
jekyll_build ${TARGET_REPOSITORY} ${ENTRY} $?