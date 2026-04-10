# AWS Auth Skill

## Core Pattern

Do NOT run AWS CLI commands in the agent's own pane. Execute AWS CLI commands in
the authenticated pane provided by the user (e.g. pane %50). Use
`tmux send-keys` to run commands in that pane.

```sh
# Send a command to the authenticated pane and wait for output
tmux send-keys -t %50 'aws sts get-caller-identity' Enter
sleep 2
tmux capture-pane -t %50 -p
```

## Why This Pattern

All shincorp profiles (`shincorp-stg-admin`, `shincorp-prod-admin`) are
SSO-based. SSO tokens expire and require interactive browser/device auth
(`aws sso login`). The agent cannot do this interactively — the human must
authenticate first in a dedicated pane. Once authenticated, the pane holds valid
session credentials accessible to all commands sent there.

## Workflow

1. User authenticates: `aws sso login --profile shincorp-stg-admin` in their
   pane
2. User provides pane ID (e.g. `%50`) or the agent discovers it from context
3. Agent sends all AWS commands to that pane via `tmux send-keys -t <pane_id>`
4. Agent captures output via `tmux capture-pane -t <pane_id> -p`

## Confirmation Step

Before running real operations, confirm the pane has valid credentials:

```sh
tmux send-keys -t %50 'aws sts get-caller-identity' Enter
sleep 2
tmux capture-pane -t %50 -p | tail -20
```

Expected output includes `Account`, `UserId`, `Arn`. If expired, instruct user
to re-login.

## Key Rules

- WORKERS NEVER HANDLE AUTHENTICATION — do not run `aws sso login`, profile
  discovery, or credential selection
- Before any AWS task, ask messenger which pane has the authenticated shell
- Send all AWS CLI commands to that pane via `tmux send-keys`
- Never attempt `aws sso login`, credential discovery, or profile selection
  yourself
- If the user says "I logged into pane X" — use that pane ID directly via tmux
  send-keys
