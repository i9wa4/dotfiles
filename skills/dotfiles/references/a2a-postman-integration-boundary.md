# Postman Integration Boundary

Dotfiles supplies the authored role policy in
`config/tmux-a2a-postman/postman.md`. Package and Skill installation use the
ordinary pinned flake input and shared agent-Skill configuration.

Postman owns its CLI, configuration format, mailbox/native identity,
notifications, execution coordination, diagnostics and transport tests. Use
its installed help, shipped Skills and upstream documentation for those
contracts. Dotfiles does not provide another Postman command, launcher,
configuration compiler, test framework or update program.

Edit topology and declared parent/child relationships in `postman.md` using
Postman's configuration reference. Starting an agent is independent of that
configuration. Clients start directly; the complete Markdown returned by POP
carries the common and recipient-role policy.

Develop and validate Postman in its own repository. Its
[contributor guide](https://github.com/i9wa4/tmux-a2a-postman/blob/main/CONTRIBUTING.md)
owns native terminal and recursive transport verification. Dotfiles checks its
own declarative configuration and role-policy source, without duplicating the
transport implementation or test driver.

Keep the explicit compatible Postman revision in `flake.nix` and refresh its
lock entry with ordinary Nix commands when choosing a new revision. Source
checks do not activate the installed configuration or prove a live-fleet switch.

## 1. Optional top-level external channel

The selected Postman source implements `channel-sync` and
`channel-report-heredoc`. A provisioned binding activates them only for the
exact top-level native interface/session/workspace. The public role template
does not guess a live session or a machine's mailbox path. Keep machine bindings
in an explicit local `postman.md` copy and pass that absolute config
consistently to the producer and consoles; do not add a generated-config program
or shell substitutions to YAML.

For setup, read the installed config-auditor reference and
`postman-usage/references/external-channel.md`, plus the selected revision's
[filesystem contract](https://github.com/i9wa4/tmux-a2a-postman/blob/main/docs/design/external-filesystem-channel.md).
Add its supported external root/workspace/session scalar fields to a copy of
the complete role template, preserving the catalog, common policy, local edges
and any explicit parent/child tree. The workspace is the canonical HOME-relative
agent-pane directory. The mailbox root must be canonical, persistent, private
and separate from internal Postman state; do not repurpose the main state root.
Provision its parent and retain the binding and histories across restarts.

The external producer publishes one immutable UTF-8 body by atomic rename, then
invokes `channel-sync` in the actual configured interface's native tmux context
with the same absolute config. Repeat a bounded scan on reconnect or after a
missed event. Preserve the exact socket/pane identity; environment strings alone
do not authorize a binding. No configured caller means no autonomous intake.
Use the upstream scan result to handle known remaining items; do not add empty
POP polling, a timer, or a second discovery/notification engine here.

Messenger fully reads its claimed external mail and delegates through the local
orchestrator. Return a substantive correlated `done` or concrete `blocked`
report only after that scope's evidence is reconciled. Pending decisions use
the exact generated scope and filenames; ordinary comments such as “proceed”
are conversation, not permission. Late/conflicting/changed-scope decisions never
authorize another effect. Descendant interfaces use their immediate parents and
cannot claim the top-level external binding.

Keep output until explicit user cleanup. Scan/reconnect catches up retained
reports; local outbox publication is not proof of human/application receipt.
The separate Issue Mailbox producer, if used, owns its GitHub delivery and
activation, not Postman's role/approval authority. Concurrent direct human
typing has no draft-protection guarantee.

Perform source/fixture verification in owned isolated resources using upstream
terminal actors. Record exact selected binary/config, receiver-owned full reads,
delegation and terminal correlation separately from model comprehension,
installed activation and physical-client receipt. Follow the established
operator rollout procedure for a live binding; do not edit a private mailbox or
reload live sessions as a development check.

## 2. Consumer verification snapshot — 2026-11-02

The selected public revision `a0d729094c089840559cecc5b716b6100a37ca06`
supplies the implemented channel, matching help/Skills and native transport
tests. Its package was built through this dotfiles input and reported
`git-a0d7290`. No pin change or replacement mailbox engine was needed.

An isolated Linux tmux 3.8 trial used this complete role template, selected
local/upstream Skill metadata, two distinct parent/child bindings and a declared
missing child. Only fixture-local catalog roots and explicit native binding/tree
fields were added. The upstream terminal editor and archive reader were reused;
fixed receiver actors owned POP, complete-file reads, exact replies and
execution decisions. The controller only published external files and triggered
intake. It did not supply recipient actions or inject startup policy mail.

| Scenario                                                                                 | Observed result                                                                                                                                   |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| External input through root interface/coordinator and child interface/coordinator/worker | A correlated terminal result returned to the original external exchange; child approver read the exact request before the harmless worker effect. |
| Duplicate trigger and unchanged external filename/body                                   | Zero new intake; each completed worker effect remained exactly once.                                                                              |
| Replacement interface TUI and missing local outbox files on reconnect                    | Retained output recovered with the same report IDs/bytes; no repeated effect.                                                                     |
| Child attempts the root's external binding                                               | Rejected by native workspace/session/interface checks.                                                                                            |
| Two independent bindings                                                                 | Separate exchanges/reports and one effect per binding; neither consumed the other's input.                                                        |
| Declared child unavailable                                                               | A correlated BLOCKED result, with no worker effect.                                                                                               |
| Ambiguous ordinary “proceed” while a decision is pending                                 | Separate clarification/blocker; original pending scope unchanged and no effect.                                                                   |
| Exact scoped decline / approve                                                           | Decline left effects at zero; approve followed delegation and command review, producing one effect.                                               |
| Late answer to a closed decision                                                         | Rejected; no additional effect.                                                                                                                   |

All 45 receiver-owned complete-file SHA-256 proofs matched retained archives.
No paid model, real GitHub destination, actual user mailbox or live session was
used. This proves the scripted transport/correlation path and policy delivery;
it does not establish model comprehension, substantive Guardian/Critic review,
remote human identity, human receipt or installed-machine activation. Those
stages retain their existing authorization and rollout owners.

For a later AI-led check, use Postman's
[cloud/tmux development runbook](https://github.com/i9wa4/tmux-a2a-postman/blob/main/docs/development/cloud-tmux-debugging.md).
Build the selected input, make a private copy of this complete policy with
literal fixture bindings/catalog roots, and start fixed consoles in owned
native role panes. Publish one atomic external file; let submitted notifications
drive receiver tools and retain archive hashes, exact reply/report references
and effect counters. Repeat reconnect/duplicate/decision/failure cases, verify
native ownership before cleanup, and report the source/binary/platform and
evidence limits. Keep this a consumer trial of upstream primitives, rather than
adding another dotfiles launcher, compiler or transport test framework.
