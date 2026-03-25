# Nix generation for review skill SKILL.md files.
# All inputs live in refs/ (build-time fragments, not deployed as skills).
#
# refs/review-core-pre.md    -- shared §1, §2, Step 1 (LABEL_PLACEHOLDER)
# refs/review-core-post.md   -- shared Step 3, Step 4 (LABEL_PLACEHOLDER)
# refs/frontmatter-{label}.md -- per-skill YAML frontmatter (multi-line desc)
# refs/step2-{label}.md      -- per-skill Step 2 content
#
# Output:
#   skillCcDir     -- subagent-claude-review/SKILL.md (LABEL=cc)
#   skillCcDeepDir -- subagent-claude-review-deep/SKILL.md (LABEL=cc-deep)
#   skillCxDir     -- subagent-codex-review/SKILL.md (LABEL=cx)
#   skillCxDeepDir -- subagent-codex-review-deep/SKILL.md (LABEL=cx-deep)
#
# Generated SKILL.md section order: frontmatter -> §1 -> §2 -> Step1 -> Step2 -> Step3 -> Step4
{ pkgs }:
let
  genSkill =
    {
      skillName,
      label,
      frontmatterFile,
      step2File,
    }:
    pkgs.runCommand "skill-${label}" { } ''
      mkdir -p $out/${skillName}
      {
        # 1. Frontmatter from per-skill file (preserves multi-line description)
        cat ${frontmatterFile}
        printf '\n'
        # 2. Shared pre-Step2 content (§1, §2, Step 1) with LABEL substituted
        ${pkgs.gnused}/bin/sed \
          -e "s/LABEL_PLACEHOLDER/${label}/g" \
          ${./refs/review-core-pre.md}
        printf '\n'
        # 3. Engine-specific Step 2
        cat ${step2File}
        printf '\n'
        # 4. Shared post-Step2 content (Step 3, Step 4) with LABEL substituted
        ${pkgs.gnused}/bin/sed \
          -e "s/LABEL_PLACEHOLDER/${label}/g" \
          ${./refs/review-core-post.md}
      } > "$out/${skillName}/SKILL.md"
    '';
in
{
  skillCcDir = genSkill {
    skillName = "subagent-claude-review";
    label = "cc";
    frontmatterFile = ./refs/frontmatter-cc.md;
    step2File = ./refs/step2-cc.md;
  };
  skillCcDeepDir = genSkill {
    skillName = "subagent-claude-review-deep";
    label = "cc-deep";
    frontmatterFile = ./refs/frontmatter-cc-deep.md;
    step2File = ./refs/step2-cc-deep.md;
  };
  skillCxDir = genSkill {
    skillName = "subagent-codex-review";
    label = "cx";
    frontmatterFile = ./refs/frontmatter-cx.md;
    step2File = ./refs/step2-cx.md;
  };
  skillCxDeepDir = genSkill {
    skillName = "subagent-codex-review-deep";
    label = "cx-deep";
    frontmatterFile = ./refs/frontmatter-cx-deep.md;
    step2File = ./refs/step2-cx-deep.md;
  };
}
