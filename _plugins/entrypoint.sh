#!/usr/bin/env bash
# Structure: Cell Types – Modulo 6
# https://www.hexspin.com/proof-of-confinement/

set_target() {
  
  # Get Structure
  if [[ "$2" == *"github.io"* ]]; then
    [[ -n "$ID" ]] && SPIN=$( echo $ID | sed 's/.* //')
    IFS=', '; array=($(pinned_repos.rb ${OWNER} | yq eval -P | sed "s/ /, /g"))
  else
    export HEADER="Accept: application/vnd.github+json"
    echo ${INPUT_TOKEN} | gh auth login --with-token && gist.sh &>/dev/null
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

  echo -e "\n$hr\nWORKSPACE\n$hr"
  cd /maps && mv -f /tmp/workdir/* .
  NR=$(cat /tmp/gist_files | awk "NR==$(( $3 + 1 ))")
  [[ $1 != "eq19.github.io" ]] && wget -O /maps/README.md ${NR} &>/dev/null
  rm -rf .git && find . -type d -name .git -prune -exec rm -rf {} \; && git init
  if [[ $1 == *"github.io"* ]]; then OWNER=$2; mv /maps/_assets /maps/assets; fi && ls -al /maps

  echo -e "\n$hr\nCONFIG\n$hr"
  sed -i "1s|^|repository: ${OWNER}/$1\n|" /maps/_config.yml
  [[ $1 != *"github.io"* ]] && sed -i "1s|^|basedir: /$1\n|" /maps/_config.yml
  sed -i "1s|^|id: $(( $3 + 30 ))\n|" /maps/_config.yml && cat /maps/_config.yml

  echo -e "\n$hr\nBUILD\n$hr"
  find . -type f -name "*.md" -exec sed -i 's/💎:/sort:/g' {} +
  # Jekyll Quick Reference (Cheat Sheet) https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --profile -t -s /maps -p /maps/_plugins/gems
  
  echo -e "\n$hr\nDEPLOY\n$hr"
  cd _site && touch .nojekyll && mv /maps/README.md .
  if [[ $1 == "eq19.github.io" ]]; then echo "www.eq19.com" > CNAME; fi && ls -al . && echo -e "\n"

  REMOTE_REPO="https://${USER}:${INPUT_TOKEN}@github.com/${OWNER}/$1.git"
  git init --initial-branch=master > /dev/null && git remote add origin ${REMOTE_REPO}
  git add . && git commit -m "jekyll build" > /dev/null && git push --force ${REMOTE_REPO} master:gh-pages
}

# Set repository with the update workflow 
git config --global user.name "${USER}" && git config --global user.email "${USER}@users.noreply.github.com"
git config --global --add safe.directory ${GITHUB_WORKSPACE} && rm -rf .github && mv /maps/.github . && git add .
git commit -m "update workflow" > /dev/null && git push > /dev/null 2>&1

# Capture the string and the return status https://unix.stackexchange.com/a/615292/158462
if [[ ${REPO} != *"github.io"* ]]; then ENTRY=$(set_target ${OWNER} ${USER}); else ID=$(set_target ${OWNER} ${ID}); fi
TARGET_REPOSITORY=$(set_target $(basename ${REPO}) ${OWNER}.github.io)
jekyll_build ${TARGET_REPOSITORY} ${ENTRY} $?
