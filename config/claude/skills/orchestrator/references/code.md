# Code Workflow

Implementation workflow for executing approved plans.

## 1. Overview

```text
Orchestrator (READONLY)
    |
    +-- 1. Load approved plan from .i9wa4/plans/
    |
    +-- 2. Break down into implementation tasks
    |
    +-- 3. Delegate each task to Worker/Subagent (WRITABLE)
    |
    +-- 4. Collect results and verify
    |
    +-- 5. Create PR or completion report
```

## 2. Prerequisites

- Approved plan exists in `.i9wa4/plans/`
- User has approved the plan via ExitPlanMode
- Implementation steps are clearly defined

## 3. Task Breakdown

Break plan steps into atomic implementation tasks:

| Task Type       | Description                    | Executor   |
| --------------- | ------------------------------ | ---------- |
| File creation   | Create new files               | Subagent   |
| File edit       | Modify existing files          | Subagent   |
| Multi-file      | Changes across multiple files  | Worker     |
| Test execution  | Run tests and verify           | Subagent   |
| Build           | Build and verify               | Subagent   |
| Complex feature | Interactive, iterative work    | Worker     |

## 4. Delegation Templates

See: `rules/subagent.md` for Subagent launch rules.

### 4.1. Simple Task (Subagent)

For isolated, well-defined changes:

```text
[SUBAGENT capability=WRITABLE]

Task: Implement <specific change>

Reference: .i9wa4/plans/<plan-file>.md (Step X)

Changes:
- File: <file path>
- What: <specific change>

Verification:
- <how to verify>

Output: .i9wa4/{timestamp}-cx-impl-{id}.md
```

### 4.2. Complex Task (Worker)

For interactive or multi-step work:

```text
[WORKER capability=WRITABLE]

Task: Implement <feature name>

Reference: .i9wa4/plans/<plan-file>.md (Steps X-Y)

Context:
- <relevant background>
- <design decisions>

Files to modify:
- <file 1>
- <file 2>

Expected outcome:
- <what should work when done>
```

### 4.3. Test and Verify (Subagent)

After implementation:

```text
[SUBAGENT capability=WRITABLE]

Task: Run tests and verify implementation

Reference: .i9wa4/plans/<plan-file>.md (Test Strategy)

Commands:
- <test command>
- <build command>

Report failures to: .i9wa4/{timestamp}-cx-test-{id}.md
```

## 5. Execution Flow

### 5.1. Sequential Execution

For dependent tasks:

```text
1. Delegate Task A (WRITABLE)
2. Wait for completion
3. Verify result
4. Delegate Task B (WRITABLE)
5. ...
```

### 5.2. Parallel Execution

For independent tasks (use codex exec):

```bash
TS=$(date +%Y%m%d-%H%M%S) && \
for TASK in task1 task2 task3; do
  ID=$(openssl rand -hex 2)
  codex exec --sandbox danger-full-access "[SUBAGENT capability=WRITABLE]
Task: ${TASK}
Reference: .i9wa4/plans/plan.md
Output: .i9wa4/${TS}-cx-impl-${ID}.md" &
done
wait
```

## 6. Result Collection

### 6.1. Verify Outputs

Check all implementation outputs:

```bash
ls -la .i9wa4/{timestamp}-*-impl-*.md
```

### 6.2. Run Final Tests

Verify the complete implementation:

```text
[SUBAGENT capability=READONLY]

Task: Final verification of implementation

Run:
- All tests
- Linting
- Build

Report: .i9wa4/{timestamp}-cx-verify-{id}.md
```

## 7. Completion

### 7.1. Git Operations

Delegate commit creation:

```text
[WORKER capability=WRITABLE]

Task: Create commit for implementation

Changes summary:
- <list of changes>

Reference: Plan at .i9wa4/plans/<plan-file>.md

Follow git.md rules for commit message format.
```

### 7.2. PR Creation

Delegate PR creation:

```text
[WORKER capability=WRITABLE]

Task: Create PR for implementation

Title: <PR title>
Base: main
Branch: <feature-branch>

Reference: Plan at .i9wa4/plans/<plan-file>.md

Include:
- Summary of changes
- Test plan
- Related issues
```

### 7.3. Completion Report

Create final report:

Output: `.i9wa4/{timestamp}-completion-{id}.md`

```markdown
# Implementation Complete

## Plan Reference

- File: .i9wa4/plans/<plan-file>.md

## Changes Made

| File           | Change Type | Description |
| -------------- | ----------- | ----------- |
| <file>         | <type>      | <desc>      |

## Test Results

- <test outcome>

## PR / Commit

- <PR number or commit hash>

## Notes

- <any additional notes>
```
