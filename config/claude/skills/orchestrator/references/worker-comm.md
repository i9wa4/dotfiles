# Worker Communication

Protocol for Worker communication via tmux panes.

## 1. Prerequisites

- Both sender and receiver running in the same tmux session/window
- Target pane is interactive (waiting for input)

## 2. Find Worker Pane

```bash
find_agent_pane() {
  local target_agent="$1"
  local panes=$(tmux list-panes -F "#{pane_index} #{pane_pid} #{pane_id}")

  while read -r pane_index pane_pid pane_id; do
    if ps -ax -o ppid,command | grep -v grep | grep -F -- "$target_agent" \
       | grep -q "^\s*$pane_pid"; then
      echo "$pane_index $pane_id"
      return 0
    fi
  done <<< "$panes"

  return 1
}
```

## 3. Buffer and File Management

Orchestrator manages buffer and file lifecycle to prevent command injection.

### 3.1. Directory Structure

```text
/tmp/
└── worker-comm/
    └── {SESSION_TS}-{ORCH}to{WORKER}/
        ├── 001-request.md
        ├── 002-response.md
        ├── 003-request.md
        └── 004-response.md
```

Example: `20260117-155000-6to7/`

### 3.2. Naming Convention

```bash
# Pane numbers (strip %)
MY_NUM=$(echo "${MY_PANE}" | tr -d '%')
TARGET_NUM=$(echo "${TARGET_PANE}" | tr -d '%')

# Session directory (created once per session)
SESSION_TS=$(date +%Y%m%d-%H%M%S)
COMM_DIR="/tmp/worker-comm/${SESSION_TS}-${MY_NUM}to${TARGET_NUM}"
mkdir -p "${COMM_DIR}"

# Buffer name
BUFFER_NAME="msg-${MY_NUM}-${TARGET_NUM}"

# Sequence number (count existing files + 1)
SEQ=$(printf "%03d" $(( $(ls -1 "${COMM_DIR}"/*.md 2>/dev/null | wc -l) + 1 )))
```

### 3.3. Lifecycle

```text
Orchestrator                         Worker
    |                                   |
    +-- create session dir              |
    +-- write 001-request.md            |
    +-- load buffer                     |
    +-- paste to Worker ──────────────> |
    +-- (wait)                          +-- receive request
    |                                   +-- (process)
    |                                   +-- write 002-response.md
    |                                   +-- load buffer (same name)
    | <──────────────── paste to Orch ──+
    +-- receive response                |
    +-- delete buffer                   |
    +-- (files remain for history)      |
```

## 4. Message Format

### 4.1. Request

```text
[WORKER capability=READONLY id=YYYYMMDD-HHMMSS-XXXX from=<sender> pane=<pane> to=<receiver> to_pane=<pane>]
{request body}

[RESPONSE INSTRUCTIONS]
Buffer: msg-<orch_num>-<worker_num>
Response file: /tmp/worker-comm/<session_ts>-<orch>to<worker>/<seq>-response.md
Response via:
cat > <response_file> << 'RESP_EOF'
[WORKER RESPONSE id=... from=<receiver> pane=<pane> to=<sender> to_pane=<pane>]
{response}
RESP_EOF
tmux load-buffer -b "<buffer_name>" <response_file> && \
tmux paste-buffer -b "<buffer_name>" -t <orchestrator_pane> && \
sleep 0.5 && tmux send-keys -t <orchestrator_pane> Enter
```

### 4.2. Response

```text
[WORKER RESPONSE id=YYYYMMDD-HHMMSS-XXXX from=<receiver> pane=<pane> to=<sender> to_pane=<pane>]
{response body}
```

### 4.3. ID Generation

```bash
id=$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 2)
```

## 5. Send Procedure (Orchestrator)

1. Verify your own pane:

   ```bash
   tmux display-message -p "index=#{pane_index} id=#{pane_id}"
   ```

2. Find target Worker pane (Section 2)

3. Setup session directory and names (first time only):

   ```bash
   MY_NUM=$(echo "${MY_PANE}" | tr -d '%')
   TARGET_NUM=$(echo "${TARGET_PANE}" | tr -d '%')
   SESSION_TS=$(date +%Y%m%d-%H%M%S)
   COMM_DIR="/tmp/worker-comm/${SESSION_TS}-${MY_NUM}to${TARGET_NUM}"
   mkdir -p "${COMM_DIR}"
   BUFFER_NAME="msg-${MY_NUM}-${TARGET_NUM}"
   ```

4. Generate sequence number:

   ```bash
   SEQ=$(printf "%03d" $(( $(ls -1 "${COMM_DIR}"/*.md 2>/dev/null | wc -l) + 1 )))
   REQ_FILE="${COMM_DIR}/${SEQ}-request.md"
   RESP_SEQ=$(printf "%03d" $(( SEQ + 1 )))
   RESP_FILE="${COMM_DIR}/${RESP_SEQ}-response.md"
   ```

5. Build request with header + response instructions (include RESP_FILE path)

6. Write message to file:

   ```bash
   cat > "${REQ_FILE}" << 'EOF'
   {message with header and response instructions}
   EOF
   ```

7. Send via buffer:

   ```bash
   tmux load-buffer -b "${BUFFER_NAME}" "${REQ_FILE}"
   tmux paste-buffer -b "${BUFFER_NAME}" -t <target_pane>
   sleep 0.5
   tmux send-keys -t <target_pane> Enter
   ```

8. Display "Waiting for Worker response..."

9. After receiving response, cleanup buffer (files remain):

   ```bash
   tmux delete-buffer -b "${BUFFER_NAME}"
   ```

## 6. Response Procedure (Worker)

1. Receive request with buffer name and response file in RESPONSE INSTRUCTIONS

2. Process request

3. Write response to specified file:

   ```bash
   cat > "${RESP_FILE}" << 'EOF'
   [WORKER RESPONSE id=... from=<me> pane=<my_pane> to=<sender> to_pane=<sender_pane>]
   {response body}
   EOF
   ```

4. Send via same buffer:

   ```bash
   tmux load-buffer -b "${BUFFER_NAME}" "${RESP_FILE}"
   tmux paste-buffer -b "${BUFFER_NAME}" -t <orchestrator_pane>
   sleep 0.5
   tmux send-keys -t <orchestrator_pane> Enter
   ```

## 7. Capability in Messages

Always include capability in the header:

| Capability | When to Use                    |
| ---------- | ------------------------------ |
| READONLY   | Investigation, review, consult |
| WRITABLE   | Implementation, modification   |

Example request with WRITABLE capability:

```text
[WORKER capability=WRITABLE id=20260117-120000-a1b2 from=claude pane=%6 to=codex to_pane=%7]
Implement the authentication module as specified in plan.
Reference: .i9wa4/plans/auth-plan.md

[RESPONSE INSTRUCTIONS]
Buffer: msg-6-7
Response file: /tmp/worker-comm/20260117-120000-6to7/002-response.md
Response via:
cat > /tmp/worker-comm/20260117-120000-6to7/002-response.md << 'RESP_EOF'
[WORKER RESPONSE id=20260117-120000-a1b2 from=codex pane=%7 to=claude to_pane=%6]
{your response}
RESP_EOF
tmux load-buffer -b "msg-6-7" /tmp/worker-comm/20260117-120000-6to7/002-response.md && \
tmux paste-buffer -b "msg-6-7" -t %6 && \
sleep 0.5 && tmux send-keys -t %6 Enter
```

## 8. Security Notes

- NEVER use `tmux send-keys -l -- "{message}"` for message content
- Always use buffer-based communication to prevent command injection
- Orchestrator is responsible for buffer cleanup after receiving response
- Message files remain in `/tmp/worker-comm/` for history and debugging
