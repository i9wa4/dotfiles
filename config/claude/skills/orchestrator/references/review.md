# Review Workflow

Unified review workflow for code and design reviews.

## 1. Overview

```text
Orchestrator
    |
    +-- 1. Setup (review_type, target_type, target)
    |
    +-- 2. Ask user for parallel review count
    |
    +-- 3. Generate timestamp
    |
    +-- 4. Launch cx reviewers (codex exec background)
    |
    +-- 5. Launch cc reviewers (Task tool parallel)
    |
    +-- 6. Wait all -> .i9wa4/reviews/
    |
    +-- 7. Integrate results -> summary
```

Default: 10 parallel (cx x 5 + cc x 5)
Priority-based assignment when parallel count is specified.

For Capability and Header format, see SKILL.md Section 2.2 and 2.3.

## 2. Setup Options

### 2.1. Review Type

| Type   | Description                        |
| ------ | ---------------------------------- |
| code   | Code changes (PR, commit, branch)  |
| design | Design documents (Issue, Markdown) |

### 2.2. Target Type

For code review:

| Type   | Description     |
| ------ | --------------- |
| pr     | Pull Request    |
| commit | Specific commit |
| branch | Branch vs main  |

For design review:

| Type     | Description              |
| -------- | ------------------------ |
| issue    | GitHub Issue             |
| document | Markdown or other docs   |

### 2.3. Target Value

| Target Type | Value Example      |
| ----------- | ------------------ |
| pr          | 123                |
| commit      | abc1234            |
| branch      | feature/xxx        |
| issue       | 456                |
| document    | docs/design.md     |

## 3. Ask Parallel Count

Before launching reviewers, ask user:

```text
How many parallel reviewers? (default: 10)
- 10: Full review (cx x 5 + cc x 5)
- 5: Half review (cx x 5 only)
- Custom: Specify number
```

## 4. Priority and Assignment

### 4.1. Code Review Priority

| Priority | Role         | Focus                  |
| -------- | ------------ | ---------------------- |
| 1        | security     | OWASP, vulnerabilities |
| 2        | architecture | Patterns, structure    |
| 3        | historian    | History, context       |
| 4        | code         | Quality, readability   |
| 5        | qa           | Edge cases, acceptance |

### 4.2. Design Review Priority

| Priority | Role         | Focus                  |
| -------- | ------------ | ---------------------- |
| 1        | security     | OWASP, vulnerabilities |
| 2        | architecture | Patterns, structure    |
| 3        | historian    | History, context       |
| 4        | data         | Data model, schema     |
| 5        | qa           | Edge cases, acceptance |

### 4.3. Assignment Order

Default: 10 (cx x 5 + cc x 5)

Assign cx first to manage token usage of cc (main session).
Follow priority order from 4.1/4.2.

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

## 5. Execution Flow

1. Ask user for parallel review count
2. Generate shared timestamp: `date +%Y%m%d-%H%M%S`
3. Determine assignments based on parallel count and priority
4. Launch cx reviewers (Bash background): `codex exec ... &`
5. Launch cc reviewers (Task tool parallel)
6. Wait for all reviewers
7. Read results from `.i9wa4/reviews/`
8. Integrate and output summary

## 6. Templates

### 6.1. Session Info Format

```text
<!-- REVIEW_SESSION
timestamp: {TS}
source: cc | cx
role: {ROLE}
short_id: {ID}
output_file: .i9wa4/reviews/{source}-{ROLE}.md
review_type: code | design
target_type: pr | commit | branch | issue | document
target: {TARGET}
-->
```

### 6.2. How to Get Review Target

Based on target_type:

| Target Type | Command                                                |
| ----------- | ------------------------------------------------------ |
| pr          | `gh pr view {target} --json body,comments` + diff      |
| commit      | `git show {target}`                                    |
| branch      | `git diff main...HEAD`                                 |
| issue       | `gh issue view {target} --json body,comments`          |
| document    | Read the file at {target}                              |

### 6.3. Agent Reference

Load agent definition based on role:

```text
@~/ghq/github.com/i9wa4/dotfiles/config/claude/agents/reviewer-{ROLE}.md
```

### 6.4. Review Task Content

Common task content for both Task tool and codex exec.

Variables:

| Variable    | Description                    |
| ----------- | ------------------------------ |
| TS          | Shared timestamp from Step 2   |
| SOURCE      | cc (Task tool) or cx (codex)   |
| ID          | `openssl rand -hex 2`          |
| ROLE        | From priority table            |
| REVIEW_TYPE | code or design                 |
| TARGET_TYPE | pr, commit, branch, issue, doc |
| TARGET      | Target value                   |

```text
[SUBAGENT capability=READONLY]

<!-- REVIEW_SESSION
timestamp: {TS}
source: {SOURCE}
role: {ROLE}
short_id: {ID}
review_type: {REVIEW_TYPE}
target_type: {TARGET_TYPE}
target: {TARGET}
-->

Refer to "How to Get Review Target" for review target.
Refer to "Agent Reference" for agent definition.

Return your review directly as your response. Do NOT create files.
```

### 6.5. Launching Reviewers

See: `references/subagent.md` for launch details and prompt template.

Task tool (cc):

```text
Call Task tool with the prompt (parallel execution)
```

Codex CLI (cx):

See `references/subagent.md` Section 4 for sandbox settings.

```bash
# Use -o to capture output (path relative to caller, not affected by -C)
codex exec --sandbox workspace-write -C .i9wa4 \
  -o ".i9wa4/reviews/cx-${ROLE}.md" \
  "[SUBAGENT capability=READONLY] ..." &
```

Batch execution example:

```bash
TS=$(date +%Y%m%d-%H%M%S) && \
REVIEW_TYPE=code && \
TARGET_TYPE=commit && \
TARGET=abc1234 && \
for ROLE in security architecture historian code qa; do
  ID=$(openssl rand -hex 2)
  codex exec --sandbox workspace-write -C .i9wa4 \
    -o ".i9wa4/reviews/cx-${ROLE}.md" \
    "[SUBAGENT capability=READONLY]
timestamp: ${TS}
role: ${ROLE}
...
Return your review directly. Do NOT create files." &
done
wait  # Required: wait for all background jobs
```

NOTE: `-o` path is relative to caller's directory (not affected by `-C`).

For design review: use ROLE list `security architecture historian data qa`

## 7. Summary Output

After all complete, create integrated summary.

Output: `.i9wa4/reviews/summary.md`

```markdown
# Review Summary

## Target

- Type: {review_type} / {target_type}
- Target: {target}

## Findings by Severity

### Critical/High

| #   | Issue | Reporter | File |
| --- | ----- | -------- | ---- |

### Medium

| #   | Issue | Reporter | File |
| --- | ----- | -------- | ---- |

### Low

| #   | Issue | Reporter | File |
| --- | ----- | -------- | ---- |

## Detailed Findings

(Merged from each reviewer's output)
```
