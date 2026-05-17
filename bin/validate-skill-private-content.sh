#!/usr/bin/env bash
# Scans Agent Skill cleanup changes for private or non-portable local content.

set -eu

usage() {
  echo "usage: validate-skill-private-content.sh [--report] (--staged|<path>...)" >&2
}

report_only=0
staged=0
paths=

while [ "$#" -gt 0 ]; do
  case "$1" in
  --report)
    report_only=1
    shift
    ;;
  --staged)
    staged=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --*)
    usage
    exit 64
    ;;
  *)
    paths="${paths}${paths:+
}$1"
    shift
    ;;
  esac
done

if [ "$staged" -eq 1 ] && [ -n "$paths" ]; then
  usage
  exit 64
fi

if [ "$staged" -eq 0 ] && [ -z "$paths" ]; then
  usage
  exit 64
fi

path_list=$(mktemp)
file_list=$(mktemp)
findings=$(mktemp)
staged_dir=

cleanup() {
  rm -f "$path_list" "$file_list" "$findings"
  if [ -n "$staged_dir" ]; then
    rm -rf "$staged_dir"
  fi
}

trap cleanup EXIT HUP INT TERM

is_scan_target() {
  case "$1" in
  skills/* | config/tmux-a2a-postman/postman.md | docs/agent-skill-management.md | docs/dotfiles-operating-concepts.md)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

is_text_target() {
  case "$1" in
  */.git/* | .git/*)
    return 1
    ;;
  *.png | *.jpg | *.jpeg | *.gif | *.webp | *.pdf | *.zip | *.gz | *.sqlite | *.db)
    return 1
    ;;
  *)
    return 0
    ;;
  esac
}

append_scan_file() {
  display_path=$1
  scan_path=$2

  if is_text_target "$display_path"; then
    printf '%s\t%s\n' "$display_path" "$scan_path" >>"$file_list"
  fi
}

append_path() {
  path=${1#./}

  case "$path" in
  skills | skills/)
    echo "private-content scan: pass specific skill paths such as skills/<name>, not top-level skills" >&2
    echo "Use --staged for the commit gate or scan named skill directories as cleanup reaches them." >&2
    exit 64
    ;;
  esac

  if ! is_scan_target "$path"; then
    return 0
  fi

  if [ -d "$path" ]; then
    find -L "$path" -type f \
      \( -name 'SKILL.md' -o -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.sh' -o -name '*.py' -o -name '*.mjs' -o -name '*.sql' \) \
      -print | while IFS= read -r file; do
      append_scan_file "$file" "$file"
    done
    return 0
  fi

  if [ -f "$path" ]; then
    append_scan_file "$path" "$path"
  fi
}

append_staged_path() {
  path=${1#./}

  if ! is_scan_target "$path" || ! is_text_target "$path"; then
    return 0
  fi

  scan_path="$staged_dir/$path"
  mkdir -p "$(dirname "$scan_path")"
  if ! git show ":$path" >"$scan_path"; then
    echo "private-content scan: unable to read staged content for $path" >&2
    exit 1
  fi

  append_scan_file "$path" "$scan_path"
}

if [ "$staged" -eq 1 ]; then
  staged_dir=$(mktemp -d)
  git diff --cached --name-only --diff-filter=ACMR >"$path_list"
else
  printf '%s\n' "$paths" >"$path_list"
fi

while IFS= read -r path; do
  [ -n "$path" ] || continue
  if [ "$staged" -eq 1 ]; then
    append_staged_path "$path"
  else
    append_path "$path"
  fi
done <"$path_list"

if [ ! -s "$file_list" ]; then
  echo "private-content scan: no matching Agent Skills cleanup files"
  exit 0
fi

sort -u "$file_list" -o "$file_list"

tab=$(printf '\t')
while IFS="$tab" read -r display_path scan_path; do
  awk -v file="$display_path" '
    function emit(rule) {
      if (allow_current) {
        return
      }
      printf "%s:%d: %s: %s\n", file, FNR, rule, $0
      found = 1
    }
    {
      allow_current = allow_next || ($0 ~ /private-content-scan:[[:space:]]*allow/)
      allow_next = 0

      if (file == "config/tmux-a2a-postman/postman.md" &&
          $0 ~ /^  - path: ~\/ghq\/github.com\/i9wa4\/(dotfiles|tmux-a2a-postman)\/skills\/?$/) {
        next
      }

      if ($0 ~ /\/home\/[[:alnum:]_.-]+\//) {
        emit("home-directory absolute path")
      }
      if ($0 ~ /\/Users\/[[:alnum:]_.-]+\//) {
        emit("home-directory absolute path")
      }
      if ($0 ~ /\/nix\/store\/[[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]][[:alnum:]]/) {
        emit("Nix store runtime path")
      }
      if ($0 ~ /~\/ghq\//) {
        emit("repo clone path under home")
      }
      if ($0 ~ /~\/\.(local\/state|claude|codex|dbt|config\/vde)/) {
        emit("home-directory runtime/config path")
      }
      if ($0 ~ /20[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]-sf[[:alnum:]]+-r[[:alnum:]]+-from-/) {
        emit("copied runtime message id")
      }
      if ($0 ~ /(AKIA|ASIA)[A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9][A-Z0-9]/) {
        emit("account-specific credential token")
      }
      if ($0 ~ /arn:aws:[^:]+:[^:]*:[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]:/) {
        emit("account-specific cloud resource id")
      }
      if ($0 ~ /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\.dkr\.ecr\./) {
        emit("account-specific cloud registry id")
      }

      if ($0 ~ /private-content-scan:[[:space:]]*allow-next-line/) {
        allow_next = 1
      }
    }
    END {
      exit found ? 1 : 0
    }
  ' "$scan_path" >>"$findings" || true
done <"$file_list"

if [ -s "$findings" ]; then
  cat "$findings" >&2
  echo "FAIL: private-content candidates found" >&2
  echo "Fix them, or record why they are intentionally retained and add a private-content-scan allow annotation." >&2
  if [ "$report_only" -eq 1 ]; then
    exit 0
  fi
  exit 1
fi

echo "private-content scan: OK"
