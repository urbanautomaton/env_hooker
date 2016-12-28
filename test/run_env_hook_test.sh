# shellcheck shell=bash
# vi: set ft=sh:

# shellcheck source=/dev/null
. ./test/helper.sh

function enter_dummy_project() {
  enter_count=$((enter_count + 1))
  export entered_dummy_directory=$1
}

function exit_dummy_project() {
  exit_count=$((exit_count + 1))
  export exited_dummy_directory=$entered_dummy_directory
  unset entered_dummy_directory
}

function setUp() {
  enter_count=0
  exit_count=0
  cd "$test_root"
  mkdir -p "$test_project_dir"
  touch "${test_project_dir}/.dummyproject"
}

function tearDown() {
  rm -rf "$test_project_dir"
  unset entered_directory exited_dummy_directory enter_count exit_count
}

function test_calls_enter_function_with_directory() {
  cd "$test_project_dir"
  # Okay so the problem is trap DEBUG doesn't run until the end of the
  # function (look up "simple command" maybe?)
  # http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called with the entered directory" \
    "$test_project_dir" \
    "$entered_dummy_directory"
}

function test_calls_enter_function_only_once_if_still_inside_project() {
  cd "$test_project_dir"
  __env_hooker_run_env_hook .dummyproject dummy_project
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called exactly once" \
    "0" \
    "$enter_count"
}

function test_does_not_call_exit_function_if_inside_project() {
  cd "$test_project_dir"
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is not called" \
    "0" \
    "$exit_count"
}

function test_calls_exit_function_if_exiting_project() {
  cd "$test_project_dir"
  __env_hooker_run_env_hook .dummyproject dummy_project
  cd "$test_root"
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called" \
    "1" \
    "$exit_count"
}

function test_calls_exit_function_only_once_if_exiting_project() {
  cd "$test_project_dir"
  __env_hooker_run_env_hook .dummyproject dummy_project
  cd "$test_root"
  __env_hooker_run_env_hook .dummyproject dummy_project
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called" \
    "1" \
    "$exit_count"
}

SHUNIT_PARENT=$0 . $SHUNIT2
