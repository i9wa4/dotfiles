---
title: "Cache common queries | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Use the dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl)* [Deploy metrics](https://docs.getdbt.com/docs/use-dbt-semantic-layer/deploy-sl)* Cache common queries

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsl-cache+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsl-cache+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsl-cache+so+I+can+ask+questions+about+it.)

On this page

The Semantic Layer allows you to cache common queries in order to speed up performance and reduce compute on expensive queries.

There are two different types of caching:

* [Result caching](#result-caching) leverages your data platform's built-in caching layer.
* [Declarative caching](#declarative-caching) allows you to pre-warm the cache using saved queries configuration.

While you can use caching to speed up your queries and reduce compute time, knowing the difference between the two depends on your use case:

* Result caching happens automatically by leveraging your data platform's cache.
* Declarative caching allows you to 'declare' the queries you specifically want to cache. With declarative caching, you need to anticipate which queries you want to cache.
* Declarative caching also allows you to dynamically filter your dashboards without losing the performance benefits of caching. This works because filters on dimensions (that are already in a saved query config) will use the cache.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* dbt [Enterprise or Enterprise+](https://www.getdbt.com/) plans.
* dbt environments must be on [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) and not legacy dbt Core versions.
* A successful job run and [production environment](https://docs.getdbt.com/docs/deploy/deploy-environments#set-as-production-environment).
* For declarative caching, you need to have [exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) defined in your [saved queries](https://docs.getdbt.com/docs/build/saved-queries) YAML configuration file.

## Result caching[​](#result-caching "Direct link to Result caching")

Result caching leverages your data platform’s built-in caching layer and features. [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow) generates the same SQL for multiple query requests, this means it can take advantage of your data platform’s cache. Double-check your data platform's specifications.

Here's how caching works, using Snowflake as an example, and should be similar across other data platforms:

1. **Run from cold cache** — When you run a semantic layer query from your BI tool that hasn't been executed in the past 24 hours, the query scans the entire dataset and doesn't use the cache.
2. **Run from warm cache** — If you rerun the same query after 1 hour, the SQL generated and executed on Snowflake remains the same. On Snowflake, the result cache is set per user for 24 hours, which allows the repeated query to use the cache and return results faster.

Different data platforms might have different caching layers and cache invalidation rules. Here's a list of resources on how caching works on some common data platforms:

* [BigQuery](https://cloud.google.com/bigquery/docs/cached-results)
* [DataBricks](https://docs.databricks.com/en/optimizations/disk-cache.html)
* [Microsoft Fabric](https://learn.microsoft.com/en-us/fabric/data-warehouse/caching)
* [Redshift](https://docs.aws.amazon.com/redshift/latest/dg/c_challenges_achieving_high_performance_queries.html#result-caching)
* [Snowflake](https://community.snowflake.com/s/article/Caching-in-the-Snowflake-Cloud-Data-Platform)
* [Starburst Galaxy](https://docs.starburst.io/starburst-galaxy/data-engineering/optimization-performance-and-quality/workload-optimization/warp-speed-enabled.html)

## Declarative caching[​](#declarative-caching "Direct link to Declarative caching")

Declarative caching enables you to pre-warm the cache using [saved queries](https://docs.getdbt.com/docs/build/saved-queries) by setting the cache config to `true` in your `saved_queries` settings. This is useful for optimizing performance for key dashboards or common ad-hoc query requests.

tip

Declarative caching also allows you to dynamically filter your dashboards without losing the performance benefits of caching. This works because filters on dimensions (that are already in a saved query config) will use the cache.

For example, if you filter a metric by geographical region on a dashboard, the query will hit the cache, ensuring faster results. This also removes the need to create separate saved queries with static filters.

For configuration details, refer to [Declarative caching setup](#declarative-caching-setup).

How declarative caching works:

* Make sure your saved queries YAML configuration file has [exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) defined.
* Running a saved query triggers the Semantic Layer to:
  + Build a cached table from a saved query, with exports defined, into your data platform.
  + Make sure any query requests that match the saved query's inputs use the cache, returning data more quickly.
  + Automatically invalidates the cache when it detects new and fresh data in any upstream models related to the metrics in your cached table.
  + Refreshes (or rebuilds) the cache the next time you run the saved query.

 📹 Check out this video demo to see how declarative caching works!

This video demonstrates the concept of declarative caching, how to run it using the dbt scheduler, and how fast your dashboards load as a result.

Refer to the following diagram, which illustrates what happens when the Semantic Layer receives a query request:

[![Overview of the declarative cache query flow](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/declarative-cache-query-flow.jpg?v=2 "Overview of the declarative cache query flow")](#)Overview of the declarative cache query flow

### Declarative caching setup[​](#declarative-caching-setup "Direct link to Declarative caching setup")

To populate the cache, you need to configure an export in your saved query YAML file configuration *and* set the `cache config` to `true`. You can't cache a saved query without an export defined.

semantic\_model.yml

```
saved_queries:
  - name: my_saved_query
    ... # Rest of the saved queries configuration.
    config:
      cache:
        enabled: true  # Set to true to enable, defaults to false.
    exports:
      - name: order_data_key_metrics
        config:
          export_as: table
```

To enable saved queries at the project level, you can set the `saved-queries` configuration in the [`dbt_project.yml` file](https://docs.getdbt.com/reference/dbt_project.yml). This saves you time in configuring saved queries in each file:

dbt\_project.yml

```
saved-queries:
  my_saved_query:
    config:
      +cache:
        enabled: true
```

### Run your declarative cache[​](#run-your-declarative-cache "Direct link to Run your declarative cache")

After setting up declarative caching in your YAML configuration, you can now run [exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) with the dbt job scheduler to build a cached table from a saved query into your data platform.

* Use [exports to set up a job](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) to run a saved query dbt.
* The dbt Semantic Layer builds a cache table in your data platform in a dedicated `dbt_sl_cache` schema.
* The cache schema and tables are created using your deployment credentials. You need to grant read access to this schema for your Semantic Layer user.
* The cache refreshes (or rebuilds) on the same schedule as the saved query job.

[![Overview of the cache creation flow.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/cache-creation-flow.jpg?v=2 "Overview of the cache creation flow.")](#)Overview of the cache creation flow.

After a successful job run, you can go back to your dashboard to experience the speed and benefits of declarative caching.

## Cache management[​](#cache-management "Direct link to Cache management")

dbt uses the metadata from your dbt model runs to intelligently manage cache invalidation. When you start a dbt job, it keeps track of the last model runtime and checks the freshness of the metrics upstream of your cache.

If an upstream model has data in it that was created after the cache was created, dbt invalidates the cache. This means queries won't use outdated cases and will instead query directly from the source data. Stale, outdated cache tables are periodically dropped and dbt will write a new cache the next time your saved query runs.

You can manually invalidate the cache through the [dbt Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview) using the `InvalidateCacheResult` field.

## FAQs[​](#faqs "Direct link to FAQs")

How does caching interact with access controls?

Cached data is stored separately from the underlying models. If metrics are pulled from the cache, we don’t have the security context applied to those tables at query time.

In the future, we plan to clone credentials, identify the minimum access level needed, and apply those permissions to cached tables.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Validate semantic nodes in CI](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci)
* [Saved queries](https://docs.getdbt.com/docs/build/saved-queries)
* [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Write queries with exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports)[Next

Consume your metrics](https://docs.getdbt.com/docs/use-dbt-semantic-layer/consume-metrics)

* [Prerequisites](#prerequisites)* [Result caching](#result-caching)* [Declarative caching](#declarative-caching)
      + [Declarative caching setup](#declarative-caching-setup)+ [Run your declarative cache](#run-your-declarative-cache)* [Cache management](#cache-management)* [FAQs](#faqs)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/use-dbt-semantic-layer/sl-cache.md)
