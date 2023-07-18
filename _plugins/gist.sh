#!/usr/bin/env bash

clone_gist() {

  PATTERN="sort_by(.created_at)|.[] | select(.public==true).files.[].raw_url"
  gh api -H "${HEADER}" /users/eq19/gists --jq "${PATTERN}" > /tmp/gist_files
  gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /maps/_includes/workdir/addition
  gh gist clone 4ffc4d02579d5cfd336a553c6da2f267 /maps/_includes/workdir/multiplication

  gh gist clone bbfac33187aae966e2faedf253f7b703 /maps/_includes/workdir/exponentiation
  gh gist clone e9832026b5b78f694e4ad22c3eb6c3ef /maps/_includes/workdir/exponentiation/folder1
  gh gist clone e84a0961dc7636c01d5953d19d65e30a /maps/_includes/workdir/exponentiation/folder2
  gh gist clone dc30497160f3389546d177da901537d9 /maps/_includes/workdir/exponentiation/folder3
  gh gist clone b9f901cda16e8a11dd24ee6b677ca288 /maps/_includes/workdir/exponentiation/folder4
  gh gist clone 765ddc69e339079a5a64b56c1d46e00f /maps/_includes/workdir/exponentiation/folder5
  gh gist clone f78d4470250720fb18111165564d555f /maps/_includes/workdir/exponentiation/folder6

  gh gist clone fd5135db1c295af4d3dae5f95f6891ea /maps/_includes/workdir/identition
  gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /maps/_includes/workdir/identition/folder1
  gh gist clone b32915925d9d365e2e9351f0c4ed786e /maps/_includes/workdir/identition/folder2
  gh gist clone 88d09204b2e5986237bd66d062406fde /maps/_includes/workdir/identition/folder3
  gh gist clone 8cab5e72d52ecb338a2f2187082a1699 /maps/_includes/workdir/identition/folder4
  gh gist clone 54600a56d20163c2da8910dd804ec406 /maps/_includes/workdir/identition/folder5
  gh gist clone f1af4317b619154719546e615aaa2155 /maps/_includes/workdir/identition/folder6
  gh gist clone 6c89c3b0f109e0ead561a452720d1ebf /maps/_includes/workdir/identition/folder7
  gh gist clone f21abd90f8d471390aad23d6ecc90d6d /maps/_includes/workdir/identition/folder8
  gh gist clone 6e2fcc2138be6fb68839a3ede32f0525 /maps/_includes/workdir/identition/folder9
  gh gist clone b541275ab7deda356feef32d600e44d8 /maps/_includes/workdir/identition/folder10
  gh gist clone 80c8098f16f3e6ca06893b17a02d910e /maps/_includes/workdir/identition/folder11
  gh gist clone 4ffc4d02579d5cfd336a553c6da2f267 /maps/_includes/workdir/identition/folder12

  gh gist clone 5b26b3cd8dc42d94ef240496ad56a54f /maps/_includes/workdir/identition/folder12/folder2
}