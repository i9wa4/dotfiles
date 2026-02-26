# Shared MCP server definitions for Claude Code and Codex CLI
# Used by claude-code.nix and codex.nix
{pkgs, inputs}:
let
  # Servers managed by mcp-servers-nix (pinned Nix packages)
  nixServers =
    (inputs.mcp-servers-nix.lib.evalModule pkgs {
      programs = {
        context7.enable = true;
      };
    })
    .config
    .settings
    .servers;

  # Servers not yet in mcp-servers-nix (use npx/uvx at runtime)
  manualServers = {
    awslabs-aws-documentation-mcp-server = {
      command = "uvx";
      args = ["awslabs.aws-documentation-mcp-server@latest"];
    };
    drawio = {
      command = "npx";
      args = ["-y" "@drawio/mcp"];
    };
  };
in
  nixServers // manualServers
