#!/usr/bin/env bash
# Structure: Cell Types – Modulo 6
# https://www.hexspin.com/proof-of-confinement/

set_target() {
  
  # Get Structure
  if [[ "$2" == *"github.io"* ]]; then
    [[ -n "$ID" ]] && SPIN=$( expr 6 '*' "$3" )
    IFS=', '; array=($(pinned_repos.rb ${OWNER} | yq eval -P | sed "s/ /, /g"))
  else
    HEADER="Accept: application/vnd.github+json"
    echo ${INPUT_TOKEN} | gh auth login --with-token
    IFS=', '; array=($(gh api -H "${HEADER}" /user/orgs  --jq '.[].login' | sort | yq eval -P | sed "s/ /, /g"))
  fi
  
  # Iterate the Structure
  printf -v array_str -- ',,%q' "${array[@]}"
  if [[ ! "${array_str},," =~ ",,$1,," ]]; then ID=1; echo ${array[0]}
  elif [[ "${array[-1]}" == "$1" ]]; then ID=${#array[@]}; echo $2
  else
    for ((i=0; i < ${#array[@]}; i++)); do
      if [[ "${array[$i]}" == "$1" && "$i" -lt "${#array[@]}-1" ]]; then ID=$(( $i + 1 )); echo ${array[$ID]}; fi
    done
  fi
  
  # Generate id from the Structure
  [[ -z "$SPIN" ]] && SPIN=0
  return $(( $ID + $SPIN ))
}

jekyll_build() {

  echo -e "\n$hr\nCONFIG\n$hr"
  git config --global user.name "${GITHUB_ACTOR}" && git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  git config --global --add safe.directory ${GITHUB_WORKSPACE} && rm -rf .github && mv /maps/.github . && git add .
  git commit -m "update workflow" > /dev/null && git push > /dev/null 2>&1

  rm -Rf -- */ && find /maps/_* -maxdepth 0 \! -name '_plugins' -type d -exec mv {} . \; -prune
  
  sed -i "1s|^|target_repository: $1\n|" ${JEKYLL_CFG}
  sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG}
  sed -i "1s|^|id: $(( $2 + 30 ))\n|" ${JEKYLL_CFG} && cat ${JEKYLL_CFG}

  echo -e "\n$hr\nWORKSPACE\n$hr"
  mv _includes/workdir/* .
  if [[ $1 == *"github.io"* ]]; then mv _assets assets; fi && ls -al .

  echo -e "\n$hr\nBUILD\n$hr"
  # https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  REMOTE_REPO="https://${GITHUB_ACTOR}:${INPUT_TOKEN}@github.com/$1.git"
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --profile -t -c ${JEKYLL_CFG} -p /maps/_plugins/gem
  
  cd ${GITHUB_WORKSPACE}/_site && git init --initial-branch=master > /dev/null && git remote add origin ${REMOTE_REPO}
  if [[ $1 == "eq19/eq19.github.io" ]]; then echo "www.eq19.com" > CNAME; fi && touch .nojekyll && git add .
  git commit -m "jekyll build" > /dev/null && git push --force ${REMOTE_REPO} master:gh-pages

  echo -e "\n$hr\nDEPLOY\n$hr"
  ls -al
}

# https://unix.stackexchange.com/a/615292/158462
[[ ${GITHUB_REPOSITORY} == *"github.io"* ]] && OWNER=$(set_target ${OWNER} ${GITHUB_ACTOR}) || ID=$(set_target ${OWNER} ${OWNER})
echo ID $ID $?
TARGET_REPOSITORY=$(set_target $(basename ${GITHUB_REPOSITORY}) ${OWNER}.github.io 2)
jekyll_build ${OWNER}/${TARGET_REPOSITORY} $?
