---
name: subagent-review
description: |
  10-parallel code/design review using reviewer subagents.
  Use when:
  - Running code reviews on PRs, commits, or branches
  - Running design reviews on issues or documents
  - Need multi-perspective review (security, architecture, code, QA, historian)
---

# Subagent Review Skill

## 1. Review Workflow

### 1.1. Setup (Fully Automatic)

No arguments required. Everything is auto-detected:

| Item        | Detection                                              |
| ----------- | ------------------------------------------------------ |
| review_type | `git diff main...HEAD` has output -> code, else design |
| scope       | Always `git diff main...HEAD`                          |
| context     | Directory name pattern (see 1.3.2)                     |

Default: 10 parallel (cx x 5 + cc x 5)

### 1.2. Priority (Code Review)

| Priority | Role         | Focus                  |
| -------- | ------------ | ---------------------- |
| 1        | security     | OWASP, vulnerabilities |
| 2        | architecture | Patterns, structure    |
| 3        | historian    | History, context       |
| 4        | code         | Quality, readability   |
| 5        | qa           | Edge cases, acceptance |

For design review: replace `code` with `data` (Data model, schema).
Assign: cx first (1-5), then cc (1-5). cx manages token usage of cc.

### 1.3. Scope and Context

#### 1.3.1. Scope (Review Target) - Always Local

| Scope | Command                 | When                       |
| ----- | ----------------------- | -------------------------- |
| diff  | `git diff main...HEAD`  | Default. Branch changes    |
| file  | Read the file at {path} | User specifies a file path |

#### 1.3.2. Context (Metadata) - Auto-detected from Directory Name

Detect PR/Issue number from current directory name pattern:

- `*-pr-{N}` -> PR worktree -> fetch PR #{N} metadata
- `*-issue-{N}` -> Issue worktree -> fetch Issue #{N} metadata
- Otherwise -> no metadata (diff only)

Detection command:

```bash
basename "$(git rev-parse --show-toplevel)" | grep -oP '(pr|issue)-\K[0-9]+'
```

#### 1.3.3. Context Fetch Procedure

1. Detect type and number from directory name
2. Fetch primary metadata:
   - PR: `gh pr view {N} --json body,comments`
   - Issue: `gh issue view {N} --json body,comments`
3. For PR: parse body for referenced Issues/PRs (`#123`, `Closes #456`, etc.)
   and fetch each with `gh issue view` or `gh pr view`
4. Save all context to `.i9wa4/tmp/review-context.md`

IMPORTANT: For PR reviews, always chase references in the PR body.
Related Issues/PRs provide critical intent and acceptance criteria.

Agent file:
@~/.agents/subagents/reviewer-{ROLE}.md

### 1.4. Review Execution

#### 1.4.1. IMPORTANT: Always execute 10-parallel reviews as standard practice

Always execute the following for design/code reviews:

- cc x 5: Launch reviewer-\* agents in parallel via Task tool
- cx x 5: Execute codex exec sequentially via worker-codex

2-parallel execution (worker-claude + worker-codex only) is prohibited.

Task content template:

```text
[SUBAGENT capability=READONLY]
<!-- REVIEW_SESSION
timestamp: {TS}, source: {SOURCE}, role: {ROLE}
review_type: {REVIEW_TYPE}
-->
Review the diff in .i9wa4/tmp/review-diff.txt from {ROLE} perspective.
Context (PR/Issue metadata): .i9wa4/tmp/review-context.md
Return your review directly. Do NOT create files.
```

#### 1.4.2. Method A: Task Tool (Recommended for Claude Code)

Use Task tool with reviewer agents. Launch multiple Task tools in a single
message for parallel execution with clean output isolation.

```text
Task tool calls (parallel):
- subagent_type: reviewer-security
- subagent_type: reviewer-architecture
- subagent_type: reviewer-historian
- subagent_type: reviewer-code
- subagent_type: reviewer-qa
```

Each reviewer agent reads the agent file automatically.

#### 1.4.3. Method B: Codex CLI Sequential (Recommended for Codex)

NEVER use background processes (`&`) with codex exec -
causes output interleaving.

```bash
for ROLE in security architecture historian code qa; do
  FILE=$(mkoutput --dir reviews --label "${ROLE}-cx")
  codex exec --sandbox workspace-write -C .i9wa4 -o "$FILE" "{task}"
done
```

#### 1.4.4. Method C: Codex CLI Parallel (Advanced)

For true parallelism without output mixing, use separate terminal sessions
or accept that outputs will be written to files (not displayed cleanly).

WARNING: Background execution (`&`) with `wait` causes stderr/stdout mixing.

### 1.5. Parallel Execution for 10-Review (cc x 5 + cx x 5)

IMPORTANT: Start cc and cx reviews simultaneously for true parallelism.

#### 1.5.1. Step 1: Auto-detect and Prepare

Run these steps automatically (no user input needed):

```bash
# 1. Save diff
git diff main...HEAD > .i9wa4/tmp/review-diff.txt

# 2. Detect review_type
if [ -s .i9wa4/tmp/review-diff.txt ]; then
  REVIEW_TYPE="code"
else
  REVIEW_TYPE="design"
fi

# 3. Detect context from directory name
DIR_NAME=$(basename "$(git rev-parse --show-toplevel)")
PR_NUM=$(echo "$DIR_NAME" | grep -oP 'pr-\K[0-9]+' || true)
ISSUE_NUM=$(echo "$DIR_NAME" | grep -oP 'issue-\K[0-9]+' || true)

# 4. Fetch context metadata
CONTEXT_FILE=".i9wa4/tmp/review-context.md"
echo "# Review Context" > "$CONTEXT_FILE"

if [ -n "$PR_NUM" ]; then
  echo "## PR #${PR_NUM}" >> "$CONTEXT_FILE"
  gh pr view "$PR_NUM" --json title,body,comments >> "$CONTEXT_FILE"
  # Chase references: extract #NNN from PR body, fetch each
  gh pr view "$PR_NUM" --json body --jq '.body' \
    | grep -oP '#\K[0-9]+' | sort -u | while read -r REF; do
      echo "## Referenced #${REF}" >> "$CONTEXT_FILE"
      gh issue view "$REF" --json title,body,comments >> "$CONTEXT_FILE" 2>/dev/null \
        || gh pr view "$REF" --json title,body,comments >> "$CONTEXT_FILE" 2>/dev/null \
        || echo "(not found)" >> "$CONTEXT_FILE"
    done
elif [ -n "$ISSUE_NUM" ]; then
  echo "## Issue #${ISSUE_NUM}" >> "$CONTEXT_FILE"
  gh issue view "$ISSUE_NUM" --json title,body,comments >> "$CONTEXT_FILE"
fi
```

#### 1.5.2. Step 2: Launch cc x 5 (Single Message)

In one message, call Task tool 5 times in parallel:

```text
Task tool calls (parallel, single message):
- subagent_type: reviewer-security
- subagent_type: reviewer-architecture
- subagent_type: reviewer-historian
- subagent_type: reviewer-code (or reviewer-data for design review)
- subagent_type: reviewer-qa
```

Each prompt should include:

```text
[SUBAGENT capability=READONLY]
Review from {ROLE} perspective.
Diff: .i9wa4/tmp/review-diff.txt
Context: .i9wa4/tmp/review-context.md
```

#### 1.5.3. Step 3: Launch cx x 5 (Background Processes)

Use file output to avoid interleaving:

```bash
for ROLE in security architecture historian data qa; do
  FILE=$(mkoutput --dir reviews --label "review-${ROLE}-cx")
  codex exec --sandbox workspace-write -o "$FILE" \
    "[SUBAGENT capability=READONLY] Review from ${ROLE} perspective. Diff: .i9wa4/tmp/review-diff.txt Context: .i9wa4/tmp/review-context.md" &
done
wait
```

#### 1.5.4. Step 4: Collect Results

```bash
# Check all review files
ls -la .i9wa4/reviews/*-review-*.md

# Read and summarize
cat .i9wa4/reviews/*-review-*.md
```

#### 1.5.5. Timing Optimization

| Action           | Timing                   |
| ---------------- | ------------------------ |
| Auto-detect/prep | Before starting reviews  |
| Launch cc x 5    | Immediately (Task tool)  |
| Launch cx x 5    | Immediately (background) |
| Collect results  | After wait completes     |

### 1.6. Reviewer Deliberation (Optional)

IMPORTANT: This is an optional phase. Execute only when:

- Running as orchestrator (role name is "orchestrator")
- User explicitly requests comprehensive review with deliberation

For standalone execution, Phase 1 (Section 1.5) alone is sufficient.

After Phase 1 review completion, discuss with critic and guardian to collect
additional findings.

#### 1.6.1. Purpose

1. Collect additional findings from other perspectives
2. Prevent cross-functional oversights
3. Ensure comprehensive multi-angle coverage

#### 1.6.2. Deliberation Prompt

Share all Phase 1 review results with critic and guardian and request
additional findings.

```text
[SUBAGENT capability=READONLY]
<!-- DELIBERATION_SESSION
timestamp: {TS}, role: {ROLE}
review_type: {REVIEW_TYPE}
-->

## Phase 1 Review Results Summary

{List all Phase 1 findings sorted by severity}

## Questions

Based on other reviewers' findings, from your expert perspective ({ROLE}):

1. Are there any additional points to raise?
2. Are there any supplementary points related to other findings?
3. Are there any overlooked perspectives?

Output in the same format as Phase 1 only if there are additional findings.
If no additional findings, explicitly state "No additional findings."
```

#### 1.6.3. Deliberation Execution

Execute 10-parallel (cc x 5 + cx x 5) same as Phase 1.

```text
Task tool calls (parallel, single message):
- subagent_type: reviewer-security (with Phase 1 results)
- subagent_type: reviewer-architecture (with Phase 1 results)
- subagent_type: reviewer-historian (with Phase 1 results)
- subagent_type: reviewer-code or reviewer-data (with Phase 1 results)
- subagent_type: reviewer-qa (with Phase 1 results)
```

#### 1.6.4. Result Files

Save deliberation results to `.i9wa4/reviews/`:

- cc: Use Task tool results directly
- cx: `{timestamp}-deliberation-{ROLE}-cx.md`

### 1.7. Summary Output

Create file:

```bash
mkdir -p .i9wa4/reviews && touch .i9wa4/reviews/summary.md
```

```markdown
# Review Summary

## Target

- Type: {review_type}, Directory: {dir_name}

## Findings by Phase

### Phase 1: Initial Review

| #   | Issue               | Reporter     | Severity | File               |
| --- | ------------------- | ------------ | -------- | ------------------ |
| 1   | {issue description} | {role}-{src} | High     | `path/to/file:123` |

### Phase 2: Deliberation

| #   | Issue                | Reporter     | Triggered By | Severity | File               |
| --- | -------------------- | ------------ | ------------ | -------- | ------------------ |
| 1   | {additional finding} | {role}-{src} | {role}       | Medium   | `path/to/file:456` |

## Coverage Analysis

| Perspective  | Phase 1 | Phase 2 | Total |
| ------------ | ------- | ------- | ----- |
| Security     | N       | M       | N+M   |
| Architecture | N       | M       | N+M   |
| Historian    | N       | M       | N+M   |
| Code/Data    | N       | M       | N+M   |
| QA           | N       | M       | N+M   |
| **Total**    | **X**   | **Y**   | **Z** |
```

## 2. Standalone Usage (Lightweight Mode)

For quick reviews without Reviewer Deliberation:

1. Execute Phase 1 only (Section 1.5)
2. Collect results (Section 1.5.4)
3. Create summary (Section 1.7) with Phase 1 only

Skip Phase 2 (Section 1.6) to reduce execution time and token usage.
