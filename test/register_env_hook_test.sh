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

function test_records_hook_in_global_state() {
  register_env_hook .dummyproject dummy_project

  assertTrue \
    "returns a success code" \
    "register_env_hook .dummyproject dummy_project"

  assertEquals \
    "adds hook to global hooks storage" \
    ".dummyproject dummy_project" \
    "${ENV_HOOKER_HOOKS[*]}"
}

function test_returns_error_status_if_arguments_not_present() {
  assertFalse \
    "returns error status if arguments not present" \
    "register_env_hook 2>/dev/null"

  assertEquals \
    "does not record the hook" \
    "" \
    "${ENV_HOOKER_HOOKS[*]}"
}

function test_returns_error_status_if_hook_functions_not_defined() {
  assertFalse \
    "returns error status if hook functions not defined" \
    "register_env_hook .notsetup not_setup 2>/dev/null"

  assertEquals \
    "does not record the hook" \
    "" \
    "${ENV_HOOKER_HOOKS[*]}"
}

# shellcheck source=/dev/null
SHUNIT_PARENT=${0} . ${SHUNIT2}
