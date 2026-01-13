---
title: "One post tagged with \"dbt product updates\" | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/tags/dbt-product-updates"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



note

This blog post was updated on December 18, 2023 to cover the support of MVs on dbt-bigquery
and updates on how to test MVs.

## Introduction[​](#introduction "Direct link to Introduction")

The year was 2020. I was a kitten-only household, and dbt Labs was still Fishtown Analytics. A enterprise customer I was working with, Jetblue, asked me for help running their dbt models every 2 minutes to meet a 5 minute SLA.

After getting over the initial terror, we talked through the use case and soon realized there was a better option. Together with my team, I created [lambda views](https://discourse.getdbt.com/t/how-to-create-near-real-time-models-with-just-dbt-sql/1457) to meet the need.

Flash forward to 2023. I’m writing this as my giant dog snores next to me (don’t worry the cats have multiplied as well). Jetblue has outgrown lambda views due to performance constraints (a view can only be so performant) and we are at another milestone in dbt’s journey to support streaming. What. a. time.

Today we are announcing that we now support Materialized Views in dbt. So, what does that mean?
