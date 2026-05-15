/*
  Renders subagent files for both Claude and Codex from a single SSOT
  (`subagents/_metadata.nix` + `subagents/<name>.md`).

  Outputs:
    claudeAgentsDir  -- linkFarm of <name>.md files for ~/.claude/agents/
    codexAgentsDir   -- linkFarm of <name>.toml files for ~/.codex/agents/

  The public `subagent-review` skill is hand-authored under top-level
  `skills/subagent-review/` and installed through the normal skill pipeline.
  This renderer only materializes native Claude/Codex subagent definitions.
*/
{ pkgs }:
let
  inherit (pkgs) lib;
  metadata = import ../subagents/_metadata.nix { inherit lib; };
  inherit (metadata) resolved;
  names = builtins.attrNames resolved;
  subagentsDir = ../subagents;

  readBody = name: builtins.readFile "${subagentsDir}/${name}.md";

  mkClaudeAgent =
    name:
    let
      cfg = resolved.${name};
      body = readBody name;
    in
    {
      name = "${name}.md";
      path = pkgs.writeText "${name}.md" (
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
    name:
    let
      cfg = resolved.${name};
      body = readBody name;
    in
    {
      name = "${name}.toml";
      path = pkgs.writeText "${name}.toml" (
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
  claudeAgentsDir = pkgs.linkFarm "agents-claude" (map mkClaudeAgent names);
  codexAgentsDir = pkgs.linkFarm "agents-codex" (map mkCodexAgent names);
  skillSources = { };
}
