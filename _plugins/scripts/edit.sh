#!/usr/bin/env bash

IFS=$'\n' read -d '' -r -a array < _Sidebar.md

echo $1
echo ${array[2]};
