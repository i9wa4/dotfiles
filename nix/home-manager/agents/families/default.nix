{
  pkgs,
}:
let
  inherit (pkgs) lib;
  renderCodexAgents = import ./render-codex-agents.nix { inherit pkgs; };
  subagents = import ./subagents/family.nix {
    inherit
      pkgs
      renderCodexAgents
      ;
  };
  review = import ./review/family.nix {
    inherit
      pkgs
      renderCodexAgents
      ;
  };
  familyList = [
    subagents
    review
  ];

  mergeAgentDirs =
    name: attr:
    pkgs.runCommand name { } ''
      mkdir -p $out
      for dir in ${lib.concatStringsSep " " (map (family: toString family.${attr}) familyList)}; do
        for artifact in "$dir"/*; do
          ln -s "$artifact" "$out/$(basename "$artifact")"
        done
      done
    '';

  mergeFamilyAttrSets = attr: lib.foldl' (acc: family: acc // (family.${attr} or { })) { } familyList;
in
{
  # Families keep family-local content in their own directories, but installers
  # consume a single central entrypoint from here.
  inherit
    subagents
    review
    ;

  claudeAgentsDir = mergeAgentDirs "agents-claude-all-families" "claudeAgentsDir";

  codexAgentsDir = mergeAgentDirs "agents-codex-all-families" "codexAgentsDir";

  skillSources = mergeFamilyAttrSets "skillSources";
}
