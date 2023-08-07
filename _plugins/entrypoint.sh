#!/usr/bin/env bash
# Structure: Cell Types – Modulo 6
# https://www.hexspin.com/proof-of-confinement/

set_target() {
  
  # Get Structure
  if [[ $2 == *"github.io"* ]]; then
    [[ -n "$CELL" ]] && SPIN=$(( CELL * 7 ))
    echo "  - spin: ${CELL}" >> /maps/_config.yml
    pinned_repos.rb ${OWNER} | yq eval -P | sed "s/ /, /g" > /tmp/pinned_repo
    IFS=', '; array=($(cat /tmp/pinned_repo))
  else
    gh api -H "${HEADER}" /user/orgs --jq '.[].description' | sort -uf | yq eval -P | sed "s/ /, /g" > /tmp/desc
    gh api -H "${HEADER}" /user/orgs  --jq '.[].login' | sort -uf | yq eval -P | sed "s/ /, /g" > /tmp/user_orgs
    IFS=', '; array=($(cat /tmp/user_orgs))
  fi
  
  # Iterate the Structure
  printf -v array_str -- ',,%q' "${array[@]}"
  if [[ ! "${array_str},," =~ ",,$1,," ]]; then
    SPAN=0; echo ${array[0]}
  elif [[ "${array[-1]}" == "$1" ]]; then
    SPAN=${#array[@]}; echo $2 | sed "s|${OWNER}.github.io|${ENTRY}.github.io|g"
  else
    for ((i=0; i < ${#array[@]}; i++)); do
      if [[ "${array[$i]}" == "$1" && "$i" -lt "${#array[@]}-1" ]]; then SPAN=$(( $i + 1 )); echo ${array[$SPAN]}; fi
    done
  fi
  
  # Generate id from the Structure
  [[ -z "$SPIN" ]] && if [[ "$1" != "$2" ]]; then SPIN=0; else SPIN=7; fi
  if [[ -n "$CELL" ]]; then
    echo "  - span: ${SPAN}" >> /maps/_config.yml
    echo "  - pinned:  [$(cat /tmp/pinned_repo)]" >> /maps/_config.yml
    echo "  - user_orgs:  [$(cat /tmp/user_orgs)]" >> /maps/_config.yml
    echo "  - orgs_description:  [$(cat /tmp/desc)]" >> /maps/_config.yml
  fi
  return $(( $SPAN + $SPIN ))
}

jekyll_build() {

  echo -e "\n$hr\nCONFIG\n$hr"
  [[ $1 == *"github.io"* ]] && OWNER=$2
  sed -i "1s|^|repository: ${OWNER}/$1\n|" /maps/_config.yml

  [[ "${OWNER}" != "eq19" ]] && PROPERTY=$(gh api -H "${HEADER}" /orgs/${OWNER} --jq '.name')
  [[ -n "$PROPERTY" ]] && sed -i "1s|^|property: ${PROPERTY}\n|" /maps/_config.yml
  
  MYPATH=("io" "maps" "feed" "lexer" "parser" "syntax" "grammar")
  [[ $1 != *"github.io"* ]] && sed -i "1s|^|baseurl: /${MYPATH[$((($3 + 1) % 7))]}\n|" /maps/_config.yml
  sed -i "1s|^|id: $(( $3 + 31 ))\n|" /maps/_config.yml && gist.sh $1 ${OWNER} $3 &>/dev/null && cat /maps/_config.yml

  echo -e "\n$hr\nWORKSPACE\n$hr"
  cd /maps && mv -f /tmp/workdir/* .
  NR=$(cat /tmp/gist_files | awk "NR==$(( $3 + 2 ))")
  [[ $1 != "eq19.github.io" ]] && wget -O /maps/README.md ${NR} &>/dev/null
  if [[ $1 == *"github.io"* ]]; then mv /maps/_assets /maps/assets; fi && ls -al /maps

  echo -e "\n$hr\nBUILD\n$hr"
  CREDENTIAL=${INPUT_TOKEN}
  [[ "${OWNER}" != "${USER}" ]] && CREDENTIAL=${INPUT_OWNER}
  find . -type f -name "*.md" -exec sed -i 's/💎:/sort:/g' {} +
  REMOTE_REPO="https://${ACTOR}:${CREDENTIAL}@github.com/${OWNER}/$1.git"

  # Jekyll Quick Reference (Cheat Sheet) https://gist.github.com/DrOctogon/bfb6e392aa5654c63d12
  JEKYLL_GITHUB_TOKEN=${INPUT_TOKEN} bundle exec jekyll build --profile -t -s /maps -p /maps/_plugins/gems
  
  echo -e "\n$hr\nDEPLOY\n$hr"
  cd _site && touch .nojekyll && mv /maps/README.md .
  if [[ $1 == "eq19.github.io" ]]; then echo "www.eq19.com" > CNAME; fi && ls -al . && echo -e "\n"

  git init --initial-branch=master > /dev/null && git remote add origin ${REMOTE_REPO}
  git add . && git commit -m "jekyll build" > /dev/null && git push --force ${REMOTE_REPO} master:gh-pages
}

# Set update workflow
git config --global user.name "${ACTOR}"
git config --global --add safe.directory ${GITHUB_WORKSPACE}
git config --global user.email "${ACTOR}@users.noreply.github.com"

rm -rf .github && mv /maps/.github . && chown -R "$(whoami)" .github
[[ "${OWNER}" == "${USER}" ]] && sed -i 's/feed/lexer/g' .github/workflows/main.yml
git add . && git commit -m "update workflow" > /dev/null && git push > /dev/null 2>&1

# Get structure on gist files
HEADER="Accept: application/vnd.github+json"
echo ${INPUT_TOKEN} | gh auth login --with-token
PATTERN='sort_by(.created_at)|.[] | select(.public == true).files.[] | select(.filename != "README.md").raw_url'
gh api -H "${HEADER}" /users/eq19/gists --jq "${PATTERN}" > /tmp/gist_files

# Capture the string and return status
if [[ "${OWNER}" != "${USER}" ]]; then ENTRY=$(set_target ${OWNER} ${USER}); else ENTRY=$(set_target ${OWNER}); fi
CELL=$? && TARGET_REPOSITORY=$(set_target $(basename ${REPO}) ${OWNER}.github.io)
jekyll_build ${TARGET_REPOSITORY} ${ENTRY} $?
