# Single source of truth for prohibited Bash commands.
# Used by claude-code.nix (permissions.deny) and codex-cli.nix (default.rules).
#
# claudeGlob: exact glob pattern for Claude Code permissions.deny
#   NOTE: spacing before * matters. "git push*" blocks bare `git push`;
#         "git push *" would NOT block bare `git push`.
# argv: command argv prefix for Codex CLI prefix_rule()
# justification: human-readable reason shown in Codex CLI denial messages
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
