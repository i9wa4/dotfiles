---
title: "SingleStore configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/singlestore-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* SingleStore configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fsinglestore-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fsinglestore-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fsinglestore-configs+so+I+can+ask+questions+about+it.)

On this page

## Incremental materialization strategies[​](#incremental-materialization-strategies "Direct link to Incremental materialization strategies")

The [`incremental_strategy` config](https://docs.getdbt.com/docs/build/incremental-models#about-incremental_strategy) controls how dbt builds incremental models. Currently, SingleStoreDB supports only the `delete+insert` configuration.

The `delete+insert` incremental strategy directs dbt to follow a two-step incremental approach. Initially, it identifies and removes the records flagged by the configured `is_incremental()` block. Subsequently, it re-inserts these records.

## Performance Optimizations[​](#performance-optimizations "Direct link to Performance Optimizations")

[SingleStore Physical Database Schema Design documentation](https://docs.singlestore.com/managed-service/en/create-a-database/physical-database-schema-design/concepts-of-physical-database-schema-design.html) is helpful if you want to use specific options (that are described below) in your dbt project.

### Storage type[​](#storage-type "Direct link to Storage type")

SingleStore supports two storage types: **In-Memory Rowstore** and **Disk-based Columnstore** (the latter is default). See [the docs](https://docs.singlestore.com/managed-service/en/create-a-database/physical-database-schema-design/concepts-of-physical-database-schema-design/choosing-a-table-storage-type.html) for details. The dbt-singlestore adapter allows you to specify which storage type your table materialization would rely on using `storage_type` config parameter.

rowstore\_model.sql

```
{{ config(materialized='table', storage_type='rowstore') }}

select ...
```

### Keys[​](#keys "Direct link to Keys")

SingleStore tables are [sharded](https://docs.singlestore.com/managed-service/en/getting-started-with-managed-service/about-managed-service/sharding.html) and can be created with various column definitions. The following options are supported by the dbt-singlestore adapter, each of them accepts `column_list` (a list of column names) as an option value. Please refer to [Creating a Columnstore Table](https://docs.singlestore.com/managed-service/en/create-a-database/physical-database-schema-design/procedures-for-physical-database-schema-design/creating-a-columnstore-table.html) for more informartion on various key types in SingleStore.

* `primary_key` (translated to `PRIMARY KEY (column_list)`)
* `sort_key` (translated to `KEY (column_list) USING CLUSTERED COLUMNSTORE`)
* `shard_key` (translated to `SHARD KEY (column_list)`)
* `unique_table_key` (translated to `UNIQUE KEY (column_list)`)

primary\_and\_shard\_model.sql

```
{{
    config(
        primary_key=['id', 'user_id'],
        shard_key=['id']
    )
}}

select ...
```

unique\_and\_sort\_model.sql

```
{{
    config(
        materialized='table',
        unique_table_key=['id'],
        sort_key=['status'],
    )
}}

select ...
```

### Indexes[​](#indexes "Direct link to Indexes")

Similarly to the Postgres adapter, table models, incremental models, seeds, and snapshots may have a list of `indexes` defined. Each index can have the following components:

* `columns` (list, required): one or more columns on which the index is defined
* `unique` (boolean, optional): whether the index should be declared unique
* `type` (string, optional): a supported [index type](https://docs.singlestore.com/managed-service/en/reference/sql-reference/data-definition-language-ddl/create-index.html), `hash` or `btree`

As SingleStore tables are sharded, there are certain limitations to indexes creation, see the [docs](https://docs.singlestore.com/managed-service/en/create-a-database/physical-database-schema-design/concepts-of-physical-database-schema-design/understanding-keys-and-indexes-in-singlestore.html) for more details.

indexes\_model.sql

```
{{
    config(
        materialized='table',
        shard_key=['id'],
        indexes=[{'columns': ['order_date', 'id']}, {'columns': ['status'], 'type': 'hash'}]
    )
}}

select ...
```

### Other options[​](#other-options "Direct link to Other options")

You can specify the character set and collation for the table using `charset` and/or `collation` options. Supported values for `charset` are `binary`, `utf8`, and `utf8mb4`. Supported values for `collation` can be viewed as the output of `SHOW COLLATION` SQL query. Default collations for the corresponding charcter sets are `binary`, `utf8_general_ci`, and `utf8mb4_general_ci`.

utf8mb4\_model.sql

```
{{
    config(
        charset='utf8mb4',
        collation='utf8mb4_general_ci'
    )
}}

select ...
```

## Model contracts[​](#model-contracts "Direct link to Model contracts")

Starting from 1.5, the `dbt-singlestore` adapter supports model contracts.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Constraint type Support Platform enforcement|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | not\_null ✅ Supported ✅ Enforced|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | primary\_key ✅ Supported ❌ Not enforced|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | foreign\_key ❌ Not supported ❌ Not enforced|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | unique ✅ Supported ❌ Not enforced|  |  |  | | --- | --- | --- | | check ❌ Not supported ❌ Not enforced | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Consider the following restrictions while using contracts with the `dbt-singlestore` adapter:

### Model and Column Definitions:[​](#model-and-column-definitions "Direct link to Model and Column Definitions:")

* The `unique` constraint can only be set at the model level. Hence, do not set it at the column level.
* Repeating constraints will return an error. For example, setting `primary_key` in both column and model settings returns an error.

### Overwriting Settings:[​](#overwriting-settings "Direct link to Overwriting Settings:")

The contract setting overrides the configuration setting. For example, if you define a `primary_key` or `unique_table_key` in the config and then also set it in the contract, the contract setting replaces the configuration setting.

### Working with constants:[​](#working-with-constants "Direct link to Working with constants:")

dim\_customers.yml

```
models:
  - name: dim_customers
    config:
      materialized: table
      contract:
        enforced: true
    columns:
      - name: customer_id
        data_type: int
        constraints:
          - type: not_null
      - name: customer_name
        data_type: text
```

Let's say your model is defined as:

dim\_customers.sql

```
select
  'abc123' as customer_id,
  'My Best Customer' as customer_name
```

When using constants, you must specify the data types directly. If not, SingleStoreDB will automatically choose what it thinks is the most appropriate data type.

dim\_customers.sql

```
select
  ('abc123' :> int) as customer_id,
  ('My Best Customer' :> text) as customer_name
```

### Misleading datatypes[​](#misleading-datatypes "Direct link to Misleading datatypes")

Using `model contracts` ensures that you don't accidentally add the wrong type of data into a column. For instance, if you expect a number in a column, but accidentally specify text to be added, the model contract catches it and returns an error.

The error message may occasionally show a different data type name than expected, because of how the `singlestoredb-python` connector works. For instance,

dim\_customers.sql

```
select
  'abc123' as customer_id,
  ('My Best Customer' :> text) as customer_name
```

will result in

```
Please ensure the name, data_type, and number of columns in your contract match the columns in your model's definition.
| column_name | definition_type | contract_type | mismatch_reason       |
| customer_id | LONGBLOB        | LONG          | data type mismatch    |
```

It's important to note that certain data type mappings might show up differently in error messages, but this doesn't affect how they work. Here's a quick list of what you might see:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Data type Data type returned by singlestoredb-python|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | BOOL TINY|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | INT LONG|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | CHAR BINARY|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | VARCHAR VARBINARY|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | TEXT BLOB|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | TINYTEXT TINYBLOB|  |  |  |  | | --- | --- | --- | --- | | MEDIUMTEXT MEDIUMBLOB|  |  | | --- | --- | | LONGTEXT LONGBLOB | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Just keep these points in mind when setting up and using your `dbt-singlestore` adapter, and you'll avoid common pitfalls!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Redshift configurations](https://docs.getdbt.com/reference/resource-configs/redshift-configs)[Next

Snowflake configurations](https://docs.getdbt.com/reference/resource-configs/snowflake-configs)

* [Incremental materialization strategies](#incremental-materialization-strategies)* [Performance Optimizations](#performance-optimizations)
    + [Storage type](#storage-type)+ [Keys](#keys)+ [Indexes](#indexes)+ [Other options](#other-options)* [Model contracts](#model-contracts)
      + [Model and Column Definitions:](#model-and-column-definitions)+ [Overwriting Settings:](#overwriting-settings)+ [Working with constants:](#working-with-constants)+ [Misleading datatypes](#misleading-datatypes)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/singlestore-configs.md)
