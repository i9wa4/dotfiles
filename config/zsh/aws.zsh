#!/usr/bin/env zsh
# shellcheck disable=all

# AWS command wrapper (tracks SSO profile)
aws() {
  local profile=""
  local i
  for ((i=1; i<=${#@}; i++)); do
    if [[ "${@[$i]}" == "--profile" ]]; then
      profile="${@[$((i+1))]}"
      break
    fi
  done

  command aws "$@"
  local ret=$?

  if [[ "$1" == "sso" && "$2" == "login" && $ret -eq 0 && -n "$profile" ]]; then
    export MY_AWS_PROFILE="$profile"
  fi

  return $ret
}
