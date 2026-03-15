# Single source of truth (SSOT) for denied Bash commands.
# Both Claude Code and Codex CLI consume this file via their respective
# Nix modules, each reading the fields relevant to their enforcement engine.
#
# ── Data Flow ──────────────────────────────────────────────────────────
#
#   denied-bash-commands.nix (this file)
#   │
#   ├── claudeGlob  ─► claude-code.nix ─► settings.json permissions.deny
#   │                    Format: Bash(<glob>)
#   │                    Engine: glob match against full command string
#   │                    Role: proactive (tells Claude not to attempt)
#   │
#   ├── hookRegex   ─► claude-code.nix ─► ~/.claude/bash-deny-patterns.sh
#   │                    Source'd by claude-pretooluse-bash-deny.sh at runtime.
#   │                    Engine: grep -E per shell fragment (split on ;&|)
#   │                    Role: reactive (blocks with justification message)
#   │
#   ├── argv ───────► codex-cli.nix ──► ~/.codex/rules/default.rules
#   │                    Format: prefix_rule(pattern=[...], decision="forbidden")
#   │                    Engine: argv prefix match (parsed tokens, not raw string)
#   │
#   └── justification ─► claude-code.nix ─► bash-deny-patterns.sh (denial message)
#                       ─► codex-cli.nix  ─► default.rules (denial message)
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
# hookRegex (Claude Code · PreToolUse hook)
#   - Extended regex (grep -E) applied per shell fragment
#   - The hook splits commands on ;&| then checks each fragment
#   - Use \b for word boundaries (e.g., \brm\b avoids matching "farm")
#   - Defense-in-depth layer on top of permissions.deny
#
# argv (Codex CLI · prefix_rule)
#   - Array of argv tokens for prefix matching
#   - Codex CLI parses the command into argv BEFORE matching,
#     so compound commands are handled natively
#   - Only decision="forbidden" is confirmed; "allow"/"ask" unverified
#
# justification (Claude Code hook + Codex CLI)
#   - Human-readable reason shown when a command is denied
#   - Used by both tools: hook's denial message and Codex CLI's rules
#
# ── Adding a new entry ─────────────────────────────────────────────────
#
#   1. Add an entry below with claudeGlob, hookRegex, argv, and justification
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
    hookRegex = "git -C";
    argv = [
      "git"
      "-C"
    ];
    justification = "cross-directory git operations are denied";
  }
  {
    claudeGlob = "git push*";
    hookRegex = "git push";
    argv = [
      "git"
      "push"
    ];
    justification = "pushing is denied";
  }
  {
    claudeGlob = "git rebase*";
    hookRegex = "git rebase";
    argv = [
      "git"
      "rebase"
    ];
    justification = "rebase is denied";
  }
  {
    claudeGlob = "git reset*";
    hookRegex = "git reset";
    argv = [
      "git"
      "reset"
    ];
    justification = "reset is denied";
  }
  {
    claudeGlob = "git commit --amend*";
    hookRegex = "git commit.*--amend";
    argv = [
      "git"
      "commit"
      "--amend"
    ];
    justification = "amend is denied (causes force push requirement)";
  }
  {
    claudeGlob = "git merge*";
    hookRegex = "git merge";
    argv = [
      "git"
      "merge"
    ];
    justification = "merge is denied";
  }
  {
    claudeGlob = "git branch -d*";
    hookRegex = "git branch -d";
    argv = [
      "git"
      "branch"
      "-d"
    ];
    justification = "branch deletion is denied";
  }
  {
    claudeGlob = "git branch -D*";
    hookRegex = "git branch -D";
    argv = [
      "git"
      "branch"
      "-D"
    ];
    justification = "branch force-deletion is denied";
  }
  {
    claudeGlob = "rm *";
    hookRegex = "\\brm\\b";
    argv = [ "rm" ];
    justification = "rm is denied; use mv /tmp/ instead";
  }
  {
    claudeGlob = "sudo *";
    hookRegex = "\\bsudo\\b";
    argv = [ "sudo" ];
    justification = "sudo is denied";
  }
]
