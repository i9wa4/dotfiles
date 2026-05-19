#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

script_path=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/issue-worktree-create
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mock_bin="${tmp_dir}/bin"
origin="${tmp_dir}/origin.git"
repo="${tmp_dir}/repo"
log_file="${tmp_dir}/issue-worktree-create-current-branch-smoke.log"
mkdir -p "$mock_bin"

cat >"${mock_bin}/gh" <<'EOF'
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ ${1:-} == "issue" && ${2:-} == "view" && ${3:-} == "999" ]]; then
  printf '%s\n' '{"title":"Use current branch as base","body":"","comments":[]}'
  exit 0
fi

printf 'unexpected gh invocation: %s\n' "$*" >&2
exit 1
EOF

cat >"${mock_bin}/claude" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "current-branch-smoke"
EOF

cat >"${mock_bin}/repo-setup" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

cat >"${mock_bin}/zoxide" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

chmod +x "${mock_bin}/gh" "${mock_bin}/claude" "${mock_bin}/repo-setup" "${mock_bin}/zoxide"

git init --bare "$origin" >/dev/null
git init "$repo" >/dev/null
git -C "$repo" config user.name "Smoke Test"
git -C "$repo" config user.email "smoke@example.com"
git -C "$repo" branch -M main
git -C "$repo" remote add origin "$origin"

printf '%s\n' "base" >"${repo}/tracked.txt"
git -C "$repo" add tracked.txt
git -C "$repo" commit -m "base" >/dev/null
git -C "$repo" push -u origin main >/dev/null

git -C "$repo" switch -c stack-base >/dev/null
printf '%s\n' "stack base" >"${repo}/feature.txt"
git -C "$repo" add feature.txt
git -C "$repo" commit -m "stack base" >/dev/null

cd "$repo"
PATH="${mock_bin}:${PATH}" "$script_path" 999 >"$log_file"

expected_commit=$(git -C "$repo" rev-parse stack-base)
actual_commit=$(git -C "$repo" rev-parse issue-999-current-branch-smoke)

if [[ $actual_commit != "$expected_commit" ]]; then
  printf 'expected new issue branch at %s, got %s\n' "$expected_commit" "$actual_commit" >&2
  exit 1
fi

if [[ ! -f "${repo}/.worktrees/issue-999-current-branch-smoke/feature.txt" ]]; then
  printf 'expected issue worktree to contain current-branch file\n' >&2
  exit 1
fi

if ! rg -q 'Created local branch: issue-999-current-branch-smoke \(from stack-base\)' "$log_file"; then
  printf 'expected creation output to name stack-base as the source branch\n' >&2
  exit 1
fi

printf '%s\n' "issue-worktree-create current-branch smoke passed"
