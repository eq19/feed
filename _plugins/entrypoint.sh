#!/usr/bin/env bash
# Structure: Cell Types – Modulo 6
# https://www.hexspin.com/cell-types/

jekyll_build() {
  
  rm -rf  nodes.* && rm -Rf -- */ && mv /maps/text/_* .
  if [[ $1 == *"github.io"* ]]; then mv /maps/_assets assets; fi
  JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml && mv /maps/_config.yml ${JEKYLL_CFG}

  sed -i "1s|^|target_repository: $1\n|" ${JEKYLL_CFG}
  sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG} && cat ${JEKYLL_CFG}

  # https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --trace --profile ${INPUT_JEKYLL_BASEURL:=} -c ${JEKYLL_CFG}

  git config --global user.name "${GITHUB_ACTOR}" && git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  REMOTE_REPO="https://${GITHUB_ACTOR}:${INPUT_TOKEN}@github.com/$1.git" && echo -e "Deploying to $1 on branch gh-pages"
  git clone -b gh-pages --single-branch ${REMOTE_REPO} &>/dev/null && cd $(basename $1) && rm -rf *
  mv -v ${GITHUB_WORKSPACE}/_site/* . && touch .nojekyll && git add .
  git commit -m "jekyll build" && git push -u origin gh-pages
}

set_target() {
  
  # Get pinned repos.
  IFS=', '; array=($(pinned_repos.rb $1 | yq eval -P | sed "s/ /, /g"))
  
  # Iterate the pinned repos
  printf -v array_str -- ',,%q' "${array[@]}"
  if [[ ! "${array_str},," =~ ",,$1,," ]]; then TARGET_REPOSITORY=${OWNER}/${array[0]}
  elif [[ "${array[-1]}" == "$1" ]]; then TARGET_REPOSITORY=${OWNER}/${OWNER}.github.io
  else
    for i in 0 1 2 3 4 5; do
      [[ "${array[$i]}" == "$1" && "$i" -lt 5 ]] && TARGET_REPOSITORY=${OWNER}/${array[$i+1]}
    done
  fi
}

set_owner() {

  # Get organization list
  HEADER="Accept: application/vnd.github+json"
  echo ${INPUT_TOKEN} | gh auth login --with-token
  IFS=', '; array=($(gh api -H "${HEADER}" /user/orgs  --jq '.[].login' | sort | yq eval -P | sed "s/ /, /g"))
  
  # Iterate the organization list
  printf -v array_str -- ',,%q' "${array[@]}"
  if [[ ! "${array_str},," =~ ",,$1,," ]]; then OWNER=${array[0]}
  elif [[ "${array[-1]}" == "$1" ]]; then OWNER=${GITHUB_ACTOR}
  else
    for ((i=0; i < ${#array[@]}; i++)); do
      [[ "${array[$i]}" == "$1" && "$i" -lt ${#array[@]}-1  ]] && OWNER=${array[$i+1]}
    done
  fi
}


[[ ${GITHUB_REPOSITORY} != *"github.io"* ]]  && OWNER=${GITHUB_REPOSITORY_OWNER} || set_owner ${GITHUB_REPOSITORY_OWNER}
echo -e "\n$hr\nSET REPOSITORY\n$hr" && set_target "$(basename ${GITHUB_REPOSITORY})"
echo -e "\n$hr\nDEPLOY\n$hr" && jekyll_build "${TARGET_REPOSITORY}"
