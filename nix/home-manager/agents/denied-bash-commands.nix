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
#   ├── claudeCode.patternsFile ────► ~/.claude/scripts/deny-bash-patterns.sh
#   │   (all entries, hookRegex auto-derived from argv)
#   │   Source'd by claude-pretooluse-deny-bash.sh at runtime.
#   │
#   └── codexCli.rulesContent ──────► ~/.codex/rules/default.rules
#       (all entries)                  Format: prefix_rule(...)
#
# ── Entry Fields ───────────────────────────────────────────────────────
#
# argv (required)
#   - Token array used by Codex CLI prefix_rule AND auto-derived hookRegex
#   - hookRegex derivation:
#       1 token  → ^token([[:space:]]|$)
#       2+ tokens → ^token1.*token2
#
# justification (required)
#   - Human-readable denial + repair hint (shared by Claude Code hook + Codex CLI)
#
# claudeSettingsJson (optional, default: false)
#   - true → also add to ~/.claude/settings.json permissions.deny
#   - Auto-derives glob from argv: 1 token → "token *", 2+ → joined + *
#   - Use for truly dangerous commands (Claude won't even attempt them)
#
# anchored (optional, default: true)
#   - false → uses (^|[[:space:]]) instead of ^ so the pattern can match after
#     wrapper prefixes inside the fragment (bash -c, env, exec, etc.)
#   - Use for high-consequence operations (push, reset, rebase, etc.)
#
# hookRegex (optional)
#   - Verbatim regex string; overrides auto-derived hookRegex entirely
#   - Use when argv-based derivation produces an over-broad pattern
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
      hookRegex = "^git\\s+-C\\s";
      justification = "cross-directory git operations are denied; cd into the target repo and run git there instead";
    }
    {
      argv = [
        "git"
        "push"
      ];
      anchored = false;
      justification = "pushing is denied; stop after local verification and report the branch and commit instead";
    }
    {
      argv = [
        "git"
        "rebase"
      ];
      anchored = false;
      justification = "rebase is denied; make a new commit or request an explicit rollback or rewrite task instead";
    }
    {
      argv = [
        "git"
        "reset"
      ];
      anchored = false;
      justification = "reset is denied; inspect with git status or git diff and use apply_patch or an explicit rollback task instead";
    }
    {
      argv = [
        "git"
        "commit"
        "--amend"
      ];
      anchored = false;
      justification = "amend is denied because it creates a force-push requirement; make a new commit and report the new hash instead";
    }
    {
      argv = [
        "git"
        "merge"
      ];
      anchored = false;
      justification = "merge is denied; keep the branch linear and use a new commit or ask for explicit integration instructions";
    }
    {
      argv = [
        "git"
        "branch"
        "-d"
      ];
      anchored = false;
      justification = "branch deletion is denied; leave branch cleanup to the user and report the stale branch instead";
    }
    {
      argv = [
        "git"
        "branch"
        "-D"
      ];
      anchored = false;
      justification = "branch force-deletion is denied; leave branch cleanup to the user and report the stale branch instead";
    }
    {
      argv = [
        "git"
        "branch"
        "--delete"
      ];
      anchored = false;
      justification = "branch deletion is denied; leave branch cleanup to the user and report the stale branch instead";
    }
    {
      argv = [
        "git"
        "branch"
        "--delete"
        "--force"
      ];
      anchored = false;
      justification = "branch force-deletion is denied; leave branch cleanup to the user and report the stale branch instead";
    }
    {
      argv = [ "rm" ];
      anchored = false;
      # Override: \b is not POSIX ERE; causes false positives on paths like "dataplatform".
      # Require rm to be preceded by start-of-fragment or whitespace instead.
      hookRegex = "(^|[[:space:]])rm([[:space:]]|$|-)";
      justification = "rm is denied; move the target to /tmp/ or edit it surgically with apply_patch instead";
      claudeSettingsJson = true;
    }
    {
      argv = [ "sudo" ];
      anchored = false;
      justification = "sudo is denied; stay within user permissions or report the exact manual step that requires elevation";
      claudeSettingsJson = true;
    }
    {
      argv = [
        "aws"
        "sso"
        "login"
      ];
      anchored = false;
      justification = "aws sso login is denied; ask the user to run the login in their own tmux pane and continue only after credentials already exist";
      claudeSettingsJson = true;
    }
    {
      argv = [
        "tmux"
        "select-pane"
        "-T"
      ];
      anchored = false;
      justification = "tmux pane-title renames are denied because role identity depends on pane_title; keep the current pane title and report the needed role change instead";
      claudeSettingsJson = true;
    }
  ];

  # Hook bypass: fragments starting with these prefixes (followed by whitespace
  # or end) skip the regex deny check entirely. Use only for tools that take
  # user-data as arguments and do not execute arbitrary user commands.
  # The hook still recursively checks bash -c / sh -c wrappers via
  # unwrap_shell_wrapper, so wrapping a denied command in bash -c does not
  # reach the bypass.
  # This list is consumed only by the Claude Code regex hook; Codex CLI's
  # argv-based prefix_rule matcher does not have the substring false-positive
  # this guards against.
  allowPrefixBypass = [
    "tmux-a2a-postman"
  ];

  # Auto-derive hookRegex from argv (applied per shell fragment after ;&| split):
  #   1 token  → ^token([[:space:]]|$) (must be the command, not an argument)
  #   2+ tokens → ^token1.*tokenN([[:space:]]|$) (last token anchored at a word
  #     boundary so substrings like "merge" inside "--no-merges" do not match)
  #   anchored = false → use (^|[[:space:]]) instead of ^ so wrapper prefixes
  #     (bash -c, env, exec) are caught without relying on non-POSIX \b
  #   hookRegex override → use verbatim (ignores anchored field)
  mkHookRegex =
    cmd:
    cmd.hookRegex or (
      let
        anchored = cmd.anchored or true;
        prefix = if anchored then "^" else "(^|[[:space:]])";
        tail = "([[:space:]]|$)";
      in
      if builtins.length cmd.argv == 1 then
        "${prefix}${builtins.head cmd.argv}${tail}"
      else
        prefix + builtins.concatStringsSep ".*" cmd.argv + tail
    );

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
      escapedJustification = builtins.replaceStrings [ "\\" "\"" ] [ "\\\\" "\\\"" ] cmd.justification;
    in
    ''
      prefix_rule(
          pattern = [${patternItems}],
          decision = "forbidden",
          justification = "${escapedJustification}",
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
    patternsFile = pkgs.writeText "deny-bash-patterns.sh" ''
      # Auto-generated by home-manager from denied-bash-commands.nix
      # Do not edit manually — run: home-manager switch
      DENY_PATTERNS=(
      ${builtins.concatStringsSep "\n" (map (cmd: "  '${mkHookRegex cmd}'") entries)}
      )
      DENY_JUSTIFICATIONS=(
      ${builtins.concatStringsSep "\n" (
        map (cmd: "  '${builtins.replaceStrings [ "'" ] [ "'\\''" ] cmd.justification}'") entries
      )}
      )
      ALLOW_PREFIX_BYPASS=(
      ${builtins.concatStringsSep "\n" (map (p: "  '${p}'") allowPrefixBypass)}
      )
    '';
  };

  codexCli = {
    # prefix_rule content for default.rules (all entries)
    rulesContent = builtins.concatStringsSep "\n" (map mkPrefixRule entries);
  };
}
