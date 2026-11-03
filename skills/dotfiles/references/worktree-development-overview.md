# Worktree Architecture and History

Use [Worktree Workflow](workspace-worktree-workflow.md) as the single
operational entrypoint. This overview explains the design and provenance; it
does not own a second command/setup procedure.

## 1. Architecture

The base checkout supports repository maintenance while independent issues,
features and PR reviews use linked worktrees. Each has its own branch, files and
index while sharing Git repository metadata. Isolation protects unrelated work,
including small documentation changes; a shared index is not a concurrency tool.

Native Git owns linked-checkout mechanics and the canonical worktree inventory.
Checked-in wrappers own local issue/PR naming, source/upstream selection,
cross-repository PR support, environment bootstrap and navigation registration.
There is no separate worktree backend package or hidden per-machine task
database.

Managed `.worktrees/` roots are relative to the invoking checkout. That
relationship matters when invoking a wrapper from an existing linked checkout or
intentionally stacking a dependent issue. Off-main invocation preserves the
stable main branch; the workflow reference gives exact base-selection behavior
and safety checks.

## 2. Trust and Responsibility

A branch-controlled environment can execute code while loading. The operational
owner therefore distinguishes copied/generated issue setup from branch-provided,
existing or PR-review files and preserves their different authorization gates.
A returned checkout path is not evidence of successful hook/devshell setup.

Zsh navigation changes the current pane's directory and aligns tmux naming with
its repository/worktree. Agent Workspace owns that navigation detail. It does
not change worktree ownership or make a shared checkout safe for overlapping
edits.

Inspection and deletion remain separate. Native inventory and `worktree-status`
provide evidence; confirmed clean, unlocked and merged/obsolete checkouts can be
removed explicitly. No background cleanup or generic backend replacement is part
of this design. Runtime activation and Postman transport have their own owners.

## 3. Historical Context

These are retained implementation changes, not an alternate current recipe:

- Sibling layouts such as `../dotfiles-issue-123` are legacy; managed roots
  moved to checkout-local `.worktrees/`.
- The npm-managed backend was removed; wrappers now use native Git directly.
- Jump functions moved into `config/zsh/zoxide.zsh`, sourced by
  `nix/home-manager/modules/zsh.nix`. Re-entry now changes the current pane's
  directory rather than switching tmux sessions; ghq supplements zoxide results.
- Issue/PR flows learned to preserve local main off-main, and PR review learned
  to fetch cross-repository heads without rewriting divergent local branches.
- Worktree status became a read-only inventory of every registered checkout,
  with remote issue/PR state only where naming rules identify it.
- Old "approved target after migration" descriptions ceased being runtime
  authority. Current code is authoritative; the adoption evaluation remains a
  private-vault decision record, not a public private-path pointer.

## 4. Related Ownership

The workflow reference links executable sources and publication guidance.
[Agent Workspace](workspace-guidance.md) owns boot, session naming, navigation,
lock diagnosis and pane references. Preserve their distinct scopes instead of
replicating issue/PR setup here.
