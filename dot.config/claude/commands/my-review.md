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
| 2        | code         | Quality, readability   |
| 3        | architecture | Patterns, structure    |
| 4        | qa           | Edge cases, acceptance |
| 5        | historian    | History, context       |

### 3.2. Design Review Priority

| Priority | Role         | Focus                  |
| -------- | ------------ | ---------------------- |
| 1        | security     | OWASP, vulnerabilities |
| 2        | architecture | Patterns, structure    |
| 3        | data         | Data model, schema     |
| 4        | qa           | Edge cases, acceptance |
| 5        | historian    | History, context       |

### 3.3. Assignment Order

Default: 10 (cc x 5 + cx x 5)

If parallel count specified, assign by priority with cc first:

| #   | Code            | Design          |
| --- | --------------- | --------------- |
| 1   | cc-security     | cc-security     |
| 2   | cc-code         | cc-architecture |
| 3   | cc-architecture | cc-data         |
| 4   | cc-qa           | cc-qa           |
| 5   | cc-historian    | cc-historian    |
| 6   | cx-security     | cx-security     |
| 7   | cx-code         | cx-architecture |
| 8   | cx-architecture | cx-data         |
| 9   | cx-qa           | cx-qa           |
| 10  | cx-historian    | cx-historian    |

Example: parallel=3 for code -> cc-security, cc-code, cc-architecture

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
@~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/reviewer-{ROLE}.md
```

### 5.4. CC Template (Task tool)

```text
{SESSION_INFO from 5.1}

Refer to Section 5.2 for how to get review target.
Refer to Section 5.3 for agent definition.

Target: {TARGET}

Save results to: {output_file}
```

### 5.5. CX Template (codex exec)

Single execution:

```bash
TS=$(date +%Y%m%d-%H%M%S) && \
ID=$(openssl rand -hex 2) && \
ROLE=security && \
REVIEW_TYPE=code && \
TARGET_TYPE=pr && \
TARGET=123 && \
codex exec -s workspace-write --add-dir /tmp "<!-- REVIEW_SESSION
timestamp: ${TS}
source: cx
role: ${ROLE}
short_id: ${ID}
output_file: .i9wa4/${TS}-cx-${ROLE}-${ID}.md
review_type: ${REVIEW_TYPE}
target_type: ${TARGET_TYPE}
target: ${TARGET}
-->

Refer to my-review.md Section 5.2 for how to get review target.

Load agent: @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/reviewer-${ROLE}.md

Save results to: .i9wa4/${TS}-cx-${ROLE}-${ID}.md"
```

Batch execution (5 parallel):

```bash
TS=$(date +%Y%m%d-%H%M%S) && \
REVIEW_TYPE=code && \
TARGET_TYPE=pr && \
TARGET=123 && \
for ROLE in security code architecture qa historian; do
  ID=$(openssl rand -hex 2)
  codex exec -s workspace-write --add-dir /tmp "<!-- REVIEW_SESSION
timestamp: ${TS}
source: cx
role: ${ROLE}
short_id: ${ID}
output_file: .i9wa4/${TS}-cx-${ROLE}-${ID}.md
review_type: ${REVIEW_TYPE}
target_type: ${TARGET_TYPE}
target: ${TARGET}
-->

Refer to my-review.md Section 5.2 for how to get review target.

Load agent: @~/ghq/github.com/i9wa4/dotfiles/dot.config/claude/agents/reviewer-${ROLE}.md

Save results to: .i9wa4/${TS}-cx-${ROLE}-${ID}.md" &
done
wait
```

For design: change ROLE list to `security architecture data qa historian`

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
