#!/usr/bin/env bash

set -euo pipefail

die()
{
    echo "$@" >&2
    exit 1
}

[ $# -ne 1 ] || die "usage: $0"

# clone/update gcc src
if [ ! -d gcc ]; then
    #git clone https://github.com/gcc-mirror/gcc/ --shallow-since="2023-01-01"
    git init gcc
    git -C gcc config remote.origin.url https://forge.sourceware.org/gcc/gcc-TEST
    git -C gcc config remote.origin.fetch "+refs/pull/*:refs/remotes/forgejo/pull/*"
    git -C gcc config --global init.defaultBranch master
fi
git -C gcc fetch -a --progress --prune --no-tags


get_all_branches_to_build()
{
    git -C gcc branch -a | \
	grep forgejo/pull/ | \
	sed -e 's+remotes/forgejo/pull/++' -e 's+/head++' | \
	sort -n
}

build_list=""
for branch in $(get_all_branches_to_build); do
    echo -n "PR: $branch"
    ci_complete=0
    git branch -a | grep -q "${branch}_ci_complete" && ci_complete=1
    if [ ${ci_complete} -eq 1 ]; then
	echo "  already done"
    else
	echo "  todo"
    fi
done
