---
title: "About thread_id | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/thread_id"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* thread\_id

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fthread_id+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fthread_id+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fthread_id+so+I+can+ask+questions+about+it.)

The `thread_id` outputs an identifier for the current Python thread that is executing a node, like `Thread-1`.

This value is useful when auditing or analyzing dbt invocation metadata. It corresponds to the `thread_id` within the [`Result` object](https://docs.getdbt.com/reference/dbt-classes#result-objects) and [`run_results.json`](https://docs.getdbt.com/reference/artifacts/run-results-json).

If available, the `thread_id` is:

* available in the compilation context of [`query-comment`](https://docs.getdbt.com/reference/project-configs/query-comment)
* included in the `info` dictionary in dbt [events and logs](https://docs.getdbt.com/reference/events-logging#info)
* included in the `metadata` dictionary in [dbt artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts#common-metadata)
* included as a label in all BigQuery jobs that dbt originates

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

this](https://docs.getdbt.com/reference/dbt-jinja-functions/this)[Next

tojson](https://docs.getdbt.com/reference/dbt-jinja-functions/tojson)
