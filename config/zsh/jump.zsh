#!/usr/bin/env zsh
# shellcheck disable=all

# zoxide-backed jump commands
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --no-cmd)"
fi

__vde_worktree_query_paths() {
  command -v ghq &>/dev/null || return 0
  command -v jq &>/dev/null || return 0
  command -v vde-worktree &>/dev/null || return 0

  ghq list -p | while IFS= read -r repo_path; do
    [[ -n "$repo_path" ]] || continue
    [[ -f "$repo_path/config/vde/worktree/config.yml" ]] || continue

    local repo_json
    repo_json="$(
      command zsh -fc 'cd "$1" && vde-worktree list --json 2>/dev/null' zsh "$repo_path"
    )" || continue

    printf '%s\n' "$repo_json" | jq -r --arg repo_path "$repo_path" '
      .worktrees[]
      | select(.path != $repo_path)
      | .path // empty
    '
  done
}

__z_query_paths() {
  {
    zoxide query --list 2>/dev/null || true
    ghq list -p 2>/dev/null || true
    __vde_worktree_query_paths
  } | awk '!seen[$0]++ { print; fflush() }'
}

__z_query_rows() {
  {
    zoxide query --list --score 2>/dev/null | awk '
      NF == 0 { next }
      {
        path = $0
        sub(/^[[:space:]]*[0-9.]+[[:space:]]+/, "", path)
        print path "\t" $1 "\tzoxide"
      }
    '
    ghq list -p 2>/dev/null | awk 'NF { print $0 "\t-\tghq" }'
    __vde_worktree_query_paths | awk 'NF { print $0 "\t-\tworktree" }'
  } | awk -F '\t' '
    {
      path = $1
      score = $2
      source = $3

      if (!(path in seen)) {
        seen[path] = 1
        order[++count] = path
        scores[path] = score
        sources[path] = source
        next
      }

      if (scores[path] == "-" && score != "-") {
        scores[path] = score
      }

      split(sources[path], existing, /\+/)
      already_present = 0
      for (i in existing) {
        if (existing[i] == source) {
          already_present = 1
          break
        }
      }

      if (!already_present) {
        sources[path] = sources[path] "+" source
      }
    }
    END {
      for (i = 1; i <= count; i++) {
        path = order[i]
        print scores[path] "\t" sources[path] "\t" path
      }
    }
  '
}

zi() {
  local selected_row
  local selected_path
  selected_row="$(
    __z_query_rows |
      fzf --layout=reverse --no-sort --height='~15' \
        --delimiter=$'\t' \
        --nth='2,3' \
        --header=$'score\tsource\tpath' \
        --query="$*"
  )" || return $?

  [[ -n "$selected_row" ]] || return 1
  selected_path="${selected_row#*$'\t'}"
  selected_path="${selected_path#*$'\t'}"
  [[ -n "$selected_path" ]] || return 1
  cd "$selected_path" || return $?
}

z() {
  if [[ "$#" -eq 0 ]]; then
    zi
    return $?
  fi

  if [[ "$#" -eq 1 ]]; then
    if [[ "$1" == "-" ]]; then
      cd - || return $?
      return $?
    fi

    if [[ -d "$1" ]]; then
      cd "$1" || return $?
      return $?
    fi

    local target_path
    target_path="$(zoxide query --exclude "$PWD" -- "$1" 2>/dev/null)" || {
      zi "$1"
      return $?
    }

    [[ -n "$target_path" ]] || {
      zi "$1"
      return $?
    }

    cd "$target_path" || return $?
    return $?
  fi

  zi "$@"
}
