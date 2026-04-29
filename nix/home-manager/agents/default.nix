# Top-level entry point for agent tooling.
# This is the only .nix file at this directory level by design --
# everything else is grouped into purpose-named subdirectories:
#   claude/       Claude Code runtime config
#   codex/        Codex CLI runtime config
#   shared/       cross-runtime data and builders (deny rules, MCP servers,
#                 install manifest, render-agents, agent-skills installer)
#   subagents/    subagent prompt bodies + _metadata.nix (single SSOT)
#   skills/       hand-authored skills (claude/codex config optimizers,
#                 workspace-trust-fix, etc.)
#   scripts/      hook + statusline scripts
#
# See README.md for the editing map.
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./shared/agent-skills.nix
    ./claude
    ./codex
  ];

  home.packages = [
    inputs.llm-agents.packages.${pkgs.system}.claude-code
    inputs.llm-agents.packages.${pkgs.system}.codex
    inputs.llm-agents.packages.${pkgs.system}.ccusage
    inputs.llm-agents.packages.${pkgs.system}.ccusage-codex
    inputs.tmux-a2a-postman.packages.${pkgs.system}.default
  ];
}
