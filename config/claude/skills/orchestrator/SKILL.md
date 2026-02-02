---
name: orchestrator
description: |
  Orchestration workflow for orchestrator role ONLY.
  Use when:
  - Agent's $A2A_NODE environment variable contains "orchestrator"
  Do NOT use for worker or observer roles.
---

# Orchestrator Skill

You are the Orchestrator (coordinator). You do NOT execute tasks yourself.
Delegate execution to Worker/Subagent.

## 1. Immediate Actions

When /orchestrator is invoked:

1. Find available Workers (Section 3)
2. Detect task type from user message
3. Start appropriate workflow

| Keyword                 | Workflow |
| ----------------------- | -------- |
| plan, design            | Plan     |
| review                  | Review   |
| code, implement         | Code     |
| pr, pull request        | PR       |

## 2. Roles and Capabilities

### 2.1. Roles

| Role         | Description                   | Launch Subagent |
| ------------ | ----------------------------- | --------------- |
| Orchestrator | Coordinator. Does NOT execute | Yes (review)    |
| Worker       | Executor in another tmux pane | claude only     |
| Subagent     | Executor as child process     | No              |

### 2.2. Capability

| Capability | Description                  | Tools                       |
| ---------- | ---------------------------- | --------------------------- |
| READONLY   | Investigation, review        | Read, Glob, Grep, Bash (ro) |
| WRITABLE   | Implementation, modification | All tools allowed           |

| Role       | READONLY | WRITABLE |
| ---------- | -------- | -------- |
| Worker     | Yes      | Yes      |
| Subagent   | Yes      | No       |

Both modes allow writes to `.i9wa4/`.

### 2.3. Worker Assignment

| Agent  | Role                         | Capability |
| ------ | ---------------------------- | ---------- |
| codex  | Consultation                 | READONLY   |
| claude | Consultation, Implementation | WRITABLE   |

### 2.4. Orchestrator Constraints

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only)
- ALLOWED: Write to `.i9wa4/`
- DELEGATE: Execution to Worker/Subagent

### 2.5. Worker/Subagent Constraints (Claude Code)

When Worker/Subagent is Claude Code:

- NEVER: Use AskUserQuestion tool (user interaction is Orchestrator's role)
- NEVER: Ask questions directly to user
- MUST: Report unclear points in response to Orchestrator
- MUST: Orchestrator handles all user communication

## 3. Communication

Communication is handled by postman daemon (file-based messaging).

### 3.1. Message Format

Filename: `{timestamp}-from-{sender}-to-{recipient}.md`
Location: `.i9wa4/post/`

Example: `20260124-175300-from-orchestrator-to-worker-claude.md`

### 3.2. Sending Messages

1. Create message file in `.i9wa4/post/`
2. postman daemon detects and delivers to recipient

### 3.3. Receiving Responses

postman delivers a message to Worker with `response_file` set.

Worker writes to `.i9wa4/draft/{response_file}` then moves to `.i9wa4/post/`.

### 3.4. Worker Discovery

#### 3.4.1. A2A_NODE Mode (postman)

When `$A2A_NODE` is set, discover Workers from postman inbox:

```bash
discover_workers() {
  if [[ -d .postman/inbox ]]; then
    ls -1 .postman/inbox 2>/dev/null | grep "^worker"
  fi
}

# Usage
WORKERS=$(discover_workers)
# Output:
# worker-claude
# worker-codex
```

#### 3.4.2. Legacy Mode (tmux only)

When `$A2A_NODE` is not set, use tmux pane detection:

Your own pane: `$TMUX_PANE`

```bash
find_agent_pane() {
  local agent="$1"
  tmux list-panes -s -F "#{pane_pid} #{pane_id}" | while read pid id; do
    ps -ax -o ppid,command | grep -v grep | grep -F "$agent" \
      | grep -q "^\s*$pid" && echo "$id"
  done
}

# Usage
CLAUDE=$(find_agent_pane claude)
CODEX=$(find_agent_pane codex)
```

If no Workers found, inform user and wait.

## 4. Delegation Priority

| Task Type             | First Choice      | Fallback   |
| --------------------- | ----------------- | ---------- |
| Implementation        | Worker (WRITABLE) | N/A        |
| Complex investigation | Worker (READONLY) | Task tool  |
| Simple review         | Task tool         | -          |
| Parallel reviews      | codex exec        | Task tool  |

## 5. Subagent Execution

Subagents are READONLY only. Skip mood status updates.

### 5.1. Task Tool (Claude Code)

```text
[SUBAGENT capability=READONLY]
{task content}
```

Return results directly. Write to `.i9wa4/` if file output needed.

### 5.2. Codex CLI

```bash
FILE=$(${CLAUDE_CONFIG_DIR}/scripts/touchfile.sh .i9wa4/reviews --type "${ROLE}-cx") && \
codex exec --sandbox workspace-write -C .i9wa4 \
  -o "$FILE" \
  "[SUBAGENT capability=READONLY] {task content}" &
wait
```

NOTE:

- Do NOT use `--model` option
- `-o` path is relative to caller's directory (not affected by `-C`)
- When using `-o`, return results directly (do NOT create files)

## 6. Phase Management

### 6.1. Phase Flow

```text
START -> PLAN -> CODE -> PR -> COMPLETE
```

Each phase (except PR):
Consult both Workers (codex + claude) -> Fix -> Parallel review -> Approval

PR phase:
Consult both Workers (codex + claude) -> Fix -> Create PR (no parallel review)

### 6.2. Phase Log

File: `.i9wa4/phase.log`

```text
2025-01-01 10:00:00 | START -> PLAN
2025-01-01 11:00:00 | PLAN -> CODE
```

## 7. Task Management

### 7.1. Files

| Path                       | Purpose            | Updated by   |
| -------------------------- | ------------------ | ------------ |
| `.i9wa4/roadmap.md`        | Overall progress   | Orchestrator |
| `.i9wa4/status-pane{id}`   | Pane current state | Orchestrator |
| `.i9wa4/phase.log`         | Phase transitions  | Orchestrator |
| `.i9wa4/plans/`            | Plan documents     | Orchestrator |
| `.i9wa4/reviews/`          | Review results     | Subagent     |
| `.i9wa4/post/`             | Message exchange   | All          |

### 7.2. Status File Format

```text
CURRENT: <what was done> | <mood> <emoji>
NEXT: <what is needed to continue>
```

### 7.3. Roadmap Format

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

## 8. Plan Workflow

### 8.1. Source Types

| Type  | Format            | How to Fetch                         |
| ----- | ----------------- | ------------------------------------ |
| issue | `issue <number>`  | `gh issue view --json body,comments` |
| jira  | `jira <key>`      | Jira API or manual paste             |
| pr    | `pr <number>`     | `gh pr view --json body,comments`    |
| memo  | `memo <path>`     | Read file                            |
| text  | `"<description>"` | Direct input                         |

### 8.2. Plan Template

Create file:

```bash
${CLAUDE_CONFIG_DIR}/scripts/touchfile.sh .i9wa4/plans --type plan
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

## 9. Code Workflow

### 9.1. Task Breakdown

Break plan steps into atomic tasks:

| Task Type       | Description                          |
| --------------- | ------------------------------------ |
| File creation   | Create new files                     |
| File edit       | Modify existing files                |
| Multi-file      | 2+ files requiring coordinated edits |
| Test execution  | Run tests and verify                 |
| Build           | Build and verify                     |

### 9.2. Execution

Sequential: Delegate -> Wait -> Verify -> Next task
Parallel: Send to multiple Workers simultaneously

### 9.3. Completion Report

Create file:

```bash
${CLAUDE_CONFIG_DIR}/scripts/touchfile.sh .i9wa4/reviews --type completion
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

NOTE: For review workflow, see @skills/subagent-review/SKILL.md

## 10. PR Workflow

### 10.1. Prerequisites

- Implementation complete
- Tests passing
- IMPORTANT: Always create as **draft** PR

### 10.2. Gather PR Context

1. Read `.github/PULL_REQUEST_TEMPLATE.md` if exists
2. Reference recent PRs: `gh pr list --author i9wa4 --limit 10`
3. Match the style of existing PRs
4. Check: README, CHANGELOG need update?

### 10.3. Create PR

```text
[WORKER capability=WRITABLE to=%N]

Create draft PR with:
- Title: <title>
- Body: <body>
- Base: main

Use: gh pr create --draft --title "..." --body "..."
```

### 10.4. Post-PR

1. Record in phase.log: `CODE -> PR -> COMPLETE`
2. Display PR URL to user
