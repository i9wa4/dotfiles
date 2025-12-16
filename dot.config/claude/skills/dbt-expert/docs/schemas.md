---
title: "About schemas variable | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/schemas"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* schemas

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fschemas+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fschemas+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fschemas+so+I+can+ask+questions+about+it.)

`schemas` is a variable available in an `on-run-end` hook, representing a list of schemas that dbt built objects in on this run.

If you do not use [custom schemas](https://docs.getdbt.com/docs/build/custom-schemas), `schemas` will evaluate to your target schema, e.g. `['dbt_alice']`. If you use custom schemas, it will include these as well, e.g. `['dbt_alice', 'dbt_alice_marketing', 'dbt_alice_finance']`.

The `schemas` variable is useful for granting privileges to all schemas that dbt builds relations in, like so (note this is Redshift specific syntax):

dbt\_project.yml

```
...

on-run-end:
  - "{% for schema in schemas%}grant usage on schema {{ schema }} to group reporter;{% endfor%}"
  - "{% for schema in schemas %}grant select on all tables in schema {{ schema }} to group reporter;{% endfor%}"
  - "{% for schema in schemas %}alter default privileges in schema {{ schema }}  grant select on tables to group reporter;{% endfor %}"
```

Want more in-depth instructions on the recommended way to grant privileges?

We've written a full discourse article [here](https://discourse.getdbt.com/t/the-exact-grant-statements-we-use-in-a-dbt-project/430)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

schema](https://docs.getdbt.com/reference/dbt-jinja-functions/schema)[Next

selected\_resources](https://docs.getdbt.com/reference/dbt-jinja-functions/selected_resources)
