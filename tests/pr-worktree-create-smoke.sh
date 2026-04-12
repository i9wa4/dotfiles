#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <fixture-json>" >&2
  exit 1
fi

fixture_path=$1
repo_root=$(git rev-parse --show-toplevel)
tmp_dir=$(mktemp -d)
mock_bin="${tmp_dir}/bin"
mock_repo_root="${tmp_dir}/repo"
mock_refs_dir="${tmp_dir}/refs"
mock_worktree_root="${tmp_dir}/worktrees"
output_file="${tmp_dir}/output.txt"
trap 'rm -rf "${tmp_dir}"' EXIT

mkdir -p "${mock_bin}" "${mock_repo_root}" "${mock_refs_dir}" "${mock_worktree_root}"

cat <<'EOF' > "${mock_bin}/gh"
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
python - "${PR_WORKTREE_SMOKE_FIXTURE}" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    data = json.load(handle)

print(
    f"{data['headRefName']}\t"
    f"{data['headRepositoryOwner']['login']}\t"
    f"{data['headRepository']['name']}\t"
    f"{str(data['isCrossRepository']).lower()}"
)
PY
EOF

cat <<'EOF' > "${mock_bin}/git"
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $1 == "rev-parse" && $2 == "--show-toplevel" ]]; then
  printf '%s\n' "${PR_WORKTREE_SMOKE_REPO_ROOT}"
  exit 0
fi

if [[ $1 == "rev-parse" && $2 == "--abbrev-ref" && $3 == "HEAD" ]]; then
  printf '%s\n' "topic/current"
  exit 0
fi

if [[ $1 == "fetch" && $2 == "origin" && $# -eq 2 ]]; then
  exit 0
fi

if [[ $1 == "show-ref" && $2 == "--verify" && $3 == "--quiet" ]]; then
  ref_file="${PR_WORKTREE_SMOKE_REFS_DIR}/${4//\//__}"
  if [[ -f "${ref_file}" ]]; then
    exit 0
  fi

  exit 1
fi

if [[ $1 == "fetch" && $# -eq 3 ]]; then
  printf 'MOCK_FETCH %s %s\n' "$2" "$3"
  local_ref=${3#*:}
  touch "${PR_WORKTREE_SMOKE_REFS_DIR}/refs__heads__${local_ref}"
  exit 0
fi

if [[ $1 == "pull" && $2 == "--ff-only" && $3 == "origin" && $4 == "main" ]]; then
  exit 0
fi

echo "unexpected git command: $*" >&2
exit 1
EOF

cat <<'EOF' > "${mock_bin}/vde-worktree"
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $1 == "path" ]]; then
  exit 1
fi

if [[ $1 == "switch" ]]; then
  worktree_path="${PR_WORKTREE_SMOKE_WORKTREE_ROOT}/$2"
  mkdir -p "${worktree_path}"
  printf '%s\n' "${worktree_path}"
  exit 0
fi

echo "unexpected vde-worktree command: $*" >&2
exit 1
EOF

cat <<'EOF' > "${mock_bin}/repo-setup"
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
printf '%s\n' "MOCK_REPO_SETUP"
EOF

cat <<'EOF' > "${mock_bin}/zoxide"
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
if [[ $1 == "add" ]]; then
  printf '%s\n' "MOCK_ZOXIDE_ADD $2"
  exit 0
fi

echo "unexpected zoxide command: $*" >&2
exit 1
EOF

chmod +x "${mock_bin}/gh" "${mock_bin}/git" "${mock_bin}/vde-worktree" "${mock_bin}/repo-setup" "${mock_bin}/zoxide"

pr_branch=$(jq -r '.headRefName' "${fixture_path}")
is_cross_repo=$(jq -r '.isCrossRepository' "${fixture_path}")
expected_same_repo_target="origin/${pr_branch}"
pr_local_branch="pr-123-${pr_branch//\//-}"

if [[ ${PR_WORKTREE_SMOKE_PRECREATE_LOCAL_BRANCH:-false} == "true" ]]; then
  touch "${mock_refs_dir}/refs__heads__${pr_local_branch}"
fi

if ! PATH="${mock_bin}:${PATH}" \
  PR_WORKTREE_SMOKE_FIXTURE="${fixture_path}" \
  PR_WORKTREE_SMOKE_REPO_ROOT="${mock_repo_root}" \
  PR_WORKTREE_SMOKE_REFS_DIR="${mock_refs_dir}" \
  PR_WORKTREE_SMOKE_WORKTREE_ROOT="${mock_worktree_root}" \
  "${repo_root}/bin/pr-worktree-create" 123 > "${output_file}" 2>&1; then
  cat "${output_file}" >&2
  exit 1
fi

cat "${output_file}"

if ! grep -F "Fetch target:" "${output_file}" >/dev/null; then
  echo "Missing fetch target output" >&2
  exit 1
fi

if [[ "${is_cross_repo}" == "true" ]]; then
  if grep -F "${expected_same_repo_target}" "${output_file}" >/dev/null; then
    echo "Fork PR output still assumes ${expected_same_repo_target}" >&2
    exit 1
  fi
else
  if ! grep -F "${expected_same_repo_target}" "${output_file}" >/dev/null; then
    echo "Same-repo PR output did not include ${expected_same_repo_target}" >&2
    exit 1
  fi
fi

if [[ ${PR_WORKTREE_SMOKE_PRECREATE_LOCAL_BRANCH:-false} == "true" ]]; then
  if ! grep -F "Refreshed local review branch: ${pr_local_branch}" "${output_file}" >/dev/null; then
    echo "Existing local review branch was not refreshed explicitly" >&2
    exit 1
  fi
fi
