---
title: "Firebolt configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/firebolt-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Firebolt configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffirebolt-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffirebolt-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffirebolt-configs+so+I+can+ask+questions+about+it.)

On this page

## Setting `quote_columns`[​](#setting-quote_columns "Direct link to setting-quote_columns")

To prevent a warning, make sure to explicitly set a value for `quote_columns` in your `dbt_project.yml`. See the [doc on quote\_columns](https://docs.getdbt.com/reference/resource-configs/quote_columns) for more information.

```
seeds:
  +quote_columns: false  #or `true` if you have CSV column headers with spaces
```

## Model configuration for fact tables[​](#model-configuration-for-fact-tables "Direct link to Model configuration for fact tables")

A dbt model can be created as a Firebolt fact table and configured using the following syntax:

* Project file* Property file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +materialized: table
    +table_type: fact
    +primary_index: [ <column-name>, ... ]
    +indexes:
      - index_type: aggregating
        key_columns: [ <column-name>, ... ]
        aggregation: [ <agg-sql>, ... ]
      ...
```

models/properties.yml

```
models:
  - name: <model-name>
    config:
      materialized: table
      table_type: fact
      primary_index: [ <column-name>, ... ]
      indexes:
        - index_type: aggregating
          key_columns: [ <column-name>, ... ]
          aggregation: [ <agg-sql>, ... ]
        ...
```

models/<model\_name>.sql

```
{{ config(
    materialized = "table"
    table_type = "fact"
    primary_index = [ "<column-name>", ... ],
    indexes = [
      {
        "index_type": "aggregating"
        "key_columns": [ "<column-name>", ... ],
        "aggregation": [ "<agg-sql>", ... ],
      },
      ...
    ]
) }}
```

#### Fact table configurations[​](#fact-table-configurations "Direct link to Fact table configurations")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Configuration Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `materialized` How the model will be materialized into Firebolt. Must be `table` to create a fact table.| `table_type` Whether the materialized table will be a [fact or dimension](https://docs.firebolt.io/godocs/Overview/working-with-tables/working-with-tables.html#fact-and-dimension-tables) table.| `primary_index` Sets the primary index for the fact table using the inputted list of column names from the model. Required for fact tables.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `indexes` A list of aggregating indexes to create on the fact table.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `index_type` Specifies that the index is an [aggregating index](https://docs.firebolt.io/godocs/Guides/working-with-indexes/using-aggregating-indexes.html). Should be set to `aggregating`.| `key_columns` Sets the grouping of the aggregating index using the inputted list of column names from the model.|  |  | | --- | --- | | `aggregation` Sets the aggregations on the aggregating index using the inputted list of SQL agg expressions. | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Example of a fact table with an aggregating index[​](#example-of-a-fact-table-with-an-aggregating-index "Direct link to Example of a fact table with an aggregating index")

```
{{ config(
    materialized = "table",
    table_type = "fact",
    primary_index = "id",
    indexes = [
      {
        "index_type": "aggregating",
        "key_columns": "order_id",
        "aggregation": ["COUNT(DISTINCT status)", "AVG(customer_id)"]
      }
    ]
) }}
```

## Model configuration for dimension tables[​](#model-configuration-for-dimension-tables "Direct link to Model configuration for dimension tables")

A dbt model can be materialized as a Firebolt dimension table and configured using the following syntax:

* Project file* Property file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +materialized: table
    +table_type: dimension
    ...
```

models/properties.yml

```
models:
  - name: <model-name>
    config:
      materialized: table
      table_type: dimension
    ...
```

models/<model\_name>.sql

```
{{ config(
    materialized = "table",
    table_type = "dimension",
    ...
) }}
```

Dimension tables do not support aggregation indexes.

#### Dimension table configurations[​](#dimension-table-configurations "Direct link to Dimension table configurations")

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Configuration Description|  |  |  |  | | --- | --- | --- | --- | | `materialized` How the model will be materialized into Firebolt. Must be `table` to create a dimension table.| `table_type` Whether the materialized table will be a [fact or dimension](https://docs.firebolt.io/godocs/Overview/working-with-tables/working-with-tables.html#fact-and-dimension-tables) table. | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## How aggregating indexes are named[​](#how-aggregating-indexes-are-named "Direct link to How aggregating indexes are named")

In dbt-firebolt, you do not provide names for aggregating indexes; they are named programmatically. dbt will generate index names using the following convention:

```
<table-name>__<key-column>__<index-type>_<unix-timestamp-at-execution>
```

For example, a join index could be named `my_users__id__join_1633504263` and an aggregating index could be named `my_orders__order_date__aggregating_1633504263`.

## Managing ingestion via external tables[​](#managing-ingestion-via-external-tables "Direct link to Managing ingestion via external tables")

`dbt-firebolt` supports dbt's [external tables feature](https://docs.getdbt.com/reference/resource-properties/external), which allows dbt to manage the table ingestion process from S3 into Firebolt. This is an optional feature but can be highly convenient depending on your use case.

More information on using external tables including properly configuring IAM can be found in the Firebolt [documentation](https://docs.firebolt.io/godocs/Guides/loading-data/working-with-external-tables.html).

#### Installation of external tables package[​](#installation-of-external-tables-package "Direct link to Installation of external tables package")

To install and use `dbt-external-tables` with Firebolt, you must:

1. Add this package to your packages.yml:

   ```
   packages:
     - package: dbt-labs/dbt_external_tables
       version: <version>
   ```
2. Add these fields to your `dbt_project.yml`:

   ```
   dispatch:
     - macro_namespace: dbt_external_tables
       search_order: ['dbt', 'dbt_external_tables']
   ```
3. Pull in the `packages.yml` dependencies by calling `dbt deps`.

#### Using external tables[​](#using-external-tables "Direct link to Using external tables")

To use external tables, you must define a table as `external` in your `dbt_project.yml` file. Every external table must contain the fields `url`, `type`, and `object_pattern`. Note that the Firebolt external table specification requires fewer fields than what is specified in the dbt documentation.

In addition to specifying the columns, an external table may specify partitions. Partitions are not columns and they cannot have the same name as columns. To avoid YAML parsing errors, remember to encase string literals (such as the `url` and `object_pattern` values) in single quotation marks.

#### dbt\_project.yml syntax for an external table[​](#dbt_projectyml-syntax-for-an-external-table "Direct link to dbt_project.yml syntax for an external table")

```
sources:
  - name: firebolt_external
    schema: "{{ target.schema }}"
    loader: S3

    tables:
      - name: <table-name>
        external:
          url: 's3://<bucket_name>/'
          object_pattern: '<regex>'
          type: '<type>'
          credentials:
            aws_key_id: <key-id>
            aws_secret_key: <key-secret>
          object_pattern: '<regex>'
          compression: '<compression-type>'
          partitions:
            - name: <partition-name>
              data_type: <partition-type>
              regex: '<partition-definition-regex>'
          columns:
            - name: <column-name>
              data_type: <type>
```

`aws_key_id` and `aws_secret_key` are the credentails that allow Firebolt access to your S3 bucket. Learn
how to set them up by following this [guide](https://docs.firebolt.io/godocs/Guides/loading-data/creating-access-keys-aws.html). If your bucket is public these parameters are not necessary.

#### Running external tables[​](#running-external-tables "Direct link to Running external tables")

The `stage_external_sources` macro is inherited from the [dbt-external-tables package](https://github.com/dbt-labs/dbt-external-tables#syntax) and is the primary point of entry when using thes package. It has two operational modes: standard and "full refresh."

```
# iterate through all source nodes, create if missing, refresh metadata
$ dbt run-operation stage_external_sources

# iterate through all source nodes, create or replace (no refresh command is required as data is fetched live from remote)
$ dbt run-operation stage_external_sources --vars "ext_full_refresh: true"
```

## Incremental models[​](#incremental-models "Direct link to Incremental models")

The [`incremental_strategy` configuration](https://docs.getdbt.com/docs/build/incremental-strategy) controls how dbt builds incremental models. Firebolt currently supports `append`, `insert_overwrite` and `delete+insert` configuration. You can specify `incremental_strategy` in `dbt_project.yml` or within a model file's `config()` block. The `append` configuration is the default. Specifying this configuration is optional.

The `append` strategy performs an `INSERT INTO` statement with all the new data based on the model definition. This strategy doesn't update or delete existing rows, so if you do not filter the data to the most recent records only, it is likely that duplicate records will be inserted.

Example source code:

```
{{ config(
   materialized = 'incremental',
   incremental_strategy='append'
) }}

/* All rows returned by this query will be appended to the existing model */


select * from {{ ref('raw_orders') }}
{% if is_incremental() %}
   where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

Example run code:

```
CREATE DIMENSION TABLE IF NOT EXISTS orders__dbt_tmp AS
SELECT * FROM raw_orders
WHERE order_date > (SELECT MAX(order_date) FROM orders);

INSERT INTO orders VALUES ([columns])
SELECT ([columns])
FROM orders__dbt_tmp;
```

## Seeds behavior[​](#seeds-behavior "Direct link to Seeds behavior")

When running the `dbt seed` command we perform a `DROP CASCADE` operation instead of `TRUNCATE`.

## Practice[​](#practice "Direct link to Practice")

You can look at our modified version of the jaffle\_shop, [jaffle\_shop\_firebolt](https://github.com/firebolt-db/jaffle_shop_firebolt), to see how indexes, as well as external tables, can be set or clone and execute the commands listed in the README.md

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Microsoft Fabric Spark configurations](https://docs.getdbt.com/reference/resource-configs/fabricspark-configs)[Next

Greenplum configurations](https://docs.getdbt.com/reference/resource-configs/greenplum-configs)

* [Setting `quote_columns`](#setting-quote_columns)* [Model configuration for fact tables](#model-configuration-for-fact-tables)* [Model configuration for dimension tables](#model-configuration-for-dimension-tables)* [How aggregating indexes are named](#how-aggregating-indexes-are-named)* [Managing ingestion via external tables](#managing-ingestion-via-external-tables)* [Incremental models](#incremental-models)* [Seeds behavior](#seeds-behavior)* [Practice](#practice)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/firebolt-configs.md)
