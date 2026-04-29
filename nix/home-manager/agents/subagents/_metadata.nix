/*
  Subagent metadata. Single source of truth for both:
    - per-agent name/description/tier-defaults consumed by render-agents.nix to
      generate ~/.claude/agents/<name>.md and ~/.codex/agents/<name>.toml
    - the (engine, tier) -> model lookup table baked into the unified
      `subagent-review` dispatcher SKILL.md by render-agents.nix

  Layout:
    defaults
      claude.tier{1,2}.{model,effort}
      codex.tier{1,2}.{model,modelReasoningEffort}

    agents.<name>
      name, description (required)
      claude.tier{1,2}.{model,effort}              (optional, override)
      codex.tier{1,2}.{model,modelReasoningEffort} (optional, override)

    resolved.<name> -- defaults deep-merged with per-agent overrides; the
                      shape consumers should read from
*/
{ lib }:
let
  # Per-(engine, tier) defaults. Apply to every agent unless that agent
  # overrides the same field below.
  defaults = {
    claude = {
      tier1 = {
        model = "opus";
        effort = "high";
      };
      tier2 = {
        model = "inherit";
        effort = "medium";
      };
    };
    codex = {
      tier1 = {
        model = "gpt-5.5";
        modelReasoningEffort = "xhigh";
      };
      tier2 = {
        model = null;
        modelReasoningEffort = "medium";
      };
    };
  };

  # Per-agent declarations. `name` and `description` are required. Any
  # `claude.tierN.{model,effort}` or `codex.tierN.{model,modelReasoningEffort}`
  # field is OPTIONAL; omitted fields fall back to `defaults.*`.
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
      # This agent intentionally pins sonnet at both tiers -- research tasks
      # don't benefit from opus and the old single-tier config locked in
      # sonnet. tier1 is the same as tier2 by design here.
      claude.tier1.model = "sonnet";
      claude.tier2.model = "sonnet";
      codex.tier1.modelReasoningEffort = "medium";
    };
  };

  # Materialised per-agent config with defaults deep-merged in.
  # Consumers read from `resolved` -- they never have to redo the merge.
  resolved = lib.mapAttrs (_: agent: lib.recursiveUpdate defaults agent) agents;
in
{
  inherit defaults agents resolved;
}
