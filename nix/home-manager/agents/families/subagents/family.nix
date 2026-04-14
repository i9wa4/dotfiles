{
  pkgs,
  renderCodexAgents,
}:
let
  inherit (pkgs) lib;
  sourceDir = ../../subagents;
  metadata = import ./metadata.nix;
  subagentNames = builtins.attrNames metadata;

  mkClaudeAgent =
    basename:
    let
      cfg = metadata.${basename};
      body = builtins.readFile "${sourceDir}/${basename}.md";
    in
    {
      name = "${basename}.md";
      path = pkgs.writeText "${basename}.md" (
        ''
          ---
          name: ${builtins.toJSON cfg.name}
          description: ${builtins.toJSON cfg.description}
          model: ${builtins.toJSON cfg.claude.model}
          effort: ${builtins.toJSON cfg.claude.effort}
          ---

        ''
        + body
      );
    };

  mkCodexAgent =
    basename:
    let
      cfg = metadata.${basename};
      body = builtins.readFile "${sourceDir}/${basename}.md";
    in
    {
      name = "${basename}.toml";
      path = pkgs.writeText "${basename}.toml" (
        ''
          name = ${builtins.toJSON cfg.name}
          description = ${builtins.toJSON cfg.description}
        ''
        + lib.optionalString (cfg.codex.model != null) ''
          model = ${builtins.toJSON cfg.codex.model}
        ''
        + lib.optionalString (cfg.codex.modelReasoningEffort != null) ''
          model_reasoning_effort = ${builtins.toJSON cfg.codex.modelReasoningEffort}
        ''
        + "developer_instructions = '''\n\n"
        + body
        + "\n'''\n"
      );
    };
in
{
  claudeAgentsDir = pkgs.linkFarm "subagents-claude-agents" (map mkClaudeAgent subagentNames);

  codexAgentsDir = pkgs.linkFarm "subagents-codex-agents" (map mkCodexAgent subagentNames);
}
