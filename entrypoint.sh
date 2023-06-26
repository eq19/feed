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
  
  # Access a user's pinned repos
  # https://stackoverflow.com/q/43352056/4058484
  
  chmod +x /maps/pinned_repos.rb
  IFS=', '; array=($(/maps/pinned_repos.rb ${OWNER} | yq eval -P | sed "s/ /, /g"))
  [ -z "${GITHUB_REPOSITORY##*github.io*}" ] && TARGET_REPOSITORY=${OWNER}/${array[0]}

  # Structure: Cell Types – Modulo 6
  # https://www.hexspin.com/cell-types/

  for i in 0 1 2 3 4 5
  do
    j=$(($i+1)) && NAME=${array[$i]}
    [[ -z "${GITHUB_REPOSITORY##*$NAME*}" && "$i" -lt 5 ]] && TARGET_REPOSITORY=${OWNER}/${array[$j]}
  done

  rm -rf  nodes.* && rm -Rf -- */ && mv /maps/text/_* .
  [ -z "${TARGET_REPOSITORY##*github.io*}" ] && mv /maps/_assets assets

  mv /maps/_config.yml ${JEKYLL_CFG}
  sed -i "1s|^|target_repository: $TARGET_REPOSITORY\n|" ${JEKYLL_CFG}
  sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG} && cat ${JEKYLL_CFG}

  # https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --trace --profile ${INPUT_JEKYLL_BASEURL:=} -c ${JEKYLL_CFG}
  echo -e "\n$hr\nDEPLOY\n$hr" && deploy_remote "${TARGET_REPOSITORY}"
}

set_owner() {
  echo ${INPUT_TOKEN} | gh auth login --with-token
  IFS=', '; array=($(gh api -H "Accept: application/vnd.github+json" /user/orgs  --jq '.[].login' | yq eval -P | sed "s/ /, /g"))
  for item in ${array[@]}; do echo $item; done
}

[ -z "${GITHUB_REPOSITORY##*github.io*}" ] && set_owner
echo -e "\n$hr\nJEKYLL BUILD\n$hr" && jekyll_build
