#!/bin/sh

TOKEN=${INPUT_TOKEN}
ACTOR=${GITHUB_ACTOR}
JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml

setup_config() {
	# pinned repos
	# https://stackoverflow.com/a/43358500/4058484
	curl -s -X POST "${GITHUB_GRAPHQL_URL}" -H "Authorization: bearer $TOKEN" --data-raw '{"query":"{\n  user(login: \"'${GITHUB_REPOSITORY_OWNER}'\") {\n pinnedItems(first: 6, types: REPOSITORY) {\n nodes {\n ... on Repository {\n name\n }\n }\n }\n }\n}"' | jq --raw-output '.data.user.pinnedItems' | yq eval -P | sed "s/name: //g" > nodes.yaml

	for i in 0 1 2 3 4 5
	do
	   j=$(($i+1))
	   NAME=$(yq eval ".nodes[$i]" nodes.yaml)
	   [ -z "${GITHUB_REPOSITORY##*$NAME*}" ] && TARGET=$(yq eval ".nodes[$j]" nodes.yaml)
	done

	rm nodes.yaml
	rm -Rf -- */ && mv /maps/text/_* .
	REPOSITORY=${GITHUB_REPOSITORY_OWNER}/${TARGET}
	[ "${REPOSITORY}" == "eq19/eq19.github.io" ] && mv /maps/assets .

    mv /maps/_config.yml ${JEKYLL_CFG}
	sed -i "1s|^|target_repository: $REPOSITORY\n|" ${JEKYLL_CFG}
	sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG} && cat ${JEKYLL_CFG}

	# https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
	JEKYLL_GITHUB_TOKEN=${TOKEN} bundle exec jekyll build --trace --profile ${INPUT_JEKYLL_BASEURL:=} -c ${JEKYLL_CFG}
}

echo -e "\n$hr\nJEKYLL BUILD\n$hr"
setup_config


deploy_remote() {
  echo -e "Deploying to $1 on branch gh-pages"
  REMOTE_REPO="https://${ACTOR}:${TOKEN}@github.com/$1.git"

  git config --global user.name "${ACTOR}"
  git config --global user.email "${ACTOR}@users.noreply.github.com"

  git clone -b gh-pages --single-branch ${REMOTE_REPO} &>/dev/null
  cd $(basename $1) && rm -rf *

  mv -v ${GITHUB_WORKSPACE}/_site/* . && touch .nojekyll && git add .
  git commit -m "jekyll build from cction ${GITHUB_SHA}"
  git push -u origin gh-pages
}

echo -e "\n$hr\nDEPLOY\n$hr"
deploy_remote "${REPOSITORY}"
