---
title: "Materialize configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/materialize-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Materialize configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmaterialize-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmaterialize-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmaterialize-configs+so+I+can+ask+questions+about+it.)

On this page

## Performance optimizations[​](#performance-optimizations "Direct link to Performance optimizations")

### Clusters[​](#clusters "Direct link to Clusters")

Enable the configuration of [clusters](https://github.com/MaterializeInc/materialize/blob/main/misc/dbt-materialize/CHANGELOG.md#120---2022-08-31).

The default [cluster](https://materialize.com/docs/overview/key-concepts/#clusters) that is used to maintain materialized views or indexes can be configured in your [profile](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) using the `cluster` connection parameter. To override the cluster that is used for specific models (or groups of models), use the `cluster` configuration parameter.

my\_view\_cluster.sql

```
{{ config(materialized='materializedview', cluster='not_default') }}

select ...
```

dbt\_project.yml

```
models:
  project_name:
    +materialized: materializedview
    +cluster: not_default
```

### Incremental models: Materialized Views[​](#incremental-models-materialized-views "Direct link to Incremental models: Materialized Views")

Materialize, at its core, is a real-time database that delivers incremental view updates without ever compromising on latency or correctness. Use [materialized views](https://materialize.com/docs/overview/key-concepts/#materialized-views) to compute and incrementally update the results of your query.

### Indexes[​](#indexes "Direct link to Indexes")

Enable additional configuration for [indexes](https://github.com/MaterializeInc/materialize/blob/main/misc/dbt-materialize/CHANGELOG.md#120---2022-08-31).

Like in any standard relational database, you can use [indexes](https://materialize.com/docs/overview/key-concepts/#indexes) to optimize query performance in Materialize. Improvements can be significant, reducing response times down to single-digit milliseconds.

Materialized views (`materializedview`), views (`view`) and sources (`source`) may have a list of `indexes` defined. Each [Materialize index](https://materialize.com/docs/sql/create-index/) can have the following components:

* `columns` (list, required): one or more columns on which the index is defined. To create an index that uses *all* columns, use the `default` component instead.
* `name` (string, optional): the name for the index. If unspecified, Materialize will use the materialization name and column names provided.
* `cluster` (string, optional): the cluster to use to create the index. If unspecified, indexes will be created in the cluster used to create the materialization.
* `default` (bool, optional): Default: `False`. If set to `True`, creates a default index that uses all columns.

my\_view\_index.sql

```
{{ config(materialized='view',
          indexes=[{'columns': ['col_a'], 'cluster': 'cluster_a'}]) }}
          indexes=[{'columns': ['symbol']}]) }}

select ...
```

my\_view\_default\_index.sql

```
{{ config(materialized='view',
    indexes=[{'default': True}]) }}

select ...
```

### Data tests[​](#data-tests "Direct link to Data tests")

If you set the optional `--store-failures` flag or [`store_failures` config](https://docs.getdbt.com/reference/resource-configs/store_failures), dbt will create a materialized view for each configured test that can keep track of failures over time. By default, test views are created in a schema suffixed with `dbt_test__audit`. To specify a custom suffix, use the `schema` config.

dbt\_project.yml

```
data_tests:
  project_name:
    +store_failures: true
    +schema: test
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

IBM Netezza configurations](https://docs.getdbt.com/reference/resource-configs/ibm-netezza-config)[Next

Microsoft SQL Server configurations](https://docs.getdbt.com/reference/resource-configs/mssql-configs)

* [Performance optimizations](#performance-optimizations)
  + [Clusters](#clusters)+ [Incremental models: Materialized Views](#incremental-models-materialized-views)+ [Indexes](#indexes)+ [Data tests](#data-tests)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/materialize-configs.md)
