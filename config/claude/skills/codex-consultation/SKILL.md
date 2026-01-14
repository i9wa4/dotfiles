---
name: codex-consultation
description: |
  Consult with Codex CLI via tmux send-keys.
  Use when:
  - Need design review or second opinion
  - Want to discuss architecture decisions
  - Need specialized analysis from another AI
---

# Codex Consultation Skill

Consult with Codex CLI running in another tmux pane.
Bidirectional communication via tmux send-keys.

## 1. Prerequisites

- Both Claude Code and Codex CLI running in same tmux window
- Codex CLI must be in interactive mode (waiting for input)

## 2. Workflow

```text
[Claude Code] --send-keys--> [Codex CLI]
                                |
                             (process)
                                |
[Claude Code] <--send-keys-- [Codex CLI]
```

## 3. Detect Panes

### 3.1. Find Codex Pane

```bash
# Get pane list with process info
tmux list-panes -F "#{pane_index} #{pane_pid} #{pane_id}"

# Check if codex is running in each pane
ps -ax -o ppid,command | grep codex | grep -v grep
```

### 3.2. Find Claude Code Pane (for Codex to reply)

```bash
# Same method, look for 'claude' process
ps -ax -o ppid,command | grep claude | grep -v grep
```

## 4. Send Consultation

### 4.1. Message Format

Include return instructions in the consultation:

```text
[CONSULTATION REQUEST]

{your question or design topic}

[RESPONSE INSTRUCTIONS]
When done, send your response to Claude Code pane using:
tmux send-keys -t {claude_pane_id} -l -- '[CODEX RESPONSE] {your response}' && sleep 0.5 && tmux send-keys -t {claude_pane_id} Enter
```

### 4.2. Send Command

IMPORTANT: sleep 0.5 is required between text and Enter.

```bash
# Escape and send
tmux send-keys -t {codex_pane_id} -l -- "{escaped_message}"
sleep 0.5
tmux send-keys -t {codex_pane_id} Enter
```

## 5. Implementation Steps

When user requests consultation:

1. Detect codex pane ID
2. Detect claude pane ID (for return path)
3. Format message with return instructions
4. Send via tmux send-keys
5. Output "Waiting for Codex response..." to user
6. Response arrives as user input with [CODEX RESPONSE] marker

## 6. Example Usage

User: "codexに設計相談して"

Claude Code actions:

1. Find codex pane: `%42`
2. Find claude pane: `%41`
3. Format consultation with return path
4. Send to codex
5. Display "Codex に相談を送信しました. 応答を待っています..."

## 7. Response Handling

When receiving `[CODEX RESPONSE]` in user input:

- Parse the response content
- Integrate feedback into current work
- Continue with updated understanding

## 8. Shell Helper Functions

### 8.1. Find AI CLI Pane

```bash
find_ai_pane() {
  local target_cli="$1"  # "codex" or "claude"
  local panes=$(tmux list-panes -F "#{pane_pid} #{pane_id}")

  while read -r pane_pid pane_id; do
    if ps -ax -o ppid,command | grep -v grep | grep "$target_cli" | grep -q "^\s*$pane_pid"; then
      echo "$pane_id"
      return 0
    fi
  done <<< "$panes"

  return 1
}
```

### 8.2. Send Consultation

```bash
send_consultation() {
  local message="$1"
  local codex_pane=$(find_ai_pane "codex")
  local claude_pane=$(find_ai_pane "claude")

  if [ -z "$codex_pane" ]; then
    echo "Codex pane not found"
    return 1
  fi

  # Format with return instructions (include sleep 0.5)
  local full_message="[CONSULTATION REQUEST]

$message

[RESPONSE INSTRUCTIONS]
When done, send response via:
tmux send-keys -t $claude_pane -l -- '[CODEX RESPONSE] {your response}' && sleep 0.5 && tmux send-keys -t $claude_pane Enter"

  tmux send-keys -t "$codex_pane" -l -- "$full_message"
  sleep 0.5
  tmux send-keys -t "$codex_pane" Enter
}
```

## 9. Important Notes

- Codex must understand the return instruction format
- Long responses may need file-based transfer instead
- Network latency: local tmux is fast, but AI processing takes time
