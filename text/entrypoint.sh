#!/bin/sh

BRANCH=gh-pages
TOKEN=${INPUT_TOKEN}
ACTOR=${GITHUB_ACTOR}
JEKYLL_BASEURL=${INPUT_JEKYLL_BASEURL:=}
JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml

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
# https://stackoverflow.com/a/43358500/4058484
echo -e "\n$hr\nCONFIG FILE\n$hr"
sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG}
curl -s -X POST "${GITHUB_GRAPHQL_URL}" -H "Authorization: bearer $TOKEN" --data-raw '{"query":"{\n  user(login: \"'${GITHUB_REPOSITORY_OWNER}'\") {\n pinnedItems(first: 6, types: REPOSITORY) {\n nodes {\n ... on Repository {\n name\n }\n }\n }\n }\n}"' | jq --raw-output '.data.user.pinnedItems' | yq eval -P | sed "s/name: //g" >> ${JEKYLL_CFG} && cat ${JEKYLL_CFG}

for i in 0 1 2 3 4 5
do
   yq eval '.nodes[i]' ${JEKYLL_CFG}
done


pwd && mv /maps/text/_* . && ls -al
REPOSITORY=eq19/parser
[ "${REPOSITORY}" == "eq19/eq19.github.io" ] && mv /maps/assets . 

echo -e "\n$hr\nJEKYLL BUILD\n$hr"
# https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
JEKYLL_GITHUB_TOKEN=${TOKEN} bundle exec jekyll build --trace --profile \
  ${JEKYLL_BASEURL} -c ${JEKYLL_CFG}

cd ./_site #&& touch .nojekyll
git init --initial-branch=master && deploy_remote "${REPOSITORY}"
