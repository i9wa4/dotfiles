_: {
  researcher-tech = {
    name = "researcher-tech";
    description = "Technical research specialist. Thorough investigator.";

    claude = {
      model = "sonnet";
      effort = "medium";
    };

    codex = {
      # Keep the generic researcher on the active/default Codex model in this
      # lane; #146 only makes that choice explicit in one family-local place.
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  super-codex-reviewer = {
    name = "super-codex-reviewer";
    description = "Deep code reviewer. Perfectionist. Debates until consensus.";

    claude = {
      # The raw shared body currently carries a Codex-only model string. Keep
      # Claude on the parent model instead of inventing a new Claude-specific pin
      # in this metadata-shape lane.
      model = "inherit";
      effort = "medium";
    };

    codex = {
      model = "gpt-5.4";
      modelReasoningEffort = "medium";
    };
  };
}
