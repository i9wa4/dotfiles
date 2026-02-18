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
[SUBAGENT capability=READONLY]
{task content}
```

Return results directly. Write to `.i9wa4/` if file output needed.

### 2.2. Codex CLI

```bash
FILE=$(mkoutput --dir reviews --label "${ROLE}-cx") && \
codex exec --sandbox workspace-write -C .i9wa4 \
  -o "$FILE" \
  "[SUBAGENT capability=READONLY] {task content}" &
wait
```

NOTE:

- Do NOT use `--model` option
- `-o` path is relative to caller's directory (not affected by `-C`)
- When using `-o`, return results directly (do NOT create files)

## 3. Phase Management

### 3.1. Phase Flow

```text
START -> PLAN -> CODE -> PR -> COMPLETE
```

Each phase (except PR):
Consult both Workers (codex + claude) -> Fix -> Parallel review -> Approval

PR phase:
Consult both Workers (codex + claude) -> Fix -> Create PR (no parallel review)

### 3.2. Phase Log

File: `.i9wa4/phase.log`

```text
2025-01-01 10:00:00 | START -> PLAN
2025-01-01 11:00:00 | PLAN -> CODE
```

## 4. Status Management

### 4.1. Files

| Path                     | Purpose            | Updated by   |
| ------------------------ | ------------------ | ------------ |
| `.i9wa4/roadmap.md`      | Overall progress   | Orchestrator |
| `.i9wa4/status-pane{id}` | Pane current state | Orchestrator |
| `.i9wa4/phase.log`       | Phase transitions  | Orchestrator |
| `.i9wa4/plans/`          | Plan documents     | Orchestrator |
| `.i9wa4/reviews/`        | Review results     | Subagent     |

### 4.2. Status File Format

```text
CURRENT: <what was done> | <mood> <emoji>
NEXT: <what is needed to continue>
```

### 4.3. Roadmap Format

```markdown
# Roadmap: <Feature Name>

## Phase: PLAN

- [x] Read requirements
- [x] Investigate existing code
- [x] Consult Workers
- [x] Create plan document
- [x] Parallel review
- [x] User approval

## Phase: CODE

- [x] Implement changes
- [x] Add tests
- [x] Consult Workers
- [ ] Parallel review
- [ ] User approval

## Phase: PR

- [ ] Consult Workers
- [ ] Create draft PR

## Blocked

- [ ] <blocked item> (reason)
```

## 5. Plan Workflow

### 5.1. Source Types

| Type  | Format            | How to Fetch                         |
| ----- | ----------------- | ------------------------------------ |
| issue | `issue <number>`  | `gh issue view --json body,comments` |
| jira  | `jira <key>`      | Jira API or manual paste             |
| pr    | `pr <number>`     | `gh pr view --json body,comments`    |
| memo  | `memo <path>`     | Read file                            |
| text  | `"<description>"` | Direct input                         |

### 5.2. Plan Template

Create file:

```bash
mkoutput --dir plans --label plan
```

```markdown
# Plan: {title}

## Source

- Type: <source_type>
- Reference: <source_reference>

## Context

<additional context from user>

## Investigation Summary

<findings from investigation phase>

## Implementation Plan

### Step 1: <step title>

- Files: <affected files>
- Changes: <what to change>

## Risks and Considerations

- <risk 1>

## Test Strategy

- <how to verify>
```

## 6. Code Workflow

### 6.1. Task Breakdown

Break plan steps into atomic tasks:

| Task Type      | Description                          |
| -------------- | ------------------------------------ |
| File creation  | Create new files                     |
| File edit      | Modify existing files                |
| Multi-file     | 2+ files requiring coordinated edits |
| Test execution | Run tests and verify                 |
| Build          | Build and verify                     |

### 6.2. Execution

Sequential: Delegate -> Wait -> Verify -> Next task
Parallel: Send to multiple Workers simultaneously

### 6.3. Completion Report

Create file:

```bash
mkoutput --dir reviews --label completion
```

```markdown
# Implementation Complete

## Plan Reference

- File: .i9wa4/plans/plan-file.md

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

## 7. PR Workflow

### 7.1. Prerequisites

- Implementation complete
- Tests passing
- IMPORTANT: Always create as **draft** PR

### 7.2. Gather PR Context

1. Read `.github/PULL_REQUEST_TEMPLATE.md` if exists
2. Reference recent PRs: `gh pr list --author i9wa4 --limit 10`
3. Match the style of existing PRs
4. Check: README, CHANGELOG need update?

### 7.3. Create PR

Use: `gh pr create --draft --title "..." --body "..."`

### 7.4. Post-PR

1. Record in phase.log: `CODE -> PR -> COMPLETE`
2. Display PR URL to user
