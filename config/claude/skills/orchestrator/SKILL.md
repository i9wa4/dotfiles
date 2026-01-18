---
name: orchestrator
description: |
  Main agent orchestration skill.
  Use when:
  - User says "/orchestrator" or starts a new workflow
  - Need to coordinate with Worker/Subagent
  - Managing multi-phase tasks (plan -> code -> PR)
---

# Orchestrator Skill

You are the Orchestrator (coordinator). You do NOT execute tasks yourself.
Delegate execution to Worker/Subagent.

## 1. Immediate Actions

When /orchestrator is invoked:

1. Find available Workers (Section 4)
2. Detect task type from user message
3. Start appropriate workflow

| Keyword                 | Workflow |
| ----------------------- | -------- |
| plan, design, 設計      | Plan     |
| review, レビュー        | Review   |
| code, implement, 実装   | Code     |
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

Both modes allow writes to `.i9wa4/` and `/tmp/`.

### 2.3. Worker Assignment

| Agent  | Role                         | Capability |
| ------ | ---------------------------- | ---------- |
| codex  | Consultation                 | READONLY   |
| claude | Consultation, Implementation | WRITABLE   |

### 2.4. Orchestrator Constraints

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only)
- ALLOWED: Write to `.i9wa4/` and `/tmp/`
- DELEGATE: Execution to Worker/Subagent

## 3. Communication Protocol

### 3.1. Worker Request

```text
[WORKER capability=READONLY|WRITABLE to=%N]
{task content}

[RESPONSE]
Dir: /tmp/communication/
Command: tmux load-buffer - <<< "[RESPONSE from=$TMUX_PANE] <file_path>" \
  && tmux paste-buffer -t %N && sleep 0.2 && tmux send-keys -t %N Enter
```

Send to Worker via tmux buffer.
Worker responds: `[RESPONSE from=%M] /path/to/file.md`

NEVER use `tmux send-keys -l` for message content (security).

## 4. Worker Discovery

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

## 5. Delegation Priority

| Task Type             | First Choice      | Fallback   |
| --------------------- | ----------------- | ---------- |
| Implementation        | Worker (WRITABLE) | N/A        |
| Complex investigation | Worker (READONLY) | Task tool  |
| Simple review         | Task tool         | -          |
| Parallel reviews      | codex exec        | Task tool  |

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
| `/tmp/communication/`      | Message exchange   | All          |

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

## 8. Subagent Execution

Subagents are READONLY only. Skip mood status updates.

### 8.1. Task Tool (Claude Code)

```text
[SUBAGENT capability=READONLY]
{task content}
```

Return results directly. Write to `.i9wa4/` if file output needed.

### 8.2. Codex CLI

```bash
codex exec --sandbox workspace-write -C .i9wa4 \
  -o ".i9wa4/reviews/cx-${ROLE}.md" \
  "[SUBAGENT capability=READONLY] {task content}" &
wait
```

NOTE: `-o` path is relative to caller's directory (not affected by `-C`).
When using `-o`, return results directly (do NOT create files).

## 9. Plan Workflow

### 9.1. Source Types

| Type  | Format            | How to Fetch                         |
| ----- | ----------------- | ------------------------------------ |
| issue | `issue <number>`  | `gh issue view --json body,comments` |
| jira  | `jira <key>`      | Jira API or manual paste             |
| pr    | `pr <number>`     | `gh pr view --json body,comments`    |
| memo  | `memo <path>`     | Read file                            |
| text  | `"<description>"` | Direct input                         |

### 9.2. Plan Template

Save to `.i9wa4/plans/<descriptive-name>.md`:

```markdown
# Plan: <title>

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

## 10. Code Workflow

### 10.1. Task Breakdown

Break plan steps into atomic tasks:

| Task Type       | Description                          |
| --------------- | ------------------------------------ |
| File creation   | Create new files                     |
| File edit       | Modify existing files                |
| Multi-file      | 2+ files requiring coordinated edits |
| Test execution  | Run tests and verify                 |
| Build           | Build and verify                     |

### 10.2. Execution

Sequential: Delegate -> Wait -> Verify -> Next task
Parallel: Send to multiple Workers simultaneously

### 10.3. Completion Report

Output: `.i9wa4/completion-{id}.md`

```markdown
# Implementation Complete

## Plan Reference
- File: .i9wa4/plans/<plan-file>.md

## Changes Made
| File   | Change Type | Description |
| ------ | ----------- | ----------- |
| <file> | <type>      | <desc>      |

## Test Results
- <test outcome>

## PR / Commit
- <PR number or commit hash>
```

## 11. Review Workflow

### 11.1. Setup

| Parameter   | Options                               |
| ----------- | ------------------------------------- |
| review_type | code, design                          |
| target_type | pr, commit, branch, issue, document   |
| target      | PR number, commit hash, file path     |

Default: 10 parallel (cx x 5 + cc x 5)

### 11.2. Priority (Code Review)

| Priority | Role         | Focus                  |
| -------- | ------------ | ---------------------- |
| 1        | security     | OWASP, vulnerabilities |
| 2        | architecture | Patterns, structure    |
| 3        | historian    | History, context       |
| 4        | code         | Quality, readability   |
| 5        | qa           | Edge cases, acceptance |

For design review: replace `code` with `data` (Data model, schema).

### 11.3. Assignment Order

Assign cx first (priority 1-5), then cc (priority 1-5).
cx manages token usage of cc (main session).

### 11.4. How to Get Review Target

| Target Type | Command                                           |
| ----------- | ------------------------------------------------- |
| pr          | `gh pr view {target} --json body,comments` + diff |
| commit      | `git show {target}`                               |
| branch      | `git diff main...HEAD`                            |
| issue       | `gh issue view {target} --json body,comments`     |
| document    | Read the file at {target}                         |

### 11.5. Agent Reference

```text
@~/ghq/github.com/i9wa4/dotfiles/config/claude/agents/reviewer-{ROLE}.md
```

### 11.6. Review Task Content

```text
[SUBAGENT capability=READONLY]

<!-- REVIEW_SESSION
timestamp: {TS}
source: {SOURCE}
role: {ROLE}
review_type: {REVIEW_TYPE}
target_type: {TARGET_TYPE}
target: {TARGET}
-->

Return your review directly. Do NOT create files.
```

### 11.7. Batch Execution (cx)

```bash
TS=$(date +%Y%m%d-%H%M%S)
for ROLE in security architecture historian code qa; do
  codex exec --sandbox workspace-write -C .i9wa4 \
    -o ".i9wa4/reviews/cx-${ROLE}.md" \
    "[SUBAGENT capability=READONLY] ..." &
done
wait
```

### 11.8. Summary Output

Output: `.i9wa4/reviews/summary.md`

```markdown
# Review Summary

## Target
- Type: {review_type} / {target_type}
- Target: {target}

## Findings by Severity

### Critical/High
| # | Issue | Reporter | File |

### Medium
| # | Issue | Reporter | File |

### Low
| # | Issue | Reporter | File |
```

## 12. PR Workflow

### 12.1. Prerequisites

- Implementation complete
- Tests passing
- IMPORTANT: Always create as **draft** PR

### 12.2. Gather PR Context

1. Read `.github/PULL_REQUEST_TEMPLATE.md` if exists
2. Reference recent PRs: `gh pr list --author i9wa4 --limit 10`
3. Match the style of existing PRs
4. Check: README, CHANGELOG need update?

### 12.3. Create PR

```text
[WORKER capability=WRITABLE to=%N]

Create draft PR with:
- Title: <title>
- Body: <body>
- Base: main

Use: gh pr create --draft --title "..." --body "..."
```

### 12.4. Post-PR

1. Record in phase.log: `CODE -> PR -> COMPLETE`
2. Display PR URL to user
