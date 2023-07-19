#!/usr/bin/env bash

rm -rf /tmp/workdir

gh gist clone c9bdc2bbe55f2d162535023c8d321831 /tmp/workdir
gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /tmp/workdir/addition
mv -f /tmp/workdir/addition.md /tmp/workdir/addition/README.md

gh gist clone 4ffc4d02579d5cfd336a553c6da2f267 /tmp/workdir/multiplication
mv -f /tmp/workdir/multiplication.md /tmp/workdir/multiplication/README.md

gh gist clone bbfac33187aae966e2faedf253f7b703 /tmp/workdir/exponentiation
mv -f /tmp/workdir/the_exponentiation.md /tmp/workdir/exponentiation/README.md
gh gist clone e9832026b5b78f694e4ad22c3eb6c3ef /tmp/workdir/exponentiation/folder18
gh gist clone e84a0961dc7636c01d5953d19d65e30a /tmp/workdir/exponentiation/folder17
gh gist clone dc30497160f3389546d177da901537d9 /tmp/workdir/exponentiation/folder16
gh gist clone b9f901cda16e8a11dd24ee6b677ca288 /tmp/workdir/exponentiation/folder15
gh gist clone 765ddc69e339079a5a64b56c1d46e00f /tmp/workdir/exponentiation/folder14
gh gist clone f78d4470250720fb18111165564d555f /tmp/workdir/exponentiation/folder13

gh gist clone fd5135db1c295af4d3dae5f95f6891ea /tmp/workdir/identition
mv -f /tmp/workdir/the_identition.md /tmp/workdir/identition/README.md
gh gist clone 0ce5848f7ad62dc46dedfaa430069857 /tmp/workdir/identition/folder1
gh gist clone b32915925d9d365e2e9351f0c4ed786e /tmp/workdir/identition/folder2
gh gist clone 88d09204b2e5986237bd66d062406fde /tmp/workdir/identition/folder3
gh gist clone 8cab5e72d52ecb338a2f2187082a1699 /tmp/workdir/identition/folder4
gh gist clone 54600a56d20163c2da8910dd804ec406 /tmp/workdir/identition/folder5
gh gist clone f1af4317b619154719546e615aaa2155 /tmp/workdir/identition/folder6
gh gist clone 6c89c3b0f109e0ead561a452720d1ebf /tmp/workdir/identition/folder7
gh gist clone f21abd90f8d471390aad23d6ecc90d6d /tmp/workdir/identition/folder8
gh gist clone 6e2fcc2138be6fb68839a3ede32f0525 /tmp/workdir/identition/folder9
gh gist clone b541275ab7deda356feef32d600e44d8 /tmp/workdir/identition/folder10
gh gist clone 80c8098f16f3e6ca06893b17a02d910e /tmp/workdir/identition/folder11

gh gist clone 5b26b3cd8dc42d94ef240496ad56a54f /tmp/workdir/identition/folder12
mv -f /tmp/workdir/the_root.md /tmp/workdir/identition/folder12/README.md

find /tmp/workdir -type d -name .git -prune -exec rm -rf {} \;
