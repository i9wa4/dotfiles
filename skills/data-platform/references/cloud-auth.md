# Cloud Auth

Use this reference when a cloud task requires credentials that are already
available in a user-authenticated shell pane.

## 1. Core Pattern

Do not run interactive cloud login commands in the agent pane. Ask for or use
the user-provided authenticated pane, then send commands to that pane with
`tmux send-keys` and capture output with `tmux capture-pane`.

```sh
tmux send-keys -t <pane_id> 'aws sts get-caller-identity' Enter
sleep 2
tmux capture-pane -t <pane_id> -p
```

## 2. Workflow

1. The user authenticates in their own pane.
2. The user provides the pane ID, or the task context already names it.
3. Confirm credentials with a read-only identity command.
4. Send subsequent cloud commands to that pane.
5. Capture output from that pane for evidence.

## 3. Rules

- Do not run interactive SSO login, credential discovery, or profile selection
  from the agent pane.
- Confirm credentials before real operations.
- Stop for explicit approval before any command that writes cloud resources or
  production data.
- If credentials are expired, report that the user-authenticated pane must be
  refreshed.
