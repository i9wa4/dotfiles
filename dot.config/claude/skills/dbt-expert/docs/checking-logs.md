---
title: "How can I see the SQL that dbt is running? | dbt Developer Hub"
source_url: "https://docs.getdbt.com/faqs/Runs/checking-logs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Frequently asked questions](https://docs.getdbt.com/docs/faqs)* [Runs](https://docs.getdbt.com/category/runs)* Reviewing SQL that dbt runs

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FRuns%2Fchecking-logs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FRuns%2Fchecking-logs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FRuns%2Fchecking-logs+so+I+can+ask+questions+about+it.)

To check out the SQL that dbt is running, you can look in:

* dbt:
  + Within the run output, click on a model name, and then select "Details"
* dbt Core:
  + The `target/compiled/` directory for compiled `select` statements
  + The `target/run/` directory for compiled `create` statements
  + The `logs/dbt.log` file for verbose logging.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Runs](https://docs.getdbt.com/category/runs)[Next

Notifications to debug failed runs](https://docs.getdbt.com/faqs/Runs/failed-prod-run)
