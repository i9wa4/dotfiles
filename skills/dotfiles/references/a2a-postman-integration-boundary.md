# A2A/Postman Integration Boundary

This page defines the repo boundary between the dotfiles-managed Software
Factory harness and `i9wa4/tmux-a2a-postman`. Postman respects A2A vocabulary
where useful, but it remains a tmux/file-backed coordination runtime until the
daemon exposes an A2A protocol binding.

## 1. Source-Of-Truth Boundary

| Contract surface | Owning repo | Consumer | Compatibility expectation |
| --- | --- | --- | --- |
| Role topology, role contracts, language policy, public-write gates, and review route | `i9wa4/dotfiles` via `config/tmux-a2a-postman/postman.md` | Postman-delivered agent panes | Keep authoritative in the postman common template. Update with guardian/critic review before changing role authority, public-write gates, or completion semantics. |
| Dotfiles skills and generated skill catalog paths | `i9wa4/dotfiles` via `skills/` and `nix/home-manager/agents/shared/agent-skills.nix` | Claude, Codex, and postman `skill_path` injection | Preserve active loader behavior separately from dormant reference inventory. Skills may explain daemon use, but must not define daemon behavior. |
| Agent runtime configuration, hooks, and shared deny data | `i9wa4/dotfiles` via `nix/home-manager/agents/` | Claude and Codex launcher profiles | Runtime enforcement belongs in each runtime's controls or shared hooks. Prompt contracts are not OS enforcement. |
| Message storage, `send-heredoc`, `pop`, inbox/read/archive moves, dead-letter routing, and pane hints | `i9wa4/tmux-a2a-postman` | Dotfiles role contracts and live agents | Treat daemon CLI/docs as the behavior source. Dotfiles may require agents to use the commands, but must not re-specify file mutation semantics. |
| Status projection, visible node states, severity, queues, and daemon-submit diagnostics | `i9wa4/tmux-a2a-postman` | Orchestrator, workers, and operators | Consume the daemon's status schema. Dotfiles docs may define operational response rules, but schema fields and transitions belong upstream. |
| Command-approval mechanics, thread records, digest matching, and approver identity checks | `i9wa4/tmux-a2a-postman` | Dotfiles approver role and workers | Dotfiles owns when human/current approval is required; daemon owns how `execute-bash` records and enforces wrapper-mediated approval. |
| A2A terminology alignment | `i9wa4/tmux-a2a-postman` for daemon semantics; `i9wa4/dotfiles` for harness wording | A2A-aware operators | Use alignment phrasing only. Do not claim A2A server, AgentCard, `SendMessage`, `GetTask`, or task-state compliance without daemon support. |
| Cross-session diplomat authorization | `i9wa4/tmux-a2a-postman` issue <https://github.com/i9wa4/tmux-a2a-postman/issues/624> | Future dotfiles diplomat role | Disabled by default. Dotfiles may reserve a role, but must not claim live cross-session relay until upstream protocol and verification gates land. |

## 2. Lifecycle Handoff

The task lifecycle is harness-owned above the transport layer:

1. Human or upstream caller sends a request to `messenger`.
2. `messenger` relays to `orchestrator`.
3. `orchestrator` assigns `worker` or `worker-alt`, preserving one durable
   artifact owner.
4. The executor maintains the task artifact, performs scoped source work, and
   reports `DONE:` or `BLOCKED:` to `orchestrator`.
5. `orchestrator` routes worker readiness through `guardian`; guardian obtains
   critic evidence for substantive review and returns a final internal verdict.
6. `orchestrator` reports completion to `messenger` only after the internal
   review route succeeds.
7. `messenger` presents the result to the human.

The completion report must name the task artifact, original checklist verdict,
changed files, verification evidence, and remaining blockers. Guardian approval
is an internal review gate only. It never replaces explicit current human
approval for public GitHub writes, remote branch publication, PR creation or
updates, production-data writes, tags, releases, or equivalent external side
effects.

The daemon does not own task identity. Transport identities are `message_id`,
optional `thread_id`, and reply-required `input_request_id`; task identity
belongs to the issue, artifact, or external planner.

## 3. Delivery-State Vocabulary

Use these terms in dotfiles harness reports:

| Term | Meaning | Agent behavior |
| --- | --- | --- |
| `queued` | A message or daemon-submit request exists but has not produced committed delivery or response evidence. | Do not assume delivery. Inspect status or request evidence before retrying. |
| `processed` | The daemon committed the action, such as moving mail to inbox/read, writing a response, recording a decision, or dead-lettering. | Follow the committed evidence; do not duplicate a send/pop solely because the client timed out. |
| `timeout` | A CLI request returned before daemon-submit produced a response. The daemon may still commit later. | Inspect `inspect-daemon-submit --id <id>` and status/debug evidence before retrying. |
| `pending` | For node status, inbound reply-required work is unresolved. For daemon-submit, a request is waiting for worker capacity or same-inbox ordering. | Handle the actionable request if it belongs to this node; otherwise wait or report transport uncertainty with evidence. |
| `waiting` | The node has sent reply-required mail and is waiting for another node's response. | Do not mark blocked unless a concrete `BLOCKED:` report or failure condition exists. |
| `late_response` | A timed-out daemon-submit request later produced a response file. | Read the late response and reconcile it before any retry or no-op decision. |
| `delivery_stuck` | Pending post delivery is older than the daemon threshold. | Report transport uncertainty to `orchestrator`; avoid blind resend. |
| `delivery_failure` | Mail was dead-lettered or another durable delivery failure exists. | Report the failure path/reason and await routing or source correction. |

Pane hints and daemon PING notifications are not message bodies. After `pop`
returns a message path, the receiver must read the complete archived Markdown
body before handling, routing, replying, or deciding no action is needed.

## 4. Command Approval Boundary

`tmux-a2a-postman execute-bash` is a coordination and audit wrapper. It records
metadata, command digest, approval thread, decision, and exit status for
wrapper-mediated commands. It is not a sandbox, does not prevent direct shell
execution, and does not replace runtime enforcement.

Responsibilities stay separate:

- Dotfiles role contracts decide when workers must use the postman-mediated
  approval lane and when explicit current human approval is required.
- The daemon owns `execute-bash` command matching, decision records, fail-open
  and fail-closed behavior, and approver identity checks.
- Runtime enforcement belongs in Codex sandbox/profile settings, Claude
  permissions/sandboxing, or shared PreToolUse hooks.

The configured `command_approver_node` must resolve to a live node before
blocking approval is treated as restrictive. If status reports unresolved or
deprecated command approver markers, treat the approval migration as failed.

## 5. Diplomat Boundary

The `diplomat` role in dotfiles is reserved for cross-session design and policy
traffic. It is not an active relay. Requests that require cross-session relay
must be reported as blocked until daemon-side `diplomat_node` authorization,
status surfacing, contact hints, and anti-open-relay verification are approved
and released.

Do not add cross-session authority by editing dotfiles role text alone. The
upstream dependency is `i9wa4/tmux-a2a-postman` issue
<https://github.com/i9wa4/tmux-a2a-postman/issues/624>.

## 6. Maintainability And Security Gates

Before changing this boundary, record evidence for:

- the exact dotfiles-owned files being changed;
- the daemon-side doc, code path, issue, or release URL the change depends on;
- whether the change affects prompt policy, runtime enforcement, transport
  behavior, status schema, or external side effects;
- the review route needed before publication;
- focused verification that active loader paths, role reachability, command
  approval status, and message pop/read behavior still match the intended
  boundary.

Implementation must stay repo-local unless a separate daemon issue authorizes
daemon changes. Cross-repo mutation is not part of this dotfiles issue.
