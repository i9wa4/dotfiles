{
  pkgs,
  renderCodexAgents,
}:
let
  sourceDir = ../../subagents;
in
{
  claudeAgentsDir = pkgs.runCommand "subagents-claude-agents" { } ''
    mkdir -p $out
    for md in ${sourceDir}/*.md; do
      ln -s "$md" "$out/$(basename "$md")"
    done
  '';

  codexAgentsDir = renderCodexAgents {
    familyName = "subagents";
    inherit sourceDir;
  };
}
