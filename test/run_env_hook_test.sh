# shellcheck shell=bash
# vi: set ft=sh:

. ./test/helper.sh

function enter_dummy_project() {
  enter_count=$((enter_count + 1))
  export entered_dummy_directory=$1
}

function exit_dummy_project() {
  exit_count=$((exit_count + 1))
  export exited_dummy_directory=${entered_dummy_directory}
  unset entered_dummy_directory
}

function setUp() {
  enter_count=0
  exit_count=0
  cd "${test_root}" || exit
  mkdir -p "${test_project_dir}"
  touch "${test_project_dir}/.dummyproject"
}

function tearDown() {
  rm -rf "${test_project_dir}"
  unset entered_directory \
    exited_dummy_directory \
    enter_count \
    exit_count \
    ENV_HOOKER_ENTERED_dummy_project
}

function test_calls_enter_function_with_directory() {
  cd "${test_project_dir}" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called with the entered directory" \
    "${test_project_dir}" \
    "${entered_dummy_directory}"
}

function test_calls_enter_function_with_project_root_if_entered_at_subdir() {
  local subdir="${test_project_dir}/sub_dir"
  mkdir -p "$subdir"
  cd "$subdir" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called with the project root if entered at a subdirectory" \
    "${test_project_dir}" \
    "${entered_dummy_directory}"
}

function test_calls_enter_function_only_once_if_still_inside_project() {
  cd "${test_project_dir}" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called exactly once" \
    1 \
    "${enter_count}"
}

function test_does_not_call_exit_function_if_inside_project() {
  cd "${test_project_dir}" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is not called" \
    0 \
    "${exit_count}"
}

function test_calls_exit_function_if_exiting_project() {
  cd "${test_project_dir}" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project
  cd "${test_root}" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called" \
    1 \
    "${exit_count}"
}

function test_calls_exit_function_only_once_if_exiting_project() {
  cd "${test_project_dir}" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project
  cd "${test_root}" || exit
  __env_hooker_run_env_hook .dummyproject dummy_project
  __env_hooker_run_env_hook .dummyproject dummy_project

  assertEquals \
    "is called exactly once" \
    1 \
    "${exit_count}"
}

# shellcheck source=/dev/null
SHUNIT_PARENT=${0} . ${SHUNIT2}
