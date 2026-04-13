# AI tool packages from llm-agents.nix (versions come from flake.lock)
# Install with: nix profile add '.#claude-code' etc. (see Makefile nix-profile target)
{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      packages = {
        inherit (inputs.llm-agents.packages.${system})
          claude-code
          codex
          ccusage
          ccusage-codex
          ;
      };
    };
}
