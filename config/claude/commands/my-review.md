---
description: "Code/Design Review"
---

# my-review

Unified review command for code and design reviews.

## 1. Overview

```text
Claude Code
|
+-- setup (review_type, target_type, target, parallel_count)
|
+-- generate timestamp
|
+-- cx x 5 (Bash background, GPT)
|
+-- cc x 5 (Task tool parallel, Claude)
|
+-- wait all -> .i9wa4/{timestamp}-*-*-*.md
|
+-- integrate results -> summary
```

Default: 10 parallel (cx x 5 + cc x 5)
Priority-based assignment when parallel count is specified.

## 2. Setup Options

### 2.1. Review Type

- code: Code changes (PR, commit, branch)
- design: Design documents (Issue, Markdown, etc.)

### 2.2. Target Type

For code review:

- pr: Pull Request
- commit: Specific commit
- branch: Branch (vs main)

For design review:

- issue: GitHub Issue
- document: Markdown or other docs

### 2.3. Target Value

- PR: number (e.g., 123)
- Commit: hash (e.g., abc1234)
- Branch: name (e.g., feature/xxx)
- Issue: number (e.g., 456)
- Document: path (e.g., docs/design.md)

## 3. Priority and Assignment

### 3.1. Code Review Priority

| Priority | Role         | Focus                  |
| -------- | ------------ | ---------------------- |
| 1        | security     | OWASP, vulnerabilities |
| 2        | architecture | Patterns, structure    |
| 3        | historian    | History, context       |
| 4        | code         | Quality, readability   |
| 5        | qa           | Edge cases, acceptance |

### 3.2. Design Review Priority

| Priority | Role         | Focus                  |
| -------- | ------------ | ---------------------- |
| 1        | security     | OWASP, vulnerabilities |
| 2        | architecture | Patterns, structure    |
| 3        | historian    | History, context       |
| 4        | data         | Data model, schema     |
| 5        | qa           | Edge cases, acceptance |

### 3.3. Assignment Order

Default: 10 (cx x 5 + cc x 5)

Assign cx first to manage token usage of cc (main session).
Follow priority order from 3.1/3.2.

| #  | Assignee      |
| -- | ------------- |
| 1  | cx-priority-1 |
| 2  | cx-priority-2 |
| 3  | cx-priority-3 |
| 4  | cx-priority-4 |
| 5  | cx-priority-5 |
| 6  | cc-priority-1 |
| 7  | cc-priority-2 |
| 8  | cc-priority-3 |
| 9  | cc-priority-4 |
| 10 | cc-priority-5 |

## 4. Execution Flow

1. Generate shared timestamp: `date +%Y%m%d-%H%M%S`
2. Determine assignments based on parallel count and priority
3. Launch cx reviewers (Bash background): `codex exec ... &`
4. Launch cc reviewers (Task tool parallel)
5. Wait for all reviewers
6. Read results: `.i9wa4/{timestamp}-*-*-*.md`
7. Integrate and output summary

## 5. Templates

### 5.1. Session Info Format

```text
<!-- REVIEW_SESSION
timestamp: {TS}
source: cc | cx
role: {ROLE}
short_id: {ID}
output_file: .i9wa4/{TS}-{source}-{ROLE}-{ID}.md
review_type: code | design
target_type: pr | commit | branch | issue | document
target: {TARGET}
-->
```

### 5.2. How to Get Review Target

Based on target_type:

- pr: `gh pr view {target} --json body,comments` + `git diff main...HEAD`
- commit: `git show {target}`
- branch: `git diff main...HEAD`
- issue: `gh issue view {target} --json body,comments`
- document: Read the file at {target}

### 5.3. Agent Reference

Load agent definition based on role:

```text
@~/ghq/github.com/i9wa4/dotfiles/config/claude/agents/reviewer-{ROLE}.md
```

### 5.4. Review Task Content

Common task content for both Task tool and codex exec.

Variables:

- `TS`: Shared timestamp from Step 1
- `SOURCE`: cc (Task tool) or cx (codex exec)
- `ID`: `openssl rand -hex 2`
- `ROLE`: From priority table
- `REVIEW_TYPE`: code or design
- `TARGET_TYPE`: pr, commit, branch, issue, or document
- `TARGET`: Target value

```text
<!-- REVIEW_SESSION
timestamp: {TS}
source: {SOURCE}
role: {ROLE}
short_id: {ID}
output_file: .i9wa4/{TS}-{SOURCE}-{ROLE}-{ID}.md
review_type: {REVIEW_TYPE}
target_type: {TARGET_TYPE}
target: {TARGET}
-->

Refer to "How to Get Review Target" for review target.
Refer to "Agent Reference" for agent definition.

Save results to: .i9wa4/{TS}-{SOURCE}-{ROLE}-{ID}.md
```

### 5.5. Launching Reviewers

Use subagent.md "Subagent Prompt Template" with the task content above.

- Task tool: Call Task tool with the prompt
- Codex CLI: `codex exec --sandbox danger-full-access "..."`
    - Append `&` for parallel execution

<!-- NOTE: Batch execution example for reference.
     Shell variables must be expanded before passing to codex exec. -->

```bash
TS=$(date +%Y%m%d-%H%M%S) && \
REVIEW_TYPE=code && \
TARGET_TYPE=commit && \
TARGET=abc1234 && \
for ROLE in security architecture historian code qa; do
  ID=$(openssl rand -hex 2)
  codex exec --sandbox danger-full-access "[SUBAGENT MODE] ...
timestamp: ${TS}
role: ${ROLE}
...
Save results to: .i9wa4/${TS}-cx-${ROLE}-${ID}.md" &
done
wait
```

For design review: use ROLE list `security architecture data qa historian`

## 6. Summary Output

After all complete, create integrated summary.

Output: `.i9wa4/{timestamp}-summary-{id}.md`

```markdown
# Review Summary

## Target

- Type: {review_type} / {target_type}
- Target: {target}

## Findings by Severity

### Critical/High

| # | Issue | Reporter | File |
|---|-------|----------|------|

### Medium

| # | Issue | Reporter | File |
|---|-------|----------|------|

### Low

| # | Issue | Reporter | File |
|---|-------|----------|------|

## Detailed Findings

(Merged from each reviewer's output)
```
