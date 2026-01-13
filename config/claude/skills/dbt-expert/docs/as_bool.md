---
title: "About as_bool filter | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/as_bool"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* as\_bool

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_bool+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_bool+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_bool+so+I+can+ask+questions+about+it.)

On this page

The `as_bool` Jinja filter will coerce Jinja-compiled output into a boolean
value (`True` or `False`), or return an error if it cannot be represented
as a bool.

### Usage:[​](#usage "Direct link to Usage:")

In the example below, the `as_bool` filter is used to coerce a Jinja
expression to enable or disable a set of models based on the `target`.

dbt\_project.yml

```
models:
  my_project:
    for_export:
      enabled: "{{ (target.name == 'prod') | as_bool }}"
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

adapter](https://docs.getdbt.com/reference/dbt-jinja-functions/adapter)[Next

as\_native](https://docs.getdbt.com/reference/dbt-jinja-functions/as_native)

* [Usage:](#usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/as_bool.md)
