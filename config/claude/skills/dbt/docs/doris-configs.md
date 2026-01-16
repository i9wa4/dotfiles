---
title: "Doris/SelectDB configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/doris-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Doris/SelectDB configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdoris-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdoris-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdoris-configs+so+I+can+ask+questions+about+it.)

On this page

## Models[​](#models "Direct link to Models")

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Type Supported? Details|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | view materialization YES Creates a [view](https://doris.apache.org/docs/sql-manual/sql-reference/Data-Definition-Statements/Create/CREATE-VIEW/).| table materialization YES Creates a [table](https://doris.apache.org/docs/sql-manual/sql-reference/Data-Definition-Statements/Create/CREATE-TABLE/).| incremental materialization YES Creates a table if it doesn't exist, and then item table model must be '[unique](https://doris.apache.org/docs/data-table/data-model#uniq-model/)'. | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### View Materialization[​](#view-materialization "Direct link to View Materialization")

A dbt model can be created as a Doris view and configured using the following syntax:

* Project file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +materialized: view
```

models/<model\_name>.sql

```
{{ config(materialized = "view") }}
```

### Table Materialization[​](#table-materialization "Direct link to Table Materialization")

A dbt model can be created as a [Doris table](https://doris.apache.org/docs/sql-manual/sql-reference/Data-Definition-Statements/Create/CREATE-TABLE/) and configured using the following syntax:

* Project file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +materialized: table
    +duplicate_key: [ <column-name>, ... ],
    +partition_by: [ <column-name>, ... ],
    +partition_type: <engine-type>,
    +partition_by_init: [<pertition-init>, ... ]
    +distributed_by: [ <column-name>, ... ],
    +buckets: int,
    +properties: {<key>:<value>,...}
```

models/<model\_name>.sql

```
{{ config(
    materialized = "table",
    duplicate_key = [ "<column-name>", ... ],
    partition_by = [ "<column-name>", ... ],
    partition_type = "<engine-type>",
    partition_by_init = ["<pertition-init>", ... ]
    distributed_by = [ "<column-name>", ... ],
    buckets = "int",
    properties = {"<key>":"<value>",...}
      ...
    ]
) }}
```

#### Table Configuration[​](#table-configuration "Direct link to Table Configuration")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required?|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `materialized` How the model will be materialized into Doris. Must be `table` to create a table model. Required|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `duplicate_key` The key list of Doris table model :'[duplicate](https://doris.apache.org/docs/data-table/data-model#duplicate-model)'. Required|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `partition_by` The partition key list of Doris. ([Doris partition](https://doris.apache.org/docs/data-table/data-partition)) Optional|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `partition_type` The partition type of Doris. Optional (default: `RANGE`)| `partition_by_init` The partition rule or some real partitions item. Optional|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `distributed_by` The bucket key list of Doris. ([Doris distribute](https://doris.apache.org/docs/data-table/data-partition#partitioning-and-bucket)) Required|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `buckets` The bucket number in one Doris partition. Required|  |  |  | | --- | --- | --- | | `properties` The other configuration of Doris. ([Doris properties](https://doris.apache.org/docs/sql-manual/sql-reference/Data-Definition-Statements/Create/CREATE-TABLE/?&_highlight=properties)) Required | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Incremental Materialization[​](#incremental-materialization "Direct link to Incremental Materialization")

An incremental Doris table, item table model must be 'unique' and is configured using the following syntax:

* Project file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +materialized: incremental
    +unique_key: [ <column-name>, ... ],
    +partition_by: [ <column-name>, ... ],
    +partition_type: <engine-type>,
    +partition_by_init: [<pertition-init>, ... ]
    +distributed_by: [ <column-name>, ... ],
    +buckets: int,
    +properties: {<key>:<value>,...}
```

models/<model\_name>.sql

```
{{ config(
    materialized = "incremental",
    unique_key = [ "<column-name>", ... ],
    partition_by = [ "<column-name>", ... ],
    partition_type = "<engine-type>",
    partition_by_init = ["<pertition-init>", ... ]
    distributed_by = [ "<column-name>", ... ],
    buckets = "int",
    properties = {"<key>":"<value>",...}
      ...
    ]
) }}
```

#### Incremental Table Configuration[​](#incremental-table-configuration "Direct link to Incremental Table Configuration")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required?|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `materialized` How the model will be materialized into Doris. Must be `table` to create a table model. Required|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `unique_key` The key list of Doris table model :'[Doris unique](https://doris.apache.org/docs/data-table/data-model#uniq-model)'. Required|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `partition_by` The partition key list of Doris. ([Doris partition](https://doris.apache.org/docs/data-table/data-partition)) Optional|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `partition_type` The partition type of Doris. Optional (default: `RANGE`)| `partition_by_init` The partition rule or some real partitions item. Optional|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `distributed_by` The bucket key list of Doris. ([Doris distribute](https://doris.apache.org/docs/data-table/data-partition#partitioning-and-bucket)) Required|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `buckets` The bucket number in one Doris partition. Required|  |  |  | | --- | --- | --- | | `properties` The other configuration of Doris. ([Doris properties](https://doris.apache.org/docs/sql-manual/sql-reference/Data-Definition-Statements/Create/CREATE-TABLE/?&_highlight=properties)) Required | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

DeltaStream configurations](https://docs.getdbt.com/reference/resource-configs/deltastream-configs)[Next

DuckDB configurations](https://docs.getdbt.com/reference/resource-configs/duckdb-configs)

* [Models](#models)
  + [View Materialization](#view-materialization)+ [Table Materialization](#table-materialization)+ [Incremental Materialization](#incremental-materialization)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/doris-configs.md)
