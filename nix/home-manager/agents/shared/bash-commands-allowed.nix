# Single source of truth (SSOT) for allowed Bash commands.
# Both Claude Code and Codex CLI consume this module's pre-computed outputs.
# Paired with bash-commands-denied.nix: this file is the default-deny
# allowlist gate (checked first); the deny file supplies friendlier,
# specific messages for the commands most likely to be attempted anyway.
#
# ── Model ──────────────────────────────────────────────────────────────
#
# Default-deny: a Bash command is allowed only if it matches an entry
# here, or the dedicated grep/rg procedural check in
# pretooluse-deny-bash.sh (too shape-sensitive for a single regex entry;
# see that script's `check_grep_rg_allow` for the exact, already
# approver-reviewed rule set). Every other command is denied, whether or
# not it also happens to match a bash-commands-denied.nix entry.
#
# ── Usage ──────────────────────────────────────────────────────────────
#
#   allowedBash = import ./bash-commands-allowed.nix { };
#
#   # Both Claude Code and Codex CLI
#   home.file."...".source = allowedBash.patternsFile;
#   (merged into the same generated file as bash-commands-denied.nix's
#   patternsFile by the caller -- see claude/default.nix and
#   codex/default.nix)
#
# ── Entry Fields ───────────────────────────────────────────────────────
#
# argv (required)
#   - Token array used to auto-derive hookRegex (same derivation rules as
#     bash-commands-denied.nix: 1 token -> anchored single-command match,
#     2+ tokens -> ordered substring match with a word-boundary tail).
#
# anchored (optional, default: true)
#   - false -> uses (^|[[:space:]]) instead of ^ so the pattern can match
#     after wrapper prefixes inside the fragment (bash -c, env, exec).
#     Not expected to be needed for read-only allowlist entries, but kept
#     for symmetry with the deny file's field shape.
#
# hookRegex (optional)
#   - Verbatim regex string; overrides auto-derived hookRegex entirely.
#
# note (required)
#   - Human-readable reason this command is safe to auto-allow. Not shown
#     to the agent (allow decisions don't need a repair hint); documents
#     the review rationale for humans reading this file.
#
# ── Adding a new entry ─────────────────────────────────────────────────
#
#   1. Add { argv = [...]; note = "..."; } below.
#   2. Confirm the command is genuinely side-effect-free and cannot be
#      abused via argument injection (see the exclusion notes at the
#      bottom of this file before adding anything that can write, invoke
#      a subshell/system() call, or read environment/secret material).
#   3. Run: home-manager switch
#   4. Both Claude Code and Codex CLI pick up the change automatically.
#
# ── Scope ──────────────────────────────────────────────────────────────
#
# This file covers Bash command allow rules ONLY. It has no effect on
# `permissions.deny` (Claude's own native, harness-level denials for
# truly dangerous commands, e.g. `rm`, `sudo`) or on Codex/Claude
# filesystem and network sandbox settings -- those remain separate,
# orthogonal controls.
_:
let
  entries = [
    {
      argv = [ "tmux-a2a-postman" ];
      note = "The postman CLI is the approval channel itself; requiring approval to use it would be circular. Does not execute arbitrary commands itself (see the shared hook's shell-wrapper unwrap, which still recurses into bash -c/sh -c payloads). A send-heredoc call's --to/--body-carrying heredoc is shell redirection syntax resolved by bash before the CLI ever receives stdin, not CLI-internal data handling -- the shared hook's mask_heredoc_bodies (issue #355) is what keeps a QUOTED heredoc body (<<'DELIM') inert for this allow entry; an unquoted delimiter (<<DELIM) is deliberately left unmasked and fully scanned, because bash itself expands substitutions inside that body as live syntax.";
    }
    {
      argv = [ "ls" ];
      note = "Read-only directory listing.";
    }
    {
      argv = [ "pwd" ];
      note = "Read-only cwd report.";
    }
    {
      argv = [ "cat" ];
      note = "Read-only file output. Callers wanting write/exec side effects need shell metacharacters, which the shared hook's chaining/substitution/redirection check rejects before this allowlist is even consulted.";
    }
    {
      argv = [ "head" ];
      note = "Read-only partial file output.";
    }
    {
      argv = [ "tail" ];
      note = "Read-only partial file output.";
    }
    {
      argv = [ "wc" ];
      note = "Read-only counting.";
    }
    {
      argv = [ "sort" ];
      note = "Read-only/stdin-transform, no filesystem mutation without redirection (already rejected upstream).";
    }
    {
      argv = [ "uniq" ];
      note = "Read-only/stdin-transform.";
    }
    {
      argv = [ "cut" ];
      note = "Read-only/stdin-transform.";
    }
    {
      argv = [ "date" ];
      note = "Informational, no side effects.";
    }
    {
      argv = [ "whoami" ];
      note = "Informational, no side effects.";
    }
    {
      argv = [ "which" ];
      note = "Informational, no side effects.";
    }
    {
      argv = [ "echo" ];
      note = "Informational; writes only to stdout unless redirected, which is rejected upstream.";
    }
    {
      argv = [
        "git"
        "status"
      ];
      note = "Read-only repository inspection.";
    }
    {
      argv = [
        "git"
        "diff"
      ];
      note = "Read-only repository inspection.";
    }
    {
      argv = [
        "git"
        "log"
      ];
      note = "Read-only repository inspection.";
    }
    {
      argv = [
        "git"
        "show"
      ];
      note = "Read-only repository inspection.";
    }
    {
      argv = [
        "git"
        "branch"
      ];
      # Deliberately narrower than the auto-derived tail, and fully
      # end-anchored (not the usual "space-or-end" tail): the standard
      # `([[:space:]]|$)` tail only requires ONE space after "branch" and
      # does not care what follows, so "git branch -d stale" would still
      # match it -- verified by a real pipe-test during implementation,
      # which caught exactly this before it shipped. Requiring `$`
      # immediately (after an optional "--list") makes this match ONLY
      # the bare no-argument list form or "git branch --list", never a
      # form carrying -d/-D/--delete, which stay denied.
      hookRegex = "^git[[:space:]]+branch([[:space:]]+--list)?[[:space:]]*$";
      note = "Read-only branch listing only -- deliberately excludes -d/-D/--delete, which stay denied.";
    }
  ];

  # Auto-derive hookRegex from argv (same derivation as
  # bash-commands-denied.nix's mkHookRegex, duplicated here rather than
  # shared to keep each file independently readable end-to-end).
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

in
{
  inherit entries;

  # Generated array fragment, merged into the same generated patterns
  # file as bash-commands-denied.nix's DENY_PATTERNS by the caller (see
  # claude/default.nix and codex/default.nix), so the shared hook script
  # sources one file with both ALLOW_PATTERNS and DENY_PATTERNS defined.
  allowPatternsFragment = ''
    ALLOW_PATTERNS=(
    ${builtins.concatStringsSep "\n" (map (cmd: "  '${mkHookRegex cmd}'") entries)}
    )
  '';
}
