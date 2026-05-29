# Runtime metadata for native reviewer subagents.
#
# Prompt bodies stay in the sibling Markdown files. This file owns settings
# that the runtimes read as configuration instead of instruction text.
{
  researcher-tech = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  reviewer-architecture = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  reviewer-code = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  reviewer-data = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  reviewer-historian = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  reviewer-qa = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };

  reviewer-security = {
    claude = {
      model = "inherit";
      effort = "medium";
    };
    codex = {
      model = null;
      modelReasoningEffort = "medium";
    };
  };
}
