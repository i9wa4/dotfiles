#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

# What: classify auto-generated Nix GC roots and directly unlink current CANDIDATE roots.
# When: run through gc-roots-delete before manual Nix store cleanup to remove only guarded stale candidates.
# Example: nix run '.#gc-roots-delete'

usage() {
  cat <<'EOF'
Usage: list-stale-nix-gcroots.sh

Behavior:
  Re-classify auto GC roots as KEEP, CANDIDATE, or BLOCKED
  Re-exec directly under sudo when deletion is needed
  Unlink only current CANDIDATE symlink roots
  Run nix-collect-garbage after candidate deletion

Examples:
  nix run '.#gc-roots-delete'
  sudo ./bin/ubuntu/list-stale-nix-gcroots.sh
EOF
}

REAL_USER="${SUDO_USER:-$(id -un)}"

safe_text() {
  value="$1"

  if [[ -z $value ]]; then
    return
  fi

  printf '%q' "$value"
}

run_as_real_user() {
  if [[ $EUID -eq 0 && $REAL_USER != root ]]; then
    runuser -u "$REAL_USER" -- "$@"
  else
    "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "ERROR: Unknown argument: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
  shift
done

if [[ $EUID -ne 0 ]]; then
  echo "INFO: gc-roots-delete re-executes this script via sudo so root-context Nix features are not required." >&2
  exec sudo -- "$BASH" "$0" "$@"
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

active_paths_file="${tmp_dir}/active-paths.txt"
roots_file="${tmp_dir}/roots.txt"
output_file="${tmp_dir}/output.tsv"
sorted_output_file="${tmp_dir}/sorted-output.tsv"

: >"$active_paths_file"
: >"$roots_file"
: >"$output_file"
: >"$sorted_output_file"

find /nix/var/nix/gcroots/auto -maxdepth 1 -type l | sort >"$roots_file"

discover_repo_root() {
  candidate_repo=""

  candidate_repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n $candidate_repo && -f $candidate_repo/config/vde/worktree/config.yml ]]; then
    printf '%s\n' "$candidate_repo"
    return 0
  fi

  while IFS= read -r root_path; do
    candidate_link="$(readlink "$root_path" 2>/dev/null || true)"

    case "$candidate_link" in
    *"/.worktrees/"*)
      candidate_repo="${candidate_link%%/.worktrees/*}"
      if [[ -f $candidate_repo/config/vde/worktree/config.yml ]]; then
        printf '%s\n' "$candidate_repo"
        return 0
      fi
      ;;
    esac
  done <"$roots_file"

  return 1
}

run_repo_vde_worktree_list() {
  if [[ -z ${REPO_ROOT:-} ]]; then
    return 1
  fi

  if [[ $EUID -eq 0 && $REAL_USER != root ]]; then
    # shellcheck disable=SC2016
    runuser -u "$REAL_USER" -- sh -c 'cd "$1" && vde-worktree list --json' sh "$REPO_ROOT"
  else
    { cd "$REPO_ROOT" && vde-worktree list --json; }
  fi
}

REPO_ROOT="$(discover_repo_root || true)"

if [[ -n $REPO_ROOT ]]; then
  {
    run_as_real_user git -C "$REPO_ROOT" worktree list --porcelain | awk '
      /^worktree / { print substr($0, 10) }
    '
  } >>"$active_paths_file"

  if command -v vde-worktree >/dev/null 2>&1; then
    { run_repo_vde_worktree_list 2>/dev/null | jq -r '.worktrees[]?.path // empty'; } >>"$active_paths_file" || true
  fi
fi

sort -u "$active_paths_file" -o "$active_paths_file"

is_active_worktree_path() {
  candidate_path="$1"

  while IFS= read -r active_path; do
    if [[ -z $active_path ]]; then
      continue
    fi

    if [[ $candidate_path == "$active_path" || $candidate_path == "$active_path/"* ]]; then
      return 0
    fi
  done <"$active_paths_file"

  return 1
}

classify_root() {
  root_path="$1"
  link_path="$2"

  base_name="$(basename "$link_path")"

  if [[ $base_name == home-manager-* || $base_name == profile-* ]]; then
    printf 'KEEP\tnix-profile-generation'
    return
  fi

  case "$link_path" in
  */.local/state/home-manager/gcroots/current-home)
    printf 'BLOCKED\tprotected-current-home-path'
    return
    ;;
  */.direnv/*)
    printf 'BLOCKED\tprotected-direnv-path'
    return
    ;;
  */result | */result-* | */result/*)
    printf 'BLOCKED\tprotected-result-path'
    return
    ;;
  /tmp/*)
    printf 'BLOCKED\tprotected-temp-path'
    return
    ;;
  esac

  if [[ -n $link_path ]] && is_active_worktree_path "$link_path"; then
    printf 'BLOCKED\tactive-worktree-path'
    return
  fi

  if [[ -n $link_path && -e $link_path ]]; then
    printf 'KEEP\tlive-link-path'
    return
  fi

  if [[ $link_path == *"/.worktrees/"* ]]; then
    printf 'CANDIDATE\tmissing-worktree-path'
    return
  fi

  printf 'CANDIDATE\tmissing-link-path'
}

delete_count=0
candidate_count=0
keep_count=0
blocked_count=0

while IFS= read -r root_path; do
  link_path="$(readlink "$root_path" 2>/dev/null || true)"
  target_path="$(readlink -f "$root_path" 2>/dev/null || true)"

  read -r state reason <<EOF
$(classify_root "$root_path" "$link_path")
EOF

  case "$state" in
  KEEP)
    keep_count=$((keep_count + 1))
    ;;
  CANDIDATE)
    candidate_count=$((candidate_count + 1))
    ;;
  BLOCKED)
    blocked_count=$((blocked_count + 1))
    ;;
  esac

  printf '%s\t%s\t%s\t%s\t%s\n' "$state" "$reason" "$root_path" "$link_path" "$target_path" >>"$output_file"

  if [[ $state == CANDIDATE ]]; then
    echo "DELETE root=$(safe_text "$root_path") link=$(safe_text "$link_path") reason=$(safe_text "$reason")"
    unlink "$root_path"
    delete_count=$((delete_count + 1))
  fi
done <"$roots_file"

sort -t $'\t' -k1,1 -k2,2 -k3,3 "$output_file" >"$sorted_output_file"
while IFS=$'\t' read -r state reason root_path link_path target_path; do
  printf '%s reason=%s root=%s link=%s target=%s\n' \
    "$state" \
    "$(safe_text "$reason")" \
    "$(safe_text "$root_path")" \
    "$(safe_text "$link_path")" \
    "$(safe_text "$target_path")"
done <"$sorted_output_file"

echo "SUMMARY keep=${keep_count} candidate=${candidate_count} blocked=${blocked_count}"
echo "GC start deleted_roots=${delete_count}"
/nix/var/nix/profiles/default/bin/nix-collect-garbage
echo "GC done deleted_roots=${delete_count}"
