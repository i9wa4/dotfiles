#!/usr/bin/env zsh
# shellcheck disable=all

setopt prompt_subst

function _get_simplified_path() {
  local path="${PWD}"
  path="${path/#$HOME\/ghq\/github.com\//}"
  path="${path/#$HOME/~}"
  echo "${path}"
}

function _get_devshell_indicator() {
  if [[ -n "${IN_NIX_SHELL}" || -n "${DIRENV_DIR}" ]]; then
    local repo_name=""
    if [[ -n "${DIRENV_DIR}" ]]; then
      local dir="${DIRENV_DIR#-}"
      if [[ "${dir}" =~ ghq/github\.com/(.+)$ ]]; then
        repo_name="${match[1]}"
      fi
    fi
    if [[ -n "${repo_name}" ]]; then
      print "❄️${repo_name} "
    else
      print "❄️devShell "
    fi
  fi
}

function _get_aws_profile_indicator() {
  [[ -n "${MY_AWS_PROFILE}" ]] && print -n "🔶${MY_AWS_PROFILE}"
}

function _get_context_line() {
  local devshell="$(_get_devshell_indicator)"
  local aws="$(_get_aws_profile_indicator)"
  print -n "${devshell}${aws}"
}

# SSH connection detection
# if [[ -n "${SSH_CONNECTION}" || -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
#   _IS_LOCAL=0
# else
#   _IS_LOCAL=1
# fi

# Deterministic hex derived from hostname (cksum is POSIX, works on macOS/Linux)
_HOST_HASH=$(printf '%s' "${HOST}" | cksum | awk '{printf "%x", $1}' | cut -c1-3)
_HOST_PREFIX="[${_HOST_HASH}] "

precmd() {
  local context="$(_get_context_line)"
  if [[ -n "${context}" ]]; then
    PROMPT=$'\n'"${context}"$'\n'"${_HOST_PREFIX}[%D{%Y-%m-%d %H:%M:%S}] %S[\$(_get_simplified_path)]%s \$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)"$'\n$ '
  else
    PROMPT=$'\n'"${_HOST_PREFIX}[%D{%Y-%m-%d %H:%M:%S}] %S[\$(_get_simplified_path)]%s \$(${HOME}/ghq/github.com/i9wa4/dotfiles/bin/repo-status)"$'\n$ '
  fi
}
