# PanePals consumer cutover

This page tracks the Dotfiles side of
[issue #589](https://github.com/i9wa4/dotfiles/issues/589). The upstream naming
and one-time migration procedure belong to
[tmux-a2a-postman issue #1125](https://github.com/i9wa4/tmux-a2a-postman/issues/1125).
Source and CI preparation here do not activate a machine or migrate a live
workspace.

## 1. Source transition

The staging input is named `panepals` and, before the repository rename, points
to an exact published commit in `i9wa4/tmux-a2a-postman`. Its default Nix
package must export the `panepals` executable and matching `dist/skills`. After
the human renames the upstream repository, update the URL in a separate
authorized cutover. Keep the package and Skill source on the same resolved lock
revision. Do not substitute an unverified tag or a future repository URL.

The active consumers are the Home Manager package and Skill source, shared
command policy, tmux status row, VDE pane layout, shell snippets, validation
scripts and update app. The upstream names are `coordinator`, `builder`,
`builder-alt`, `review-lead`, `review-peer`, `env-a`, `env-b`,
`panepals-send-message`, and `panepals-records`. The `approver`, `messenger`,
`agent`, `dev`, subcommands and ordinary mailbox directory names remain
unchanged. Preserve pane clients, models, effort, command approval and role
responsibilities.

## 2. Linked-source checkout gate

Home Manager links `$HOME/.config/tmux` and `$HOME/.config/vde` directly to
`config/tmux` and `config/vde` in the primary Dotfiles checkout with
`mkOutOfStoreSymlink`. A merge or checkout that changes those source files
therefore exposes the `panepals` status command and renamed VDE roles and
presets immediately, even without a Home Manager switch. This draft's isolated
worktree does not alter those live links.

Do not merge or check out the renamed source in the linked primary checkout
until the separately authorized cutover. First verify the exact upstream
package and Skill revision, quiesce affected panes and mail, and preserve the
pre-cutover source revision, installed generation and state snapshot. With
the primary checkout still on the old source, activate the candidate Home
Manager generation from the isolated worktree and verify that the installed
`panepals` executable and selected config are available. Complete the migration
procedure from upstream issue #1125 at the point it specifies; its state
transition order remains upstream-owned. Only after both package and state are
ready may the linked checkout advance and load the new tmux/VDE config or start
new role panes. Keep new mail stopped until the native bindings, status row and
reply/approval routes pass the live checks below.

If the source changes are exposed early or live validation fails, stop new mail
and keep the panes quiesced. Restore the recorded pre-cutover versions of the
linked tmux/VDE source files before restoring the old installed generation. Use
the upstream #1125 state rollback procedure with the recorded snapshot in its
specified order. Retain both state roots and unresolved obligations. Do not use
a broad Git reset that would discard unrelated work.

## 3. Live cutover boundary

Before a separately authorized activation, inventory the currently selected
config and state roots, native tmux session and pane bindings, pending inbound
and outbound replies, approval requests, drafts, and retained archives. The old
defaults are `$HOME/.config/tmux-a2a-postman/` and
`$HOME/.local/state/tmux-a2a-postman/`; the new roots are
`$HOME/.config/panepals/` and `$HOME/.local/state/panepals/`. A custom
`postman.md` becomes `panepals.md` under the selected new config root. Preserve
the old roots and historical archives for access and rollback.

Quiesce the affected native panes and stop new mail before applying the
upstream #1125 migration procedure. Record the exact binary, config file, state
snapshot, tmux binding and unresolved message IDs. Never treat a notification or
mailbox count as proof that a pending reply or approval has been resolved. The
upstream procedure owns copy, conflict, recovery and rollback semantics;
Dotfiles must not implement a second state migrator.

After an authorized activation, validate the installed `panepals` binary,
selected config, native pane binding, status row, complete POP archive read,
exact reply route and approval boundary in the target session. Record which
checks cover source, CI, installed machine and live behavior. If validation
fails, stop new work, retain both state roots, and follow upstream #1125
rollback instructions against the recorded snapshot and binary revision. Do not
delete old archives or silently reassign pending obligations.

The #589 draft PR is a source review artifact. Merge, upstream repo rename,
release, machine activation and live migration remain separate human-owned
steps.
