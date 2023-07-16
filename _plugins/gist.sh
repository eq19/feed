#!/usr/bin/env bash

clone_gist() {

  PATTERN="sort_by(.created_at)|.[] | select(.public==true).files.[].raw_url"
  gh api -H "${HEADER}" /users/eq19/gists --jq "${PATTERN}" > /tmp/gist_files
  gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /maps/_includes/workdir/addition &>/dev/null
  gh gist clone 5b26b3cd8dc42d94ef240496ad56a54f /maps/_includes/workdir/multiplication &>/dev/null

  gh gist clone e9832026b5b78f694e4ad22c3eb6c3ef /maps/_includes/workdir/exponentiation/folder1 &>/dev/null
  gh gist clone e84a0961dc7636c01d5953d19d65e30a /maps/_includes/workdir/exponentiation/folder2 &>/dev/null
  gh gist clone dc30497160f3389546d177da901537d9 /maps/_includes/workdir/exponentiation/folder3 &>/dev/null
  gh gist clone b9f901cda16e8a11dd24ee6b677ca288 /maps/_includes/workdir/exponentiation/folder4 &>/dev/null
  gh gist clone 765ddc69e339079a5a64b56c1d46e00f /maps/_includes/workdir/exponentiation/folder5 &>/dev/null
  gh gist clone f78d4470250720fb18111165564d555f /maps/_includes/workdir/exponentiation/folder6 &>/dev/null
}