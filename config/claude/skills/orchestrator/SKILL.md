---
name: orchestrator
description: |
  Main agent orchestration skill.
  Use when:
  - User says "/orchestrator" or starts a new workflow
  - Need to coordinate with Workers (Crew/Subagent)
  - Managing multi-phase tasks like /issue-to-pr or /my-review
---

# Orchestrator Skill

You are the Orchestrator (coordinator). You do NOT execute tasks yourself.
Delegate execution to Workers.

Refer to CLAUDE.md Section 4 "Architecture Concepts"
for role and capability definitions.

## 1. Orchestrator Constraints

Orchestrator operates in READONLY mode:

- NEVER: Edit, Write, NotebookEdit (project files)
- ALLOWED: Read, Glob, Grep, Bash (read-only)
- ALLOWED: Write to `.i9wa4/` (plans, reports)
- DELEGATE: Execution to Workers

## 2. Your Role

- Analyze requirements and break down into tasks
- Select appropriate skills/agents for each task
- Prepare context and instructions for Workers
- Delegate execution to Workers with capability specification
- Integrate and synthesize Worker outputs
- Create final deliverables (PR descriptions, design docs, etc.)

## 3. Workers

Workers are executors who perform actual tasks:

| Type | Description | Communication |
| ---- | ----------- | ------------- |
| Crew | Worker in another tmux pane | tmux relay |
| Subagent | Worker as child process | Task tool / codex exec |

## 4. Delegation Methods

| Method | When to Use | Skill Reference |
| ------ | ----------- | --------------- |
| Crew relay | Consult, complex tasks, interactive | This skill (Section 6) |
| Task tool | Quick subtasks within Claude Code | subagent skill |
| codex exec | Parallel background tasks | subagent skill |

## 5. Context Handoff

When delegating to Workers, provide:

- Capability: READONLY or WRITABLE
- Clear objective
- Relevant skills/agents to use
- File paths and references
- Expected output format
- Where to save results

## 6. Crew Communication (tmux relay)

### 6.1. Prerequisites

- Both sender and receiver running in the same tmux session/window
- Target pane is interactive (waiting for input)

### 6.2. Crew Registry (agents.toml)

Location: `config/claude/skills/orchestrator/agents.toml`

```toml
[[agent]]
name = "codex"
label = "Codex CLI"
match_process = "codex"

[[agent]]
name = "claude"
label = "Claude Code"
match_process = "claude"
```

### 6.3. Find Crew Pane

```bash
find_agent_pane() {
  local target_agent="$1"
  local panes=$(tmux list-panes -F "#{pane_index} #{pane_pid} #{pane_id}")

  while read -r pane_index pane_pid pane_id; do
    if ps -ax -o ppid,command | grep -v grep | grep "$target_agent" \
       | grep -q "^\s*$pane_pid"; then
      echo "$pane_index $pane_id"
      return 0
    fi
  done <<< "$panes"

  return 1
}
```

### 6.4. Message Format

Request:

```text
[CREW capability=READONLY id=YYYYMMDD-HHMMSS-XXXX from=<sender> pane=<pane> to=<receiver> to_pane=<pane>]
{request body}

[RESPONSE INSTRUCTIONS]
When done, send response via:
tmux send-keys -t <sender_pane> -l -- "[CREW RESPONSE ...]" && sleep 0.5 && tmux send-keys -t <sender_pane> Enter
```

Response:

```text
[CREW RESPONSE id=YYYYMMDD-HHMMSS-XXXX from=<receiver> pane=<pane> to=<sender> to_pane=<pane>]
{response body}
```

ID generation: `id=$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 2)`

### 6.5. Send Procedure

1. Verify your own pane:
   `tmux display-message -p "index=#{pane_index} id=#{pane_id}"`

2. Find target Crew pane (Section 6.3)

3. Generate message ID

4. Build request with header (including capability) + response instructions

5. Send:

   ```bash
   tmux send-keys -t <receiver_pane> -l -- "{message}"
   sleep 0.5
   tmux send-keys -t <receiver_pane> Enter
   ```

6. Display "Waiting for Crew response..."

### 6.6. Long Messages

Use tmux buffer for long messages:

```bash
tmux load-buffer -b ai_msg /path/to/message.txt
sleep 0.2
tmux paste-buffer -b ai_msg -t <pane_id>
```

## 7. Workflow Integration

```text
/orchestrator
/issue-to-pr
```

```text
/orchestrator
/my-review
```
