---
name: tmux
description: |
  tmux pane operations guide for debugging and monitoring separate panes
  Use when:
  - Sending commands to another tmux pane
  - Capturing output from another tmux pane
  - Monitoring long-running commands in separate panes
  - Debugging devcontainer build/up operations
  - Working with multiple panes in parallel
---

# tmux Pane Operations

This skill provides a guide for interacting with separate tmux panes.

## 1. Basic Commands

### 1.1. Send Commands to Another Pane

```bash
tmux send-keys -t %N "command" Enter
```

- `%N`: Target pane ID (e.g., `%33`, `%42`)
- `"command"`: Command to execute in the target pane
- `Enter`: Simulate pressing Enter key to execute the command

IMPORTANT: `"command"` and `Enter` MUST be on the same line.
If separated by a newline, the newline is treated as premature Enter.

IMPORTANT: When sending multiple commands consecutively,
always add `sleep 1` between each send-keys call.
Without the delay, commands may be dropped or concatenated.

### 1.2. Capture Output from Another Pane

```bash
tmux capture-pane -t %N -p
```

- `-t %N`: Target pane ID
- `-p`: Print captured content to stdout

### 1.3. Capture Specific Lines

```bash
# Capture last N lines
tmux capture-pane -t %N -p | tail -N

# Capture first N lines
tmux capture-pane -t %N -p | head -N

# Capture with line range
tmux capture-pane -t %N -p -S -100 -E -1
```

- `-S`: Start line (negative values count from bottom)
- `-E`: End line (negative values count from bottom)

## 2. Common Workflows

### 2.1. Execute Command and Monitor Progress

```bash
# Step 1: Send command
tmux send-keys -t %33 "long-running-command" Enter

# Step 2: Wait for initial output
sleep 3

# Step 3: Check progress
tmux capture-pane -t %33 -p | tail -20

# Step 4: Continue monitoring if needed
sleep 10 && tmux capture-pane -t %33 -p | tail -20
```

### 2.2. devcontainer Build/Up Monitoring

```bash
# Send build command
tmux send-keys -t %33 "devcontainer build --workspace-folder /path/to/project" Enter

# Monitor build progress (check every 10-15 seconds)
sleep 10 && tmux capture-pane -t %33 -p | tail -25

# Verify completion
tmux capture-pane -t %33 -p | tail -30
```

### 2.3. Parallel Task Execution

```bash
# Start multiple tasks in different panes (sleep 1 between each)
tmux send-keys -t %33 "task1" Enter
sleep 1
tmux send-keys -t %34 "task2" Enter
sleep 1
tmux send-keys -t %35 "task3" Enter

# Check all panes
tmux capture-pane -t %33 -p | tail -10
tmux capture-pane -t %34 -p | tail -10
tmux capture-pane -t %35 -p | tail -10
```

## 3. Best Practices

### 3.1. Timing Considerations

- YOU MUST: Add `sleep 1` between consecutive send-keys calls
- Add `sleep` between send-keys and capture-pane for commands that take time
- Adjust sleep duration based on expected command execution time
- For long-running commands, use multiple capture-pane calls with intervals

### 3.2. Output Verification

- Use `tail -N` to focus on recent output
- Check for success/error indicators in output
- Look for completion messages or status codes

### 3.3. Error Handling

- If output shows errors, capture more context with larger tail values
- Use full capture (`tmux capture-pane -t %N -p`) for comprehensive debugging
- Check for timeout or hang conditions

## 4. Common Use Cases

### 4.1. Container Operations

- devcontainer build/up monitoring
- Docker compose operations
- Container log monitoring

### 4.2. Build Systems

- Long compilation processes
- Test suite execution
- Deployment pipelines

### 4.3. Development Workflows

- Running development servers in separate panes
- Watching file changes
- Running multiple services simultaneously

## 5. Pane Identification

```bash
# List all panes with IDs
tmux list-panes -a

# Get current pane ID
tmux display-message -p '#{pane_id}'
```

## 6. Notes

- Pane IDs persist within a tmux session
- Use unique pane IDs (%N format) for reliable targeting
- Commands sent via send-keys execute in the target pane's context
- Captured output reflects the current visible content of the pane
