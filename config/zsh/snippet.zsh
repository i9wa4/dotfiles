#!/usr/bin/env zsh
# shellcheck disable=all

typeset -ga __snippet_names
typeset -ga __snippet_keywords
typeset -ga __snippet_bodies
typeset -ga __snippet_contexts

__snippet_add() {
  __snippet_names+=("$1")
  __snippet_keywords+=("$2")
  __snippet_bodies+=("$3")
  __snippet_contexts+=("$4")
}

if command ls --time-style=long-iso -d . >/dev/null 2>&1; then
  __snippet_ll_body='ls -aFlv --color=always --time-style=long-iso -h'
else
  __snippet_ll_body='/bin/ls -aFlv --color=always -D "%Y-%m-%d %H:%M:%S" -h'
fi
__snippet_add "ll" "ll" "$__snippet_ll_body" ""
unset __snippet_ll_body
__snippet_add "(AWS) profile" "p" "--profile \$(aws configure list-profiles | fzf)" "^aws[[:space:]]"
__snippet_add "(Git) graph --all" "la" "log --graph --format='%C(auto)%h%C(auto)%d %C(auto)%s%n%C(brightblack)[%ai] %C(green)<%an> %C(brightblack)<%ae>' --name-status --all" "^git[[:space:]]"
__snippet_add "(Git) graph" "lo" "log --graph --format='%C(auto)%h%C(auto)%d %C(auto)%s%n%C(brightblack)[%ai] %C(green)<%an> %C(brightblack)<%ae>' --name-status" "^git[[:space:]]"
__snippet_add "(ghq) update" "gup" "ghq-repo-repair && ghq list | ghq get --update --parallel && ghq-repo-status" ""
__snippet_add "(macOS) caffeinate" "caffeinate" "sudo pmset disablesleep" ""
__snippet_add "(vde-layout) dev" "vd" "vde-layout dev" ""
__snippet_add "(vde-layout) main" "vm" "vde-layout main" ""
# Team boot fixes native session_path once, before any team role is started.
# It neither injects a model prompt nor changes roots during later navigation.
__snippet_vde_team() {
  local preset="$1"
  case "$preset" in
    preset-p|preset-w) ;;
    *) print -u2 -- "Unsupported team preset: $preset"; return 1 ;;
  esac
  local native_socket="${TMUX%%,*}"
  local native_pane="$TMUX_PANE"
  if [[ "$native_socket" != /* || ! "$native_pane" =~ '^%[0-9]+$' ]]; then
    print -u2 -- "Start the team inside its target tmux pane."
    return 1
  fi
  local native_session workspace_directory previous_directory titles pane_title
  native_session=$(command tmux -S "$native_socket" display-message -p -t "$native_pane" '#{session_id}') || return $?
  [[ "$native_session" =~ '^\$[0-9]+$' ]] || return 1
  workspace_directory=$(builtin pwd -P) || return $?
  previous_directory=$(command tmux -S "$native_socket" display-message -p -t "$native_pane" '#{session_path}') || return $?
  titles=$(command tmux -S "$native_socket" list-panes -s -t "$native_session" -F '#{pane_title}') || return $?
  for pane_title in "${(@f)titles}"; do
    case "$pane_title" in
      messenger|orchestrator|worker|worker-alt|approver|guardian|critic)
        print -u2 -- "A team role already exists in this session; do not rebind or start a duplicate team."
        return 1
        ;;
      agent)
        if [[ "$previous_directory" != "$workspace_directory" ]]; then
          print -u2 -- "An agent already exists; start a fresh session in the intended directory instead of rebinding it."
          return 1
        fi
        ;;
    esac
  done
  # A finite control client updates the native directory without attaching the
  # user's terminal, changing environment/size, or remaining resident.
  command tmux -S "$native_socket" -C attach-session -E \
    -f ignore-size,read-only,no-output -t "$native_session" \
    -c "$workspace_directory" </dev/null >/dev/null || return $?
  local verified_directory
  verified_directory=$(command tmux -S "$native_socket" display-message -p -t "$native_pane" '#{session_path}') || return $?
  if [[ "$verified_directory" != "$workspace_directory" ]]; then
    print -u2 -- "The tmux session directory did not match the requested workspace."
    return 1
  fi
  command vde-layout "$preset"
}

__snippet_add "(vde-layout) preset-p" "vp" "__snippet_vde_team preset-p" ""
__snippet_add "(vde-layout) preset-w" "vw" "__snippet_vde_team preset-w" ""

__snippet_find_index() {
  local keyword="$1"
  local lbuffer="$2"
  local context i

  for i in {1..$#__snippet_keywords}; do
    [[ "${__snippet_keywords[$i]}" == "$keyword" ]] || continue

    context="${__snippet_contexts[$i]}"
    if [[ -z "$context" || "$lbuffer" =~ $context ]]; then
      REPLY="$i"
      return 0
    fi
  done

  return 1
}

__snippet_expand() {
  local suffix="${1:-}"
  local keyword prefix index

  keyword="${LBUFFER##*[[:space:]]}"
  [[ -n "$keyword" ]] || return 1

  prefix="${LBUFFER[1,$(( ${#LBUFFER} - ${#keyword} ))]}"
  __snippet_find_index "$keyword" "$LBUFFER" || return 1
  index="$REPLY"

  LBUFFER="${prefix}${__snippet_bodies[$index]}${suffix}"
  return 0
}

__snippet_magic_space() {
  if __snippet_expand " "; then
    zle redisplay
  else
    zle self-insert
  fi
}

__snippet_accept_line() {
  __snippet_expand
  zle accept-line
}

__snippet_insert() {
  local selected index

  if ! command -v fzf &>/dev/null; then
    zle reset-prompt
    return 1
  fi

  selected="$(
    for index in {1..$#__snippet_names}; do
      printf '%s\t%-12s %s\t%s\n' \
        "$index" \
        "${__snippet_keywords[$index]}" \
        "${__snippet_names[$index]}" \
        "${__snippet_bodies[$index]}"
    done |
      fzf \
        --layout=reverse \
        --height='~50%' \
        --prompt='snippet> ' \
        --delimiter=$'\t' \
        --with-nth=2 \
        --preview='printf "%s\n" {3}' \
        --preview-window='down,3,wrap'
  )" || {
    zle reset-prompt
    return $?
  }

  index="${selected%%$'\t'*}"
  [[ -n "$index" ]] || {
    zle reset-prompt
    return 1
  }

  LBUFFER+="${__snippet_bodies[$index]}"
  zle reset-prompt
}

zle -N snippet-magic-space __snippet_magic_space
zle -N snippet-accept-line __snippet_accept_line
zle -N snippet-insert __snippet_insert

bindkey " " snippet-magic-space
bindkey "^m" snippet-accept-line
bindkey "^x^i" snippet-insert
