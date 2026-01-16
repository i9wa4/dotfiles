---
title: "About profiles.yml context | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/profiles-yml-context"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* profiles.yml context

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fprofiles-yml-context+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fprofiles-yml-context+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fprofiles-yml-context+so+I+can+ask+questions+about+it.)

On this page

The following context methods are available when configuring
resources in the `profiles.yml` file.

**Available context methods:**

* [env\_var](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var)
* [var](https://docs.getdbt.com/reference/dbt-jinja-functions/var) (*Note: only variables defined with `--vars` are available*)

### Example usage[​](#example-usage "Direct link to Example usage")

~/.dbt/profiles.yml

```
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: redshift
      host: "{{ env_var('DBT_HOST') }}"
      user: "{{ env_var('DBT_USER') }}"
      password: "{{ env_var('DBT_PASS') }}"
      port: 5439
      dbname: analytics
      schema: dbt_dbanin
      threads: 4
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

print](https://docs.getdbt.com/reference/dbt-jinja-functions/print)[Next

project\_name](https://docs.getdbt.com/reference/dbt-jinja-functions/project_name)

* [Example usage](#example-usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/profiles-yml-context.md)
