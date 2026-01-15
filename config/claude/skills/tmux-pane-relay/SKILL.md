# Tmux Pane Relay Skill

Relay consultation messages between AI panes using tmux.
All AI CLIs are treated as "agents" defined in `agents.toml`.

## 1. Prerequisites

- Both sender and receiver running in the same tmux session/window
- Target pane is interactive (waiting for input)
- `agents.toml` defines detectable agents

## 2. Registry (agents.toml)

Location: `config/claude/skills/tmux-pane-relay/agents.toml`

```toml
[[agent]]
name = "codex"
label = "Codex CLI"
match_current_command = "codex"
match_pane_title = "codex|Codex"
match_process = "codex"

[[agent]]
name = "claude"
label = "Claude Code"
match_current_command = "claude"
match_pane_title = "claude|Claude"
match_process = "claude"
```

- `name` is used by `--to <name>` and in message headers
- `match_*` values are regex strings (skip if empty)

## 3. Detect Panes

### 3.1. Overview

1. `tmux list-panes -F "#{pane_id} #{pane_pid} ..."`
2. Exclude current pane (`tmux display-message -p "#{pane_id}"`)
3. Filter by `match_current_command` and/or `match_pane_title`
4. Confirm with `ps -o command= -p <pid>` and `match_process`
5. If `--to <name>` is provided, restrict to that agent
6. If multiple panes remain, show selection UI (fzf if available)

### 3.2. Find Agent Pane

```bash
find_agent_pane() {
  local target_agent="$1"  # "codex" or "claude"
  local panes=$(tmux list-panes -F "#{pane_pid} #{pane_id}")

  while read -r pane_pid pane_id; do
    if ps -ax -o ppid,command | grep -v grep | grep "$target_agent" | grep -q "^\s*$pane_pid"; then
      echo "$pane_id"
      return 0
    fi
  done <<< "$panes"

  return 1
}
```

## 4. Message Format

### 4.1. Request

```text
[AI REQUEST id=YYYYMMDD-HHMMSS-XXXX from=<sender> pane=<sender_pane> to=<receiver> to_pane=<receiver_pane>]
{request body}

[RESPONSE INSTRUCTIONS]
When done, send response via:
tmux send-keys -t <sender_pane> -l -- "[AI RESPONSE id=YYYYMMDD-HHMMSS-XXXX from=<receiver> pane=<receiver_pane> to=<sender> to_pane=<sender_pane>] {your response}" && sleep 0.5 && tmux send-keys -t <sender_pane> Enter
```

### 4.2. Response

```text
[AI RESPONSE id=YYYYMMDD-HHMMSS-XXXX from=<receiver> pane=<receiver_pane> to=<sender> to_pane=<sender_pane>]
{response body}
```

### 4.3. ID Generation

```bash
id=$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 2)
```

## 5. Send Procedure

### 5.1. Steps

1. Detect sender pane (current pane)
2. Resolve receiver pane via registry
3. Generate message ID
4. Build request with header + response instructions
5. Send with `tmux send-keys -l --`, then `sleep 0.5`, then `Enter`
6. Display "Waiting for AI response..."

### 5.2. Send Command

```bash
tmux send-keys -t <receiver_pane> -l -- "{escaped_message}"
sleep 0.5
tmux send-keys -t <receiver_pane> Enter
```

## 6. Response Handling

When receiving `[AI RESPONSE ...]` in user input:

- Parse the response content using `id` + `from/to + pane`
- Integrate feedback into current work
- Continue with updated understanding

## 7. Long Messages

If the message is long, use tmux buffer:

```bash
tmux load-buffer -b ai_msg /path/to/message.txt
sleep 0.2
tmux paste-buffer -b ai_msg -t <pane_id>
```

## 8. Example Usage

User: "Codexに設計相談して"

Claude Code actions:

1. Find codex pane: `%3`
2. Find claude pane (self): `%2`
3. Generate ID: `20260116-013500-a1b2`
4. Format request with return path
5. Send to codex
6. Display "Codex に相談を送信しました。応答を待っています..."
