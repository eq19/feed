#!/usr/bin/env bash
# Structure: Cell Types – Modulo 6
# https://www.hexspin.com/proof-of-confinement/

jekyll_build() {
  
  echo -e "\n$hr\nSET CONFIG\n$hr"
  rm -rf  nodes.* && rm -Rf -- */ && mv /maps/text/_* .
  if [[ $1 == *"github.io"* ]]; then mv /maps/_assets assets; fi
  JEKYLL_CFG=${GITHUB_WORKSPACE}/_config.yml && mv /maps/_config.yml ${JEKYLL_CFG}

  sed -i "1s|^|target_repository: $1\n|" ${JEKYLL_CFG}
  sed -i "1s|^|repository: $GITHUB_REPOSITORY\n|" ${JEKYLL_CFG} && cat ${JEKYLL_CFG}

  echo -e "\n$hr\nBUILD & DEPLOY\n$hr"
  # https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --trace --profile ${INPUT_JEKYLL_BASEURL:=} -c ${JEKYLL_CFG}

  git config --global user.name "${GITHUB_ACTOR}" && git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  REMOTE_REPO="https://${GITHUB_ACTOR}:${INPUT_TOKEN}@github.com/$1.git" && echo -e "Deploying to $1 on branch gh-pages"
  git clone -b gh-pages --single-branch ${REMOTE_REPO} &>/dev/null && cd $(basename $1) && rm -rf *
git config --global --add safe.directory '*'
  mv -v ${GITHUB_WORKSPACE}/_site/* . && touch .nojekyll && git add .
  git commit -m "jekyll build" && git push -u origin gh-pages
}

set_target() {
  
  # Get Structure
  if [[ "$2" == *"github.io"* ]]; then
    IFS=', '; array=($(pinned_repos.rb ${OWNER} | yq eval -P | sed "s/ /, /g"))
  else
    HEADER="Accept: application/vnd.github+json"
    echo ${INPUT_TOKEN} | gh auth login --with-token
    IFS=', '; array=($(gh api -H "${HEADER}" /user/orgs  --jq '.[].login' | sort | yq eval -P | sed "s/ /, /g"))
  fi
  
  # Iterate the Structure
  printf -v array_str -- ',,%q' "${array[@]}"
  if [[ ! "${array_str},," =~ ",,$1,," ]]; then echo ${array[0]}
  elif [[ "${array[-1]}" == "$1" ]]; then echo $2
  else
    for ((i=0; i < ${#array[@]}; i++)); do
      [[ "${array[$i]}" == "$1" && "$i" -lt "${#array[@]}-1" ]] && echo ${array[$i+1]}
    done
  fi
}

[[ ${GITHUB_REPOSITORY} == *"github.io"* ]] && OWNER=$(set_target ${OWNER} ${GITHUB_ACTOR})
TARGET_REPOSITORY=$(set_target $(basename ${GITHUB_REPOSITORY}) ${OWNER}.github.io)
jekyll_build ${OWNER}/${TARGET_REPOSITORY}
