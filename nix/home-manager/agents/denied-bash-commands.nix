# Single source of truth (SSOT) for denied Bash commands.
# Both Claude Code and Codex CLI consume this module's pre-computed outputs.
#
# ── Usage ──────────────────────────────────────────────────────────────
#
#   deniedBash = import ./denied-bash-commands.nix { inherit pkgs; };
#
#   # Claude Code
#   permissions.deny = deniedBash.claudeCode.denyPermissions ++ [ ... ];
#   home.file."...".source = deniedBash.claudeCode.patternsFile;
#
#   # Codex CLI
#   rulesContent = deniedBash.codexCli.rulesContent;
#
# ── Data Flow ──────────────────────────────────────────────────────────
#
#   entries (below)
#   │
#   ├── claudeCode.denyPermissions ─► ~/.claude/settings.json permissions.deny
#   │   (only entries with claudeSettingsJson = true)
#   │   Format: Bash(<glob>), glob auto-derived from argv
#   │
#   ├── claudeCode.patternsFile ────► ~/.claude/bash-deny-patterns.sh
#   │   (all entries, hookRegex auto-derived from argv)
#   │   Source'd by claude-pretooluse-bash-deny.sh at runtime.
#   │
#   └── codexCli.rulesContent ──────► ~/.codex/rules/default.rules
#       (all entries)                  Format: prefix_rule(...)
#
# ── Entry Fields ───────────────────────────────────────────────────────
#
# argv (required)
#   - Token array used by Codex CLI prefix_rule AND auto-derived hookRegex
#   - hookRegex derivation: 1 token → \btoken\b, 2+ → joined with .*
#
# justification (required)
#   - Human-readable denial message (shared by Claude Code hook + Codex CLI)
#
# claudeSettingsJson (optional, default: false)
#   - true → also add to ~/.claude/settings.json permissions.deny
#   - Auto-derives glob from argv: 1 token → "token *", 2+ → joined + *
#   - Use for truly dangerous commands (Claude won't even attempt them)
#
# ── Adding a new entry ─────────────────────────────────────────────────
#
#   1. Add { argv = [...]; justification = "..."; } below
#      (add claudeSettingsJson = true for truly dangerous commands)
#   2. Run: home-manager switch
#   3. Both Claude Code and Codex CLI pick up the change automatically
#
# ── Scope ──────────────────────────────────────────────────────────────
#
# This file covers Bash command deny rules ONLY.
# File access restrictions (Read/Write deny patterns) are defined
# directly in claude-code.nix. Codex CLI has no file access deny
# equivalent (noted in codex-cli.nix).
{ pkgs }:
let
  entries = [
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
      argv = [ "rm" ];
      justification = "rm is denied; use mv /tmp/ instead";
      claudeSettingsJson = true;
    }
    {
      argv = [ "sudo" ];
      justification = "sudo is denied";
      claudeSettingsJson = true;
    }
  ];

  # Auto-derive hookRegex from argv (applied per shell fragment after ;&| split):
  #   1 token  → ^token\b (must be the command, not an argument)
  #   2+ tokens → ^token1.*token2 (first token anchored, rest flexible)
  mkHookRegex =
    cmd:
    if builtins.length cmd.argv == 1 then
      "^${builtins.head cmd.argv}\\b"
    else
      "^" + builtins.concatStringsSep ".*" cmd.argv;

  # Auto-derive claudeGlob from argv (for entries with claudeSettingsJson = true):
  #   1 token  → "token *" (space before * to require an argument)
  #   2+ tokens → "token1 token2*" (no space, matches with or without trailing args)
  mkClaudeGlob =
    cmd:
    if builtins.length cmd.argv == 1 then
      "${builtins.head cmd.argv} *"
    else
      builtins.concatStringsSep " " cmd.argv + "*";

  mkPrefixRule =
    cmd:
    let
      patternItems = builtins.concatStringsSep ", " (map (s: "\"${s}\"") cmd.argv);
    in
    ''
      prefix_rule(
          pattern = [${patternItems}],
          decision = "forbidden",
          justification = "${cmd.justification}",
      )
    '';
in
{
  inherit entries;

  claudeCode = {
    # permissions.deny entries (only commands with claudeSettingsJson = true)
    denyPermissions = map (cmd: "Bash(${mkClaudeGlob cmd})") (
      builtins.filter (cmd: cmd.claudeSettingsJson or false) entries
    );

    # Generated patterns file for the PreToolUse hook (all entries)
    patternsFile = pkgs.writeText "bash-deny-patterns.sh" ''
      # Auto-generated by home-manager from denied-bash-commands.nix
      # Do not edit manually — run: home-manager switch
      DENY_PATTERNS=(
      ${builtins.concatStringsSep "\n" (map (cmd: "  '${mkHookRegex cmd}'") entries)}
      )
      DENY_JUSTIFICATIONS=(
      ${builtins.concatStringsSep "\n" (map (cmd: "  '${cmd.justification}'") entries)}
      )
    '';
  };

  codexCli = {
    # prefix_rule content for default.rules (all entries)
    rulesContent = builtins.concatStringsSep "\n" (map mkPrefixRule entries);
  };
}
