# Agent Command Approval Design

This design documents the current command approval and writable-surface model
for Codex CLI, Claude Code, and the postman-mediated command approval layer.
The May 2026 sections describe runtime permission design for issue #201; the
July 2026 update records the adopted `tmux-a2a-postman execute-bash` contract.

Update checked on 2026-07-13:

- Local `tmux-a2a-postman --version`: `git-c928f9d`.
- Adjacent `tmux-a2a-postman` source repo recent changes include command
  approval through `execute-bash`, reply-delivered approval requests, and the
  migration of the approver marker to the Mermaid `command_approver_node`
  class.
- `diplomat_node` is a separate, not-yet-shipped design issue for
  cross-session edge authorization. Do not configure it in dotfiles until that
  issue lands in `tmux-a2a-postman`.
- This repo currently has `config/tmux-a2a-postman/postman.md` only; there is
  no checked-in `postman.toml` policy file.

Sources checked on 2026-05-30:

- OpenAI Codex sandboxing:
  <https://developers.openai.com/codex/concepts/sandboxing>
- OpenAI Codex auto-review:
  <https://developers.openai.com/codex/concepts/sandboxing/auto-review>
- OpenAI Codex permission profiles:
  <https://developers.openai.com/codex/permissions>
- Claude Code permissions:
  <https://code.claude.com/docs/en/permissions>
- Claude Code settings:
  <https://code.claude.com/docs/en/settings>
- Claude Code sandboxing:
  <https://code.claude.com/docs/en/sandboxing>

## 1. Current Agent Launch Layer

The tmux/vde launcher is the highest-precedence behavior for active panes.
Today `config/vde/layout.yml` starts Codex panes with:

```sh
codex --yolo --add-dir "${SUBDIR}" --model gpt-5.5 --config model_reasoning_effort=xhigh
```

It starts the Claude critic pane with:

```sh
claude --allow-dangerously-skip-permissions --dangerously-skip-permissions \
  --add-dir "${SUBDIR}" \
  --model "opus[1m]" --effort xhigh
```

That means current postman panes are intentionally high-autonomy sessions:
approval prompts and permission-layer prompts are mostly bypassed at launch
time. Repo-managed PreToolUse hooks are a separate configured guardrail layer
from runtime permission rules. This design does not count Claude
`permissions.deny` rules as active for the bypass-launched critic pane unless
a version-specific verification proves that behavior. The `--add-dir` value
extends the workspace surface for each session. The exact extra directory is
chosen by the vde session environment, not by Home Manager agent config.

The current local tool versions observed during the 2026-07-14 refresh were
`codex-cli 0.144.3` and `Claude Code 2.1.207`.

## 2. Current Codex Behavior

Repo-owned Codex config lives primarily in
`nix/home-manager/agents/codex/default.nix`.

### 2.1. Command Approval

<!-- private-content-scan: allow-next-line -->
The managed `~/.codex/config.toml` base does not currently set
`sandbox_mode`, `approval_policy`, `approvals_reviewer`, or
`default_permissions`. The active postman approval behavior therefore comes
from the launcher command. In the current worker launch, `--yolo` results in a
full-access Codex session with sandbox mode `danger-full-access` and approval
policy `never`.

The managed config does set:

- `network_access = true`
- `web_search = "live"`
- `features.hooks = true`
- `features.multi_agent = true`
- `features.skills = true`
- TUI status items for `permissions` and `approval-mode`

The status line is important because it makes launch-mode drift visible in the
pane before the agent starts making changes.

### 2.2. Sandbox And Writable Surface

Codex's sandbox and approval controls are not the same layer as the shared
Bash deny hook. The OpenAI docs describe the common sandbox modes as:
`read-only`, `workspace-write`, and `danger-full-access`. They describe the
common approval policies as `untrusted`, `on-request`, and `never`.

The repo currently relies on launcher-level `--yolo --add-dir` for the active
postman panes. Home Manager does not yet define a least-privilege Codex
workspace profile. The generated config does mark owned `ghq` repositories as
trusted projects, but trust is not a writable-root boundary. It controls
project trust state, not what the sandbox may modify.

Codex hooks currently add these local checks:

- `PreToolUse` `Bash` runs
  `nix/home-manager/agents/scripts/pretooluse-deny-bash.sh`.
- `PreToolUse` `apply_patch|Edit|Write` runs
  `nix/home-manager/agents/scripts/codex-pretooluse-observe-write.sh`.

The write hook is observation-only. Codex has no repo-managed role-aware write
deny equivalent to Claude's `claude-pretooluse-deny-write.sh`.

`scripts/lazygit/ai-commit.sh` is separate from postman agent panes. It uses
`codex exec --ephemeral --ignore-rules --sandbox read-only -c
approval_policy='"never"'` for commit-message generation from a staged diff,
and should not be used as evidence for interactive agent-pane approval
behavior.

### 2.3. Auto-Review

Codex auto-review is not configured today. OpenAI documents auto-review as an
approval reviewer choice, not a sandbox boundary change: eligible approval
requests can route to a reviewer agent, while actions already allowed inside
the sandbox still run without extra review.

Because auto-review is Codex-specific and does not replace the existing
guardian/critic/human approval lane, the first implementation should be
**opt-in**, not default. The current default launcher should remain unchanged
until the opt-in profile has evidence for the verification scenarios in
section 7.

## 3. Current Claude Code Behavior

Repo-owned Claude config lives primarily in
`nix/home-manager/agents/claude/default.nix`.

### 3.1. Permission Rules

Claude settings are generated by Home Manager and copied to the writable user
<!-- private-content-scan: allow-next-line -->
settings file `~/.claude/settings.json`. The repo currently configures
`permissions.deny`, but it does not configure `permissions.allow`,
`permissions.ask`, `permissions.defaultMode`, `allowedTools`,
`disallowedTools`, or `permissionMode`.

The current deny set is:

- `deniedBash.claudeCode.denyPermissions` from
  `nix/home-manager/agents/shared/denied-bash-commands.nix` for selected
  high-consequence Bash commands.
- `Read(**/*key*)`
- `Read(**/*token*)`
- `Read(.env*)`
- `Read(~/.ssh/**)`
- `Write(**/secrets/**)`
- `Write(.env*)`

Claude Code evaluates deny, ask, and allow rules as runtime permission policy,
not as prompt guidance. The official docs also note that read and edit deny
rules apply to built-in file tools and recognized file-reading shell commands,
but not to arbitrary subprocesses that open files themselves.

This deny set documents the current configured permission policy. The current
critic pane is launched with `--allow-dangerously-skip-permissions` plus
`--dangerously-skip-permissions`, and installed Claude Code 2.1.207 help
describes the first flag as enabling bypass as an option and the second as
selecting bypass mode. Therefore the design treats `permissions.deny` as a
non-bypass expectation unless a follow-up captures installed-version evidence
that a specific deny rule still applies in bypass mode.

### 3.2. Launch Mode And Hooks

The vde launcher starts the Claude critic pane with the two bypass flags
followed by `--add-dir "${SUBDIR}"`. The allow flag makes bypass mode
selectable, and the dangerous skip flag selects it. That suppresses normal
permission prompts and, per the installed help, bypasses permission checks for
that pane. Do not use the current critic launch as evidence that
`permissions.deny` is enforced.

The repo configures these Claude hooks:

- `UserPromptSubmit` runs
  `nix/home-manager/agents/scripts/common-userpromptsubmit.sh claude`.
- `PreToolUse` `Bash` runs the shared
  `nix/home-manager/agents/scripts/pretooluse-deny-bash.sh`.
- `PreToolUse` `Write|Edit|NotebookEdit` runs the Claude-only
  `nix/home-manager/agents/scripts/claude-pretooluse-deny-write.sh`.

These hooks are distinct from the Claude permission-layer rules above. The
installed help names `--bare`, not `--dangerously-skip-permissions`, as the
mode that skips hooks. This design therefore keeps hook verification separate
from permission-rule verification: the current bypass launch may rely on the
configured PreToolUse hook layer only after a scenario proves the hook fires.

The Claude write-deny hook enforces the multi-agent role contract for panes
that should not mutate the repo. Codex does not have an equivalent role
contract today.

### 3.3. Sandbox And Writable Surface

Claude Code has two distinct controls:

- Permissions decide whether a tool call may run.
- Sandboxing provides OS-level restrictions for Bash commands and their child
  processes.

The current repo config does not enable Claude's `sandbox` block. File access
comes from the launch directory plus `--add-dir`; the official docs state that
additional directories grant file access, not full configuration-root status.

`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` is currently set to `0` because enabling it
forced permission mode back to `default` and broke the current
`--dangerously-skip-permissions` flow. Re-enabling credential scrubbing should
wait until a follow-up defines explicit allow rules or an equivalent sandboxed
Claude profile.

## 4. Shared Policy Versus Runtime-Specific Settings

| Intent                               | Shared home                                                                          | Runtime-specific home                                                                                                                                            | Current design                                                                                                                                                                                           |
| ------------------------------------ | ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Dangerous Bash command denies        | `nix/home-manager/agents/shared/denied-bash-commands.nix`; `pretooluse-deny-bash.sh` | Claude additionally receives selected `permissions.deny` globs for non-bypass permission profiles; Codex receives the shared hook patterns                       | Shared SSOT owns command-deny intent. For the bypass-launched Claude critic, verify the PreToolUse hook separately and do not claim `permissions.deny` enforcement without installed-version evidence.   |
| Postman message and mailbox workflow | `config/tmux-a2a-postman/postman.md` and shared hook bypass data                     | Runtime hook registration paths differ                                                                                                                           | Keep postman state operations prompt-first plus hook-compatible. The shared deny hook must not false-positive on heredoc message bodies.                                                                 |
| Sensitive file read/write denies     | Policy intent should be shared                                                       | Claude has direct `Read`/`Write` denies for non-bypass permission profiles today; Codex needs sandbox or permission-profile rules in a follow-up                 | Preserve Claude's configured file denies, but do not treat them as enforced for bypass-launched panes unless tested. Add equivalent Codex boundaries only through Codex-native sandbox/profile settings. |
| Filesystem and network blast radius  | Design principle only                                                                | Codex uses sandbox modes, approval policy, writable roots, or permission profiles. Claude uses permission rules plus optional Bash sandbox or process isolation. | Keep the policy goal aligned, but implement boundaries through each runtime's native controls.                                                                                                           |
| Human review lane                    | `postman.md` approval route and review skills                                        | Codex `approvals_reviewer = "auto_review"` is Codex-only                                                                                                         | Auto-review may assist Codex approval prompts, but it must not replace guardian/critic/human approval gates.                                                                                             |
| Role-based write restrictions        | `postman.md` role contract                                                           | Claude has `claude-pretooluse-deny-write.sh`; Codex currently observes write payloads only                                                                       | Keep Claude enforcement. Add Codex enforcement only after the observed write payloads support a reliable rule.                                                                                           |

### 4.1. Postman Command Approval Layer

`tmux-a2a-postman execute-bash` is now the shared command-approval wrapper for
postman sessions. It records requester, reviewer audit label, label, category,
mode, command digest, reason, expiry, approval thread id, decision, and exit
status, then runs the command through `bash -lc` only when the selected mode
allows it.

This wrapper is coordination and audit, not a security boundary. It does not
sandbox Bash, block direct shell execution, or prevent another process from
running the same command. Keep runtime enforcement in Codex sandboxing, Claude
permissions/sandboxing, or the shared PreToolUse hooks when the rule must hold
against bypass.

The real approver is not the `reviewer` field in a policy or CLI flag.
`reviewer` is an audit label. The authenticated approver is the single node
marked in the `postman.md` Mermaid graph:

```mermaid
graph LR
    messenger --- orchestrator
    orchestrator --- worker
    orchestrator --- approver
    class approver command_approver_node
    classDef command_approver_node fill:#fef3c7
```

This repo marks the dedicated `approver` node as that singleton. All command
approval policies share the same approver. Per-policy approver routing is not
supported.

The fail-open rule is the most important operational detail: `advisory`,
`warn-only`, and `blocking` become restrictive only when the Mermaid
`command_approver_node` resolves to a real configured node. If the marker is
absent or misspelled, every wrapper-mediated command runs and is recorded as
`auto_approved_no_reviewer`, including commands requested in `blocking` mode.
Migration is complete only when `tmux-a2a-postman get-status` has neither
`command_approval.unresolved_command_approvers` nor
`command_approval.deprecated_command_approvers`.

When a command needs approval and a valid approver exists, `execute-bash`
delivers a reply-required approval request to that approver. The approver can
decide by replying on the approval thread with a body starting
`APPROVED: <reason>` or `NOT APPROVED: <reason>`, preserving the supplied
`thread_id` in frontmatter. The approver can also decide from its own pane:

```sh
tmux-a2a-postman execute-bash \
  --thread-id command-approval-... \
  --record-decision approved \
  --reason "digest reviewed"
```

Decision identity always comes from the calling tmux pane title or the reply
sender, never from `--reviewer`. A decision attempted from any pane other than
the resolved `command_approver_node` is refused or recorded as wrong reviewer.

Current dotfiles adoption:

- `config/tmux-a2a-postman/postman.md` adds a dedicated `approver` node and
  marks it with
  `command_approver_node`.
- `config/vde/layout.yml` starts an `approver` pane in the standard `preset-p`
  and `preset-w` team layouts. This is required: a Mermaid approver marker that
  has no live pane title resolves as unavailable and can leave blocking command
  approval in fail-open mode.
- `config/vde/layout.yml` also starts a reserved `diplomat` pane so future
  cross-session design traffic has a stable node name, but no `diplomat_node`
  routing is configured yet.
- The common template states that `execute-bash` is the only postman-mediated
  command approval lane and that direct shell execution bypasses its audit.
- The approver role contract tells approver to approve or reject command
  approval threads, and not to run the requested command locally while acting
  as approver.
- The orchestrator role contract routes command-approval policy questions to
  `approver` rather than deciding approval threads itself.
- Worker roles must use `execute-bash` with a specific `--label`,
  `--category`, and `--reason` when delegated work requires this approval lane.
- There is still no checked-in `postman.toml` command policy. Any future
  blocking policy must be added alongside a verification showing the valid
  Mermaid approver marker survives config load.

### 4.2. Diplomat Node Status

`diplomat_node` is not part of command approval. It is an open
`tmux-a2a-postman` design for tree-derived cross-session authorization:
sessions declared through `[[postman.workspace_tree]]` would each name one
`diplomat_node`, and those diplomats would be allowed to communicate across
parent/child session boundaries derived from the workspace tree.

Do not add a `diplomat_node` class or active cross-session authorization to
this repo yet. As of the 2026-07-13 check:

- The workspace tree prerequisite is present in `tmux-a2a-postman` through
  issue #504 / PR #622.
- The diplomat design itself remains open as issue #624.
- Related trust-ledger accountability work remains open as issue #614, and the
  diplomat design names that work as relevant to confused-deputy risk.
- `config/tmux-a2a-postman/postman.md` reserves a `diplomat` node for future
  design and policy routing only. It must report blocked for active
  cross-session relay until upstream support lands and this repo adds explicit
  verification gates.

When `diplomat_node` ships, the dotfiles follow-up should be separate from
command approval and should update:

- `config/tmux-a2a-postman/postman.md` only if the shipped syntax uses the
  Markdown topology file.
- `config/vde/layout.yml` if the existing reserved `diplomat` pane needs a
  different runtime, pane title, or launch placement for the shipped feature.
- A checked-in `postman.toml` only if the shipped syntax stays under
  `[[postman.workspace_tree]]`.
- The role contracts for whichever node is allowed to relay cross-session
  traffic, including explicit anti-open-relay instructions.
- Verification that status output and "You can talk to" include the derived
  diplomat edges without exposing filesystem paths.

## 5. Follow-Up Implementation Shape

The first implementation should be an opt-in profile or preset, not a default
change.

Recommended first Codex shape:

- Add an opt-in Codex launcher or profile that uses `sandbox_mode =
  "workspace-write"` and `approval_policy = "on-request"`.
- Add `approvals_reviewer = "auto_review"` only in that opt-in path.
- Keep the existing `--yolo` vde panes unchanged until the opt-in path passes
  the scenarios below.
- Prefer the established sandbox keys for the first pass. Codex permission
  profiles are still documented as beta and do not compose with older sandbox
  settings, so adopting `default_permissions` should be a later, explicit
  migration.

Recommended first Claude shape:

- Do not change the current critic pane launch in the same follow-up.
- Prototype any Claude reduction in bypass behavior separately with explicit
  `permissions.defaultMode`, allow rules, or a `sandbox` block.
- Revisit `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "0"` only after the permission
  prompt behavior has an explicit allow surface.

Issue #192 is closed and does not block this design. Its native source-layout
cleanup means follow-up implementation should edit the current installer and
runtime config files directly, not revive the retired native-agent renderer
shape.

## 6. Repo Files For A Follow-Up

A follow-up implementation is expected to touch some subset of these
repo-relative paths:

- `config/vde/layout.yml` for opt-in pane or preset launch flags.
- `nix/home-manager/agents/codex/default.nix` for Codex sandbox,
  approval-reviewer, or config-profile generation.
- `nix/home-manager/agents/claude/default.nix` for Claude permission mode,
  allow/ask rules, sandbox settings, or env-scrub changes.
- `nix/home-manager/agents/shared/denied-bash-commands.nix` only if the shared
  Bash deny policy itself changes.
- `nix/home-manager/agents/scripts/pretooluse-deny-bash.sh` only if a
  verification scenario proves the shared hook mishandles command parsing or
  postman payloads.
- `skills/dotfiles/references/agent-command-approval-design.md` to record the
  final accepted shape.
- `skills/dotfiles/references/agent-config-philosophy.md`,
  `skills/dotfiles/references/agent-hooks-architecture.md`, and
  `skills/dotfiles/references/deny-bash-design.md` if the implementation changes
  the shared-versus runtime-specific boundary.
- `skills/dotfiles/references/codex-cli.md` and
  `skills/dotfiles/references/claude-code.md` for harness
  changelog and operational notes.
- `config/tmux-a2a-postman/postman.md` only if the human approval or worker
  operating contract changes.
- `config/vde/layout.yml` whenever adding a postman node that must exist as a
  live pane; topology-only nodes are not enough for command approval identity.
- A future checked-in `postman.toml`, if command approval policies become
  declarative rather than per-command `execute-bash` flags.

## 7. Representative Verification Scenarios

These are design scenarios for the follow-up implementation. They should run
from a disposable issue worktree or scratch repository, not from `main`.

| Scenario                 | Codex expectation                                                                                                                                                                                                      | Claude expectation                                                                                                                                                                                  | Evidence to capture                                                                                                                                                                        |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Normal repo edits        | Current `--yolo` pane can edit as before. Opt-in profile can edit files inside the current workspace under `workspace-write` without widening to full access.                                                          | Worker-like panes can edit according to their permission mode. Non-worker panes should be tested against the write-deny hook separately from permission rules.                                      | Create, edit, and remove a scratch file under the issue worktree; capture status line mode and `git status --short`; record whether denial came from a hook or a permission rule.          |
| Cross-directory reads    | Reads from the launch directory and explicit `--add-dir` roots work. Reads outside those roots should prompt, fail, or be denied depending on the selected sandbox profile.                                            | Reads from launch directory and `--add-dir` roots work. Sensitive `Read(...)` denies are expected for a non-bypass profile; bypass mode must not claim them unless tested on the installed version. | Attempt a normal read in the worktree, a read from the added directory, and a denied sensitive-path read; record permission mode and whether the denial came from `permissions.deny`.      |
| Package operations       | Routine local checks such as `nix run '.#check'` work in the intended profile. Networked package or cache operations either work only when intentionally allowed or route through approval.                            | Package checks follow the selected permission mode. If sandboxing is enabled, Bash child processes stay inside the configured filesystem and network boundary.                                      | Run the repo check surface and one package-manager command with expected network behavior documented.                                                                                      |
| Denied commands          | `git push`, `git reset`, `git rebase`, `git commit --amend`, `rm`, `sudo`, `aws sso login`, `git -C`, and `tmux select-pane -T` remain blocked by the shared hook or future Codex-native forbidden rules.              | The shared PreToolUse hook should block the same command set when hooks run. The high-consequence `permissions.deny` subset is a non-bypass expectation unless a bypass-mode test proves otherwise. | Execute harmless dry forms where possible, or use hook/unit command checks that prove the deny rule fires without side effects; record hook-layer and permission-layer results separately. |
| Postman state operations | `tmux-a2a-postman pop` and `tmux-a2a-postman send-heredoc` remain usable. Heredoc bodies that mention denied commands do not trigger false positives. Direct mailbox file edits remain outside the operating contract. | Same as Codex. `--dangerously-skip-permissions` must not be required for legitimate postman state traffic once an alternative profile exists.                                                       | Pop a ping/status message in a test session, send a heredoc containing command-like text, and confirm the shared Bash deny hook does not block message transport.                          |

Postman command approval scenario:

- Codex expectation: `execute-bash --mode blocking` does not fail open after
  config load when `approver` is the resolved `command_approver_node`. Direct
  shell remains a documented bypass, not a tested approval path.
- Claude expectation: same as Codex because approval identity comes from tmux
  pane title, not runtime vendor settings.
- Evidence to capture: restart the postman daemon after config changes, run
  `get-status`, confirm no unresolved/deprecated command approval markers,
  create a harmless blocking request, approve or reject from `approver`, and
  inspect the recorded thread.
