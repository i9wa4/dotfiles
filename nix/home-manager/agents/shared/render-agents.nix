/*
  Renders subagent files for both Claude and Codex from a single SSOT
  (`subagents/_metadata.nix` + `subagents/<name>.md`).

  Outputs:
    claudeAgentsDir  -- linkFarm of <name>.md files for ~/.claude/agents/
    codexAgentsDir   -- linkFarm of <name>.toml files for ~/.codex/agents/
    skillSources.subagent-review -- generated SKILL.md (with the tier-to-model
                                    table baked from _metadata.nix defaults)

  Each agent file's frontmatter / TOML carries the *tier 2* defaults
  (the lighter / inherit-default shape); tier 1 is selected at spawn time
  by the dispatcher SKILL.md via `Task(model=..., effort=...)` for Claude
  and `codex exec -m <MODEL> -c model_reasoning_effort=<EFFORT>` for Codex.
*/
{ pkgs }:
let
  inherit (pkgs) lib;
  metadata = import ../subagents/_metadata.nix;
  inherit (metadata) resolved defaults;
  names = builtins.attrNames resolved;
  subagentsDir = ../subagents;

  readBody = name: builtins.readFile "${subagentsDir}/${name}.md";

  mkClaudeAgent =
    name:
    let
      cfg = resolved.${name};
      body = readBody name;
    in
    {
      name = "${name}.md";
      path = pkgs.writeText "${name}.md" (
        ''
          ---
          name: ${builtins.toJSON cfg.name}
          description: ${builtins.toJSON cfg.description}
          model: ${builtins.toJSON cfg.claude.tier2.model}
          effort: ${builtins.toJSON cfg.claude.tier2.effort}
          ---

        ''
        + body
      );
    };

  mkCodexAgent =
    name:
    let
      cfg = resolved.${name};
      body = readBody name;
    in
    {
      name = "${name}.toml";
      path = pkgs.writeText "${name}.toml" (
        ''
          name = ${builtins.toJSON cfg.name}
          description = ${builtins.toJSON cfg.description}
        ''
        + lib.optionalString (cfg.codex.tier2.model != null) ''
          model = ${builtins.toJSON cfg.codex.tier2.model}
        ''
        + lib.optionalString (cfg.codex.tier2.modelReasoningEffort != null) ''
          model_reasoning_effort = ${builtins.toJSON cfg.codex.tier2.modelReasoningEffort}
        ''
        + "developer_instructions = '''\n\n"
        + body
        + "\n'''\n"
      );
    };

  # Tier-to-model table baked from metadata.defaults so the dispatcher's table
  # never drifts from the build-time render.
  cT1 = defaults.claude.tier1;
  xT1 = defaults.codex.tier1;

  subagentReviewSkillMd = pkgs.writeText "subagent-review-SKILL.md" ''
    ---
    name: subagent-review
    description: |
      Multi-perspective parallel code/design review. Spawns 5 reviewer subagents
      per requested (engine, tier) combination.
      Default: `cc tier2 cx tier2` (10 reviewers, 5 each on Claude and Codex).

      Argument format: space-separated tokens.
        - Engine: cc | cx (Claude / Codex)
        - Tier:   tier1 | tier2 (deep / shallow; default tier2)
      Tier and engine apply to subsequent reviewers until overridden.

      Examples:
        subagent-review                       # cc tier2 cx tier2 (default)
        subagent-review cc tier1              # 5 Claude tier 1
        subagent-review cc tier1 cx tier1     # 10 reviewers, both tier 1

      Use when running code reviews on PRs/commits/branches or design reviews
      on issues/documents.
    ---

    # Subagent Review (Unified Dispatcher)

    Single dispatcher. Tier is enforced at spawn time via override; the agent
    file's frontmatter carries the tier 2 defaults intentionally -- the model
    belongs to the call, not the file.

    ## 1. Pre-flight

    - Halt on `main` / `master` / `develop` branch.
    - If PR/code review requested but no diff exists: halt and report. Do NOT
      fall back silently to design review.

    ## 2. Tier-to-model table (applied at spawn)

    Generated from `subagents/_metadata.nix` `defaults`:

    | Tier  | Claude `model` | Claude `effort` | Codex `model` | Codex `effort` |
    | ----- | -------------- | --------------- | ------------- | -------------- |
    | tier1 | `${cT1.model}` | `${cT1.effort}` | `${xT1.model}` | `${xT1.modelReasoningEffort}` |
    | tier2 | (use frontmatter default) | (use default) | (use frontmatter default) | (use default) |

    Per-agent overrides live in `_metadata.nix` `agents.<name>`. Read
    `metadata.resolved.<name>` for the merged effective values when an
    individual reviewer needs a different model than the table.

    ## 3. Cheap local verifier first

    If the target is code or config changes, run one cheap local verifier before
    any reviewer fan-out. Tier 1 MUST NOT launch on a trivially-failing worktree.

    Verifier selection order:

    - Use the task or plan's stated verifier if one exists.
    - Otherwise use the narrowest obvious repo verifier for the touched files.
    - If no repo-specific verifier is clear, at minimum run `git diff --check`.

    Repair loop: one focused repair + one rerun. If still failing, carry the
    failure into the review request rather than hiding it.

    ## 4. Spawn pool

    For each `(engine, tier)` pair in the parsed arg list:

      Capture baseline file count under
      `~/.local/state/mkmd/*/*/reviews/review-*-${"$"}{engine}-${"$"}{tier}.md`.

      For role in `[security, architecture, historian, code, qa]`:

        If engine == cc:
          Task(
            subagent_type=f"reviewer-{role}",
            model=tier1_model_if_tier1_else_omit,
            effort=tier1_effort_if_tier1_else_omit,
            prompt=<<reviewer prompt with target diff/dir>>
          )

        If engine == cx:
          codex exec --sandbox workspace-write \
            $(if tier1: -m ${cT1.model} -c model_reasoning_effort=${xT1.modelReasoningEffort}) \
            -- @reviewer-{role} "<reviewer prompt>"

    Spawn all in the same turn so engines run simultaneously.

    ## 5. Verify

    After all spawns complete, file-count delta per `(engine, tier)` must equal 5.
    Codex `launch-failures-${"$"}{engine}-${"$"}{tier}` artifacts surface as
    `BLOCKED` -- do not retry; recommend the matching Claude fallback.

    ## 6. Merged summary

    ```bash
    SUMMARY_FILE=$(mkmd --dir reviews --label summary)
    ```

    ````markdown
    # Review Summary

    ## Target

    - Directory: {dir_name}
    - Pools run: {engine-tier list}
    - Sources: per-pool summaries

    ## Resumable Handoff

    - Objective: {current objective or `Not provided`}
    - Blockers: {current blockers or `None recorded`}
    - Active paths:
      - `{path/to/active-artifact}`
    - Next action: {next action after accepting or retrying this review}
    - Latest verification status: {worker verification outcome or `Not provided`}

    ## Findings

    | #   | Issue           | Reporter        | Severity | Confidence | File               |
    | --- | --------------- | --------------- | -------- | ---------- | ------------------ |
    | 1   | {concise title} | {role}-{engine}-{tier} | BLOCKING | High | `path/to/file:123` |

    Deduplication: same issue reported across pools collapses into one entry
    listing all reporters. Re-rank by severity after deduplication.

    ## Coverage

    | Perspective  | cc-tier2 | cc-tier1 | cx-tier2 | cx-tier1 | Total |
    | ------------ | -------- | -------- | -------- | -------- | ----- |
    | Security     | N        | N        | N        | N        | N     |
    | Architecture | N        | N        | N        | N        | N     |
    | Historian    | N        | N        | N        | N        | N     |
    | Code         | N        | N        | N        | N        | N     |
    | QA           | N        | N        | N        | N        | N     |
    | **Total**    | **N**    | **N**    | **N**    | **N**    | **N** |

    (Omit columns for pools not invoked in this run.)
    ````

    ## 7. Planner -> Worker -> Evaluator contract

    When reused as part of a long-running workflow, this dispatcher is the
    evaluator stage for the planner -> worker -> evaluator contract defined in
    `plan-design`.

    - Planner input expected: objective, acceptance criteria, active artifact
      paths, latest worker verification outcome.
    - Worker input expected: implementation/investigation artifact, changed
      paths, residual blockers, concrete next action if rejected.
    - Evaluator guarantees: do not promote incomplete review runs; verify every
      requested batch completed before merging; return findings tied to concrete
      files/paths; reject with specific retry work when evidence or coverage is
      incomplete.

    The evaluator output preserves objective, blockers, active paths, and next
    action so a later session can resume from the merged summary without
    reopening the full transcript.

    ## 8. Reviewer deliberation (out of scope)

    The deliberation pass (second-round cross-examination) is NOT performed by
    this dispatcher. Callers requiring deliberation must collect Phase 1 results
    and perform deliberation themselves.
  '';

  subagentReviewSkillDir = pkgs.runCommand "skill-subagent-review" { } ''
    mkdir -p $out/subagent-review
    cp ${subagentReviewSkillMd} $out/subagent-review/SKILL.md
  '';
in
{
  claudeAgentsDir = pkgs.linkFarm "agents-claude" (map mkClaudeAgent names);
  codexAgentsDir = pkgs.linkFarm "agents-codex" (map mkCodexAgent names);
  skillSources = {
    subagent-review = {
      path = subagentReviewSkillDir;
    };
  };
}
