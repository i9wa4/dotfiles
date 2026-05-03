# Shared MCP server definitions for Claude Code and Codex CLI
# Used by claude/default.nix and codex/default.nix
_:
# Keep MCP disabled by default. Context7 is used through the ctx7 CLI and
# skills instead, so Codex/Claude do not start or register MCP servers.
{ }
