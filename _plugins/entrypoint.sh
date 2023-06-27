#!/usr/bin/env bash

OWNER=${GITHUB_REPOSITORY_OWNER}
JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml
TARGET_REPOSITORY=${OWNER}/${OWNER}.github.io

deploy_remote() {
  echo -e "Deploying to $1 on branch gh-pages"
  REMOTE_REPO="https://${GITHUB_ACTOR}:${INPUT_TOKEN}@github.com/$1.git"

  git config --global user.name "${GITHUB_ACTOR}" && git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  git clone -b gh-pages --single-branch ${REMOTE_REPO} &>/dev/null && cd $(basename $1) && rm -rf *
  mv -v ${GITHUB_WORKSPACE}/_site/* . && touch .nojekyll && git add .
  git commit -m "jekyll build" && git push -u origin gh-pages
}

jekyll_build() {

  # Structure: Cell Types – Modulo 6
  # https://www.hexspin.com/cell-types/

  IFS=', '; array=($(pinned_repos.rb $1 | yq eval -P | sed "s/ /, /g"))
  if [ -z "${GITHUB_REPOSITORY##*github.io*}" ]; then TARGET_REPOSITORY=$1/${array[0]}
  else
    for i in 0 1 2 3 4 5; do
      [[ -z "${GITHUB_REPOSITORY##*${array[$i]}*}" && "$i" -lt 5 ]] && TARGET_REPOSITORY=$1/${array[$i+1]}
    done
  fi

  find . ! -name 'README.md' -type f -exec rm -f {} +
  rm -Rf -- */ && mv /maps/text/_* . && if [ -z "${TARGET_REPOSITORY##*github.io*}" ]; then mv /maps/_assets assets; fi
  
  mv /maps/_config.yml ${JEKYLL_CFG}
  sed -i "1s|^|target_repository: $TARGET_REPOSITORY\n|" ${JEKYLL_CFG}
  sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG} && cat ${JEKYLL_CFG}

  # https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --trace --profile ${INPUT_JEKYLL_BASEURL:=} -c ${JEKYLL_CFG}
  echo -e "\n$hr\nDEPLOY\n$hr" && deploy_remote "${TARGET_REPOSITORY}"
}

set_owner() {
  # Get organization list
  HEADER="Accept: application/vnd.github+json"
  echo ${INPUT_TOKEN} | gh auth login --with-token
  IFS=', '; array=($(gh api -H "${HEADER}" /user/orgs  --jq '.[].login' | sort | yq eval -P | sed "s/ /, /g"))
  
  # Iterate the organization list
  if [[ "$OWNER" -eq "${array[-1]}" ]]; then OWNER=${GITHUB_ACTOR}
  elif [[ ! " ${array[*]} " =~ " ${OWNER} " ]]; then OWNER=${array[0]}
  else
    for ((i=0; i < ${#array[@]}; i++)); do
      [[ "${array[$i]}" -eq "${OWNER}" && "$i" -lt ${#array[@]}-1  ]] && OWNER=${array[$i+1]}
    done
  fi
}

[ -z "${GITHUB_REPOSITORY##*github.io*}" ] && set_owner
echo -e "\n$hr\nJEKYLL BUILD\n$hr" && jekyll_build "${OWNER}"
