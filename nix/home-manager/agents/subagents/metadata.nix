# Runtime metadata for native reviewer subagents.
#
# Prompt bodies stay in the sibling Markdown files. This file owns settings
# that the runtimes read as configuration instead of instruction text.
{
  reviewer-architecture = {
    claude = {
      model = "sonnet";
      effort = "high";
    };
    codex = {
      model = "gpt-5.4";
      modelReasoningEffort = "medium";
    };
  };

  reviewer-code = {
    claude = {
      model = "sonnet";
      effort = "high";
    };
    codex = {
      model = "gpt-5.4";
      modelReasoningEffort = "medium";
    };
  };

  reviewer-data = {
    claude = {
      model = "sonnet";
      effort = "high";
    };
    codex = {
      model = "gpt-5.4";
      modelReasoningEffort = "high";
    };
  };

  reviewer-historian = {
    claude = {
      model = "sonnet";
      effort = "high";
    };
    codex = {
      model = "gpt-5.4";
      modelReasoningEffort = "medium";
    };
  };

  reviewer-qa = {
    claude = {
      model = "sonnet";
      effort = "high";
    };
    codex = {
      model = "gpt-5.4";
      modelReasoningEffort = "medium";
    };
  };

  reviewer-security = {
    claude = {
      model = "sonnet";
      effort = "high";
    };
    codex = {
      model = "gpt-5.4";
      modelReasoningEffort = "medium";
    };
  };
}
