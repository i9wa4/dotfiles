---
title: "About dbt_version variable | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/dbt_version"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* dbt\_version

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt_version+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt_version+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdbt_version+so+I+can+ask+questions+about+it.)

On this page

The `dbt_version` variable returns the installed version of dbt that is
currently running. It can be used for debugging or auditing purposes. For details about release versioning, refer to [Versioning](https://docs.getdbt.com/reference/commands/version#versioning).

## Example usages[​](#example-usages "Direct link to Example usages")

macros/get\_version.sql

```
{% macro get_version() %}

  {% do log("The installed version of dbt is: " ~ dbt_version, info=true) %}

{% endmacro %}
```

```
$ dbt run-operation get_version
The installed version of dbt is 1.6.0
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt\_project.yml context](https://docs.getdbt.com/reference/dbt-jinja-functions/dbt-project-yml-context)[Next

debug](https://docs.getdbt.com/reference/dbt-jinja-functions/debug-method)

* [Example usages](#example-usages)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/dbt_version.md)
