# Deny-Bash Design

This document captures the design philosophy of the Bash command deny system
that guards Claude Code and Codex CLI sessions in this repository.

## 1. Purpose and Non-Purpose

The deny system is a **guardrail against accidental execution** of dangerous
commands by AI agents that did not realise they were dangerous. It is not a
hardened security boundary against a determined or malicious actor.

What it protects against:

- An agent typing `git push` directly when push is policy-denied.
- An agent typing `rm -rf /tmp/foo` directly.
- An agent wrapping a denied command in `bash -c "..."` or `sudo` /
  `env` / similar wrappers.
- An agent using long-form flags (`--delete`) when the short form (`-d`)
  is the documented deny.

The hook is a syntactic allowlist, not a sandbox for an allowed process or for
source separately submitted through Postman's typed execution path. It does
not establish the effects of arbitrary programs after they start or replace
runtime permissions and human authorization.

## 2. Single Source of Truth

The shared hook uses two source files:

- `nix/home-manager/agents/shared/bash-commands-allowed.nix` defines the
  default-deny allowlist. Its `entries` generate `ALLOW_PATTERNS`; the hook
  also has a dedicated grep/rg/ripgrep allow check.
- `nix/home-manager/agents/shared/bash-commands-denied.nix` defines
  `DENY_PATTERNS` and their explanations for commands outside the allowlist.
  Its `stripDataArgs` removes quoted message values before both
  `ALLOW_PATTERNS` and `DENY_PATTERNS` matching.
  These patterns improve denial messages; they do not grant or remove execution
  permission after the allowlist decision.

The Nix modules expose these related outputs:

| Output                       | Consumer                                                                                                                                      | Mechanism                                                                                            |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `claudeCode.denyPermissions` | `~/.claude/settings.json` `permissions.deny`                                                                                                  | `Bash(<glob>)` glob match (Claude Code built-in) (private-content-scan: allow; managed runtime path) |
| `claudeCode.patternsFile`    | `~/.claude/scripts/deny-bash-patterns.sh` and `~/.codex/scripts/deny-bash-patterns.sh` (sourced by the shared `pretooluse-deny-bash.sh` hook) | POSIX ERE regex match (private-content-scan: allow; managed runtime path)                            |

The generated `patternsFile` carries both `ALLOW_PATTERNS` and
`DENY_PATTERNS` for the shared PreToolUse hook. Codex does not duplicate the
shared command rules into embedded `prefix_rule(...)` rules; filesystem and
network blast-radius controls remain the responsibility of Codex
sandbox/approval settings.

## 3. Permission And Hook Layers

A Bash command from an AI agent can pass through permission checks, hook
checks, and user confirmation prompts before it can run. These are different
runtime surfaces. Any bypass-mode claim must name the exact layer that was
verified.

### 3.1. Layer 1 — Claude Code Permission Checks

Claude Code normally recognises certain dangerous patterns
(`rm /`, `rm $HOME`, `sudo`, env-var prefixes, compound commands containing
dangerous primitives, redirects to `/dev/tcp/...`, `find -exec`,
`find -delete`, etc.) and surfaces permission prompts or denial behavior.

Installed Claude Code 2.1.210 help describes
`--allow-dangerously-skip-permissions` as enabling bypass as an option, and
`--dangerously-skip-permissions` as bypassing all permission checks. Therefore
this design does not claim that the built-in safety classifier or
`permissions.deny` rules remain active in bypass-launched panes without
installed-version verification for that exact behavior.

### 3.2. Layer 2 — Local Permission Rules And Shared PreToolUse Hook

Per-repo deny rules are sourced from the SSOT and emitted into two mechanisms
with different bypass semantics:

- Claude `permissions.deny` glob entries (only entries with
  `claudeSettingsJson = true`) are the configured permission policy for
  non-bypass Claude profiles. Treat these as enforced only outside
  `--dangerously-skip-permissions` unless a scenario on the installed Claude
  Code version proves otherwise.
- The shared PreToolUse hook (`scripts/pretooluse-deny-bash.sh`) is a separate
  hook-layer guardrail. It first checks the default-deny allowlist in both
  runtimes. A command outside it receives a deny payload; a matching
  `DENY_PATTERNS` entry supplies a specific justification. Installed help
  names `--bare`, not `--dangerously-skip-permissions`, as hook-skipping mode,
  but bypass-launched panes still need explicit hook-fire evidence before
  relying on this layer.

### 3.3. Layer 3 — Per-Command User Confirmation Prompt

Standard "Allow Bash(`<command>`)?" prompts. Claude suppresses these prompts
under `--dangerously-skip-permissions`; bypass-launched panes must not treat
permission prompts or `permissions.deny` as active guardrails without
version-specific evidence. Codex confirmation and sandbox behavior is
configured through Codex approval/sandbox settings, not through duplicated
command-deny entries.

## 4. Hook Processing Pipeline

The shared hook normalizes line continuations and masks literal quoted
heredoc bodies before checking the command. It then applies these stages:

1. The dedicated grep/rg/ripgrep check may allow its narrow read-only shape.
2. `check_bash_command_for_allow` splits top-level shell fragments and requires
   every fragment to pass its risk, secret-path and allowlist checks. A matching
   `ALLOW_PATTERNS` entry or the dedicated safe Git check permits that fragment.
3. If no allow path accepts the command, `check_bash_command_for_denials`
   matches known-bad patterns to choose a specific explanation. It may unwrap
   shell wrappers and strip quoted message arguments before matching, but it
   cannot turn a rejected command into an allowed one.
4. A remaining unmatched command receives the generic not-on-the-allowlist
   denial. Both denial paths point to `tmux-a2a-postman execute-heredoc` for an
   exact, separately reviewed invocation.

## 5. Adding New Entries

### 5.1. New Deny Rule

Add to the denied module's `entries`. Set `claudeSettingsJson = true` only when
the command is truly dangerous and Claude should not even attempt it;
otherwise the entry supplies a specific hook denial message for a command
already outside the allowlist.

Use `anchored = true` (the default) only when the deny target must appear as
the first token of the fragment. Use `anchored = false` when the command can
appear after wrapper prefixes like `sudo`, `env`, `watch`, etc.

The auto-generated regex is `^token1.*tokenN([[:space:]]|$)` for `anchored
= true` (or `(^|[[:space:]])` instead of `^` for `anchored = false`). The
trailing word boundary prevents substring matches like `merge` inside
`--no-merges`.

Provide a `hookRegex` override only when the auto-derived regex is too broad
or too narrow for a specific case (see the existing `rm` and `git -C`
overrides for examples).

### 5.2. New Allowlist Entry

Add to `bash-commands-allowed.nix` only after checking the full command and
argument shape. An allowlist match admits automatic hook continuation, so
ordinary entries must be side-effect-free and must not hide another command.

`tmux-a2a-postman` is the approval channel's explicit allowlist entry. Its
`execute-heredoc` subcommand can execute caller-supplied source in a fresh shell
after the typed review decision, or under the documented advisory path when
no approver is configured or positively present. The CLI entry avoids a
circular hook denial; it is not a claim that every Postman invocation is inert
or that command approval replaces human/runtime authority. See installed
`tmux-a2a-postman help execute-heredoc` for the current workflow.

### 5.3. New Strip Arg

Add to `stripDataArgs`, which the hook applies before both allowlist and
denial-message pattern matching. The bar for adding an arg:

- The arg must conventionally take a quoted message or text value.
- Stripping the value must not hide command tokens needed for allowlist
  classification or a specific denial explanation.

`-m` qualifies because `git commit`, `git tag`, `gh issue create`, and
similar tools all take it as a textual message argument. The strip
preserves the rest of the command, so `git commit -m "msg" --amend` still
receives the `--amend`-specific denial explanation.

## 6. Known Limits

The hook checks command text with bounded shell-shape, secret-path and
allowlist rules; it does not prove the behavior of an allowed process. Quoted
heredoc bodies are inert data for this check, while unquoted bodies remain
visible because the shell expands them. A new CLI subcommand or argument
behavior can change the effects of an allowlisted entry and needs a fresh
review against installed help and runtime evidence.

`DENY_PATTERNS` affect the explanation for an off-allowlist command, not the
allow decision. Missing wrapper or flag spellings can weaken the specificity
of that explanation, but an off-allowlist command still receives the generic
denial. Separately approved Postman execution has its own decision and
human/runtime gates; it is not confined by this direct-Bash allowlist.

## 7. References

- `skills/dotfiles/references/agent-config-philosophy.md` — the design
  principles this hook system follows (prompt-first, shared SSOT,
  vendor-specific as compensation).
- `nix/home-manager/agents/shared/bash-commands-allowed.nix` — default-deny
  allowlist and automatic hook-admission decisions.
- `nix/home-manager/agents/shared/bash-commands-denied.nix` — specific denial
  messages, `stripDataArgs` and Claude native deny entries.
- `nix/home-manager/agents/scripts/pretooluse-deny-bash.sh` — the
  PreToolUse hook script.
- `nix/home-manager/agents/claude/default.nix` — wires the shared policy into
  <!-- private-content-scan: allow-next-line -->
  `~/.claude/settings.json` and `~/.claude/scripts/`.
- `nix/home-manager/agents/codex/default.nix` — wires the shared hook and
  <!-- private-content-scan: allow-next-line -->
  generated patterns into `~/.codex/scripts/` and `~/.codex/hooks.json`.
- `tmux-a2a-postman help execute-heredoc` — the typed invocation and approval
  path for commands denied by the direct Bash allowlist.
