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
    └── {STARTED_AT}-o{ORCH_NUM}-w{WORKER_NUM}/
        ├── 001-request.md
        ├── 002-response.md
        ├── 003-request.md
        └── 004-response.md
```

Example: `20260117-155000-o6-w7/`

### 3.2. Naming Convention

```bash
# Pane numbers (strip %)
ORCH_NUM=$(echo "${ORCHESTRATOR}" | tr -d '%')
WORKER_NUM=$(echo "${WORKER}" | tr -d '%')

# Session directory (created once per session)
STARTED_AT=$(date +%Y%m%d-%H%M%S)
COMM_DIR="/tmp/worker-comm/${STARTED_AT}-o${ORCH_NUM}-w${WORKER_NUM}"
mkdir -p "${COMM_DIR}"

# Buffer name
BUFFER_NAME="msg-o${ORCH_NUM}-w${WORKER_NUM}"

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
    |                                   +-- notify path
    | <──────────────── [RESPONSE ready] path
    +-- read response file              |
    +-- delete buffer                   |
    +-- (files remain for history)      |
```

## 4. Message Format

### 4.1. Request

```text
[WORKER capability=READONLY id=YYYYMMDD-HHMMSS-XXXX started_at=YYYYMMDD-HHMMSS orchestrator=%N worker=%M]
{request body}

[RESPONSE INSTRUCTIONS]
Response file: <response_file_path>
Notify via:
tmux load-buffer -b "<buffer_name>" - <<< "[RESPONSE ready] <response_file_path>"
tmux paste-buffer -b "<buffer_name>" -t <orchestrator_pane>
sleep 1 && tmux send-keys -t <orchestrator_pane> Enter
```

### 4.2. Response Notification

```text
[RESPONSE ready] /tmp/worker-comm/<started_at>-o<orch>-w<worker>/<seq>-response.md
```

Orchestrator reads the file to get full response content.

### 4.3. Response File Content

```text
[WORKER RESPONSE id=YYYYMMDD-HHMMSS-XXXX started_at=YYYYMMDD-HHMMSS orchestrator=%N worker=%M]
{response body}
```

### 4.4. ID Generation

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
   ORCH_NUM=$(echo "${ORCHESTRATOR}" | tr -d '%')
   WORKER_NUM=$(echo "${WORKER}" | tr -d '%')
   STARTED_AT=$(date +%Y%m%d-%H%M%S)
   COMM_DIR="/tmp/worker-comm/${STARTED_AT}-o${ORCH_NUM}-w${WORKER_NUM}"
   mkdir -p "${COMM_DIR}"
   BUFFER_NAME="msg-o${ORCH_NUM}-w${WORKER_NUM}"
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
   sleep 1
   tmux send-keys -t <target_pane> Enter
   ```

8. Wait for `[RESPONSE ready] <path>` notification

9. Read response file content

10. After processing, cleanup buffer (files remain):

    ```bash
    tmux delete-buffer -b "${BUFFER_NAME}"
    ```

## 6. Response Procedure (Worker)

1. Receive request with response file path in RESPONSE INSTRUCTIONS

2. Process request

3. Write response to specified file:

   ```bash
   cat > "${RESP_FILE}" << 'EOF'
   [WORKER RESPONSE id=... started_at=... orchestrator=%N worker=%M]
   {response body}
   EOF
   ```

4. Notify Orchestrator (path only):

   ```bash
   tmux load-buffer -b "${BUFFER_NAME}" - <<< "[RESPONSE ready] ${RESP_FILE}"
   tmux paste-buffer -b "${BUFFER_NAME}" -t <orchestrator_pane>
   sleep 1
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
[WORKER capability=WRITABLE id=20260117-120000-a1b2 started_at=20260117-120000 orchestrator=%6 worker=%7]
Implement the authentication module as specified in plan.
Reference: .i9wa4/plans/auth-plan.md

[RESPONSE INSTRUCTIONS]
Response file: /tmp/worker-comm/20260117-120000-o6-w7/002-response.md
Notify via:
tmux load-buffer -b "msg-o6-w7" - <<< "[RESPONSE ready] /tmp/worker-comm/20260117-120000-o6-w7/002-response.md"
tmux paste-buffer -b "msg-o6-w7" -t %6
sleep 1 && tmux send-keys -t %6 Enter
```

## 8. Security Notes

- NEVER use `tmux send-keys -l -- "{message}"` for message content
- Always use buffer-based communication to prevent command injection
- Orchestrator is responsible for buffer cleanup after receiving response
- Message files remain in `/tmp/worker-comm/` for history and debugging
