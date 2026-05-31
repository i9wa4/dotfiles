#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

echo "Generating Codex CLI config..."

: "${CODEX_BASE_CONFIG:?CODEX_BASE_CONFIG is required}"
: "${CODEX_GENERATE_CONFIG_PY:?CODEX_GENERATE_CONFIG_PY is required}"
: "${CODEX_GHQ_ROOT:?CODEX_GHQ_ROOT is required}"
: "${CODEX_MANAGED_END:?CODEX_MANAGED_END is required}"
: "${CODEX_MANAGED_START:?CODEX_MANAGED_START is required}"
: "${CODEX_OUTPUT:?CODEX_OUTPUT is required}"

repo_list="$(mktemp)"
trap 'rm -f "$repo_list"' EXIT
mkdir -p "$(dirname "$CODEX_OUTPUT")"
: >"$repo_list"

# Match both .git directories (main repos) and .git files (worktrees, submodules).
# max-depth 7 covers ~/ghq/<host>/<org>/<repo>/.worktrees/<branch>/.git (depth 6) with margin.
# NOTE: Codex CLI's project_trust_key() normalizes via Rust PathBuf.to_string_lossy(),
# which strips trailing slashes. The TOML key must match exactly (no trailing slash)
# or else HashMap<String, ProjectConfig> lookup misses and the trust prompt re-appears.
{
  fd --hidden --no-ignore "^\.git$" "$CODEX_GHQ_ROOT" --max-depth 7 2>/dev/null |
    sort |
    while read -r gitdir; do
      repo=$(dirname "$gitdir")
      case "$repo" in
      *\"* | *\\*)
        echo "WARNING: skipping repo path unsafe for TOML quoted keys: $repo" >&2
        continue
        ;;
      esac
      printf '%s\n' "$repo"
    done
} >"$repo_list"

CODEX_REPO_LIST="$repo_list" python3 "$CODEX_GENERATE_CONFIG_PY"

chmod 644 "$CODEX_OUTPUT"
trap - EXIT
rm -f "$repo_list"
echo "Generated: $CODEX_OUTPUT"
