---
title: "Copilot style guide | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/copilot-styleguide"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot)* Copilot style guide

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcopilot-styleguide+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcopilot-styleguide+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fcopilot-styleguide+so+I+can+ask+questions+about+it.)

On this page

This guide provides an overview of the Copilot `dbt-styleguide.md` file, outlining its structure, recommended usage, and best practices for effective implementation in your dbt projects.

The `dbt-styleguide.md` is a template for creating a style guide for dbt projects. It includes:

* SQL style guidelines (for example, using lowercase keywords and trailing commas)
* Model organization and naming conventions
* Model configurations and testing practices
* Recommendations for using pre-commit hooks to enforce style rules

This guide helps ensure consistency and clarity in dbt projects.

## `dbt-styleguide.md` for Copilot[​](#dbt-styleguidemd-for-copilot "Direct link to dbt-styleguidemd-for-copilot")

Using Copilot in the Studio IDE, you can automatically generate a style guide template called `dbt-styleguide.md`. If the style guide is manually added or edited, it must also follow this naming convention. Any other file name cannot be used with Copilot.

Add the `dbt-styleguide.md` file to the root of your project. Copilot will use it as context for the large language model (LLM) when generating [data tests](https://docs.getdbt.com/docs/build/data-tests), [metrics](https://docs.getdbt.com/docs/build/metrics-overview), [semantic models](https://docs.getdbt.com/docs/build/semantic-models), and [documentation](https://docs.getdbt.com/docs/build/documentation).

Note, by creating a `dbt-styleguide.md` for Copilot, you are overriding dbt's default style guide.

## Creating `dbt-styleguide.md` in the Studio IDE[​](#creating-dbt-styleguidemd-in-the-studio-ide "Direct link to creating-dbt-styleguidemd-in-the-studio-ide")

1. Open a file in the Studio IDE.
2. Click **Copilot** in the toolbar.
3. Select **Generate ... Style guide** from the menu.

[![Generate styleguide in Copilot](https://docs.getdbt.com/img/docs/dbt-cloud/generate-styleguide.png?v=2 "Generate styleguide in Copilot")](#)Generate styleguide in Copilot

4. The style guide template appears in the Studio IDE. Click **Save**.
   `dbt-styleguide.md` is added at the root level of your project.

If you haven't previously generated a style guide file, the latest version will be automatically sourced from dbt platform.

## If `dbt-styleguide.md` already exists[​](#if-dbt-styleguidemd-already-exists "Direct link to if-dbt-styleguidemd-already-exists")

If there is an existing `dbt-styleguide.md` file and you attempt to generate a new style guide, a modal appears with the following options:

* **Cancel** — Exit without making changes.
* **Restore** — Revert to the latest version from dbt platform.
* **Edit** — Modify the existing style guide manually.

[![Styleguide exists](https://docs.getdbt.com/img/docs/dbt-cloud/styleguide-exists.png?v=2 "Styleguide exists")](#)Styleguide exists

## Further reading[​](#further-reading "Direct link to Further reading")

* [About dbt Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot)
* [How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Use dbt Copilot](https://docs.getdbt.com/docs/cloud/use-dbt-copilot)[Next

Copilot chat in studio](https://docs.getdbt.com/docs/cloud/copilot-chat-in-studio)

* [`dbt-styleguide.md` for Copilot](#dbt-styleguidemd-for-copilot)* [Creating `dbt-styleguide.md` in the Studio IDE](#creating-dbt-styleguidemd-in-the-studio-ide)* [If `dbt-styleguide.md` already exists](#if-dbt-styleguidemd-already-exists)* [Further reading](#further-reading)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/copilot-styleguide.md)
