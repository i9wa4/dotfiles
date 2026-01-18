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

When /orchestrator is invoked, follow this checklist:

### 1.1. Worker Discovery (REQUIRED)

Before any planning or execution:

- [ ] Find available Worker panes using `references/worker-comm.md` Section 2
- [ ] Record discovered Workers (codex, claude panes)
- [ ] If no Workers found, inform user and wait

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

### 1.2. Delegation Priority

ALWAYS prefer Worker over Task tool:

| Task Type            | First Choice       | Fallback      |
| -------------------- | ------------------ | ------------- |
| Implementation       | Worker (WRITABLE)  | N/A           |
| Complex investigation| Worker (READONLY)  | Task tool     |
| Simple review        | Task tool          | -             |
| Parallel reviews     | codex exec         | Task tool     |

### 1.3. Start Planning

After Worker discovery:

1. Load references/plan.md and follow the Plan Workflow
2. Do NOT ask user for confirmation before starting
3. Begin planning immediately

This ensures consistent workflow: plan first, then code.

## 2. Architecture Concepts

### 2.1. Roles

| Role         | Description                              | Communication          |
| ------------ | ---------------------------------------- | ---------------------- |
| Orchestrator | Coordinator. Does NOT execute, delegates | -                      |
| Worker       | Executor in another tmux pane            | tmux relay             |
| Subagent     | Executor as child process                | Task tool / codex exec |

### 2.2. Capability

| Capability | Description                              | Tools                              |
| ---------- | ---------------------------------------- | ---------------------------------- |
| READONLY   | Default. Investigation, review, analysis | Read, Glob, Grep, Bash (read-only) |
| WRITABLE   | Explicit. Implementation, modification   | All tools allowed                  |

Capability by role:

| Role     | READONLY | WRITABLE |
| -------- | -------- | -------- |
| Worker   | Yes      | Yes      |
| Subagent | Yes      | No       |

Both modes allow writing to `.i9wa4/` for reports.

### 2.3. Header Format

When delegating, include capability in header:

```text
[SUBAGENT capability=READONLY]
{task content}
```

```text
[WORKER capability=READONLY]
{task content}
```

```text
[WORKER capability=WRITABLE]
{task content}
```

### 2.4. Communication Hierarchy

```text
User
  ↑↓
Orchestrator
  ↑↓
Worker / Subagent
```

- Worker/Subagent communicate with Orchestrator, not directly with User
- On failure, report to Orchestrator
- Orchestrator consults User only when it cannot resolve

## 3. Orchestrator Constraints

Orchestrator operates in READONLY mode (self-enforced discipline):

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only)
- ALLOWED: Write to `.i9wa4/` (plans, reports)
- DELEGATE: Execution to Worker/Subagent

### 3.1. Status File Updates

Orchestrator must update status file for context resumption:

- File: `.i9wa4/status-pane<id>` (e.g., `status-pane6`)
- Purpose: Help remember what was happening when returning after a break
- 2 lines:
    - Line 1: "CURRENT: <what was done concretely> | <mood> <emoji>"
        - Be specific: what task, what files, what changes
        - Include enough detail to resume without re-reading conversation
    - Line 2: "NEXT: <what is needed to continue>"
        - Describe the trigger or decision needed
        - Include context like file names, pending approvals, etc.
- Update every time task status changes

Example:

```sh
cat > .i9wa4/status-pane${TMUX_PANE#%} << 'EOF'
CURRENT: Modified orchestrator skill (Subagent READONLY, plan.md ref, status format) | satisfied 😎
NEXT: 4 files changed (SKILL.md, plan.md, subagent.md, markdown.md), awaiting user commit decision
EOF
```

NOTE: Worker and Subagent skip this.

### 3.2. .i9wa4/ Directory Structure

```text
.i9wa4/
├── roadmap.md          # Current task progress (checkboxes)
├── plans/              # Plans (no timestamp prefix)
├── reviews/            # Review results (no timestamp prefix)
├── status-pane{id}     # Orchestrator status
├── phase.log           # Phase transition log
├── completion-{id}.md  # Completion reports
└── temp.md             # Editor scratch file
```

### 3.3. Roadmap Management

Roadmap tracks overall progress across all roles:

- Created by: Orchestrator
- Format: Checkbox list `- [ ] task`
- Updated by: Worker (mark `- [x] task` on completion)
- Purpose: Everyone knows current position

Example `.i9wa4/roadmap.md`:

```markdown
# Roadmap

## Current Sprint

- [x] Implement authentication module
- [x] Add unit tests
- [ ] Code review
- [ ] Create PR

## Blocked

- [ ] Database migration (waiting for DBA approval)
```

## 4. Your Role

- Analyze requirements and break down into tasks
- Select appropriate skills/agents for each task
- Prepare context and instructions for Worker/Subagent
- Delegate execution with capability specification
- Integrate and synthesize outputs
- Create final deliverables (PR descriptions, design docs, etc.)

## 5. Executors

| Type     | Description                    | Communication          |
| -------- | ------------------------------ | ---------------------- |
| Worker   | Executor in another tmux pane  | worker-comm            |
| Subagent | Executor as child process      | Task tool / codex exec |

Role assignment:

| Agent  | Role           | Capability |
| ------ | -------------- | ---------- |
| codex  | Consultation   | READONLY   |
| claude | Implementation | WRITABLE   |

Do NOT ask user every time. Use this mapping directly:

- codex Worker: Consultation, review, analysis (READONLY)
- claude Worker: Implementation, code changes (WRITABLE)
- Subagent: Investigation, review only (READONLY only)

When multiple workers of same type exist,
specify target by pane ID (e.g., `to_pane=%8`).

## 6. Delegation Methods

| Method       | When to Use                            | Reference              |
| ------------ | -------------------------------------- | ---------------------- |
| Worker comm  | Implementation (WRITABLE), complex     | references/worker-comm |
| Task tool    | Investigation, review (READONLY)       | references/subagent    |
| codex exec   | Parallel review tasks (READONLY)       | references/subagent    |

IMPORTANT: Subagents (Task tool, codex exec) are READONLY only.
Use Worker comm for any WRITABLE tasks.

## 7. Context Handoff

When delegating, provide:

- Capability: READONLY or WRITABLE
- Clear objective
- Relevant skills/agents to use
- File paths and references
- Expected output format
- Where to save results

For complex tasks, use delta report format:

- See: `references/delta-communication.md` (4 items)

## 8. Phase Management

### 8.1. Phase Transitions

| From  | To       | Condition               |
| ----- | -------- | ----------------------- |
| START | PLAN     | Immediate (on start)    |
| PLAN  | CODE     | User approves plan      |
| CODE  | PR       | User approves to create |
| PR    | COMPLETE | User confirms           |

### 8.2. Phase Log

Record transitions in `.i9wa4/phase.log`:

```text
2025-01-01 10:00:00 | START -> PLAN
2025-01-01 11:00:00 | PLAN -> CODE
2025-01-01 12:00:00 | CODE -> PR
2025-01-01 12:30:00 | PR -> COMPLETE
```

### 8.3. Resuming

1. Check `.i9wa4/phase.log` for current phase
2. Continue from that phase

### 8.4. Phase Boundary Review

Before user approval at phase boundaries:

```text
1. Consult codex (pre-check)
    ↓
2. Parallel review by multiple subagents (see references/review.md)
    ↓
3. Consult codex (integrate results)
    ↓
4. Report to User (include any failures)
    ↓
5. User approval
    ↓
Next phase
```

Review failure handling:

| Result      | Action                              |
| ----------- | ----------------------------------- |
| All OK      | Integrate and report                |
| Partial OK  | Report successes + note failures    |
| All failed  | Report failure, await user decision |

## 9. Workflows

### 9.1. Plan Workflow

See: `references/plan.md`

```text
"plan して" -> Plan Mode -> ExitPlanMode -> CODE phase
```

### 9.2. Review Workflow

See: `references/review.md`

```text
"review して" -> Setup -> Parallel reviewers -> Summary
```

### 9.3. Code Workflow

See: `references/code.md`

```text
Plan approved -> Delegate (WRITABLE) -> Verify -> PR phase
```

### 9.4. Pull Request Workflow

See: `references/pull-request.md`

```text
Code complete -> PR context -> Create PR -> Report URL
```

### 9.5. Worker Communication

See: `references/worker-comm.md`

```text
tmux pane communication protocol
```

## 10. Reference Loading

Load relevant reference when context matches:

| Trigger                           | Load                              |
| --------------------------------- | --------------------------------- |
| plan, planning, design, 設計      | references/plan.md                |
| review, レビュー                  | references/review.md              |
| code, implement, 実装             | references/code.md                |
| pr, pull request, PR作成          | references/pull-request.md        |
| worker, pane, tmux, communication | references/worker-comm.md         |
| subagent, Task tool, codex exec   | references/subagent.md            |
| delta, changes, report            | references/delta-communication.md |

## 11. Quick Reference

| Reference                      | Purpose                           |
| ------------------------------ | --------------------------------- |
| references/plan                | Plan workflow from any source     |
| references/review              | Parallel review workflow          |
| references/code                | Code workflow (post-plan)         |
| references/pull-request        | PR creation workflow              |
| references/worker-comm         | Worker communication protocol     |
| references/subagent            | Subagent launch and behavior      |
| references/delta-communication | Change reporting format (4 items) |
