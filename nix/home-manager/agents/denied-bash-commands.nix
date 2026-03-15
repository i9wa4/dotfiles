# Single source of truth (SSOT) for denied Bash commands.
# Both Claude Code and Codex CLI consume this file via their respective
# Nix modules, each reading the fields relevant to their enforcement engine.
#
# ── Data Flow ──────────────────────────────────────────────────────────
#
#   denied-bash-commands.nix (this file)
#   │
#   ├── claudeGlob  ─► claude-code.nix ─► settings.json permissions.deny
#   │   (optional)     Format: Bash(<glob>)
#   │                   Engine: glob match against full command string
#   │                   Role: proactive (tells Claude not to attempt)
#   │
#   ├── argv ───────► claude-code.nix ─► ~/.claude/bash-deny-patterns.sh
#   │   (auto)         Auto-derived hookRegex: 1 token → \btoken\b, 2+ → joined
#   │                   Source'd by claude-pretooluse-bash-deny.sh at runtime.
#   │                   Engine: grep -E per shell fragment (split on ;&|)
#   │                   Role: reactive (blocks with justification message)
#   │
#   ├── argv ───────► codex-cli.nix ──► ~/.codex/rules/default.rules
#   │                   Format: prefix_rule(pattern=[...], decision="forbidden")
#   │                   Engine: argv prefix match (parsed tokens, not raw string)
#   │
#   └── justification ─► claude-code.nix ─► bash-deny-patterns.sh (denial message)
#                       ─► codex-cli.nix  ─► default.rules (denial message)
#
# ── Field Reference ────────────────────────────────────────────────────
#
# claudeGlob (Claude Code · permissions.deny) — optional
#   - Omit for hook-only enforcement (justification shown on deny)
#   - Set for truly dangerous commands (proactive block + hook)
#   - Glob pattern matched against the full command string
#   - * is a single-level wildcard; space before * matters:
#       "rm *"       → blocks `rm file` (requires arg after rm)
#   - Claude Code is aware of shell operators (&&, |, ;), so deny rules
#     are NOT bypassed by compound commands like `ls && rm foo`
#   - Evaluation order: deny → ask → allow (first match wins)
#
# argv (Codex CLI · prefix_rule + Claude Code hook)
#   - Array of argv tokens for prefix matching
#   - Codex CLI parses the command into argv BEFORE matching,
#     so compound commands are handled natively
#   - Also used to auto-derive hookRegex for the Claude Code hook:
#       1 token  → \btoken\b (word boundary to avoid partial matches)
#       2+ tokens → tokens joined with spaces (literal match)
#   - Only decision="forbidden" is confirmed; "allow"/"ask" unverified
#
# justification (Claude Code hook + Codex CLI)
#   - Human-readable reason shown when a command is denied
#   - Used by both tools: hook's denial message and Codex CLI's rules
#
# ── Adding a new entry ─────────────────────────────────────────────────
#
#   1. Add an entry below with argv and justification
#      (add claudeGlob only for truly dangerous commands)
#   2. Run: home-manager switch
#   3. Both Claude Code and Codex CLI pick up the change automatically
#
# ── Scope ──────────────────────────────────────────────────────────────
#
# This file covers Bash command deny rules ONLY.
# File access restrictions (Read/Write deny patterns) are defined
# directly in claude-code.nix. Codex CLI has no file access deny
# equivalent (noted in codex-cli.nix).
[
  {
    argv = [
      "git"
      "-C"
    ];
    justification = "cross-directory git operations are denied";
  }
  {
    argv = [
      "git"
      "push"
    ];
    justification = "pushing is denied";
  }
  {
    argv = [
      "git"
      "rebase"
    ];
    justification = "rebase is denied";
  }
  {
    argv = [
      "git"
      "reset"
    ];
    justification = "reset is denied";
  }
  {
    argv = [
      "git"
      "commit"
      "--amend"
    ];
    justification = "amend is denied (causes force push requirement)";
  }
  {
    argv = [
      "git"
      "merge"
    ];
    justification = "merge is denied";
  }
  {
    argv = [
      "git"
      "branch"
      "-d"
    ];
    justification = "branch deletion is denied";
  }
  {
    argv = [
      "git"
      "branch"
      "-D"
    ];
    justification = "branch force-deletion is denied";
  }
  {
    claudeGlob = "rm *";
    argv = [ "rm" ];
    justification = "rm is denied; use mv /tmp/ instead";
  }
  {
    claudeGlob = "sudo *";
    argv = [ "sudo" ];
    justification = "sudo is denied";
  }
]
