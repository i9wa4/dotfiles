/*
  Subagent metadata. Single source of truth for both:
    - per-agent name/description/runtime defaults consumed by render-agents.nix to
      generate ~/.claude/agents/<name>.md and ~/.codex/agents/<name>.toml

  Layout:
    defaults
      claude.{model,effort}
      codex.{model,modelReasoningEffort}

    agents.<name>
      name, description (required)
      claude.{model,effort}              (optional, override)
      codex.{model,modelReasoningEffort} (optional, override)

    resolved.<name> -- defaults deep-merged with per-agent overrides; the
                      shape consumers should read from
*/
{ lib }:
let
  # Native runtime defaults. Apply to every agent unless that agent overrides
  # the same field below.
  defaults = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  # Per-agent declarations. `name` and `description` are required. Any
  # `claude.{model,effort}` or `codex.{model,modelReasoningEffort}` field is
  # OPTIONAL; omitted fields fall back to `defaults.*`.
  agents = {
    reviewer-security = {
      name = "reviewer-security";
      description = "Security expert. Conservative approach.";
    };
    reviewer-architecture = {
      name = "reviewer-architecture";
      description = "Architecture expert. Veteran with bird's-eye view.";
    };
    reviewer-historian = {
      name = "reviewer-historian";
      description = "Project historian. Context-focused archaeologist.";
    };
    reviewer-code = {
      name = "reviewer-code";
      description = "Code quality expert. Perfectionist.";
    };
    reviewer-data = {
      name = "reviewer-data";
      description = "Data model expert. Normalization master.";
    };
    reviewer-qa = {
      name = "reviewer-qa";
      description = "Acceptance criteria expert. Guardian of goal achievement.";
    };

    researcher-tech = {
      name = "researcher-tech";
      description = "Technical research specialist. Thorough investigator.";
      # This agent intentionally pins sonnet because research tasks do not need
      # a heavier default model.
      claude.model = "sonnet";
    };
  };

  # Materialised per-agent config with defaults deep-merged in.
  # Consumers read from `resolved` -- they never have to redo the merge.
  resolved = lib.mapAttrs (_: agent: lib.recursiveUpdate defaults agent) agents;
in
{
  inherit defaults agents resolved;
}
