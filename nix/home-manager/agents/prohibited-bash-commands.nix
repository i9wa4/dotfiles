# Single source of truth (SSOT) for prohibited Bash commands.
# Both Claude Code and Codex CLI consume this file via their respective
# Nix modules, each reading the fields relevant to their enforcement engine.
#
# ── Data Flow ──────────────────────────────────────────────────────────
#
#   prohibited-bash-commands.nix (this file)
#   │
#   ├── claudeGlob ─► claude-code.nix ─► settings.json permissions.deny
#   │                   Format: Bash(<glob>)
#   │                   Engine: glob match against full command string
#   │
#   ├── argv ──────► codex-cli.nix ──► ~/.codex/rules/default.rules
#   │                   Format: prefix_rule(pattern=[...], decision="forbidden")
#   │                   Engine: argv prefix match (parsed tokens, not raw string)
#   │
#   ├── hookRegex ─► claude-code.nix ─► ~/.claude/generated/bash-deny-patterns.sh
#   │   (planned)     Source'd by claude-pretooluse-bash-deny.sh at runtime.
#   │                   Engine: grep -E per shell fragment (split on ;&|)
#   │
#   └── justification ─► codex-cli.nix ─► default.rules (denial message)
#                          Claude Code hook uses its own message format.
#
# ── Field Reference ────────────────────────────────────────────────────
#
# claudeGlob (Claude Code · permissions.deny)
#   - Glob pattern matched against the full command string
#   - * is a single-level wildcard; space before * matters:
#       "git push*"  → blocks bare `git push` AND `git push origin main`
#       "git push *" → blocks `git push origin` but NOT bare `git push`
#       "rm *"       → blocks `rm file` (requires arg after rm)
#   - Claude Code is aware of shell operators (&&, |, ;), so deny rules
#     are NOT bypassed by compound commands like `ls && rm foo`
#   - Evaluation order: deny → ask → allow (first match wins)
#
# argv (Codex CLI · prefix_rule)
#   - Array of argv tokens for prefix matching
#   - Codex CLI parses the command into argv BEFORE matching,
#     so compound commands are handled natively
#   - Only decision="forbidden" is confirmed; "allow"/"ask" unverified
#
# hookRegex (Claude Code · PreToolUse hook) [planned]
#   - Extended regex (grep -E) applied per shell fragment
#   - The hook splits commands on ;&| then checks each fragment
#   - Use \b for word boundaries (e.g., \brm\b avoids matching "farm")
#   - Extra safety layer on top of permissions.deny
#
# justification (Codex CLI only)
#   - Human-readable reason shown when Codex CLI denies a command
#   - Claude Code hook builds its own denial message
#
# ── Adding a new entry ─────────────────────────────────────────────────
#
#   1. Add an entry below with claudeGlob, argv, and justification
#      (add hookRegex once the generated patterns file is implemented)
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
    claudeGlob = "git -C *";
    argv = [
      "git"
      "-C"
    ];
    justification = "cross-directory git operations are prohibited";
  }
  {
    claudeGlob = "git push*";
    argv = [
      "git"
      "push"
    ];
    justification = "pushing is prohibited";
  }
  {
    claudeGlob = "git rebase*";
    argv = [
      "git"
      "rebase"
    ];
    justification = "rebase is prohibited";
  }
  {
    claudeGlob = "git reset*";
    argv = [
      "git"
      "reset"
    ];
    justification = "reset is prohibited";
  }
  {
    claudeGlob = "git commit --amend*";
    argv = [
      "git"
      "commit"
      "--amend"
    ];
    justification = "amend is prohibited (causes force push requirement)";
  }
  {
    claudeGlob = "git merge*";
    argv = [
      "git"
      "merge"
    ];
    justification = "merge is prohibited";
  }
  {
    claudeGlob = "git branch -d*";
    argv = [
      "git"
      "branch"
      "-d"
    ];
    justification = "branch deletion is prohibited";
  }
  {
    claudeGlob = "git branch -D*";
    argv = [
      "git"
      "branch"
      "-D"
    ];
    justification = "branch force-deletion is prohibited";
  }
  {
    claudeGlob = "rm *";
    argv = [ "rm" ];
    justification = "rm is prohibited; use mv /tmp/ instead";
  }
  {
    claudeGlob = "sudo *";
    argv = [ "sudo" ];
    justification = "sudo is prohibited";
  }
]
