# shellcheck shell=bash
# vi: set ft=sh:

. ./test/helper.sh

function enter_dummy_project() {
  :
}

function exit_dummy_project() {
  :
}

function setUp() {
  original_hooks=(${ENV_HOOKER_HOOKS[@]})
  ENV_HOOKER_HOOKS=()
}

function tearDown() {
  ENV_HOOKER_HOOKS=(${original_hooks[@]})
}

function test_records_hook_in_global() {
  register_env_hook .dummyproject dummy_project

  assertEquals \
    "adds hook to global hooks storage" \
    ".dummyproject dummy_project" \
    "${ENV_HOOKER_HOOKS[*]}"
}

# shellcheck source=/dev/null
SHUNIT_PARENT=${0} . ${SHUNIT2}
