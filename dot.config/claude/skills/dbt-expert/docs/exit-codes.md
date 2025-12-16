---
title: "Exit codes | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/exit-codes"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* Exit codes

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fexit-codes+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fexit-codes+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fexit-codes+so+I+can+ask+questions+about+it.)

When dbt exits, it will return an exit code of either 0, 1, or 2.

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Exit Code Condition|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | 0 The dbt invocation completed without error.|  |  |  |  | | --- | --- | --- | --- | | 1 The dbt invocation completed with at least one handled error (eg. model syntax error, bad permissions, etc). The run was completed, but some models may have been skipped.|  |  | | --- | --- | | 2 The dbt invocation completed with an unhandled error (eg. ctrl-c, network interruption, etc). | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

While these exit codes may change in the future, a zero exit code will always imply success whereas a nonzero exit code will always imply failure.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Events and logs](https://docs.getdbt.com/reference/events-logging)[Next

Deprecations](https://docs.getdbt.com/reference/deprecations)
