#!/bin/bash

set -e

script_name=$(basename "$0")
username=''
password=''
title=''
remote_origin=$(git remote get-url --push origin | cut -d ':' -f 2 | sed 's/\.git//')
current_branch=$(git rev-parse --abbrev-ref HEAD)

usage() {
  echo "Usage: $script_name [-u <username>] [-p <password>] [-t <title of PR>] <body of PR>"
}

while getopts ":u:p:t:h" opt; do
  case $opt in
    u) username="$OPTARG";;
    p) password="$OPTARG";;
    t) title="$OPTARG";;
    h)
      usage
      exit
    ;;
    \?)
      echo "INVALID OPTARG $OPTARG" >&2
      usage
      exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

if [[ $current_branch == 'master' ]]; then
  echo "You're already on master, create a new branch, push it, and then run this script to open a PR to merge into master"
  exit 1
fi

if [[ -z $username ]]; then
  echo "username must be set"
  usage
fi

if [[ -z $password ]]; then
  echo "password must be set"
  usage
fi

if [[ -z $title ]]; then
  echo "title must be set"
  usage
fi


curl -s --user "$username:$password" -X POST "https://api.github.com/repos/$remote_origin/pulls" -d "{\"title\":\"$title\",\"base\":\"master\",\"head\":\"$current_branch\",\"body\":\"$@\"}"

