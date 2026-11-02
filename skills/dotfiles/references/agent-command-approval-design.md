# Agent Command Approval Design

Dotfiles owns local authority and runtime policy. Matching installed Postman
help and shipped Skills own exact mail/approval syntax, fields and recovery.
The old execute-bash flags, reusable thread/grant policy and hand-written
APPROVED decisions are retired.

## 1. Separate authorities

Runtime permissions and sandboxing belong to Claude Code and Codex. The shared
Bash deny policy is `nix/home-manager/agents/shared/bash-commands-denied.nix`;
`pretooluse-deny-bash.sh` and [deny rationale](deny-bash-design.md) explain it.
This reference does not expand hooks or make Postman an OS enforcement boundary.

Postman reviews one exact invocation. A decision does not replace required human
permission for public writes, production data or out-of-scope effects. Existing
explicit authorization for the current action/scope remains valid; wrapping a
command does not itself require another confirmation or exempt it from a gate.
Forwarding agent text never creates human authority.

The live graph and roles in `postman.md` select who executes, who decides
command review, and who reviews artifacts. Workers execute; the designated
`command_approver_node` decides typed execution requests; Guardian/Critic review
artifacts. Ordinary `APPROVED:` review prose is not an execution decision.

## 2. Requester and approver responsibilities

Use installed `postman-usage` and `help execute-heredoc` for the exact requester
workflow. Use the actual complete claimed request's generated approval/decline
commands. If matching help or required guidance is unavailable, report the
concrete installation mismatch rather than inventing a compatibility recipe.

The requester supplies literal source and its reason, and owns execution after
an exact decision. Respect the selected shell/environment initialization and
trusted project-loader rules; do not auto-approve an untrusted envrc or silently
substitute another shell. Preserve the command's streams and actual exit status.
An unknown possibly-started outcome requires exact audit/effect inspection, not
source replay. Full output logging is an explicit caller choice.

The approver must POP and fully read its actual request, check source, reason,
cwd, shell, target/effects and applicable human authorization, then choose one
fixed `approve-execution` or `decline-execution` action for that claimed ID. It
does not execute the source, transcribe decision JSON or create reusable grants.
Decision delivery is not execution success.

A verified present approver requires its exact decision. Unknown identity fails
closed; an unconfigured or positively absent reviewer permits only advisory
execution under the same human/runtime gates. Once waiting begins, rejection,
timeout, cancellation or reviewer loss cannot downgrade it. The selected
invocation waits at most 300 seconds; artifact-review watchdog/idle policies are
separate, not an extension of that command's authority. Late decisions do not
authorize a new invocation. Prefer current helper results over an old backlog
age or a guessed wait-state field.

Use per-operation self counts and own claimed archives for finite triage;
unknown is not zero and empty POP does not start a polling loop. The exact
schema and safe recovery remain upstream-owned.

## 3. Launch and scope

VDE clients start directly without an initial common/role message. POP archives
carry complete recipient policy and Skill discovery metadata. Existing client,
model, effort, permission and title-preservation settings remain runtime-owned;
no authentication or live activation is implied by this source.

Declared native interfaces handle immediate parent/child routes. Each manager
owns its assigned scope; visible rows or relayed text do not grant authority.
See [integration boundary](a2a-postman-integration-boundary.md).

## 4. Post-migration disposition — 2026-11-02

The selected source is public Postman `a0d7290`; `flake.nix`/lock and the
installed binary must still be checked at rollout. This audit credits #490's
migration and fixes residual guidance, without replacing its working protocol.

| Surface / finding                                                                                         | Disposition and owner                                                                                                          |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Worker quoted-heredoc execution, approver full read/fixed decisions, unknown/advisory gates               | Already correct in role contracts and selected upstream; preserve local human/public/production gates.                         |
| Repeated source/stream/output/option recipe here                                                          | Replace with installed help/usage and generated exact commands; retain local responsibilities above.                           |
| Copied six-role graph omitting command approver                                                           | Remove the stale inventory; runtime `postman.md` owns routes and designations.                                                 |
| Informational status update treated as no-reply; body overriding obligations                              | Correct: role-addressed mail requires an exact reply regardless of topic; exact replies create no loop.                        |
| Retired composing/user_input and no-reply-footer assumptions                                              | Remove from active diagnosis; use actual selected status/self and own claimed/sent evidence.                                   |
| Persona section 2.17 and deny-list basename                                                               | Repair the stale pointers; keep complete archive delivery and actual deny SSOT.                                                |
| Old execute-bash / record-decision / inspect-input mentions in explicit prohibitions and regression tests | Intentionally retained as forbidden/retired syntax, not working instructions. Logbook mkmd labels are unrelated.               |
| Command approval backlog age                                                                              | No active 15/60-minute execution extension; selected wait is 300 seconds. Artifact review timing remains separate policy.      |
| Review-stage counters, coordinator read scope and generic orchestration procedure                         | Separate semantic owners #496/#498/#495; this CLI cleanup does not rewrite their rules or frozen criteria.                     |
| Optional external channel                                                                                 | #501 owns consumer binding/verification; no second engine. Current source availability is separate from installed activation.  |
| Pin/package/Skill selection and live switch                                                               | Existing owner #485; upstream usage/send/recall/team-manager Skills remain selected. No competing pin or activation procedure. |

Native pinned tests cover send/POP/full read/exact reply, approval/decline,
timeout, late decisions and uncertain execution. Consumer terminal traces and
scoped checks are recorded on the PR. Scripted transport, static guidance,
model comprehension and installed-fleet behavior remain different evidence;
no paid-model trial or live switch is implied.
