#!/usr/bin/env bash

PATTERN="sort_by(.created_at)|.[] | select(.public==true).files.[].raw_url"
gh api -H "${HEADER}" /users/eq19/gists --jq "${PATTERN}" > /tmp/gist_files
rm -rf /tmp/maps /maps/addition /maps/multiplication /maps/exponentiation /maps/identition

gh gist clone c9bdc2bbe55f2d162535023c8d321831 /tmp/maps
gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /maps/addition
gh gist clone 4ffc4d02579d5cfd336a553c6da2f267 /maps/multiplication

gh gist clone bbfac33187aae966e2faedf253f7b703 /maps/exponentiation
gh gist clone e9832026b5b78f694e4ad22c3eb6c3ef /maps/exponentiation/folder18
gh gist clone e84a0961dc7636c01d5953d19d65e30a /maps/exponentiation/folder17
gh gist clone dc30497160f3389546d177da901537d9 /maps/exponentiation/folder16
gh gist clone b9f901cda16e8a11dd24ee6b677ca288 /maps/exponentiation/folder15
gh gist clone 765ddc69e339079a5a64b56c1d46e00f /maps/exponentiation/folder14
gh gist clone f78d4470250720fb18111165564d555f /maps/exponentiation/folder13

gh gist clone fd5135db1c295af4d3dae5f95f6891ea /maps/identition
gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /maps/identition/folder1
gh gist clone b32915925d9d365e2e9351f0c4ed786e /maps/identition/folder2
gh gist clone 88d09204b2e5986237bd66d062406fde /maps/identition/folder3
gh gist clone 8cab5e72d52ecb338a2f2187082a1699 /maps/identition/folder4
gh gist clone 54600a56d20163c2da8910dd804ec406 /maps/identition/folder5
gh gist clone f1af4317b619154719546e615aaa2155 /maps/identition/folder6
gh gist clone 6c89c3b0f109e0ead561a452720d1ebf /maps/identition/folder7
gh gist clone f21abd90f8d471390aad23d6ecc90d6d /maps/identition/folder8
gh gist clone 6e2fcc2138be6fb68839a3ede32f0525 /maps/identition/folder9
gh gist clone b541275ab7deda356feef32d600e44d8 /maps/identition/folder10
gh gist clone 80c8098f16f3e6ca06893b17a02d910e /maps/identition/folder11
gh gist clone 5b26b3cd8dc42d94ef240496ad56a54f /maps/identition/folder12

mv -f /tmp/maps/19_2_addition.md /maps/addition/README.md
mv -f /tmp/maps/19_3_multiplication.md /maps/multiplication/README.md
mv -f /tmp/maps/19_4_exponentiation.md /maps/exponentiation/README.md
mv -f /tmp/maps/19_5_identition.md /maps/identition/README.md
