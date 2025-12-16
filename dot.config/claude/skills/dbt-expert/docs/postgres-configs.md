---
title: "Postgres configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/postgres-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Postgres configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fpostgres-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fpostgres-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fpostgres-configs+so+I+can+ask+questions+about+it.)

On this page

## Incremental materialization strategies[​](#incremental-materialization-strategies "Direct link to Incremental materialization strategies")

In dbt-postgres, the following incremental materialization strategies are supported:

* `append` (default when `unique_key` is not defined)
* `merge`
* `delete+insert` (default when `unique_key` is defined)
* [`microbatch`](https://docs.getdbt.com/docs/build/incremental-microbatch)

## Performance optimizations[​](#performance-optimizations "Direct link to Performance optimizations")

### Unlogged[​](#unlogged "Direct link to Unlogged")

"Unlogged" tables can be considerably faster than ordinary tables, as they are not written to the write-ahead log nor replicated to read replicas. They are also considerably less safe than ordinary tables. See [Postgres docs](https://www.postgresql.org/docs/current/sql-createtable.html#SQL-CREATETABLE-UNLOGGED) for details.

my\_table.sql

```
{{ config(materialized='table', unlogged=True) }}

select ...
```

dbt\_project.yml

```
models:
  +unlogged: true
```

### Indexes[​](#indexes "Direct link to Indexes")

While Postgres works reasonably well for datasets smaller than about 10m rows, database tuning is sometimes required. It's important to create indexes for columns that are commonly used in joins or where clauses.

Table models, incremental models, seeds, snapshots, and materialized views may have a list of `indexes` defined. Each Postgres index can have three components:

* `columns` (list, required): one or more columns on which the index is defined
* `unique` (boolean, optional): whether the index should be [declared unique](https://www.postgresql.org/docs/9.4/indexes-unique.html)
* `type` (string, optional): a supported [index type](https://www.postgresql.org/docs/current/indexes-types.html) (B-tree, Hash, GIN, etc)

my\_table.sql

```
{{ config(
    materialized = 'table',
    indexes=[
      {'columns': ['column_a'], 'type': 'hash'},
      {'columns': ['column_a', 'column_b'], 'unique': True},
    ]
)}}

select ...
```

If one or more indexes are configured on a resource, dbt will run `create index` DDL statement(s) as part of that resource's materialization, within the same transaction as its main `create` statement. For the index's name, dbt uses a hash of its properties and the current timestamp, in order to guarantee uniqueness and avoid namespace conflict with other indexes.

```
create index if not exists
"3695050e025a7173586579da5b27d275"
on "my_target_database"."my_target_schema"."indexed_model"
using hash
(column_a);

create unique index if not exists
"1bf5f4a6b48d2fd1a9b0470f754c1b0d"
on "my_target_database"."my_target_schema"."indexed_model"
(column_a, column_b);
```

You can also configure indexes for a number of resources at once:

dbt\_project.yml

```
models:
  project_name:
    subdirectory:
      +indexes:
        - columns: ['column_a']
          type: hash
```

## Materialized views[​](#materialized-views "Direct link to Materialized views")

The Postgres adapter supports [materialized views](https://www.postgresql.org/docs/current/rules-materializedviews.html)
with the following configuration parameters:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Parameter Type Required Default Change Monitoring Support|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`on_configuration_change`](https://docs.getdbt.com/reference/resource-configs/on_configuration_change) `<string>` no `apply` n/a|  |  |  |  |  | | --- | --- | --- | --- | --- | | [`indexes`](#indexes) `[{<dictionary>}]` no `none` alter | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

* Project file* Property file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +materialized: materialized_view
    +on_configuration_change: apply | continue | fail
    +indexes:
      - columns: [<column-name>]
        unique: true | false
        type: hash | btree
```

models/properties.yml

```
models:
  - name: [<model-name>]
    config:
      materialized: materialized_view
      on_configuration_change: apply | continue | fail
      indexes:
        - columns: [<column-name>]
          unique: true | false
          type: hash | btree
```

models/<model\_name>.sql

```
{{ config(
    materialized="materialized_view",
    on_configuration_change="apply" | "continue" | "fail",
    indexes=[
        {
            "columns": ["<column-name>"],
            "unique": true | false,
            "type": "hash" | "btree",
        }
    ]
) }}
```

The [`indexes`](#indexes) parameter corresponds to that of a table, as explained above.
It's worth noting that, unlike tables, dbt monitors this parameter for changes and applies the changes without dropping the materialized view.
This happens via a `DROP/CREATE` of the indexes, which can be thought of as an `ALTER` of the materialized view.

Learn more about these parameters in Postgres's [docs](https://www.postgresql.org/docs/current/sql-creatematerializedview.html).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Oracle configurations](https://docs.getdbt.com/reference/resource-configs/oracle-configs)[Next

Redshift configurations](https://docs.getdbt.com/reference/resource-configs/redshift-configs)

* [Incremental materialization strategies](#incremental-materialization-strategies)* [Performance optimizations](#performance-optimizations)
    + [Unlogged](#unlogged)+ [Indexes](#indexes)* [Materialized views](#materialized-views)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/postgres-configs.md)
