#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

repo_root="$(git rev-parse --show-toplevel)"
script="${repo_root}/bin/issue-worktree-create"
tmp_dir="$(mktemp -d)"
origin_dir="${tmp_dir}/origin.git"
repo_dir="${tmp_dir}/repo"
fake_bin="${tmp_dir}/bin"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

mkdir -p "${fake_bin}"
cat >"${fake_bin}/gh" <<'GH'
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $1 == "issue" && $2 == "view" ]]; then
  printf '{"title":"Publication safety smoke","body":"","comments":[]}\n'
  exit 0
fi

echo "unexpected gh invocation: $*" >&2
exit 1
GH
chmod 0755 "${fake_bin}/gh"
cat >"${fake_bin}/claude" <<'CLAUDE'
#!/usr/bin/env bash
exit 1
CLAUDE
chmod 0755 "${fake_bin}/claude"
cat >"${fake_bin}/repo-setup" <<'REPOSETUP'
#!/usr/bin/env bash
exit 0
REPOSETUP
chmod 0755 "${fake_bin}/repo-setup"
cat >"${fake_bin}/zoxide" <<'ZOXIDE'
#!/usr/bin/env bash
exit 0
ZOXIDE
chmod 0755 "${fake_bin}/zoxide"

git init -q "${repo_dir}"
cd "${repo_dir}"
git config user.email "test@example.invalid"
git config user.name "Test User"
touch README.md
git add README.md
git commit -qm "test: initial"
git branch -M main
git clone --bare -q "${repo_dir}" "${origin_dir}"
git remote add origin "${origin_dir}"
git fetch -q origin main
git branch --track issue-999 origin/main >/dev/null
git config push.autoSetupRemote false
git config push.default simple

output_file="${tmp_dir}/issue-worktree-create.out"
PATH="${fake_bin}:${PATH}" "${script}" 999 >"${output_file}" 2>&1

if [[ -d "${repo_dir}/.worktrees/issue-999" ]]; then
  echo "FAIL: unsafe issue worktree was created" >&2
  cat "${output_file}" >&2
  exit 1
fi

if ! grep -Fq "tracks protected shared upstream 'origin/main'" "${output_file}"; then
  echo "FAIL: missing protected upstream error" >&2
  cat "${output_file}" >&2
  exit 1
fi

git branch --unset-upstream issue-999
PATH="${fake_bin}:${PATH}" "${script}" 999 >"${output_file}" 2>&1

if [[ ! -d "${repo_dir}/.worktrees/issue-999" ]]; then
  echo "FAIL: safe local issue worktree was not created" >&2
  cat "${output_file}" >&2
  exit 1
fi

upstream="$(git for-each-ref --format='%(upstream:short)' refs/heads/issue-999)"
if [[ -n ${upstream} ]]; then
  echo "FAIL: local issue branch unexpectedly has upstream '${upstream}'" >&2
  exit 1
fi

echo "issue-worktree-create publication safety smoke checks passed"
