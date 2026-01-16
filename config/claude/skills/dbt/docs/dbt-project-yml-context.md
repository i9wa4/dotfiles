---
title: "About dbt_project.yml context | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/dbt-project-yml-context"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* dbt\_project.yml context

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt-project-yml-context+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt-project-yml-context+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt-project-yml-context+so+I+can+ask+questions+about+it.)

On this page

The following context methods and variables are available when configuring
resources in the `dbt_project.yml` file. This applies to the `models:`, `seeds:`,
and `snapshots:` keys in the `dbt_project.yml` file.

**Available context methods:**

* [env\_var](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var)
* [var](https://docs.getdbt.com/reference/dbt-jinja-functions/var) (*Note: only variables defined with `--vars` are available*)

**Available context variables:**

* [target](https://docs.getdbt.com/reference/dbt-jinja-functions/target)
* [builtins](https://docs.getdbt.com/reference/dbt-jinja-functions/builtins)
* [dbt\_version](https://docs.getdbt.com/reference/dbt-jinja-functions/dbt_version)

### Example configuration[​](#example-configuration "Direct link to Example configuration")

dbt\_project.yml

```
name: my_project
version: 1.0.0

# Configure the models in models/facts/ to be materialized as views
# in development and tables in production/CI contexts

models:
  my_project:
    facts:
      +materialized: "{{ 'view' if target.name == 'dev' else 'table' }}"
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

cross-database macros](https://docs.getdbt.com/reference/dbt-jinja-functions/cross-database-macros)[Next

dbt\_version](https://docs.getdbt.com/reference/dbt-jinja-functions/dbt_version)

* [Example configuration](#example-configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/dbt-project-yml-context.md)
