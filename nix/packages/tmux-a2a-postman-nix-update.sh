#!/usr/bin/env bash
set -euo pipefail

repo="${TMUX_A2A_POSTMAN_REPO:-i9wa4/tmux-a2a-postman}"
target="${TMUX_A2A_POSTMAN_FLAKE_NIX:-flake.nix}"
gh_bin="${TMUX_A2A_POSTMAN_GH:-gh}"
sort_bin="${TMUX_A2A_POSTMAN_SORT:-sort}"

if [[ $repo != */* ]]; then
  echo "tmux-a2a-postman-nix-update: expected OWNER/REPO, got: $repo" >&2
  exit 1
fi

tag="${TMUX_A2A_POSTMAN_TAG:-}"
if [[ -z $tag ]]; then
  tag="$(
    "$gh_bin" api --paginate "repos/$repo/git/matching-refs/tags/v" \
      --jq '.[].ref | sub("^refs/tags/"; "")' |
      awk '/^v[0-9]+\.[0-9]+\.[0-9]+$/ { print }' |
      "$sort_bin" -V |
      tail -n 1
  )"
fi

if [[ -z $tag ]]; then
  echo "tmux-a2a-postman-nix-update: no stable tag found in $repo" >&2
  exit 1
fi

if [[ ! $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "tmux-a2a-postman-nix-update: unsupported tag format: $tag" >&2
  exit 1
fi

if [[ ! -f $target ]]; then
  echo "tmux-a2a-postman-nix-update: target not found: $target" >&2
  exit 1
fi

url="github:${repo}/${tag}"
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

set +e
awk -v url="$url" '
  /^[[:space:]]*tmux-a2a-postman[[:space:]]*=[[:space:]]*\{/ {
    in_target = 1
  }

  in_target && /^[[:space:]]*url[[:space:]]*=/ {
    indent = substr($0, 1, match($0, /[^[:space:]]/) - 1)
    print indent "url = \"" url "\";"
    updated += 1
    next
  }

  in_target && /^[[:space:]]*};/ {
    in_target = 0
  }

  { print }

  END {
    if (updated != 1) {
      exit 42
    }
  }
' "$target" >"$tmp_file"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  if [[ $status -eq 42 ]]; then
    echo "tmux-a2a-postman-nix-update: tmux-a2a-postman input url not found in $target" >&2
  fi
  exit "$status"
fi

if cmp -s "$tmp_file" "$target"; then
  echo "flake.nix already pins tmux-a2a-postman to $tag"
else
  install -m 0644 "$tmp_file" "$target"
  echo "updated $target tmux-a2a-postman input to $tag"
fi
