# Communication

Protocol for Orchestrator-Worker communication via tmux panes.

## 1. Prerequisites

- Both sender and receiver running in the same tmux session
- Target pane is interactive (waiting for input)

Works across different windows in the same session.

## 2. Find Worker Pane

```bash
find_agent_pane() {
  local target_agent="$1"
  local panes=$(tmux list-panes -s -F "#{pane_pid} #{pane_id}")

  while read -r pane_pid pane_id; do
    if ps -ax -o ppid,command | grep -v grep | grep -F -- "$target_agent" \
       | grep -q "^\s*$pane_pid"; then
      echo "$pane_id"
      return 0
    fi
  done <<< "$panes"

  return 1
}
```

Returns `pane_id` (e.g., `%7`) which works across windows.

## 3. Directory Structure

```text
/tmp/communication/
├── 20260117-120000-a1b2.md
├── 20260117-120500-c3d4.md
└── ...
```

Flat structure. Filename: `timestamp-randomid.md`

## 4. Message Format

### 4.1. Request (Orchestrator -> Worker)

```text
[WORKER capability=READONLY|WRITABLE to=%N]
{task content}

[RESPONSE]
Dir: /tmp/communication/
Command: tmux load-buffer - <<< "[RESPONSE from=$TMUX_PANE] <file_path>" && tmux paste-buffer -t %N && sleep 0.2 && tmux send-keys -t %N Enter
```

### 4.2. Response Notification (Worker -> Orchestrator)

```text
[RESPONSE from=%M] /tmp/communication/20260117-120500-c3d4.md
```

Orchestrator reads the file to get full response content.

## 5. Send Procedure (Orchestrator)

1. Get your own pane ID:

   ```bash
   ORCHESTRATOR="${TMUX_PANE}"  # e.g., %6
   ```

2. Find target Worker pane (Section 2)

3. Create communication directory (first time):

   ```bash
   mkdir -p /tmp/communication
   ```

4. Write request to temp file:

   ```bash
   REQ_FILE="/tmp/communication/req-$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 2).md"
   cat > "${REQ_FILE}" << 'EOF'
   [WORKER capability=WRITABLE to=%6]
   {task content}

   [RESPONSE]
   Dir: /tmp/communication/
   Command: tmux load-buffer - <<< "[RESPONSE from=$TMUX_PANE] <file_path>" && tmux paste-buffer -t %6 && sleep 0.2 && tmux send-keys -t %6 Enter
   EOF
   ```

5. Send via buffer:

   ```bash
   tmux load-buffer "${REQ_FILE}" && tmux paste-buffer -t ${WORKER} && sleep 0.2 && tmux send-keys -t ${WORKER} Enter
   ```

6. Wait for response notification: `[RESPONSE from=%M] <path>`

7. Read response file content

## 6. Response Procedure (Worker)

1. Receive request with response instructions

2. Process request

3. Generate response file:

   ```bash
   RESP_FILE="/tmp/communication/$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 2).md"
   cat > "${RESP_FILE}" << 'EOF'
   {response content}
   EOF
   ```

4. Notify Orchestrator:

   ```bash
   tmux load-buffer - <<< "[RESPONSE from=${TMUX_PANE}] ${RESP_FILE}" && tmux paste-buffer -t %6 && sleep 0.2 && tmux send-keys -t %6 Enter
   ```

## 7. Security Notes

- NEVER use `tmux send-keys -l -- "{message}"` for message content
- Always use buffer-based communication to prevent command injection
- Message files remain in `/tmp/communication/` for history
