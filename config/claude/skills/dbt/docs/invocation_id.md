---
title: "About invocation_id | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/invocation_id"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* invocation\_id

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Finvocation_id+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Finvocation_id+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Finvocation_id+so+I+can+ask+questions+about+it.)

The `invocation_id` outputs a UUID generated for this dbt command. This value is useful when auditing or analyzing dbt invocation metadata.

If available, the `invocation_id` is:

* available in the compilation context of [`query-comment`](https://docs.getdbt.com/reference/project-configs/query-comment)
* included in the `info` dictionary in dbt [events and logs](https://docs.getdbt.com/reference/events-logging#info)
* included in the `metadata` dictionary in [dbt artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts#common-metadata)
* included as a label in all BigQuery jobs that dbt originates

**Example usage**:
You can use the following example code for all data platforms. Remember to replace `TABLE_NAME` with the actual name of your target table:

`select '{{ invocation_id }}' as test_id from TABLE_NAME`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

graph](https://docs.getdbt.com/reference/dbt-jinja-functions/graph)[Next

local\_md5](https://docs.getdbt.com/reference/dbt-jinja-functions/local_md5)
