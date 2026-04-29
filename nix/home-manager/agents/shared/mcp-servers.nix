# Shared MCP server definitions for Claude Code and Codex CLI
# Used by claude-code.nix and codex-cli.nix
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
