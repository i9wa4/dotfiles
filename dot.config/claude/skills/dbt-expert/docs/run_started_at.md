---
title: "About run_started_at variable | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/run_started_at"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* run\_started\_at

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Frun_started_at+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Frun_started_at+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Frun_started_at+so+I+can+ask+questions+about+it.)

`run_started_at` outputs the timestamp that this run started, e.g. `2017-04-21 01:23:45.678`.

The `run_started_at` variable is a Python `datetime` object. As of 0.9.1, the timezone of this variable
defaults to UTC.

run\_started\_at\_example.sql

```
select
	'{{ run_started_at.strftime("%Y-%m-%d") }}' as date_day

from ...
```

To modify the timezone of this variable, use the `pytz` module:

run\_started\_at\_utc.sql

```
select
	'{{ run_started_at.astimezone(modules.pytz.timezone("America/New_York")) }}' as run_started_est

from ...
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

run\_query](https://docs.getdbt.com/reference/dbt-jinja-functions/run_query)[Next

schema](https://docs.getdbt.com/reference/dbt-jinja-functions/schema)
