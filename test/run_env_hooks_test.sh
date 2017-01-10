# shellcheck shell=bash
# vi: set ft=sh:

. ./test/helper.sh

function enter_dummy_project() {
  entered_dummy_project=${1}
}

function exit_dummy_project() {
  exited_dummy_project=$entered_dummy_project
  unset entered_dummy_project
}

function setUp() {
  cd "${test_root}" || exit
  mkdir -p "${test_project_dir}"
  touch "${test_project_dir}/.dummyproject"
  original_hooks=(${ENV_HOOKER_HOOKS[@]})
  ENV_HOOKER_HOOKS=()
  register_env_hook .dummyproject dummy_project
}

function tearDown() {
  ENV_HOOKER_HOOKS=(${original_hooks[@]})
  rm -rf "${test_project_dir}"
  unset entered_dummy_project \
    exited_dummy_project \
    ENV_HOOKER_ENTERED_dummy_project
}

function test_runs_enter_hook_on_entry() {
  cd "${test_project_dir}" && __env_hooker_run_env_hooks

  assertEquals \
    "runs the enter hook on entry" \
    "${test_project_dir}" \
    "${entered_dummy_project}"
}

function test_runs_exit_hook_on_exit() {
  cd "${test_project_dir}" && __env_hooker_run_env_hooks
  cd "${test_root}" && __env_hooker_run_env_hooks

  assertEquals \
    "runs the exit hook on exit" \
    "${test_project_dir}" \
    "${exited_dummy_project}"
}

# shellcheck source=/dev/null
SHUNIT_PARENT=${0} . ${SHUNIT2}
