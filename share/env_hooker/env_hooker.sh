# shellcheck shell=bash
# vi: set ft=sh:

ENV_HOOKER_HOOKS=()

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

function __env_hooker_has_entered_hook() {
  local -r hook_root=$1
  local -r marker=ENV_HOOK_ENTERED_${hook_root}

  eval "[[ -n \"\$$marker\" ]]"
}

function __env_hooker_mark_entered() {
  local -r hook_root=$1
  local -r entered_dir=$2
  local -r marker=ENV_HOOK_ENTERED_${hook_root}

  eval "${marker}=${entered_dir}"
}

function __env_hooker_mark_exited() {
  local -r hook_root=$1
  local -r marker=ENV_HOOK_ENTERED_${hook_root}

  eval "unset $marker"
}

function __env_hooker_run_env_hook {
  local -r hook_file=$1
  local -r hook_function_root=$2
  local -r enter_hook=enter_${hook_function_root}
  local -r exit_hook=exit_${hook_function_root}

  local current_dir="$PWD"

  until [[ -z "${current_dir}" ]]; do
    if [[ -f "${current_dir}/${hook_file}" ]]; then
      __env_hooker_has_entered_hook "$hook_function_root" && return
      __env_hooker_mark_entered "$hook_function_root" "$current_dir"

      ${enter_hook} "${current_dir}"
      return
    fi

    current_dir="${current_dir%/*}"
  done

  if __env_hooker_has_entered_hook "$hook_function_root"; then
    __env_hooker_mark_exited "$hook_function_root"

    ${exit_hook}
  fi
}

function __env_hooker_run_env_hooks {
  local hook

  for hook in "${ENV_HOOKER_HOOKS[@]}"; do
    __env_hooker_run_env_hook "${hook}"
  done
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

  ENV_HOOKER_HOOKS+=("${hook_file} ${hook_function_root}")
}

if [[ -n "$ZSH_VERSION" ]]; then
  if [[ ! "$preexec_functions" == *__env_hooker_run_env_hooks* ]]; then
    preexec_functions+=("__env_hooker_run_env_hooks")
  fi
elif [[ -n "$BASH_VERSION" ]]; then
  trap '[[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]] && __env_hooker_run_env_hooks' DEBUG
fi
