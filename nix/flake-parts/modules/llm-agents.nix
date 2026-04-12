# AI tool packages from llm-agents.nix (pinned via flake.lock)
# Install with: nix profile add '.#claude-code' etc. (see Makefile nix-profile target)
{ inputs, ... }:
{
  perSystem =
    { system, pkgs, ... }:
    let
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
      packages = {
        inherit
          claude-code
          codex
          ;
        inherit (inputs.llm-agents.packages.${system})
          ccusage
          ccusage-codex
          ;
      };
    };
}
