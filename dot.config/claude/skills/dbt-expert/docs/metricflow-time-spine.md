---
title: "MetricFlow time spine | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/metricflow-time-spine"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* [About MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow)* MetricFlow time spine

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmetricflow-time-spine+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmetricflow-time-spine+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmetricflow-time-spine+so+I+can+ask+questions+about+it.)

On this page

## Custom calendar Preview[​](#custom-calendar- "Direct link to custom-calendar-")

tip

Check out our mini guide on [how to create a time spine table](https://docs.getdbt.com/guides/mf-time-spine) to get started!

## Related docs[​](#related-docs "Direct link to Related docs")

* [MetricFlow time granularity](https://docs.getdbt.com/docs/build/dimensions?dimension=time_gran#time)
* [MetricFlow time spine mini guide](https://docs.getdbt.com/guides/mf-time-spine)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Joins](https://docs.getdbt.com/docs/build/join-logic)[Next

MetricFlow commands](https://docs.getdbt.com/docs/build/metricflow-commands)

* [Prerequisites](#prerequisites)* [Configuring time spine in YAML](#configuring-time-spine-in-yaml)
    + [Creating a time spine table](#creating-a-time-spine-table)+ [Migrating from SQL to YAML](#migrating-from-sql-to-yaml)+ [Considerations when choosing which granularities to create](#granularity-considerations)* [Example time spine tables](#example-time-spine-tables)
      + [Seconds](#seconds)+ [Minutes](#minutes)+ [Daily](#daily)+ [Daily (BigQuery)](#daily-bigquery)+ [Hourly](#hourly)* [Custom calendar](#custom-calendar-)
        + [Add custom granularities](#add-custom-granularities)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/metricflow-time-spine.md)
