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

WRAPPER: Dispatches to sub-skills based on caller-supplied labels. Each label
maps to one sub-skill (5 reviewers). Requested sub-skills are launched first so
independent labels can run simultaneously. Results are collected and merged
after all invoked sub-skills complete.

Default labels (no argument): cc cx

Label-to-sub-skill dispatch table:

| Label   | Sub-skill                | Reviewers                |
| ------- | ------------------------ | ------------------------ |
| cc      | /subagent-review-cc      | 5 Claude Tier 2 (sonnet) |
| cc-deep | /subagent-review-cc-deep | 5 Claude Tier 1 (opus)   |
| cx      | /subagent-review-cx      | 5 Codex Tier 2           |
| cx-deep | /subagent-review-cx-deep | 5 Codex Tier 1 (xhigh)   |

NOTE: Callers requiring the deliberation pass MUST invoke sub-skills directly
and perform deliberation themselves.

HARD CONSTRAINT: All invoked sub-skills MUST complete before proceeding to
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

Capture ALL baselines before any sub-skill invocation.

### Step 1: Launch Requested Sub-skills

For each label in the parsed list, invoke the corresponding sub-skill:

- If label is **cc**: invoke /subagent-review-cc
- If label is **cc-deep**: invoke /subagent-review-cc-deep
- If label is **cx**: invoke /subagent-review-cx
- If label is **cx-deep**: invoke /subagent-review-cx-deep

Launch all requested sub-skills before waiting on any one of them. For example,
the default `cc cx` run should start both sub-skills in the same turn so the
Claude-side and Codex-side reviews can proceed simultaneously.

After all requested sub-skills have been launched, wait for every invoked
sub-skill to complete before proceeding to Step 2.

### Step 2: Collect and Verify Results

After all sub-skills complete, verify new output file counts:

```bash
AFTER_CC=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc.md 2>/dev/null | wc -l)
AFTER_CC_DEEP=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cc-deep.md 2>/dev/null | wc -l)
AFTER_CX=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx.md 2>/dev/null | wc -l)
AFTER_CX_DEEP=$(ls ~/.local/state/mkmd/*/*/reviews/review-*-cx-deep.md 2>/dev/null | wc -l)
```

For each invoked label: delta must equal 5. If any delta is less than 5: do NOT
proceed. Re-invoke the relevant sub-skill.

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
this wrapper. Callers requiring deliberation must invoke sub-skills directly,
collect Phase 1 results, and perform deliberation themselves.
