---
title: "Materializations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/materializations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Enhance your models](https://docs.getdbt.com/docs/build/enhance-your-models)* Materializations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmaterializations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmaterializations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmaterializations+so+I+can+ask+questions+about+it.)

On this page

## Overview[​](#overview "Direct link to Overview")

Materializations are strategies for persisting dbt models in a warehouse. There are five types of materializations built into dbt. They are:

* table
* view
* incremental
* ephemeral
* materialized view

You can also configure [custom materializations](https://docs.getdbt.com/guides/create-new-materializations?step=1) in dbt. Custom materializations are a powerful way to extend dbt's functionality to meet your specific needs.

Learn by video!

For video tutorials on Materializations, go to dbt Learn and check out the [Materializations fundamentals course](https://learn.getdbt.com/courses/materializations-fundamentals).

## Configuring materializations[​](#configuring-materializations "Direct link to Configuring materializations")

By default, dbt models are materialized as "views". Models can be configured with a different materialization by supplying the [`materialized` configuration](https://docs.getdbt.com/reference/resource-configs/materialized) parameter as shown in the following tabs.

* Project file* Model file* Property file

dbt\_project.yml

```
# The following dbt_project.yml configures a project that looks like this:
# .
# └── models
#     ├── csvs
#     │   ├── employees.sql
#     │   └── goals.sql
#     └── events
#         ├── stg_event_log.sql
#         └── stg_event_sessions.sql

name: my_project
version: 1.0.0
config-version: 2

models:
  my_project:
    events:
      # materialize all models in models/events as tables
      +materialized: table
    csvs:
      # this is redundant, and does not need to be set
      +materialized: view
```

Alternatively, materializations can be configured directly inside of the model SQL files. This can be useful if you are also setting [Performance Optimization] configs for specific models (for example, [Redshift specific configurations](https://docs.getdbt.com/reference/resource-configs/redshift-configs) or [BigQuery specific configurations](https://docs.getdbt.com/reference/resource-configs/bigquery-configs)).

models/events/stg\_event\_log.sql

```
{{ config(materialized='table', sort='timestamp', dist='user_id') }}

select *
from ...
```

Materializations can also be configured in the model's `properties.yml` file. The following example shows the `table` materialization type. For a complete list of materialization types, refer to [materializations](https://docs.getdbt.com/docs/build/materializations#materializations).

models/properties.yml

```
models:
  - name: events
    config:
      materialized: table
```

## Materializations[​](#materializations "Direct link to Materializations")

### View[​](#view "Direct link to View")

When using the `view` materialization, your model is rebuilt as a view on each run, via a `create view as` statement.

* **Pros:** No additional data is stored, views on top of source data will always have the latest records in them.
* **Cons:** Views that perform a significant transformation, or are stacked on top of other views, are slow to query.
* **Advice:**
  + Generally start with views for your models, and only change to another materialization when you notice performance problems.
  + Views are best suited for models that do not do significant transformation, for example, renaming, or recasting columns.

### Table[​](#table "Direct link to Table")

When using the `table` materialization, your model is rebuilt as a table on each run, via a `create table as` statement.

* **Pros:** Tables are fast to query
* **Cons:**
  + Tables can take a long time to rebuild, especially for complex transformations
  + New records in underlying source data are not automatically added to the table
* **Advice:**
  + Use the table materialization for any models being queried by BI tools, to give your end user a faster experience
  + Also use the table materialization for any slower transformations that are used by many downstream models

### Incremental[​](#incremental "Direct link to Incremental")

`incremental` models allow dbt to insert or update records into a table since the last time that model was run.

* **Pros:** You can significantly reduce the build time by just transforming new records
* **Cons:** Incremental models require extra configuration and are an advanced usage of dbt. Read more about using incremental models [here](https://docs.getdbt.com/docs/build/incremental-models).
* **Advice:**
  + Incremental models are best for event-style data
  + Use incremental models when your `dbt run`s are becoming too slow (i.e. don't start with incremental models)

### Ephemeral[​](#ephemeral "Direct link to Ephemeral")

`ephemeral` models are not directly built into the database. Instead, dbt will interpolate the code from an ephemeral model into its dependent models using a common table expression (CTE). You can control the identifier for this CTE using a [model alias](https://docs.getdbt.com/docs/build/custom-aliases), but dbt will always prefix the model identifier with `__dbt__cte__`.

* **Pros:**
  + You can still write reusable logic
  + Ephemeral models can help keep your data warehouse clean by reducing clutter (also consider splitting your models across multiple schemas by [using custom schemas](https://docs.getdbt.com/docs/build/custom-schemas)).
* **Cons:**
  + You cannot select directly from this model.
  + [Operations](https://docs.getdbt.com/docs/build/hooks-operations#about-operations) (for example, macros called using [`dbt run-operation`](https://docs.getdbt.com/reference/commands/run-operation) cannot `ref()` ephemeral nodes)
  + Overuse of ephemeral materialization can also make queries harder to debug.
  + Ephemeral materialization doesn't support [model contracts](https://docs.getdbt.com/docs/mesh/govern/model-contracts#where-are-contracts-supported).
* **Advice:** Use the ephemeral materialization for:
  + Very light-weight transformations that are early on in your DAG
  + Are only used in one or two downstream models, and
  + Don't need to be queried directly

### Materialized View[​](#materialized-view "Direct link to Materialized View")

The `materialized_view` materialization allows the creation and maintenance of materialized views in the target database.
Materialized views are a combination of a view and a table, and serve use cases similar to incremental models.

* **Pros:**
  + Materialized views combine the query performance of a table with the data freshness of a view
  + Materialized views operate much like incremental materializations, however they are usually
    able to be refreshed without manual interference on a regular cadence (depending on the database), forgoing the regular dbt batch refresh
    required with incremental materializations
  + `dbt run` on materialized views corresponds to a code deployment, just like views

* **Cons:**
  + Due to the fact that materialized views are more complex database objects, database platforms tend to have
    fewer configuration options available; see your database platform's docs for more details
  + Materialized views may not be supported by every database platform

* **Advice:**
  + Consider materialized views for use cases where incremental models are sufficient, but you would like the data platform to manage the incremental logic and refresh.

#### Configuration Change Monitoring[​](#configuration-change-monitoring "Direct link to Configuration Change Monitoring")

This materialization makes use of the [`on_configuration_change`](https://docs.getdbt.com/reference/resource-configs/on_configuration_change)
config, which aligns with the incremental nature of the namesake database object. This setting tells dbt to attempt to
make configuration changes directly to the object when possible, as opposed to completely recreating
the object to implement the updated configuration. Using `dbt-postgres` as an example, indexes can
be dropped and created on the materialized view without the need to recreate the materialized view itself.

#### Scheduled Refreshes[​](#scheduled-refreshes "Direct link to Scheduled Refreshes")

In the context of a `dbt run` command, materialized views should be thought of as similar to views.
For example, a `dbt run` command is only needed if there is the potential for a change in configuration or sql;
it's effectively a deploy action.
By contrast, a `dbt run` command is needed for a table in the same scenarios *AND when the data in the table needs to be updated*.
This also holds true for incremental and snapshot models, whose underlying relations are tables.
In the table cases, the scheduling mechanism is either dbt or your local scheduler;
there is no built-in functionality to automatically refresh the data behind a table.
However, most platforms (Postgres excluded) provide functionality to configure automatically refreshing a materialized view.
Hence, materialized views work similarly to incremental models with the benefit of not needing to run dbt to refresh the data.
This assumes, of course, that auto refresh is turned on and configured in the model.

info

`dbt-snowflake` *does not* support materialized views, it uses Dynamic Tables instead. For details, refer to [Snowflake specific configurations](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#dynamic-tables).

## Python materializations[​](#python-materializations "Direct link to Python materializations")

Python models support two materializations:

* `table`
* `incremental`

Incremental Python models support all the same [incremental strategies](https://docs.getdbt.com/docs/build/incremental-strategy) as their SQL counterparts. The specific strategies supported depend on your adapter.

Python models can't be materialized as `view` or `ephemeral`. Python isn't supported for non-model resource types (like tests and snapshots).

For incremental models, like SQL models, you will need to filter incoming tables to only new rows of data:

* Snowpark* PySpark

models/my\_python\_model.py

```
import snowflake.snowpark.functions as F

def model(dbt, session):
    dbt.config(materialized = "incremental")
    df = dbt.ref("upstream_table")

    if dbt.is_incremental:

        # only new rows compared to max in current table
        max_from_this = f"select max(updated_at) from {dbt.this}"
        df = df.filter(df.updated_at >= session.sql(max_from_this).collect()[0][0])

        # or only rows from the past 3 days
        df = df.filter(df.updated_at >= F.dateadd("day", F.lit(-3), F.current_timestamp()))

    ...

    return df
```

models/my\_python\_model.py

```
import pyspark.sql.functions as F

def model(dbt, session):
    dbt.config(materialized = "incremental")
    df = dbt.ref("upstream_table")

    if dbt.is_incremental:

        # only new rows compared to max in current table
        max_from_this = f"select max(updated_at) from {dbt.this}"
        df = df.filter(df.updated_at >= session.sql(max_from_this).collect()[0][0])

        # or only rows from the past 3 days
        df = df.filter(df.updated_at >= F.date_add(F.current_timestamp(), F.lit(-3)))

    ...

    return df
```

**Note:** Incremental models are supported on BigQuery/Dataproc for the `merge` incremental strategy. The `insert_overwrite` strategy is not yet supported.

### Questions from the Community[​](#questions-from-the-community "Direct link to Questions from the Community")

![Loading](https://docs.getdbt.com/img/loader-icon.svg)[Ask the Community](https://discourse.getdbt.com/new-topic?category=help&tags=materialization "Ask the Community")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Enhance your models](https://docs.getdbt.com/docs/build/enhance-your-models)[Next

Configure incremental models](https://docs.getdbt.com/docs/build/incremental-models)

* [Overview](#overview)* [Configuring materializations](#configuring-materializations)* [Materializations](#materializations)
      + [View](#view)+ [Table](#table)+ [Incremental](#incremental)+ [Ephemeral](#ephemeral)+ [Materialized View](#materialized-view)* [Python materializations](#python-materializations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/materializations.md)
