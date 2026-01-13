---
title: "Copilot chat in Studio | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/copilot-chat-in-studio"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot)* Copilot chat in studio

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcopilot-chat-in-studio+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcopilot-chat-in-studio+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcopilot-chat-in-studio+so+I+can+ask+questions+about+it.)

On this page

Use the Copilot chat feature in Studio IDE to generate SQL using your input and the context of the active project.

Copilot chat is an interactive interface within Studio IDE that allows users to generate SQL from natural language prompts and ask analytics-related questions. By integrating contextual understanding of your dbt project, Copilot assists in streamlining SQL development while ensuring users remain actively involved in the process. This collaborative approach helps maintain accuracy, relevance, and adherence to best practices in your organization’s analytics workflows.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* Must have a [dbt Starter, Enterprise or Enterprise+ account](https://www.getdbt.com/pricing).
* Development environment is on a supported [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) to receive ongoing updates.
* Copilot enabled for your account.
  + Admins must [enable Copilot](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot#enable-dbt-copilot) (and opt-in to AI features, if required) in your dbt Cloud project settings.

## Copilot chat overview[​](#copilot-chat-overview "Direct link to Copilot chat overview")

 Generate SQL

Ask Copilot to generate SQL queries using natural language, making it faster to build or modify dbt models without manual SQL coding.

You can describe the query or data transformation you want, and Copilot will produce the corresponding SQL code for you within the Studio IDE environment.⁠

This includes the ability to:

* Scaffold new SQL models from scratch by describing your needs in plain English.
* Refactor or optimize existing SQL in your models.
* Generate complex queries, CTEs, and even automate best-practice SQL formatting, all directly in the chat or command palette UI.

To generate SQL queries:

1. Navigate to the **Copilot** button in the Studio IDE
2. Select **[\*] SQL** from the menu

[![SQL option.](https://docs.getdbt.com/img/docs/dbt-cloud/copilot-chat-generate-sql.png?v=2 "SQL option.")](#)SQL option.

 Mention a model in the project

⁠​
This model mention capability is designed to provide a much more project-aware experience than generic code assistants, enabling you to:

* Pose questions about specific models (For example, "Add a test for the model `stg_orders`")

[![Mention model with menu open.](https://docs.getdbt.com/img/docs/dbt-cloud/copilot-chat-mention-model-menu-open.png?v=2 "Mention model with menu open.")](#)Mention model with menu open.

[![Mention model after selecting from menu.](https://docs.getdbt.com/img/docs/dbt-cloud/copilot-chat-mention-model-menu-select.png?v=2 "Mention model after selecting from menu.")](#)Mention model after selecting from menu.

 Add and replace buttons

Add generated code or content into your project, or replace the selected section with the Copilot suggestion, all directly from the chat interface. This lets you review and apply changes with a single click for an efficient workflow.⁠
⁠​

These buttons are often tracked as specific user actions in the underlying event/telemetry data, confirming they are core to the expected interaction with Copilot in Studio IDE and related surfaces.⁠
⁠​

The **Add** button lets you append Copilot's output, while **Replace** swaps your current code or selection with the generated suggestion, giving you precise, in-context editing control.

Note, if the file is empty, you'll only see **Add** as an option, since there's nothing to replace.

[![Add and replace buttons.](https://docs.getdbt.com/img/docs/dbt-cloud/copilot-chat-add-replace.png?v=2 "Add and replace buttons.")](#)Add and replace buttons.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [Prerequisites](#prerequisites)* [Copilot chat overview](#copilot-chat-overview)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/copilot-chat-in-studio.md)
