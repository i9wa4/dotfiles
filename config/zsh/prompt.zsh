#!/usr/bin/env zsh
# shellcheck disable=all

setopt prompt_subst

function _get_simplified_path() {
  local display_path="${PWD}"
  display_path="${display_path/#$HOME\/ghq\/github.com\//}"
  display_path="${display_path/#$HOME/~}"
  echo "${display_path}"
}

function _get_aws_profile_indicator() {
  [[ -n "${MY_AWS_PROFILE}" ]] && print -n "🔶${MY_AWS_PROFILE}"
}

function _get_context_line() {
  local aws="$(_get_aws_profile_indicator)"
  print -n "${aws}"
}

function _get_repo_status() {
  local repo_status_text
  repo_status_text="$(command repo-status 2>/dev/null)"
  [[ -n "${repo_status_text}" ]] && print -n " ${repo_status_text}"
}

precmd() {
  local context="$(_get_context_line)"
  local display_path="$(_get_simplified_path)"
  local repo_status="$(_get_repo_status)"
  PROMPT=$'\n'"${context}[%D{%Y-%m-%d %H:%M:%S}] %S[${display_path}]%s${repo_status}"$'\n$ '
}
