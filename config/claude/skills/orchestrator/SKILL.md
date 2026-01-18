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

| Keyword                 | Workflow | Reference                  |
| ----------------------- | -------- | -------------------------- |
| plan, design, 設計      | Plan     | references/plan.md         |
| review, レビュー        | Review   | references/review.md       |
| code, implement, 実装   | Code     | references/code.md         |
| pr, pull request        | PR       | references/pull-request.md |

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
Command: tmux load-buffer - <<< "[RESPONSE from=$TMUX_PANE] <file_path>" && tmux paste-buffer -t %N && sleep 0.2 && tmux send-keys -t %N Enter
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
    ps -ax -o ppid,command | grep -v grep | grep -F "$agent" | grep -q "^\s*$pid" && echo "$id"
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
Consult both Workers (codex + claude) -> Fix -> Parallel review -> User approval

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
# Roadmap: Authentication Feature

## Phase: PLAN

- [x] Read Issue #123 requirements
- [x] Investigate existing auth code
- [x] Consult codex and claude Workers
- [x] Create plan document (.i9wa4/plans/auth-plan.md)
- [x] Parallel review (5 reviewers)
- [x] User approval

## Phase: CODE

- [x] Implement JWT middleware (src/auth/middleware.ts)
- [x] Add UserToken type (src/types/user.ts)
- [x] Update login endpoint (src/api/login.ts)
- [x] Add unit tests (tests/auth.test.ts)
- [x] Consult codex and claude Workers
- [ ] Fix: Add token expiry validation (reviewer feedback)
- [ ] Parallel review (3 reviewers)
- [ ] User approval

## Phase: PR

- [ ] Consult codex and claude Workers
- [ ] Create draft PR
- [ ] User review and merge

## Blocked

- [ ] Database schema update (waiting for DBA approval)
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
