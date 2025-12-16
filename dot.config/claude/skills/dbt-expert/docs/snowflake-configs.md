---
title: "Snowflake configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/snowflake-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Snowflake configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fsnowflake-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fsnowflake-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fsnowflake-configs+so+I+can+ask+questions+about+it.)

On this page

## Iceberg table format[​](#iceberg-table-format "Direct link to Iceberg table format")

Our Snowflake Iceberg table content has moved to a [new page](https://docs.getdbt.com/docs/mesh/iceberg/snowflake-iceberg-support)!

## Dynamic tables[​](#dynamic-tables "Direct link to Dynamic tables")

The Snowflake adapter supports [dynamic tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-about).
This materialization is specific to Snowflake, which means that any model configuration that
would normally come along for the ride from `dbt-core` (e.g. as with a `view`) may not be available
for dynamic tables. This gap will decrease in future patches and versions.
While this materialization is specific to Snowflake, it very much follows the implementation
of [materialized views](https://docs.getdbt.com/docs/build/materializations#Materialized-View).
In particular, dynamic tables have access to the `on_configuration_change` setting.
Dynamic tables are supported with the following configuration parameters:

Learn more about these parameters in Snowflake's [docs](https://docs.snowflake.com/en/sql-reference/sql/create-dynamic-table):

### Target lag[​](#target-lag "Direct link to Target lag")

Snowflake allows two configuration scenarios for scheduling automatic refreshes:

* **Time-based** — Provide a value of the form `<int> { seconds | minutes | hours | days }`. For example, if the dynamic table needs to be updated every 30 minutes, use `target_lag='30 minutes'`.
* **Downstream** — Applicable when the dynamic table is referenced by other dynamic tables. In this scenario, `target_lag='downstream'` allows for refreshes to be controlled at the target, instead of at each layer.

Learn more about `target_lag` in Snowflake's [docs](https://docs.snowflake.com/en/user-guide/dynamic-tables-refresh#understanding-target-lag). Please note that Snowflake supports a target lag of 1 minute or longer.

### Limitations[​](#limitations "Direct link to Limitations")

As with materialized views on most data platforms, there are limitations associated with dynamic tables. Some worth noting include:

* Dynamic table SQL has a [limited feature set](https://docs.snowflake.com/en/user-guide/dynamic-tables-tasks-create#query-constructs-not-currently-supported-in-dynamic-tables).
* Dynamic table SQL cannot be updated; the dynamic table must go through a `--full-refresh` (DROP/CREATE).
* Dynamic tables cannot be downstream from: materialized views, external tables, streams.
* Dynamic tables cannot reference a view that is downstream from another dynamic table.

Find more information about dynamic table limitations in Snowflake's [docs](https://docs.snowflake.com/en/user-guide/dynamic-tables-tasks-create#dynamic-table-limitations-and-supported-functions).

For dbt limitations, these dbt features are not supported:

* [Model contracts](https://docs.getdbt.com/docs/mesh/govern/model-contracts)
* [Copy grants configuration](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#copying-grants)

### Troubleshooting dynamic tables[​](#troubleshooting-dynamic-tables "Direct link to Troubleshooting dynamic tables")

If your dynamic table model fails to rerun with the following error message after the initial execution:

```
SnowflakeDynamicTableConfig.__init__() missing 6 required positional arguments: 'name', 'schema_name', 'database_name', 'query', 'target_lag', and 'snowflake_warehouse'
```

Ensure that `QUOTED_IDENTIFIERS_IGNORE_CASE` on your account is set to `FALSE`.

## Temporary tables[​](#temporary-tables "Direct link to Temporary tables")

Incremental table merges for Snowflake prefer to utilize a `view` rather than a `temporary table`. The reasoning is to avoid the database write step that a temporary table would initiate and save compile time.

However, some situations remain where a temporary table would achieve results faster or more safely. The `tmp_relation_type` configuration enables you to opt in to temporary tables for incremental builds. This is defined as part of the model configuration.

To guarantee accuracy, an incremental model using the `delete+insert` strategy with a `unique_key` defined requires a temporary table; trying to change this to a view will result in an error.

Defined in the project YAML:

dbt\_project.yml

```
name: my_project

...

models:
  <resource-path>:
    +tmp_relation_type: table | view ## If not defined, view is the default.
```

In the configuration format for the model SQL file:

dbt\_model.sql

```
{{ config(
    tmp_relation_type="table | view", ## If not defined, view is the default.
) }}
```

## Transient tables[​](#transient-tables "Direct link to Transient tables")

Snowflake supports the creation of [transient tables](https://docs.snowflake.net/manuals/user-guide/tables-temp-transient.html). Snowflake does not preserve a history for these tables, which can result in a measurable reduction of your Snowflake storage costs. Transient tables participate in time travel to a limited degree with a retention period of 1 day by default with no fail-safe period. Weigh these tradeoffs when deciding whether or not to configure your dbt models as `transient`. **By default, all Snowflake tables created by dbt are `transient`.**

### Configuring transient tables in dbt\_project.yml[​](#configuring-transient-tables-in-dbt_projectyml "Direct link to Configuring transient tables in dbt_project.yml")

A whole folder (or package) can be configured to be transient (or not) by adding a line to the `dbt_project.yml` file. This config works just like all of the [model configs](https://docs.getdbt.com/reference/model-configs) defined in `dbt_project.yml`.

dbt\_project.yml

```
name: my_project

...

models:
  +transient: false
  my_project:
    ...
```

### Configuring transience for a specific model[​](#configuring-transience-for-a-specific-model "Direct link to Configuring transience for a specific model")

A specific model can be configured to be transient by setting the `transient` model config to `true`.

my\_table.sql

```
{{ config(materialized='table', transient=true) }}

select * from ...
```

## Query tags[​](#query-tags "Direct link to Query tags")

[Query tags](https://docs.snowflake.com/en/sql-reference/parameters.html#query-tag) are a Snowflake
parameter that can be quite useful later on when searching in the [QUERY\_HISTORY view](https://docs.snowflake.com/en/sql-reference/account-usage/query_history.html).

dbt supports setting a default query tag for the duration of its Snowflake connections in
[your profile](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup). You can set more precise values (and override the default) for subsets of models by setting
a `query_tag` model config or by overriding the default `set_query_tag` macro:

dbt\_project.yml

```
models:
  <resource-path>:
    +query_tag: dbt_special
```

models/<modelname>.sql

```
{{ config(
    query_tag = 'dbt_special'
) }}

select ...
```

In this example, you can set up a query tag to be applied to every query with the model's name.

```
  {% macro set_query_tag() -%}
  {% set new_query_tag = model.name %}
  {% if new_query_tag %}
    {% set original_query_tag = get_current_query_tag() %}
    {{ log("Setting query_tag to '" ~ new_query_tag ~ "'. Will reset to '" ~ original_query_tag ~ "' after materialization.") }}
    {% do run_query("alter session set query_tag = '{}'".format(new_query_tag)) %}
    {{ return(original_query_tag)}}
  {% endif %}
  {{ return(none)}}
{% endmacro %}
```

**Note:** query tags are set at the *session* level. At the start of each model materialization, if the model has a custom `query_tag` configured, dbt will run `alter session set query_tag` to set the new value. At the end of the materialization, dbt will run another `alter` statement to reset the tag to its default value. As such, build failures midway through a materialization may result in subsequent queries running with an incorrect tag.

## Merge behavior (incremental models)[​](#merge-behavior-incremental-models "Direct link to Merge behavior (incremental models)")

The [`incremental_strategy` config](https://docs.getdbt.com/docs/build/incremental-strategy) controls how dbt builds incremental models. By default, dbt will use a [merge statement](https://docs.snowflake.net/manuals/sql-reference/sql/merge.html) on Snowflake to refresh incremental tables.

Snowflake supports the following incremental strategies:

* [`merge`](https://docs.getdbt.com/docs/build/incremental-strategy#merge) (default)
* [`append`](https://docs.getdbt.com/docs/build/incremental-strategy#append)
* [`delete+insert`](https://docs.getdbt.com/docs/build/incremental-strategy#deleteinsert)
* [`insert_overwrite`](https://docs.getdbt.com/docs/build/incremental-strategy#insert_overwrite)
  + Note: This is not a standard dbt incremental strategy. `insert_overwrite` behaves like `truncate` + re-`insert` commands on Snowflake. It doesn't support partition-based overwrites, which means it'll overwrite the entire table intentionally. It's implemented as an incremental strategy because it aligns with dbt’s workflow of not dropping existing tables.
* [`microbatch`](https://docs.getdbt.com/docs/build/incremental-microbatch)

Snowflake's `merge` statement fails with a "nondeterministic merge" error if the `unique_key` specified in your model config is not actually unique. If you encounter this error, you can instruct dbt to use a two-step incremental approach by setting the `incremental_strategy` config for your model to `delete+insert`.

## Configuring table clustering[​](#configuring-table-clustering "Direct link to Configuring table clustering")

dbt supports [table clustering](https://docs.snowflake.net/manuals/user-guide/tables-clustering-keys.html) on Snowflake. To control clustering for a table or incremental model, use the `cluster_by` config. When this configuration is applied, dbt will do two things:

1. It will implicitly order the table results by the specified `cluster_by` fields.
2. It will add the specified clustering keys to the target table.

By using the specified `cluster_by` fields to order the table, dbt minimizes the amount of work required by Snowflake's automatic clustering functionality. If an incremental model is configured to use table clustering, then dbt will also order the staged dataset before merging it into the destination table. As such, the dbt-managed table should always be in a mostly clustered state.

### Using cluster\_by[​](#using-cluster_by "Direct link to Using cluster_by")

The `cluster_by` config accepts either a string, or a list of strings to use as clustering keys. The following example will create a sessions table that is clustered by the `session_start` column.

models/events/sessions.sql

```
{{
  config(
    materialized='table',
    cluster_by=['session_start']
  )
}}

select
  session_id,
  min(event_time) as session_start,
  max(event_time) as session_end,
  count(*) as count_pageviews

from {{ source('snowplow', 'event') }}
group by 1
```

The code above will be compiled to SQL that looks (approximately) like this:

```
create or replace table my_database.my_schema.my_table as (

  select * from (
    select
      session_id,
      min(event_time) as session_start,
      max(event_time) as session_end,
      count(*) as count_pageviews

    from {{ source('snowplow', 'event') }}
    group by 1
  )

  -- this order by is added by dbt in order to create the
  -- table in an already-clustered manner.
  order by session_start

);

 alter table my_database.my_schema.my_table cluster by (session_start);
```

### Dynamic table clustering[​](#dynamic-table-clustering "Direct link to Dynamic table clustering")

Starting in dbt Core v1.10, dynamic tables support the `cluster_by` configuration. When set, dbt includes the clustering specification in the `CREATE DYNAMIC TABLE` statement.

For example:

```
{{ config(
    materialized='dynamic_table',
    snowflake_warehouse='COMPUTE_WH',
    target_lag='1 minute',
    cluster_by=['session_start', 'user_id']
) }}

select
    session_id,
    user_id,
    min(event_time) as session_start,
    max(event_time) as session_end,
    count(*) as count_pageviews
from {{ source('snowplow', 'event') }}
group by 1, 2
```

This config generates the following SQL when compiled:

```
create or replace dynamic table my_database.my_schema.my_table
  target_lag = '1 minute'
  warehouse = COMPUTE_WH
  cluster by (session_start, user_id)
as (
  select
    session_id,
    user_id,
    min(event_time) as session_start,
    max(event_time) as session_end,
    count(*) as count_pageviews
  from source_table
  group by 1, 2
);
```

You can specify clustering for dynamic tables when you create them using `CLUSTER BY` in the `CREATE DYNAMIC TABLE` statement. You don’t need to run a separate `ALTER TABLE` statement.

### Automatic clustering[​](#automatic-clustering "Direct link to Automatic clustering")

Automatic clustering is [enabled by default in Snowflake today](https://docs.snowflake.com/en/user-guide/tables-auto-reclustering.html), no action is needed to make use of it. Though there is an `automatic_clustering` config, it has no effect except for accounts with (deprecated) manual clustering enabled.

If [manual clustering is still enabled for your account](https://docs.snowflake.com/en/user-guide/tables-clustering-manual.html), you can use the `automatic_clustering` config to control whether or not automatic clustering is enabled for dbt models. When `automatic_clustering` is set to `true`, dbt will run an `alter table <table name> resume recluster` query after building the target table.

The `automatic_clustering` config can be specified in the `dbt_project.yml` file, or in a model `config()` block.

dbt\_project.yml

```
models:
  +automatic_clustering: true
```

## Python model configuration[​](#python-model-configuration "Direct link to Python model configuration")

The Snowflake adapter supports Python models. Snowflake uses its own framework, Snowpark, which has many similarities to PySpark.

**Additional setup:** You will need to [acknowledge and accept Snowflake Third Party Terms](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages.html#getting-started) to use Anaconda packages.

**Installing packages:** Snowpark supports several popular packages via Anaconda. Refer to the [complete list](https://repo.anaconda.com/pkgs/snowflake/) for more details. Packages are installed when your model is run. Different models can have different package dependencies. If you use third-party packages, Snowflake recommends using a dedicated virtual warehouse for best performance rather than one with many concurrent users.

**Python version:** To specify a different Python version, use the following configuration:

```
def model(dbt, session):
    dbt.config(
        materialized = "table",
        python_version="3.11"
    )
```

You can use the `python_version` config to run a Snowpark model with [Python versions](https://docs.snowflake.com/en/developer-guide/snowpark/python/setup) 3.9, 3.10, or 3.11.

**External access integrations and secrets**: To query external APIs within dbt Python models, use Snowflake’s [external access](https://docs.snowflake.com/en/developer-guide/external-network-access/external-network-access-overview) together with [secrets](https://docs.snowflake.com/en/developer-guide/external-network-access/secret-api-reference). Here are some additional configurations you can use:

```
import pandas
import snowflake.snowpark as snowpark

def model(dbt, session: snowpark.Session):
    dbt.config(
        materialized="table",
        secrets={"secret_variable_name": "test_secret"},
        external_access_integrations=["test_external_access_integration"],
    )
    import _snowflake
    return session.create_dataframe(
        pandas.DataFrame(
            [{"secret_value": _snowflake.get_generic_secret_string('secret_variable_name')}]
        )
    )
```

**Docs:** ["Developer Guide: Snowpark Python"](https://docs.snowflake.com/en/developer-guide/snowpark/python/index.html)

### Third-party Snowflake packages[​](#third-party-snowflake-packages "Direct link to Third-party Snowflake packages")

To use a third-party Snowflake package that isn't available in Snowflake Anaconda, upload your package by following [this example](https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages#importing-packages-through-a-snowflake-stage), and then configure the `imports` setting in the dbt Python model to reference to the zip file in your Snowflake staging.

Here’s a complete example configuration using a zip file, including using `imports` in a Python model:

```
def model(dbt, session):
    # Configure the model
    dbt.config(
        materialized="table",
        imports=["@mystage/mycustompackage.zip"],  # Specify the external package location
    )

    # Example data transformation using the imported package
    # (Assuming `some_external_package` has a function we can call)
    data = {
        "name": ["Alice", "Bob", "Charlie"],
        "score": [85, 90, 88]
    }
    df = pd.DataFrame(data)

    # Process data with the external package
    df["adjusted_score"] = df["score"].apply(lambda x: some_external_package.adjust_score(x))

    # Return the DataFrame as the model output
    return df
```

For more information on using this configuration, refer to [Snowflake's documentation](https://community.snowflake.com/s/article/how-to-use-other-python-packages-in-snowpark) on uploading and using other python packages in Snowpark not published on Snowflake's Anaconda channel.

## Configuring virtual warehouses[​](#configuring-virtual-warehouses "Direct link to Configuring virtual warehouses")

The default warehouse that dbt uses can be configured in your [Profile](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) for Snowflake connections. To override the warehouse that is used for specific models (or groups of models), use the `snowflake_warehouse` model configuration. This configuration can be used to specify a larger warehouse for certain models in order to control Snowflake costs and project build times.

* Project file* Property file* SQL config

The following example changes the warehouse for a group of models with a config argument in the YAML.

dbt\_project.yml

```
name: my_project
version: 1.0.0

...

models:
  +snowflake_warehouse: "EXTRA_SMALL"    # default Snowflake virtual warehouse for all models in the project.
  my_project:
    clickstream:
      +snowflake_warehouse: "EXTRA_LARGE"    # override the default Snowflake virtual warehouse for all models under the `clickstream` directory.
snapshots:
  +snowflake_warehouse: "EXTRA_LARGE"    # all Snapshot models are configured to use the `EXTRA_LARGE` warehouse.
```

The following example overrides the Snowflake warehouse for a single model using a config argument in the property file.

models/my\_model.yml

```
models:
  - name: my_model
    config:
      snowflake_warehouse: "EXTRA_LARGE"    # override the Snowflake virtual warehouse just for this model
```

The following example changes the warehouse for a single model with a config() block in the SQL model.

models/events/sessions.sql

```
# override the Snowflake virtual warehouse for just this model
{{
  config(
    materialized='table',
    snowflake_warehouse='EXTRA_LARGE'
  )
}}

with

aggregated_page_events as (

    select
        session_id,
        min(event_time) as session_start,
        max(event_time) as session_end,
        count(*) as count_page_views
    from {{ source('snowplow', 'event') }}
    group by 1

),

index_sessions as (

    select
        *,
        row_number() over (
            partition by session_id
            order by session_start
        ) as page_view_in_session_index
    from aggregated_page_events

)

select * from index_sessions
```

## Copying grants[​](#copying-grants "Direct link to Copying grants")

When the `copy_grants` config is set to `true`, dbt will add the `copy grants` DDL qualifier when rebuilding tables and views. The default value is `false`.

dbt\_project.yml

```
models:
  +copy_grants: true
```

## Secure views[​](#secure-views "Direct link to Secure views")

To create a Snowflake [secure view](https://docs.snowflake.net/manuals/user-guide/views-secure.html), use the `secure` config for view models. Secure views can be used to limit access to sensitive data. Note: secure views may incur a performance penalty, so you should only use them if you need them.

The following example configures the models in the `sensitive/` folder to be configured as secure views.

dbt\_project.yml

```
name: my_project
version: 1.0.0

models:
  my_project:
    sensitive:
      +materialized: view
      +secure: true
```

## Source freshness known limitation[​](#source-freshness-known-limitation "Direct link to Source freshness known limitation")

Snowflake calculates source freshness using information from the `LAST_ALTERED` column, meaning it relies on a field updated whenever any object undergoes modification, not only data updates. No action must be taken, but analytics teams should note this caveat.

Per the [Snowflake documentation](https://docs.snowflake.com/en/sql-reference/info-schema/tables#usage-notes):

> The `LAST_ALTERED` column is updated when the following operations are performed on an object:
>
> * DDL operations.
> * DML operations (for tables only).
> * Background maintenance operations on metadata performed by Snowflake.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

SingleStore configurations](https://docs.getdbt.com/reference/resource-configs/singlestore-configs)[Next

Starburst/Trino configurations](https://docs.getdbt.com/reference/resource-configs/trino-configs)

* [Iceberg table format](#iceberg-table-format)* [Dynamic tables](#dynamic-tables)
    + [Target lag](#target-lag)+ [Refresh mode](#refresh-mode)+ [Initialize](#initialize)+ [Limitations](#limitations)+ [Troubleshooting dynamic tables](#troubleshooting-dynamic-tables)* [Temporary tables](#temporary-tables)* [Transient tables](#transient-tables)
        + [Configuring transient tables in dbt\_project.yml](#configuring-transient-tables-in-dbt_projectyml)+ [Configuring transience for a specific model](#configuring-transience-for-a-specific-model)* [Query tags](#query-tags)* [Merge behavior (incremental models)](#merge-behavior-incremental-models)* [Configuring table clustering](#configuring-table-clustering)
              + [Using cluster\_by](#using-cluster_by)+ [Dynamic table clustering](#dynamic-table-clustering)+ [Automatic clustering](#automatic-clustering)* [Python model configuration](#python-model-configuration)
                + [Third-party Snowflake packages](#third-party-snowflake-packages)* [Configuring virtual warehouses](#configuring-virtual-warehouses)* [Copying grants](#copying-grants)* [Setting row access policies](#setting-row-access-policies)* [Configuring table tags](#configuring-table-tags)* [Secure views](#secure-views)* [Source freshness known limitation](#source-freshness-known-limitation)* [Pagination for object results](#pagination-for-object-results)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/snowflake-configs.md)
