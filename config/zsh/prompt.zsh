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

precmd() {
  local context="$(_get_context_line)"
  PROMPT=$'\n'"${context}[%D{%Y-%m-%d %H:%M:%S}] %S[\$(_get_simplified_path)]%s \$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)"$'\n$ '
}
