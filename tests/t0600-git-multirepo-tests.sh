#!/usr/bin/env bash

test_description='Test multiple git repos'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test init multiple repos' '
	"$PASS" init -p personal $KEY1 &&
	"$PASS" git init personal &&
	"$PASS" init -p work $KEY2 &&
	"$PASS" git init work &&
	[[ -d $PASSWORD_STORE_DIR/work/.git ]] &&
	[[ -d $PASSWORD_STORE_DIR/personal/.git ]]
'

test_expect_success 'Test alter passwords across multiple repos' '
	"$PASS" generate personal/cred1 50 &&
	"$PASS" generate work/sub/dir/cred2 50 &&
	"$PASS" rm personal/cred1 &&
	[[ ! -e $PASSWORD_STORE_DIR/personal/cred1.gpg ]] &&
	[[ -e $PASSWORD_STORE_DIR/work/sub/dir/cred2.gpg ]] &&
	export GIT_WORK_TREE="$PASSWORD_STORE_DIR/personal" &&
	export GIT_DIR="$GIT_WORK_TREE/.git" &&
	[[ "$(git rev-list --all --count)" == "4" ]] &&
	export GIT_WORK_TREE="$PASSWORD_STORE_DIR/work" &&
	export GIT_DIR="$GIT_WORK_TREE/.git" &&
	[[ "$(git rev-list --all --count)" == "3" ]]
'

test_done
