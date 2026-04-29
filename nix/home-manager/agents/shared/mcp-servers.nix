# Shared MCP server definitions for Claude Code and Codex CLI
# Used by claude/default.nix and codex/default.nix
{
  pkgs,
  inputs,
  ...
}:
(inputs.mcp-servers-nix.lib.evalModule pkgs {
  programs = {
    context7.enable = true;
  };
}).config.settings.servers
