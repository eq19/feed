#!/usr/bin/env bash

deploy_remote() {
  echo -e "Deploying to $1 on branch ${BRANCH}"
  REMOTE_REPO="https://${ACTOR}:${TOKEN}@github.com/$1.git"

  git config --global user.name "${ACTOR}"
  git config --global user.email "${ACTOR}@users.noreply.github.com"

  git clone -b gh-pages --single-branch ${REMOTE_REPO} &>/dev/null
  cd "$(basename "${REMOTE_REPO}" .git)" && rm -rf *

  mv -v ${GITHUB_WORKSPACE}/_site/* . && git add .
  git commit -m "jekyll build from cction ${GITHUB_SHA}"
  git push -u origin gh-pages

  #git remote add origin ${REMOTE_REPO} && git fetch &>/dev/null
  #git add . && git commit -m "jekyll build from Action ${GITHUB_SHA}"
  #git push --force --quiet ${REMOTE_REPO} master:${BRANCH}
}
