#!/usr/bin/env bash

clone_gist() {

  PATTERN="sort_by(.created_at)|.[] | select(.public==true).files.[].raw_url"
  gh api -H "${HEADER}" /users/eq19/gists --jq "${PATTERN}" > /tmp/gist_files
  gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /maps/_includes/workdir/addition &>/dev/null
  gh gist clone 5b26b3cd8dc42d94ef240496ad56a54f /maps/_includes/workdir/multiplication &>/dev/null

  gh gist clone e9832026b5b78f694e4ad22c3eb6c3ef /maps/_includes/workdir/exponentiation/folder1 &>/dev/null
}