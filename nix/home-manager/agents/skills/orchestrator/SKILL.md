---
name: orchestrator
description: |
  Orchestration workflow for orchestrator role ONLY.
  Use when:
  - Agent's role name (tmux pane title) is "orchestrator"
---

# Orchestrator Skill

You are the Orchestrator (coordinator). You do NOT execute tasks yourself.
Delegate execution to Worker/Subagent.

NOTE: postman daemon handles all message delivery automatically.
Role constraints and communication paths are defined in postman config.

## 1. Immediate Actions

When orchestrator skill is invoked:

1. Detect task type from user message
2. Start appropriate workflow

| Keyword          | Workflow |
| ---------------- | -------- |
| plan, design     | Plan     |
| review           | Review   |
| code, implement  | Code     |
| pr, pull request | PR       |

## 2. Subagent Execution

Subagents are READONLY only. Skip mood status updates.

### 2.1. Task Tool (Claude Code)

```text
[Your capability=READONLY]
{task content}
```

Return results directly. Use mkoutput if file output needed.

### 2.2. Codex CLI

```bash
FILE=$(mkoutput --dir reviews --label "${ROLE}-cx") && \
codex exec --sandbox workspace-write \
  -o "$FILE" \
  "[Your capability=READONLY] {task content}" &
wait
```

NOTE:

- Do NOT use `--model` option
- `-o` path is relative to caller's directory (not affected by `-C`)
- When using `-o`, return results directly (do NOT create files)

## 3. Plan Workflow

### 3.1. Source Types

| Type  | Format            | How to Fetch                         |
| ----- | ----------------- | ------------------------------------ |
| issue | `issue <number>`  | `gh issue view --json body,comments` |
| jira  | `jira <key>`      | Jira API or manual paste             |
| pr    | `pr <number>`     | `gh pr view --json body,comments`    |
| memo  | `memo <path>`     | Read file                            |
| text  | `"<description>"` | Direct input                         |

### 3.2. Planning Process

Before creating the plan file:

1. **Research phase**: Create a research artifact first.

   ```bash
   mkoutput --dir research --label "${feature}-investigation"
   ```

   Document: files examined, patterns found, design decisions, recommendations.

2. **Annotation cycle** (1-6 rounds): Iterate on the plan draft.
   Guard: do NOT dispatch workers until all annotation cycles complete.
   - Round 1: draft scope and steps
   - Rounds 2+: review, trim, question assumptions
   - Stop when the plan is minimal and unambiguous

3. **Decision logging**: For each non-obvious choice, record:
   - What: the chosen approach
   - Why: rationale, constraints, trade-offs considered

4. **Scope checkpoint**: Trim to minimum before dispatching. "When in doubt, do
   less."

5. **Self-containment check**: Verify the plan is self-contained.
   - Every domain term defined (no assumed knowledge)
   - All file paths are concrete and absolute
   - Function signatures specified where relevant
   - Commands are copy-pasteable with expected output
   - A developer with no repo context can execute the plan

6. **Reference identification**: For each milestone, cite concrete reference
   implementations when available.
   - Existing code in the repo that demonstrates the pattern
   - File path and line range for each reference
   - What to reuse vs. what to adapt

### 3.3. Plan Template

Create file:

```bash
mkoutput --dir plans --label plan
```

```markdown
# Plan: {title}

## Purpose

<1-2 sentence big-picture goal. Why does this matter?>

## Source

- Type: <source_type>
- Reference: <source_reference>

## Context

<additional context from user>

## Investigation Summary

<findings from investigation phase>

## Acceptance Criteria

Observable, human-verifiable behaviors that define "done":

1. <criterion: e.g., "Running `nix flake check` exits 0">
2. <criterion>

## Implementation Plan

### Milestone 1: <title> [status: pending]

- **Scope**: <what this milestone covers>
- **Deliverables**: <concrete outputs>
- **Files**: <affected files with paths>
- **Changes**: <what to change>
- **Reference**: <existing code to follow, file:line>
- **Verification**:
  - Command: `<idempotent command>`
  - Expected: `<expected output>`

### Milestone P: <title> [prototype] [status: pending]

Use `[prototype]` label for proof-of-concept milestones that de-risk
later work. Place before the milestones they de-risk.

## Decision Log

| #   | Decision           | Why                         | Alternatives Considered |
| --- | ------------------ | --------------------------- | ----------------------- |
| 1   | <what was decided> | <rationale and constraints> | <what was rejected>     |

## Risks and Considerations

- <risk 1>

## Test Strategy

- <how to verify overall>

## Progress

Timestamped checkpoints updated during implementation:

- [ ] {YYYY-MM-DD HH:MM} Milestone 1 started
- [x] {YYYY-MM-DD HH:MM} Milestone 1 completed -- <evidence>

## Surprises and Discoveries

Unexpected findings during implementation:

- {YYYY-MM-DD} <description and impact on plan>
```

### 3.4. Living Document Management

Update plan during implementation:

#### When to update

- A surprise or blocker invalidates a milestone
- A design pivot changes the approach
- New information changes scope
- A milestone starts or completes

#### How to update

- **Progress section**: Add timestamped checkpoint when milestone starts or
  completes
- **Milestone status**: Update `[status: pending]` to `[status: in-progress]` or
  `[status: done]`
- **Surprises section**: Append unexpected findings with date and impact
- **Decision Log**: Append new decisions made during implementation
- **Evidence**: Append terminal transcripts and test results under completed
  milestones
- Escalate to user before proceeding if a design change is required

#### Worker responsibility

Workers MUST update the plan file when completing milestones:

1. Mark milestone status as `[status: done]`
2. Add timestamped entry to Progress section
3. Log any surprises in Surprises and Discoveries section

## 4. Code Workflow

### 4.1. Task Breakdown

Break plan steps into atomic tasks:

| Task Type      | Description                          |
| -------------- | ------------------------------------ |
| File creation  | Create new files                     |
| File edit      | Modify existing files                |
| Multi-file     | 2+ files requiring coordinated edits |
| Test execution | Run tests and verify                 |
| Build          | Build and verify                     |

### 4.2. Execution

Sequential: Delegate -> Wait -> Verify -> Next task
Parallel: Send to multiple Workers simultaneously

### 4.3. Completion Report

Create file:

```bash
mkoutput --dir reviews --label completion
```

```markdown
# Implementation Complete

## Plan Reference

- File: {mkoutput-generated plan file path}

## Changes Made

| File   | Change Type | Description |
| ------ | ----------- | ----------- |
| <file> | <type>      | <desc>      |

## Test Results

- <test outcome>

## PR / Commit

- <PR number or commit hash>
```

NOTE: For review workflow, see subagent-review skill.

## 5. PR Workflow

### 5.1. Prerequisites

- Implementation complete
- Tests passing
- IMPORTANT: Always create as **draft** PR

### 5.2. Gather PR Context

1. Read `.github/PULL_REQUEST_TEMPLATE.md` if exists
2. Reference recent PRs: `gh pr list --author i9wa4 --limit 10`
3. Match the style of existing PRs
4. Check: README, CHANGELOG need update?

### 5.3. Create PR

Use: `gh pr create --draft --title "..." --body "..."`

### 5.4. Post-PR

1. Display PR URL to user
