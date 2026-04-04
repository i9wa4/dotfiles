# Nix generation for the review stack used by the installed review skills.
# This file is the SSOT for two kinds of generated artifacts:
#   1. reviewer agent markdown files with engine/model-specific frontmatter
#   2. generated review skill directories whose SKILL.md files are assembled
#      from shared refs plus family-local label metadata/templates below
# Stable build-time prompt content lives in refs/ (not deployed directly).
#
# Installation path: agent-skills.nix imports this file as `reviewGen`, then
# wires `reviewGen.skillFiles.*` into generated skill sources. On a rebuild,
# those derivations are exposed under ~/.claude/skills and ~/.codex/skills via
# the agent-skills symlink-tree targets.
#
# Reviewer agent inputs: refs/reviewer-{role}.md (6 files, no model field)
# Shared skill inputs:
#   refs/review-core-pre.md  -- shared §1, §2, Step 1 (LABEL_PLACEHOLDER)
#   refs/review-core-post.md -- shared Step 3, Step 4 (LABEL_PLACEHOLDER)
# Per-label meaning lives in the local `skillVariants` matrix below.
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
  inherit (pkgs) lib;

  indent =
    spaces: text:
    let
      prefix = lib.concatStrings (lib.replicate spaces " ");
      lines = lib.splitString "\n" (lib.removeSuffix "\n" text);
    in
    lib.concatMapStringsSep "\n" (line: "${prefix}${line}") lines;

  roleTable = ''
    | Priority | Role         |
    | -------- | ------------ |
    | 1        | security     |
    | 2        | architecture |
    | 3        | historian    |
    | 4        | {ROLE4}      |
    | 5        | qa           |
  '';

  claudeArtifactSnippet = ''
    ```bash
    OUTPUT_FILE=$(mkmd --dir reviews --label "review-''${ROLE}-''${LABEL}")
    # Write the subagent's response to OUTPUT_FILE
    ```
  '';

  codexFailureHandling = ''
    Do not run `codex sandbox linux -- /bin/true` as a separate preflight here.
    This skill already uses `codex exec --sandbox workspace-write`, and that actual
    launch path is the one that must be trusted and verified on the host.

    When a launch fails, move the aggregate failure artifact
    `launch-failures-''${LABEL}` from `tmp/` into `reviews/` and keep the per-role
    `launch-''${ROLE}-''${LABEL}` log so the wrapper can surface concrete evidence
    instead of retrying blindly. Keep the counted `review-''${ROLE}-''${LABEL}`
    artifact under `tmp/` until `codex exec` exits 0, then move it into
    `reviews/`.
  '';

  skillVariants = {
    cc = {
      label = "cc";
      skillName = "subagent-review-cc";
      title = "Subagent Review CC Skill";
      description = ''
        5-parallel code/design review using Claude-based reviewer subagents.
        Always runs Claude reviewers regardless of calling engine.
        Use when:
        - Running code or design reviews using Claude reviewers only
        - Calling engine is Codex but you want Claude-side review results
        - Running half of a full dual-engine review (pair with `subagent-review-cx`)
      '';
      intro = ''
        Launches exactly 5 Claude reviewer subagents in parallel. No engine detection.
        LABEL is always "cc". Each reviewer response is materialized to a disk file.
      '';
      step2 = {
        kind = "claude";
        heading = "### Step 2: Launch 5 Claude Subagents in Parallel";
        promptDisplay = "reviewer-{ROLE}";
      };
    };
    ccDeep = {
      label = "cc-deep";
      skillName = "subagent-review-cc-deep";
      title = "Subagent Review CC Deep Skill (Tier 1)";
      description =
        lib.concatStringsSep "\n" [
          "5-parallel code/design review using Claude Tier 1 reviewer subagents"
          "(claude-opus-4-6, pinned in agent frontmatter)."
          "Always runs Claude reviewers regardless of calling engine. LABEL is always"
          "\"cc-deep\". Each reviewer response is materialized to a disk file."
          "Use when:"
          "- Running thorough pre-merge reviews requiring maximum Claude depth"
          "- Calling engine is Codex but you want Claude Tier 1 review results"
          "- Running half of a full dual-engine deep review (pair with"
          "  `subagent-review-cx-deep`)"
          "For Tier 2 (sonnet, default): use `subagent-review-cc`"
        ]
        + "\n";
      intro = ''
        Launches exactly 5 Claude Tier 1 reviewer subagents in parallel. No engine
        detection. LABEL is always "cc-deep". Each reviewer response is materialized to
        a disk file. Tier 1: agents have model: claude-opus-4-6 pinned in frontmatter.
      '';
      step2 = {
        kind = "claude";
        heading = "### Step 2: Launch 5 Claude Tier 1 Subagents in Parallel";
        promptDisplay = "reviewer-{ROLE}-cc-deep";
      };
    };
    cx = {
      label = "cx";
      skillName = "subagent-review-cx";
      title = "Subagent Review CX Skill";
      description = ''
        5-parallel code/design review using Codex Tier 2 reviewer subagents (no model/effort flags).
        Always runs Codex reviewers regardless of calling engine.
        Use when:
        - Running code or design reviews using Codex reviewers only
        - Calling engine is Claude but you want Codex-side review results
        - Running half of a full dual-engine review (pair with `subagent-review-cc`)
        For Tier 1 (gpt-5.4, xhigh effort): use `subagent-review-cx-deep`
      '';
      intro = ''
        Launches exactly 5 Codex reviewer subagents in parallel via `codex exec`. No
        engine detection. LABEL is always "cx". Each reviewer output is written to disk.
      '';
      step2 = {
        kind = "codex";
        heading = "### Step 2: Launch 5 Codex Subagents in Parallel";
        promptPrintf = "reviewer-%s";
        execBlock =
          lib.concatStringsSep "\n" [
            "  # NOTE: inherits parent Codex session model (model pin removed)"
            "  codex exec --sandbox workspace-write \\"
            "    -o \"$OUTPUT_TMP_FILE\" \"$(cat \"$PROMPT_FILE\")\" > \"$LAUNCH_LOG\" 2>&1 &"
          ]
          + "\n";
      };
    };
    cxDeep = {
      label = "cx-deep";
      skillName = "subagent-review-cx-deep";
      title = "Subagent Review CX Deep Skill (Tier 1)";
      description = ''
        5-parallel code/design review using Codex Tier 1 reviewer subagents (gpt-5.4, xhigh effort).
        Always runs Codex reviewers with explicit model pin and reasoning effort.
        Use when:
        - Running thorough pre-merge reviews requiring maximum depth
        - Calling engine is Claude but you want Codex-side Tier 1 review results
        - Running half of a full dual-engine deep review (pair with `subagent-review-cc-deep`)
      '';
      intro = ''
        Launches exactly 5 Codex Tier 1 reviewer subagents in parallel via `codex exec`.
        No engine detection. LABEL is always "cx-deep". Each reviewer output is written
        to disk. Tier 1: explicit model pin and xhigh reasoning effort (hardcoded in
        codex exec call).
      '';
      step2 = {
        kind = "codex";
        heading = "### Step 2: Launch 5 Codex Tier 1 Subagents in Parallel";
        promptPrintf = "reviewer-%s-deep";
        execBlock =
          lib.concatStringsSep "\n" [
            "  codex exec --model gpt-5.4 \\"
            "    --config model_reasoning_effort=xhigh \\"
            "    --sandbox workspace-write \\"
            "    -o \"$OUTPUT_TMP_FILE\" \"$(cat \"$PROMPT_FILE\")\" > \"$LAUNCH_LOG\" 2>&1 &"
          ]
          + "\n";
      };
    };
  };

  mkFrontmatterText =
    variant:
    "---\n"
    + "name: ${variant.skillName}\n"
    + "description: |\n"
    + indent 2 variant.description
    + "\n"
    + "---\n\n"
    + "# ${variant.title}\n\n"
    + lib.removeSuffix "\n" variant.intro
    + "\n";

  mkClaudeStep2Text =
    variant:
    "${variant.step2.heading}\n\n"
    + "Launch all 5 reviewers in a single turn using the native Agent tool.\n"
    + "Use this prompt template for each:\n\n"
    + "```text\n"
    + "${variant.step2.promptDisplay}\n"
    + "git diff {BASE}...HEAD\n"
    + "Review context follows:\n"
    + "{contents of CONTEXT_FILE}\n"
    + "```\n\n"
    + "Inline the contents of `{CONTEXT_FILE}` into the child prompt. Do NOT pass only\n"
    + "the mkmd path.\n\n"
    + "Roles (in order):\n\n"
    + lib.removeSuffix "\n" roleTable
    + "\n\n"
    + "After each reviewer responds, materialize its response to disk:\n\n"
    + lib.removeSuffix "\n" claudeArtifactSnippet
    + "\n";

  mkCodexStep2Text =
    variant:
    "${variant.step2.heading}\n\n"
    + "```bash\n"
    + "LAUNCH_FAILURE_TMP_FILE=$(mkmd --dir tmp --label \"launch-failures-"
    + "$"
    + "{LABEL}\")\n"
    + "LAUNCH_FAILURE_FILE="
    + "$"
    + "{LAUNCH_FAILURE_TMP_FILE/\\/tmp\\//\\/reviews\\/}\n"
    + "LAUNCH_STATE_FILE=$(mkmd --dir tmp --label \"launch-state-"
    + "$"
    + "{LABEL}\")\n"
    + ": > \"$LAUNCH_STATE_FILE\"\n\n"
    + "for ROLE in security architecture historian \""
    + "$"
    + "{ROLE4}\" qa; do\n"
    + "  PROMPT_FILE=$(mkmd --dir reviews --label \"prompt-"
    + "$"
    + "{ROLE}-"
    + "$"
    + "{LABEL}\")\n"
    + "  OUTPUT_TMP_FILE=$(mkmd --dir tmp --label \"review-"
    + "$"
    + "{ROLE}-"
    + "$"
    + "{LABEL}\")\n"
    + "  LAUNCH_LOG=$(mkmd --dir reviews --label \"launch-"
    + "$"
    + "{ROLE}-"
    + "$"
    + "{LABEL}\")\n"
    + "  # Inline the review context: the mkmd path lives outside the child\n"
    + "  # workspace-write sandbox, so passing only the path breaks Codex-side review.\n"
    + "  {\n"
    + "    printf '${variant.step2.promptPrintf}\\n' \"$ROLE\"\n"
    + "    printf 'git diff %s...HEAD\\n' \"$BASE\"\n"
    + "    printf 'Review context follows:\\n'\n"
    + "    cat \"$CONTEXT_FILE\"\n"
    + "  } > \"$PROMPT_FILE\"\n"
    + "  # NOTE: --sandbox workspace-write requires codex >=0.x; omit if unavailable\n"
    + lib.removeSuffix "\n" variant.step2.execBlock
    + "\n"
    + "  printf '%s\\t%s\\t%s\\t%s\\n' \"$!\" \"$ROLE\" \"$OUTPUT_TMP_FILE\" \"$LAUNCH_LOG\" >> \"$LAUNCH_STATE_FILE\"\n"
    + "done\n\n"
    + "FAILED=0\n"
    + "while IFS=\"$(printf '\\t')\" read -r PID ROLE OUTPUT_TMP_FILE LAUNCH_LOG; do\n"
    + "  OUTPUT_FILE="
    + "$"
    + "{OUTPUT_TMP_FILE/\\/tmp\\//\\/reviews\\/}\n"
    + "  if ! wait \"$PID\"; then\n"
    + "    FAILED=1\n"
    + "    {\n"
    + "      printf 'role: %s\\n' \"$ROLE\"\n"
    + "      printf 'launch log: %s\\n' \"$LAUNCH_LOG\"\n"
    + "    } >> \"$LAUNCH_FAILURE_TMP_FILE\"\n"
    + "  else\n"
    + "    mv \"$OUTPUT_TMP_FILE\" \"$OUTPUT_FILE\"\n"
    + "  fi\n"
    + "done < \"$LAUNCH_STATE_FILE\"\n\n"
    + "if [ \"$FAILED\" -ne 0 ]; then\n"
    + "  mv \"$LAUNCH_FAILURE_TMP_FILE\" \"$LAUNCH_FAILURE_FILE\"\n"
    + "  echo \"BLOCKED: codex reviewer launch failure; see $LAUNCH_FAILURE_FILE\" >&2\n"
    + "  exit 1\n"
    + "fi\n"
    + "```\n\n"
    + lib.removeSuffix "\n" codexFailureHandling
    + "\n";

  mkStep2Text =
    variant:
    if variant.step2.kind == "claude" then mkClaudeStep2Text variant else mkCodexStep2Text variant;

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
    variant:
    let
      frontmatterFile = pkgs.writeText "frontmatter-${variant.label}.md" (mkFrontmatterText variant);
      step2File = pkgs.writeText "step2-${variant.label}.md" (mkStep2Text variant);
    in
    pkgs.runCommand "skill-${variant.label}" { } ''
      mkdir -p $out/${variant.skillName}
      {
        # 1. Frontmatter from the family-local label matrix
        cat ${frontmatterFile}
        printf '\n'
        # 2. Shared pre-Step2 content (§1, §2, Step 1) with LABEL substituted
        ${pkgs.gnused}/bin/sed \
          -e "s/LABEL_PLACEHOLDER/${variant.label}/g" \
          ${./refs/review-core-pre.md}
        printf '\n'
        # 3. Engine/tier-specific Step 2 from the local label matrix
        cat ${step2File}
        printf '\n'
        # 4. Shared post-Step2 content (Step 3, Step 4) with LABEL substituted
        ${pkgs.gnused}/bin/sed \
          -e "s/LABEL_PLACEHOLDER/${variant.label}/g" \
          ${./refs/review-core-post.md}
      } > "$out/${variant.skillName}/SKILL.md"
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
    # These derivations are the installed subagent-review-* skill directories
    # consumed by agent-skills.nix.
    ccDir = genSkill skillVariants.cc;
    ccDeepDir = genSkill skillVariants.ccDeep;
    cxDir = genSkill skillVariants.cx;
    cxDeepDir = genSkill skillVariants.cxDeep;
  };
}
