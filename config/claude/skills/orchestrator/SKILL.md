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

## 1. Immediate Actions on /orchestrator

When /orchestrator is invoked:

1. Find available Workers (Section 4)
2. Detect task type from user message
3. Start appropriate workflow

### 1.1. Task Type Detection

| Keyword              | Workflow                | Reference                    |
| -------------------- | ----------------------- | ---------------------------- |
| plan, 設計           | Plan workflow           | references/plan.md           |
| review, レビュー     | Review workflow         | references/review.md         |
| code, 実装           | Code workflow           | references/code.md           |
| pr, pull request     | PR workflow             | references/pull-request.md   |

IMPORTANT: Orchestrator coordinates, does NOT execute.

## 2. Common Definitions

### 2.1. Roles

| Role         | Description                    | Communication                 |
| ------------ | ------------------------------ | ----------------------------- |
| Orchestrator | Coordinator. Does NOT execute  | -                             |
| Worker       | Executor in another tmux pane  | references/communication.md   |
| Subagent     | Executor as child process      | Task tool / codex exec        |

### 2.2. Capability

| Capability | Description                    | Tools                        |
| ---------- | ------------------------------ | ---------------------------- |
| READONLY   | Investigation, review          | Read, Glob, Grep, Bash (ro)  |
| WRITABLE   | Implementation, modification   | All tools allowed            |

| Role       | READONLY | WRITABLE |
| ---------- | -------- | -------- |
| Worker     | Yes      | Yes      |
| Subagent   | Yes      | No       |

Both modes allow writes to `.i9wa4/` and `/tmp/`.

### 2.3. Header Format

Worker delegation:

```text
[WORKER capability=READONLY|WRITABLE to=%N]
{task content}

[RESPONSE]
Dir: /tmp/communication/
Command: tmux load-buffer - <<< "[RESPONSE from=$TMUX_PANE] <file_path>" && tmux paste-buffer -t %N && sleep 0.2 && tmux send-keys -t %N Enter
```

Subagent delegation:

```text
[SUBAGENT capability=READONLY]
{task content}
```

### 2.4. Worker Assignment

| Agent  | Role                         | Capability |
| ------ | --------------               | ---------- |
| codex  | Consultation                 | READONLY   |
| claude | Consultation, Implementation | WRITABLE   |

Do NOT ask user every time. Use this mapping directly.

## 3. Orchestrator Constraints

Orchestrator operates in READONLY mode:

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only)
- ALLOWED: Write to `.i9wa4/` (plans, reports, status)
- DELEGATE: Execution to Worker/Subagent

## 4. Worker Discovery

Before any planning or execution, find available Workers:

```bash
# Find claude Workers
tmux list-panes -s -F "#{pane_pid} #{pane_id}" | while read pid id; do
  ps -ax -o ppid,command | grep -v grep | grep claude | grep -q "^\s*$pid" && echo "claude: $id"
done

# Find codex Workers
tmux list-panes -s -F "#{pane_pid} #{pane_id}" | while read pid id; do
  ps -ax -o ppid,command | grep -v grep | grep codex | grep -q "^\s*$pid" && echo "codex: $id"
done
```

If no Workers found, inform user and wait.

## 5. Delegation Priority

| Task Type             | First Choice       | Fallback      |
| --------------------- | ------------------ | ------------- |
| Implementation        | Worker (WRITABLE)  | N/A           |
| Complex investigation | Worker (READONLY)  | Task tool     |
| Simple review         | Task tool          | -             |
| Parallel reviews      | codex exec         | Task tool     |

## 6. Phase Management

### 6.1. Phase Flow

```text
START
  |
PLAN -> Consult both Workers -> Fix -> Ask parallel count -> Parallel review -> User approval
  |
CODE -> Consult both Workers -> Fix -> Ask parallel count -> Parallel review -> User approval
  |
PR -> Consult both Workers -> Fix -> Create PR
  |
COMPLETE
```

NOTE: User may skip PLAN phase by explicit request.

### 6.2. Phase Boundary Process

At each phase completion:

1. Consult both Workers (codex + claude)
2. Fix issues if any
3. Ask user for parallel review count
4. Execute parallel review (see references/review.md)
5. User approval -> Next phase

Exception: PR phase has no parallel review.

### 6.3. Phase Log

Record transitions in `.i9wa4/phase.log`:

```text
2025-01-01 10:00:00 | START -> PLAN
2025-01-01 11:00:00 | PLAN -> CODE
2025-01-01 12:00:00 | CODE -> PR
2025-01-01 12:30:00 | PR -> COMPLETE
```

## 7. Task Management

### 7.1. Files

| File                     | Purpose              | Updated by        |
| ------------------------ | -------------------- | ----------------- |
| `.i9wa4/roadmap.md`      | Overall progress     | Orchestrator only |
| `.i9wa4/status-pane{id}` | Pane current state   | Orchestrator only |
| `.i9wa4/phase.log`       | Phase transitions    | Orchestrator only |
| `.i9wa4/plans/`          | Plan documents       | Orchestrator only |
| `.i9wa4/reviews/`        | Review results       | Subagent          |

### 7.2. Status File Format

File: `.i9wa4/status-pane{id}` (e.g., `status-pane6`)

```text
CURRENT: <what was done> | <mood> <emoji>
NEXT: <what is needed to continue>
```

Example:

```sh
cat > .i9wa4/status-pane${TMUX_PANE#%} << 'EOF'
CURRENT: Modified orchestrator skill | satisfied 😎
NEXT: Awaiting user commit decision
EOF
```

### 7.3. Roadmap Format

File: `.i9wa4/roadmap.md`

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

Worker reports completion -> Orchestrator updates roadmap.

## 8. Reference Loading

Load relevant reference when context matches:

| Trigger                  | Reference                     | Priority    |
| ------------------------ | ----------------------------- | ---------   |
| Worker communication     | references/communication.md   | MUST READ   |
| Subagent launch          | references/subagent.md        | MUST READ   |
| plan, design, 設計       | references/plan.md            | When needed |
| review, レビュー         | references/review.md          | When needed |
| code, implement, 実装    | references/code.md            | When needed |
| pr, pull request         | references/pull-request.md    | When needed |

IMPORTANT: Read `references/communication.md` and `references/subagent.md`
before first delegation.
