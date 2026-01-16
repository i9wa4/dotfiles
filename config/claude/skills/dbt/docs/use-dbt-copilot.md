---
title: "Use dbt Copilot | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/use-dbt-copilot"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot)* Use dbt Copilot

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fuse-dbt-copilot+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fuse-dbt-copilot+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fuse-dbt-copilot+so+I+can+ask+questions+about+it.)

On this page

Use Copilot to generate documentation, tests, semantic models, and code from scratch, giving you the flexibility to modify or fix generated code.

This page explains how to use Copilot to:

* [Generate resources](#generate-resources) — Save time by using Copilot’s generation button to generate documentation, tests, and semantic model files during your development in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio).
* [Generate and edit SQL inline](#generate-and-edit-sql-inline) — Use natural language prompts to generate SQL code from scratch or to edit existing SQL file by using keyboard shortcuts or highlighting code in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio).
* [Build visual models](#build-visual-models) — Use Copilot to generate models in [Canvas](https://docs.getdbt.com/docs/cloud/use-canvas) with natural language prompts.
* [Build queries](#build-queries) — Use Copilot to generate queries in [Insights](https://docs.getdbt.com/docs/explore/dbt-insights) for exploratory data analysis using natural language prompts.
* [Analyze data with the Analyst agent](#analyze-data-with-the-analyst-agent) — Use Copilot to analyze your data and get contextualized results in real time by asking a natural language question to the Analyst agent.

tip

Check out our [dbt Copilot on-demand course](https://learn.getdbt.com/learn/course/dbt-copilot/welcome-to-dbt-copilot/welcome-5-mins) to learn how to use Copilot to generate resources, and more!

## Generate resources[​](#generate-resources "Direct link to Generate resources")

Generate documentation, tests, metrics, and semantic models [resources](https://docs.getdbt.com/docs/build/projects) with the click-of-a-button in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) using dbt Copilot, saving you time. To access and use this AI feature:

1. Navigate to the Studio IDE and select a SQL model file under the **File Explorer**.
2. In the **Console** section (under the **File Editor**), click **dbt Copilot** to view the available AI options.
3. Select the available options to generate the YAML config: **Generate Documentation**, **Generate Tests**, **Generate Semantic Model**, or **Generate Metrics**. To generate multiple YAML configs for the same model, click each option separately. dbt Copilot intelligently saves the YAML config in the same file.
   * To generate metrics, you need to first have semantic models defined.
   * Once defined, click **dbt Copilot** and select **Generate Metrics**.
   * Write a prompt describing the metrics you want to generate and press enter.
   * **Accept** or **Reject** the generated code.
4. Verify the AI-generated code. You can update or fix the code as needed.
5. Click **Save As**. You should see the file changes under the **Version control** section.

[![Example of using dbt Copilot to generate documentation in the IDE](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/dbt-copilot-doc.gif?v=2 "Example of using dbt Copilot to generate documentation in the IDE")](#)Example of using dbt Copilot to generate documentation in the IDE

## Generate and edit SQL inline[​](#generate-and-edit-sql-inline "Direct link to Generate and edit SQL inline")

Copilot also allows you to generate SQL code directly within the SQL file in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio), using natural language prompts. This means you can rewrite or add specific portions of the SQL file without needing to edit the entire file.

This intelligent AI tool streamlines SQL development by reducing errors, scaling effortlessly with complexity, and saving valuable time. Copilot's [prompt window](#use-the-prompt-window), accessible by keyboard shortcut, handles repetitive or complex SQL generation effortlessly so you can focus on high-level tasks.

Use Copilot's prompt window for use cases like:

* Writing advanced transformations
* Performing bulk edits efficiently
* Crafting complex patterns like regex

### Use the prompt window[​](#use-the-prompt-window "Direct link to Use the prompt window")

Access Copilot's AI prompt window using the keyboard shortcut Cmd+B (Mac) or Ctrl+B (Windows) to:

#### 1. Generate SQL from scratch[​](#1-generate-sql-from-scratch "Direct link to 1. Generate SQL from scratch")

* Use the keyboard shortcuts Cmd+B (Mac) or Ctrl+B (Windows) to generate SQL from scratch.
* Enter your instructions to generate SQL code tailored to your needs using natural language.
* Ask Copilot to fix the code or add a specific portion of the SQL file.

[![dbt Copilot's prompt window accessible by keyboard shortcut Cmd+B (Mac) or Ctrl+B (Windows)](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/copilot-sql-generation-prompt.png?v=2 "dbt Copilot's prompt window accessible by keyboard shortcut Cmd+B (Mac) or Ctrl+B (Windows)")](#)dbt Copilot's prompt window accessible by keyboard shortcut Cmd+B (Mac) or Ctrl+B (Windows)

#### 2. Edit existing SQL code[​](#2-edit-existing-sql-code "Direct link to 2. Edit existing SQL code")

* Highlight a section of SQL code and press Cmd+B (Mac) or Ctrl+B (Windows) to open the prompt window for editing.
* Use this to refine or modify specific code snippets based on your needs.
* Ask Copilot to fix the code or add a specific portion of the SQL file.

#### 3. Review changes with the diff view to quickly assess the impact of the changes before making changes[​](#3-review-changes-with-the-diff-view-to-quickly-assess-the-impact-of-the-changes-before-making-changes "Direct link to 3. Review changes with the diff view to quickly assess the impact of the changes before making changes")

* When a suggestion is generated, Copilot displays a visual "diff" view to help you compare the proposed changes with your existing code:
  + **Green**: Means new code that will be added if you accept the suggestion.
  + **Red**: Highlights existing code that will be removed or replaced by the suggested changes.

#### 4. Accept or reject suggestions[​](#4-accept-or-reject-suggestions "Direct link to 4. Accept or reject suggestions")

* **Accept**: If the generated SQL meets your requirements, click the **Accept** button to apply the changes directly to your `.sql` file directly in the IDE.
* **Reject**: If the suggestion don’t align with your request/prompt, click **Reject** to discard the generated SQL without making changes and start again.

#### 5. Regenerate code[​](#5-regenerate-code "Direct link to 5. Regenerate code")

* To regenerate, press the **Escape** button on your keyboard (or click the Reject button in the popup). This will remove the generated code and puts your cursor back into the prompt text area.
* Update your prompt and press **Enter** to try another generation. Press **Escape** again to close the popover entirely.

Once you've accepted a suggestion, you can continue to use the prompt window to generate additional SQL code and commit your changes to the branch.

[![Edit existing SQL code using dbt Copilot's prompt window accessible by keyboard shortcut Cmd+B (Mac) or Ctrl+B (Windows)](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/copilot-sql-generation.gif?v=2 "Edit existing SQL code using dbt Copilot's prompt window accessible by keyboard shortcut Cmd+B (Mac) or Ctrl+B (Windows)")](#)Edit existing SQL code using dbt Copilot's prompt window accessible by keyboard shortcut Cmd+B (Mac) or Ctrl+B (Windows)

## Build visual models[​](#build-visual-models "Direct link to Build visual models")

Copilot seamlessly integrates with the [Canvas](https://docs.getdbt.com/docs/cloud/canvas), a drag-and-drop experience that helps you build your visual models using natural language prompts. Before you begin, make sure you can [access the Canvas](https://docs.getdbt.com/docs/cloud/use-canvas#access-canvas).

To begin building models with natural language prompts in the Canvas:

1. Click on the **dbt Copilot** icon in Canvas menu.
2. In the dbt Copilot prompt box, enter your prompt in natural language for Copilot to build the model(s) you want. You can also reference existing models using the `@` symbol. For example, to build a model that calculates the total price of orders, you can enter `@orders` in the prompt and it'll pull in and reference the `orders` model.
3. Click **Generate** and dbt Copilot generates a summary of the model(s) you want to build.
   * To start over, click on the **+** icon. To close the prompt box, click **X**.

   [![Enter a prompt in the dbt Copilot prompt box to build models using natural language](https://docs.getdbt.com/img/docs/dbt-cloud/copilot-generate.jpg?v=2 "Enter a prompt in the dbt Copilot prompt box to build models using natural language")](#)Enter a prompt in the dbt Copilot prompt box to build models using natural language
4. Click **Apply** to generate the model(s) in the Canvas.
5. dbt Copilot displays a visual "diff" view to help you compare the proposed changes with your existing code. Review the diff view in the canvas to see the generated operators built byCopilot:
   * White: Located in the top of the canvas and means existing set up or blank canvas that will be removed or replaced by the suggested changes.
   * Green: Located in the bottom of the canvas and means new code that will be added if you accept the suggestion.

   [![Visual diff view of proposed changes](https://docs.getdbt.com/img/docs/dbt-cloud/copilot-diff.jpg?v=2 "Visual diff view of proposed changes")](#)Visual diff view of proposed changes
6. Reject or accept the suggestions
7. In the **generated** operator box, click the play icon to preview the data
8. Confirm the results or continue building your model.

   [![Use the generated operator with play icon to preview the data](https://docs.getdbt.com/img/docs/dbt-cloud/copilot-output.jpg?v=2 "Use the generated operator with play icon to preview the data")](#)Use the generated operator with play icon to preview the data
9. To edit the generated model, open **Copilot** prompt box and type your edits.
10. Click **Submit** and Copilot will generate the revised model. Repeat steps 5-8 until you're happy with the model.

## Build queries[​](#build-queries "Direct link to Build queries")

Use Copilot to build queries in [Insights](https://docs.getdbt.com/docs/explore/dbt-insights) with natural language prompts to seamlessly explore and query data with an intuitive, context-rich interface. Before you begin, make sure you can [access Insights](https://docs.getdbt.com/docs/explore/access-dbt-insights).

To begin building SQL queries with natural language prompts in Insights:

1. Click the **Copilot** icon in the Query console sidebar menu.
2. Click **Generate SQL**.
3. In the dbt Copilot prompt box, enter your prompt in natural language for dbt Copilot to build the SQL query you want.
4. Click **↑** to submit your prompt. Copilot generates a summary of the SQL query you want to build. To clear the prompt, click on the **Clear** button. To close the prompt box, click the Copilot icon again.
5. Copilot will automatically generate the SQL with an explanation of the query.
   * Click **Add** to add the generated SQL to the existing query.
   * Click **Replace** to replace the existing query with the generated SQL.
6. In the **Query console menu**, click the **Run** button to preview the data.
7. Confirm the results or continue building your model.

[![dbt Copilot in dbt Insights](https://docs.getdbt.com/img/docs/dbt-insights/insights-copilot.gif?v=2 "dbt Copilot in dbt Insights")](#)dbt Copilot in dbt Insights

## Analyze data with the Analyst agent [Private beta](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[​](#analyze-data-with-the-analyst-agent- "Direct link to analyze-data-with-the-analyst-agent-")

Use dbt Copilot to analyze your data and get contextualized results in real time by asking natural language questions to the [Insights](https://docs.getdbt.com/docs/explore/dbt-insights) Analyst agent. To request access to the Analyst agent, [join the waitlist](https://www.getdbt.com/product/dbt-agents#dbt-Agents-signup).

Before you begin, make sure you can [access Insights](https://docs.getdbt.com/docs/explore/access-dbt-insights).

1. Click the **Copilot** icon in the Query console sidebar menu.
2. Click **Agent**.
3. In the dbt Copilot prompt box, enter your question.
4. Click **↑** to submit your question.

   The agent then translates natural language questions into structured queries, executes queries against governed dbt models and metrics, and returns results with references, assumptions, and possible next steps.

   The agent can loop through these steps multiple times if it hasn't reached a complete answer, allowing for complex, multi-step analysis.⁠
5. Confirm the results or continue asking the agent for more insights about your data.

Your conversation with the agent remains even if you switch tabs within dbt Insights. However, they disappear when you navigate out of Insights or when you close your browser.

[![Using the Analyst agent in Insights](https://docs.getdbt.com/img/docs/dbt-insights/insights-copilot-agent.png?v=2 "Using the Analyst agent in Insights")](#)Using the Analyst agent in Insights

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Enable dbt Copilot](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot)[Next

Copilot style guide](https://docs.getdbt.com/docs/cloud/copilot-styleguide)

* [Generate resources](#generate-resources)* [Generate and edit SQL inline](#generate-and-edit-sql-inline)
    + [Use the prompt window](#use-the-prompt-window)* [Build visual models](#build-visual-models)* [Build queries](#build-queries)* [Analyze data with the Analyst agent](#analyze-data-with-the-analyst-agent-)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/use-dbt-copilot.md)
