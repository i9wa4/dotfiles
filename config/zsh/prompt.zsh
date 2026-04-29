#!/usr/bin/env zsh
# shellcheck disable=all

setopt prompt_subst

# SSH connection detection
if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  _IS_LOCAL=0
else
  _IS_LOCAL=1
fi

function _get_simplified_path() {
  local path="${PWD}"
  path="${path/#$HOME\/ghq\/github.com\//}"
  path="${path/#$HOME/~}"
  echo "${path}"
}

function _get_devshell_indicator() {
  if [[ -n "${IN_NIX_SHELL}" || -n "${DIRENV_DIR}" ]]; then
    print -n "💠"
  fi
}

function _get_aws_profile_indicator() {
  [[ -n "${MY_AWS_PROFILE}" ]] && print -n "🔶${MY_AWS_PROFILE}"
}

function _get_context_line() {
  local remote=""
  [[ "${_IS_LOCAL}" -eq 0 ]] && remote="🌐"
  local devshell="$(_get_devshell_indicator)"
  local aws="$(_get_aws_profile_indicator)"
  print -n "${remote}${devshell}${aws}"
}

# typeset -g _PROMPT_REPO_STATUS=""
# typeset -g _PROMPT_REPO_STATUS_PWD=""
# typeset -g _PROMPT_REPO_STATUS_UPDATED_AT=0
#
# function _refresh_repo_status() {
#   if [[ "${PWD}" == "${_PROMPT_REPO_STATUS_PWD}" && $((SECONDS - _PROMPT_REPO_STATUS_UPDATED_AT)) -lt 5 ]]; then
#     return
#   fi
#
#   _PROMPT_REPO_STATUS="$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)"
#   _PROMPT_REPO_STATUS_PWD="${PWD}"
#   _PROMPT_REPO_STATUS_UPDATED_AT=${SECONDS}
# }

precmd() {
  # _refresh_repo_status
  local context="$(_get_context_line)"
  local path="$(_get_simplified_path)"
  # PROMPT=$'\n'"${context}[%D{%Y-%m-%d %H:%M:%S}] %S[${path}]%s ${_PROMPT_REPO_STATUS}"$'\n$ '
  PROMPT=$'\n'"${context}[%D{%Y-%m-%d %H:%M:%S}] %S[${path}]%s"$'\n$ '
}
