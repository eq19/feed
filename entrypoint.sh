#!/bin/sh

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
  
  # https://stackoverflow.com/q/43352056/4058484
  chmod +x /maps/pinned_repos.rb && /maps/pinned_repos.rb ${OWNER} > nodes.yaml
  [ -z "${GITHUB_REPOSITORY##*github.io*}" ] && TARGET_REPOSITORY=${OWNER}/$(head -n 1 nodes.yaml)

  while read -r ONE; do
    read -r TWO
    [ -z "${GITHUB_REPOSITORY##*$ONE*}" ] && TARGET_REPOSITORY=${OWNER}/${TWO}
  done < nodes.yaml

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
  gh api -H "Accept: application/vnd.github+json" /user/orgs --jq "map(.login)" > nodes.json
  OWNER=$(jq -r ".[1]" nodes.json)
}

[ -z "${GITHUB_REPOSITORY##*github.io*}" ] && set_owner
#echo -e "\n$hr\nJEKYLL BUILD\n$hr" && jekyll_build
chmod +x /maps/pinned_repos.rb && /maps/pinned_repos.rb ${OWNER} > nodes.yaml
  while read -r ONE; do
    read -r TWO
    [ -z "${GITHUB_REPOSITORY##*$ONE*}" ] && TARGET_REPOSITORY=${OWNER}/${TWO}
  done < nodes.yaml
echo ${TARGET_REPOSITORY}
