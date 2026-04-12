# Agent tooling boundary for frequent switch/update work
{
  pkgs,
  inputs,
  ...
}:
let
  inherit (pkgs) system;
  claude-code = import ../../lib/pinned-claude-code.nix {
    inherit
      pkgs
      inputs
      system
      ;
  };
  codex = import ../../lib/pinned-codex.nix {
    inherit
      pkgs
      inputs
      system
      ;
  };
in
{
  imports = [
    ./agent-skills.nix
    ./claude-code.nix
    ./codex-cli.nix
  ];

  home.packages = [
    claude-code
    codex
    inputs.llm-agents.packages.${pkgs.system}.ccusage
    inputs.llm-agents.packages.${pkgs.system}.ccusage-codex
    inputs.claude-chill.packages.${pkgs.system}.default
    inputs.tmux-a2a-postman.packages.${pkgs.system}.default
  ];
}
