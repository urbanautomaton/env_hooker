# shellcheck shell=bash
# vi: set ft=sh:

function __env_hooker_command_exists() {
  type -t "$1" >/dev/null
}

function __env_hooker_usage() {
  cat >&2 <<EOS
Usage: register_env_hook <hook_file_name> <hook_function_root>

  <hook_file_name>     - the file whose presence will trigger the hook
  <hook_function_root> - the suffix for the hook functions
EOS
}

function __env_hooker_add_env_handler() {
  local -r handler=$1

  if [[ -n "$__ENV_HOOKER_HANDLERS" ]]; then
    __ENV_HOOKER_HANDLERS="$__ENV_HOOKER_HANDLERS && $handler"
  else
    __ENV_HOOKER_HANDLERS=$handler
  fi
}

function __env_hooker_run_env_hook {
  local -r hook_file=$1
  local -r hook_function_root=$2
  local -r enter_hook=enter_${hook_function_root}
  local -r exit_hook=exit_${hook_function_root}
  local -r marker=ENV_HOOK_ENTERED_${hook_function_root}
  local entered=""

  eval "entered=\$$marker"

  local current_dir="$PWD"

  until [[ -z "${current_dir}" ]]; do
    if [[ -f "${current_dir}/${hook_file}" ]]; then
      [[ -n "$entered" ]] && return
      eval "${marker}=${current_dir}"
      ${enter_hook} "${current_dir}"
      return
    fi

    current_dir="${current_dir%/*}"
  done

  if [[ -n "$entered" ]]; then
    eval "unset $marker"
    ${exit_hook}
  fi
}

function register_env_hook {
  local -r hook_file=$1
  local -r hook_function_root=$2
  local -r enter_hook=enter_${hook_function_root}
  local -r exit_hook=exit_${hook_function_root}

  if [[ ! -n "$hook_file" || ! -n "$hook_function_root" ]]; then
    __env_hooker_usage
    return
  fi

  if ! __env_hooker_command_exists "${enter_hook}" || ! __env_hooker_command_exists "${exit_hook}"; then
    cat >&2 <<EOS
Error: functions ${enter_hook}() and ${exit_hook}() must be defined before
registering this hook

EOS
    __env_hooker_usage
    return
  fi

  __env_hooker_add_env_handler "__env_hooker_run_env_hook ${hook_file} ${hook_function_root}"
}

function attach_env_hooks() {
  [[ -z "$__ENV_HOOKER_HANDLERS" ]] && return

  echo "$__ENV_HOOKER_HANDLERS"
  if [[ -n "$ZSH_VERSION" ]]; then
    if [[ -n "$__ENV_HOOKER_HANDLERS" ]]; then
      preexec_functions+=("$__ENV_HOOKER_HANDLERS")
    fi
  elif [[ -n "$BASH_VERSION" ]]; then
    if [[ -n "$__ENV_HOOKER_HANDLERS" ]]; then
      # shellcheck disable=SC2016
      prompt_test='[[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]]'
      # shellcheck disable=SC2064
      trap "$prompt_test && $__ENV_HOOKER_HANDLERS" DEBUG
    fi
  fi
}
