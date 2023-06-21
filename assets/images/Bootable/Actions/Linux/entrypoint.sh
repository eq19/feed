#!/bin/sh

BRANCH=gh-pages
TOKEN=${INPUT_TOKEN}
ACTOR=${GITHUB_ACTOR}
JEKYLL_BASEURL=${INPUT_JEKYLL_BASEURL:=}
JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml
REPOSITORY=eq19/parser

git config --global user.name "${ACTOR}"
git config --global user.email "${ACTOR}@users.noreply.github.com"

deploy_remote() {
  echo -e "Deploying to $1 on branch ${BRANCH}"
  REMOTE_REPO="https://${ACTOR}:${TOKEN}@github.com/$1.git"

  git remote add origin ${REMOTE_REPO} && git fetch &>/dev/null
  git add . && git commit -m "jekyll build from Action ${GITHUB_SHA}"
  git push --force --quiet ${REMOTE_REPO} master:${BRANCH}
}

# pinned repos
# https://dev.to/thomasaudo/get-started-with-github-grapql-api--1g8b
echo -e "\n$hr\nPINNED  REPOSITORIES\n$hr"
AUTH="Authorization: bearer $JEKYLL_GITHUB_TOKEN"
curl -L -X POST "${GITHUB_GRAPHQL_URL}" -H "$AUTH" \
--data-raw '{"query":"{\n  user(login: \"'${GITHUB_REPOSITORY_OWNER}'\") {\n pinnedItems(first: 6, types: REPOSITORY) {\n nodes {\n ... on Repository {\n name\n }\n }\n }\n }\n}"'

echo -e "\n$hr\nJEKYLL BUILD\n$hr" && pwd
# https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG}
JEKYLL_GITHUB_TOKEN=${TOKEN} bundle exec jekyll build --trace --profile \
  ${JEKYLL_BASEURL} -c ${JEKYLL_CFG} -d /vendor/build

cd /vendor/build #&& touch .nojekyll
rm -rf .git && git init --initial-branch=master && deploy_remote "${REPOSITORY}"
