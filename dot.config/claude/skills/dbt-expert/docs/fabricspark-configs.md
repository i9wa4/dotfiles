---
title: "Microsoft Fabric Spark configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/fabricspark-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Microsoft Fabric Spark configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffabricspark-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffabricspark-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffabricspark-configs+so+I+can+ask+questions+about+it.)

On this page

## Configuring tables[​](#configuring-tables "Direct link to Configuring tables")

When materializing a model as `table`, you may include several optional configs that are specific to the dbt-spark plugin, in addition to the standard [model configs](https://docs.getdbt.com/reference/model-configs).

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required? Example |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | file\_format The file format to use when creating tables (`parquet`, `delta`, `csv`). Optional `delta`| location\_root [1](#user-content-fn-1) The specified directory used to store table data. The table alias is appended to it. Optional `Files/<folder>` or `Tables/<tableName>`| partition\_by Partition the table by the specified columns. A directory is created for each partition. Optional `date_day`| clustered\_by Each partition in the table will be split into a fixed number of buckets by the specified columns. Optional `country_code`| buckets The number of buckets to create while clustering Required if `clustered_by` is specified `8`| tblproperties The table properties configure table behavior. Properties differ depending on the file format, see reference docs ([Parquet](https://spark.apache.org/docs/3.5.4/sql-data-sources-parquet.html#data-source-option), [Delta](https://docs.delta.io/latest/table-properties.html)). Optional `Provider=delta Location=abfss://.../Files/tables/sales_data TableProperty.created.by=data_engineering_team TableProperty.purpose=sales analytics CreatedBy=Delta Lake CreatedAt=2024-12-01 14:21:00 Format=Parquet PartitionColumns=region MinReaderVersion=1 MinWriterVersion=2` | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Incremental models[​](#incremental-models "Direct link to Incremental models")

dbt seeks to offer useful, intuitive modeling abstractions by means of its built-in configurations and materializations. Because there is so much variance between Spark clusters out in the world—not to mention the powerful features offered to open source users by the Delta file format and custom runtime—making sense of all the available options is an undertaking in its own right.

For that reason, the dbt-fabricspark plugin leans heavily on the [`incremental_strategy` config](https://docs.getdbt.com/docs/build/incremental-strategy). This config tells the incremental materialization how to build models in runs beyond their first. It can be set to one of three values:

* **`append`** (default): Insert new records without updating or overwriting any existing data.
* **`insert_overwrite`**: If `partition_by` is specified, overwrite partitions in the table with new data. If no `partition_by` is specified, overwrite the entire table with new data.
* **`merge`** (Delta file format only): Match records based on a `unique_key`; update old records, insert new ones. (If no `unique_key` is specified, all new data is inserted, similar to `append`.)
* `microbatch` Implements the [microbatch strategy](https://docs.getdbt.com/docs/build/incremental-microbatch) using `event_time` to define time-based ranges for filtering data.

Each of these strategies has its pros and cons, which we'll discuss below. As with any model config, `incremental_strategy` may be specified in `dbt_project.yml` or within a model file's `config()` block.

### The `append` strategy[​](#the-append-strategy "Direct link to the-append-strategy")

Following the `append` strategy, dbt will perform an `insert into` statement with all new data. The appeal of this strategy is that it is straightforward and functional across all platforms, file types, connection methods, and Fabric Spark versions. However, this strategy *cannot* update, overwrite, or delete existing data, so it is likely to insert duplicate records for many data sources.

Specifying `append` as the incremental strategy is optional, since it's the default strategy used when none is specified.

* Source code* Run code

fabricspark\_incremental.sql

```
{{ config(
    materialized='incremental',
    incremental_strategy='append',
) }}

--  All rows returned by this query will be appended to the existing table

select * from {{ ref('events') }}
{% if is_incremental() %}
  where event_ts > (select max(event_ts) from {{ this }})
{% endif %}
```

fabricspark\_incremental.sql

```
create temporary view fabricspark_incremental__dbt_tmp as

    select * from analytics.events

    where event_ts >= (select max(event_ts) from {{ this }})

;

insert into table analytics.fabricspark_incremental
    select `date_day`, `users` from spark_incremental__dbt_tmp
```

### The `insert_overwrite` strategy[​](#the-insert_overwrite-strategy "Direct link to the-insert_overwrite-strategy")

This strategy is most effective when specified alongside a `partition_by` clause in your model config. dbt will run an [atomic `insert overwrite` statement](https://spark.apache.org/docs/3.0.0-preview/sql-ref-syntax-dml-insert-overwrite-table.html) that dynamically replaces all partitions included in your query. Be sure to re-select *all* of the relevant data for a partition when using this incremental strategy.

If no `partition_by` is specified, then the `insert_overwrite` strategy will atomically replace all contents of the table, overriding all existing data with only the new records. The column schema of the table remains the same, however. This can be desirable in some limited circumstances, since it minimizes downtime while the table contents are overwritten. The operation is comparable to running `truncate` + `insert` on other databases. For atomic replacement of Delta-formatted tables, use the `table` materialization (which runs `create or replace`) instead.

**Usage notes:**

* This strategy is not supported for tables with `file_format: delta`.

* Source code* Run code

fabricspark\_incremental.sql

```
{{ config(
    materialized='incremental',
    partition_by=['date_day'],
    file_format='parquet'
) }}

/*
  Every partition returned by this query will be overwritten
  when this model runs
*/

with new_events as (

    select * from {{ ref('events') }}

    {% if is_incremental() %}
    where date_day >= date_add(current_date, -1)
    {% endif %}

)

select
    date_day,
    count(*) as users

from events
group by 1
```

fabricspark\_incremental.sql

```
create temporary view fabricspark_incremental__dbt_tmp as

    with new_events as (

        select * from analytics.events


        where date_day >= date_add(current_date, -1)


    )

    select
        date_day,
        count(*) as users

    from events
    group by 1

;

insert overwrite table analytics.fabricspark_incremental
    partition (date_day)
    select `date_day`, `users` from spark_incremental__dbt_tmp
```

### The `merge` strategy[​](#the-merge-strategy "Direct link to the-merge-strategy")

**Usage notes:** The `merge` incremental strategy requires:

* `file_format: delta`
* Fabric Spark Runtime 3.0 and above for delta file format

dbt will run an atomic `merge` statement which looks nearly identical to the default merge behavior on Fabric Warehouse or SQL database or Snowflake and BigQuery. If a `unique_key` is specified (recommended), dbt will update old records with values from new records that match on the key column. If a `unique_key` is not specified, dbt will forgo match criteria and simply insert all new records (similar to `append` strategy).

* Source code* Run code

merge\_incremental.sql

```
{{ config(
    materialized='incremental',
    file_format='delta',
    unique_key='user_id',
    incremental_strategy='merge'
) }}

with new_events as (

    select * from {{ ref('events') }}

    {% if is_incremental() %}
    where date_day >= date_add(current_date, -1)
    {% endif %}

)

select
    user_id,
    max(date_day) as last_seen

from events
group by 1
```

target/run/merge\_incremental.sql

```
create temporary view merge_incremental__dbt_tmp as

    with new_events as (

        select * from analytics.events


        where date_day >= date_add(current_date, -1)


    )

    select
        user_id,
        max(date_day) as last_seen

    from events
    group by 1

;

merge into analytics.merge_incremental as DBT_INTERNAL_DEST
    using merge_incremental__dbt_tmp as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.user_id = DBT_INTERNAL_DEST.user_id
    when matched then update set *
    when not matched then insert *
```

## Persisting model descriptions[​](#persisting-model-descriptions "Direct link to Persisting model descriptions")

Relation-level docs persistence is supported in dbt. For more
information on configuring docs persistence, see [the docs](https://docs.getdbt.com/reference/resource-configs/persist_docs).

When the `persist_docs` option is configured appropriately, you'll be able to
see model descriptions in the `Comment` field of `describe [table] extended`
or `show table extended in [database] like '*'`.

## Always `schema`, never `database`[​](#always-schema-never-database "Direct link to always-schema-never-database")

Fabric Spark uses the terms "schema" and "database" interchangeably. dbt understands
`database` to exist at a higher level than `schema`. As such, you should *never*
use or set `database` as a node config or in the target profile when running dbt-fabricspark.
Move over, the adapter does not support schemas within Lakehouse.

## Default file format configurations[​](#default-file-format-configurations "Direct link to Default file format configurations")

To access advanced incremental strategies features, such as
[snapshots](https://docs.getdbt.com/docs/build/snapshots) and the `merge` incremental strategy, you will want to
use the Delta file format as the default file format when materializing models as tables.

It's quite convenient to do this by setting a top-level configuration in your
project file:

dbt\_project.yml

```
models:
  +file_format: delta

seeds:
  +file_format: delta

snapshots:
  +file_format: delta
```

## Footnotes[​](#footnote-label "Direct link to Footnotes")

1. If you configure `location_root`, dbt specifies a location path in the `create table` statement. This changes the table from "managed" to "external" in Fabric Lakehouse. [↩](#user-content-fnref-1)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Microsoft Fabric Data Warehouse configurations](https://docs.getdbt.com/reference/resource-configs/fabric-configs)[Next

Firebolt configurations](https://docs.getdbt.com/reference/resource-configs/firebolt-configs)

* [Configuring tables](#configuring-tables)* [Incremental models](#incremental-models)
    + [The `append` strategy](#the-append-strategy)+ [The `insert_overwrite` strategy](#the-insert_overwrite-strategy)+ [The `merge` strategy](#the-merge-strategy)* [Persisting model descriptions](#persisting-model-descriptions)* [Always `schema`, never `database`](#always-schema-never-database)* [Default file format configurations](#default-file-format-configurations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/fabricspark-configs.md)
