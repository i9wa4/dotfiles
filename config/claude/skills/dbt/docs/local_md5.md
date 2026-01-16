---
title: "About local_md5 context variable | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/local_md5"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* local\_md5

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Flocal_md5+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Flocal_md5+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Flocal_md5+so+I+can+ask+questions+about+it.)

The `local_md5` context variable calculates an [MD5 hash](https://en.wikipedia.org/wiki/MD5) of the given string. The string `local_md5` emphasizes that the hash is calculated *locally*, in the dbt-Jinja context. This variable is typically useful for advanced use cases. For example, when you generate unique identifiers within custom materialization or operational logic, you can either avoid collisions between temporary relations or identify changes by comparing checksums.

It is different than the `md5` SQL function, supported by many SQL dialects, which runs remotely in the data platform. You want to always use SQL hashing functions when generating surrogate keys.

Usage:

```
-- source
{%- set value_hash = local_md5("hello world") -%}
'{{ value_hash }}'

-- compiled
'5eb63bbbe01eeed093cb22bb8f5acdc3'
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

invocation\_id](https://docs.getdbt.com/reference/dbt-jinja-functions/invocation_id)[Next

log](https://docs.getdbt.com/reference/dbt-jinja-functions/log)
