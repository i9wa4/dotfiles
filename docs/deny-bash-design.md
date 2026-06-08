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

What it deliberately does not protect against:

- File-write-then-execute patterns like `echo "git push" > /tmp/x; /tmp/x`.
- Complete shell parsing for command substitutions and process substitutions.
  The hook normalises obvious command-substitution boundaries for deny matching
  and rejects supported data-only here-doc stripping when substitutions appear
  on the redirecting command line, but it is not a shell parser.
- Indirect execution through other languages
  (`python -c 'os.system("git push")'`).
- An agent that explicitly intends to evade the hook.

The trade-off is conscious. Closing every evasion path would require either
shell-aware parsing inside the hook or sandboxing the entire subprocess tree,
both of which exceed the value the hook is meant to deliver.

## 2. Single Source of Truth

`nix/home-manager/agents/shared/denied-bash-commands.nix` is the SSOT. It
defines three top-level lists:

- `entries` — deny rules. Each entry has an `argv` token list, an
  `anchored` flag, an optional `hookRegex` override, an optional
  `claudeSettingsJson` flag, and a human-readable `justification`.
- `allowPrefixBypass` — fragments starting with these prefixes skip the
  regex deny check entirely.
- `stripDataArgs` — for these arg names, the quoted value following the
  arg is replaced with `""` before the regex deny check.

The Nix module exposes two outputs that consume this SSOT:

| Output                       | Consumer                                                                                                                                      | Mechanism                                        |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `claudeCode.denyPermissions` | `~/.claude/settings.json` `permissions.deny`                                                                                                  | `Bash(<glob>)` glob match (Claude Code built-in) |
| `claudeCode.patternsFile`    | `~/.claude/scripts/deny-bash-patterns.sh` and `~/.codex/scripts/deny-bash-patterns.sh` (sourced by the shared `pretooluse-deny-bash.sh` hook) | POSIX ERE regex match                            |

`allowPrefixBypass` and `stripDataArgs` are emitted into the shared
`patternsFile`, so both Claude Code and Codex CLI inherit the same
data-carrier and message-argument protections. Codex does not duplicate the
shared command-deny set into embedded `prefix_rule(...)` rules; filesystem
and network blast-radius controls remain the responsibility of Codex
sandbox/approval settings.

## 3. Three Permission Layers

A Bash command from an AI agent passes through up to three independent gates
before it can run.

### 3.1. Layer 1 — Claude Code Built-In Safety Classifier

Claude Code itself recognises certain dangerous patterns
(`rm /`, `rm $HOME`, `sudo`, env-var prefixes, compound commands containing
dangerous primitives, redirects to `/dev/tcp/...`, `find -exec`,
`find -delete`, etc.) and surfaces a confirmation prompt.

`--dangerously-skip-permissions` does not bypass this layer. Recent Claude
Code releases (v2.1.98 onward) have closed several bypass-mode loopholes that
previously made compound commands and env-var prefixes auto-skip. See
`docs/claude-code` updates and the deny-system commit history for details.

### 3.2. Layer 2 — Local `permissions.deny` and Shared PreToolUse Hook

Per-repo deny rules sourced from the SSOT. Two sub-layers:

- Claude `permissions.deny` glob entries (only entries with
  `claudeSettingsJson = true`). Claude Code refuses to even attempt these
  commands. Bypass mode does not weaken this set.
- The shared PreToolUse hook (`scripts/pretooluse-deny-bash.sh`) reads
  `patternsFile` in both runtimes and matches every entry's regex against
  the issued Bash command. A match emits a deny payload with the entry's
  `justification`.

### 3.3. Layer 3 — Per-Command User Confirmation Prompt

Standard "Allow Bash(`<command>`)?" prompts. Suppressed by
`--dangerously-skip-permissions` for Claude commands that pass Layers 1 and 2.
Codex confirmation and sandbox behavior is configured through Codex
approval/sandbox settings, not through duplicated command-deny entries.

## 4. Hook Processing Pipeline

`check_bash_command_for_denials` and `check_bash_fragment_for_denials` in the
hook script implement this order. The full issued command first gets a narrow
here-doc pre-pass, then each fragment of the command (after quote-aware
splitting on top-level `;`, `&`, `|` operators) is processed as follows:

1. **Trim** leading and trailing whitespace.
2. **Safe here-doc body strip** (`strip_safe_heredoc_bodies`). The hook skips a
   here-doc body only when all of these are true:
   - the redirecting command line is a simple `cat` data-carrier command;
   - the command line has exactly one here-doc redirect;
   - the delimiter word is quoted after Bash quote-removal, including mixed or
     backslash quoting;
   - the command line has no top-level `;`, `&`, or `|`, no process
     substitution, no command substitution, and no unsupported fake marker;
   - the quote-removed terminator is found, with leading tabs accepted only for
     `<<-`.

   Unsupported or malformed here-doc syntax stays in the command text and is
   scanned fail-closed. Interpreter stdin (`bash <<'EOF'`), unquoted here-docs
   that can expand `$(...)`, pipelines such as `cat <<'EOF' | bash`, comments,
   arithmetic shifts, and missing terminators are not stripped.
3. **Bypass check** (`is_allow_prefix_bypass`). If the fragment starts with
   any prefix in `ALLOW_PREFIX_BYPASS`, return success without further
   checks. Spaces inside a multi-token prefix are matched as
   `[[:space:]]+`.
4. **Wrapper unwrap** (`unwrap_shell_wrapper`). If the fragment is
   `bash -c "..."`, `sh -c "..."`, or `zsh -c "..."` (including the `-lc`
   and `-cl` short forms), the inner script is extracted, one quote layer
   is stripped, and the inner script is recursively passed back through
   `check_bash_command_for_denials`. This makes wrapping a denied command
   in `bash -c` ineffective at evading the deny.
5. **Data-arg strip** (`strip_data_arg_values`). For each arg name listed
   in `STRIP_DATA_ARGS`, the quoted value following the arg is replaced
   with an empty string. This prevents legitimate `-m "msg with rm in it"`
   style messages from triggering false positives without weakening the
   check on flags that follow the message arg.
6. **Command-substitution boundary normalisation**
   (`normalize_command_substitution_boundaries`). `$(` and backtick boundaries
   that remain after data-arg stripping are normalised to whitespace before
   regex matching so deny rules can still match a command that starts at a
   substitution boundary. This is a guardrail, not full shell parsing.
7. **Regex match** loop. The (possibly stripped) fragment is tested against
   each pattern in `DENY_PATTERNS`. The first match emits a deny payload
   with the corresponding justification. The deny payload reports the
   **original fragment**, not the stripped one, so the agent sees the
   command it actually issued.

If none of the patterns match, the fragment is allowed.

## 5. Adding New Entries

### 5.1. New Deny Rule

Add to `entries`. Set `claudeSettingsJson = true` only when the command is
truly dangerous and Claude should not even attempt it; otherwise rely on the
hook side alone, which produces a teachable deny message.

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

### 5.2. New Bypass Prefix

Add to `allowPrefixBypass`. The bar for adding a prefix:

- The tool must be a pure data carrier. It must not execute commands that
  appear in its arguments.
- The tool must not be one whose subcommands include destructive
  operations on local state.
- A bypass prefix is whole-fragment exempt, so it only makes sense when
  the entire command line is data passing.

`tmux-a2a-postman` qualifies because every subcommand only manipulates the
postman state files and Claude UI; it never runs user-supplied commands.

### 5.3. New Strip Arg

Add to `stripDataArgs`. The bar for adding an arg:

- The arg must conventionally take a quoted message or text value.
- Stripping the value must not disable a deny rule that depends on the
  value being present (in practice, deny rules check command tokens, not
  argument values).

`-m` qualifies because `git commit`, `git tag`, `gh issue create`, and
similar tools all take it as a textual message argument. The strip
preserves the rest of the command, so `git commit -m "msg" --amend` still
trips the `--amend` deny.

## 6. Known Limits

Ranked from most-likely-to-be-encountered to least:

1. **Command substitution.** The hook normalises obvious `$(` and backtick
   boundaries before regex matching, which catches cases like `$(git push)`,
   including inside unquoted here-doc bodies that remain scanned. Double-quoted
   values for `stripDataArgs` stay scanned when they contain command
   substitution, because that content is executable shell territory rather than
   inert message text. The hook does not parse nested shell syntax or
   distinguish every inert argument inside a substitution from every executable
   command in that substitution.
2. **File-write-then-execute.** `echo "git push" > /tmp/x; bash /tmp/x` is
   two separate fragments after splitting; the second runs `bash`, which is
   not a denied command, and the file content is not analysed.
3. **Indirect execution.** Any command that spawns a shell out of band
   (`python -c '...'`, `node -e '...'`, `make run`) is opaque to the hook.
4. **Wrapper edge cases.** `unwrap_shell_wrapper` only catches
   `^(bash|sh|zsh) -(c|lc|cl) ...`. Variants like `/usr/bin/env bash -c`
   or `exec bash -c` are not unwrapped; they fall through to the regex
   loop and may or may not match depending on the wrapper layout.
5. **Long-form flag drift.** When git, AWS CLI, or another tool adds a new
   long-form spelling for an existing flag, both spellings need separate
   deny entries (see the `git branch -d` / `git branch --delete` pair).

These are accepted as part of the guardrail-not-boundary stance described
in section 1. If a stricter posture becomes necessary, the right move is to
replace the regex layer with a shell-aware parser, not to keep adding
special cases on top of regex.

## 7. References

- `docs/agent-config-philosophy.md` — the design principles this hook
  system follows (prompt-first, shared SSOT, vendor-specific as
  compensation).
- `nix/home-manager/agents/shared/denied-bash-commands.nix` — SSOT.
- `nix/home-manager/agents/scripts/pretooluse-deny-bash.sh` — the
  PreToolUse hook script.
- `nix/home-manager/agents/claude/default.nix` — wires the SSOT into
  `~/.claude/settings.json` and `~/.claude/scripts/`.
- `nix/home-manager/agents/codex/default.nix` — wires the shared hook and
  generated patterns into `~/.codex/scripts/` and `~/.codex/hooks.json`.
- `config/tmux-a2a-postman/postman.md` section 2.16 — multi-agent
  bash discipline that complements this hook system on the agent side.
