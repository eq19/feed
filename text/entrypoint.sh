#!/bin/sh

TOKEN=${INPUT_TOKEN}
ACTOR=${GITHUB_ACTOR}
SCRIPT_DIR=/maps/text/scripts
JEKYLL_BASEURL=${INPUT_JEKYLL_BASEURL:=}
JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml

echo -e "\n$hr\nCONFIG FILE\n$hr"
mv /maps/_config.yml ${JEKYLL_CFG}
source ${SCRIPT_DIR}/config.sh && setup_config && cat ${JEKYLL_CFG}

echo -e "\n$hr\nJEKYLL BUILD\n$hr" && ls -al
# https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
JEKYLL_GITHUB_TOKEN=${TOKEN} bundle exec jekyll build --trace --profile \
  ${JEKYLL_BASEURL} -c ${JEKYLL_CFG}

echo -e "\n$hr\nDEPLOY\n$hr"
source ${SCRIPT_DIR}/remote.sh && deploy_remote "${REPOSITORY}"
