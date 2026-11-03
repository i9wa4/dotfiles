#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/gh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${POSTMAN_TEST_LOOKUP_FAIL:-} == 1 ]]; then
  exit 12
fi
cat "$POSTMAN_TEST_RELEASES"
SH
chmod +x "$tmp_dir/gh"

cat >"$tmp_dir/releases.json" <<'JSON'
[
  {"tagName":"v0.10.0","isDraft":false,"isPrerelease":false,"publishedAt":"2026-11-02T15:16:12Z"},
  {"tagName":"v0.99.0-rc.1","isDraft":false,"isPrerelease":true,"publishedAt":"2026-11-04T00:00:00Z"},
  {"tagName":"v0.98.0","isDraft":true,"isPrerelease":false,"publishedAt":"2026-11-04T00:00:00Z"},
  {"tagName":"v0.97.0-test","isDraft":false,"isPrerelease":false,"publishedAt":"2026-11-04T00:00:00Z"},
  {"tagName":"v0.11.0","isDraft":false,"isPrerelease":false,"publishedAt":"2026-11-03T17:28:30Z"}
]
JSON
cat >"$tmp_dir/flake.nix" <<'NIX'
{
  inputs.tmux-a2a-postman = {
    url = "github:i9wa4/tmux-a2a-postman/old-commit";
  };
}
NIX

export POSTMAN_GH="$tmp_dir/gh"
export POSTMAN_TEST_RELEASES="$tmp_dir/releases.json"
export POSTMAN_FLAKE_FILE="$tmp_dir/flake.nix"

bash "$script_dir/input-update-postman.sh"
grep -q 'github:i9wa4/tmux-a2a-postman/v0.11.0' "$POSTMAN_FLAKE_FILE"
cp "$POSTMAN_FLAKE_FILE" "$tmp_dir/after-first-update.nix"
bash "$script_dir/input-update-postman.sh"
cmp "$POSTMAN_FLAKE_FILE" "$tmp_dir/after-first-update.nix"

if POSTMAN_TEST_LOOKUP_FAIL=1 bash "$script_dir/input-update-postman.sh"; then
  echo 'expected release lookup failure' >&2
  exit 1
fi
cmp "$POSTMAN_FLAKE_FILE" "$tmp_dir/after-first-update.nix"

printf '%s\n' '[{"tagName":"v0.12.0-rc.1","isDraft":false,"isPrerelease":true,"publishedAt":"2026-11-04T00:00:00Z"}]' >"$POSTMAN_TEST_RELEASES"
if bash "$script_dir/input-update-postman.sh"; then
  echo 'expected no-stable-release failure' >&2
  exit 1
fi
cmp "$POSTMAN_FLAKE_FILE" "$tmp_dir/after-first-update.nix"
echo 'input-update-postman tests passed'
