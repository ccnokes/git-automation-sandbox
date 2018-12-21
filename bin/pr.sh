#!/bin/bash

set -e

script_name=$(basename "$0")
remote_origin=$(git remote get-url --push origin | cut -d ':' -f 2 | sed 's/\.git//')
current_branch=$(git rev-parse --abbrev-ref HEAD)

username=''
password=''
title=''

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
      usage >&2
      exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

# should be on the branch you're PRing
if [[ $current_branch == 'master' ]]; then
  echo "You're already on master, create a new branch, push it, and then run this script to open a PR to merge into master"
  exit 1
fi

# that branch should exist in the remote already
if ! git ls-remote --exit-code --heads $(git remote get-url --push origin) "refs/heads/$current_branch"; then
  echo "This branch isn't pushed. First push this branch, then re-run this script." >&2
  exit 1
fi

check_is_set() {
  if [[ -z $2 ]]; then
    echo "ERROR! $1 must be set" >&2
    usage >&2
    exit 1
  fi
}

check_is_set "username" $username
check_is_set "password" $password
check_is_set "title" $title

data=$(cat <<-END
{
  "title": "$title",
  "base": "master",
  "head": "$current_branch",
  "body": "$@"
}
END
)

curl -s --user "$username:$password" -X POST "https://api.github.com/repos/$remote_origin/pulls" -d "$data" > /dev/null

