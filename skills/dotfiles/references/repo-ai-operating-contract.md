# Repo AI Operating Contract

This is the standalone operating contract for AI work in this repo.

It is broader than `tmux-a2a-postman` alone. The scope here is the whole
repo-local AI runtime under `nix/home-manager/agents`, plus the routing and
approval contract carried by `tmux-a2a-postman`.

For the broader repository philosophy, read
`skills/dotfiles/references/operating-concepts.md`.

For review responsibility boundaries across automation, AI assistance, and human
or owner approval, read
`skills/dotfiles/references/repo-ai-review-boundaries.md`.

## 1. Scope

Use this document when the question is "how should an AI agent operate inside
this repo right now?"

That includes:

- shared operating instructions
- installed Claude and Codex configuration under Home Manager
- hooks and resumable handoff behavior
- skill and review installation
- tmux role identity
- `tmux-a2a-postman` routing and approval rules

## 2. Repo-local AI stack

The repo-local AI stack is assembled from a few core sources.

### 2.1. Shared instruction core

The pinned Postman binary owns the standard role/common policy and complete
workflow HelpDocs. Full POP archives carry the intended recipient's policy;
startup injects no initial prompt. Inspect `tmux-a2a-postman help config` for
source selection and the bundled default. An explicit user postman.md is a
complete override, never a merge with the builtin team.

Dotfiles installs personal/domain Skills and the upstream thin entries through
one declarative source graph. The builtin mail catalog describes Postman's own
entries; local Skills remain discoverable through each client's installed tree.
The shared AGENTS/CLAUDE source only acknowledges notifications and POP/help.

### 2.2. Declarative installation

`nix/home-manager/agents/claude/default.nix`,
`nix/home-manager/agents/codex/default.nix`, and
`nix/home-manager/agents/shared/agent-skills.nix` declaratively materialize
the runtime under:

<!-- private-content-scan: allow-next-line -->
- `~/.claude/`
<!-- private-content-scan: allow-next-line -->
- `~/.codex/`
<!-- private-content-scan: allow-next-line -->
- `~/.claude/skills`
<!-- private-content-scan: allow-next-line -->
- `~/.codex/skills`

The point is that the installed runtime should come from this repo, not from
manual edits in home directories.

### 2.3. tmux role identity

Inside this repo, role identity is tied to the tmux pane title. That means
role, routing, and prompt context are linked to the pane you are currently in,
not just to abstract agent labels.

## 3. Shared operating rules

These rules are the residual loaded prompt rules kept local because
non-postman Claude/Codex sessions still need them. Postman-role sessions also
receive the stronger common contract from `tmux-a2a-postman`.

They come from the postman common contract plus the installed local skills.
They are expected regardless of engine:

- read files in full
- verify against the actual repo before reporting
- prefer small verifiable steps
- use Nix-managed or POSIX-safe tooling where possible
- avoid destructive git operations unless explicitly instructed
- use repo-relative paths or stable URLs on public GitHub surfaces; reserve
  machine-local absolute paths for user chat, internal artifacts, and debug
  evidence
- treat pane-title identity as important runtime state

For worker-style nodes inside the postman graph, two more rules matter:

- non-user-facing nodes do not end by asking the human user a question
- success and failure are reported as `DONE:` or `BLOCKED:`

### 3.1. Repo-local execution safety

These repo-local rules belong in this document rather than in a broad fallback
skill:

- read each relevant file in full before making claims about it
- avoid unrelated refactors and do not delete unmentioned handlers, functions,
  or sections
- prefer the smallest verifiable step that satisfies the request
- when changing behavior and a cheap failing reproducer is possible, start
  there
- verify changes with actual command output before reporting success
- use Nix-managed or POSIX-compatible tools where possible because this repo
  targets Linux and macOS
- do not pollute global environments; use repo-local or temporary environments
  when a tool needs isolation
- do not commit generated dependency directories, virtual environments, or
  disposable build outputs
- never hardcode personal usernames, hostnames, or machine names in shared Nix
  configuration
- use uppercase annotations such as `NOTE:`, `TODO:`, `FIXME:`, and `WARNING:`

### 3.2. Durable handoff artifacts

Read the complete `tmux-a2a-postman help records` for selection, protected
active indices, recovery, creation, linked details and retention. Existing known
local records remain canonical across upgrades. The legacy Logbook entry remains
an installed compatibility pointer plus personal Gist/Issue delivery adapters.

### 3.3. Planning and acceptance

Read `tmux-a2a-postman help planning` and the applicable repository's actual
checks. Original criteria, actual evidence and remaining blockers determine
acceptance; do not impose a second local plan/checklist format or duplicate
milestone state. The selected role/common contract supplies immediate duties.

### 3.4. Coordination reads

`tmux-a2a-postman help orchestration` owns scope, read-back and one-writer
procedures. A coordinator reads relevant records and verifies delegated record
updates; implementation investigation, tests and every write stay delegated.
Incoming paths or logs do not grant access to peer inboxes, unrelated private
records or source execution. Runtime permission still applies.

## 4. Hook contract

Hooks are not optional conveniences in this repo. They are part of the local
operating contract.

### 4.1. Shared intent across engines

Both engines are expected to support these behaviors as closely as their hook
surfaces allow:

- deny dangerous Bash actions before execution
- keep handoff state durable through postman messages and artifacts

### 4.2. Claude runtime hooks

The Claude runtime currently carries:

- `PreToolUse` for shared Bash denials

### 4.3. Codex runtime hooks

The Codex runtime currently carries:

- `PreToolUse` for Bash denials

The surface is not identical, but the repo is aiming for equivalent operating
discipline.

## 5. Shared policy sources

Two repo files matter especially because they are single sources of truth
consumed by both engines.

### 5.1. `shared/bash-commands-denied.nix`

This file defines the dangerous Bash patterns once and then emits:

- Claude deny permissions
- the generated Bash deny patterns file used by the shared Claude/Codex
  PreToolUse hook

If the repo changes a Bash safety policy, this is where it should happen.

### 5.2. `shared/install-manifest.nix`

This file maps the installed shared skill surface. Reviewer prompt guidance is
provided by `skills/subagent-review/references/`; Claude and Codex use their
active runtime/account defaults without generated agent files.
The `subagent-review` skill is hand-authored under
`skills/subagent-review/SKILL.md` and installed through the same local skill
pipeline as other applicable skills. Its references provide the reusable
reviewer guidance without a generated dispatcher.

### 5.3. Review-system ownership and materialization

The installed `tmux-a2a-postman help reviews` owns required perspectives,
independent evidence, stage admission, bounded counters and final authority.
`help review-report` owns optional structured output and decision quality;
`help review-lookup` owns the portable read-only evidence procedure. Actual
prompts ship in `tmux-a2a-postman resources` under `review/`.

The upstream `postman-review` entry and retained local `subagent-review` alias
are installed through `shared/agent-skills.nix`. Legacy reference paths point to
the same binary procedures. No generated reviewer agent files, dispatcher,
extra model/tier selection or second review policy is installed. Runtime-native
capabilities and permissions remain prerequisites, not guarantees of a Skill.

`config/vde/layout.yml` retains personal engine/layout choices. It does not own
Postman roles or alter the guardian/critic route. Both engines get the shared
installed entries; reviewer model/effort defaults come from the chosen runtime.

## 6. Claude/Codex parity contract

The repo expects parity of quality bar, not literal product sameness.

In practice that means:

- both postman-driven engines should receive the same repo-local operating core
- both engines should see the same review topology
- both engines should obey the same Bash deny policy
- both engines should use the same durable handoff discipline through postman
  traffic and artifacts
- both engines should be able to participate in the same repo-local review and
  routing model

When an engine cannot match the other feature-for-feature, the fallback should
still preserve the same intent: safe execution, explicit handoff, and
verifiable reporting.

## 7. Intentional Claude/Codex Asymmetries

Shared policy that must stay aligned across Claude and Codex

The shared policy line above is the part that must not drift. Both engines are
still expected to inherit the same repo-local operating core, deny policy,
review topology, and resumable handoff discipline.

Within that shared policy, the repo currently treats these differences as
intentional:

- Claude-only native secret-path `permissions.deny` entries
- Codex denser installed rules artifact

These differences are acceptable only so long as they keep the same local
intent: safe execution, explicit handoff, and verifiable reporting.

## 8. Postman routing and role ownership

The selected Postman configuration owns roles and actual edges. Use
`tmux-a2a-postman help config` to inspect/export it; custom configuration is a
complete override. Full archives expose recipient contacts and exact reply
commands. Native route verification does not grant human or runtime authority.
Worker ownership, recursive interfaces and result routing follow the complete
installed `help orchestration` topic, not another local node list.

## 9. Review and command-approval boundaries

`tmux-a2a-postman help reviews` alone owns artifact-review admission, Guardian's
final verdict, Critic's independent evidence, corrections and substantive
rework. `help review-report` owns optional JSON. The local compatibility
references do not redefine any of those procedures or counters.

Typed execution approval follows the installed execution/decision HelpDocs.
Dotfiles-specific hook/deny mechanisms and permission boundaries remain in
[Command Approval Design](agent-command-approval-design.md). A review verdict,
Postman decision, forwarded message or accessible path never substitutes for
required human authority or runtime permissions. Existing human authorization
persists; a workflow must not manufacture a new approval requirement per turn.

Personal Japanese PR-comment drafting remains in `create-review-comment`; local
GitHub publication/hygiene remains in `dev-platform-workflow`. These local
adapters do not copy or override the generic review algorithm.

## 10. Status and routing rules

### 10.1. Message purpose does not change transport obligations

A status request or status update is ordinary message content, not a transport
category or no-reply option. Sending to a role creates a reply-required request;
replying to a claimed ID uses its exact return route and creates no further
reply obligation. Read the actual archive metadata and generated guidance.
Neither informational prose nor a footer can cancel that recorded obligation.
A completed exact reply needs no ACK-of-ACK; task acceptance remains separate.

### 10.2. Keep recurring status compact

Use only the smallest useful delta:

- current task
- blockers
- waiting_on
- next action
- the minimum evidence needed to justify a changed state

Do not re-expand the full situation when nothing material changed.

### 10.3. Footer lines are hints, not authority

Recipient-specific `You can talk to` contacts and exact reply commands explain
configured routes and correlation. They do not broaden the graph, replace fresh
native validation or grant human permission. Do not infer a no-reply flag from
old footer wording; use the actual recorded message obligation.

## 11. Delivery-health rules

Do not treat unread mail, quiet panes, or old wait terminology as proof of
stuck delivery by themselves.

At a concrete workflow boundary, inspect the selected version's `get-status`
and operation `self` evidence using the upstream usage Skill. Unknown counts
are not zero; sampled screen changes and quiet panes do not establish task
progress, liveness, delivery failure or completion. The getters' schema and
refresh behavior belong to matching installed help, not this policy reference.

Use own claimed/read and sent evidence for exact correlation and supported
recovery. Do not inspect peer raw inboxes or internal wait files, revive retired
`composing` / `user_input` classifications, poll empty POP, or blindly resend an
unknown outcome. Escalate a concrete blocker with its observed evidence.

## 12. Historical-drift rules

Older retained mail may still show:

- `postman` as if it were a current live recipient
- the old `orchestrator -> critic -> guardian -> critic` review route
- the old `orchestrator -> guardian -> critic -> orchestrator` review route
- `guardian` as reachable only from `critic`

Treat those as historical signatures rather than the current contract.

## 13. Failure reporting

Use concise terminal states:

- `DONE: <summary>`
- `BLOCKED: <reason>`

If a hook, permission rule, or tool restriction blocks the requested action, do
not retry silently. Report the block immediately.

## 14. Recommended reading order

For authorized harness maintenance, read in this order. Coordination-only work
uses its trusted role and required operating procedures; this list does not
authorize implementation investigation or maintenance from a coordinator pane.

1. `nix/home-manager/agents/README.md`
2. `nix/home-manager/agents/claude/default.nix`
3. `nix/home-manager/agents/codex/default.nix`
4. `nix/home-manager/agents/shared/agent-skills.nix`
5. `tmux-a2a-postman help config`
6. this file
