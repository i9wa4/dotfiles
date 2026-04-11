{
  pkgs,
  renderCodexAgents,
}:
let
  reviewGen = import ../../review/review-artifacts-gen.nix { inherit pkgs; };
  staticSkillsDir = ../../review/skills;
  validateSkillSource =
    name: src:
    pkgs.runCommand name { } ''
      cp -r ${src} $out
      chmod -R u+w $out
      ${pkgs.bash}/bin/bash ${../../scripts/validate-skill-frontmatter.sh} "$out"
    '';

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
      path = validateSkillSource "review-local-skills-validated" staticSkillsDir;
    };
    generated-cc = {
      path = validateSkillSource "review-generated-cc-validated" reviewGen.skillFiles.ccDir;
    };
    generated-cc-deep = {
      path = validateSkillSource "review-generated-cc-deep-validated" reviewGen.skillFiles.ccDeepDir;
    };
    generated-cx = {
      path = validateSkillSource "review-generated-cx-validated" reviewGen.skillFiles.cxDir;
    };
    generated-cx-deep = {
      path = validateSkillSource "review-generated-cx-deep-validated" reviewGen.skillFiles.cxDeepDir;
    };
  };
}
