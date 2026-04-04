{
  pkgs,
}:
let
  renderCodexAgents = import ./render-codex-agents.nix { inherit pkgs; };
in
{
  # First adopter: plain subagents. Review stays on the existing path for now
  # and can plug in later as a sibling family without another installer rewrite.
  subagents = import ./subagents/family.nix {
    inherit
      pkgs
      renderCodexAgents
      ;
  };
}
