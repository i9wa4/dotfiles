# Nix generation for review infrastructure: reviewer agents + review skill SKILL.md files.
# All build-time inputs live in refs/ (not deployed directly).
#
# Reviewer agent inputs: refs/reviewer-{role}.md (6 files, no model field)
# Skill fragment inputs:
#   refs/review-core-pre.md     -- shared §1, §2, Step 1 (LABEL_PLACEHOLDER)
#   refs/review-core-post.md    -- shared Step 3, Step 4 (LABEL_PLACEHOLDER)
#   refs/frontmatter-{label}.md -- per-skill YAML frontmatter (multi-line desc)
#   refs/step2-{label}.md       -- per-skill Step 2 content
#
# Output attrs:
#   agentFiles.{ccDir,ccDeepDir,cxDir,cxDeepDir}  -- reviewer .md files
#   skillFiles.{ccDir,ccDeepDir,cxDir,cxDeepDir}  -- SKILL.md files
#
# NOTE: Reviewer file naming convention (engine in install path, not filename):
#   CC Tier2: reviewer-{role}.md, name: reviewer-{role}
#   CC Tier1: reviewer-{role}-deep.md, name: reviewer-{role}-cc-deep
#   CX Tier2: reviewer-{role}.md, name: reviewer-{role}
#   CX Tier1: reviewer-{role}-deep.md, name: reviewer-{role}-deep
{ pkgs }:
let
  genReviewers =
    {
      model,
      dirSuffix,
      fileSuffix ? "",
      nameSuffix ? "",
    }:
    pkgs.runCommand "reviewer-${dirSuffix}" { } ''
      mkdir -p $out
      for ref in ${./refs}/reviewer-*.md; do
        role=$(basename "$ref" .md \
          | ${pkgs.gnused}/bin/sed 's/^reviewer-//')
        name=$(${pkgs.gnused}/bin/sed -n 's/^name: //p' "$ref")
        desc=$(${pkgs.gnused}/bin/sed -n 's/^description: //p' "$ref")
        # Use temp file: command substitution strips trailing newlines
        ${pkgs.gawk}/bin/awk \
          'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' \
          "$ref" > "$out/_body_tmp"
        outfile="reviewer-''${role}${fileSuffix}.md"
        {
          printf -- '---\nname: %s%s\ndescription: %s\nmodel: %s\n---\n\n' \
            "$name" "${nameSuffix}" "$desc" "${model}"
          cat "$out/_body_tmp"
        } > "$out/$outfile"
        rm "$out/_body_tmp"
      done
    '';

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
  agentFiles = {
    ccDir = genReviewers {
      model = "sonnet";
      dirSuffix = "cc";
    };
    ccDeepDir = genReviewers {
      model = "claude-opus-4-6";
      dirSuffix = "cc-deep";
      fileSuffix = "-deep";
      nameSuffix = "-cc-deep";
    };
    cxDir = genReviewers {
      model = "gpt-5.4";
      dirSuffix = "cx";
    };
    cxDeepDir = genReviewers {
      model = "gpt-5.4";
      dirSuffix = "cx-deep";
      fileSuffix = "-deep";
      nameSuffix = "-deep";
    };
  };

  skillFiles = {
    ccDir = genSkill {
      skillName = "subagent-review-cc";
      label = "cc";
      frontmatterFile = ./refs/frontmatter-cc.md;
      step2File = ./refs/step2-cc.md;
    };
    ccDeepDir = genSkill {
      skillName = "subagent-review-cc-deep";
      label = "cc-deep";
      frontmatterFile = ./refs/frontmatter-cc-deep.md;
      step2File = ./refs/step2-cc-deep.md;
    };
    cxDir = genSkill {
      skillName = "subagent-review-cx";
      label = "cx";
      frontmatterFile = ./refs/frontmatter-cx.md;
      step2File = ./refs/step2-cx.md;
    };
    cxDeepDir = genSkill {
      skillName = "subagent-review-cx-deep";
      label = "cx-deep";
      frontmatterFile = ./refs/frontmatter-cx-deep.md;
      step2File = ./refs/step2-cx-deep.md;
    };
  };
}
