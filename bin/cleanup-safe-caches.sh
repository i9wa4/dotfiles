#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# What: prune only the repo's explicit safe_cache surface for user-owned caches.
# When: run for low-risk reclaim after previewing the listed cache paths.
# Example: CLEANUP_UV="$(command -v uv)" bash ./bin/cleanup-safe-caches.sh --dry-run

dry_run=false

usage() {
  cat <<'EOF'
Usage: cleanup-safe-caches.sh [--dry-run|--preview|--apply]

Behavior:
  Prunes only the repo's explicit safe_cache surface for user-owned caches.
  --dry-run and --preview list the cleanup actions without removing anything.
  --apply is accepted for explicit apply mode; omitting a mode also applies.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run | --preview)
    dry_run=true
    shift
    ;;
  --apply)
    dry_run=false
    shift
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
done

remove_dir() {
  target="$1"

  if [[ -d $target ]]; then
    if [[ $dry_run == true ]]; then
      echo "Would remove $target"
    else
      echo "Removing $target"
      rm -rf "$target"
    fi
  else
    echo "Skipping missing $target"
  fi
}

cleanup_uv="${CLEANUP_UV:-uv}"
cache_root="${XDG_CACHE_HOME:-$HOME/.cache}"
uv_cache_dir="$("$cleanup_uv" cache dir)"

if command -v pgrep >/dev/null 2>&1 && pgrep -x uv >/dev/null 2>&1; then
  echo "Skipping uv cache prune in $uv_cache_dir (active uv process detected)"
else
  if [[ $dry_run == true ]]; then
    echo "Would prune uv cache in $uv_cache_dir"
  else
    echo "Pruning uv cache in $uv_cache_dir"
    "$cleanup_uv" cache prune
  fi
fi

remove_dir "$cache_root/pre-commit"
remove_dir "$cache_root/ruff"

if [[ $(uname -s) == Linux ]]; then
  remove_dir "$cache_root/go-build"
  remove_dir "$cache_root/nix"
fi

remove_dir "$HOME/.npm"

if [[ -d $HOME/Library/Caches ]]; then
  remove_dir "$HOME/Library/Caches/pre-commit"
  remove_dir "$HOME/Library/Caches/ruff"
fi

if [[ $dry_run == true ]]; then
  echo "Cleanup dry run complete; pass --apply or omit --dry-run to remove listed caches."
else
  echo "Cleanup complete."
fi
