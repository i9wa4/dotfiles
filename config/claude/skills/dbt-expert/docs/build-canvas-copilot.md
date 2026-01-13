---
title: "Build with dbt Copilot | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/build-canvas-copilot"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* [dbt Canvas](https://docs.getdbt.com/docs/cloud/canvas)* Build with dbt Copilot

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fbuild-canvas-copilot+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fbuild-canvas-copilot+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fbuild-canvas-copilot+so+I+can+ask+questions+about+it.)

Use Copilot to build visual models in the Canvas with natural language prompts.

[Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) seamlessly integrates with [Canvas](https://docs.getdbt.com/docs/cloud/canvas), a drag-and-drop experience that helps you with build your visual models using natural language prompts. Before you begin, make sure you can access [Canvas](https://docs.getdbt.com/docs/cloud/use-canvas#access-canvas).

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

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Edit and create dbt models](https://docs.getdbt.com/docs/cloud/use-canvas)[Next

About dbt projects](https://docs.getdbt.com/docs/build/projects)
