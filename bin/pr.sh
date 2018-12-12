#!/bin/bash

set -e

username=''
password=''
title=''
remote_origin=$(git remote get-url --push origin | cut -d ':' -f 2 | sed 's/\.git//')
current_branch=$(git rev-parse --abbrev-ref HEAD)

while getopts ":u:p:t:" opt; do
  case $opt in
    u) username="$OPTARG";;
    p) password="$OPTARG";;
    t) title="$OPTARG";;
    \?)
      echo "INVALID OPTARG $OPTARG" >&2
      exit 1
    ;;
  esac
done

shift $((OPTIND - 1))


curl --user "$username:$password" -X POST "https://api.github.com/repos/$remote_origin/pulls" -d "{\"title\":\"$title\",\"base\":\"master\",\"head\":\"$current_branch\",\"body\":\"$@\"}"

