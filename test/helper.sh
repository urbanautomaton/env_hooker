# shellcheck shell=bash

# [[ -z "$SHUNIT2"     ]] && SHUNIT2=/usr/share/shunit2/shunit2
[[ -z "$SHUNIT2"     ]] && SHUNIT2=/usr/local/bin/shunit2
[[ -n "$ZSH_VERSION" ]] && setopt shwordsplit

export PREFIX="$PWD/test"
export HOME="$PREFIX/home"
export PATH="$PWD/bin:$PATH"

# shellcheck source=/dev/null
. ./share/env_hooker/env_hooker.sh

test_root="$PWD/test"
test_project_dir="$PWD/test/project"

setUp() { return; }
tearDown() { return; }
oneTimeTearDown() { return; }
