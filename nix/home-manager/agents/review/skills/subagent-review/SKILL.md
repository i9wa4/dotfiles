---
name: subagent-review
description: |
  Argument-driven code/design review wrapper. Invokes reviewer sub-skills for
  each specified engine+tier label. Defaults to 'cc cx' (10 reviewers) if no
  arguments given.
  Argument format: space-separated labels from {cc, cc-deep, cx, cx-deep}
  Examples: 'cc cx' (default), 'cc-deep cx-deep', 'cc', 'cx-deep'
  Use when:
  - Running code reviews on PRs, commits, or branches
  - Running design reviews on issues or documents
  - Need multi-perspective review (security, architecture, code, QA, historian)
---

# Subagent Review Skill

WRAPPER: Dispatches to child skills based on caller-supplied labels. Each
label maps to one child skill (5 reviewers). Requested child skills are
launched first so independent labels can run simultaneously. Results are
collected and merged after all invoked child skills complete.

Default labels (no argument): cc cx

Label-to-child-skill dispatch table:

| Label   | Child Skill               | Reviewers                |
| ------- | ------------------------- | ------------------------ |
| cc      | `subagent-review-cc`      | 5 Claude Tier 2 (sonnet) |
| cc-deep | `subagent-review-cc-deep` | 5 Claude Tier 1 (opus)   |
| cx      | `subagent-review-cx`      | 5 Codex Tier 2           |
| cx-deep | `subagent-review-cx-deep` | 5 Codex Tier 1 (xhigh)   |

NOTE: Callers requiring the deliberation pass MUST invoke the child
skills directly and perform deliberation themselves.

HARD CONSTRAINT: All invoked child skills MUST complete before proceeding to
the merged summary. Do NOT produce a merged summary with missing result files.

## 1. Pre-flight Check

```bash
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ]; then
  echo "HALT: On protected branch (${BRANCH})."
fi
```

If code/PR review was requested and no diff exists: halt and report.
Do NOT fall back silently to design review.

## 2. Review Workflow

### Step 0: Parse Arguments and Capture Baseline

Parse the caller-supplied labels. If none, default to: cc cx

```bash
BEFORE_CC=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc.md 2>/dev/null | wc -l)
BEFORE_CC_DEEP=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc-deep.md 2>/dev/null | wc -l)
BEFORE_CX=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx.md 2>/dev/null | wc -l)
BEFORE_CX_DEEP=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx-deep.md 2>/dev/null | wc -l)
```

Capture ALL baselines before any child-skill invocation.

### Step 0.5: Run Cheap Local Verification First

If the target is code or config changes, run one cheap local verifier before
any reviewer fan-out. Deep variants (`cc-deep`, `cx-deep`) MUST NOT be launched
against an unverified worktree.

Verifier selection order:

- Use the task or plan's stated verifier if one exists
- Otherwise use the narrowest obvious repo verifier for the touched files
- If no repo-specific verifier is clear, at minimum run `git diff --check`

Repair loop:

- If the verifier fails with a concrete fix, make one focused repair and rerun
  the same verifier once
- If the second pass still fails, stop the cheap loop and carry that failure
  into the review request and merged summary instead of hiding it

Do NOT burn reviewer budget on a trivially failing worktree when a cheap
verifier already names the next edit.

### Step 1: Launch Requested Child Skills

For each label in the parsed list, invoke the corresponding child skill:

- If label is **cc**: use skill `subagent-review-cc`
- If label is **cc-deep**: use skill `subagent-review-cc-deep`
- If label is **cx**: use skill `subagent-review-cx`
- If label is **cx-deep**: use skill `subagent-review-cx-deep`

Launch all requested child skills before waiting on any one of them. For
example, the default `cc cx` run should start both child skills in the same
turn so the Claude-side and Codex-side reviews can proceed simultaneously.

For Codex labels, keep the child prompt self-contained. Do NOT pass only an
mkmd context file path from `~/.local/state/mkmd/...`; `codex exec --sandbox
workspace-write` child sessions cannot read that path.

For Codex labels, rely on the actual `codex exec --sandbox workspace-write`
launch result from the child skill. Do NOT add a separate `codex sandbox linux`
preflight in the wrapper; that probes a different path and can fail on hosts
where the real reviewer launch still works.
The child skill must persist launch evidence as `launch-failures-${label}` plus
per-role `launch-${role}-${label}` logs whenever an actual Codex launch fails.

After all requested child skills have been launched, wait for every invoked
child skill to complete before proceeding to Step 2.

### Step 2: Collect and Verify Results

After all child skills complete, verify new output file counts:

```bash
AFTER_CC=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc.md 2>/dev/null | wc -l)
AFTER_CC_DEEP=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc-deep.md 2>/dev/null | wc -l)
AFTER_CX=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx.md 2>/dev/null | wc -l)
AFTER_CX_DEEP=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx-deep.md 2>/dev/null | wc -l)
```

For each invoked label: delta must equal 5.

If any Claude label delta is less than 5: do NOT proceed. Re-invoke the
relevant child skill.

If a Codex label delta is less than 5 because the child skill produced
`launch-failures-${label}` with concrete `codex exec --sandbox workspace-write`
launch evidence: do NOT retry. Surface BLOCKED with that artifact path and the
matching per-role `launch-${role}-${label}` log paths, then recommend the
matching Claude fallback (`cc` or `cc-deep`) for this host.

Otherwise, if a Codex label delta is less than 5 for some other reason: do NOT
proceed. Re-invoke the relevant child skill.

### Step 3: Merged Summary

```bash
SUMMARY_FILE=$(mkmd --dir reviews --label summary)
```

Generate the merged summary in one pass. Do NOT require a follow-up.
Carry forward the current objective, blockers, active paths, next action, and
latest verification status from the planner/worker inputs. If a field is not
available, say `Not provided` rather than omitting it.

````markdown
# Review Summary

## Target

- Directory: {dir_name}
- Labels run: {labels}
- Sources: {label}-side summaries

## Resumable Handoff

- Objective: {current objective or `Not provided`}
- Blockers: {current blockers or `None recorded`}
- Active paths:
  - `{path/to/active-artifact-or-file}`
- Next action: {next action after accepting or retrying this review}
- Latest verification status: {worker verification outcome or `Not provided`}

## Findings

| #   | Issue           | Reporter       | Severity | Confidence | File               |
| --- | --------------- | -------------- | -------- | ---------- | ------------------ |
| 1   | {concise title} | {role}-{label} | BLOCKING | High       | `path/to/file:123` |

Deduplication rule: if the same issue is reported by multiple labels,
consolidate into one entry listing all reporters.
Re-rank by severity after deduplication.

## Key Findings Detail

(BLOCKING, IMPORTANT, or flagged by 3+ reviewers across all invoked labels)

### {title}

**What**: {description}

**Where**:

- `path/to/file.ext:NN` -- `code`

**Reporters**: {role}-cc, {role}-cx

**Fix**:

\```lang
-- Before
-- After
\```

## Coverage

| Perspective  | cc Count | cc-deep Count | cx Count | cx-deep Count | Total |
| ------------ | -------- | ------------- | -------- | ------------- | ----- |
| Security     | N        | N             | N        | N             | N     |
| Architecture | N        | N             | N        | N             | N     |
| Historian    | N        | N             | N        | N             | N     |
| Code/Data    | N        | N             | N        | N             | N     |
| QA           | N        | N             | N        | N             | N     |
| **Total**    | **N**    | **N**         | **N**    | **N**         | **N** |

(Omit columns for labels not invoked in this run.)
````

## 3. Planner -> Worker -> Evaluator Contract

When reused as part of a long-running workflow, this wrapper is the evaluator
stage for the planner->worker->evaluator contract defined in `plan-design`.

- Planner input expected:
  - objective
  - acceptance criteria
  - active artifact paths
  - latest worker verification outcome
- Worker input expected:
  - implementation or investigation artifact
  - changed paths
  - residual blockers
  - concrete next action if the evaluator rejects
- Evaluator guarantees from this wrapper:
  - do not promote incomplete review runs
  - verify every requested reviewer batch completed before merging
  - return merged findings tied to concrete files/paths
  - reject with specific retry work when evidence or coverage is incomplete

The evaluator output should preserve the current objective, blockers, active
paths, and next action so a later session can resume from the merged summary
without reopening the full transcript.

## 4. Reviewer Deliberation (Out of Scope)

The deliberation pass (second-round cross-examination) is NOT performed by
this wrapper. Callers requiring deliberation must invoke the child skills
directly, collect Phase 1 results, and perform deliberation themselves.
