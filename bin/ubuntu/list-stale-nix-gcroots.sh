#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

usage() {
  cat <<'EOF'
Usage: list-stale-nix-gcroots.sh [--dry-run|--delete]

Modes:
  --dry-run  Classify auto GC roots as KEEP, CANDIDATE, or BLOCKED
  --delete   Delete only current CANDIDATE roots, then run nix-collect-garbage
EOF
}

MODE="dry-run"

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    MODE="dry-run"
    ;;
  --delete)
    MODE="delete"
    ;;
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

if [[ $MODE == delete && $EUID -ne 0 ]]; then
  echo "ERROR: --delete requires root so only current CANDIDATE roots can be removed safely." >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

active_paths_file="${tmp_dir}/active-paths.txt"
roots_file="${tmp_dir}/roots.txt"
output_file="${tmp_dir}/output.tsv"

: >"$active_paths_file"
: >"$roots_file"
: >"$output_file"

git worktree list --porcelain | awk '
  /^worktree / { print substr($0, 10) }
' >>"$active_paths_file"

if command -v vde-worktree >/dev/null 2>&1; then
  vde-worktree list --json 2>/dev/null | jq -r '.worktrees[]?.path // empty' >>"$active_paths_file" || true
fi

sort -u "$active_paths_file" -o "$active_paths_file"
find /nix/var/nix/gcroots/auto -maxdepth 1 -type l | sort >"$roots_file"

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

  if [[ $MODE == delete && $state == CANDIDATE ]]; then
    echo "DELETE root=${root_path} link=${link_path} reason=${reason}"
    rm -f "$root_path"
    delete_count=$((delete_count + 1))
  fi
done <"$roots_file"

sort -t $'\t' -k1,1 -k2,2 -k3,3 "$output_file" | awk -F '\t' '
  {
    printf "%s reason=%s root=%s link=%s target=%s\n", $1, $2, $3, $4, $5
  }
'

echo "SUMMARY keep=${keep_count} candidate=${candidate_count} blocked=${blocked_count} mode=${MODE}"

if [[ $MODE == delete ]]; then
  echo "GC start deleted_roots=${delete_count}"
  nix-collect-garbage
  echo "GC done deleted_roots=${delete_count}"
fi
