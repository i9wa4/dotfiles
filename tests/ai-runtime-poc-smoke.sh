#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
set -o posix

repo_root=$(git rev-parse --show-toplevel)

if [[ -n ${RUNNER_TEMP:-} ]]; then
  case "${RUNNER_TEMP}" in
  */ai-runtime-poc) runtime_root="${RUNNER_TEMP}" ;;
  *) runtime_root="${RUNNER_TEMP}/ai-runtime-poc" ;;
  esac
else
  runtime_root="${TMPDIR:-/tmp}/ai-runtime-poc"
fi

case "${runtime_root}" in
"${HOME}/.claude" | \
  "${HOME}/.claude/"* | \
  "${HOME}/.codex" | \
  "${HOME}/.codex/"*)
  echo "Disposable runtime root must stay separate from managed user paths: ${runtime_root}" >&2
  exit 1
  ;;
esac

if [[ -e ${runtime_root} ]]; then
  chmod -R u+w "${runtime_root}"
fi

rm -rf "${runtime_root}"
mkdir -p "${runtime_root}"
cd "${repo_root}"

# This POC renders directly into disposable temp output and never activates the
# managed ~/.claude or ~/.codex runtime.
nix_expr=$(
  cat <<'EOF'
let
  flake = builtins.getFlake (toString ./.);
  pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; };
  renderCodexAgents = import ./nix/home-manager/agents/families/render-codex-agents.nix { inherit pkgs; };
  family = import ./nix/home-manager/agents/families/subagents/family.nix {
    inherit
      pkgs
      renderCodexAgents
      ;
  };
in
pkgs.runCommand "ai-runtime-poc" { } ''
  mkdir -p "$out/.claude/agents" "$out/.codex/agents"
  cp -LR ${family.claudeAgentsDir}/. "$out/.claude/agents/"
  cp -LR ${family.codexAgentsDir}/. "$out/.codex/agents/"
''
EOF
)

runtime_store=$(nix build --impure --no-link --print-out-paths --expr "${nix_expr}")
cp -LR "${runtime_store}/." "${runtime_root}/"

claude_agent="${runtime_root}/.claude/agents/researcher-tech.md"
codex_agent="${runtime_root}/.codex/agents/super-codex-reviewer.toml"

test -f "${claude_agent}"
test -f "${codex_agent}"

grep -F 'name: "researcher-tech"' "${claude_agent}" >/dev/null
grep -F 'model: "sonnet"' "${claude_agent}" >/dev/null
grep -F 'Technical research specialist. Verifies claims, compares options, provides' "${claude_agent}" >/dev/null

grep -F 'name = "super-codex-reviewer"' "${codex_agent}" >/dev/null
grep -F 'model = "gpt-5.4"' "${codex_agent}" >/dev/null
grep -F "developer_instructions = '''" "${codex_agent}" >/dev/null
grep -F 'Perfectionist code reviewer. Demands correctness at every level.' "${codex_agent}" >/dev/null

printf 'Disposable runtime root: %s\n' "${runtime_root}"
printf 'Verified Claude agent: %s\n' "${claude_agent}"
printf 'Verified Codex agent: %s\n' "${codex_agent}"
