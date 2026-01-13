---
title: "About properties.yml context | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/dbt-properties-yml-context"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* properties.yml context

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt-properties-yml-context+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt-properties-yml-context+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt-properties-yml-context+so+I+can+ask+questions+about+it.)

On this page

The following context methods and variables are available when configuring
resources in a `properties.yml` file.

**Available context methods:**

* [env\_var](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var)
* [var](https://docs.getdbt.com/reference/dbt-jinja-functions/var)

**Available context variables:**

* [target](https://docs.getdbt.com/reference/dbt-jinja-functions/target)
* [builtins](https://docs.getdbt.com/reference/dbt-jinja-functions/builtins)
* [dbt\_version](https://docs.getdbt.com/reference/dbt-jinja-functions/dbt_version)

### Example configuration[​](#example-configuration "Direct link to Example configuration")

properties.yml

```
# Configure this model to be materialized as a view
# in development and a table in production/CI contexts

models:
  - name: dim_customers
    config:
      materialized: "{{ 'view' if target.name == 'dev' else 'table' }}"
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

project\_name](https://docs.getdbt.com/reference/dbt-jinja-functions/project_name)[Next

ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref)

* [Example configuration](#example-configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/properties-yml-context.md)
