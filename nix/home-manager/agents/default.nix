# Top-level entry point for agent tooling.
# This is the only .nix file at this directory level by design --
# everything else is grouped into purpose-named subdirectories:
#   claude/       Claude Code runtime config
#   codex/        Codex CLI runtime config
#   shared/       cross-runtime data (deny rules, MCP servers, install
#                 manifest, agent-skills installer)
#   subagents/    committed Claude/Codex native reviewer agent files
#   skills/       hand-authored skills (agent-harness-engineering, runtime
#                 config optimizers, etc.)
#   scripts/      hook + statusline scripts
#
# See README.md for the editing map.
{
  ...
}:
{
  imports = [
    ./shared/agent-skills.nix
    ./claude
    ./codex
  ];
}
