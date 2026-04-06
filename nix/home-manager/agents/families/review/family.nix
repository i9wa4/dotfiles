{
  pkgs,
  renderCodexAgents,
}:
let
  reviewGen = import ../../review/review-artifacts-gen.nix { inherit pkgs; };
  staticSkillsDir = ../../review/skills;

  claudeAgentsDir = pkgs.runCommand "review-claude-agents" { } ''
    mkdir -p $out
    for md in ${reviewGen.agentFiles.ccDir}/*.md; do
      ln -s "$md" "$out/$(basename "$md")"
    done
    for md in ${reviewGen.agentFiles.ccDeepDir}/*.md; do
      ln -s "$md" "$out/$(basename "$md")"
    done
  '';

  codexMarkdownDir = pkgs.runCommand "review-codex-markdown" { } ''
    mkdir -p $out
    for md in ${reviewGen.agentFiles.cxDir}/*.md; do
      ln -s "$md" "$out/$(basename "$md")"
    done
    for md in ${reviewGen.agentFiles.cxDeepDir}/*.md; do
      ln -s "$md" "$out/$(basename "$md")"
    done
  '';
in
{
  inherit claudeAgentsDir;

  codexAgentsDir = renderCodexAgents {
    familyName = "review";
    sourceDir = codexMarkdownDir;
  };

  skillSources = {
    review-local = {
      path = staticSkillsDir;
    };
    generated-cc = {
      path = reviewGen.skillFiles.ccDir;
    };
    generated-cc-deep = {
      path = reviewGen.skillFiles.ccDeepDir;
    };
    generated-cx = {
      path = reviewGen.skillFiles.cxDir;
    };
    generated-cx-deep = {
      path = reviewGen.skillFiles.cxDeepDir;
    };
  };
}
