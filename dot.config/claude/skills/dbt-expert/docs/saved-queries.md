---
title: "Saved queries | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/saved-queries"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* Saved queries

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsaved-queries+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsaved-queries+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsaved-queries+so+I+can+ask+questions+about+it.)

On this page

Saved queries are a way to save commonly used queries in MetricFlow. You can group metrics, dimensions, and filters that are logically related into a saved query. Saved queries are nodes and visible in the dbt DAG.

Saved queries serve as the foundational building block, allowing you to [configure exports](#configure-exports) in your saved query configuration. Exports takes this functionality a step further by enabling you to [schedule and write saved queries](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) directly within your data platform using [dbt's job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler).

## Parameters[​](#parameters "Direct link to Parameters")

To create a saved query, refer to the following table parameters.

tip

Note that we use the double colon (::) to indicate whether a parameter is nested within another parameter. So for example, `query_params::metrics` means the `metrics` parameter is nested under `query_params`.

If you use multiple metrics in a saved query, then you will only be able to reference the common dimensions these metrics share in the `group_by` or `where` clauses. Use the entity name prefix with the Dimension object, like `Dimension('user__ds')`.

## Configure saved query[​](#configure-saved-query "Direct link to Configure saved query")

Use saved queries to define and manage common Semantic Layer queries in YAML, including metrics and dimensions. Saved queries enable you to organize and reuse common MetricFlow queries within dbt projects. For example, you can group related metrics together for better organization, and include commonly used dimensions and filters.

In your saved query config, you can also leverage [caching](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache) with the dbt job scheduler to cache common queries, speed up performance, and reduce compute costs.

In the following example, you can set the saved query in the `semantic_model.yml` file:

semantic\_model.yml

Note that you can set `export_as` to both the saved query and the exports [config](https://docs.getdbt.com/reference/resource-properties/config), with the exports config value taking precedence. If a key isn't set in the exports config, it will inherit the saved query config value.

#### Where clause[​](#where-clause "Direct link to Where clause")

Use the following syntax to reference entities, dimensions, time dimensions, or metrics in filters and refer to [Metrics as dimensions](https://docs.getdbt.com/docs/build/ref-metrics-in-filters) for details on how to use metrics as dimensions with metric filters:

```
filter: |
  {{ Entity('entity_name') }}

filter: |
  {{ Dimension('primary_entity__dimension_name') }}

filter: |
  {{ TimeDimension('time_dimension', 'granularity') }}

filter: |
  {{ Metric('metric_name', group_by=['entity_name']) }}
```

#### Project-level saved queries[​](#project-level-saved-queries "Direct link to Project-level saved queries")

To enable saved queries at the project level, you can set the `saved-queries` configuration in the [`dbt_project.yml` file](https://docs.getdbt.com/reference/dbt_project.yml). This saves you time in configuring saved queries in each file:

dbt\_project.yml

```
saved-queries:
  my_saved_query:
    +cache:
      enabled: true
```

For more information on `dbt_project.yml` and config naming conventions, see the [dbt\_project.yml reference page](https://docs.getdbt.com/reference/dbt_project.yml#naming-convention).

To build `saved_queries`:

* Make sure you set the right [environment variable](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports#set-environment-variable) in your environment.
* Run the command `dbt build --resource-type saved_query` using the [`--resource-type` flag](https://docs.getdbt.com/reference/global-configs/resource-type).

## Configure exports[​](#configure-exports "Direct link to Configure exports")

Exports are an additional configuration added to a saved query. They define *how* to write a saved query, along with the schema and table name.

Once you've configured your saved query and set the foundation block, you can now configure exports in the `saved_queries` YAML configuration file (the same file as your metric definitions). This will also allow you to [run exports](#run-exports) automatically within your data platform using [dbt's job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler).

The following is an example of a saved query with an export:

semantic\_model.yml

## Run exports[​](#run-exports "Direct link to Run exports")

Once you've configured exports, you can now take things a step further by running exports to automatically write saved queries within your data platform using [dbt's job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler). This feature is only available with the [dbt's Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl).

For more information on how to run exports, refer to the [Exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) documentation.

## FAQs[​](#faqs "Direct link to FAQs")

Can I have multiple exports in a single saved query?

Yes, this is possible. However, the difference would be the name, schema, and materialization strategy of the export.

How can I select saved\_queries by their resource type?

To include all saved queries in the dbt build run, use the [`--resource-type` flag](https://docs.getdbt.com/reference/global-configs/resource-type) and run the command `dbt build --resource-type saved_query`.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Validate semantic nodes in a CI job](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci)
* Configure [caching](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Simple](https://docs.getdbt.com/docs/build/simple)[Next

Advanced data modeling](https://docs.getdbt.com/docs/build/advanced-topics)

* [Parameters](#parameters)* [Configure saved query](#configure-saved-query)* [Configure exports](#configure-exports)* [Run exports](#run-exports)* [FAQs](#faqs)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/saved-queries.md)
