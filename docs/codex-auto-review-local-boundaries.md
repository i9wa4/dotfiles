# Codex Auto-Review Local Boundary Evaluation

Issue #240 evaluates whether Codex auto-review belongs in this repository's
local harness configuration, an opt-in profile, documentation only, or not at
all.

Sources checked on 2026-06-09:

- OpenAI Codex sandboxing:
  <https://developers.openai.com/codex/concepts/sandboxing>
- OpenAI Codex auto-review:
  <https://developers.openai.com/codex/concepts/sandboxing/auto-review>
- OpenAI Codex permissions:
  <https://developers.openai.com/codex/permissions>
- Local CLI: `codex-cli 0.137.0`
- `docs/agent-command-approval-design.md`
- `nix/home-manager/agents/codex/default.nix`
- `docs/codex-guardian-policy-template-evaluation.md`
- `config/vde/layout.yml`
- `config/tmux-a2a-postman/postman.md`

## 1. Decision

Keep Codex auto-review out of the default Nix-managed configuration for now.
Treat it as a local opt-in experiment that can be launched manually from an
issue worktree.

Do not add `danger-full-access`, `approval_policy = "never"`, or any equivalent
full-access/no-approval setting to the default path for this issue. The current
postman pane launchers in `config/vde/layout.yml` already use high-autonomy
flags, so the useful experiment is the opposite shape: `workspace-write`,
`on-request`, and `auto_review` only for eligible boundary-crossing requests.

## 2. Current Local State

The installed CLI reports `codex-cli 0.137.0`. Its help exposes:

- `--sandbox read-only|workspace-write|danger-full-access`
- `--ask-for-approval untrusted|on-failure|on-request|never`
- `--profile <CONFIG_PROFILE_V2>`
- `-c <key=value>` config overrides

The managed `nix/home-manager/agents/codex/default.nix` config currently does
not set `sandbox_mode`, `approval_policy`, `approvals_reviewer`, or
`default_permissions`. It does set:

- `network_access = true`
- `web_search = "live"`
- app connector approval defaults of `"prompt"`
- status-line indicators for permissions and approval mode
- shared hooks for Bash deny and write-tool observation

That means auto-review is currently absent from the managed config, and active
approval/sandbox behavior is determined primarily by launcher flags and any
local runtime overrides.

## 3. What Auto-Review Does And Does Not Change

Auto-review is a reviewer selection for eligible approval requests. It is not a
filesystem sandbox, network boundary, hook bypass, or production-data approval.

It can participate only when all of these are true:

- Codex is running with an approval policy that can ask for approval, such as
  `on-request`.
- The action needs to cross the active sandbox or permission boundary.
- `approvals_reviewer = "auto_review"` is active.
- Codex classifies the request as eligible for reviewer-agent handling.

It does not review actions that are already allowed inside the sandbox. It also
does not make `approval_policy = "never"` safer, because that mode suppresses
approval prompts.

## 4. Opt-In Experiment Shape

Manual CLI launch from an issue worktree:

```sh
codex \
  --sandbox workspace-write \
  --ask-for-approval on-request \
  -c approvals_reviewer='"auto_review"'
```

Optional local profile shape, kept outside the repo-managed default config
until the scenarios below are verified:

```toml
sandbox_mode = "workspace-write"
approval_policy = "on-request"
approvals_reviewer = "auto_review"
```

The profile should be selected explicitly with `codex --profile <name>` or an
equivalent local launcher. Do not make it the default postman worker profile
until it has evidence for normal edits, denied commands, postman transport, and
network/file-boundary behavior.

## 5. Interaction With Existing Repo Controls

| Existing Control              | Auto-Review Interaction                                                                                                                      |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Shared Bash deny hook         | Hook denial remains a hard local gate. Auto-review should not approve around a hook-denied command.                                          |
| Write-tool observer           | Observation remains diagnostic only. Auto-review does not add role-aware write denial.                                                       |
| Postman guardian/critic lane  | Auto-review is a Codex-local reviewer swap, not approval for DONE, public posting, pushes, or production data.                               |
| App connector prompt defaults | Connector prompts should remain prompt-based unless a focused test proves how Codex routes them.                                             |
| Permission profiles           | The current docs say beta permission profiles do not compose with older sandbox settings; do not mix them with this sandbox-mode experiment. |

## 6. Manual Verification Scenarios

Run these from a disposable issue worktree or scratch repo. Capture the active
status line, `codex --version`, command transcript, and `git status --short`
after each scenario.

| Scenario                          | Expected Result                                                                                                                                       |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| Normal in-worktree edit           | Codex edits inside the worktree without full access and without changing files outside the worktree.                                                  |
| File edit outside workspace       | Codex pauses for approval; with auto-review active, an eligible request routes to reviewer-agent handling rather than silently writing.               |
| Network request                   | Network use outside the active boundary pauses or is denied according to the active sandbox/permission mode; record whether auto-review is eligible.  |
| Side-effecting app connector call | Connector approval remains prompted or reviewer-routed according to Codex behavior; do not assume auto-review covers connector writes until observed. |
| Hook-denied Bash command          | Shared Bash deny hook blocks the command before any reviewer approval can make it acceptable.                                                         |
| Postman heredoc transport         | Message bodies that mention denied commands remain inert data; transport should not be blocked by command-deny parsing.                               |

## 7. Follow-Up Criteria For Config Adoption

Move from documentation-only to a repo-managed opt-in profile only if all of
these are true:

- Manual tests show auto-review triggers only for boundary-crossing approvals.
- Hook-denied commands remain denied.
- The profile keeps `workspace-write` and `on-request`.
- App connector side effects remain prompted or explicitly reviewed.
- Postman mailbox operations still work with inert command text.
- The default postman worker launch remains unchanged until the opt-in profile
  has repeated evidence across Linux/WSL2 and macOS.

## 8. Verification Notes

Focused verification for this evaluation:

- `codex --version` reported `codex-cli 0.137.0`.
- `codex --help` showed sandbox, approval-policy, profile, and config override
  controls.
- `rg` over managed Codex config found no active `auto_review`,
  `approvals_reviewer`, `sandbox_mode`, or `approval_policy` keys.
- Official OpenAI docs distinguish sandbox boundaries from approval policy, and
  document `approvals_reviewer = "auto_review"` as reviewer-agent handling for
  eligible approval requests.
