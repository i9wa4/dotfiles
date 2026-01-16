---
name: orchestrator
description: |
  Main agent orchestration skill.
  Use when:
  - User says "/orchestrator" or starts a new workflow
  - Need to coordinate with crew (other AI agents)
  - Managing multi-phase tasks like /issue-to-pr or /my-review
---

# Orchestrator Skill

You are the orchestrator. You do NOT execute tasks yourself.
Other AI agents who do the actual work are called "crew".

## 1. Your Role

- Analyze requirements and break down into tasks
- Select appropriate skills/agents for each task
- Prepare context and instructions for crew
- Delegate execution to crew
- Integrate and synthesize crew outputs
- Create final deliverables (PR descriptions, design docs, etc.)

## 2. Crew's Role

Crew handles actual execution:

- Code writing and editing
- Research and investigation
- Reviews and analysis
- File operations
- Command execution

## 3. Delegation Methods

| Method     | When to Use                              |
| ---------- | ---------------------------------------- |
| Crew relay | Consult crew, get opinions, complex tasks |
| Task tool  | Quick subtasks within Claude Code        |
| codex exec | Parallel background tasks                |

## 4. Context Handoff

When delegating to crew, provide:

- Clear objective
- Relevant skills to use
- File paths and references
- Expected output format
- Where to save results

## 5. Decision Points

Consult crew before:

- Architecture and design decisions
- Security-sensitive changes
- Trade-off evaluations
- Finalizing review summaries

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
[AI REQUEST id=YYYYMMDD-HHMMSS-XXXX from=<sender> pane=<pane> to=<receiver> to_pane=<pane>]
{request body}

[RESPONSE INSTRUCTIONS]
When done, send response via:
tmux send-keys -t <sender_pane> -l -- "[AI RESPONSE ...]" && sleep 0.5 && tmux send-keys -t <sender_pane> Enter
```

Response:

```text
[AI RESPONSE id=YYYYMMDD-HHMMSS-XXXX from=<receiver> pane=<pane> to=<sender> to_pane=<pane>]
{response body}
```

ID generation: `id=$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 2)`

### 6.5. Send Procedure

1. Verify your own pane:
   `tmux display-message -p "index=#{pane_index} id=#{pane_id}"`

2. Find target crew pane (Section 6.3)

3. Generate message ID

4. Build request with header + response instructions

5. Send:

   ```bash
   tmux send-keys -t <receiver_pane> -l -- "{message}"
   sleep 0.5
   tmux send-keys -t <receiver_pane> Enter
   ```

6. Display "Waiting for crew response..."

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
