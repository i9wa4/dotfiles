---
title: "About doc function | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/doc"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* doc

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdoc+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdoc+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fdoc+so+I+can+ask+questions+about+it.)

The `doc` function is used to reference docs blocks in the description field of schema.yml files. It is analogous to the `ref` function. For more information, consult the [Documentation guide](https://docs.getdbt.com/docs/explore/build-and-view-your-docs).

Usage:

orders.md

```
{% docs orders %}

# docs
- go
- here

{% enddocs %}
```

schema.yml

```
models:
  - name: orders
    description: "{{ doc('orders') }}"
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch)[Next

env\_var](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var)
