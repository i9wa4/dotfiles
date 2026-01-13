---
title: "About as_number filter | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/as_number"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* as\_number

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_number+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_number+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_number+so+I+can+ask+questions+about+it.)

On this page

The `as_number` Jinja filter will coerce Jinja-compiled output into a numeric
value (integer or float), or return an error if it cannot be represented as
a number.

### Usage[​](#usage "Direct link to Usage")

In the example below, the `as_number` filter is used to coerce an environment
variables into a numeric value to dynamically control the connection port.

profiles.yml

```
my_profile:
  outputs:
    dev:
      type: postgres
      port: "{{ env_var('PGPORT') | as_number }}"
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

as\_native](https://docs.getdbt.com/reference/dbt-jinja-functions/as_native)[Next

builtins](https://docs.getdbt.com/reference/dbt-jinja-functions/builtins)

* [Usage](#usage)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/as_number.md)
