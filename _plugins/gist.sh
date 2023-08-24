#!/usr/bin/env bash

rm -rf /tmp/workdir /tmp/gistdir

WIKI=https://github.com/$2/$1.wiki.git
BASE=https://github.com/eq19/eq19.github.io.wiki.git

git ls-remote ${WIKI} > /dev/null 2>&1
git clone $([ $? == 0 ] && echo $WIKI || echo $BASE) /tmp/workdir
gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /tmp/gistdir

gh gist clone b32915925d9d365e2e9351f0c4ed786e /tmp/gistdir/identition/folder1
gh gist clone 88d09204b2e5986237bd66d062406fde /tmp/gistdir/identition/folder2
gh gist clone 8cab5e72d52ecb338a2f2187082a1699 /tmp/gistdir/identition/folder3
gh gist clone 54600a56d20163c2da8910dd804ec406 /tmp/gistdir/identition/folder4
gh gist clone f1af4317b619154719546e615aaa2155 /tmp/gistdir/identition/folder5
gh gist clone 6c89c3b0f109e0ead561a452720d1ebf /tmp/gistdir/identition/folder6
gh gist clone f21abd90f8d471390aad23d6ecc90d6d /tmp/gistdir/identition/folder7
gh gist clone 6e2fcc2138be6fb68839a3ede32f0525 /tmp/gistdir/identition/folder8
gh gist clone b541275ab7deda356feef32d600e44d8 /tmp/gistdir/identition/folder9
gh gist clone 80c8098f16f3e6ca06893b17a02d910e /tmp/gistdir/identition/folder10
gh gist clone 4ffc4d02579d5cfd336a553c6da2f267 /tmp/gistdir/identition/folder11

gh gist clone f78d4470250720fb18111165564d555f /tmp/gistdir/exponentiation/folder13
gh gist clone 765ddc69e339079a5a64b56c1d46e00f /tmp/gistdir/exponentiation/folder14
gh gist clone b9f901cda16e8a11dd24ee6b677ca288 /tmp/gistdir/exponentiation/folder15
gh gist clone dc30497160f3389546d177da901537d9 /tmp/gistdir/exponentiation/folder16
gh gist clone e84a0961dc7636c01d5953d19d65e30a /tmp/gistdir/exponentiation/folder17
gh gist clone e9832026b5b78f694e4ad22c3eb6c3ef /tmp/gistdir/exponentiation/folder18

find /tmp/workdir -type f -name "Home.md" -prune -exec sh -c 'mv -f "$1" "${1%/*}/README.md"' sh {} \;
find /tmp/gistdir -type f -name "*zone.md" -prune -exec sh -c 'mv -f "$1" "${1%-*}/README.md"' sh {} \;
find /tmp/workdir/identition -type f -name "*.md" -prune -exec sh -c 'mv -f "$1" "${1%/*}/README.md"' sh {} \;
find /tmp/workdir/exponentiation -type f -name "*.md" -prune -exec sh -c 'mv -f "$1" "${1%/*}/README.md"' sh {} \;
find /tmp/gistdir -type d -name .git -prune -exec rm -rf {} \; && find /tmp/gistdir -type f -name "README.md" -exec rm -rf {} \;
