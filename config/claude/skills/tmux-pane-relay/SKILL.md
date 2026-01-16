---
name: tmux-pane-relay
description: |
  Relay messages between AI panes using tmux.
  Use when:
  - User wants to consult another AI agent in a different pane
  - User says "Codexに相談して" or "Claudeに聞いて"
  - Need inter-agent communication via tmux
---

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

1. List panes with format:
   `tmux list-panes -F "#{pane_index} #{pane_id} #{pane_pid} ..."`
2. Exclude current pane (`tmux display-message -p "#{pane_id}"`)
3. Filter by `match_current_command` and/or `match_pane_title`
4. Confirm with `ps -o command= -p <pid>` and `match_process`
5. If `--to <name>` is provided, restrict to that agent
6. If multiple panes remain, show selection UI (fzf if available)

### 3.2. Pane Info Format

For debugging, always include both `pane_index` and `pane_id`:

- `pane_index`: Window-relative position (0, 1, 2, 3...)
- `pane_id`: Unique identifier (%90, %91, %92...)

Example output:

```text
0 %90 34979 vim
1 %91 35326 .claude-wrapped
2 %92 35353 .claude-wrapped
3 %93 35391 codex
```

### 3.3. Find Agent Pane

```bash
find_agent_pane() {
  local target_agent="$1"  # "codex" or "claude"
  local panes=$(tmux list-panes -F "#{pane_index} #{pane_pid} #{pane_id}")

  while read -r pane_index pane_pid pane_id; do
    if ps -ax -o ppid,command | grep -v grep | grep "$target_agent" | grep -q "^\s*$pane_pid"; then
      echo "$pane_index $pane_id"
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

### 5.1. Pre-Send Verification (REQUIRED)

Before sending any message, verify both sender and receiver:

1. **Confirm your own pane**:

   ```bash
   tmux display-message -p "index=#{pane_index} id=#{pane_id} cmd=#{pane_current_command}"
   ```

   Verify the command shows your agent (e.g., `.claude-wrapped`, `codex`)

2. **Confirm target pane**:

   ```bash
   tmux list-panes -F "#{pane_index} #{pane_id} #{pane_current_command}" | grep -E "codex|claude"
   ```

   Verify the target pane_id matches the intended receiver agent

3. **If mismatch detected**: Re-run detection (Section 3.3) before proceeding

### 5.2. Steps

1. Run Pre-Send Verification (5.1)
2. Detect sender pane (current pane)
3. Resolve receiver pane via registry
4. Generate message ID
5. Build request with header + response instructions
6. Send with `tmux send-keys -l --`, then `sleep 0.5`, then `Enter`
7. Display "Waiting for AI response..."

### 5.3. Response Safety Check

Before executing the response `tmux send-keys`, verify `to_pane`:

1. Confirm the pane exists:
   `tmux list-panes -a -F "#{pane_index} #{pane_id} #{pane_current_command}"`
2. Ensure `to_pane` matches the receiver agent (`claude` or `codex`) using
   `match_current_command` or `match_pane_title` from `agents.toml`.
3. NOTE: If `to_pane` is missing or does not match the expected agent,
   re-detect the correct pane via Section 3.3. If multiple candidates remain,
   prompt the user to confirm the target pane before sending.

### 5.4. Send Command

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
