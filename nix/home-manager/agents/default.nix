# Agent tooling boundary for frequent switch/update work
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./agent-skills.nix
    ./claude-code.nix
    ./codex-cli.nix
  ];

  home.packages = [
    inputs.llm-agents.packages.${pkgs.system}.claude-code
    inputs.llm-agents.packages.${pkgs.system}.codex
    inputs.llm-agents.packages.${pkgs.system}.ccusage
    inputs.llm-agents.packages.${pkgs.system}.ccusage-codex
    inputs.claude-chill.packages.${pkgs.system}.default
    inputs.tmux-a2a-postman.packages.${pkgs.system}.default
  ];
}
